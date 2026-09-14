#include "mmult_accel.h"
#include <etc/ap_utils.h>
// [Sửa lỗi C-sim] <ap_utils.h> nằm ở "include/etc/ap_utils.h" trong bản cài Vitis 2025.2, không
// phải "include/ap_utils.h" trực tiếp như ap_int.h — đường include mặc định của project này
// (sinh từ hls_config.cfg, chỉ có "-I .../include") không thấy được, gây "fatal error: 'ap_utils.h'
// file not found" khi chạy C-sim. Thay vì sửa include path (project sinh tự động, dễ bị ghi đè),
// tự định nghĩa macro ap_wait() y hệt logic thật trong
// D:/Xilinx/2025.2/Vitis/include/etc/autopilot_ssdm_op.h (đã đọc trực tiếp để đối chiếu, không
// đoán): synthesis (AESL_SYN) gọi intrinsic _ssdm_op_Wait(1) do frontend HLS tự nhận diện theo
// tên, không cần khai báo thêm; C-sim thường (không AESL_SYN) là no-op hoàn toàn.

/**
 * @brief Matrix multiplication accelerator parameters (Giai đoạn 2)
 *
 * Xem docs/modules/mmult_accel.md và docs/modules/interface_contract.md cho
 * quyết định thiết kế đầy đủ. Compute (MAC) đã chuyển hết sang RTL
 * (SYSTOLIC_CORE_TOP) — file này chỉ còn vai trò "ống dẫn dữ liệu" + tiling
 * cho B/C + bắt tay tile.
 *
 * [SỬA — Hướng B, 2026-08-17, xem docs/modules/mmult_accel.md mục "Hướng B"]
 * Sau 9 lần sửa liên tiếp (SỬA LẦN 1-9) đều treo tại đúng 1 vị trí trong bộ
 * sinh RTL đọc `m_axi` của Vitis HLS cho pattern "vòng lặp lớn (49152 lần)
 * vừa đọc AXI vừa ghi BRAM" — không phụ thuộc cách viết C++ (đã thử: gộp
 * phẳng, DATAFLOW/hls::stream, mảng tĩnh đơn giản kiểu bài báo gốc, đủ loại
 * pragma burst/trip-count/điều kiện). Kết luận: đây là hạn chế/lỗi thật của
 * chính công cụ, không sửa được bằng cách viết lại C++. Đã bỏ hẳn việc đọc A
 * khỏi HLS — chuyển sang module RTL tự viết `AXI4_A_READER`
 * (src/axi4_a_reader.v), nối trực tiếp vào 64 khối `DUAL_PORT_BRAM_8B` (bank
 * A) trong Block Design, không qua Vitis HLS. `A` vẫn còn là tham số (giữ
 * nguyên hợp đồng phần mềm PYNQ) nhưng chỉ lấy giá trị địa chỉ qua
 * `s_axilite`, xuất ra `a_base_addr_o` cho RTL tự đọc — không có `m_axi`
 * cho A nữa.
 *
 * [SỬA — Hướng B tiếp, 2026-08-17, xem docs/modules/axi4_b_reader.md] Stage 2
 * (`tb_integration_top.sv`) bắt được bằng chứng RTL thật: `copy_B_block` và
 * `tile_i` được HLS khởi động `ap_start` CÙNG 1 CYCLE (vì `b_bank<n>` là cổng
 * ghi thẳng, HLS không thấy phụ thuộc dữ liệu C++ nào giữa 2 vùng) —
 * `copy_B_block` không bao giờ báo `ap_done` thật. Đã bỏ hẳn việc đọc B khỏi
 * HLS luôn — chuyển sang module RTL tự viết `AXI4_B_READER`
 * (src/axi4_b_reader.v), đọc lại mỗi lần đổi `j_block` (khác A chỉ đọc 1
 * lần/call). `B` cũng đổi sang `B_addr` (địa chỉ số nguyên, không còn `m_axi`)
 * — cùng lý do/cách làm với `A_addr` ở SỬA LẦN 11.
 *
 * [BUGFIX — SỬA LẦN 13, 2026-08-18, xem docs/modules/mmult_accel.md] Sau khi
 * Hướng B (A+B) hết treo, Verification bắt được bằng chứng RTL thật
 * (`[GMEMC-WDATA]`): `writeC` ghi ra DDR giá trị 0 dù `c_arr` tại nguồn
 * (SYSTOLIC_CORE_TOP, qua `[TILE-CAPTURE]`) đúng. Cùng họ lỗi với
 * `tile_valid_o`/`tile_done_i` (SỬA LẦN 10 cũ) — `c_arr` là cổng `ap_none`
 * đọc từ ngoài nhưng thiếu `volatile`, khiến Vitis HLS có thể lập lịch/tối ưu
 * đọc sai thời điểm (đọc trước khi giá trị thật ổn định, hoặc dùng giá trị đã
 * "chốt" từ trước). Đã thêm `volatile` cho `c_arr` — khớp đúng mẫu đã sửa cho
 * `tile_ready_i`/`tile_done_i`/`a_loaded_i`/`b_loaded_i`.
 *
 * [SỬA LẦN 16 — 2026-08-18, xem docs/modules/axi4_c_writer.md] SỬA LẦN 14
 * (tách capture_c ra vòng PIPELINE riêng) và SỬA LẦN 15 (đưa capture_c vào
 * trong PROTOCOL fixed dùng ap_wait()) đều KHÔNG giải quyết được — log
 * C-synthesis xác nhận Vitis HLS vẫn tự động pipeline hoá capture_c
 * (`Final II=1`) bất kể `ap_wait()`, `PROTOCOL fixed` không cưỡng chế được
 * đối với vòng lặp. Đã bỏ hẳn `c_arr`/`writeC`/`capture_c`/con trỏ `C` khỏi
 * HLS — chuyển hẳn sang module RTL tự viết `AXI4_C_WRITER`
 * (src/axi4_c_writer.v), đọc trực tiếp `c_o` từ `SYSTOLIC_CORE_TOP` ngay lúc
 * `tile_done_o` (đã xác nhận đúng 100% qua waveform thật) và tự ghi ra DDR —
 * cùng hướng đã áp dụng thành công cho A và B. `C` đổi sang `C_addr` (địa chỉ
 * số nguyên, không còn `m_axi`/con trỏ) — cùng lý do/cách làm `A_addr`.
 */
#define DO_PRAGMA(x) _Pragma(#x)

extern "C"
{
    void mmult_accel(
        ap_uint<32> A_addr, ap_uint<32> B_addr, ap_uint<32> C_addr,
        int N, int K, int M, int update_A,
        bool &tile_i_sel_o,
        ap_uint<3> &tile_j_sel_o,
        volatile bool &tile_valid_o, volatile bool &tile_ready_i, volatile bool &tile_done_i,
        ap_uint<32> &a_base_addr_o,
        volatile bool &a_reload_req_o, volatile bool &a_loaded_i,
        ap_uint<32> &b_base_addr_o, ap_uint<32> &b_row_stride_o,
        ap_uint<16> &b_num_rows_o, ap_uint<16> &b_block_width_o,
        volatile bool &b_reload_req_o, volatile bool &b_loaded_i,
        ap_uint<32> &c_base_addr_o, ap_uint<32> &c_row_stride_o,
        ap_uint<16> &c_global_i0_o, ap_uint<16> &c_global_j0_o,
        ap_uint<16> &c_valid_rows_o, ap_uint<16> &c_valid_cols_o,
        volatile bool &c_write_done_i)
    {
        // A_addr/B_addr: KHÔNG còn con trỏ — chỉ s_axilite, số nguyên thuần.
        // [SỬA LẦN 11 — 2026-08-17] Bản trước dùng `const DTYPE_IN *A` rồi ép
        // `(ap_uint<32>)(size_t)A` để lấy địa chỉ -> Vitis HLS báo lỗi thật lúc
        // C-synthesis: "SYNCHK 200-41: unsupported pointer reinterpretation
        // from type 'i8*' to type 'int'" (ép kiểu con trỏ->số nguyên không
        // synthesize được, dù C-sim compile/chạy bình thường vì dùng compiler
        // C++ chuẩn). Đổi hẳn tham số sang `ap_uint<32>` ngay từ đầu, không ép
        // kiểu gì nữa — driver PYNQ (D2) phải tự tính địa chỉ vật lý buffer
        // A/B rồi truyền số nguyên, xem docs/modules/mmult_accel.md.
        #pragma HLS INTERFACE s_axilite port = A_addr bundle = control
        #pragma HLS INTERFACE s_axilite port = B_addr bundle = control
        #pragma HLS INTERFACE s_axilite port = C_addr bundle = control

        #pragma HLS INTERFACE s_axilite port = N bundle = control
        #pragma HLS INTERFACE s_axilite port = K bundle = control
        #pragma HLS INTERFACE s_axilite port = M bundle = control
        #pragma HLS INTERFACE s_axilite port = update_A bundle = control
        #pragma HLS INTERFACE s_axilite port = return bundle = control

        #pragma HLS INTERFACE ap_none port = tile_i_sel_o
        #pragma HLS INTERFACE ap_none port = tile_j_sel_o
        #pragma HLS INTERFACE ap_none port = tile_valid_o
        #pragma HLS INTERFACE ap_none port = tile_ready_i
        #pragma HLS INTERFACE ap_none port = tile_done_i
        #pragma HLS INTERFACE ap_none port = a_base_addr_o
        #pragma HLS INTERFACE ap_none port = a_reload_req_o
        #pragma HLS INTERFACE ap_none port = a_loaded_i
        #pragma HLS INTERFACE ap_none port = b_base_addr_o
        #pragma HLS INTERFACE ap_none port = b_row_stride_o
        #pragma HLS INTERFACE ap_none port = b_num_rows_o
        #pragma HLS INTERFACE ap_none port = b_block_width_o
        #pragma HLS INTERFACE ap_none port = b_reload_req_o
        #pragma HLS INTERFACE ap_none port = b_loaded_i
        #pragma HLS INTERFACE ap_none port = c_base_addr_o
        #pragma HLS INTERFACE ap_none port = c_row_stride_o
        #pragma HLS INTERFACE ap_none port = c_global_i0_o
        #pragma HLS INTERFACE ap_none port = c_global_j0_o
        #pragma HLS INTERFACE ap_none port = c_valid_rows_o
        #pragma HLS INTERFACE ap_none port = c_valid_cols_o
        #pragma HLS INTERFACE ap_none port = c_write_done_i

        // Xuất địa chỉ DDR của A cho AXI4_A_READER (RTL) tự đọc — A_addr đã là
        // số nguyên sẵn (không còn ép kiểu con trỏ), gán thẳng.
        a_base_addr_o = A_addr;

        // [SỬA LẦN 16] Xuất địa chỉ DDR của C + M (row stride) cho AXI4_C_WRITER
        // — cả 2 không đổi trong suốt 1 lần gọi, chỉ cần gán 1 lần ở đây.
        c_base_addr_o  = C_addr;
        c_row_stride_o = (ap_uint<32>)M;

        // Bắt tay nạp A với AXI4_A_READER — cùng mẫu đã kiểm chứng đúng với
        // tile_valid_o/tile_ready_i/tile_done_i (volatile& + ap_wait() +
        // PROTOCOL fixed, tránh Vitis HLS tối ưu mất phép gán do không đọc lại
        // trong C++ — xem lịch sử bug "tile_valid_o hard-code 0",
        // docs/feedback_to_spec.md). Chỉ chờ khi update_A=1 — update_A=0 thì
        // dùng lại dữ liệu A đã nạp từ lần gọi trước, không request nạp lại.
        if (update_A) {
            #pragma HLS PROTOCOL fixed

            a_reload_req_o = true;
            ap_wait();

            wait_a_loaded:
            while (!a_loaded_i) {
                ap_wait();
            }

            a_reload_req_o = false;
            ap_wait();
        }

        //--------------------------------------------------------------
        // Vòng lặp block cột B — [SỬA — Hướng B tiếp, 2026-08-17] đã bỏ hẳn
        // copy_B_block (đọc AXI + ghi 32 bank) khỏi HLS, chuyển sang
        // AXI4_B_READER (RTL). Mỗi lần đổi j_block: cấp địa chỉ/kích thước
        // block hiện tại rồi bắt tay y hệt mẫu đã kiểm chứng của A
        // (a_reload_req_o/a_loaded_i) — chỉ khác là bắt tay này lặp lại MỖI
        // vòng j_block (không chỉ 1 lần/call như A).
        //--------------------------------------------------------------
        outer_j_block:
        for (int j_block = 0; j_block < M; j_block += BLOCK_M) {
            int current_block_M = ((j_block + BLOCK_M) <= M) ? BLOCK_M : (M - j_block);

            b_base_addr_o   = B_addr + (ap_uint<32>)j_block;
            b_row_stride_o  = (ap_uint<32>)M;
            b_num_rows_o    = (ap_uint<16>)K;
            b_block_width_o = (ap_uint<16>)current_block_M;

            {
                #pragma HLS PROTOCOL fixed

                b_reload_req_o = true;
                ap_wait();

                wait_b_loaded:
                while (!b_loaded_i) {
                    ap_wait();
                }

                b_reload_req_o = false;
                ap_wait();
            }

            tile_i:
            for (int i0 = 0; i0 < N; i0 += TILE_SIZE) {
                tile_j:
                for (int j0 = 0; j0 < current_block_M; j0 += TILE_SIZE) {

                    // N=64=2*TILE_SIZE cố định ở Giai đoạn 2 -> chỉ 2 nửa.
                    tile_i_sel_o = (i0 != 0);
                    // BLOCK_M=256=8*TILE_SIZE -> 8 nhóm cột/block, khớp đúng
                    // "jj" AXI4_B_READER dùng khi rải B vào bank (RTL, không
                    // còn trong HLS — xem src/axi4_b_reader.v).
                    tile_j_sel_o = (ap_uint<3>)(j0 / TILE_SIZE);

                    // [SỬA LẦN 16] Toạ độ + kích thước hợp lệ của tile hiện
                    // tại, cấp cho AXI4_C_WRITER — cùng công thức boundary
                    // check đã dùng trong writeC cũ (global_i<N &&
                    // global_j<current_block_M), tính sẵn số hàng/cột hợp lệ
                    // thay vì để RTL tự kiểm tra từng phần tử.
                    c_global_i0_o   = (ap_uint<16>)i0;
                    c_global_j0_o   = (ap_uint<16>)(j_block + j0);
                    c_valid_rows_o  = (ap_uint<16>)((N - i0 < TILE_SIZE) ? (N - i0) : TILE_SIZE);
                    c_valid_cols_o  = (ap_uint<16>)((current_block_M - j0 < TILE_SIZE)
                                                     ? (current_block_M - j0) : TILE_SIZE);

                    // Bắt tay tile với SYSTOLIC_CORE_TOP — đã sửa xong (bug
                    // "tile_valid_o hard-code 0" + bug "không tụt về 0"), xem
                    // docs/feedback_to_spec.md và docs/bug_history.md #22.
                    //
                    // [SỬA LẦN 16 — 2026-08-18, xem docs/modules/axi4_c_writer.md]
                    // SỬA LẦN 13-15 (thêm volatile, tách vòng đọc c_arr,
                    // ép PROTOCOL fixed) đều KHÔNG giải quyết được việc đọc
                    // c_arr đúng thời điểm trong writeC — log C-synthesis xác
                    // nhận Vitis HLS vẫn tự pipeline hoá vòng đọc bất kể
                    // ap_wait()/PROTOCOL fixed. Đã bỏ hẳn c_arr/writeC khỏi
                    // HLS, chuyển sang AXI4_C_WRITER (RTL) — module đó tự đọc
                    // trực tiếp c_o từ SYSTOLIC_CORE_TOP ngay lúc tile_done_o,
                    // không qua Vitis HLS. Ở đây chỉ cần thêm đúng 1 bước chờ
                    // c_write_done_i (bool đơn, không phải mảng/vòng lặp —
                    // cùng mẫu while(!x){ap_wait();} đã hoạt động đúng cho
                    // mọi bắt tay bool khác trong file này) trước khi cho
                    // phép tile kế tiếp bắt đầu.
                    {
                        #pragma HLS PROTOCOL fixed

                        wait_tile_ready:
                        while (!tile_ready_i) {
                            ap_wait();
                        }

                        tile_valid_o = true;
                        ap_wait();

                        wait_tile_done:
                        while (!tile_done_i) {
                            ap_wait();
                        }

                        tile_valid_o = false;
                        ap_wait();

                        wait_c_write_done:
                        while (!c_write_done_i) {
                            ap_wait();
                        }
                    }
                    // Không còn writeC ở đây — AXI4_C_WRITER (RTL) đã tự ghi
                    // C ra DDR trong lúc chờ c_write_done_i ở trên.
                }
            }
        }
    }
}
