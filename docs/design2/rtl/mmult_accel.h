#ifndef MMULT_ACCEL_H
#define MMULT_ACCEL_H

#include <ap_int.h>
#include <stdint.h>

/**
 * @brief Khai bao dung chung giua mmult_accel.cpp (implementation) va
 * testbench (02_verification/bench/tb_mmult_accel_hls.cpp).
 *
 * Tach rieng ra header de testbench khong phai #include truc tiep
 * mmult_accel.cpp (tranh dinh nghia ham mmult_accel 2 lan trong 2 translation
 * unit khac nhau -> "duplicate symbol" luc link, vi mmult_accel.cpp da duoc
 * bien dich rieng qua syn.file trong hls_config.cfg).
 */
#define MAX_N 64
#define MAX_K 768
#define MAX_M 3072
#define BLOCK_M 256

const int TILE_SIZE = 32;
const int B_BANKS   = 32;              // khớp TILE_SIZE, cyclic factor=32
const int B_BANK_DEPTH = MAX_K * (BLOCK_M / B_BANKS); // 768*8 = 6144

#define DTYPE_IN int8_t
#define DTYPE_OUT int32_t

// ---------------------------------------------------------------------
// [SỬA — Hướng B tiếp, 2026-08-17, xem docs/modules/axi4_b_reader.md]
// B_BANK_LIST/B_PARAM (32 tham số `b_bank<n>`) đã BỎ khỏi header này — cùng lý
// do đã bỏ A_ROW_LIST/A_PARAM trước đó: Verification bắt được bằng chứng RTL
// thật (`tb_integration_top.sv` Stage 2) cho thấy Vitis HLS lập lịch
// `copy_B_block` chồng lấp với `tile_i` (khởi động `ap_start` cùng 1 cycle,
// `copy_B_block` không bao giờ báo `ap_done` thật) — vì `b_bank<n>` là cổng
// GHI THẲNG ra ngoài (bram interface, không đọc lại trong C++), HLS không
// thấy phụ thuộc dữ liệu nào giữa `copy_B_block` (chỉ ghi) và `tile_i` (không
// đụng `b_bank<n>`) nên "tưởng" được phép chạy song song — sai với thiết kế
// phần cứng thật (B phải ghi xong trước khi RTL đọc). Đã bỏ hẳn việc đọc B
// khỏi HLS, chuyển sang module RTL tự viết `AXI4_B_READER`
// (src/axi4_b_reader.v), giống hệt cách đã làm cho A ở Hướng B lần 1. Xem
// docs/task.md mục "Stage 2 chạy được — A hết treo, lộ ra bug MỚI ở B/tile".
// ---------------------------------------------------------------------

extern "C"
{
    /**
     * @brief Matrix multiplication accelerator — nạp DDR + tiling, compute ở RTL.
     *
     * [SỬA — Hướng B, 2026-08-17] Đã bỏ hẳn việc đọc A VÀ B khỏi HLS. `A_addr`/
     * `B_addr` chỉ còn là giá trị địa chỉ DDR (KHÔNG phải con trỏ, xem SỬA LẦN
     * 11 — Vitis HLS không synthesize được ép kiểu con trỏ->số nguyên), đi qua
     * `s_axilite`, không bao giờ dereference trong C++. `AXI4_A_READER` tự đọc
     * A 1 lần/call (ghi 64 bank A); `AXI4_B_READER` tự đọc B MỖI LẦN đổi
     * `j_block` (ghi 32 bank B) — cả 2 không qua Vitis HLS nữa.
     *
     * @param A_addr          Địa chỉ DDR của A (số nguyên thuần) — xem SỬA LẦN 11.
     * @param B_addr          Địa chỉ DDR của B (số nguyên thuần, cùng lý do A_addr).
     * @param C_addr          Địa chỉ DDR của C (số nguyên thuần) — [SỬA LẦN 16]
     *                        cùng lý do A_addr/B_addr, cấp cho `AXI4_C_WRITER`
     *                        tự ghi, không còn `m_axi`/con trỏ `C` trong HLS.
     * @param N,K,M,update_A  AXI-Lite control, không đổi so với Giai đoạn 0.
     * @param tile_i_sel_o    0/1 = đang xử lý hàng 0-31 / 32-63 của A.
     * @param tile_j_sel_o    0..7 = nhóm cột B (jj=j0/TILE_SIZE) đang xử lý.
     * @param tile_valid_o, tile_ready_i, tile_done_i  Bắt tay với SYSTOLIC_CORE_TOP.
     * @param a_base_addr_o   = A_addr, cấp cho `AXI4_A_READER` tự đọc DDR.
     * @param a_reload_req_o, a_loaded_i  Bắt tay với `AXI4_A_READER` — request
     *                        nạp lại A (khi update_A=1) / báo đã nạp xong.
     * @param b_base_addr_o   = B_addr + j_block (offset phần tử của block cột
     *                        hiện tại), cấp cho `AXI4_B_READER`.
     * @param b_row_stride_o  = M (số cột 1 hàng DDR gốc của B) — để
     *                        `AXI4_B_READER` tự tính địa chỉ hàng kế tiếp.
     * @param b_num_rows_o    = K (runtime) — số hàng cần đọc cho block hiện tại.
     * @param b_block_width_o = current_block_M (runtime, <=256) — độ rộng thật
     *                        của block cột hiện tại (có thể < BLOCK_M ở block cuối).
     * @param b_reload_req_o, b_loaded_i  Bắt tay với `AXI4_B_READER` — request
     *                        nạp block B mới (mỗi lần đổi `j_block`) / báo xong.
     * @param c_base_addr_o   = C_addr, cấp cho `AXI4_C_WRITER` tự ghi DDR.
     * @param c_row_stride_o  = M — để `AXI4_C_WRITER` tự tính địa chỉ hàng.
     * @param c_global_i0_o, c_global_j0_o  Hàng/cột bắt đầu (toạ độ tuyệt đối)
     *                        của tile hiện tại — gán cùng lúc `tile_i_sel_o`.
     * @param c_valid_rows_o, c_valid_cols_o  Số hàng/cột hợp lệ trong tile
     *                        (đã trừ biên N/current_block_M — khớp boundary
     *                        check `writeC` cũ).
     * @param c_write_done_i  `AXI4_C_WRITER` báo đã ghi xong C của tile hiện
     *                        tại ra DDR — [SỬA LẦN 16] bắt buộc chờ tín hiệu
     *                        này trước khi bắt đầu tile kế tiếp (tránh
     *                        SYSTOLIC_CORE_TOP xoá acc cho tile mới trong lúc
     *                        `AXI4_C_WRITER` còn đang đọc `c_o` của tile cũ).
     */
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
        volatile bool &c_write_done_i);
}

#endif // MMULT_ACCEL_H
