// tb_mmult_accel_hls.cpp — test C-sim thuan cho mmult_accel (khong can RTL).
//
// [SUA - Huong B, 2026-08-17, xem docs/modules/mmult_accel.md muc "Huong B" +
// docs/task.md] Sau 9 lan sua lien tiep deu treo, Design da bo han viec doc A khoi
// Vitis HLS - chuyen sang module RTL tu viet AXI4_A_READER (01_design/src/axi4_a_reader.v,
// test rieng o tb_axi4_a_reader.sv). `mmult_accel` gio KHONG CON 64 tham so `a_bank<n>`
// nua (A_ROW_LIST/A_PARAM da bi xoa khoi mmult_accel.h).
//
// [SUA - SUA LAN 11, 2026-08-17] Tham so `A` khong con la con tro nua - da doi han sang
// `ap_uint<32> A_addr` (so nguyen thuan) ngay trong chu ky ham, vi Vitis HLS khong
// synthesize duoc phep ep kieu con tro->so nguyen (SYNCHK 200-41) can thiet de xuat gia
// tri dia chi ra `a_base_addr_o` cho AXI4_A_READER tu doc DDR.
//
// [SUA - SUA LAN 12, 2026-08-17, xem docs/modules/axi4_b_reader.md] Verification bam
// duoc bang chung RTL that (tb_integration_top.sv Stage 2, [PROBE3]) cho thay Vitis HLS
// lap lich copy_B_block CHONG LAP voi tile_i (khoi dong ap_start CUNG 1 cycle, copy_B_block
// khong bao gio bao ap_done that) - vi b_bank<n> la cong GHI THANG ra ngoai (khong doc lai
// trong C++) nen HLS khong thay phu thuoc du lieu giua 2 vung, "tuong" duoc phep chay song
// song, sai voi thiet ke phan cung that. Design da bo han copy_B_block khoi HLS, chuyen
// sang AXI4_B_READER tu viet (giong het huong da lam cho A) - `B` cung doi tu con tro sang
// `ap_uint<32> B_addr`, khong con 32 tham so `b_bank<n>`/`B_BANK_LIST` nua.
//
// [SUA - SUA LAN 16, 2026-08-18, xem docs/modules/axi4_c_writer.md] Sau 3 lan sua writeC/
// c_arr phia Vitis HLS deu that bai (SUA LAN 13/14/15, cuoi cung xac nhan qua log
// C-synthesis: Vitis HLS TU DONG pipeline hoa vong lap capture_c bat ke PROTOCOL fixed/
// ap_wait()) - Design bo han c_arr/writeC/con tro C khoi HLS, chuyen sang module RTL tu
// viet AXI4_C_WRITER (doc truc tiep c_o tu SYSTOLIC_CORE_TOP luc tile_done_o, tu ghi AXI4
// ra DDR - khong qua Vitis HLS nua). `C` cung doi tu con tro sang `ap_uint<32> C_addr`
// (cung ly do/cach lam voi A_addr/B_addr).
//
// Test nay gio KHONG CON kiem tra noi dung bank A/B lan ghi C (ca 3 deu chuyen sang RTL tu
// viet, test rieng o tb_axi4_a_reader.sv/tb_axi4_b_reader.sv/tb_axi4_c_writer.sv) - chi con
// kiem tra `a_base_addr_o`/`b_base_addr_o`/`c_base_addr_o` khop dung gia tri da cap,
// `c_row_stride_o`=M, (c)/(c2) tile_i_sel_o/tile_j_sel_o dung gia tri.
//
// LUU Y: tile_done_i/tile_ready_i/a_loaded_i/b_loaded_i/c_write_done_i la tham so
// truyen-theo-gia-tri (khong phai con tro/tham chieu toi phan cung that) - C-sim thuan
// khong the mo phong RTL "cho roi bao xong". Theo dung pham vi task ("Khong can RTL"), test
// goi voi tile_done_i=true, a_loaded_i=true, b_loaded_i=true, c_write_done_i=true ngay tu
// dau de bo qua vong cho, tap trung test dung tile_i_sel_o/tile_j_sel_o + cac gia tri dia
// chi/stride xuat ra dung. Xac nhan thu tu bat tay THAT (len/xuong dung luc) cho ca 4 module
// RTL (A/B/C + SYSTOLIC_CORE_TOP) chi lam duoc o buoc RTL that (tb_integration_top.sv),
// khong phai o C-sim nay.

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "../../01_design/src/mmult_accel.h"

static int pass_count = 0;
static int fail_count = 0;

static void report(bool cond, const char *msg) {
  if (cond) {
    pass_count++;
    std::printf("[PASS] %s\n", msg);
  } else {
    fail_count++;
    std::printf("[FAIL] %s\n", msg);
  }
}

// Chay 1 test case: N,K,M tuy chinh, tra ve tile_i_sel_o cuoi cung va kiem tra cac assertion.
static void run_case(int N, int K, int M, const char *tag) {
  std::printf("---- Case: %s (N=%d, K=%d, M=%d) ----\n", tag, N, K, M);

  // [SUA - SUA LAN 11/12/16] A, B, C gio deu chi la gia tri dia chi (ap_uint<32>), khong
  // con la con tro/mang thuc - mmult_accel khong con doc A/B lan ghi C nua (chuyen het sang
  // AXI4_A_READER/AXI4_B_READER/AXI4_C_WRITER tu viet).
  bool tile_i_sel_o = false;
  ap_uint<3> tile_j_sel_o = 0;

  bool tile_valid_o = false;
  bool tile_ready_i = true;
  bool tile_done_i = true; // C-sim: bo qua cho RTL that, xem chu thich dau file.
  // Gia tri A_addr/B_addr/C_addr test - so nguyen bat ky dai dien dia chi DDR (khong con y
  // nghia con tro thuc, chi la gia tri de doi chieu a_base_addr_o/b_base_addr_o/c_base_addr_o
  // co truyen dung khong). Doi theo tung case (cong them offset khac nhau) de chac chan
  // khong "an" loi do trung ngau nhien voi gia tri mac dinh/gia tri case truoc, va 3 gia tri
  // khac nhau de phat hien duoc neu lo gan nham cho nhau.
  ap_uint<32> A_addr = 0xDEAD0000 + (ap_uint<32>)N;
  ap_uint<32> B_addr = 0xBEEF0000 + (ap_uint<32>)N;
  ap_uint<32> C_addr = 0xCAFE0000 + (ap_uint<32>)N;
  ap_uint<32> a_base_addr_o = 0;
  bool a_reload_req_o = false;
  bool a_loaded_i = true; // C-sim: bo qua cho RTL that (AXI4_A_READER), xem chu thich dau file.
  ap_uint<32> b_base_addr_o = 0;
  ap_uint<32> b_row_stride_o = 0;
  ap_uint<16> b_num_rows_o = 0;
  ap_uint<16> b_block_width_o = 0;
  bool b_reload_req_o = false;
  bool b_loaded_i = true; // C-sim: bo qua cho RTL that (AXI4_B_READER), xem chu thich dau file.
  ap_uint<32> c_base_addr_o = 0;
  ap_uint<32> c_row_stride_o = 0;
  ap_uint<16> c_global_i0_o = 0, c_global_j0_o = 0;
  ap_uint<16> c_valid_rows_o = 0, c_valid_cols_o = 0;
  bool c_write_done_i = true; // C-sim: bo qua cho RTL that (AXI4_C_WRITER), xem chu thich dau file.

  mmult_accel(A_addr, B_addr, C_addr, N, K, M, /*update_A=*/1,
              tile_i_sel_o,
              tile_j_sel_o,
              tile_valid_o, tile_ready_i, tile_done_i,
              a_base_addr_o, a_reload_req_o, a_loaded_i,
              b_base_addr_o, b_row_stride_o, b_num_rows_o, b_block_width_o,
              b_reload_req_o, b_loaded_i,
              c_base_addr_o, c_row_stride_o,
              c_global_i0_o, c_global_j0_o,
              c_valid_rows_o, c_valid_cols_o,
              c_write_done_i);

  // (a) Kiem tra a_base_addr_o/b_base_addr_o/c_base_addr_o khop dung gia tri A_addr/B_addr/
  // C_addr da cap (khong con kiem tra noi dung bank A/B lan ghi C - viec do gio thuoc
  // AXI4_A_READER/AXI4_B_READER/AXI4_C_WRITER, test rieng o
  // tb_axi4_a_reader.sv/tb_axi4_b_reader.sv/tb_axi4_c_writer.sv).
  {
    char buf[128];
    std::snprintf(buf, sizeof(buf),
                   "%s: a_base_addr_o khop dung gia tri A_addr da cap", tag);
    report(a_base_addr_o == A_addr, buf);
  }
  {
    char buf[128];
    std::snprintf(buf, sizeof(buf),
                   "%s: b_base_addr_o khop dung gia tri B_addr da cap", tag);
    report(b_base_addr_o == B_addr, buf);
  }
  {
    char buf[128];
    std::snprintf(buf, sizeof(buf),
                   "%s: c_base_addr_o khop dung gia tri C_addr da cap", tag);
    report(c_base_addr_o == C_addr, buf);
  }
  {
    char buf[128];
    std::snprintf(buf, sizeof(buf),
                   "%s: c_row_stride_o = M (%d)", tag, M);
    report(c_row_stride_o == (ap_uint<32>)M, buf);
  }

  // (c) Kiem tra tile_i_sel_o cuoi cung: N<=32 -> chi i0=0 -> false; N>32 -> lan cuoi
  // i0=32 -> true.
  {
    bool expected_final_sel = (N > TILE_SIZE);
    char buf[128];
    std::snprintf(buf, sizeof(buf),
                   "%s: tile_i_sel_o cuoi cung = %d (ky vong %d, N=%d)",
                   tag, tile_i_sel_o, expected_final_sel, N);
    report(tile_i_sel_o == expected_final_sel, buf);
  }

  // (c2) Kiem tra tile_j_sel_o cuoi cung = (j0_cuoi/TILE_SIZE) % 8, voi j0_cuoi la
  // gia tri j0 lon nhat < current_block_M trong vong tile_j (M < BLOCK_M nen
  // current_block_M = M o day).
  {
    int last_j0 = ((M - 1) / TILE_SIZE) * TILE_SIZE;
    ap_uint<3> expected_final_jsel = (ap_uint<3>)((last_j0 / TILE_SIZE) % 8);
    char buf[128];
    std::snprintf(buf, sizeof(buf),
                   "%s: tile_j_sel_o cuoi cung = %d (ky vong %d, M=%d)",
                   tag, (int)tile_j_sel_o, (int)expected_final_jsel, M);
    report(tile_j_sel_o == expected_final_jsel, buf);
  }

  // (d) Kiem tra c_global_i0_o/c_global_j0_o/c_valid_rows_o/c_valid_cols_o cuoi cung dung
  // gia tri ky vong cho tile CUOI CUNG duoc xu ly (i0_cuoi, j0_cuoi trong vong lap tile_i/
  // tile_j) - thay the (d)/(d2) cu (khong con ap dung vi mmult_accel khong con ghi C).
  {
    int last_i0 = ((N - 1) / TILE_SIZE) * TILE_SIZE;
    int last_j0 = ((M - 1) / TILE_SIZE) * TILE_SIZE;
    int expected_valid_rows = (N - last_i0 < TILE_SIZE) ? (N - last_i0) : TILE_SIZE;
    int expected_valid_cols = (M - last_j0 < TILE_SIZE) ? (M - last_j0) : TILE_SIZE;
    char buf[160];
    std::snprintf(buf, sizeof(buf),
                   "%s: c_global_i0_o/j0_o cuoi cung = %d/%d (ky vong %d/%d)",
                   tag, (int)c_global_i0_o, (int)c_global_j0_o, last_i0, last_j0);
    report(c_global_i0_o == (ap_uint<16>)last_i0 && c_global_j0_o == (ap_uint<16>)last_j0, buf);
    std::snprintf(buf, sizeof(buf),
                   "%s: c_valid_rows_o/cols_o cuoi cung = %d/%d (ky vong %d/%d)",
                   tag, (int)c_valid_rows_o, (int)c_valid_cols_o,
                   expected_valid_rows, expected_valid_cols);
    report(c_valid_rows_o == (ap_uint<16>)expected_valid_rows &&
           c_valid_cols_o == (ap_uint<16>)expected_valid_cols, buf);
  }
}

int main() {
  // Case 1: N=20 (<32, chi i0=0), K=50, M=100 - tile le, N/K/M khong chia het 32.
  run_case(20, 50, 100, "Case 1 (N=20<32, K=50, M=100)");

  // Case 2: N=48 (>32, co ca i0=0 va i0=32), K=50, M=100.
  run_case(48, 50, 100, "Case 2 (N=48>32, K=50, M=100)");

  std::printf("========================================\n");
  std::printf("tb_mmult_accel_hls: %d PASS, %d FAIL\n", pass_count, fail_count);
  if (fail_count == 0) std::printf("tb_mmult_accel_hls: ALL TESTS PASSED\n");
  else std::printf("tb_mmult_accel_hls: SOME TESTS FAILED\n");
  std::printf("========================================\n");

  return fail_count == 0 ? 0 : 1;
}
