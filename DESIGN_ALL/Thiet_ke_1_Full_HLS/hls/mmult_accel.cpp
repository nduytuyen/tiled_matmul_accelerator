// ============================================================================
// GHI CHÚ: bản này được chú thích thêm (tiếng Việt) để đọc lại dễ hơn,
// KHÔNG dùng để tổng hợp/build lại — bản gốc dùng để build nằm ở gốc repo
// (mmult_accel.cpp) và trong mmult_accel_hls/. File này chỉ để tham khảo.
// ============================================================================

#include <ap_int.h>       // kiểu số nguyên độ rộng tùy ý của Xilinx (ap_int<N>) — ở đây không dùng trực tiếp
                           // nhưng include sẵn phòng khi cần khai báo kiểu bit-width lẻ
#include <hls_stream.h>    // kiểu hls::stream<T> (FIFO phần cứng) — file này cũng không dùng trực tiếp,
                           // include theo thói quen chuẩn của project Vitis HLS
#include <stdint.h>        // kiểu số nguyên chuẩn C (int8_t, int32_t...) — chính là kiểu A/B/C dùng bên dưới

/**
 * @brief Matrix multiplication accelerator parameters
 *
 * These parameters define the maximum dimensions supported by the accelerator
 * and are constrained by available FPGA resources (particularly BRAM).
 */
// #define ở đây là MACRO — trình biên dịch thay thế trực tiếp (copy-paste) trước khi build,
// không phải biến thật, không tốn tài nguyên phần cứng, chỉ là "hằng số đặt tên".
#define MAX_N 64    // Maximum number of rows in matrix A and output C
#define MAX_K 768   // Maximum shared dimension between matrices A and B
#define MAX_M 768   // Maximum number of columns in matrix B and output C
// 3 số này là KÍCH THƯỚC TỐI ĐA (chỉ để cấp phát bộ nhớ BRAM đủ lớn lúc tổng hợp),
// KHÔNG PHẢI kích thước thật lúc chạy — kích thước thật lấy từ tham số N,K,M truyền vào hàm.

/**
 * @brief Memory blocking parameter for column-wise processing
 *
 * For efficient memory usage, matrix B is processed in blocks of BLOCK_M columns.
 * This reduces on-chip memory requirements while maintaining high throughput.
 */
#define BLOCK_M 256   // mỗi lần chỉ nạp 256 cột của B vào BRAM (thay vì nạp hết M=768/3072 cột)

/**
 * @brief Computation tile size for enhanced parallelism
 *
 * The tile size determines the dimensions of local buffers used during computation.
 * Larger values increase parallelism but require more FPGA resources.
 */
// const int (khác #define): đây là BIẾN THẬT có kiểu dữ liệu, được trình biên dịch kiểm tra kiểu,
// nhưng vẫn là hằng số (const = không đổi được sau khi gán). Cách dùng const int cho hằng số
// là "hiện đại" hơn #define vì an toàn kiểu (type-safe) hơn.
const int TILE_SIZE = 32;   // 1 tile tính toán = 32x32 phần tử (khớp T=32 đã học ở phần lý thuyết)

/**
 * @brief Data type definitions for input and output matrices
 *
 * Using int8_t for inputs enables efficient storage and computation.
 * int32_t for outputs provides sufficient dynamic range for accumulated results.
 */
#define DTYPE_IN int8_t     // kiểu dữ liệu A, B: số nguyên có dấu 8-bit (-128..127) — đúng kiểu lượng tử hóa
#define DTYPE_OUT int32_t   // kiểu dữ liệu C: số nguyên có dấu 32-bit — đủ rộng để cộng dồn (accumulate) không tràn số

// extern "C" { ... }: báo cho trình biên dịch C++ ĐỪNG "name-mangle" (đổi tên nội bộ) hàm bên trong.
// Bình thường C++ tự đổi tên hàm (kèm thông tin kiểu tham số) để hỗ trợ overload;
// nhưng Vitis HLS cần thấy đúng tên hàm gốc "mmult_accel" để sinh đúng tên cổng phần cứng/driver.
// => Luôn cần extern "C" khi viết hàm top-level cho Vitis HLS.
extern "C"
{
    /**
     * @brief Matrix multiplication accelerator with persistent on-chip storage
     *
     * This function implements an optimized matrix multiplication (C = A×B) where:
     * - Matrix A can be persistent in on-chip memory between calls
     * - Processing is tiled and blocked for optimal FPGA resource utilization
     * - Computation is highly parallelized within each tile
     *
     * @param A Input matrix A [N×K] (row-major)
     * @param B Input matrix B [K×M] (row-major)
     * @param C Output matrix C [N×M] (row-major)
     * @param N Number of rows in matrix A and output C
     * @param K Shared dimension between matrices A and B
     * @param M Number of columns in matrix B and output C
     * @param update_A Flag to control reloading of matrix A (1=reload, 0=reuse)
     */
    // const DTYPE_IN *A: con trỏ (pointer) trỏ tới vùng nhớ chứa mảng A, "const" nghĩa là
    // hàm này CHỈ ĐỌC A, không được ghi/sửa giá trị A qua con trỏ này (trình biên dịch sẽ báo lỗi nếu cố ghi).
    // "row-major" nghĩa là dữ liệu 2 chiều được lưu phẳng (1 chiều) theo từng HÀNG liên tiếp —
    // ví dụ A[i][k] thật ra nằm ở A[i*K + k] trong bộ nhớ (không có mảng 2 chiều thật trong DDR).
    void mmult_accel(const DTYPE_IN *A, const DTYPE_IN *B, DTYPE_OUT *C,
                     int N, int K, int M, int update_A)
    {
        //********************************************************************
        // AXI Memory Interface Configuration:
        // Connects matrices A, B, C to external memory through separate channels
        // with specified depth limits for memory transfers
        //********************************************************************
        // #pragma HLS ...: đây KHÔNG PHẢI code C++ thường — là "chỉ thị" (directive) riêng của
        // Vitis HLS, chỉ tồn tại lúc TỔNG HỢP (biên dịch C++ -> RTL), không sinh ra phép tính nào.
        // Nó ra lệnh cho HLS: "sinh phần cứng giao tiếp kiểu này cho tham số này".
        //
        // INTERFACE m_axi: biến con trỏ A thành 1 cổng AXI4 MASTER thật (đọc/ghi DDR qua burst).
        //   port=A        -> áp dụng cho tham số A
        //   offset=slave  -> địa chỉ gốc của A (giá trị con trỏ, 64-bit) được nạp qua AXI4-LITE
        //                    (xem khối s_axilite bên dưới), không qua chính cổng AXI4 này
        //   bundle=gmemA  -> đặt tên cổng vật lý riêng "gmemA"; B và C dùng tên khác (gmemB, gmemC)
        //                    => sinh ra 3 CỔNG AXI4 MASTER ĐỘC LẬP, chạy song song được, không tranh bus
        //   depth=MAX_N*MAX_K -> chỉ để công cụ mô phỏng (csim) biết kích thước tối đa của A,
        //                        không phải giới hạn phần cứng thật lúc chạy
        #pragma HLS INTERFACE m_axi port = A offset = slave bundle = gmemA depth = MAX_N * MAX_K
        #pragma HLS INTERFACE m_axi port = B offset = slave bundle = gmemB depth = MAX_K * MAX_M
        #pragma HLS INTERFACE m_axi port = C offset = slave bundle = gmemC depth = MAX_N * MAX_M

        //********************************************************************
        // AXI-Lite Control Interface Configuration:
        // Provides host control over function parameters and execution state
        //********************************************************************
        // INTERFACE s_axilite: biến tham số thành 1 THANH GHI trong cổng AXI4-LITE SLAVE
        // (tên cổng gộp chung "control"). PS (CPU) sẽ ghi/đọc các thanh ghi này qua PYNQ.
        //   - A, B, C ở đây là ĐỊA CHỈ GỐC (con trỏ) của 3 vùng nhớ — khác với m_axi ở trên
        //     (m_axi là luồng DỮ LIỆU tại địa chỉ đó). Đây chính là lý do A/B/C xuất hiện 2 lần.
        //   - N, K, M, update_A: tham số điều khiển bình thường, cũng thành thanh ghi 32-bit.
        //   - port=return: ứng với tín hiệu điều khiển thực thi ap_start/ap_done/ap_idle/ap_ready
        //     (không phải giá trị trả về — hàm này kiểu void, không return gì cả).
        
        #pragma HLS INTERFACE s_axilite port = A bundle = control
        #pragma HLS INTERFACE s_axilite port = B bundle = control
        #pragma HLS INTERFACE s_axilite port = C bundle = control
        #pragma HLS INTERFACE s_axilite port = N bundle = control
        #pragma HLS INTERFACE s_axilite port = K bundle = control
        #pragma HLS INTERFACE s_axilite port = M bundle = control
        #pragma HLS INTERFACE s_axilite port = update_A bundle = control
        #pragma HLS INTERFACE s_axilite port = return bundle = control

        //********************************************************************
        // Persistent On-Chip Storage for Matrix A:
        // Static allocation ensures data persistence across function calls
        // Dual-port BRAM implementation enables parallel access
        //********************************************************************
        // static: từ khóa C++ chuẩn (không riêng HLS) — biến "static" bên trong 1 hàm sẽ
        // GIỮ NGUYÊN GIÁ TRỊ giữa các lần gọi hàm (không bị khởi tạo lại mỗi lần gọi như biến thường).
        // => Đây chính là cơ chế cho phép A_bram còn giữ dữ liệu A của lượt gọi TRƯỚC,
        //    nên khi update_A=0 thì không cần nạp lại A từ DDR nữa.
        // DTYPE_IN A_bram[MAX_N][MAX_K]: khai báo mảng 2 chiều 64x768 phần tử int8_t.
        static DTYPE_IN A_bram[MAX_N][MAX_K];
        // BIND_STORAGE: ra lệnh cho HLS TỔNG HỢP mảng này thành BRAM vật lý (không phải
        // dùng flip-flop/LUTRAM). type=ram_2p = bộ nhớ 2 CỔNG (Read/Write độc lập, truy cập
        // song song được), impl=bram = ép dùng khối BRAM cứng có sẵn trên FPGA (không phải LUTRAM mềm).
        #pragma HLS BIND_STORAGE variable=A_bram type=ram_2p impl=bram

        // Conditionally reload matrix A from external memory to on-chip BRAM
        // This optimization allows reusing A across multiple calculations
        if(update_A)   // if thường của C++: chỉ chạy khối nạp A khi cờ update_A != 0
        {
            copy_A:   // đây là NHÃN (label) đặt tên cho vòng lặp — không ảnh hưởng logic chạy,
                      // chỉ giúp đọc report/RTL sinh ra dễ tìm đúng vòng lặp này (thấy tên "copy_A"
                      // thay vì "loop 1, loop 2..."). Bắt buộc phải có dấu ":" sau tên nhãn.
            for (int i = 0; i < N; i++) {
                for (int k = 0; k < K; k++) {
                    // PIPELINE II=1: ra lệnh cho HLS làm cho vòng lặp này CHẢY ỐNG (pipeline) —
                    // nghĩa là 1 lần lặp mới được PHÁT ĐỘNG mỗi 1 chu kỳ (Initiation Interval = 1),
                    // dù bản thân 1 lần lặp có thể mất nhiều chu kỳ để hoàn tất (độ trễ/latency riêng).
                    // Không có pragma này, HLS mặc định chạy TUẦN TỰ (lặp xong hết mới sang lặp kế) — rất chậm.
                    #pragma HLS PIPELINE II=1
                    A_bram[i][k] = A[i * K + k];   // đọc A theo kiểu row-major (đã giải thích ở trên)
                }
            }
        }

        //********************************************************************
        // Block-based Processing of Matrix B:
        // Process matrix B in column blocks to optimize memory usage
        // Each block is loaded into on-chip BRAM for efficient access
        //********************************************************************
        outer_j_block:
        // j_block += BLOCK_M: mỗi vòng nhảy đúng 256 cột (thay vì +1 như vòng lặp thường)
        for (int j_block = 0; j_block < M; j_block += BLOCK_M) {
            // Toán tử 3 ngôi (ternary) "?:" — cú pháp rút gọn của if/else:
            //   dieu_kien ? gia_tri_neu_dung : gia_tri_neu_sai
            // Ở đây: nếu khối tiếp theo còn đủ 256 cột thì dùng đủ BLOCK_M,
            // nếu không (khối cuối cùng, M không chia hết cho 256) thì chỉ lấy phần còn lại (M - j_block).
            int current_block_M = ((j_block + BLOCK_M) <= M) ? BLOCK_M : (M - j_block);

            // Allocate on-chip storage for current block of matrix B
            // Mảng này khai báo BÊN TRONG vòng lặp (không có "static") — về mặt phần cứng,
            // HLS vẫn tổng hợp thành đúng 1 khối BRAM cố định (không thật sự "cấp phát lại" mỗi vòng
            // như phần mềm chạy trên CPU) — chỉ là quy ước code cho dễ đọc (biến chỉ dùng trong scope này).
            DTYPE_IN B_bram[MAX_K][BLOCK_M];
            #pragma HLS BIND_STORAGE variable=B_bram type=ram_2p impl=bram

            // Load current block of matrix B into on-chip BRAM
            copy_B_block:
            for (int k = 0; k < K; k++) {
                for (int j = 0; j < current_block_M; j++) {
                    #pragma HLS PIPELINE II=1
                    B_bram[k][j] = B[k * M + (j_block + j)];   // B[k][j_block+j] dạng row-major
                }
            }

            //****************************************************************
            // Tiled Matrix Multiplication:
            // Divide computation into tiles for both row and column dimensions
            // This approach optimizes data reuse and computation parallelism
            //****************************************************************
            tile_i:
            for (int i0 = 0; i0 < N; i0 += TILE_SIZE) {       // nhảy theo từng tile 32 hàng
                tile_j:
                for (int j0 = 0; j0 < current_block_M; j0 += TILE_SIZE) {   // nhảy theo từng tile 32 cột

                    // Allocate and partition register array for output tile
                    // Complete partitioning transforms the array into individual registers
                    // for maximum parallel access
                    // localC: mảng 32x32 int32_t — đây LÀ 1024 THANH GHI RIÊNG (không phải BRAM),
                    // nhờ ARRAY_PARTITION bên dưới.
                    DTYPE_OUT localC[TILE_SIZE][TILE_SIZE];
                    // ARRAY_PARTITION ... complete: "xé" mảng thành từng PHẦN TỬ RIÊNG LẺ,
                    // mỗi phần tử = 1 flip-flop/thanh ghi độc lập, truy cập được ĐỒNG THỜI
                    // (không bị giới hạn chỉ 1-2 cổng đọc/ghi như BRAM). dim=0 nghĩa là partition
                    // hết TẤT CẢ các chiều của mảng (cả 2 chiều 32x32 => 1024 thanh ghi độc lập).
                    // Đây là cơ sở phần cứng để 1024 phép nhân-cộng chạy song song thật sự trong compute loop.
                    #pragma HLS ARRAY_PARTITION variable=localC dim=0 complete

                    // Initialize output tile to zero
                    // Full unrolling enables parallel initialization of all elements
                    init_c:
                    for (int ii = 0; ii < TILE_SIZE; ii++) {
                        // UNROLL: "trải phẳng" vòng lặp — HLS sinh ra 32 (hoặc 32x32) bản sao
                        // phần cứng chạy CÙNG 1 CHU KỲ, thay vì lặp lại cùng 1 khối phần cứng 32 lần.
                        // Cần ARRAY_PARTITION đi kèm (như localC ở trên) thì UNROLL mới thật sự song song được —
                        // nếu không, dù unroll code, phần cứng vẫn bị "nghẽn cổ chai" ở số cổng BRAM ít ỏi.
                        #pragma HLS UNROLL
                        for (int jj = 0; jj < TILE_SIZE; jj++) {
                            #pragma HLS UNROLL
                            localC[ii][jj] = 0;
                        }
                    }

                    // Allocate and partition register arrays for input tiles
                    // Complete partitioning enables parallel access to all elements
                    DTYPE_IN localA[TILE_SIZE][TILE_SIZE];
                    DTYPE_IN localB[TILE_SIZE][TILE_SIZE];
                    #pragma HLS ARRAY_PARTITION variable=localA dim=0 complete
                    #pragma HLS ARRAY_PARTITION variable=localB dim=0 complete
                    // => localA, localB, localC cộng lại đúng 2048 (localA+localB) + 1024 (localC)
                    //    thanh ghi cục bộ đã nhắc ở phần lý thuyết (S3 nạp 2048 thanh ghi, S4 dùng 1024 PE).

                    //****************************************************************
                    // K-dimension Tiling:
                    // Process shared dimension K in tiles to maximize data reuse
                    // For each K-tile, load data into local buffers then compute
                    //****************************************************************
                    k_loop:
                    for (int k0 = 0; k0 < K; k0 += TILE_SIZE) {   // 24 vòng (K/32) đã nhắc ở phần lý thuyết
                        // Load tile from matrix A into local buffer
                        // Pipelined implementation balances throughput and resource usage
                        loadA:
                        for (int ii = 0; ii < TILE_SIZE; ii++) {
                            for (int kk = 0; kk < TILE_SIZE; kk++) {
                                #pragma HLS PIPELINE II=1
                                int global_i = i0 + ii;
                                int global_k = k0 + kk;
                                // Kiểm tra biên (boundary check): nếu N hoặc K không chia hết cho 32,
                                // tile cuối sẽ "thừa ra" ngoài kích thước thật — gán 0 cho phần thừa
                                // để không đọc tràn mảng và không làm sai kết quả tích lũy.
                                if (global_i < N && global_k < K)
                                    localA[ii][kk] = A_bram[global_i][global_k];
                                else
                                    localA[ii][kk] = 0;
                            }
                        }

                        // Load tile from matrix B into local buffer
                        // Pipelined for efficient memory access
                        loadB:
                        for (int kk = 0; kk < TILE_SIZE; kk++) {
                            for (int jj = 0; jj < TILE_SIZE; jj++) {
                                #pragma HLS PIPELINE II=1
                                int global_k = k0 + kk;
                                int global_j = j0 + jj;
                                if (global_k < K && global_j < current_block_M)
                                    localB[kk][jj] = B_bram[global_k][global_j];
                                else
                                    localB[kk][jj] = 0;
                            }
                        }

                        // Compute matrix multiplication for current tile
                        // Highly optimized with pipelining and unrolling for maximum throughput
                        compute:
                        for (int kk = 0; kk < TILE_SIZE; kk++) {
                            // Vòng ngoài (kk) chỉ PIPELINE (chạy nối tiếp nhưng chồng gối theo chu kỳ),
                            // 2 vòng trong (ii, jj) UNROLL hoàn toàn => mỗi chu kỳ của kk thực hiện
                            // ĐỒNG THỜI 32x32 = 1024 phép nhân-cộng — đúng "1024 PE song song" đã học.
                            #pragma HLS PIPELINE II=1
                            for (int ii = 0; ii < TILE_SIZE; ii++) {
                                #pragma HLS UNROLL
                                // Pre-load and cast A value to output type once per iteration
                                // (DTYPE_OUT)... : ép kiểu (type cast) tường minh từ int8_t sang int32_t
                                // TRƯỚC khi nhân, để phép nhân/cộng thực hiện đúng ở độ rộng 32-bit
                                // (tránh tràn số nếu nhân ở 8-bit rồi mới mở rộng).
                                DTYPE_OUT a_val = (DTYPE_OUT)localA[ii][kk];
                                for (int jj = 0; jj < TILE_SIZE; jj++) {
                                    #pragma HLS UNROLL
                                    // Cast B value to output type and accumulate product
                                    DTYPE_OUT b_val = (DTYPE_OUT)localB[kk][jj];
                                    // += : toán tử cộng-dồn (localC[ii][jj] = localC[ii][jj] + a_val*b_val)
                                    // Đây chính là phép MAC (multiply-accumulate) của từng PE.
                                    localC[ii][jj] += a_val * b_val;
                                }
                            }
                        }
                    } // End of k_loop

                    // Write computed tile back to external memory
                    // Boundary checking ensures valid data only is written
                    writeC:
                    for (int ii = 0; ii < TILE_SIZE; ii++) {
                        for (int jj = 0; jj < TILE_SIZE; jj++) {
                            #pragma HLS PIPELINE II=1
                            int global_i = i0 + ii;
                            int global_j = j0 + jj;
                            if (global_i < N && global_j < current_block_M)
                                C[global_i * M + (j_block + global_j)] = localC[ii][jj];   // ghi C row-major
                        }
                    }
                }
            }
        }
    }
}
