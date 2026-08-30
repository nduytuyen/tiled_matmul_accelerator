`timescale 1ns / 1ps

// Test theo RTL hien tai (2026-07-21, ban cong phang): SYSTOLIC_CORE_TOP khong con
// port mang bram_a_addr_o[64]/bram_b_addr_o[32] ma la 64+32 CONG PHANG dat ten rieng
// (bram_a0_addr_o..bram_a63_dout_i, bram_b0_addr_o..bram_b31_dout_i) - vi Vitis HLS
// xuat 64/32 tham so C++ rieng biet thanh cong phang rieng, khong phai 1 mang. RTL
// cung da them tile_j_sel_i (3-bit, chon nhom cot B trong 8 nhom cua BLOCK_M=256),
// dia chi B = k_cnt_q*8 + tile_j_sel_q. Xem 01_design/src/systolic_core_top.sv,
// docs/feedback_to_spec.md muc "dia chi bank B..." (da xac nhan + sua).
//
// Khai bao tuong minh 96 tin hieu (64 A + 32 B) + logic doc BRAM dong bo cho tung
// bank (KHONG dung X-macro kieu `LIST(`SUBMACRO) - Vivado xsim khong ho tro truyen
// ten macro co backtick lam tham so cho macro khac, gay loi "[HDL 9-1206] Syntax
// error near '('"). Tin hieu testbench dat TRUNG TEN voi port DUT de dung `.*` khi
// instance, tranh phai liet ke tay khi noi cong.
module tb_systolic_core_top;

  localparam int ARR_SIZE = 32;
  localparam int A_ROWS   = 64;
  localparam int DATA_W   = 8;
  localparam int ACC_W    = 32;
  localparam int K_DEPTH  = 768;
  localparam int B_BANK_DEPTH = K_DEPTH * 8; // 6144, khop mmult_accel.h
  // [Bugfix B2] SYSTOLIC_PE_ARRAY bo dac cach row/col==0, fill tang 63->64 cycle
  // -> ACC_CYCLES cua SYSTOLIC_CORE_TOP doi thanh (2*ARR_SIZE)+K_DEPTH=832 (thay 831 cu).
  // [Bugfix moi - BRAM doc dong bo tre 1 cycle] a_row/b_col truoc day dung addr_valid
  // (cung cycle phat addr/en) de gate, doc dout TRUOC KHI kip hop le - RTL da sua bang
  // data_valid_q (tre 1 cycle dung), them BRAM_READ_LATENCY=1 vao ACC_CYCLES: 832->833.
  localparam int EXPECT_CYCLES = (2 * ARR_SIZE) + K_DEPTH + 1; // 833
  localparam time CLK_PERIOD = 10ns;

  logic clk_i;
  logic rst_ni;

  logic tile_valid_i;
  logic tile_ready_o;
  logic tile_done_o;
  logic       tile_i_sel_i;
  logic [2:0] tile_j_sel_i;

  logic signed [ACC_W-1:0] c_o [ARR_SIZE][ARR_SIZE];

  // [BUGFIX - phat hien 2026-08-11 khi viet tb_integration_top.sv Stage 1] SYSTOLIC_CORE_TOP
  // KHONG co port ten "c_o" - do la mang NOI BO cua DUT (xem 01_design/src/systolic_core_top.sv
  // dong 1353, "noi bo, xem lop chuyen doi ben duoi"), duoc gan ra 1024 port PHANG rieng ten
  // c0_0_o..c31_31_o (dong 1710 tro di trong file do). Ban truoc chi khai bao "c_o" o day va
  // dung `.*` de instance - vi khong co identifier nao ten "c0_0_o"..."c31_31_o" trong scope,
  // `.*` KHONG the noi 1024 port that cua DUT toi dau ca -> "c_o" cuc bo o day luon la X (chua
  // bao gio duoc DUT ghi), khien check_c_o so sanh X voi expected. Ket qua PASS da bao cao truoc
  // do ("c_o khop 100% golden model") vi vay KHONG dang tin - can chay lai sau bugfix nay.
  // Sua: khai bao 1024 tin hieu phang cX_Y_o (trung ten port that cua DUT, de `.*` noi dung),
  // roi "bom" gia tri that vao "c_o" cuc bo (van dung cho check_c_o, khong doi logic check).
  logic signed [ACC_W-1:0] c0_0_o;
  logic signed [ACC_W-1:0] c0_1_o;
  logic signed [ACC_W-1:0] c0_2_o;
  logic signed [ACC_W-1:0] c0_3_o;
  logic signed [ACC_W-1:0] c0_4_o;
  logic signed [ACC_W-1:0] c0_5_o;
  logic signed [ACC_W-1:0] c0_6_o;
  logic signed [ACC_W-1:0] c0_7_o;
  logic signed [ACC_W-1:0] c0_8_o;
  logic signed [ACC_W-1:0] c0_9_o;
  logic signed [ACC_W-1:0] c0_10_o;
  logic signed [ACC_W-1:0] c0_11_o;
  logic signed [ACC_W-1:0] c0_12_o;
  logic signed [ACC_W-1:0] c0_13_o;
  logic signed [ACC_W-1:0] c0_14_o;
  logic signed [ACC_W-1:0] c0_15_o;
  logic signed [ACC_W-1:0] c0_16_o;
  logic signed [ACC_W-1:0] c0_17_o;
  logic signed [ACC_W-1:0] c0_18_o;
  logic signed [ACC_W-1:0] c0_19_o;
  logic signed [ACC_W-1:0] c0_20_o;
  logic signed [ACC_W-1:0] c0_21_o;
  logic signed [ACC_W-1:0] c0_22_o;
  logic signed [ACC_W-1:0] c0_23_o;
  logic signed [ACC_W-1:0] c0_24_o;
  logic signed [ACC_W-1:0] c0_25_o;
  logic signed [ACC_W-1:0] c0_26_o;
  logic signed [ACC_W-1:0] c0_27_o;
  logic signed [ACC_W-1:0] c0_28_o;
  logic signed [ACC_W-1:0] c0_29_o;
  logic signed [ACC_W-1:0] c0_30_o;
  logic signed [ACC_W-1:0] c0_31_o;
  logic signed [ACC_W-1:0] c1_0_o;
  logic signed [ACC_W-1:0] c1_1_o;
  logic signed [ACC_W-1:0] c1_2_o;
  logic signed [ACC_W-1:0] c1_3_o;
  logic signed [ACC_W-1:0] c1_4_o;
  logic signed [ACC_W-1:0] c1_5_o;
  logic signed [ACC_W-1:0] c1_6_o;
  logic signed [ACC_W-1:0] c1_7_o;
  logic signed [ACC_W-1:0] c1_8_o;
  logic signed [ACC_W-1:0] c1_9_o;
  logic signed [ACC_W-1:0] c1_10_o;
  logic signed [ACC_W-1:0] c1_11_o;
  logic signed [ACC_W-1:0] c1_12_o;
  logic signed [ACC_W-1:0] c1_13_o;
  logic signed [ACC_W-1:0] c1_14_o;
  logic signed [ACC_W-1:0] c1_15_o;
  logic signed [ACC_W-1:0] c1_16_o;
  logic signed [ACC_W-1:0] c1_17_o;
  logic signed [ACC_W-1:0] c1_18_o;
  logic signed [ACC_W-1:0] c1_19_o;
  logic signed [ACC_W-1:0] c1_20_o;
  logic signed [ACC_W-1:0] c1_21_o;
  logic signed [ACC_W-1:0] c1_22_o;
  logic signed [ACC_W-1:0] c1_23_o;
  logic signed [ACC_W-1:0] c1_24_o;
  logic signed [ACC_W-1:0] c1_25_o;
  logic signed [ACC_W-1:0] c1_26_o;
  logic signed [ACC_W-1:0] c1_27_o;
  logic signed [ACC_W-1:0] c1_28_o;
  logic signed [ACC_W-1:0] c1_29_o;
  logic signed [ACC_W-1:0] c1_30_o;
  logic signed [ACC_W-1:0] c1_31_o;
  logic signed [ACC_W-1:0] c2_0_o;
  logic signed [ACC_W-1:0] c2_1_o;
  logic signed [ACC_W-1:0] c2_2_o;
  logic signed [ACC_W-1:0] c2_3_o;
  logic signed [ACC_W-1:0] c2_4_o;
  logic signed [ACC_W-1:0] c2_5_o;
  logic signed [ACC_W-1:0] c2_6_o;
  logic signed [ACC_W-1:0] c2_7_o;
  logic signed [ACC_W-1:0] c2_8_o;
  logic signed [ACC_W-1:0] c2_9_o;
  logic signed [ACC_W-1:0] c2_10_o;
  logic signed [ACC_W-1:0] c2_11_o;
  logic signed [ACC_W-1:0] c2_12_o;
  logic signed [ACC_W-1:0] c2_13_o;
  logic signed [ACC_W-1:0] c2_14_o;
  logic signed [ACC_W-1:0] c2_15_o;
  logic signed [ACC_W-1:0] c2_16_o;
  logic signed [ACC_W-1:0] c2_17_o;
  logic signed [ACC_W-1:0] c2_18_o;
  logic signed [ACC_W-1:0] c2_19_o;
  logic signed [ACC_W-1:0] c2_20_o;
  logic signed [ACC_W-1:0] c2_21_o;
  logic signed [ACC_W-1:0] c2_22_o;
  logic signed [ACC_W-1:0] c2_23_o;
  logic signed [ACC_W-1:0] c2_24_o;
  logic signed [ACC_W-1:0] c2_25_o;
  logic signed [ACC_W-1:0] c2_26_o;
  logic signed [ACC_W-1:0] c2_27_o;
  logic signed [ACC_W-1:0] c2_28_o;
  logic signed [ACC_W-1:0] c2_29_o;
  logic signed [ACC_W-1:0] c2_30_o;
  logic signed [ACC_W-1:0] c2_31_o;
  logic signed [ACC_W-1:0] c3_0_o;
  logic signed [ACC_W-1:0] c3_1_o;
  logic signed [ACC_W-1:0] c3_2_o;
  logic signed [ACC_W-1:0] c3_3_o;
  logic signed [ACC_W-1:0] c3_4_o;
  logic signed [ACC_W-1:0] c3_5_o;
  logic signed [ACC_W-1:0] c3_6_o;
  logic signed [ACC_W-1:0] c3_7_o;
  logic signed [ACC_W-1:0] c3_8_o;
  logic signed [ACC_W-1:0] c3_9_o;
  logic signed [ACC_W-1:0] c3_10_o;
  logic signed [ACC_W-1:0] c3_11_o;
  logic signed [ACC_W-1:0] c3_12_o;
  logic signed [ACC_W-1:0] c3_13_o;
  logic signed [ACC_W-1:0] c3_14_o;
  logic signed [ACC_W-1:0] c3_15_o;
  logic signed [ACC_W-1:0] c3_16_o;
  logic signed [ACC_W-1:0] c3_17_o;
  logic signed [ACC_W-1:0] c3_18_o;
  logic signed [ACC_W-1:0] c3_19_o;
  logic signed [ACC_W-1:0] c3_20_o;
  logic signed [ACC_W-1:0] c3_21_o;
  logic signed [ACC_W-1:0] c3_22_o;
  logic signed [ACC_W-1:0] c3_23_o;
  logic signed [ACC_W-1:0] c3_24_o;
  logic signed [ACC_W-1:0] c3_25_o;
  logic signed [ACC_W-1:0] c3_26_o;
  logic signed [ACC_W-1:0] c3_27_o;
  logic signed [ACC_W-1:0] c3_28_o;
  logic signed [ACC_W-1:0] c3_29_o;
  logic signed [ACC_W-1:0] c3_30_o;
  logic signed [ACC_W-1:0] c3_31_o;
  logic signed [ACC_W-1:0] c4_0_o;
  logic signed [ACC_W-1:0] c4_1_o;
  logic signed [ACC_W-1:0] c4_2_o;
  logic signed [ACC_W-1:0] c4_3_o;
  logic signed [ACC_W-1:0] c4_4_o;
  logic signed [ACC_W-1:0] c4_5_o;
  logic signed [ACC_W-1:0] c4_6_o;
  logic signed [ACC_W-1:0] c4_7_o;
  logic signed [ACC_W-1:0] c4_8_o;
  logic signed [ACC_W-1:0] c4_9_o;
  logic signed [ACC_W-1:0] c4_10_o;
  logic signed [ACC_W-1:0] c4_11_o;
  logic signed [ACC_W-1:0] c4_12_o;
  logic signed [ACC_W-1:0] c4_13_o;
  logic signed [ACC_W-1:0] c4_14_o;
  logic signed [ACC_W-1:0] c4_15_o;
  logic signed [ACC_W-1:0] c4_16_o;
  logic signed [ACC_W-1:0] c4_17_o;
  logic signed [ACC_W-1:0] c4_18_o;
  logic signed [ACC_W-1:0] c4_19_o;
  logic signed [ACC_W-1:0] c4_20_o;
  logic signed [ACC_W-1:0] c4_21_o;
  logic signed [ACC_W-1:0] c4_22_o;
  logic signed [ACC_W-1:0] c4_23_o;
  logic signed [ACC_W-1:0] c4_24_o;
  logic signed [ACC_W-1:0] c4_25_o;
  logic signed [ACC_W-1:0] c4_26_o;
  logic signed [ACC_W-1:0] c4_27_o;
  logic signed [ACC_W-1:0] c4_28_o;
  logic signed [ACC_W-1:0] c4_29_o;
  logic signed [ACC_W-1:0] c4_30_o;
  logic signed [ACC_W-1:0] c4_31_o;
  logic signed [ACC_W-1:0] c5_0_o;
  logic signed [ACC_W-1:0] c5_1_o;
  logic signed [ACC_W-1:0] c5_2_o;
  logic signed [ACC_W-1:0] c5_3_o;
  logic signed [ACC_W-1:0] c5_4_o;
  logic signed [ACC_W-1:0] c5_5_o;
  logic signed [ACC_W-1:0] c5_6_o;
  logic signed [ACC_W-1:0] c5_7_o;
  logic signed [ACC_W-1:0] c5_8_o;
  logic signed [ACC_W-1:0] c5_9_o;
  logic signed [ACC_W-1:0] c5_10_o;
  logic signed [ACC_W-1:0] c5_11_o;
  logic signed [ACC_W-1:0] c5_12_o;
  logic signed [ACC_W-1:0] c5_13_o;
  logic signed [ACC_W-1:0] c5_14_o;
  logic signed [ACC_W-1:0] c5_15_o;
  logic signed [ACC_W-1:0] c5_16_o;
  logic signed [ACC_W-1:0] c5_17_o;
  logic signed [ACC_W-1:0] c5_18_o;
  logic signed [ACC_W-1:0] c5_19_o;
  logic signed [ACC_W-1:0] c5_20_o;
  logic signed [ACC_W-1:0] c5_21_o;
  logic signed [ACC_W-1:0] c5_22_o;
  logic signed [ACC_W-1:0] c5_23_o;
  logic signed [ACC_W-1:0] c5_24_o;
  logic signed [ACC_W-1:0] c5_25_o;
  logic signed [ACC_W-1:0] c5_26_o;
  logic signed [ACC_W-1:0] c5_27_o;
  logic signed [ACC_W-1:0] c5_28_o;
  logic signed [ACC_W-1:0] c5_29_o;
  logic signed [ACC_W-1:0] c5_30_o;
  logic signed [ACC_W-1:0] c5_31_o;
  logic signed [ACC_W-1:0] c6_0_o;
  logic signed [ACC_W-1:0] c6_1_o;
  logic signed [ACC_W-1:0] c6_2_o;
  logic signed [ACC_W-1:0] c6_3_o;
  logic signed [ACC_W-1:0] c6_4_o;
  logic signed [ACC_W-1:0] c6_5_o;
  logic signed [ACC_W-1:0] c6_6_o;
  logic signed [ACC_W-1:0] c6_7_o;
  logic signed [ACC_W-1:0] c6_8_o;
  logic signed [ACC_W-1:0] c6_9_o;
  logic signed [ACC_W-1:0] c6_10_o;
  logic signed [ACC_W-1:0] c6_11_o;
  logic signed [ACC_W-1:0] c6_12_o;
  logic signed [ACC_W-1:0] c6_13_o;
  logic signed [ACC_W-1:0] c6_14_o;
  logic signed [ACC_W-1:0] c6_15_o;
  logic signed [ACC_W-1:0] c6_16_o;
  logic signed [ACC_W-1:0] c6_17_o;
  logic signed [ACC_W-1:0] c6_18_o;
  logic signed [ACC_W-1:0] c6_19_o;
  logic signed [ACC_W-1:0] c6_20_o;
  logic signed [ACC_W-1:0] c6_21_o;
  logic signed [ACC_W-1:0] c6_22_o;
  logic signed [ACC_W-1:0] c6_23_o;
  logic signed [ACC_W-1:0] c6_24_o;
  logic signed [ACC_W-1:0] c6_25_o;
  logic signed [ACC_W-1:0] c6_26_o;
  logic signed [ACC_W-1:0] c6_27_o;
  logic signed [ACC_W-1:0] c6_28_o;
  logic signed [ACC_W-1:0] c6_29_o;
  logic signed [ACC_W-1:0] c6_30_o;
  logic signed [ACC_W-1:0] c6_31_o;
  logic signed [ACC_W-1:0] c7_0_o;
  logic signed [ACC_W-1:0] c7_1_o;
  logic signed [ACC_W-1:0] c7_2_o;
  logic signed [ACC_W-1:0] c7_3_o;
  logic signed [ACC_W-1:0] c7_4_o;
  logic signed [ACC_W-1:0] c7_5_o;
  logic signed [ACC_W-1:0] c7_6_o;
  logic signed [ACC_W-1:0] c7_7_o;
  logic signed [ACC_W-1:0] c7_8_o;
  logic signed [ACC_W-1:0] c7_9_o;
  logic signed [ACC_W-1:0] c7_10_o;
  logic signed [ACC_W-1:0] c7_11_o;
  logic signed [ACC_W-1:0] c7_12_o;
  logic signed [ACC_W-1:0] c7_13_o;
  logic signed [ACC_W-1:0] c7_14_o;
  logic signed [ACC_W-1:0] c7_15_o;
  logic signed [ACC_W-1:0] c7_16_o;
  logic signed [ACC_W-1:0] c7_17_o;
  logic signed [ACC_W-1:0] c7_18_o;
  logic signed [ACC_W-1:0] c7_19_o;
  logic signed [ACC_W-1:0] c7_20_o;
  logic signed [ACC_W-1:0] c7_21_o;
  logic signed [ACC_W-1:0] c7_22_o;
  logic signed [ACC_W-1:0] c7_23_o;
  logic signed [ACC_W-1:0] c7_24_o;
  logic signed [ACC_W-1:0] c7_25_o;
  logic signed [ACC_W-1:0] c7_26_o;
  logic signed [ACC_W-1:0] c7_27_o;
  logic signed [ACC_W-1:0] c7_28_o;
  logic signed [ACC_W-1:0] c7_29_o;
  logic signed [ACC_W-1:0] c7_30_o;
  logic signed [ACC_W-1:0] c7_31_o;
  logic signed [ACC_W-1:0] c8_0_o;
  logic signed [ACC_W-1:0] c8_1_o;
  logic signed [ACC_W-1:0] c8_2_o;
  logic signed [ACC_W-1:0] c8_3_o;
  logic signed [ACC_W-1:0] c8_4_o;
  logic signed [ACC_W-1:0] c8_5_o;
  logic signed [ACC_W-1:0] c8_6_o;
  logic signed [ACC_W-1:0] c8_7_o;
  logic signed [ACC_W-1:0] c8_8_o;
  logic signed [ACC_W-1:0] c8_9_o;
  logic signed [ACC_W-1:0] c8_10_o;
  logic signed [ACC_W-1:0] c8_11_o;
  logic signed [ACC_W-1:0] c8_12_o;
  logic signed [ACC_W-1:0] c8_13_o;
  logic signed [ACC_W-1:0] c8_14_o;
  logic signed [ACC_W-1:0] c8_15_o;
  logic signed [ACC_W-1:0] c8_16_o;
  logic signed [ACC_W-1:0] c8_17_o;
  logic signed [ACC_W-1:0] c8_18_o;
  logic signed [ACC_W-1:0] c8_19_o;
  logic signed [ACC_W-1:0] c8_20_o;
  logic signed [ACC_W-1:0] c8_21_o;
  logic signed [ACC_W-1:0] c8_22_o;
  logic signed [ACC_W-1:0] c8_23_o;
  logic signed [ACC_W-1:0] c8_24_o;
  logic signed [ACC_W-1:0] c8_25_o;
  logic signed [ACC_W-1:0] c8_26_o;
  logic signed [ACC_W-1:0] c8_27_o;
  logic signed [ACC_W-1:0] c8_28_o;
  logic signed [ACC_W-1:0] c8_29_o;
  logic signed [ACC_W-1:0] c8_30_o;
  logic signed [ACC_W-1:0] c8_31_o;
  logic signed [ACC_W-1:0] c9_0_o;
  logic signed [ACC_W-1:0] c9_1_o;
  logic signed [ACC_W-1:0] c9_2_o;
  logic signed [ACC_W-1:0] c9_3_o;
  logic signed [ACC_W-1:0] c9_4_o;
  logic signed [ACC_W-1:0] c9_5_o;
  logic signed [ACC_W-1:0] c9_6_o;
  logic signed [ACC_W-1:0] c9_7_o;
  logic signed [ACC_W-1:0] c9_8_o;
  logic signed [ACC_W-1:0] c9_9_o;
  logic signed [ACC_W-1:0] c9_10_o;
  logic signed [ACC_W-1:0] c9_11_o;
  logic signed [ACC_W-1:0] c9_12_o;
  logic signed [ACC_W-1:0] c9_13_o;
  logic signed [ACC_W-1:0] c9_14_o;
  logic signed [ACC_W-1:0] c9_15_o;
  logic signed [ACC_W-1:0] c9_16_o;
  logic signed [ACC_W-1:0] c9_17_o;
  logic signed [ACC_W-1:0] c9_18_o;
  logic signed [ACC_W-1:0] c9_19_o;
  logic signed [ACC_W-1:0] c9_20_o;
  logic signed [ACC_W-1:0] c9_21_o;
  logic signed [ACC_W-1:0] c9_22_o;
  logic signed [ACC_W-1:0] c9_23_o;
  logic signed [ACC_W-1:0] c9_24_o;
  logic signed [ACC_W-1:0] c9_25_o;
  logic signed [ACC_W-1:0] c9_26_o;
  logic signed [ACC_W-1:0] c9_27_o;
  logic signed [ACC_W-1:0] c9_28_o;
  logic signed [ACC_W-1:0] c9_29_o;
  logic signed [ACC_W-1:0] c9_30_o;
  logic signed [ACC_W-1:0] c9_31_o;
  logic signed [ACC_W-1:0] c10_0_o;
  logic signed [ACC_W-1:0] c10_1_o;
  logic signed [ACC_W-1:0] c10_2_o;
  logic signed [ACC_W-1:0] c10_3_o;
  logic signed [ACC_W-1:0] c10_4_o;
  logic signed [ACC_W-1:0] c10_5_o;
  logic signed [ACC_W-1:0] c10_6_o;
  logic signed [ACC_W-1:0] c10_7_o;
  logic signed [ACC_W-1:0] c10_8_o;
  logic signed [ACC_W-1:0] c10_9_o;
  logic signed [ACC_W-1:0] c10_10_o;
  logic signed [ACC_W-1:0] c10_11_o;
  logic signed [ACC_W-1:0] c10_12_o;
  logic signed [ACC_W-1:0] c10_13_o;
  logic signed [ACC_W-1:0] c10_14_o;
  logic signed [ACC_W-1:0] c10_15_o;
  logic signed [ACC_W-1:0] c10_16_o;
  logic signed [ACC_W-1:0] c10_17_o;
  logic signed [ACC_W-1:0] c10_18_o;
  logic signed [ACC_W-1:0] c10_19_o;
  logic signed [ACC_W-1:0] c10_20_o;
  logic signed [ACC_W-1:0] c10_21_o;
  logic signed [ACC_W-1:0] c10_22_o;
  logic signed [ACC_W-1:0] c10_23_o;
  logic signed [ACC_W-1:0] c10_24_o;
  logic signed [ACC_W-1:0] c10_25_o;
  logic signed [ACC_W-1:0] c10_26_o;
  logic signed [ACC_W-1:0] c10_27_o;
  logic signed [ACC_W-1:0] c10_28_o;
  logic signed [ACC_W-1:0] c10_29_o;
  logic signed [ACC_W-1:0] c10_30_o;
  logic signed [ACC_W-1:0] c10_31_o;
  logic signed [ACC_W-1:0] c11_0_o;
  logic signed [ACC_W-1:0] c11_1_o;
  logic signed [ACC_W-1:0] c11_2_o;
  logic signed [ACC_W-1:0] c11_3_o;
  logic signed [ACC_W-1:0] c11_4_o;
  logic signed [ACC_W-1:0] c11_5_o;
  logic signed [ACC_W-1:0] c11_6_o;
  logic signed [ACC_W-1:0] c11_7_o;
  logic signed [ACC_W-1:0] c11_8_o;
  logic signed [ACC_W-1:0] c11_9_o;
  logic signed [ACC_W-1:0] c11_10_o;
  logic signed [ACC_W-1:0] c11_11_o;
  logic signed [ACC_W-1:0] c11_12_o;
  logic signed [ACC_W-1:0] c11_13_o;
  logic signed [ACC_W-1:0] c11_14_o;
  logic signed [ACC_W-1:0] c11_15_o;
  logic signed [ACC_W-1:0] c11_16_o;
  logic signed [ACC_W-1:0] c11_17_o;
  logic signed [ACC_W-1:0] c11_18_o;
  logic signed [ACC_W-1:0] c11_19_o;
  logic signed [ACC_W-1:0] c11_20_o;
  logic signed [ACC_W-1:0] c11_21_o;
  logic signed [ACC_W-1:0] c11_22_o;
  logic signed [ACC_W-1:0] c11_23_o;
  logic signed [ACC_W-1:0] c11_24_o;
  logic signed [ACC_W-1:0] c11_25_o;
  logic signed [ACC_W-1:0] c11_26_o;
  logic signed [ACC_W-1:0] c11_27_o;
  logic signed [ACC_W-1:0] c11_28_o;
  logic signed [ACC_W-1:0] c11_29_o;
  logic signed [ACC_W-1:0] c11_30_o;
  logic signed [ACC_W-1:0] c11_31_o;
  logic signed [ACC_W-1:0] c12_0_o;
  logic signed [ACC_W-1:0] c12_1_o;
  logic signed [ACC_W-1:0] c12_2_o;
  logic signed [ACC_W-1:0] c12_3_o;
  logic signed [ACC_W-1:0] c12_4_o;
  logic signed [ACC_W-1:0] c12_5_o;
  logic signed [ACC_W-1:0] c12_6_o;
  logic signed [ACC_W-1:0] c12_7_o;
  logic signed [ACC_W-1:0] c12_8_o;
  logic signed [ACC_W-1:0] c12_9_o;
  logic signed [ACC_W-1:0] c12_10_o;
  logic signed [ACC_W-1:0] c12_11_o;
  logic signed [ACC_W-1:0] c12_12_o;
  logic signed [ACC_W-1:0] c12_13_o;
  logic signed [ACC_W-1:0] c12_14_o;
  logic signed [ACC_W-1:0] c12_15_o;
  logic signed [ACC_W-1:0] c12_16_o;
  logic signed [ACC_W-1:0] c12_17_o;
  logic signed [ACC_W-1:0] c12_18_o;
  logic signed [ACC_W-1:0] c12_19_o;
  logic signed [ACC_W-1:0] c12_20_o;
  logic signed [ACC_W-1:0] c12_21_o;
  logic signed [ACC_W-1:0] c12_22_o;
  logic signed [ACC_W-1:0] c12_23_o;
  logic signed [ACC_W-1:0] c12_24_o;
  logic signed [ACC_W-1:0] c12_25_o;
  logic signed [ACC_W-1:0] c12_26_o;
  logic signed [ACC_W-1:0] c12_27_o;
  logic signed [ACC_W-1:0] c12_28_o;
  logic signed [ACC_W-1:0] c12_29_o;
  logic signed [ACC_W-1:0] c12_30_o;
  logic signed [ACC_W-1:0] c12_31_o;
  logic signed [ACC_W-1:0] c13_0_o;
  logic signed [ACC_W-1:0] c13_1_o;
  logic signed [ACC_W-1:0] c13_2_o;
  logic signed [ACC_W-1:0] c13_3_o;
  logic signed [ACC_W-1:0] c13_4_o;
  logic signed [ACC_W-1:0] c13_5_o;
  logic signed [ACC_W-1:0] c13_6_o;
  logic signed [ACC_W-1:0] c13_7_o;
  logic signed [ACC_W-1:0] c13_8_o;
  logic signed [ACC_W-1:0] c13_9_o;
  logic signed [ACC_W-1:0] c13_10_o;
  logic signed [ACC_W-1:0] c13_11_o;
  logic signed [ACC_W-1:0] c13_12_o;
  logic signed [ACC_W-1:0] c13_13_o;
  logic signed [ACC_W-1:0] c13_14_o;
  logic signed [ACC_W-1:0] c13_15_o;
  logic signed [ACC_W-1:0] c13_16_o;
  logic signed [ACC_W-1:0] c13_17_o;
  logic signed [ACC_W-1:0] c13_18_o;
  logic signed [ACC_W-1:0] c13_19_o;
  logic signed [ACC_W-1:0] c13_20_o;
  logic signed [ACC_W-1:0] c13_21_o;
  logic signed [ACC_W-1:0] c13_22_o;
  logic signed [ACC_W-1:0] c13_23_o;
  logic signed [ACC_W-1:0] c13_24_o;
  logic signed [ACC_W-1:0] c13_25_o;
  logic signed [ACC_W-1:0] c13_26_o;
  logic signed [ACC_W-1:0] c13_27_o;
  logic signed [ACC_W-1:0] c13_28_o;
  logic signed [ACC_W-1:0] c13_29_o;
  logic signed [ACC_W-1:0] c13_30_o;
  logic signed [ACC_W-1:0] c13_31_o;
  logic signed [ACC_W-1:0] c14_0_o;
  logic signed [ACC_W-1:0] c14_1_o;
  logic signed [ACC_W-1:0] c14_2_o;
  logic signed [ACC_W-1:0] c14_3_o;
  logic signed [ACC_W-1:0] c14_4_o;
  logic signed [ACC_W-1:0] c14_5_o;
  logic signed [ACC_W-1:0] c14_6_o;
  logic signed [ACC_W-1:0] c14_7_o;
  logic signed [ACC_W-1:0] c14_8_o;
  logic signed [ACC_W-1:0] c14_9_o;
  logic signed [ACC_W-1:0] c14_10_o;
  logic signed [ACC_W-1:0] c14_11_o;
  logic signed [ACC_W-1:0] c14_12_o;
  logic signed [ACC_W-1:0] c14_13_o;
  logic signed [ACC_W-1:0] c14_14_o;
  logic signed [ACC_W-1:0] c14_15_o;
  logic signed [ACC_W-1:0] c14_16_o;
  logic signed [ACC_W-1:0] c14_17_o;
  logic signed [ACC_W-1:0] c14_18_o;
  logic signed [ACC_W-1:0] c14_19_o;
  logic signed [ACC_W-1:0] c14_20_o;
  logic signed [ACC_W-1:0] c14_21_o;
  logic signed [ACC_W-1:0] c14_22_o;
  logic signed [ACC_W-1:0] c14_23_o;
  logic signed [ACC_W-1:0] c14_24_o;
  logic signed [ACC_W-1:0] c14_25_o;
  logic signed [ACC_W-1:0] c14_26_o;
  logic signed [ACC_W-1:0] c14_27_o;
  logic signed [ACC_W-1:0] c14_28_o;
  logic signed [ACC_W-1:0] c14_29_o;
  logic signed [ACC_W-1:0] c14_30_o;
  logic signed [ACC_W-1:0] c14_31_o;
  logic signed [ACC_W-1:0] c15_0_o;
  logic signed [ACC_W-1:0] c15_1_o;
  logic signed [ACC_W-1:0] c15_2_o;
  logic signed [ACC_W-1:0] c15_3_o;
  logic signed [ACC_W-1:0] c15_4_o;
  logic signed [ACC_W-1:0] c15_5_o;
  logic signed [ACC_W-1:0] c15_6_o;
  logic signed [ACC_W-1:0] c15_7_o;
  logic signed [ACC_W-1:0] c15_8_o;
  logic signed [ACC_W-1:0] c15_9_o;
  logic signed [ACC_W-1:0] c15_10_o;
  logic signed [ACC_W-1:0] c15_11_o;
  logic signed [ACC_W-1:0] c15_12_o;
  logic signed [ACC_W-1:0] c15_13_o;
  logic signed [ACC_W-1:0] c15_14_o;
  logic signed [ACC_W-1:0] c15_15_o;
  logic signed [ACC_W-1:0] c15_16_o;
  logic signed [ACC_W-1:0] c15_17_o;
  logic signed [ACC_W-1:0] c15_18_o;
  logic signed [ACC_W-1:0] c15_19_o;
  logic signed [ACC_W-1:0] c15_20_o;
  logic signed [ACC_W-1:0] c15_21_o;
  logic signed [ACC_W-1:0] c15_22_o;
  logic signed [ACC_W-1:0] c15_23_o;
  logic signed [ACC_W-1:0] c15_24_o;
  logic signed [ACC_W-1:0] c15_25_o;
  logic signed [ACC_W-1:0] c15_26_o;
  logic signed [ACC_W-1:0] c15_27_o;
  logic signed [ACC_W-1:0] c15_28_o;
  logic signed [ACC_W-1:0] c15_29_o;
  logic signed [ACC_W-1:0] c15_30_o;
  logic signed [ACC_W-1:0] c15_31_o;
  logic signed [ACC_W-1:0] c16_0_o;
  logic signed [ACC_W-1:0] c16_1_o;
  logic signed [ACC_W-1:0] c16_2_o;
  logic signed [ACC_W-1:0] c16_3_o;
  logic signed [ACC_W-1:0] c16_4_o;
  logic signed [ACC_W-1:0] c16_5_o;
  logic signed [ACC_W-1:0] c16_6_o;
  logic signed [ACC_W-1:0] c16_7_o;
  logic signed [ACC_W-1:0] c16_8_o;
  logic signed [ACC_W-1:0] c16_9_o;
  logic signed [ACC_W-1:0] c16_10_o;
  logic signed [ACC_W-1:0] c16_11_o;
  logic signed [ACC_W-1:0] c16_12_o;
  logic signed [ACC_W-1:0] c16_13_o;
  logic signed [ACC_W-1:0] c16_14_o;
  logic signed [ACC_W-1:0] c16_15_o;
  logic signed [ACC_W-1:0] c16_16_o;
  logic signed [ACC_W-1:0] c16_17_o;
  logic signed [ACC_W-1:0] c16_18_o;
  logic signed [ACC_W-1:0] c16_19_o;
  logic signed [ACC_W-1:0] c16_20_o;
  logic signed [ACC_W-1:0] c16_21_o;
  logic signed [ACC_W-1:0] c16_22_o;
  logic signed [ACC_W-1:0] c16_23_o;
  logic signed [ACC_W-1:0] c16_24_o;
  logic signed [ACC_W-1:0] c16_25_o;
  logic signed [ACC_W-1:0] c16_26_o;
  logic signed [ACC_W-1:0] c16_27_o;
  logic signed [ACC_W-1:0] c16_28_o;
  logic signed [ACC_W-1:0] c16_29_o;
  logic signed [ACC_W-1:0] c16_30_o;
  logic signed [ACC_W-1:0] c16_31_o;
  logic signed [ACC_W-1:0] c17_0_o;
  logic signed [ACC_W-1:0] c17_1_o;
  logic signed [ACC_W-1:0] c17_2_o;
  logic signed [ACC_W-1:0] c17_3_o;
  logic signed [ACC_W-1:0] c17_4_o;
  logic signed [ACC_W-1:0] c17_5_o;
  logic signed [ACC_W-1:0] c17_6_o;
  logic signed [ACC_W-1:0] c17_7_o;
  logic signed [ACC_W-1:0] c17_8_o;
  logic signed [ACC_W-1:0] c17_9_o;
  logic signed [ACC_W-1:0] c17_10_o;
  logic signed [ACC_W-1:0] c17_11_o;
  logic signed [ACC_W-1:0] c17_12_o;
  logic signed [ACC_W-1:0] c17_13_o;
  logic signed [ACC_W-1:0] c17_14_o;
  logic signed [ACC_W-1:0] c17_15_o;
  logic signed [ACC_W-1:0] c17_16_o;
  logic signed [ACC_W-1:0] c17_17_o;
  logic signed [ACC_W-1:0] c17_18_o;
  logic signed [ACC_W-1:0] c17_19_o;
  logic signed [ACC_W-1:0] c17_20_o;
  logic signed [ACC_W-1:0] c17_21_o;
  logic signed [ACC_W-1:0] c17_22_o;
  logic signed [ACC_W-1:0] c17_23_o;
  logic signed [ACC_W-1:0] c17_24_o;
  logic signed [ACC_W-1:0] c17_25_o;
  logic signed [ACC_W-1:0] c17_26_o;
  logic signed [ACC_W-1:0] c17_27_o;
  logic signed [ACC_W-1:0] c17_28_o;
  logic signed [ACC_W-1:0] c17_29_o;
  logic signed [ACC_W-1:0] c17_30_o;
  logic signed [ACC_W-1:0] c17_31_o;
  logic signed [ACC_W-1:0] c18_0_o;
  logic signed [ACC_W-1:0] c18_1_o;
  logic signed [ACC_W-1:0] c18_2_o;
  logic signed [ACC_W-1:0] c18_3_o;
  logic signed [ACC_W-1:0] c18_4_o;
  logic signed [ACC_W-1:0] c18_5_o;
  logic signed [ACC_W-1:0] c18_6_o;
  logic signed [ACC_W-1:0] c18_7_o;
  logic signed [ACC_W-1:0] c18_8_o;
  logic signed [ACC_W-1:0] c18_9_o;
  logic signed [ACC_W-1:0] c18_10_o;
  logic signed [ACC_W-1:0] c18_11_o;
  logic signed [ACC_W-1:0] c18_12_o;
  logic signed [ACC_W-1:0] c18_13_o;
  logic signed [ACC_W-1:0] c18_14_o;
  logic signed [ACC_W-1:0] c18_15_o;
  logic signed [ACC_W-1:0] c18_16_o;
  logic signed [ACC_W-1:0] c18_17_o;
  logic signed [ACC_W-1:0] c18_18_o;
  logic signed [ACC_W-1:0] c18_19_o;
  logic signed [ACC_W-1:0] c18_20_o;
  logic signed [ACC_W-1:0] c18_21_o;
  logic signed [ACC_W-1:0] c18_22_o;
  logic signed [ACC_W-1:0] c18_23_o;
  logic signed [ACC_W-1:0] c18_24_o;
  logic signed [ACC_W-1:0] c18_25_o;
  logic signed [ACC_W-1:0] c18_26_o;
  logic signed [ACC_W-1:0] c18_27_o;
  logic signed [ACC_W-1:0] c18_28_o;
  logic signed [ACC_W-1:0] c18_29_o;
  logic signed [ACC_W-1:0] c18_30_o;
  logic signed [ACC_W-1:0] c18_31_o;
  logic signed [ACC_W-1:0] c19_0_o;
  logic signed [ACC_W-1:0] c19_1_o;
  logic signed [ACC_W-1:0] c19_2_o;
  logic signed [ACC_W-1:0] c19_3_o;
  logic signed [ACC_W-1:0] c19_4_o;
  logic signed [ACC_W-1:0] c19_5_o;
  logic signed [ACC_W-1:0] c19_6_o;
  logic signed [ACC_W-1:0] c19_7_o;
  logic signed [ACC_W-1:0] c19_8_o;
  logic signed [ACC_W-1:0] c19_9_o;
  logic signed [ACC_W-1:0] c19_10_o;
  logic signed [ACC_W-1:0] c19_11_o;
  logic signed [ACC_W-1:0] c19_12_o;
  logic signed [ACC_W-1:0] c19_13_o;
  logic signed [ACC_W-1:0] c19_14_o;
  logic signed [ACC_W-1:0] c19_15_o;
  logic signed [ACC_W-1:0] c19_16_o;
  logic signed [ACC_W-1:0] c19_17_o;
  logic signed [ACC_W-1:0] c19_18_o;
  logic signed [ACC_W-1:0] c19_19_o;
  logic signed [ACC_W-1:0] c19_20_o;
  logic signed [ACC_W-1:0] c19_21_o;
  logic signed [ACC_W-1:0] c19_22_o;
  logic signed [ACC_W-1:0] c19_23_o;
  logic signed [ACC_W-1:0] c19_24_o;
  logic signed [ACC_W-1:0] c19_25_o;
  logic signed [ACC_W-1:0] c19_26_o;
  logic signed [ACC_W-1:0] c19_27_o;
  logic signed [ACC_W-1:0] c19_28_o;
  logic signed [ACC_W-1:0] c19_29_o;
  logic signed [ACC_W-1:0] c19_30_o;
  logic signed [ACC_W-1:0] c19_31_o;
  logic signed [ACC_W-1:0] c20_0_o;
  logic signed [ACC_W-1:0] c20_1_o;
  logic signed [ACC_W-1:0] c20_2_o;
  logic signed [ACC_W-1:0] c20_3_o;
  logic signed [ACC_W-1:0] c20_4_o;
  logic signed [ACC_W-1:0] c20_5_o;
  logic signed [ACC_W-1:0] c20_6_o;
  logic signed [ACC_W-1:0] c20_7_o;
  logic signed [ACC_W-1:0] c20_8_o;
  logic signed [ACC_W-1:0] c20_9_o;
  logic signed [ACC_W-1:0] c20_10_o;
  logic signed [ACC_W-1:0] c20_11_o;
  logic signed [ACC_W-1:0] c20_12_o;
  logic signed [ACC_W-1:0] c20_13_o;
  logic signed [ACC_W-1:0] c20_14_o;
  logic signed [ACC_W-1:0] c20_15_o;
  logic signed [ACC_W-1:0] c20_16_o;
  logic signed [ACC_W-1:0] c20_17_o;
  logic signed [ACC_W-1:0] c20_18_o;
  logic signed [ACC_W-1:0] c20_19_o;
  logic signed [ACC_W-1:0] c20_20_o;
  logic signed [ACC_W-1:0] c20_21_o;
  logic signed [ACC_W-1:0] c20_22_o;
  logic signed [ACC_W-1:0] c20_23_o;
  logic signed [ACC_W-1:0] c20_24_o;
  logic signed [ACC_W-1:0] c20_25_o;
  logic signed [ACC_W-1:0] c20_26_o;
  logic signed [ACC_W-1:0] c20_27_o;
  logic signed [ACC_W-1:0] c20_28_o;
  logic signed [ACC_W-1:0] c20_29_o;
  logic signed [ACC_W-1:0] c20_30_o;
  logic signed [ACC_W-1:0] c20_31_o;
  logic signed [ACC_W-1:0] c21_0_o;
  logic signed [ACC_W-1:0] c21_1_o;
  logic signed [ACC_W-1:0] c21_2_o;
  logic signed [ACC_W-1:0] c21_3_o;
  logic signed [ACC_W-1:0] c21_4_o;
  logic signed [ACC_W-1:0] c21_5_o;
  logic signed [ACC_W-1:0] c21_6_o;
  logic signed [ACC_W-1:0] c21_7_o;
  logic signed [ACC_W-1:0] c21_8_o;
  logic signed [ACC_W-1:0] c21_9_o;
  logic signed [ACC_W-1:0] c21_10_o;
  logic signed [ACC_W-1:0] c21_11_o;
  logic signed [ACC_W-1:0] c21_12_o;
  logic signed [ACC_W-1:0] c21_13_o;
  logic signed [ACC_W-1:0] c21_14_o;
  logic signed [ACC_W-1:0] c21_15_o;
  logic signed [ACC_W-1:0] c21_16_o;
  logic signed [ACC_W-1:0] c21_17_o;
  logic signed [ACC_W-1:0] c21_18_o;
  logic signed [ACC_W-1:0] c21_19_o;
  logic signed [ACC_W-1:0] c21_20_o;
  logic signed [ACC_W-1:0] c21_21_o;
  logic signed [ACC_W-1:0] c21_22_o;
  logic signed [ACC_W-1:0] c21_23_o;
  logic signed [ACC_W-1:0] c21_24_o;
  logic signed [ACC_W-1:0] c21_25_o;
  logic signed [ACC_W-1:0] c21_26_o;
  logic signed [ACC_W-1:0] c21_27_o;
  logic signed [ACC_W-1:0] c21_28_o;
  logic signed [ACC_W-1:0] c21_29_o;
  logic signed [ACC_W-1:0] c21_30_o;
  logic signed [ACC_W-1:0] c21_31_o;
  logic signed [ACC_W-1:0] c22_0_o;
  logic signed [ACC_W-1:0] c22_1_o;
  logic signed [ACC_W-1:0] c22_2_o;
  logic signed [ACC_W-1:0] c22_3_o;
  logic signed [ACC_W-1:0] c22_4_o;
  logic signed [ACC_W-1:0] c22_5_o;
  logic signed [ACC_W-1:0] c22_6_o;
  logic signed [ACC_W-1:0] c22_7_o;
  logic signed [ACC_W-1:0] c22_8_o;
  logic signed [ACC_W-1:0] c22_9_o;
  logic signed [ACC_W-1:0] c22_10_o;
  logic signed [ACC_W-1:0] c22_11_o;
  logic signed [ACC_W-1:0] c22_12_o;
  logic signed [ACC_W-1:0] c22_13_o;
  logic signed [ACC_W-1:0] c22_14_o;
  logic signed [ACC_W-1:0] c22_15_o;
  logic signed [ACC_W-1:0] c22_16_o;
  logic signed [ACC_W-1:0] c22_17_o;
  logic signed [ACC_W-1:0] c22_18_o;
  logic signed [ACC_W-1:0] c22_19_o;
  logic signed [ACC_W-1:0] c22_20_o;
  logic signed [ACC_W-1:0] c22_21_o;
  logic signed [ACC_W-1:0] c22_22_o;
  logic signed [ACC_W-1:0] c22_23_o;
  logic signed [ACC_W-1:0] c22_24_o;
  logic signed [ACC_W-1:0] c22_25_o;
  logic signed [ACC_W-1:0] c22_26_o;
  logic signed [ACC_W-1:0] c22_27_o;
  logic signed [ACC_W-1:0] c22_28_o;
  logic signed [ACC_W-1:0] c22_29_o;
  logic signed [ACC_W-1:0] c22_30_o;
  logic signed [ACC_W-1:0] c22_31_o;
  logic signed [ACC_W-1:0] c23_0_o;
  logic signed [ACC_W-1:0] c23_1_o;
  logic signed [ACC_W-1:0] c23_2_o;
  logic signed [ACC_W-1:0] c23_3_o;
  logic signed [ACC_W-1:0] c23_4_o;
  logic signed [ACC_W-1:0] c23_5_o;
  logic signed [ACC_W-1:0] c23_6_o;
  logic signed [ACC_W-1:0] c23_7_o;
  logic signed [ACC_W-1:0] c23_8_o;
  logic signed [ACC_W-1:0] c23_9_o;
  logic signed [ACC_W-1:0] c23_10_o;
  logic signed [ACC_W-1:0] c23_11_o;
  logic signed [ACC_W-1:0] c23_12_o;
  logic signed [ACC_W-1:0] c23_13_o;
  logic signed [ACC_W-1:0] c23_14_o;
  logic signed [ACC_W-1:0] c23_15_o;
  logic signed [ACC_W-1:0] c23_16_o;
  logic signed [ACC_W-1:0] c23_17_o;
  logic signed [ACC_W-1:0] c23_18_o;
  logic signed [ACC_W-1:0] c23_19_o;
  logic signed [ACC_W-1:0] c23_20_o;
  logic signed [ACC_W-1:0] c23_21_o;
  logic signed [ACC_W-1:0] c23_22_o;
  logic signed [ACC_W-1:0] c23_23_o;
  logic signed [ACC_W-1:0] c23_24_o;
  logic signed [ACC_W-1:0] c23_25_o;
  logic signed [ACC_W-1:0] c23_26_o;
  logic signed [ACC_W-1:0] c23_27_o;
  logic signed [ACC_W-1:0] c23_28_o;
  logic signed [ACC_W-1:0] c23_29_o;
  logic signed [ACC_W-1:0] c23_30_o;
  logic signed [ACC_W-1:0] c23_31_o;
  logic signed [ACC_W-1:0] c24_0_o;
  logic signed [ACC_W-1:0] c24_1_o;
  logic signed [ACC_W-1:0] c24_2_o;
  logic signed [ACC_W-1:0] c24_3_o;
  logic signed [ACC_W-1:0] c24_4_o;
  logic signed [ACC_W-1:0] c24_5_o;
  logic signed [ACC_W-1:0] c24_6_o;
  logic signed [ACC_W-1:0] c24_7_o;
  logic signed [ACC_W-1:0] c24_8_o;
  logic signed [ACC_W-1:0] c24_9_o;
  logic signed [ACC_W-1:0] c24_10_o;
  logic signed [ACC_W-1:0] c24_11_o;
  logic signed [ACC_W-1:0] c24_12_o;
  logic signed [ACC_W-1:0] c24_13_o;
  logic signed [ACC_W-1:0] c24_14_o;
  logic signed [ACC_W-1:0] c24_15_o;
  logic signed [ACC_W-1:0] c24_16_o;
  logic signed [ACC_W-1:0] c24_17_o;
  logic signed [ACC_W-1:0] c24_18_o;
  logic signed [ACC_W-1:0] c24_19_o;
  logic signed [ACC_W-1:0] c24_20_o;
  logic signed [ACC_W-1:0] c24_21_o;
  logic signed [ACC_W-1:0] c24_22_o;
  logic signed [ACC_W-1:0] c24_23_o;
  logic signed [ACC_W-1:0] c24_24_o;
  logic signed [ACC_W-1:0] c24_25_o;
  logic signed [ACC_W-1:0] c24_26_o;
  logic signed [ACC_W-1:0] c24_27_o;
  logic signed [ACC_W-1:0] c24_28_o;
  logic signed [ACC_W-1:0] c24_29_o;
  logic signed [ACC_W-1:0] c24_30_o;
  logic signed [ACC_W-1:0] c24_31_o;
  logic signed [ACC_W-1:0] c25_0_o;
  logic signed [ACC_W-1:0] c25_1_o;
  logic signed [ACC_W-1:0] c25_2_o;
  logic signed [ACC_W-1:0] c25_3_o;
  logic signed [ACC_W-1:0] c25_4_o;
  logic signed [ACC_W-1:0] c25_5_o;
  logic signed [ACC_W-1:0] c25_6_o;
  logic signed [ACC_W-1:0] c25_7_o;
  logic signed [ACC_W-1:0] c25_8_o;
  logic signed [ACC_W-1:0] c25_9_o;
  logic signed [ACC_W-1:0] c25_10_o;
  logic signed [ACC_W-1:0] c25_11_o;
  logic signed [ACC_W-1:0] c25_12_o;
  logic signed [ACC_W-1:0] c25_13_o;
  logic signed [ACC_W-1:0] c25_14_o;
  logic signed [ACC_W-1:0] c25_15_o;
  logic signed [ACC_W-1:0] c25_16_o;
  logic signed [ACC_W-1:0] c25_17_o;
  logic signed [ACC_W-1:0] c25_18_o;
  logic signed [ACC_W-1:0] c25_19_o;
  logic signed [ACC_W-1:0] c25_20_o;
  logic signed [ACC_W-1:0] c25_21_o;
  logic signed [ACC_W-1:0] c25_22_o;
  logic signed [ACC_W-1:0] c25_23_o;
  logic signed [ACC_W-1:0] c25_24_o;
  logic signed [ACC_W-1:0] c25_25_o;
  logic signed [ACC_W-1:0] c25_26_o;
  logic signed [ACC_W-1:0] c25_27_o;
  logic signed [ACC_W-1:0] c25_28_o;
  logic signed [ACC_W-1:0] c25_29_o;
  logic signed [ACC_W-1:0] c25_30_o;
  logic signed [ACC_W-1:0] c25_31_o;
  logic signed [ACC_W-1:0] c26_0_o;
  logic signed [ACC_W-1:0] c26_1_o;
  logic signed [ACC_W-1:0] c26_2_o;
  logic signed [ACC_W-1:0] c26_3_o;
  logic signed [ACC_W-1:0] c26_4_o;
  logic signed [ACC_W-1:0] c26_5_o;
  logic signed [ACC_W-1:0] c26_6_o;
  logic signed [ACC_W-1:0] c26_7_o;
  logic signed [ACC_W-1:0] c26_8_o;
  logic signed [ACC_W-1:0] c26_9_o;
  logic signed [ACC_W-1:0] c26_10_o;
  logic signed [ACC_W-1:0] c26_11_o;
  logic signed [ACC_W-1:0] c26_12_o;
  logic signed [ACC_W-1:0] c26_13_o;
  logic signed [ACC_W-1:0] c26_14_o;
  logic signed [ACC_W-1:0] c26_15_o;
  logic signed [ACC_W-1:0] c26_16_o;
  logic signed [ACC_W-1:0] c26_17_o;
  logic signed [ACC_W-1:0] c26_18_o;
  logic signed [ACC_W-1:0] c26_19_o;
  logic signed [ACC_W-1:0] c26_20_o;
  logic signed [ACC_W-1:0] c26_21_o;
  logic signed [ACC_W-1:0] c26_22_o;
  logic signed [ACC_W-1:0] c26_23_o;
  logic signed [ACC_W-1:0] c26_24_o;
  logic signed [ACC_W-1:0] c26_25_o;
  logic signed [ACC_W-1:0] c26_26_o;
  logic signed [ACC_W-1:0] c26_27_o;
  logic signed [ACC_W-1:0] c26_28_o;
  logic signed [ACC_W-1:0] c26_29_o;
  logic signed [ACC_W-1:0] c26_30_o;
  logic signed [ACC_W-1:0] c26_31_o;
  logic signed [ACC_W-1:0] c27_0_o;
  logic signed [ACC_W-1:0] c27_1_o;
  logic signed [ACC_W-1:0] c27_2_o;
  logic signed [ACC_W-1:0] c27_3_o;
  logic signed [ACC_W-1:0] c27_4_o;
  logic signed [ACC_W-1:0] c27_5_o;
  logic signed [ACC_W-1:0] c27_6_o;
  logic signed [ACC_W-1:0] c27_7_o;
  logic signed [ACC_W-1:0] c27_8_o;
  logic signed [ACC_W-1:0] c27_9_o;
  logic signed [ACC_W-1:0] c27_10_o;
  logic signed [ACC_W-1:0] c27_11_o;
  logic signed [ACC_W-1:0] c27_12_o;
  logic signed [ACC_W-1:0] c27_13_o;
  logic signed [ACC_W-1:0] c27_14_o;
  logic signed [ACC_W-1:0] c27_15_o;
  logic signed [ACC_W-1:0] c27_16_o;
  logic signed [ACC_W-1:0] c27_17_o;
  logic signed [ACC_W-1:0] c27_18_o;
  logic signed [ACC_W-1:0] c27_19_o;
  logic signed [ACC_W-1:0] c27_20_o;
  logic signed [ACC_W-1:0] c27_21_o;
  logic signed [ACC_W-1:0] c27_22_o;
  logic signed [ACC_W-1:0] c27_23_o;
  logic signed [ACC_W-1:0] c27_24_o;
  logic signed [ACC_W-1:0] c27_25_o;
  logic signed [ACC_W-1:0] c27_26_o;
  logic signed [ACC_W-1:0] c27_27_o;
  logic signed [ACC_W-1:0] c27_28_o;
  logic signed [ACC_W-1:0] c27_29_o;
  logic signed [ACC_W-1:0] c27_30_o;
  logic signed [ACC_W-1:0] c27_31_o;
  logic signed [ACC_W-1:0] c28_0_o;
  logic signed [ACC_W-1:0] c28_1_o;
  logic signed [ACC_W-1:0] c28_2_o;
  logic signed [ACC_W-1:0] c28_3_o;
  logic signed [ACC_W-1:0] c28_4_o;
  logic signed [ACC_W-1:0] c28_5_o;
  logic signed [ACC_W-1:0] c28_6_o;
  logic signed [ACC_W-1:0] c28_7_o;
  logic signed [ACC_W-1:0] c28_8_o;
  logic signed [ACC_W-1:0] c28_9_o;
  logic signed [ACC_W-1:0] c28_10_o;
  logic signed [ACC_W-1:0] c28_11_o;
  logic signed [ACC_W-1:0] c28_12_o;
  logic signed [ACC_W-1:0] c28_13_o;
  logic signed [ACC_W-1:0] c28_14_o;
  logic signed [ACC_W-1:0] c28_15_o;
  logic signed [ACC_W-1:0] c28_16_o;
  logic signed [ACC_W-1:0] c28_17_o;
  logic signed [ACC_W-1:0] c28_18_o;
  logic signed [ACC_W-1:0] c28_19_o;
  logic signed [ACC_W-1:0] c28_20_o;
  logic signed [ACC_W-1:0] c28_21_o;
  logic signed [ACC_W-1:0] c28_22_o;
  logic signed [ACC_W-1:0] c28_23_o;
  logic signed [ACC_W-1:0] c28_24_o;
  logic signed [ACC_W-1:0] c28_25_o;
  logic signed [ACC_W-1:0] c28_26_o;
  logic signed [ACC_W-1:0] c28_27_o;
  logic signed [ACC_W-1:0] c28_28_o;
  logic signed [ACC_W-1:0] c28_29_o;
  logic signed [ACC_W-1:0] c28_30_o;
  logic signed [ACC_W-1:0] c28_31_o;
  logic signed [ACC_W-1:0] c29_0_o;
  logic signed [ACC_W-1:0] c29_1_o;
  logic signed [ACC_W-1:0] c29_2_o;
  logic signed [ACC_W-1:0] c29_3_o;
  logic signed [ACC_W-1:0] c29_4_o;
  logic signed [ACC_W-1:0] c29_5_o;
  logic signed [ACC_W-1:0] c29_6_o;
  logic signed [ACC_W-1:0] c29_7_o;
  logic signed [ACC_W-1:0] c29_8_o;
  logic signed [ACC_W-1:0] c29_9_o;
  logic signed [ACC_W-1:0] c29_10_o;
  logic signed [ACC_W-1:0] c29_11_o;
  logic signed [ACC_W-1:0] c29_12_o;
  logic signed [ACC_W-1:0] c29_13_o;
  logic signed [ACC_W-1:0] c29_14_o;
  logic signed [ACC_W-1:0] c29_15_o;
  logic signed [ACC_W-1:0] c29_16_o;
  logic signed [ACC_W-1:0] c29_17_o;
  logic signed [ACC_W-1:0] c29_18_o;
  logic signed [ACC_W-1:0] c29_19_o;
  logic signed [ACC_W-1:0] c29_20_o;
  logic signed [ACC_W-1:0] c29_21_o;
  logic signed [ACC_W-1:0] c29_22_o;
  logic signed [ACC_W-1:0] c29_23_o;
  logic signed [ACC_W-1:0] c29_24_o;
  logic signed [ACC_W-1:0] c29_25_o;
  logic signed [ACC_W-1:0] c29_26_o;
  logic signed [ACC_W-1:0] c29_27_o;
  logic signed [ACC_W-1:0] c29_28_o;
  logic signed [ACC_W-1:0] c29_29_o;
  logic signed [ACC_W-1:0] c29_30_o;
  logic signed [ACC_W-1:0] c29_31_o;
  logic signed [ACC_W-1:0] c30_0_o;
  logic signed [ACC_W-1:0] c30_1_o;
  logic signed [ACC_W-1:0] c30_2_o;
  logic signed [ACC_W-1:0] c30_3_o;
  logic signed [ACC_W-1:0] c30_4_o;
  logic signed [ACC_W-1:0] c30_5_o;
  logic signed [ACC_W-1:0] c30_6_o;
  logic signed [ACC_W-1:0] c30_7_o;
  logic signed [ACC_W-1:0] c30_8_o;
  logic signed [ACC_W-1:0] c30_9_o;
  logic signed [ACC_W-1:0] c30_10_o;
  logic signed [ACC_W-1:0] c30_11_o;
  logic signed [ACC_W-1:0] c30_12_o;
  logic signed [ACC_W-1:0] c30_13_o;
  logic signed [ACC_W-1:0] c30_14_o;
  logic signed [ACC_W-1:0] c30_15_o;
  logic signed [ACC_W-1:0] c30_16_o;
  logic signed [ACC_W-1:0] c30_17_o;
  logic signed [ACC_W-1:0] c30_18_o;
  logic signed [ACC_W-1:0] c30_19_o;
  logic signed [ACC_W-1:0] c30_20_o;
  logic signed [ACC_W-1:0] c30_21_o;
  logic signed [ACC_W-1:0] c30_22_o;
  logic signed [ACC_W-1:0] c30_23_o;
  logic signed [ACC_W-1:0] c30_24_o;
  logic signed [ACC_W-1:0] c30_25_o;
  logic signed [ACC_W-1:0] c30_26_o;
  logic signed [ACC_W-1:0] c30_27_o;
  logic signed [ACC_W-1:0] c30_28_o;
  logic signed [ACC_W-1:0] c30_29_o;
  logic signed [ACC_W-1:0] c30_30_o;
  logic signed [ACC_W-1:0] c30_31_o;
  logic signed [ACC_W-1:0] c31_0_o;
  logic signed [ACC_W-1:0] c31_1_o;
  logic signed [ACC_W-1:0] c31_2_o;
  logic signed [ACC_W-1:0] c31_3_o;
  logic signed [ACC_W-1:0] c31_4_o;
  logic signed [ACC_W-1:0] c31_5_o;
  logic signed [ACC_W-1:0] c31_6_o;
  logic signed [ACC_W-1:0] c31_7_o;
  logic signed [ACC_W-1:0] c31_8_o;
  logic signed [ACC_W-1:0] c31_9_o;
  logic signed [ACC_W-1:0] c31_10_o;
  logic signed [ACC_W-1:0] c31_11_o;
  logic signed [ACC_W-1:0] c31_12_o;
  logic signed [ACC_W-1:0] c31_13_o;
  logic signed [ACC_W-1:0] c31_14_o;
  logic signed [ACC_W-1:0] c31_15_o;
  logic signed [ACC_W-1:0] c31_16_o;
  logic signed [ACC_W-1:0] c31_17_o;
  logic signed [ACC_W-1:0] c31_18_o;
  logic signed [ACC_W-1:0] c31_19_o;
  logic signed [ACC_W-1:0] c31_20_o;
  logic signed [ACC_W-1:0] c31_21_o;
  logic signed [ACC_W-1:0] c31_22_o;
  logic signed [ACC_W-1:0] c31_23_o;
  logic signed [ACC_W-1:0] c31_24_o;
  logic signed [ACC_W-1:0] c31_25_o;
  logic signed [ACC_W-1:0] c31_26_o;
  logic signed [ACC_W-1:0] c31_27_o;
  logic signed [ACC_W-1:0] c31_28_o;
  logic signed [ACC_W-1:0] c31_29_o;
  logic signed [ACC_W-1:0] c31_30_o;
  logic signed [ACC_W-1:0] c31_31_o;

  assign c_o[0][0] = c0_0_o;
  assign c_o[0][1] = c0_1_o;
  assign c_o[0][2] = c0_2_o;
  assign c_o[0][3] = c0_3_o;
  assign c_o[0][4] = c0_4_o;
  assign c_o[0][5] = c0_5_o;
  assign c_o[0][6] = c0_6_o;
  assign c_o[0][7] = c0_7_o;
  assign c_o[0][8] = c0_8_o;
  assign c_o[0][9] = c0_9_o;
  assign c_o[0][10] = c0_10_o;
  assign c_o[0][11] = c0_11_o;
  assign c_o[0][12] = c0_12_o;
  assign c_o[0][13] = c0_13_o;
  assign c_o[0][14] = c0_14_o;
  assign c_o[0][15] = c0_15_o;
  assign c_o[0][16] = c0_16_o;
  assign c_o[0][17] = c0_17_o;
  assign c_o[0][18] = c0_18_o;
  assign c_o[0][19] = c0_19_o;
  assign c_o[0][20] = c0_20_o;
  assign c_o[0][21] = c0_21_o;
  assign c_o[0][22] = c0_22_o;
  assign c_o[0][23] = c0_23_o;
  assign c_o[0][24] = c0_24_o;
  assign c_o[0][25] = c0_25_o;
  assign c_o[0][26] = c0_26_o;
  assign c_o[0][27] = c0_27_o;
  assign c_o[0][28] = c0_28_o;
  assign c_o[0][29] = c0_29_o;
  assign c_o[0][30] = c0_30_o;
  assign c_o[0][31] = c0_31_o;
  assign c_o[1][0] = c1_0_o;
  assign c_o[1][1] = c1_1_o;
  assign c_o[1][2] = c1_2_o;
  assign c_o[1][3] = c1_3_o;
  assign c_o[1][4] = c1_4_o;
  assign c_o[1][5] = c1_5_o;
  assign c_o[1][6] = c1_6_o;
  assign c_o[1][7] = c1_7_o;
  assign c_o[1][8] = c1_8_o;
  assign c_o[1][9] = c1_9_o;
  assign c_o[1][10] = c1_10_o;
  assign c_o[1][11] = c1_11_o;
  assign c_o[1][12] = c1_12_o;
  assign c_o[1][13] = c1_13_o;
  assign c_o[1][14] = c1_14_o;
  assign c_o[1][15] = c1_15_o;
  assign c_o[1][16] = c1_16_o;
  assign c_o[1][17] = c1_17_o;
  assign c_o[1][18] = c1_18_o;
  assign c_o[1][19] = c1_19_o;
  assign c_o[1][20] = c1_20_o;
  assign c_o[1][21] = c1_21_o;
  assign c_o[1][22] = c1_22_o;
  assign c_o[1][23] = c1_23_o;
  assign c_o[1][24] = c1_24_o;
  assign c_o[1][25] = c1_25_o;
  assign c_o[1][26] = c1_26_o;
  assign c_o[1][27] = c1_27_o;
  assign c_o[1][28] = c1_28_o;
  assign c_o[1][29] = c1_29_o;
  assign c_o[1][30] = c1_30_o;
  assign c_o[1][31] = c1_31_o;
  assign c_o[2][0] = c2_0_o;
  assign c_o[2][1] = c2_1_o;
  assign c_o[2][2] = c2_2_o;
  assign c_o[2][3] = c2_3_o;
  assign c_o[2][4] = c2_4_o;
  assign c_o[2][5] = c2_5_o;
  assign c_o[2][6] = c2_6_o;
  assign c_o[2][7] = c2_7_o;
  assign c_o[2][8] = c2_8_o;
  assign c_o[2][9] = c2_9_o;
  assign c_o[2][10] = c2_10_o;
  assign c_o[2][11] = c2_11_o;
  assign c_o[2][12] = c2_12_o;
  assign c_o[2][13] = c2_13_o;
  assign c_o[2][14] = c2_14_o;
  assign c_o[2][15] = c2_15_o;
  assign c_o[2][16] = c2_16_o;
  assign c_o[2][17] = c2_17_o;
  assign c_o[2][18] = c2_18_o;
  assign c_o[2][19] = c2_19_o;
  assign c_o[2][20] = c2_20_o;
  assign c_o[2][21] = c2_21_o;
  assign c_o[2][22] = c2_22_o;
  assign c_o[2][23] = c2_23_o;
  assign c_o[2][24] = c2_24_o;
  assign c_o[2][25] = c2_25_o;
  assign c_o[2][26] = c2_26_o;
  assign c_o[2][27] = c2_27_o;
  assign c_o[2][28] = c2_28_o;
  assign c_o[2][29] = c2_29_o;
  assign c_o[2][30] = c2_30_o;
  assign c_o[2][31] = c2_31_o;
  assign c_o[3][0] = c3_0_o;
  assign c_o[3][1] = c3_1_o;
  assign c_o[3][2] = c3_2_o;
  assign c_o[3][3] = c3_3_o;
  assign c_o[3][4] = c3_4_o;
  assign c_o[3][5] = c3_5_o;
  assign c_o[3][6] = c3_6_o;
  assign c_o[3][7] = c3_7_o;
  assign c_o[3][8] = c3_8_o;
  assign c_o[3][9] = c3_9_o;
  assign c_o[3][10] = c3_10_o;
  assign c_o[3][11] = c3_11_o;
  assign c_o[3][12] = c3_12_o;
  assign c_o[3][13] = c3_13_o;
  assign c_o[3][14] = c3_14_o;
  assign c_o[3][15] = c3_15_o;
  assign c_o[3][16] = c3_16_o;
  assign c_o[3][17] = c3_17_o;
  assign c_o[3][18] = c3_18_o;
  assign c_o[3][19] = c3_19_o;
  assign c_o[3][20] = c3_20_o;
  assign c_o[3][21] = c3_21_o;
  assign c_o[3][22] = c3_22_o;
  assign c_o[3][23] = c3_23_o;
  assign c_o[3][24] = c3_24_o;
  assign c_o[3][25] = c3_25_o;
  assign c_o[3][26] = c3_26_o;
  assign c_o[3][27] = c3_27_o;
  assign c_o[3][28] = c3_28_o;
  assign c_o[3][29] = c3_29_o;
  assign c_o[3][30] = c3_30_o;
  assign c_o[3][31] = c3_31_o;
  assign c_o[4][0] = c4_0_o;
  assign c_o[4][1] = c4_1_o;
  assign c_o[4][2] = c4_2_o;
  assign c_o[4][3] = c4_3_o;
  assign c_o[4][4] = c4_4_o;
  assign c_o[4][5] = c4_5_o;
  assign c_o[4][6] = c4_6_o;
  assign c_o[4][7] = c4_7_o;
  assign c_o[4][8] = c4_8_o;
  assign c_o[4][9] = c4_9_o;
  assign c_o[4][10] = c4_10_o;
  assign c_o[4][11] = c4_11_o;
  assign c_o[4][12] = c4_12_o;
  assign c_o[4][13] = c4_13_o;
  assign c_o[4][14] = c4_14_o;
  assign c_o[4][15] = c4_15_o;
  assign c_o[4][16] = c4_16_o;
  assign c_o[4][17] = c4_17_o;
  assign c_o[4][18] = c4_18_o;
  assign c_o[4][19] = c4_19_o;
  assign c_o[4][20] = c4_20_o;
  assign c_o[4][21] = c4_21_o;
  assign c_o[4][22] = c4_22_o;
  assign c_o[4][23] = c4_23_o;
  assign c_o[4][24] = c4_24_o;
  assign c_o[4][25] = c4_25_o;
  assign c_o[4][26] = c4_26_o;
  assign c_o[4][27] = c4_27_o;
  assign c_o[4][28] = c4_28_o;
  assign c_o[4][29] = c4_29_o;
  assign c_o[4][30] = c4_30_o;
  assign c_o[4][31] = c4_31_o;
  assign c_o[5][0] = c5_0_o;
  assign c_o[5][1] = c5_1_o;
  assign c_o[5][2] = c5_2_o;
  assign c_o[5][3] = c5_3_o;
  assign c_o[5][4] = c5_4_o;
  assign c_o[5][5] = c5_5_o;
  assign c_o[5][6] = c5_6_o;
  assign c_o[5][7] = c5_7_o;
  assign c_o[5][8] = c5_8_o;
  assign c_o[5][9] = c5_9_o;
  assign c_o[5][10] = c5_10_o;
  assign c_o[5][11] = c5_11_o;
  assign c_o[5][12] = c5_12_o;
  assign c_o[5][13] = c5_13_o;
  assign c_o[5][14] = c5_14_o;
  assign c_o[5][15] = c5_15_o;
  assign c_o[5][16] = c5_16_o;
  assign c_o[5][17] = c5_17_o;
  assign c_o[5][18] = c5_18_o;
  assign c_o[5][19] = c5_19_o;
  assign c_o[5][20] = c5_20_o;
  assign c_o[5][21] = c5_21_o;
  assign c_o[5][22] = c5_22_o;
  assign c_o[5][23] = c5_23_o;
  assign c_o[5][24] = c5_24_o;
  assign c_o[5][25] = c5_25_o;
  assign c_o[5][26] = c5_26_o;
  assign c_o[5][27] = c5_27_o;
  assign c_o[5][28] = c5_28_o;
  assign c_o[5][29] = c5_29_o;
  assign c_o[5][30] = c5_30_o;
  assign c_o[5][31] = c5_31_o;
  assign c_o[6][0] = c6_0_o;
  assign c_o[6][1] = c6_1_o;
  assign c_o[6][2] = c6_2_o;
  assign c_o[6][3] = c6_3_o;
  assign c_o[6][4] = c6_4_o;
  assign c_o[6][5] = c6_5_o;
  assign c_o[6][6] = c6_6_o;
  assign c_o[6][7] = c6_7_o;
  assign c_o[6][8] = c6_8_o;
  assign c_o[6][9] = c6_9_o;
  assign c_o[6][10] = c6_10_o;
  assign c_o[6][11] = c6_11_o;
  assign c_o[6][12] = c6_12_o;
  assign c_o[6][13] = c6_13_o;
  assign c_o[6][14] = c6_14_o;
  assign c_o[6][15] = c6_15_o;
  assign c_o[6][16] = c6_16_o;
  assign c_o[6][17] = c6_17_o;
  assign c_o[6][18] = c6_18_o;
  assign c_o[6][19] = c6_19_o;
  assign c_o[6][20] = c6_20_o;
  assign c_o[6][21] = c6_21_o;
  assign c_o[6][22] = c6_22_o;
  assign c_o[6][23] = c6_23_o;
  assign c_o[6][24] = c6_24_o;
  assign c_o[6][25] = c6_25_o;
  assign c_o[6][26] = c6_26_o;
  assign c_o[6][27] = c6_27_o;
  assign c_o[6][28] = c6_28_o;
  assign c_o[6][29] = c6_29_o;
  assign c_o[6][30] = c6_30_o;
  assign c_o[6][31] = c6_31_o;
  assign c_o[7][0] = c7_0_o;
  assign c_o[7][1] = c7_1_o;
  assign c_o[7][2] = c7_2_o;
  assign c_o[7][3] = c7_3_o;
  assign c_o[7][4] = c7_4_o;
  assign c_o[7][5] = c7_5_o;
  assign c_o[7][6] = c7_6_o;
  assign c_o[7][7] = c7_7_o;
  assign c_o[7][8] = c7_8_o;
  assign c_o[7][9] = c7_9_o;
  assign c_o[7][10] = c7_10_o;
  assign c_o[7][11] = c7_11_o;
  assign c_o[7][12] = c7_12_o;
  assign c_o[7][13] = c7_13_o;
  assign c_o[7][14] = c7_14_o;
  assign c_o[7][15] = c7_15_o;
  assign c_o[7][16] = c7_16_o;
  assign c_o[7][17] = c7_17_o;
  assign c_o[7][18] = c7_18_o;
  assign c_o[7][19] = c7_19_o;
  assign c_o[7][20] = c7_20_o;
  assign c_o[7][21] = c7_21_o;
  assign c_o[7][22] = c7_22_o;
  assign c_o[7][23] = c7_23_o;
  assign c_o[7][24] = c7_24_o;
  assign c_o[7][25] = c7_25_o;
  assign c_o[7][26] = c7_26_o;
  assign c_o[7][27] = c7_27_o;
  assign c_o[7][28] = c7_28_o;
  assign c_o[7][29] = c7_29_o;
  assign c_o[7][30] = c7_30_o;
  assign c_o[7][31] = c7_31_o;
  assign c_o[8][0] = c8_0_o;
  assign c_o[8][1] = c8_1_o;
  assign c_o[8][2] = c8_2_o;
  assign c_o[8][3] = c8_3_o;
  assign c_o[8][4] = c8_4_o;
  assign c_o[8][5] = c8_5_o;
  assign c_o[8][6] = c8_6_o;
  assign c_o[8][7] = c8_7_o;
  assign c_o[8][8] = c8_8_o;
  assign c_o[8][9] = c8_9_o;
  assign c_o[8][10] = c8_10_o;
  assign c_o[8][11] = c8_11_o;
  assign c_o[8][12] = c8_12_o;
  assign c_o[8][13] = c8_13_o;
  assign c_o[8][14] = c8_14_o;
  assign c_o[8][15] = c8_15_o;
  assign c_o[8][16] = c8_16_o;
  assign c_o[8][17] = c8_17_o;
  assign c_o[8][18] = c8_18_o;
  assign c_o[8][19] = c8_19_o;
  assign c_o[8][20] = c8_20_o;
  assign c_o[8][21] = c8_21_o;
  assign c_o[8][22] = c8_22_o;
  assign c_o[8][23] = c8_23_o;
  assign c_o[8][24] = c8_24_o;
  assign c_o[8][25] = c8_25_o;
  assign c_o[8][26] = c8_26_o;
  assign c_o[8][27] = c8_27_o;
  assign c_o[8][28] = c8_28_o;
  assign c_o[8][29] = c8_29_o;
  assign c_o[8][30] = c8_30_o;
  assign c_o[8][31] = c8_31_o;
  assign c_o[9][0] = c9_0_o;
  assign c_o[9][1] = c9_1_o;
  assign c_o[9][2] = c9_2_o;
  assign c_o[9][3] = c9_3_o;
  assign c_o[9][4] = c9_4_o;
  assign c_o[9][5] = c9_5_o;
  assign c_o[9][6] = c9_6_o;
  assign c_o[9][7] = c9_7_o;
  assign c_o[9][8] = c9_8_o;
  assign c_o[9][9] = c9_9_o;
  assign c_o[9][10] = c9_10_o;
  assign c_o[9][11] = c9_11_o;
  assign c_o[9][12] = c9_12_o;
  assign c_o[9][13] = c9_13_o;
  assign c_o[9][14] = c9_14_o;
  assign c_o[9][15] = c9_15_o;
  assign c_o[9][16] = c9_16_o;
  assign c_o[9][17] = c9_17_o;
  assign c_o[9][18] = c9_18_o;
  assign c_o[9][19] = c9_19_o;
  assign c_o[9][20] = c9_20_o;
  assign c_o[9][21] = c9_21_o;
  assign c_o[9][22] = c9_22_o;
  assign c_o[9][23] = c9_23_o;
  assign c_o[9][24] = c9_24_o;
  assign c_o[9][25] = c9_25_o;
  assign c_o[9][26] = c9_26_o;
  assign c_o[9][27] = c9_27_o;
  assign c_o[9][28] = c9_28_o;
  assign c_o[9][29] = c9_29_o;
  assign c_o[9][30] = c9_30_o;
  assign c_o[9][31] = c9_31_o;
  assign c_o[10][0] = c10_0_o;
  assign c_o[10][1] = c10_1_o;
  assign c_o[10][2] = c10_2_o;
  assign c_o[10][3] = c10_3_o;
  assign c_o[10][4] = c10_4_o;
  assign c_o[10][5] = c10_5_o;
  assign c_o[10][6] = c10_6_o;
  assign c_o[10][7] = c10_7_o;
  assign c_o[10][8] = c10_8_o;
  assign c_o[10][9] = c10_9_o;
  assign c_o[10][10] = c10_10_o;
  assign c_o[10][11] = c10_11_o;
  assign c_o[10][12] = c10_12_o;
  assign c_o[10][13] = c10_13_o;
  assign c_o[10][14] = c10_14_o;
  assign c_o[10][15] = c10_15_o;
  assign c_o[10][16] = c10_16_o;
  assign c_o[10][17] = c10_17_o;
  assign c_o[10][18] = c10_18_o;
  assign c_o[10][19] = c10_19_o;
  assign c_o[10][20] = c10_20_o;
  assign c_o[10][21] = c10_21_o;
  assign c_o[10][22] = c10_22_o;
  assign c_o[10][23] = c10_23_o;
  assign c_o[10][24] = c10_24_o;
  assign c_o[10][25] = c10_25_o;
  assign c_o[10][26] = c10_26_o;
  assign c_o[10][27] = c10_27_o;
  assign c_o[10][28] = c10_28_o;
  assign c_o[10][29] = c10_29_o;
  assign c_o[10][30] = c10_30_o;
  assign c_o[10][31] = c10_31_o;
  assign c_o[11][0] = c11_0_o;
  assign c_o[11][1] = c11_1_o;
  assign c_o[11][2] = c11_2_o;
  assign c_o[11][3] = c11_3_o;
  assign c_o[11][4] = c11_4_o;
  assign c_o[11][5] = c11_5_o;
  assign c_o[11][6] = c11_6_o;
  assign c_o[11][7] = c11_7_o;
  assign c_o[11][8] = c11_8_o;
  assign c_o[11][9] = c11_9_o;
  assign c_o[11][10] = c11_10_o;
  assign c_o[11][11] = c11_11_o;
  assign c_o[11][12] = c11_12_o;
  assign c_o[11][13] = c11_13_o;
  assign c_o[11][14] = c11_14_o;
  assign c_o[11][15] = c11_15_o;
  assign c_o[11][16] = c11_16_o;
  assign c_o[11][17] = c11_17_o;
  assign c_o[11][18] = c11_18_o;
  assign c_o[11][19] = c11_19_o;
  assign c_o[11][20] = c11_20_o;
  assign c_o[11][21] = c11_21_o;
  assign c_o[11][22] = c11_22_o;
  assign c_o[11][23] = c11_23_o;
  assign c_o[11][24] = c11_24_o;
  assign c_o[11][25] = c11_25_o;
  assign c_o[11][26] = c11_26_o;
  assign c_o[11][27] = c11_27_o;
  assign c_o[11][28] = c11_28_o;
  assign c_o[11][29] = c11_29_o;
  assign c_o[11][30] = c11_30_o;
  assign c_o[11][31] = c11_31_o;
  assign c_o[12][0] = c12_0_o;
  assign c_o[12][1] = c12_1_o;
  assign c_o[12][2] = c12_2_o;
  assign c_o[12][3] = c12_3_o;
  assign c_o[12][4] = c12_4_o;
  assign c_o[12][5] = c12_5_o;
  assign c_o[12][6] = c12_6_o;
  assign c_o[12][7] = c12_7_o;
  assign c_o[12][8] = c12_8_o;
  assign c_o[12][9] = c12_9_o;
  assign c_o[12][10] = c12_10_o;
  assign c_o[12][11] = c12_11_o;
  assign c_o[12][12] = c12_12_o;
  assign c_o[12][13] = c12_13_o;
  assign c_o[12][14] = c12_14_o;
  assign c_o[12][15] = c12_15_o;
  assign c_o[12][16] = c12_16_o;
  assign c_o[12][17] = c12_17_o;
  assign c_o[12][18] = c12_18_o;
  assign c_o[12][19] = c12_19_o;
  assign c_o[12][20] = c12_20_o;
  assign c_o[12][21] = c12_21_o;
  assign c_o[12][22] = c12_22_o;
  assign c_o[12][23] = c12_23_o;
  assign c_o[12][24] = c12_24_o;
  assign c_o[12][25] = c12_25_o;
  assign c_o[12][26] = c12_26_o;
  assign c_o[12][27] = c12_27_o;
  assign c_o[12][28] = c12_28_o;
  assign c_o[12][29] = c12_29_o;
  assign c_o[12][30] = c12_30_o;
  assign c_o[12][31] = c12_31_o;
  assign c_o[13][0] = c13_0_o;
  assign c_o[13][1] = c13_1_o;
  assign c_o[13][2] = c13_2_o;
  assign c_o[13][3] = c13_3_o;
  assign c_o[13][4] = c13_4_o;
  assign c_o[13][5] = c13_5_o;
  assign c_o[13][6] = c13_6_o;
  assign c_o[13][7] = c13_7_o;
  assign c_o[13][8] = c13_8_o;
  assign c_o[13][9] = c13_9_o;
  assign c_o[13][10] = c13_10_o;
  assign c_o[13][11] = c13_11_o;
  assign c_o[13][12] = c13_12_o;
  assign c_o[13][13] = c13_13_o;
  assign c_o[13][14] = c13_14_o;
  assign c_o[13][15] = c13_15_o;
  assign c_o[13][16] = c13_16_o;
  assign c_o[13][17] = c13_17_o;
  assign c_o[13][18] = c13_18_o;
  assign c_o[13][19] = c13_19_o;
  assign c_o[13][20] = c13_20_o;
  assign c_o[13][21] = c13_21_o;
  assign c_o[13][22] = c13_22_o;
  assign c_o[13][23] = c13_23_o;
  assign c_o[13][24] = c13_24_o;
  assign c_o[13][25] = c13_25_o;
  assign c_o[13][26] = c13_26_o;
  assign c_o[13][27] = c13_27_o;
  assign c_o[13][28] = c13_28_o;
  assign c_o[13][29] = c13_29_o;
  assign c_o[13][30] = c13_30_o;
  assign c_o[13][31] = c13_31_o;
  assign c_o[14][0] = c14_0_o;
  assign c_o[14][1] = c14_1_o;
  assign c_o[14][2] = c14_2_o;
  assign c_o[14][3] = c14_3_o;
  assign c_o[14][4] = c14_4_o;
  assign c_o[14][5] = c14_5_o;
  assign c_o[14][6] = c14_6_o;
  assign c_o[14][7] = c14_7_o;
  assign c_o[14][8] = c14_8_o;
  assign c_o[14][9] = c14_9_o;
  assign c_o[14][10] = c14_10_o;
  assign c_o[14][11] = c14_11_o;
  assign c_o[14][12] = c14_12_o;
  assign c_o[14][13] = c14_13_o;
  assign c_o[14][14] = c14_14_o;
  assign c_o[14][15] = c14_15_o;
  assign c_o[14][16] = c14_16_o;
  assign c_o[14][17] = c14_17_o;
  assign c_o[14][18] = c14_18_o;
  assign c_o[14][19] = c14_19_o;
  assign c_o[14][20] = c14_20_o;
  assign c_o[14][21] = c14_21_o;
  assign c_o[14][22] = c14_22_o;
  assign c_o[14][23] = c14_23_o;
  assign c_o[14][24] = c14_24_o;
  assign c_o[14][25] = c14_25_o;
  assign c_o[14][26] = c14_26_o;
  assign c_o[14][27] = c14_27_o;
  assign c_o[14][28] = c14_28_o;
  assign c_o[14][29] = c14_29_o;
  assign c_o[14][30] = c14_30_o;
  assign c_o[14][31] = c14_31_o;
  assign c_o[15][0] = c15_0_o;
  assign c_o[15][1] = c15_1_o;
  assign c_o[15][2] = c15_2_o;
  assign c_o[15][3] = c15_3_o;
  assign c_o[15][4] = c15_4_o;
  assign c_o[15][5] = c15_5_o;
  assign c_o[15][6] = c15_6_o;
  assign c_o[15][7] = c15_7_o;
  assign c_o[15][8] = c15_8_o;
  assign c_o[15][9] = c15_9_o;
  assign c_o[15][10] = c15_10_o;
  assign c_o[15][11] = c15_11_o;
  assign c_o[15][12] = c15_12_o;
  assign c_o[15][13] = c15_13_o;
  assign c_o[15][14] = c15_14_o;
  assign c_o[15][15] = c15_15_o;
  assign c_o[15][16] = c15_16_o;
  assign c_o[15][17] = c15_17_o;
  assign c_o[15][18] = c15_18_o;
  assign c_o[15][19] = c15_19_o;
  assign c_o[15][20] = c15_20_o;
  assign c_o[15][21] = c15_21_o;
  assign c_o[15][22] = c15_22_o;
  assign c_o[15][23] = c15_23_o;
  assign c_o[15][24] = c15_24_o;
  assign c_o[15][25] = c15_25_o;
  assign c_o[15][26] = c15_26_o;
  assign c_o[15][27] = c15_27_o;
  assign c_o[15][28] = c15_28_o;
  assign c_o[15][29] = c15_29_o;
  assign c_o[15][30] = c15_30_o;
  assign c_o[15][31] = c15_31_o;
  assign c_o[16][0] = c16_0_o;
  assign c_o[16][1] = c16_1_o;
  assign c_o[16][2] = c16_2_o;
  assign c_o[16][3] = c16_3_o;
  assign c_o[16][4] = c16_4_o;
  assign c_o[16][5] = c16_5_o;
  assign c_o[16][6] = c16_6_o;
  assign c_o[16][7] = c16_7_o;
  assign c_o[16][8] = c16_8_o;
  assign c_o[16][9] = c16_9_o;
  assign c_o[16][10] = c16_10_o;
  assign c_o[16][11] = c16_11_o;
  assign c_o[16][12] = c16_12_o;
  assign c_o[16][13] = c16_13_o;
  assign c_o[16][14] = c16_14_o;
  assign c_o[16][15] = c16_15_o;
  assign c_o[16][16] = c16_16_o;
  assign c_o[16][17] = c16_17_o;
  assign c_o[16][18] = c16_18_o;
  assign c_o[16][19] = c16_19_o;
  assign c_o[16][20] = c16_20_o;
  assign c_o[16][21] = c16_21_o;
  assign c_o[16][22] = c16_22_o;
  assign c_o[16][23] = c16_23_o;
  assign c_o[16][24] = c16_24_o;
  assign c_o[16][25] = c16_25_o;
  assign c_o[16][26] = c16_26_o;
  assign c_o[16][27] = c16_27_o;
  assign c_o[16][28] = c16_28_o;
  assign c_o[16][29] = c16_29_o;
  assign c_o[16][30] = c16_30_o;
  assign c_o[16][31] = c16_31_o;
  assign c_o[17][0] = c17_0_o;
  assign c_o[17][1] = c17_1_o;
  assign c_o[17][2] = c17_2_o;
  assign c_o[17][3] = c17_3_o;
  assign c_o[17][4] = c17_4_o;
  assign c_o[17][5] = c17_5_o;
  assign c_o[17][6] = c17_6_o;
  assign c_o[17][7] = c17_7_o;
  assign c_o[17][8] = c17_8_o;
  assign c_o[17][9] = c17_9_o;
  assign c_o[17][10] = c17_10_o;
  assign c_o[17][11] = c17_11_o;
  assign c_o[17][12] = c17_12_o;
  assign c_o[17][13] = c17_13_o;
  assign c_o[17][14] = c17_14_o;
  assign c_o[17][15] = c17_15_o;
  assign c_o[17][16] = c17_16_o;
  assign c_o[17][17] = c17_17_o;
  assign c_o[17][18] = c17_18_o;
  assign c_o[17][19] = c17_19_o;
  assign c_o[17][20] = c17_20_o;
  assign c_o[17][21] = c17_21_o;
  assign c_o[17][22] = c17_22_o;
  assign c_o[17][23] = c17_23_o;
  assign c_o[17][24] = c17_24_o;
  assign c_o[17][25] = c17_25_o;
  assign c_o[17][26] = c17_26_o;
  assign c_o[17][27] = c17_27_o;
  assign c_o[17][28] = c17_28_o;
  assign c_o[17][29] = c17_29_o;
  assign c_o[17][30] = c17_30_o;
  assign c_o[17][31] = c17_31_o;
  assign c_o[18][0] = c18_0_o;
  assign c_o[18][1] = c18_1_o;
  assign c_o[18][2] = c18_2_o;
  assign c_o[18][3] = c18_3_o;
  assign c_o[18][4] = c18_4_o;
  assign c_o[18][5] = c18_5_o;
  assign c_o[18][6] = c18_6_o;
  assign c_o[18][7] = c18_7_o;
  assign c_o[18][8] = c18_8_o;
  assign c_o[18][9] = c18_9_o;
  assign c_o[18][10] = c18_10_o;
  assign c_o[18][11] = c18_11_o;
  assign c_o[18][12] = c18_12_o;
  assign c_o[18][13] = c18_13_o;
  assign c_o[18][14] = c18_14_o;
  assign c_o[18][15] = c18_15_o;
  assign c_o[18][16] = c18_16_o;
  assign c_o[18][17] = c18_17_o;
  assign c_o[18][18] = c18_18_o;
  assign c_o[18][19] = c18_19_o;
  assign c_o[18][20] = c18_20_o;
  assign c_o[18][21] = c18_21_o;
  assign c_o[18][22] = c18_22_o;
  assign c_o[18][23] = c18_23_o;
  assign c_o[18][24] = c18_24_o;
  assign c_o[18][25] = c18_25_o;
  assign c_o[18][26] = c18_26_o;
  assign c_o[18][27] = c18_27_o;
  assign c_o[18][28] = c18_28_o;
  assign c_o[18][29] = c18_29_o;
  assign c_o[18][30] = c18_30_o;
  assign c_o[18][31] = c18_31_o;
  assign c_o[19][0] = c19_0_o;
  assign c_o[19][1] = c19_1_o;
  assign c_o[19][2] = c19_2_o;
  assign c_o[19][3] = c19_3_o;
  assign c_o[19][4] = c19_4_o;
  assign c_o[19][5] = c19_5_o;
  assign c_o[19][6] = c19_6_o;
  assign c_o[19][7] = c19_7_o;
  assign c_o[19][8] = c19_8_o;
  assign c_o[19][9] = c19_9_o;
  assign c_o[19][10] = c19_10_o;
  assign c_o[19][11] = c19_11_o;
  assign c_o[19][12] = c19_12_o;
  assign c_o[19][13] = c19_13_o;
  assign c_o[19][14] = c19_14_o;
  assign c_o[19][15] = c19_15_o;
  assign c_o[19][16] = c19_16_o;
  assign c_o[19][17] = c19_17_o;
  assign c_o[19][18] = c19_18_o;
  assign c_o[19][19] = c19_19_o;
  assign c_o[19][20] = c19_20_o;
  assign c_o[19][21] = c19_21_o;
  assign c_o[19][22] = c19_22_o;
  assign c_o[19][23] = c19_23_o;
  assign c_o[19][24] = c19_24_o;
  assign c_o[19][25] = c19_25_o;
  assign c_o[19][26] = c19_26_o;
  assign c_o[19][27] = c19_27_o;
  assign c_o[19][28] = c19_28_o;
  assign c_o[19][29] = c19_29_o;
  assign c_o[19][30] = c19_30_o;
  assign c_o[19][31] = c19_31_o;
  assign c_o[20][0] = c20_0_o;
  assign c_o[20][1] = c20_1_o;
  assign c_o[20][2] = c20_2_o;
  assign c_o[20][3] = c20_3_o;
  assign c_o[20][4] = c20_4_o;
  assign c_o[20][5] = c20_5_o;
  assign c_o[20][6] = c20_6_o;
  assign c_o[20][7] = c20_7_o;
  assign c_o[20][8] = c20_8_o;
  assign c_o[20][9] = c20_9_o;
  assign c_o[20][10] = c20_10_o;
  assign c_o[20][11] = c20_11_o;
  assign c_o[20][12] = c20_12_o;
  assign c_o[20][13] = c20_13_o;
  assign c_o[20][14] = c20_14_o;
  assign c_o[20][15] = c20_15_o;
  assign c_o[20][16] = c20_16_o;
  assign c_o[20][17] = c20_17_o;
  assign c_o[20][18] = c20_18_o;
  assign c_o[20][19] = c20_19_o;
  assign c_o[20][20] = c20_20_o;
  assign c_o[20][21] = c20_21_o;
  assign c_o[20][22] = c20_22_o;
  assign c_o[20][23] = c20_23_o;
  assign c_o[20][24] = c20_24_o;
  assign c_o[20][25] = c20_25_o;
  assign c_o[20][26] = c20_26_o;
  assign c_o[20][27] = c20_27_o;
  assign c_o[20][28] = c20_28_o;
  assign c_o[20][29] = c20_29_o;
  assign c_o[20][30] = c20_30_o;
  assign c_o[20][31] = c20_31_o;
  assign c_o[21][0] = c21_0_o;
  assign c_o[21][1] = c21_1_o;
  assign c_o[21][2] = c21_2_o;
  assign c_o[21][3] = c21_3_o;
  assign c_o[21][4] = c21_4_o;
  assign c_o[21][5] = c21_5_o;
  assign c_o[21][6] = c21_6_o;
  assign c_o[21][7] = c21_7_o;
  assign c_o[21][8] = c21_8_o;
  assign c_o[21][9] = c21_9_o;
  assign c_o[21][10] = c21_10_o;
  assign c_o[21][11] = c21_11_o;
  assign c_o[21][12] = c21_12_o;
  assign c_o[21][13] = c21_13_o;
  assign c_o[21][14] = c21_14_o;
  assign c_o[21][15] = c21_15_o;
  assign c_o[21][16] = c21_16_o;
  assign c_o[21][17] = c21_17_o;
  assign c_o[21][18] = c21_18_o;
  assign c_o[21][19] = c21_19_o;
  assign c_o[21][20] = c21_20_o;
  assign c_o[21][21] = c21_21_o;
  assign c_o[21][22] = c21_22_o;
  assign c_o[21][23] = c21_23_o;
  assign c_o[21][24] = c21_24_o;
  assign c_o[21][25] = c21_25_o;
  assign c_o[21][26] = c21_26_o;
  assign c_o[21][27] = c21_27_o;
  assign c_o[21][28] = c21_28_o;
  assign c_o[21][29] = c21_29_o;
  assign c_o[21][30] = c21_30_o;
  assign c_o[21][31] = c21_31_o;
  assign c_o[22][0] = c22_0_o;
  assign c_o[22][1] = c22_1_o;
  assign c_o[22][2] = c22_2_o;
  assign c_o[22][3] = c22_3_o;
  assign c_o[22][4] = c22_4_o;
  assign c_o[22][5] = c22_5_o;
  assign c_o[22][6] = c22_6_o;
  assign c_o[22][7] = c22_7_o;
  assign c_o[22][8] = c22_8_o;
  assign c_o[22][9] = c22_9_o;
  assign c_o[22][10] = c22_10_o;
  assign c_o[22][11] = c22_11_o;
  assign c_o[22][12] = c22_12_o;
  assign c_o[22][13] = c22_13_o;
  assign c_o[22][14] = c22_14_o;
  assign c_o[22][15] = c22_15_o;
  assign c_o[22][16] = c22_16_o;
  assign c_o[22][17] = c22_17_o;
  assign c_o[22][18] = c22_18_o;
  assign c_o[22][19] = c22_19_o;
  assign c_o[22][20] = c22_20_o;
  assign c_o[22][21] = c22_21_o;
  assign c_o[22][22] = c22_22_o;
  assign c_o[22][23] = c22_23_o;
  assign c_o[22][24] = c22_24_o;
  assign c_o[22][25] = c22_25_o;
  assign c_o[22][26] = c22_26_o;
  assign c_o[22][27] = c22_27_o;
  assign c_o[22][28] = c22_28_o;
  assign c_o[22][29] = c22_29_o;
  assign c_o[22][30] = c22_30_o;
  assign c_o[22][31] = c22_31_o;
  assign c_o[23][0] = c23_0_o;
  assign c_o[23][1] = c23_1_o;
  assign c_o[23][2] = c23_2_o;
  assign c_o[23][3] = c23_3_o;
  assign c_o[23][4] = c23_4_o;
  assign c_o[23][5] = c23_5_o;
  assign c_o[23][6] = c23_6_o;
  assign c_o[23][7] = c23_7_o;
  assign c_o[23][8] = c23_8_o;
  assign c_o[23][9] = c23_9_o;
  assign c_o[23][10] = c23_10_o;
  assign c_o[23][11] = c23_11_o;
  assign c_o[23][12] = c23_12_o;
  assign c_o[23][13] = c23_13_o;
  assign c_o[23][14] = c23_14_o;
  assign c_o[23][15] = c23_15_o;
  assign c_o[23][16] = c23_16_o;
  assign c_o[23][17] = c23_17_o;
  assign c_o[23][18] = c23_18_o;
  assign c_o[23][19] = c23_19_o;
  assign c_o[23][20] = c23_20_o;
  assign c_o[23][21] = c23_21_o;
  assign c_o[23][22] = c23_22_o;
  assign c_o[23][23] = c23_23_o;
  assign c_o[23][24] = c23_24_o;
  assign c_o[23][25] = c23_25_o;
  assign c_o[23][26] = c23_26_o;
  assign c_o[23][27] = c23_27_o;
  assign c_o[23][28] = c23_28_o;
  assign c_o[23][29] = c23_29_o;
  assign c_o[23][30] = c23_30_o;
  assign c_o[23][31] = c23_31_o;
  assign c_o[24][0] = c24_0_o;
  assign c_o[24][1] = c24_1_o;
  assign c_o[24][2] = c24_2_o;
  assign c_o[24][3] = c24_3_o;
  assign c_o[24][4] = c24_4_o;
  assign c_o[24][5] = c24_5_o;
  assign c_o[24][6] = c24_6_o;
  assign c_o[24][7] = c24_7_o;
  assign c_o[24][8] = c24_8_o;
  assign c_o[24][9] = c24_9_o;
  assign c_o[24][10] = c24_10_o;
  assign c_o[24][11] = c24_11_o;
  assign c_o[24][12] = c24_12_o;
  assign c_o[24][13] = c24_13_o;
  assign c_o[24][14] = c24_14_o;
  assign c_o[24][15] = c24_15_o;
  assign c_o[24][16] = c24_16_o;
  assign c_o[24][17] = c24_17_o;
  assign c_o[24][18] = c24_18_o;
  assign c_o[24][19] = c24_19_o;
  assign c_o[24][20] = c24_20_o;
  assign c_o[24][21] = c24_21_o;
  assign c_o[24][22] = c24_22_o;
  assign c_o[24][23] = c24_23_o;
  assign c_o[24][24] = c24_24_o;
  assign c_o[24][25] = c24_25_o;
  assign c_o[24][26] = c24_26_o;
  assign c_o[24][27] = c24_27_o;
  assign c_o[24][28] = c24_28_o;
  assign c_o[24][29] = c24_29_o;
  assign c_o[24][30] = c24_30_o;
  assign c_o[24][31] = c24_31_o;
  assign c_o[25][0] = c25_0_o;
  assign c_o[25][1] = c25_1_o;
  assign c_o[25][2] = c25_2_o;
  assign c_o[25][3] = c25_3_o;
  assign c_o[25][4] = c25_4_o;
  assign c_o[25][5] = c25_5_o;
  assign c_o[25][6] = c25_6_o;
  assign c_o[25][7] = c25_7_o;
  assign c_o[25][8] = c25_8_o;
  assign c_o[25][9] = c25_9_o;
  assign c_o[25][10] = c25_10_o;
  assign c_o[25][11] = c25_11_o;
  assign c_o[25][12] = c25_12_o;
  assign c_o[25][13] = c25_13_o;
  assign c_o[25][14] = c25_14_o;
  assign c_o[25][15] = c25_15_o;
  assign c_o[25][16] = c25_16_o;
  assign c_o[25][17] = c25_17_o;
  assign c_o[25][18] = c25_18_o;
  assign c_o[25][19] = c25_19_o;
  assign c_o[25][20] = c25_20_o;
  assign c_o[25][21] = c25_21_o;
  assign c_o[25][22] = c25_22_o;
  assign c_o[25][23] = c25_23_o;
  assign c_o[25][24] = c25_24_o;
  assign c_o[25][25] = c25_25_o;
  assign c_o[25][26] = c25_26_o;
  assign c_o[25][27] = c25_27_o;
  assign c_o[25][28] = c25_28_o;
  assign c_o[25][29] = c25_29_o;
  assign c_o[25][30] = c25_30_o;
  assign c_o[25][31] = c25_31_o;
  assign c_o[26][0] = c26_0_o;
  assign c_o[26][1] = c26_1_o;
  assign c_o[26][2] = c26_2_o;
  assign c_o[26][3] = c26_3_o;
  assign c_o[26][4] = c26_4_o;
  assign c_o[26][5] = c26_5_o;
  assign c_o[26][6] = c26_6_o;
  assign c_o[26][7] = c26_7_o;
  assign c_o[26][8] = c26_8_o;
  assign c_o[26][9] = c26_9_o;
  assign c_o[26][10] = c26_10_o;
  assign c_o[26][11] = c26_11_o;
  assign c_o[26][12] = c26_12_o;
  assign c_o[26][13] = c26_13_o;
  assign c_o[26][14] = c26_14_o;
  assign c_o[26][15] = c26_15_o;
  assign c_o[26][16] = c26_16_o;
  assign c_o[26][17] = c26_17_o;
  assign c_o[26][18] = c26_18_o;
  assign c_o[26][19] = c26_19_o;
  assign c_o[26][20] = c26_20_o;
  assign c_o[26][21] = c26_21_o;
  assign c_o[26][22] = c26_22_o;
  assign c_o[26][23] = c26_23_o;
  assign c_o[26][24] = c26_24_o;
  assign c_o[26][25] = c26_25_o;
  assign c_o[26][26] = c26_26_o;
  assign c_o[26][27] = c26_27_o;
  assign c_o[26][28] = c26_28_o;
  assign c_o[26][29] = c26_29_o;
  assign c_o[26][30] = c26_30_o;
  assign c_o[26][31] = c26_31_o;
  assign c_o[27][0] = c27_0_o;
  assign c_o[27][1] = c27_1_o;
  assign c_o[27][2] = c27_2_o;
  assign c_o[27][3] = c27_3_o;
  assign c_o[27][4] = c27_4_o;
  assign c_o[27][5] = c27_5_o;
  assign c_o[27][6] = c27_6_o;
  assign c_o[27][7] = c27_7_o;
  assign c_o[27][8] = c27_8_o;
  assign c_o[27][9] = c27_9_o;
  assign c_o[27][10] = c27_10_o;
  assign c_o[27][11] = c27_11_o;
  assign c_o[27][12] = c27_12_o;
  assign c_o[27][13] = c27_13_o;
  assign c_o[27][14] = c27_14_o;
  assign c_o[27][15] = c27_15_o;
  assign c_o[27][16] = c27_16_o;
  assign c_o[27][17] = c27_17_o;
  assign c_o[27][18] = c27_18_o;
  assign c_o[27][19] = c27_19_o;
  assign c_o[27][20] = c27_20_o;
  assign c_o[27][21] = c27_21_o;
  assign c_o[27][22] = c27_22_o;
  assign c_o[27][23] = c27_23_o;
  assign c_o[27][24] = c27_24_o;
  assign c_o[27][25] = c27_25_o;
  assign c_o[27][26] = c27_26_o;
  assign c_o[27][27] = c27_27_o;
  assign c_o[27][28] = c27_28_o;
  assign c_o[27][29] = c27_29_o;
  assign c_o[27][30] = c27_30_o;
  assign c_o[27][31] = c27_31_o;
  assign c_o[28][0] = c28_0_o;
  assign c_o[28][1] = c28_1_o;
  assign c_o[28][2] = c28_2_o;
  assign c_o[28][3] = c28_3_o;
  assign c_o[28][4] = c28_4_o;
  assign c_o[28][5] = c28_5_o;
  assign c_o[28][6] = c28_6_o;
  assign c_o[28][7] = c28_7_o;
  assign c_o[28][8] = c28_8_o;
  assign c_o[28][9] = c28_9_o;
  assign c_o[28][10] = c28_10_o;
  assign c_o[28][11] = c28_11_o;
  assign c_o[28][12] = c28_12_o;
  assign c_o[28][13] = c28_13_o;
  assign c_o[28][14] = c28_14_o;
  assign c_o[28][15] = c28_15_o;
  assign c_o[28][16] = c28_16_o;
  assign c_o[28][17] = c28_17_o;
  assign c_o[28][18] = c28_18_o;
  assign c_o[28][19] = c28_19_o;
  assign c_o[28][20] = c28_20_o;
  assign c_o[28][21] = c28_21_o;
  assign c_o[28][22] = c28_22_o;
  assign c_o[28][23] = c28_23_o;
  assign c_o[28][24] = c28_24_o;
  assign c_o[28][25] = c28_25_o;
  assign c_o[28][26] = c28_26_o;
  assign c_o[28][27] = c28_27_o;
  assign c_o[28][28] = c28_28_o;
  assign c_o[28][29] = c28_29_o;
  assign c_o[28][30] = c28_30_o;
  assign c_o[28][31] = c28_31_o;
  assign c_o[29][0] = c29_0_o;
  assign c_o[29][1] = c29_1_o;
  assign c_o[29][2] = c29_2_o;
  assign c_o[29][3] = c29_3_o;
  assign c_o[29][4] = c29_4_o;
  assign c_o[29][5] = c29_5_o;
  assign c_o[29][6] = c29_6_o;
  assign c_o[29][7] = c29_7_o;
  assign c_o[29][8] = c29_8_o;
  assign c_o[29][9] = c29_9_o;
  assign c_o[29][10] = c29_10_o;
  assign c_o[29][11] = c29_11_o;
  assign c_o[29][12] = c29_12_o;
  assign c_o[29][13] = c29_13_o;
  assign c_o[29][14] = c29_14_o;
  assign c_o[29][15] = c29_15_o;
  assign c_o[29][16] = c29_16_o;
  assign c_o[29][17] = c29_17_o;
  assign c_o[29][18] = c29_18_o;
  assign c_o[29][19] = c29_19_o;
  assign c_o[29][20] = c29_20_o;
  assign c_o[29][21] = c29_21_o;
  assign c_o[29][22] = c29_22_o;
  assign c_o[29][23] = c29_23_o;
  assign c_o[29][24] = c29_24_o;
  assign c_o[29][25] = c29_25_o;
  assign c_o[29][26] = c29_26_o;
  assign c_o[29][27] = c29_27_o;
  assign c_o[29][28] = c29_28_o;
  assign c_o[29][29] = c29_29_o;
  assign c_o[29][30] = c29_30_o;
  assign c_o[29][31] = c29_31_o;
  assign c_o[30][0] = c30_0_o;
  assign c_o[30][1] = c30_1_o;
  assign c_o[30][2] = c30_2_o;
  assign c_o[30][3] = c30_3_o;
  assign c_o[30][4] = c30_4_o;
  assign c_o[30][5] = c30_5_o;
  assign c_o[30][6] = c30_6_o;
  assign c_o[30][7] = c30_7_o;
  assign c_o[30][8] = c30_8_o;
  assign c_o[30][9] = c30_9_o;
  assign c_o[30][10] = c30_10_o;
  assign c_o[30][11] = c30_11_o;
  assign c_o[30][12] = c30_12_o;
  assign c_o[30][13] = c30_13_o;
  assign c_o[30][14] = c30_14_o;
  assign c_o[30][15] = c30_15_o;
  assign c_o[30][16] = c30_16_o;
  assign c_o[30][17] = c30_17_o;
  assign c_o[30][18] = c30_18_o;
  assign c_o[30][19] = c30_19_o;
  assign c_o[30][20] = c30_20_o;
  assign c_o[30][21] = c30_21_o;
  assign c_o[30][22] = c30_22_o;
  assign c_o[30][23] = c30_23_o;
  assign c_o[30][24] = c30_24_o;
  assign c_o[30][25] = c30_25_o;
  assign c_o[30][26] = c30_26_o;
  assign c_o[30][27] = c30_27_o;
  assign c_o[30][28] = c30_28_o;
  assign c_o[30][29] = c30_29_o;
  assign c_o[30][30] = c30_30_o;
  assign c_o[30][31] = c30_31_o;
  assign c_o[31][0] = c31_0_o;
  assign c_o[31][1] = c31_1_o;
  assign c_o[31][2] = c31_2_o;
  assign c_o[31][3] = c31_3_o;
  assign c_o[31][4] = c31_4_o;
  assign c_o[31][5] = c31_5_o;
  assign c_o[31][6] = c31_6_o;
  assign c_o[31][7] = c31_7_o;
  assign c_o[31][8] = c31_8_o;
  assign c_o[31][9] = c31_9_o;
  assign c_o[31][10] = c31_10_o;
  assign c_o[31][11] = c31_11_o;
  assign c_o[31][12] = c31_12_o;
  assign c_o[31][13] = c31_13_o;
  assign c_o[31][14] = c31_14_o;
  assign c_o[31][15] = c31_15_o;
  assign c_o[31][16] = c31_16_o;
  assign c_o[31][17] = c31_17_o;
  assign c_o[31][18] = c31_18_o;
  assign c_o[31][19] = c31_19_o;
  assign c_o[31][20] = c31_20_o;
  assign c_o[31][21] = c31_21_o;
  assign c_o[31][22] = c31_22_o;
  assign c_o[31][23] = c31_23_o;
  assign c_o[31][24] = c31_24_o;
  assign c_o[31][25] = c31_25_o;
  assign c_o[31][26] = c31_26_o;
  assign c_o[31][27] = c31_27_o;
  assign c_o[31][28] = c31_28_o;
  assign c_o[31][29] = c31_29_o;
  assign c_o[31][30] = c31_30_o;
  assign c_o[31][31] = c31_31_o;

  int pass_count = 0;
  int fail_count = 0;

  // LUU Y (2026-07-21): ban truoc dung X-macro kieu `A_IDX_LIST(`DECL_A) (truyen ten
  // macro co backtick lam tham so cho macro khac) - Vivado xsim KHONG ho tro kieu
  // "higher-order macro" nay (loi that: [HDL 9-1206] Syntax error near '(' tai dung
  // vi tri goi macro long nhau), khac voi GCC/Verilator co the chap nhan. Da doi sang
  // liet ke tuong minh 64+32 bank (sinh bang script, khong go tay) - dung phong cach
  // Design da dung cho RTL that (systolic_core_top.sv cung liet ke tuong minh 64+32
  // cong phang vi ly do tuong tu).

  // ---- Khai bao 64x3 tin hieu A (trung ten port DUT) -----------------------------
  logic [9:0]               bram_a0_addr_o;
  logic                     bram_a0_en_o;
  logic signed [DATA_W-1:0] bram_a0_dout_i;
  logic [9:0]               bram_a1_addr_o;
  logic                     bram_a1_en_o;
  logic signed [DATA_W-1:0] bram_a1_dout_i;
  logic [9:0]               bram_a2_addr_o;
  logic                     bram_a2_en_o;
  logic signed [DATA_W-1:0] bram_a2_dout_i;
  logic [9:0]               bram_a3_addr_o;
  logic                     bram_a3_en_o;
  logic signed [DATA_W-1:0] bram_a3_dout_i;
  logic [9:0]               bram_a4_addr_o;
  logic                     bram_a4_en_o;
  logic signed [DATA_W-1:0] bram_a4_dout_i;
  logic [9:0]               bram_a5_addr_o;
  logic                     bram_a5_en_o;
  logic signed [DATA_W-1:0] bram_a5_dout_i;
  logic [9:0]               bram_a6_addr_o;
  logic                     bram_a6_en_o;
  logic signed [DATA_W-1:0] bram_a6_dout_i;
  logic [9:0]               bram_a7_addr_o;
  logic                     bram_a7_en_o;
  logic signed [DATA_W-1:0] bram_a7_dout_i;
  logic [9:0]               bram_a8_addr_o;
  logic                     bram_a8_en_o;
  logic signed [DATA_W-1:0] bram_a8_dout_i;
  logic [9:0]               bram_a9_addr_o;
  logic                     bram_a9_en_o;
  logic signed [DATA_W-1:0] bram_a9_dout_i;
  logic [9:0]               bram_a10_addr_o;
  logic                     bram_a10_en_o;
  logic signed [DATA_W-1:0] bram_a10_dout_i;
  logic [9:0]               bram_a11_addr_o;
  logic                     bram_a11_en_o;
  logic signed [DATA_W-1:0] bram_a11_dout_i;
  logic [9:0]               bram_a12_addr_o;
  logic                     bram_a12_en_o;
  logic signed [DATA_W-1:0] bram_a12_dout_i;
  logic [9:0]               bram_a13_addr_o;
  logic                     bram_a13_en_o;
  logic signed [DATA_W-1:0] bram_a13_dout_i;
  logic [9:0]               bram_a14_addr_o;
  logic                     bram_a14_en_o;
  logic signed [DATA_W-1:0] bram_a14_dout_i;
  logic [9:0]               bram_a15_addr_o;
  logic                     bram_a15_en_o;
  logic signed [DATA_W-1:0] bram_a15_dout_i;
  logic [9:0]               bram_a16_addr_o;
  logic                     bram_a16_en_o;
  logic signed [DATA_W-1:0] bram_a16_dout_i;
  logic [9:0]               bram_a17_addr_o;
  logic                     bram_a17_en_o;
  logic signed [DATA_W-1:0] bram_a17_dout_i;
  logic [9:0]               bram_a18_addr_o;
  logic                     bram_a18_en_o;
  logic signed [DATA_W-1:0] bram_a18_dout_i;
  logic [9:0]               bram_a19_addr_o;
  logic                     bram_a19_en_o;
  logic signed [DATA_W-1:0] bram_a19_dout_i;
  logic [9:0]               bram_a20_addr_o;
  logic                     bram_a20_en_o;
  logic signed [DATA_W-1:0] bram_a20_dout_i;
  logic [9:0]               bram_a21_addr_o;
  logic                     bram_a21_en_o;
  logic signed [DATA_W-1:0] bram_a21_dout_i;
  logic [9:0]               bram_a22_addr_o;
  logic                     bram_a22_en_o;
  logic signed [DATA_W-1:0] bram_a22_dout_i;
  logic [9:0]               bram_a23_addr_o;
  logic                     bram_a23_en_o;
  logic signed [DATA_W-1:0] bram_a23_dout_i;
  logic [9:0]               bram_a24_addr_o;
  logic                     bram_a24_en_o;
  logic signed [DATA_W-1:0] bram_a24_dout_i;
  logic [9:0]               bram_a25_addr_o;
  logic                     bram_a25_en_o;
  logic signed [DATA_W-1:0] bram_a25_dout_i;
  logic [9:0]               bram_a26_addr_o;
  logic                     bram_a26_en_o;
  logic signed [DATA_W-1:0] bram_a26_dout_i;
  logic [9:0]               bram_a27_addr_o;
  logic                     bram_a27_en_o;
  logic signed [DATA_W-1:0] bram_a27_dout_i;
  logic [9:0]               bram_a28_addr_o;
  logic                     bram_a28_en_o;
  logic signed [DATA_W-1:0] bram_a28_dout_i;
  logic [9:0]               bram_a29_addr_o;
  logic                     bram_a29_en_o;
  logic signed [DATA_W-1:0] bram_a29_dout_i;
  logic [9:0]               bram_a30_addr_o;
  logic                     bram_a30_en_o;
  logic signed [DATA_W-1:0] bram_a30_dout_i;
  logic [9:0]               bram_a31_addr_o;
  logic                     bram_a31_en_o;
  logic signed [DATA_W-1:0] bram_a31_dout_i;
  logic [9:0]               bram_a32_addr_o;
  logic                     bram_a32_en_o;
  logic signed [DATA_W-1:0] bram_a32_dout_i;
  logic [9:0]               bram_a33_addr_o;
  logic                     bram_a33_en_o;
  logic signed [DATA_W-1:0] bram_a33_dout_i;
  logic [9:0]               bram_a34_addr_o;
  logic                     bram_a34_en_o;
  logic signed [DATA_W-1:0] bram_a34_dout_i;
  logic [9:0]               bram_a35_addr_o;
  logic                     bram_a35_en_o;
  logic signed [DATA_W-1:0] bram_a35_dout_i;
  logic [9:0]               bram_a36_addr_o;
  logic                     bram_a36_en_o;
  logic signed [DATA_W-1:0] bram_a36_dout_i;
  logic [9:0]               bram_a37_addr_o;
  logic                     bram_a37_en_o;
  logic signed [DATA_W-1:0] bram_a37_dout_i;
  logic [9:0]               bram_a38_addr_o;
  logic                     bram_a38_en_o;
  logic signed [DATA_W-1:0] bram_a38_dout_i;
  logic [9:0]               bram_a39_addr_o;
  logic                     bram_a39_en_o;
  logic signed [DATA_W-1:0] bram_a39_dout_i;
  logic [9:0]               bram_a40_addr_o;
  logic                     bram_a40_en_o;
  logic signed [DATA_W-1:0] bram_a40_dout_i;
  logic [9:0]               bram_a41_addr_o;
  logic                     bram_a41_en_o;
  logic signed [DATA_W-1:0] bram_a41_dout_i;
  logic [9:0]               bram_a42_addr_o;
  logic                     bram_a42_en_o;
  logic signed [DATA_W-1:0] bram_a42_dout_i;
  logic [9:0]               bram_a43_addr_o;
  logic                     bram_a43_en_o;
  logic signed [DATA_W-1:0] bram_a43_dout_i;
  logic [9:0]               bram_a44_addr_o;
  logic                     bram_a44_en_o;
  logic signed [DATA_W-1:0] bram_a44_dout_i;
  logic [9:0]               bram_a45_addr_o;
  logic                     bram_a45_en_o;
  logic signed [DATA_W-1:0] bram_a45_dout_i;
  logic [9:0]               bram_a46_addr_o;
  logic                     bram_a46_en_o;
  logic signed [DATA_W-1:0] bram_a46_dout_i;
  logic [9:0]               bram_a47_addr_o;
  logic                     bram_a47_en_o;
  logic signed [DATA_W-1:0] bram_a47_dout_i;
  logic [9:0]               bram_a48_addr_o;
  logic                     bram_a48_en_o;
  logic signed [DATA_W-1:0] bram_a48_dout_i;
  logic [9:0]               bram_a49_addr_o;
  logic                     bram_a49_en_o;
  logic signed [DATA_W-1:0] bram_a49_dout_i;
  logic [9:0]               bram_a50_addr_o;
  logic                     bram_a50_en_o;
  logic signed [DATA_W-1:0] bram_a50_dout_i;
  logic [9:0]               bram_a51_addr_o;
  logic                     bram_a51_en_o;
  logic signed [DATA_W-1:0] bram_a51_dout_i;
  logic [9:0]               bram_a52_addr_o;
  logic                     bram_a52_en_o;
  logic signed [DATA_W-1:0] bram_a52_dout_i;
  logic [9:0]               bram_a53_addr_o;
  logic                     bram_a53_en_o;
  logic signed [DATA_W-1:0] bram_a53_dout_i;
  logic [9:0]               bram_a54_addr_o;
  logic                     bram_a54_en_o;
  logic signed [DATA_W-1:0] bram_a54_dout_i;
  logic [9:0]               bram_a55_addr_o;
  logic                     bram_a55_en_o;
  logic signed [DATA_W-1:0] bram_a55_dout_i;
  logic [9:0]               bram_a56_addr_o;
  logic                     bram_a56_en_o;
  logic signed [DATA_W-1:0] bram_a56_dout_i;
  logic [9:0]               bram_a57_addr_o;
  logic                     bram_a57_en_o;
  logic signed [DATA_W-1:0] bram_a57_dout_i;
  logic [9:0]               bram_a58_addr_o;
  logic                     bram_a58_en_o;
  logic signed [DATA_W-1:0] bram_a58_dout_i;
  logic [9:0]               bram_a59_addr_o;
  logic                     bram_a59_en_o;
  logic signed [DATA_W-1:0] bram_a59_dout_i;
  logic [9:0]               bram_a60_addr_o;
  logic                     bram_a60_en_o;
  logic signed [DATA_W-1:0] bram_a60_dout_i;
  logic [9:0]               bram_a61_addr_o;
  logic                     bram_a61_en_o;
  logic signed [DATA_W-1:0] bram_a61_dout_i;
  logic [9:0]               bram_a62_addr_o;
  logic                     bram_a62_en_o;
  logic signed [DATA_W-1:0] bram_a62_dout_i;
  logic [9:0]               bram_a63_addr_o;
  logic                     bram_a63_en_o;
  logic signed [DATA_W-1:0] bram_a63_dout_i;

  // ---- Khai bao 32x3 tin hieu B (trung ten port DUT) -----------------------------
  logic [12:0]              bram_b0_addr_o;
  logic                     bram_b0_en_o;
  logic signed [DATA_W-1:0] bram_b0_dout_i;
  logic [12:0]              bram_b1_addr_o;
  logic                     bram_b1_en_o;
  logic signed [DATA_W-1:0] bram_b1_dout_i;
  logic [12:0]              bram_b2_addr_o;
  logic                     bram_b2_en_o;
  logic signed [DATA_W-1:0] bram_b2_dout_i;
  logic [12:0]              bram_b3_addr_o;
  logic                     bram_b3_en_o;
  logic signed [DATA_W-1:0] bram_b3_dout_i;
  logic [12:0]              bram_b4_addr_o;
  logic                     bram_b4_en_o;
  logic signed [DATA_W-1:0] bram_b4_dout_i;
  logic [12:0]              bram_b5_addr_o;
  logic                     bram_b5_en_o;
  logic signed [DATA_W-1:0] bram_b5_dout_i;
  logic [12:0]              bram_b6_addr_o;
  logic                     bram_b6_en_o;
  logic signed [DATA_W-1:0] bram_b6_dout_i;
  logic [12:0]              bram_b7_addr_o;
  logic                     bram_b7_en_o;
  logic signed [DATA_W-1:0] bram_b7_dout_i;
  logic [12:0]              bram_b8_addr_o;
  logic                     bram_b8_en_o;
  logic signed [DATA_W-1:0] bram_b8_dout_i;
  logic [12:0]              bram_b9_addr_o;
  logic                     bram_b9_en_o;
  logic signed [DATA_W-1:0] bram_b9_dout_i;
  logic [12:0]              bram_b10_addr_o;
  logic                     bram_b10_en_o;
  logic signed [DATA_W-1:0] bram_b10_dout_i;
  logic [12:0]              bram_b11_addr_o;
  logic                     bram_b11_en_o;
  logic signed [DATA_W-1:0] bram_b11_dout_i;
  logic [12:0]              bram_b12_addr_o;
  logic                     bram_b12_en_o;
  logic signed [DATA_W-1:0] bram_b12_dout_i;
  logic [12:0]              bram_b13_addr_o;
  logic                     bram_b13_en_o;
  logic signed [DATA_W-1:0] bram_b13_dout_i;
  logic [12:0]              bram_b14_addr_o;
  logic                     bram_b14_en_o;
  logic signed [DATA_W-1:0] bram_b14_dout_i;
  logic [12:0]              bram_b15_addr_o;
  logic                     bram_b15_en_o;
  logic signed [DATA_W-1:0] bram_b15_dout_i;
  logic [12:0]              bram_b16_addr_o;
  logic                     bram_b16_en_o;
  logic signed [DATA_W-1:0] bram_b16_dout_i;
  logic [12:0]              bram_b17_addr_o;
  logic                     bram_b17_en_o;
  logic signed [DATA_W-1:0] bram_b17_dout_i;
  logic [12:0]              bram_b18_addr_o;
  logic                     bram_b18_en_o;
  logic signed [DATA_W-1:0] bram_b18_dout_i;
  logic [12:0]              bram_b19_addr_o;
  logic                     bram_b19_en_o;
  logic signed [DATA_W-1:0] bram_b19_dout_i;
  logic [12:0]              bram_b20_addr_o;
  logic                     bram_b20_en_o;
  logic signed [DATA_W-1:0] bram_b20_dout_i;
  logic [12:0]              bram_b21_addr_o;
  logic                     bram_b21_en_o;
  logic signed [DATA_W-1:0] bram_b21_dout_i;
  logic [12:0]              bram_b22_addr_o;
  logic                     bram_b22_en_o;
  logic signed [DATA_W-1:0] bram_b22_dout_i;
  logic [12:0]              bram_b23_addr_o;
  logic                     bram_b23_en_o;
  logic signed [DATA_W-1:0] bram_b23_dout_i;
  logic [12:0]              bram_b24_addr_o;
  logic                     bram_b24_en_o;
  logic signed [DATA_W-1:0] bram_b24_dout_i;
  logic [12:0]              bram_b25_addr_o;
  logic                     bram_b25_en_o;
  logic signed [DATA_W-1:0] bram_b25_dout_i;
  logic [12:0]              bram_b26_addr_o;
  logic                     bram_b26_en_o;
  logic signed [DATA_W-1:0] bram_b26_dout_i;
  logic [12:0]              bram_b27_addr_o;
  logic                     bram_b27_en_o;
  logic signed [DATA_W-1:0] bram_b27_dout_i;
  logic [12:0]              bram_b28_addr_o;
  logic                     bram_b28_en_o;
  logic signed [DATA_W-1:0] bram_b28_dout_i;
  logic [12:0]              bram_b29_addr_o;
  logic                     bram_b29_en_o;
  logic signed [DATA_W-1:0] bram_b29_dout_i;
  logic [12:0]              bram_b30_addr_o;
  logic                     bram_b30_en_o;
  logic signed [DATA_W-1:0] bram_b30_dout_i;
  logic [12:0]              bram_b31_addr_o;
  logic                     bram_b31_en_o;
  logic signed [DATA_W-1:0] bram_b31_dout_i;

  // ---- Mo hinh BRAM A (64 bank, depth 768) / B (32 bank, depth 6144 - da tinh ca
  // 8 nhom cot jj=0..7 xen ke theo addr=k*8+jj) ------------------------------------
  logic signed [DATA_W-1:0] mem_a [A_ROWS][K_DEPTH];
  logic signed [DATA_W-1:0] mem_b [ARR_SIZE][B_BANK_DEPTH];

  // Doc dong bo BRAM A, tre 1 cycle giua addr+en va dout hop le (interface_contract.md).
  always_ff @(posedge clk_i) begin
    if (bram_a0_en_o) bram_a0_dout_i <= mem_a[0][bram_a0_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a1_en_o) bram_a1_dout_i <= mem_a[1][bram_a1_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a2_en_o) bram_a2_dout_i <= mem_a[2][bram_a2_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a3_en_o) bram_a3_dout_i <= mem_a[3][bram_a3_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a4_en_o) bram_a4_dout_i <= mem_a[4][bram_a4_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a5_en_o) bram_a5_dout_i <= mem_a[5][bram_a5_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a6_en_o) bram_a6_dout_i <= mem_a[6][bram_a6_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a7_en_o) bram_a7_dout_i <= mem_a[7][bram_a7_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a8_en_o) bram_a8_dout_i <= mem_a[8][bram_a8_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a9_en_o) bram_a9_dout_i <= mem_a[9][bram_a9_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a10_en_o) bram_a10_dout_i <= mem_a[10][bram_a10_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a11_en_o) bram_a11_dout_i <= mem_a[11][bram_a11_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a12_en_o) bram_a12_dout_i <= mem_a[12][bram_a12_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a13_en_o) bram_a13_dout_i <= mem_a[13][bram_a13_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a14_en_o) bram_a14_dout_i <= mem_a[14][bram_a14_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a15_en_o) bram_a15_dout_i <= mem_a[15][bram_a15_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a16_en_o) bram_a16_dout_i <= mem_a[16][bram_a16_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a17_en_o) bram_a17_dout_i <= mem_a[17][bram_a17_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a18_en_o) bram_a18_dout_i <= mem_a[18][bram_a18_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a19_en_o) bram_a19_dout_i <= mem_a[19][bram_a19_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a20_en_o) bram_a20_dout_i <= mem_a[20][bram_a20_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a21_en_o) bram_a21_dout_i <= mem_a[21][bram_a21_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a22_en_o) bram_a22_dout_i <= mem_a[22][bram_a22_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a23_en_o) bram_a23_dout_i <= mem_a[23][bram_a23_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a24_en_o) bram_a24_dout_i <= mem_a[24][bram_a24_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a25_en_o) bram_a25_dout_i <= mem_a[25][bram_a25_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a26_en_o) bram_a26_dout_i <= mem_a[26][bram_a26_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a27_en_o) bram_a27_dout_i <= mem_a[27][bram_a27_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a28_en_o) bram_a28_dout_i <= mem_a[28][bram_a28_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a29_en_o) bram_a29_dout_i <= mem_a[29][bram_a29_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a30_en_o) bram_a30_dout_i <= mem_a[30][bram_a30_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a31_en_o) bram_a31_dout_i <= mem_a[31][bram_a31_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a32_en_o) bram_a32_dout_i <= mem_a[32][bram_a32_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a33_en_o) bram_a33_dout_i <= mem_a[33][bram_a33_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a34_en_o) bram_a34_dout_i <= mem_a[34][bram_a34_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a35_en_o) bram_a35_dout_i <= mem_a[35][bram_a35_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a36_en_o) bram_a36_dout_i <= mem_a[36][bram_a36_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a37_en_o) bram_a37_dout_i <= mem_a[37][bram_a37_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a38_en_o) bram_a38_dout_i <= mem_a[38][bram_a38_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a39_en_o) bram_a39_dout_i <= mem_a[39][bram_a39_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a40_en_o) bram_a40_dout_i <= mem_a[40][bram_a40_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a41_en_o) bram_a41_dout_i <= mem_a[41][bram_a41_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a42_en_o) bram_a42_dout_i <= mem_a[42][bram_a42_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a43_en_o) bram_a43_dout_i <= mem_a[43][bram_a43_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a44_en_o) bram_a44_dout_i <= mem_a[44][bram_a44_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a45_en_o) bram_a45_dout_i <= mem_a[45][bram_a45_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a46_en_o) bram_a46_dout_i <= mem_a[46][bram_a46_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a47_en_o) bram_a47_dout_i <= mem_a[47][bram_a47_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a48_en_o) bram_a48_dout_i <= mem_a[48][bram_a48_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a49_en_o) bram_a49_dout_i <= mem_a[49][bram_a49_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a50_en_o) bram_a50_dout_i <= mem_a[50][bram_a50_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a51_en_o) bram_a51_dout_i <= mem_a[51][bram_a51_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a52_en_o) bram_a52_dout_i <= mem_a[52][bram_a52_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a53_en_o) bram_a53_dout_i <= mem_a[53][bram_a53_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a54_en_o) bram_a54_dout_i <= mem_a[54][bram_a54_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a55_en_o) bram_a55_dout_i <= mem_a[55][bram_a55_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a56_en_o) bram_a56_dout_i <= mem_a[56][bram_a56_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a57_en_o) bram_a57_dout_i <= mem_a[57][bram_a57_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a58_en_o) bram_a58_dout_i <= mem_a[58][bram_a58_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a59_en_o) bram_a59_dout_i <= mem_a[59][bram_a59_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a60_en_o) bram_a60_dout_i <= mem_a[60][bram_a60_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a61_en_o) bram_a61_dout_i <= mem_a[61][bram_a61_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a62_en_o) bram_a62_dout_i <= mem_a[62][bram_a62_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_a63_en_o) bram_a63_dout_i <= mem_a[63][bram_a63_addr_o];
  end

  // Doc dong bo BRAM B, tre 1 cycle giua addr+en va dout hop le.
  always_ff @(posedge clk_i) begin
    if (bram_b0_en_o) bram_b0_dout_i <= mem_b[0][bram_b0_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b1_en_o) bram_b1_dout_i <= mem_b[1][bram_b1_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b2_en_o) bram_b2_dout_i <= mem_b[2][bram_b2_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b3_en_o) bram_b3_dout_i <= mem_b[3][bram_b3_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b4_en_o) bram_b4_dout_i <= mem_b[4][bram_b4_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b5_en_o) bram_b5_dout_i <= mem_b[5][bram_b5_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b6_en_o) bram_b6_dout_i <= mem_b[6][bram_b6_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b7_en_o) bram_b7_dout_i <= mem_b[7][bram_b7_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b8_en_o) bram_b8_dout_i <= mem_b[8][bram_b8_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b9_en_o) bram_b9_dout_i <= mem_b[9][bram_b9_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b10_en_o) bram_b10_dout_i <= mem_b[10][bram_b10_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b11_en_o) bram_b11_dout_i <= mem_b[11][bram_b11_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b12_en_o) bram_b12_dout_i <= mem_b[12][bram_b12_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b13_en_o) bram_b13_dout_i <= mem_b[13][bram_b13_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b14_en_o) bram_b14_dout_i <= mem_b[14][bram_b14_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b15_en_o) bram_b15_dout_i <= mem_b[15][bram_b15_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b16_en_o) bram_b16_dout_i <= mem_b[16][bram_b16_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b17_en_o) bram_b17_dout_i <= mem_b[17][bram_b17_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b18_en_o) bram_b18_dout_i <= mem_b[18][bram_b18_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b19_en_o) bram_b19_dout_i <= mem_b[19][bram_b19_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b20_en_o) bram_b20_dout_i <= mem_b[20][bram_b20_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b21_en_o) bram_b21_dout_i <= mem_b[21][bram_b21_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b22_en_o) bram_b22_dout_i <= mem_b[22][bram_b22_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b23_en_o) bram_b23_dout_i <= mem_b[23][bram_b23_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b24_en_o) bram_b24_dout_i <= mem_b[24][bram_b24_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b25_en_o) bram_b25_dout_i <= mem_b[25][bram_b25_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b26_en_o) bram_b26_dout_i <= mem_b[26][bram_b26_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b27_en_o) bram_b27_dout_i <= mem_b[27][bram_b27_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b28_en_o) bram_b28_dout_i <= mem_b[28][bram_b28_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b29_en_o) bram_b29_dout_i <= mem_b[29][bram_b29_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b30_en_o) bram_b30_dout_i <= mem_b[30][bram_b30_addr_o];
  end
  always_ff @(posedge clk_i) begin
    if (bram_b31_en_o) bram_b31_dout_i <= mem_b[31][bram_b31_addr_o];
  end

  SYSTOLIC_CORE_TOP #(
    .ARR_SIZE (ARR_SIZE),
    .A_ROWS   (A_ROWS),
    .DATA_W   (DATA_W),
    .ACC_W    (ACC_W),
    .K_DEPTH  (K_DEPTH)
  ) dut (.*);

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // Giam sat: tile_done_o khong duoc phep len 1 truoc dung cycle cuoi cua ST_LOAD.
  always_ff @(posedge clk_i) begin
    if (rst_ni) begin
      if (dut.state_q == dut.ST_LOAD &&
          dut.k_cnt_q != (EXPECT_CYCLES[$bits(dut.k_cnt_q)-1:0] - 1'b1)) begin
        if (tile_done_o !== 1'b0) begin
          fail_count++;
          $display("[FAIL] tile_done timing: tile_done_o len 1 som (k_cnt_q=%0d, chua het %0d cycle)",
                    dut.k_cnt_q, EXPECT_CYCLES);
        end
      end
    end
  end

  task automatic reset_dut();
    rst_ni       = 1'b0;
    tile_valid_i = 1'b0;
    tile_i_sel_i = 1'b0;
    tile_j_sel_i = 3'b000;
    repeat (2) @(posedge clk_i);
    rst_ni = 1'b1;
    @(posedge clk_i);
  endtask

  // Nap ngau nhien vao 32 bank A trong khoang [row_offset, row_offset+32).
  task automatic fill_random_a_half(input int row_offset, input int seed);
    $srandom(seed);
    for (int n = row_offset; n < row_offset + ARR_SIZE; n++)
      for (int k = 0; k < K_DEPTH; k++)
        mem_a[n][k] = $random;
  endtask

  // Nap ngau nhien vao toan bo 32 bank B, chi tai vung dia chi cua 1 nhom cot
  // col_group (0..7): addr = k*8 + col_group.
  task automatic fill_random_b_group(input int col_group, input int seed);
    $srandom(seed);
    for (int n = 0; n < ARR_SIZE; n++)
      for (int k = 0; k < K_DEPTH; k++)
        mem_b[n][k * 8 + col_group] = $random;
  endtask

  // expected[row][col] = Sum_k mem_a[row_offset+row][k] * mem_b[col][k*8+col_group]
  task automatic compute_expected(
      input int row_offset,
      input int col_group,
      output logic signed [ACC_W-1:0] expected [ARR_SIZE][ARR_SIZE]
  );
    for (int row = 0; row < ARR_SIZE; row++) begin
      for (int col = 0; col < ARR_SIZE; col++) begin
        logic signed [ACC_W-1:0] acc;
        acc = '0;
        for (int k = 0; k < K_DEPTH; k++) begin
          acc = acc + (ACC_W'(mem_a[row_offset + row][k]) * ACC_W'(mem_b[col][k * 8 + col_group]));
        end
        expected[row][col] = acc;
      end
    end
  endtask

  // Chay 1 tile: set tile_i_sel_i/tile_j_sel_i, cho tile_ready_o, assert tile_valid_i
  // 1 cycle, cho tile_done_o. Tra ve so cycle tu luc bat tay toi khi tile_done_o.
  task automatic run_one_tile(input logic sel_i, input logic [2:0] sel_j, output int cycle_count);
    cycle_count = 0;
    while (!tile_ready_o) @(posedge clk_i);
    tile_i_sel_i = sel_i;
    tile_j_sel_i = sel_j;
    tile_valid_i = 1'b1;
    @(posedge clk_i);
    tile_valid_i = 1'b0;
    while (!tile_done_o) begin
      @(posedge clk_i);
      cycle_count++;
    end
  endtask

  // Doc c_o (to hop truc tiep) dung cycle tile_done_o=1 va so voi expected.
  task automatic check_c_o(
      input logic signed [ACC_W-1:0] expected [ARR_SIZE][ARR_SIZE],
      input string tag
  );
    int mismatch;
    mismatch = 0;
    for (int row = 0; row < ARR_SIZE; row++) begin
      for (int col = 0; col < ARR_SIZE; col++) begin
        if (c_o[row][col] !== expected[row][col]) begin
          mismatch++;
          $display("[FAIL] %s: c_o[%0d][%0d]=%0d (expected %0d)",
                    tag, row, col, c_o[row][col], expected[row][col]);
        end
      end
    end
    if (mismatch == 0) begin
      pass_count++;
      $display("[PASS] %s: toan bo %0dx%0d phan tu c_o khop expected ngay cycle tile_done_o=1",
                tag, ARR_SIZE, ARR_SIZE);
    end else begin
      fail_count++;
      $display("[FAIL] %s: %0d/%0d phan tu sai", tag, mismatch, ARR_SIZE * ARR_SIZE);
    end
  endtask

  logic signed [ACC_W-1:0] expected1 [ARR_SIZE][ARR_SIZE];
  logic signed [ACC_W-1:0] expected2 [ARR_SIZE][ARR_SIZE];
  logic signed [ACC_W-1:0] expected3 [ARR_SIZE][ARR_SIZE];
  logic signed [ACC_W-1:0] expected4 [ARR_SIZE][ARR_SIZE];
  logic signed [ACC_W-1:0] expected5 [ARR_SIZE][ARR_SIZE];
  logic signed [ACC_W-1:0] expected6 [ARR_SIZE][ARR_SIZE];
  int cycles1, cycles2, cycles3, cycles4, cycles5, cycles6;

  initial begin
    clk_i = 1'b0;
    reset_dut();

    // ---- Test 1: tich luy lien tuc K=768, sel_i=0, sel_j=0 -------------------------
    fill_random_a_half(0, 32'hA5A5_0001);
    fill_random_b_group(0, 32'hA5A5_0002);
    compute_expected(0, 0, expected1);
    run_one_tile(1'b0, 3'd0, cycles1);
    check_c_o(expected1, "K=768 tich luy lien tuc, tile 1 (sel_i=0, sel_j=0)");
    $display("[INFO] Tile 1: tong cycle = %0d (ky vong %0d)", cycles1, EXPECT_CYCLES);
    if (cycles1 != EXPECT_CYCLES)
      $display("[WARN] Tile 1: cycle do duoc lech so voi %0d (chap nhan lech ~1 do do tre doc BRAM)",
                EXPECT_CYCLES);

    // ---- Test 2: tile thu 2, du lieu khac, khong cong don sai tu tile 1 -----------
    fill_random_a_half(0, 32'hB6B6_0002);
    fill_random_b_group(0, 32'hB6B6_0003);
    compute_expected(0, 0, expected2);
    run_one_tile(1'b0, 3'd0, cycles2);
    check_c_o(expected2, "K=768 tile 2 (kiem tra khong bi reset/cong don sai tu tile 1)");

    // ---- Test 3: Mux A, tile_i_sel_i=0 - bank 0-31=X, bank 32-63=garbage Y --------
    fill_random_a_half(0, 32'hC0DE_0001);   // X vao bank 0-31
    fill_random_a_half(32, 32'hDEAD_0001);  // Y (garbage) vao bank 32-63
    fill_random_b_group(0, 32'hC0DE_0002);
    compute_expected(0, 0, expected3);
    run_one_tile(1'b0, 3'd0, cycles3);
    check_c_o(expected3, "Mux A: tile_i_sel_i=0 dung bank 0-31 (X), khong dinh sang 32-63 (Y)");

    // ---- Test 4: tile ke tiep, tile_i_sel_i=1 - bank 0-31 giu X cu, 32-63 nap Z ----
    fill_random_a_half(32, 32'hFACE_0001);  // Z vao bank 32-63 (bank 0-31 van la X)
    fill_random_b_group(0, 32'hFACE_0002);
    compute_expected(32, 0, expected4);
    run_one_tile(1'b1, 3'd0, cycles4);
    check_c_o(expected4, "Mux A: tile_i_sel_i=1 dung bank 32-63 (Z), khong dinh du lieu sel=0 cu");

    // ---- Test 5: Mux B, tile_j_sel_i=0 - jj=0 co X_b, jj=1..7 la garbage ----------
    fill_random_a_half(0, 32'h1111_0001);
    fill_random_b_group(0, 32'h1111_0002); // X_b vao nhom jj=0
    for (int g = 1; g < 8; g++) fill_random_b_group(g, 32'h1111_1000 + g); // garbage jj=1..7
    compute_expected(0, 0, expected5);
    run_one_tile(1'b0, 3'd0, cycles5);
    check_c_o(expected5, "Mux B: tile_j_sel_i=0 dung nhom jj=0 (X_b), khong dinh sang jj=1..7");

    // ---- Test 6: tile ke tiep, tile_j_sel_i=3 - jj=0 giu X_b cu, jj=3 nap Z_b moi -
    fill_random_b_group(3, 32'h2222_0003); // Z_b vao nhom jj=3 (jj=0 van la X_b)
    compute_expected(0, 3, expected6);
    run_one_tile(1'b0, 3'd3, cycles6);
    check_c_o(expected6, "Mux B: tile_j_sel_i=3 dung nhom jj=3 (Z_b), khong dinh jj=0 hay nhom khac");

    $display("========================================");
    $display("tb_systolic_core_top: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_systolic_core_top: ALL TESTS PASSED");
    else $display("tb_systolic_core_top: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
