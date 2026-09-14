`timescale 1ns / 1ps

// Test module AXI4_C_WRITER (Huong B, lan 3 - xem 01_design/docs/task.md muc "SUA LAN 16",
// 01_design/docs/modules/axi4_c_writer.md). Module la AXI4 master CHI GHI (AW+W+B, khong
// AR/R), non-outstanding (1 giao dich tai 1 thoi diem: AW->W->B tuan tu, giong dung DUT).
// Doc c_data_i (bus gop 1024x32-bit, gan truc tiep gia tri test - khong can DUT nao khac)
// ngay luc tile_done_i pulse, ghi tung phan tu hop le (valid_rows x valid_cols) ra DDR.
//
// [SUA - 2026-08-23, xem 01_design/docs/modules/axi4_c_writer.md muc "SUA - 2026-08-23"]
// 2 thay doi doc lap tu ban DUT moi:
// 1. Toi uu hieu nang: DUT gio gop 1 HANG tile (toi da 32 phan tu lien tiep) thanh 1 burst AXI
//    dai (AWLEN=valid_cols-1, WLAST chi len o beat cuoi hang) thay vi 1 phan tu = 1 burst rieng
//    nhu truoc - BFM phai tu tang dia chi +4 moi beat trong cung 1 burst, chi chuyen sang B khi
//    thay WLAST=1.
// 2. Cong c_data_i (1 bus gop 32768-bit) da doi sang 1024 CONG SCALAR rieng c<row>_<col>_i (Vivado
//    IPI khong ho tro bit-select tren cong vector qua Tcl cho module-reference cell) - testbench
//    van giu bien c_data_i lam du lieu test PHIA SW (de set_c_elem/verify_tile dung nhu cu), roi
//    tach bit qua 1024 tin hieu rieng noi vao 1024 cong cua DUT (xem khoi "Bus gop -> 1024 cong
//    scalar" duoi day).
module tb_axi4_c_writer;

  localparam time CLK_PERIOD = 10ns;

  localparam int AWIDTH   = 32;
  localparam int ARR_SIZE = 32;
  localparam int CNT_W    = 16;

  logic clk_i;
  logic rst_ni;
  int   pass_count = 0;
  int   fail_count = 0;

  // ---- Dieu khien tu mmult_accel_0 (mo phong) ----
  logic [AWIDTH-1:0] c_base_addr_i;
  logic [AWIDTH-1:0] c_row_stride_i;
  logic [CNT_W-1:0]  c_global_i0_i;
  logic [CNT_W-1:0]  c_global_j0_i;
  logic [CNT_W-1:0]  c_valid_rows_i;
  logic [CNT_W-1:0]  c_valid_cols_i;
  logic              tile_valid_i;
  logic              tile_done_i;
  logic              c_write_done_o;

  // ---- Du lieu C (mo phong SYSTOLIC_CORE_TOP.c_o) - gan truc tiep, khong can DUT khac ----
  logic [ARR_SIZE*ARR_SIZE*32-1:0] c_data_i;

  // Bus gop -> 1024 cong scalar (khop dung ten port DUT c<row>_<col>_i).
  logic [31:0] c_scalar_i [0:31][0:31];
  generate
    genvar gr, gc;
    for (gr = 0; gr < ARR_SIZE; gr++) begin : gen_c_row
      for (gc = 0; gc < ARR_SIZE; gc++) begin : gen_c_col
        assign c_scalar_i[gr][gc] = c_data_i[(gr * ARR_SIZE + gc) * 32 +: 32];
      end
    end
  endgenerate

  // ---- AXI4 master chi-ghi cua DUT ----
  logic [AWIDTH-1:0] m_axi_awaddr_o;
  logic [7:0]        m_axi_awlen_o;
  logic [2:0]        m_axi_awsize_o;
  logic [1:0]        m_axi_awburst_o;
  logic              m_axi_awvalid_o;
  logic              m_axi_awready_i;
  logic [31:0]       m_axi_wdata_o;
  logic [3:0]        m_axi_wstrb_o;
  logic              m_axi_wlast_o;
  logic              m_axi_wvalid_o;
  logic              m_axi_wready_i;
  logic              m_axi_bvalid_i;
  logic              m_axi_bready_o;

  AXI4_C_WRITER #(
    .AWIDTH   (AWIDTH),
    .ARR_SIZE (ARR_SIZE),
    .CNT_W    (CNT_W)
  ) dut (
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),
    .c_base_addr_i   (c_base_addr_i),
    .c_row_stride_i  (c_row_stride_i),
    .c_global_i0_i   (c_global_i0_i),
    .c_global_j0_i   (c_global_j0_i),
    .c_valid_rows_i  (c_valid_rows_i),
    .c_valid_cols_i  (c_valid_cols_i),
    .tile_valid_i    (tile_valid_i),
    .tile_done_i     (tile_done_i),
    .c_write_done_o  (c_write_done_o),
    .c0_0_i        (c_scalar_i[0][0]),
    .c0_1_i        (c_scalar_i[0][1]),
    .c0_2_i        (c_scalar_i[0][2]),
    .c0_3_i        (c_scalar_i[0][3]),
    .c0_4_i        (c_scalar_i[0][4]),
    .c0_5_i        (c_scalar_i[0][5]),
    .c0_6_i        (c_scalar_i[0][6]),
    .c0_7_i        (c_scalar_i[0][7]),
    .c0_8_i        (c_scalar_i[0][8]),
    .c0_9_i        (c_scalar_i[0][9]),
    .c0_10_i        (c_scalar_i[0][10]),
    .c0_11_i        (c_scalar_i[0][11]),
    .c0_12_i        (c_scalar_i[0][12]),
    .c0_13_i        (c_scalar_i[0][13]),
    .c0_14_i        (c_scalar_i[0][14]),
    .c0_15_i        (c_scalar_i[0][15]),
    .c0_16_i        (c_scalar_i[0][16]),
    .c0_17_i        (c_scalar_i[0][17]),
    .c0_18_i        (c_scalar_i[0][18]),
    .c0_19_i        (c_scalar_i[0][19]),
    .c0_20_i        (c_scalar_i[0][20]),
    .c0_21_i        (c_scalar_i[0][21]),
    .c0_22_i        (c_scalar_i[0][22]),
    .c0_23_i        (c_scalar_i[0][23]),
    .c0_24_i        (c_scalar_i[0][24]),
    .c0_25_i        (c_scalar_i[0][25]),
    .c0_26_i        (c_scalar_i[0][26]),
    .c0_27_i        (c_scalar_i[0][27]),
    .c0_28_i        (c_scalar_i[0][28]),
    .c0_29_i        (c_scalar_i[0][29]),
    .c0_30_i        (c_scalar_i[0][30]),
    .c0_31_i        (c_scalar_i[0][31]),
    .c1_0_i        (c_scalar_i[1][0]),
    .c1_1_i        (c_scalar_i[1][1]),
    .c1_2_i        (c_scalar_i[1][2]),
    .c1_3_i        (c_scalar_i[1][3]),
    .c1_4_i        (c_scalar_i[1][4]),
    .c1_5_i        (c_scalar_i[1][5]),
    .c1_6_i        (c_scalar_i[1][6]),
    .c1_7_i        (c_scalar_i[1][7]),
    .c1_8_i        (c_scalar_i[1][8]),
    .c1_9_i        (c_scalar_i[1][9]),
    .c1_10_i        (c_scalar_i[1][10]),
    .c1_11_i        (c_scalar_i[1][11]),
    .c1_12_i        (c_scalar_i[1][12]),
    .c1_13_i        (c_scalar_i[1][13]),
    .c1_14_i        (c_scalar_i[1][14]),
    .c1_15_i        (c_scalar_i[1][15]),
    .c1_16_i        (c_scalar_i[1][16]),
    .c1_17_i        (c_scalar_i[1][17]),
    .c1_18_i        (c_scalar_i[1][18]),
    .c1_19_i        (c_scalar_i[1][19]),
    .c1_20_i        (c_scalar_i[1][20]),
    .c1_21_i        (c_scalar_i[1][21]),
    .c1_22_i        (c_scalar_i[1][22]),
    .c1_23_i        (c_scalar_i[1][23]),
    .c1_24_i        (c_scalar_i[1][24]),
    .c1_25_i        (c_scalar_i[1][25]),
    .c1_26_i        (c_scalar_i[1][26]),
    .c1_27_i        (c_scalar_i[1][27]),
    .c1_28_i        (c_scalar_i[1][28]),
    .c1_29_i        (c_scalar_i[1][29]),
    .c1_30_i        (c_scalar_i[1][30]),
    .c1_31_i        (c_scalar_i[1][31]),
    .c2_0_i        (c_scalar_i[2][0]),
    .c2_1_i        (c_scalar_i[2][1]),
    .c2_2_i        (c_scalar_i[2][2]),
    .c2_3_i        (c_scalar_i[2][3]),
    .c2_4_i        (c_scalar_i[2][4]),
    .c2_5_i        (c_scalar_i[2][5]),
    .c2_6_i        (c_scalar_i[2][6]),
    .c2_7_i        (c_scalar_i[2][7]),
    .c2_8_i        (c_scalar_i[2][8]),
    .c2_9_i        (c_scalar_i[2][9]),
    .c2_10_i        (c_scalar_i[2][10]),
    .c2_11_i        (c_scalar_i[2][11]),
    .c2_12_i        (c_scalar_i[2][12]),
    .c2_13_i        (c_scalar_i[2][13]),
    .c2_14_i        (c_scalar_i[2][14]),
    .c2_15_i        (c_scalar_i[2][15]),
    .c2_16_i        (c_scalar_i[2][16]),
    .c2_17_i        (c_scalar_i[2][17]),
    .c2_18_i        (c_scalar_i[2][18]),
    .c2_19_i        (c_scalar_i[2][19]),
    .c2_20_i        (c_scalar_i[2][20]),
    .c2_21_i        (c_scalar_i[2][21]),
    .c2_22_i        (c_scalar_i[2][22]),
    .c2_23_i        (c_scalar_i[2][23]),
    .c2_24_i        (c_scalar_i[2][24]),
    .c2_25_i        (c_scalar_i[2][25]),
    .c2_26_i        (c_scalar_i[2][26]),
    .c2_27_i        (c_scalar_i[2][27]),
    .c2_28_i        (c_scalar_i[2][28]),
    .c2_29_i        (c_scalar_i[2][29]),
    .c2_30_i        (c_scalar_i[2][30]),
    .c2_31_i        (c_scalar_i[2][31]),
    .c3_0_i        (c_scalar_i[3][0]),
    .c3_1_i        (c_scalar_i[3][1]),
    .c3_2_i        (c_scalar_i[3][2]),
    .c3_3_i        (c_scalar_i[3][3]),
    .c3_4_i        (c_scalar_i[3][4]),
    .c3_5_i        (c_scalar_i[3][5]),
    .c3_6_i        (c_scalar_i[3][6]),
    .c3_7_i        (c_scalar_i[3][7]),
    .c3_8_i        (c_scalar_i[3][8]),
    .c3_9_i        (c_scalar_i[3][9]),
    .c3_10_i        (c_scalar_i[3][10]),
    .c3_11_i        (c_scalar_i[3][11]),
    .c3_12_i        (c_scalar_i[3][12]),
    .c3_13_i        (c_scalar_i[3][13]),
    .c3_14_i        (c_scalar_i[3][14]),
    .c3_15_i        (c_scalar_i[3][15]),
    .c3_16_i        (c_scalar_i[3][16]),
    .c3_17_i        (c_scalar_i[3][17]),
    .c3_18_i        (c_scalar_i[3][18]),
    .c3_19_i        (c_scalar_i[3][19]),
    .c3_20_i        (c_scalar_i[3][20]),
    .c3_21_i        (c_scalar_i[3][21]),
    .c3_22_i        (c_scalar_i[3][22]),
    .c3_23_i        (c_scalar_i[3][23]),
    .c3_24_i        (c_scalar_i[3][24]),
    .c3_25_i        (c_scalar_i[3][25]),
    .c3_26_i        (c_scalar_i[3][26]),
    .c3_27_i        (c_scalar_i[3][27]),
    .c3_28_i        (c_scalar_i[3][28]),
    .c3_29_i        (c_scalar_i[3][29]),
    .c3_30_i        (c_scalar_i[3][30]),
    .c3_31_i        (c_scalar_i[3][31]),
    .c4_0_i        (c_scalar_i[4][0]),
    .c4_1_i        (c_scalar_i[4][1]),
    .c4_2_i        (c_scalar_i[4][2]),
    .c4_3_i        (c_scalar_i[4][3]),
    .c4_4_i        (c_scalar_i[4][4]),
    .c4_5_i        (c_scalar_i[4][5]),
    .c4_6_i        (c_scalar_i[4][6]),
    .c4_7_i        (c_scalar_i[4][7]),
    .c4_8_i        (c_scalar_i[4][8]),
    .c4_9_i        (c_scalar_i[4][9]),
    .c4_10_i        (c_scalar_i[4][10]),
    .c4_11_i        (c_scalar_i[4][11]),
    .c4_12_i        (c_scalar_i[4][12]),
    .c4_13_i        (c_scalar_i[4][13]),
    .c4_14_i        (c_scalar_i[4][14]),
    .c4_15_i        (c_scalar_i[4][15]),
    .c4_16_i        (c_scalar_i[4][16]),
    .c4_17_i        (c_scalar_i[4][17]),
    .c4_18_i        (c_scalar_i[4][18]),
    .c4_19_i        (c_scalar_i[4][19]),
    .c4_20_i        (c_scalar_i[4][20]),
    .c4_21_i        (c_scalar_i[4][21]),
    .c4_22_i        (c_scalar_i[4][22]),
    .c4_23_i        (c_scalar_i[4][23]),
    .c4_24_i        (c_scalar_i[4][24]),
    .c4_25_i        (c_scalar_i[4][25]),
    .c4_26_i        (c_scalar_i[4][26]),
    .c4_27_i        (c_scalar_i[4][27]),
    .c4_28_i        (c_scalar_i[4][28]),
    .c4_29_i        (c_scalar_i[4][29]),
    .c4_30_i        (c_scalar_i[4][30]),
    .c4_31_i        (c_scalar_i[4][31]),
    .c5_0_i        (c_scalar_i[5][0]),
    .c5_1_i        (c_scalar_i[5][1]),
    .c5_2_i        (c_scalar_i[5][2]),
    .c5_3_i        (c_scalar_i[5][3]),
    .c5_4_i        (c_scalar_i[5][4]),
    .c5_5_i        (c_scalar_i[5][5]),
    .c5_6_i        (c_scalar_i[5][6]),
    .c5_7_i        (c_scalar_i[5][7]),
    .c5_8_i        (c_scalar_i[5][8]),
    .c5_9_i        (c_scalar_i[5][9]),
    .c5_10_i        (c_scalar_i[5][10]),
    .c5_11_i        (c_scalar_i[5][11]),
    .c5_12_i        (c_scalar_i[5][12]),
    .c5_13_i        (c_scalar_i[5][13]),
    .c5_14_i        (c_scalar_i[5][14]),
    .c5_15_i        (c_scalar_i[5][15]),
    .c5_16_i        (c_scalar_i[5][16]),
    .c5_17_i        (c_scalar_i[5][17]),
    .c5_18_i        (c_scalar_i[5][18]),
    .c5_19_i        (c_scalar_i[5][19]),
    .c5_20_i        (c_scalar_i[5][20]),
    .c5_21_i        (c_scalar_i[5][21]),
    .c5_22_i        (c_scalar_i[5][22]),
    .c5_23_i        (c_scalar_i[5][23]),
    .c5_24_i        (c_scalar_i[5][24]),
    .c5_25_i        (c_scalar_i[5][25]),
    .c5_26_i        (c_scalar_i[5][26]),
    .c5_27_i        (c_scalar_i[5][27]),
    .c5_28_i        (c_scalar_i[5][28]),
    .c5_29_i        (c_scalar_i[5][29]),
    .c5_30_i        (c_scalar_i[5][30]),
    .c5_31_i        (c_scalar_i[5][31]),
    .c6_0_i        (c_scalar_i[6][0]),
    .c6_1_i        (c_scalar_i[6][1]),
    .c6_2_i        (c_scalar_i[6][2]),
    .c6_3_i        (c_scalar_i[6][3]),
    .c6_4_i        (c_scalar_i[6][4]),
    .c6_5_i        (c_scalar_i[6][5]),
    .c6_6_i        (c_scalar_i[6][6]),
    .c6_7_i        (c_scalar_i[6][7]),
    .c6_8_i        (c_scalar_i[6][8]),
    .c6_9_i        (c_scalar_i[6][9]),
    .c6_10_i        (c_scalar_i[6][10]),
    .c6_11_i        (c_scalar_i[6][11]),
    .c6_12_i        (c_scalar_i[6][12]),
    .c6_13_i        (c_scalar_i[6][13]),
    .c6_14_i        (c_scalar_i[6][14]),
    .c6_15_i        (c_scalar_i[6][15]),
    .c6_16_i        (c_scalar_i[6][16]),
    .c6_17_i        (c_scalar_i[6][17]),
    .c6_18_i        (c_scalar_i[6][18]),
    .c6_19_i        (c_scalar_i[6][19]),
    .c6_20_i        (c_scalar_i[6][20]),
    .c6_21_i        (c_scalar_i[6][21]),
    .c6_22_i        (c_scalar_i[6][22]),
    .c6_23_i        (c_scalar_i[6][23]),
    .c6_24_i        (c_scalar_i[6][24]),
    .c6_25_i        (c_scalar_i[6][25]),
    .c6_26_i        (c_scalar_i[6][26]),
    .c6_27_i        (c_scalar_i[6][27]),
    .c6_28_i        (c_scalar_i[6][28]),
    .c6_29_i        (c_scalar_i[6][29]),
    .c6_30_i        (c_scalar_i[6][30]),
    .c6_31_i        (c_scalar_i[6][31]),
    .c7_0_i        (c_scalar_i[7][0]),
    .c7_1_i        (c_scalar_i[7][1]),
    .c7_2_i        (c_scalar_i[7][2]),
    .c7_3_i        (c_scalar_i[7][3]),
    .c7_4_i        (c_scalar_i[7][4]),
    .c7_5_i        (c_scalar_i[7][5]),
    .c7_6_i        (c_scalar_i[7][6]),
    .c7_7_i        (c_scalar_i[7][7]),
    .c7_8_i        (c_scalar_i[7][8]),
    .c7_9_i        (c_scalar_i[7][9]),
    .c7_10_i        (c_scalar_i[7][10]),
    .c7_11_i        (c_scalar_i[7][11]),
    .c7_12_i        (c_scalar_i[7][12]),
    .c7_13_i        (c_scalar_i[7][13]),
    .c7_14_i        (c_scalar_i[7][14]),
    .c7_15_i        (c_scalar_i[7][15]),
    .c7_16_i        (c_scalar_i[7][16]),
    .c7_17_i        (c_scalar_i[7][17]),
    .c7_18_i        (c_scalar_i[7][18]),
    .c7_19_i        (c_scalar_i[7][19]),
    .c7_20_i        (c_scalar_i[7][20]),
    .c7_21_i        (c_scalar_i[7][21]),
    .c7_22_i        (c_scalar_i[7][22]),
    .c7_23_i        (c_scalar_i[7][23]),
    .c7_24_i        (c_scalar_i[7][24]),
    .c7_25_i        (c_scalar_i[7][25]),
    .c7_26_i        (c_scalar_i[7][26]),
    .c7_27_i        (c_scalar_i[7][27]),
    .c7_28_i        (c_scalar_i[7][28]),
    .c7_29_i        (c_scalar_i[7][29]),
    .c7_30_i        (c_scalar_i[7][30]),
    .c7_31_i        (c_scalar_i[7][31]),
    .c8_0_i        (c_scalar_i[8][0]),
    .c8_1_i        (c_scalar_i[8][1]),
    .c8_2_i        (c_scalar_i[8][2]),
    .c8_3_i        (c_scalar_i[8][3]),
    .c8_4_i        (c_scalar_i[8][4]),
    .c8_5_i        (c_scalar_i[8][5]),
    .c8_6_i        (c_scalar_i[8][6]),
    .c8_7_i        (c_scalar_i[8][7]),
    .c8_8_i        (c_scalar_i[8][8]),
    .c8_9_i        (c_scalar_i[8][9]),
    .c8_10_i        (c_scalar_i[8][10]),
    .c8_11_i        (c_scalar_i[8][11]),
    .c8_12_i        (c_scalar_i[8][12]),
    .c8_13_i        (c_scalar_i[8][13]),
    .c8_14_i        (c_scalar_i[8][14]),
    .c8_15_i        (c_scalar_i[8][15]),
    .c8_16_i        (c_scalar_i[8][16]),
    .c8_17_i        (c_scalar_i[8][17]),
    .c8_18_i        (c_scalar_i[8][18]),
    .c8_19_i        (c_scalar_i[8][19]),
    .c8_20_i        (c_scalar_i[8][20]),
    .c8_21_i        (c_scalar_i[8][21]),
    .c8_22_i        (c_scalar_i[8][22]),
    .c8_23_i        (c_scalar_i[8][23]),
    .c8_24_i        (c_scalar_i[8][24]),
    .c8_25_i        (c_scalar_i[8][25]),
    .c8_26_i        (c_scalar_i[8][26]),
    .c8_27_i        (c_scalar_i[8][27]),
    .c8_28_i        (c_scalar_i[8][28]),
    .c8_29_i        (c_scalar_i[8][29]),
    .c8_30_i        (c_scalar_i[8][30]),
    .c8_31_i        (c_scalar_i[8][31]),
    .c9_0_i        (c_scalar_i[9][0]),
    .c9_1_i        (c_scalar_i[9][1]),
    .c9_2_i        (c_scalar_i[9][2]),
    .c9_3_i        (c_scalar_i[9][3]),
    .c9_4_i        (c_scalar_i[9][4]),
    .c9_5_i        (c_scalar_i[9][5]),
    .c9_6_i        (c_scalar_i[9][6]),
    .c9_7_i        (c_scalar_i[9][7]),
    .c9_8_i        (c_scalar_i[9][8]),
    .c9_9_i        (c_scalar_i[9][9]),
    .c9_10_i        (c_scalar_i[9][10]),
    .c9_11_i        (c_scalar_i[9][11]),
    .c9_12_i        (c_scalar_i[9][12]),
    .c9_13_i        (c_scalar_i[9][13]),
    .c9_14_i        (c_scalar_i[9][14]),
    .c9_15_i        (c_scalar_i[9][15]),
    .c9_16_i        (c_scalar_i[9][16]),
    .c9_17_i        (c_scalar_i[9][17]),
    .c9_18_i        (c_scalar_i[9][18]),
    .c9_19_i        (c_scalar_i[9][19]),
    .c9_20_i        (c_scalar_i[9][20]),
    .c9_21_i        (c_scalar_i[9][21]),
    .c9_22_i        (c_scalar_i[9][22]),
    .c9_23_i        (c_scalar_i[9][23]),
    .c9_24_i        (c_scalar_i[9][24]),
    .c9_25_i        (c_scalar_i[9][25]),
    .c9_26_i        (c_scalar_i[9][26]),
    .c9_27_i        (c_scalar_i[9][27]),
    .c9_28_i        (c_scalar_i[9][28]),
    .c9_29_i        (c_scalar_i[9][29]),
    .c9_30_i        (c_scalar_i[9][30]),
    .c9_31_i        (c_scalar_i[9][31]),
    .c10_0_i        (c_scalar_i[10][0]),
    .c10_1_i        (c_scalar_i[10][1]),
    .c10_2_i        (c_scalar_i[10][2]),
    .c10_3_i        (c_scalar_i[10][3]),
    .c10_4_i        (c_scalar_i[10][4]),
    .c10_5_i        (c_scalar_i[10][5]),
    .c10_6_i        (c_scalar_i[10][6]),
    .c10_7_i        (c_scalar_i[10][7]),
    .c10_8_i        (c_scalar_i[10][8]),
    .c10_9_i        (c_scalar_i[10][9]),
    .c10_10_i        (c_scalar_i[10][10]),
    .c10_11_i        (c_scalar_i[10][11]),
    .c10_12_i        (c_scalar_i[10][12]),
    .c10_13_i        (c_scalar_i[10][13]),
    .c10_14_i        (c_scalar_i[10][14]),
    .c10_15_i        (c_scalar_i[10][15]),
    .c10_16_i        (c_scalar_i[10][16]),
    .c10_17_i        (c_scalar_i[10][17]),
    .c10_18_i        (c_scalar_i[10][18]),
    .c10_19_i        (c_scalar_i[10][19]),
    .c10_20_i        (c_scalar_i[10][20]),
    .c10_21_i        (c_scalar_i[10][21]),
    .c10_22_i        (c_scalar_i[10][22]),
    .c10_23_i        (c_scalar_i[10][23]),
    .c10_24_i        (c_scalar_i[10][24]),
    .c10_25_i        (c_scalar_i[10][25]),
    .c10_26_i        (c_scalar_i[10][26]),
    .c10_27_i        (c_scalar_i[10][27]),
    .c10_28_i        (c_scalar_i[10][28]),
    .c10_29_i        (c_scalar_i[10][29]),
    .c10_30_i        (c_scalar_i[10][30]),
    .c10_31_i        (c_scalar_i[10][31]),
    .c11_0_i        (c_scalar_i[11][0]),
    .c11_1_i        (c_scalar_i[11][1]),
    .c11_2_i        (c_scalar_i[11][2]),
    .c11_3_i        (c_scalar_i[11][3]),
    .c11_4_i        (c_scalar_i[11][4]),
    .c11_5_i        (c_scalar_i[11][5]),
    .c11_6_i        (c_scalar_i[11][6]),
    .c11_7_i        (c_scalar_i[11][7]),
    .c11_8_i        (c_scalar_i[11][8]),
    .c11_9_i        (c_scalar_i[11][9]),
    .c11_10_i        (c_scalar_i[11][10]),
    .c11_11_i        (c_scalar_i[11][11]),
    .c11_12_i        (c_scalar_i[11][12]),
    .c11_13_i        (c_scalar_i[11][13]),
    .c11_14_i        (c_scalar_i[11][14]),
    .c11_15_i        (c_scalar_i[11][15]),
    .c11_16_i        (c_scalar_i[11][16]),
    .c11_17_i        (c_scalar_i[11][17]),
    .c11_18_i        (c_scalar_i[11][18]),
    .c11_19_i        (c_scalar_i[11][19]),
    .c11_20_i        (c_scalar_i[11][20]),
    .c11_21_i        (c_scalar_i[11][21]),
    .c11_22_i        (c_scalar_i[11][22]),
    .c11_23_i        (c_scalar_i[11][23]),
    .c11_24_i        (c_scalar_i[11][24]),
    .c11_25_i        (c_scalar_i[11][25]),
    .c11_26_i        (c_scalar_i[11][26]),
    .c11_27_i        (c_scalar_i[11][27]),
    .c11_28_i        (c_scalar_i[11][28]),
    .c11_29_i        (c_scalar_i[11][29]),
    .c11_30_i        (c_scalar_i[11][30]),
    .c11_31_i        (c_scalar_i[11][31]),
    .c12_0_i        (c_scalar_i[12][0]),
    .c12_1_i        (c_scalar_i[12][1]),
    .c12_2_i        (c_scalar_i[12][2]),
    .c12_3_i        (c_scalar_i[12][3]),
    .c12_4_i        (c_scalar_i[12][4]),
    .c12_5_i        (c_scalar_i[12][5]),
    .c12_6_i        (c_scalar_i[12][6]),
    .c12_7_i        (c_scalar_i[12][7]),
    .c12_8_i        (c_scalar_i[12][8]),
    .c12_9_i        (c_scalar_i[12][9]),
    .c12_10_i        (c_scalar_i[12][10]),
    .c12_11_i        (c_scalar_i[12][11]),
    .c12_12_i        (c_scalar_i[12][12]),
    .c12_13_i        (c_scalar_i[12][13]),
    .c12_14_i        (c_scalar_i[12][14]),
    .c12_15_i        (c_scalar_i[12][15]),
    .c12_16_i        (c_scalar_i[12][16]),
    .c12_17_i        (c_scalar_i[12][17]),
    .c12_18_i        (c_scalar_i[12][18]),
    .c12_19_i        (c_scalar_i[12][19]),
    .c12_20_i        (c_scalar_i[12][20]),
    .c12_21_i        (c_scalar_i[12][21]),
    .c12_22_i        (c_scalar_i[12][22]),
    .c12_23_i        (c_scalar_i[12][23]),
    .c12_24_i        (c_scalar_i[12][24]),
    .c12_25_i        (c_scalar_i[12][25]),
    .c12_26_i        (c_scalar_i[12][26]),
    .c12_27_i        (c_scalar_i[12][27]),
    .c12_28_i        (c_scalar_i[12][28]),
    .c12_29_i        (c_scalar_i[12][29]),
    .c12_30_i        (c_scalar_i[12][30]),
    .c12_31_i        (c_scalar_i[12][31]),
    .c13_0_i        (c_scalar_i[13][0]),
    .c13_1_i        (c_scalar_i[13][1]),
    .c13_2_i        (c_scalar_i[13][2]),
    .c13_3_i        (c_scalar_i[13][3]),
    .c13_4_i        (c_scalar_i[13][4]),
    .c13_5_i        (c_scalar_i[13][5]),
    .c13_6_i        (c_scalar_i[13][6]),
    .c13_7_i        (c_scalar_i[13][7]),
    .c13_8_i        (c_scalar_i[13][8]),
    .c13_9_i        (c_scalar_i[13][9]),
    .c13_10_i        (c_scalar_i[13][10]),
    .c13_11_i        (c_scalar_i[13][11]),
    .c13_12_i        (c_scalar_i[13][12]),
    .c13_13_i        (c_scalar_i[13][13]),
    .c13_14_i        (c_scalar_i[13][14]),
    .c13_15_i        (c_scalar_i[13][15]),
    .c13_16_i        (c_scalar_i[13][16]),
    .c13_17_i        (c_scalar_i[13][17]),
    .c13_18_i        (c_scalar_i[13][18]),
    .c13_19_i        (c_scalar_i[13][19]),
    .c13_20_i        (c_scalar_i[13][20]),
    .c13_21_i        (c_scalar_i[13][21]),
    .c13_22_i        (c_scalar_i[13][22]),
    .c13_23_i        (c_scalar_i[13][23]),
    .c13_24_i        (c_scalar_i[13][24]),
    .c13_25_i        (c_scalar_i[13][25]),
    .c13_26_i        (c_scalar_i[13][26]),
    .c13_27_i        (c_scalar_i[13][27]),
    .c13_28_i        (c_scalar_i[13][28]),
    .c13_29_i        (c_scalar_i[13][29]),
    .c13_30_i        (c_scalar_i[13][30]),
    .c13_31_i        (c_scalar_i[13][31]),
    .c14_0_i        (c_scalar_i[14][0]),
    .c14_1_i        (c_scalar_i[14][1]),
    .c14_2_i        (c_scalar_i[14][2]),
    .c14_3_i        (c_scalar_i[14][3]),
    .c14_4_i        (c_scalar_i[14][4]),
    .c14_5_i        (c_scalar_i[14][5]),
    .c14_6_i        (c_scalar_i[14][6]),
    .c14_7_i        (c_scalar_i[14][7]),
    .c14_8_i        (c_scalar_i[14][8]),
    .c14_9_i        (c_scalar_i[14][9]),
    .c14_10_i        (c_scalar_i[14][10]),
    .c14_11_i        (c_scalar_i[14][11]),
    .c14_12_i        (c_scalar_i[14][12]),
    .c14_13_i        (c_scalar_i[14][13]),
    .c14_14_i        (c_scalar_i[14][14]),
    .c14_15_i        (c_scalar_i[14][15]),
    .c14_16_i        (c_scalar_i[14][16]),
    .c14_17_i        (c_scalar_i[14][17]),
    .c14_18_i        (c_scalar_i[14][18]),
    .c14_19_i        (c_scalar_i[14][19]),
    .c14_20_i        (c_scalar_i[14][20]),
    .c14_21_i        (c_scalar_i[14][21]),
    .c14_22_i        (c_scalar_i[14][22]),
    .c14_23_i        (c_scalar_i[14][23]),
    .c14_24_i        (c_scalar_i[14][24]),
    .c14_25_i        (c_scalar_i[14][25]),
    .c14_26_i        (c_scalar_i[14][26]),
    .c14_27_i        (c_scalar_i[14][27]),
    .c14_28_i        (c_scalar_i[14][28]),
    .c14_29_i        (c_scalar_i[14][29]),
    .c14_30_i        (c_scalar_i[14][30]),
    .c14_31_i        (c_scalar_i[14][31]),
    .c15_0_i        (c_scalar_i[15][0]),
    .c15_1_i        (c_scalar_i[15][1]),
    .c15_2_i        (c_scalar_i[15][2]),
    .c15_3_i        (c_scalar_i[15][3]),
    .c15_4_i        (c_scalar_i[15][4]),
    .c15_5_i        (c_scalar_i[15][5]),
    .c15_6_i        (c_scalar_i[15][6]),
    .c15_7_i        (c_scalar_i[15][7]),
    .c15_8_i        (c_scalar_i[15][8]),
    .c15_9_i        (c_scalar_i[15][9]),
    .c15_10_i        (c_scalar_i[15][10]),
    .c15_11_i        (c_scalar_i[15][11]),
    .c15_12_i        (c_scalar_i[15][12]),
    .c15_13_i        (c_scalar_i[15][13]),
    .c15_14_i        (c_scalar_i[15][14]),
    .c15_15_i        (c_scalar_i[15][15]),
    .c15_16_i        (c_scalar_i[15][16]),
    .c15_17_i        (c_scalar_i[15][17]),
    .c15_18_i        (c_scalar_i[15][18]),
    .c15_19_i        (c_scalar_i[15][19]),
    .c15_20_i        (c_scalar_i[15][20]),
    .c15_21_i        (c_scalar_i[15][21]),
    .c15_22_i        (c_scalar_i[15][22]),
    .c15_23_i        (c_scalar_i[15][23]),
    .c15_24_i        (c_scalar_i[15][24]),
    .c15_25_i        (c_scalar_i[15][25]),
    .c15_26_i        (c_scalar_i[15][26]),
    .c15_27_i        (c_scalar_i[15][27]),
    .c15_28_i        (c_scalar_i[15][28]),
    .c15_29_i        (c_scalar_i[15][29]),
    .c15_30_i        (c_scalar_i[15][30]),
    .c15_31_i        (c_scalar_i[15][31]),
    .c16_0_i        (c_scalar_i[16][0]),
    .c16_1_i        (c_scalar_i[16][1]),
    .c16_2_i        (c_scalar_i[16][2]),
    .c16_3_i        (c_scalar_i[16][3]),
    .c16_4_i        (c_scalar_i[16][4]),
    .c16_5_i        (c_scalar_i[16][5]),
    .c16_6_i        (c_scalar_i[16][6]),
    .c16_7_i        (c_scalar_i[16][7]),
    .c16_8_i        (c_scalar_i[16][8]),
    .c16_9_i        (c_scalar_i[16][9]),
    .c16_10_i        (c_scalar_i[16][10]),
    .c16_11_i        (c_scalar_i[16][11]),
    .c16_12_i        (c_scalar_i[16][12]),
    .c16_13_i        (c_scalar_i[16][13]),
    .c16_14_i        (c_scalar_i[16][14]),
    .c16_15_i        (c_scalar_i[16][15]),
    .c16_16_i        (c_scalar_i[16][16]),
    .c16_17_i        (c_scalar_i[16][17]),
    .c16_18_i        (c_scalar_i[16][18]),
    .c16_19_i        (c_scalar_i[16][19]),
    .c16_20_i        (c_scalar_i[16][20]),
    .c16_21_i        (c_scalar_i[16][21]),
    .c16_22_i        (c_scalar_i[16][22]),
    .c16_23_i        (c_scalar_i[16][23]),
    .c16_24_i        (c_scalar_i[16][24]),
    .c16_25_i        (c_scalar_i[16][25]),
    .c16_26_i        (c_scalar_i[16][26]),
    .c16_27_i        (c_scalar_i[16][27]),
    .c16_28_i        (c_scalar_i[16][28]),
    .c16_29_i        (c_scalar_i[16][29]),
    .c16_30_i        (c_scalar_i[16][30]),
    .c16_31_i        (c_scalar_i[16][31]),
    .c17_0_i        (c_scalar_i[17][0]),
    .c17_1_i        (c_scalar_i[17][1]),
    .c17_2_i        (c_scalar_i[17][2]),
    .c17_3_i        (c_scalar_i[17][3]),
    .c17_4_i        (c_scalar_i[17][4]),
    .c17_5_i        (c_scalar_i[17][5]),
    .c17_6_i        (c_scalar_i[17][6]),
    .c17_7_i        (c_scalar_i[17][7]),
    .c17_8_i        (c_scalar_i[17][8]),
    .c17_9_i        (c_scalar_i[17][9]),
    .c17_10_i        (c_scalar_i[17][10]),
    .c17_11_i        (c_scalar_i[17][11]),
    .c17_12_i        (c_scalar_i[17][12]),
    .c17_13_i        (c_scalar_i[17][13]),
    .c17_14_i        (c_scalar_i[17][14]),
    .c17_15_i        (c_scalar_i[17][15]),
    .c17_16_i        (c_scalar_i[17][16]),
    .c17_17_i        (c_scalar_i[17][17]),
    .c17_18_i        (c_scalar_i[17][18]),
    .c17_19_i        (c_scalar_i[17][19]),
    .c17_20_i        (c_scalar_i[17][20]),
    .c17_21_i        (c_scalar_i[17][21]),
    .c17_22_i        (c_scalar_i[17][22]),
    .c17_23_i        (c_scalar_i[17][23]),
    .c17_24_i        (c_scalar_i[17][24]),
    .c17_25_i        (c_scalar_i[17][25]),
    .c17_26_i        (c_scalar_i[17][26]),
    .c17_27_i        (c_scalar_i[17][27]),
    .c17_28_i        (c_scalar_i[17][28]),
    .c17_29_i        (c_scalar_i[17][29]),
    .c17_30_i        (c_scalar_i[17][30]),
    .c17_31_i        (c_scalar_i[17][31]),
    .c18_0_i        (c_scalar_i[18][0]),
    .c18_1_i        (c_scalar_i[18][1]),
    .c18_2_i        (c_scalar_i[18][2]),
    .c18_3_i        (c_scalar_i[18][3]),
    .c18_4_i        (c_scalar_i[18][4]),
    .c18_5_i        (c_scalar_i[18][5]),
    .c18_6_i        (c_scalar_i[18][6]),
    .c18_7_i        (c_scalar_i[18][7]),
    .c18_8_i        (c_scalar_i[18][8]),
    .c18_9_i        (c_scalar_i[18][9]),
    .c18_10_i        (c_scalar_i[18][10]),
    .c18_11_i        (c_scalar_i[18][11]),
    .c18_12_i        (c_scalar_i[18][12]),
    .c18_13_i        (c_scalar_i[18][13]),
    .c18_14_i        (c_scalar_i[18][14]),
    .c18_15_i        (c_scalar_i[18][15]),
    .c18_16_i        (c_scalar_i[18][16]),
    .c18_17_i        (c_scalar_i[18][17]),
    .c18_18_i        (c_scalar_i[18][18]),
    .c18_19_i        (c_scalar_i[18][19]),
    .c18_20_i        (c_scalar_i[18][20]),
    .c18_21_i        (c_scalar_i[18][21]),
    .c18_22_i        (c_scalar_i[18][22]),
    .c18_23_i        (c_scalar_i[18][23]),
    .c18_24_i        (c_scalar_i[18][24]),
    .c18_25_i        (c_scalar_i[18][25]),
    .c18_26_i        (c_scalar_i[18][26]),
    .c18_27_i        (c_scalar_i[18][27]),
    .c18_28_i        (c_scalar_i[18][28]),
    .c18_29_i        (c_scalar_i[18][29]),
    .c18_30_i        (c_scalar_i[18][30]),
    .c18_31_i        (c_scalar_i[18][31]),
    .c19_0_i        (c_scalar_i[19][0]),
    .c19_1_i        (c_scalar_i[19][1]),
    .c19_2_i        (c_scalar_i[19][2]),
    .c19_3_i        (c_scalar_i[19][3]),
    .c19_4_i        (c_scalar_i[19][4]),
    .c19_5_i        (c_scalar_i[19][5]),
    .c19_6_i        (c_scalar_i[19][6]),
    .c19_7_i        (c_scalar_i[19][7]),
    .c19_8_i        (c_scalar_i[19][8]),
    .c19_9_i        (c_scalar_i[19][9]),
    .c19_10_i        (c_scalar_i[19][10]),
    .c19_11_i        (c_scalar_i[19][11]),
    .c19_12_i        (c_scalar_i[19][12]),
    .c19_13_i        (c_scalar_i[19][13]),
    .c19_14_i        (c_scalar_i[19][14]),
    .c19_15_i        (c_scalar_i[19][15]),
    .c19_16_i        (c_scalar_i[19][16]),
    .c19_17_i        (c_scalar_i[19][17]),
    .c19_18_i        (c_scalar_i[19][18]),
    .c19_19_i        (c_scalar_i[19][19]),
    .c19_20_i        (c_scalar_i[19][20]),
    .c19_21_i        (c_scalar_i[19][21]),
    .c19_22_i        (c_scalar_i[19][22]),
    .c19_23_i        (c_scalar_i[19][23]),
    .c19_24_i        (c_scalar_i[19][24]),
    .c19_25_i        (c_scalar_i[19][25]),
    .c19_26_i        (c_scalar_i[19][26]),
    .c19_27_i        (c_scalar_i[19][27]),
    .c19_28_i        (c_scalar_i[19][28]),
    .c19_29_i        (c_scalar_i[19][29]),
    .c19_30_i        (c_scalar_i[19][30]),
    .c19_31_i        (c_scalar_i[19][31]),
    .c20_0_i        (c_scalar_i[20][0]),
    .c20_1_i        (c_scalar_i[20][1]),
    .c20_2_i        (c_scalar_i[20][2]),
    .c20_3_i        (c_scalar_i[20][3]),
    .c20_4_i        (c_scalar_i[20][4]),
    .c20_5_i        (c_scalar_i[20][5]),
    .c20_6_i        (c_scalar_i[20][6]),
    .c20_7_i        (c_scalar_i[20][7]),
    .c20_8_i        (c_scalar_i[20][8]),
    .c20_9_i        (c_scalar_i[20][9]),
    .c20_10_i        (c_scalar_i[20][10]),
    .c20_11_i        (c_scalar_i[20][11]),
    .c20_12_i        (c_scalar_i[20][12]),
    .c20_13_i        (c_scalar_i[20][13]),
    .c20_14_i        (c_scalar_i[20][14]),
    .c20_15_i        (c_scalar_i[20][15]),
    .c20_16_i        (c_scalar_i[20][16]),
    .c20_17_i        (c_scalar_i[20][17]),
    .c20_18_i        (c_scalar_i[20][18]),
    .c20_19_i        (c_scalar_i[20][19]),
    .c20_20_i        (c_scalar_i[20][20]),
    .c20_21_i        (c_scalar_i[20][21]),
    .c20_22_i        (c_scalar_i[20][22]),
    .c20_23_i        (c_scalar_i[20][23]),
    .c20_24_i        (c_scalar_i[20][24]),
    .c20_25_i        (c_scalar_i[20][25]),
    .c20_26_i        (c_scalar_i[20][26]),
    .c20_27_i        (c_scalar_i[20][27]),
    .c20_28_i        (c_scalar_i[20][28]),
    .c20_29_i        (c_scalar_i[20][29]),
    .c20_30_i        (c_scalar_i[20][30]),
    .c20_31_i        (c_scalar_i[20][31]),
    .c21_0_i        (c_scalar_i[21][0]),
    .c21_1_i        (c_scalar_i[21][1]),
    .c21_2_i        (c_scalar_i[21][2]),
    .c21_3_i        (c_scalar_i[21][3]),
    .c21_4_i        (c_scalar_i[21][4]),
    .c21_5_i        (c_scalar_i[21][5]),
    .c21_6_i        (c_scalar_i[21][6]),
    .c21_7_i        (c_scalar_i[21][7]),
    .c21_8_i        (c_scalar_i[21][8]),
    .c21_9_i        (c_scalar_i[21][9]),
    .c21_10_i        (c_scalar_i[21][10]),
    .c21_11_i        (c_scalar_i[21][11]),
    .c21_12_i        (c_scalar_i[21][12]),
    .c21_13_i        (c_scalar_i[21][13]),
    .c21_14_i        (c_scalar_i[21][14]),
    .c21_15_i        (c_scalar_i[21][15]),
    .c21_16_i        (c_scalar_i[21][16]),
    .c21_17_i        (c_scalar_i[21][17]),
    .c21_18_i        (c_scalar_i[21][18]),
    .c21_19_i        (c_scalar_i[21][19]),
    .c21_20_i        (c_scalar_i[21][20]),
    .c21_21_i        (c_scalar_i[21][21]),
    .c21_22_i        (c_scalar_i[21][22]),
    .c21_23_i        (c_scalar_i[21][23]),
    .c21_24_i        (c_scalar_i[21][24]),
    .c21_25_i        (c_scalar_i[21][25]),
    .c21_26_i        (c_scalar_i[21][26]),
    .c21_27_i        (c_scalar_i[21][27]),
    .c21_28_i        (c_scalar_i[21][28]),
    .c21_29_i        (c_scalar_i[21][29]),
    .c21_30_i        (c_scalar_i[21][30]),
    .c21_31_i        (c_scalar_i[21][31]),
    .c22_0_i        (c_scalar_i[22][0]),
    .c22_1_i        (c_scalar_i[22][1]),
    .c22_2_i        (c_scalar_i[22][2]),
    .c22_3_i        (c_scalar_i[22][3]),
    .c22_4_i        (c_scalar_i[22][4]),
    .c22_5_i        (c_scalar_i[22][5]),
    .c22_6_i        (c_scalar_i[22][6]),
    .c22_7_i        (c_scalar_i[22][7]),
    .c22_8_i        (c_scalar_i[22][8]),
    .c22_9_i        (c_scalar_i[22][9]),
    .c22_10_i        (c_scalar_i[22][10]),
    .c22_11_i        (c_scalar_i[22][11]),
    .c22_12_i        (c_scalar_i[22][12]),
    .c22_13_i        (c_scalar_i[22][13]),
    .c22_14_i        (c_scalar_i[22][14]),
    .c22_15_i        (c_scalar_i[22][15]),
    .c22_16_i        (c_scalar_i[22][16]),
    .c22_17_i        (c_scalar_i[22][17]),
    .c22_18_i        (c_scalar_i[22][18]),
    .c22_19_i        (c_scalar_i[22][19]),
    .c22_20_i        (c_scalar_i[22][20]),
    .c22_21_i        (c_scalar_i[22][21]),
    .c22_22_i        (c_scalar_i[22][22]),
    .c22_23_i        (c_scalar_i[22][23]),
    .c22_24_i        (c_scalar_i[22][24]),
    .c22_25_i        (c_scalar_i[22][25]),
    .c22_26_i        (c_scalar_i[22][26]),
    .c22_27_i        (c_scalar_i[22][27]),
    .c22_28_i        (c_scalar_i[22][28]),
    .c22_29_i        (c_scalar_i[22][29]),
    .c22_30_i        (c_scalar_i[22][30]),
    .c22_31_i        (c_scalar_i[22][31]),
    .c23_0_i        (c_scalar_i[23][0]),
    .c23_1_i        (c_scalar_i[23][1]),
    .c23_2_i        (c_scalar_i[23][2]),
    .c23_3_i        (c_scalar_i[23][3]),
    .c23_4_i        (c_scalar_i[23][4]),
    .c23_5_i        (c_scalar_i[23][5]),
    .c23_6_i        (c_scalar_i[23][6]),
    .c23_7_i        (c_scalar_i[23][7]),
    .c23_8_i        (c_scalar_i[23][8]),
    .c23_9_i        (c_scalar_i[23][9]),
    .c23_10_i        (c_scalar_i[23][10]),
    .c23_11_i        (c_scalar_i[23][11]),
    .c23_12_i        (c_scalar_i[23][12]),
    .c23_13_i        (c_scalar_i[23][13]),
    .c23_14_i        (c_scalar_i[23][14]),
    .c23_15_i        (c_scalar_i[23][15]),
    .c23_16_i        (c_scalar_i[23][16]),
    .c23_17_i        (c_scalar_i[23][17]),
    .c23_18_i        (c_scalar_i[23][18]),
    .c23_19_i        (c_scalar_i[23][19]),
    .c23_20_i        (c_scalar_i[23][20]),
    .c23_21_i        (c_scalar_i[23][21]),
    .c23_22_i        (c_scalar_i[23][22]),
    .c23_23_i        (c_scalar_i[23][23]),
    .c23_24_i        (c_scalar_i[23][24]),
    .c23_25_i        (c_scalar_i[23][25]),
    .c23_26_i        (c_scalar_i[23][26]),
    .c23_27_i        (c_scalar_i[23][27]),
    .c23_28_i        (c_scalar_i[23][28]),
    .c23_29_i        (c_scalar_i[23][29]),
    .c23_30_i        (c_scalar_i[23][30]),
    .c23_31_i        (c_scalar_i[23][31]),
    .c24_0_i        (c_scalar_i[24][0]),
    .c24_1_i        (c_scalar_i[24][1]),
    .c24_2_i        (c_scalar_i[24][2]),
    .c24_3_i        (c_scalar_i[24][3]),
    .c24_4_i        (c_scalar_i[24][4]),
    .c24_5_i        (c_scalar_i[24][5]),
    .c24_6_i        (c_scalar_i[24][6]),
    .c24_7_i        (c_scalar_i[24][7]),
    .c24_8_i        (c_scalar_i[24][8]),
    .c24_9_i        (c_scalar_i[24][9]),
    .c24_10_i        (c_scalar_i[24][10]),
    .c24_11_i        (c_scalar_i[24][11]),
    .c24_12_i        (c_scalar_i[24][12]),
    .c24_13_i        (c_scalar_i[24][13]),
    .c24_14_i        (c_scalar_i[24][14]),
    .c24_15_i        (c_scalar_i[24][15]),
    .c24_16_i        (c_scalar_i[24][16]),
    .c24_17_i        (c_scalar_i[24][17]),
    .c24_18_i        (c_scalar_i[24][18]),
    .c24_19_i        (c_scalar_i[24][19]),
    .c24_20_i        (c_scalar_i[24][20]),
    .c24_21_i        (c_scalar_i[24][21]),
    .c24_22_i        (c_scalar_i[24][22]),
    .c24_23_i        (c_scalar_i[24][23]),
    .c24_24_i        (c_scalar_i[24][24]),
    .c24_25_i        (c_scalar_i[24][25]),
    .c24_26_i        (c_scalar_i[24][26]),
    .c24_27_i        (c_scalar_i[24][27]),
    .c24_28_i        (c_scalar_i[24][28]),
    .c24_29_i        (c_scalar_i[24][29]),
    .c24_30_i        (c_scalar_i[24][30]),
    .c24_31_i        (c_scalar_i[24][31]),
    .c25_0_i        (c_scalar_i[25][0]),
    .c25_1_i        (c_scalar_i[25][1]),
    .c25_2_i        (c_scalar_i[25][2]),
    .c25_3_i        (c_scalar_i[25][3]),
    .c25_4_i        (c_scalar_i[25][4]),
    .c25_5_i        (c_scalar_i[25][5]),
    .c25_6_i        (c_scalar_i[25][6]),
    .c25_7_i        (c_scalar_i[25][7]),
    .c25_8_i        (c_scalar_i[25][8]),
    .c25_9_i        (c_scalar_i[25][9]),
    .c25_10_i        (c_scalar_i[25][10]),
    .c25_11_i        (c_scalar_i[25][11]),
    .c25_12_i        (c_scalar_i[25][12]),
    .c25_13_i        (c_scalar_i[25][13]),
    .c25_14_i        (c_scalar_i[25][14]),
    .c25_15_i        (c_scalar_i[25][15]),
    .c25_16_i        (c_scalar_i[25][16]),
    .c25_17_i        (c_scalar_i[25][17]),
    .c25_18_i        (c_scalar_i[25][18]),
    .c25_19_i        (c_scalar_i[25][19]),
    .c25_20_i        (c_scalar_i[25][20]),
    .c25_21_i        (c_scalar_i[25][21]),
    .c25_22_i        (c_scalar_i[25][22]),
    .c25_23_i        (c_scalar_i[25][23]),
    .c25_24_i        (c_scalar_i[25][24]),
    .c25_25_i        (c_scalar_i[25][25]),
    .c25_26_i        (c_scalar_i[25][26]),
    .c25_27_i        (c_scalar_i[25][27]),
    .c25_28_i        (c_scalar_i[25][28]),
    .c25_29_i        (c_scalar_i[25][29]),
    .c25_30_i        (c_scalar_i[25][30]),
    .c25_31_i        (c_scalar_i[25][31]),
    .c26_0_i        (c_scalar_i[26][0]),
    .c26_1_i        (c_scalar_i[26][1]),
    .c26_2_i        (c_scalar_i[26][2]),
    .c26_3_i        (c_scalar_i[26][3]),
    .c26_4_i        (c_scalar_i[26][4]),
    .c26_5_i        (c_scalar_i[26][5]),
    .c26_6_i        (c_scalar_i[26][6]),
    .c26_7_i        (c_scalar_i[26][7]),
    .c26_8_i        (c_scalar_i[26][8]),
    .c26_9_i        (c_scalar_i[26][9]),
    .c26_10_i        (c_scalar_i[26][10]),
    .c26_11_i        (c_scalar_i[26][11]),
    .c26_12_i        (c_scalar_i[26][12]),
    .c26_13_i        (c_scalar_i[26][13]),
    .c26_14_i        (c_scalar_i[26][14]),
    .c26_15_i        (c_scalar_i[26][15]),
    .c26_16_i        (c_scalar_i[26][16]),
    .c26_17_i        (c_scalar_i[26][17]),
    .c26_18_i        (c_scalar_i[26][18]),
    .c26_19_i        (c_scalar_i[26][19]),
    .c26_20_i        (c_scalar_i[26][20]),
    .c26_21_i        (c_scalar_i[26][21]),
    .c26_22_i        (c_scalar_i[26][22]),
    .c26_23_i        (c_scalar_i[26][23]),
    .c26_24_i        (c_scalar_i[26][24]),
    .c26_25_i        (c_scalar_i[26][25]),
    .c26_26_i        (c_scalar_i[26][26]),
    .c26_27_i        (c_scalar_i[26][27]),
    .c26_28_i        (c_scalar_i[26][28]),
    .c26_29_i        (c_scalar_i[26][29]),
    .c26_30_i        (c_scalar_i[26][30]),
    .c26_31_i        (c_scalar_i[26][31]),
    .c27_0_i        (c_scalar_i[27][0]),
    .c27_1_i        (c_scalar_i[27][1]),
    .c27_2_i        (c_scalar_i[27][2]),
    .c27_3_i        (c_scalar_i[27][3]),
    .c27_4_i        (c_scalar_i[27][4]),
    .c27_5_i        (c_scalar_i[27][5]),
    .c27_6_i        (c_scalar_i[27][6]),
    .c27_7_i        (c_scalar_i[27][7]),
    .c27_8_i        (c_scalar_i[27][8]),
    .c27_9_i        (c_scalar_i[27][9]),
    .c27_10_i        (c_scalar_i[27][10]),
    .c27_11_i        (c_scalar_i[27][11]),
    .c27_12_i        (c_scalar_i[27][12]),
    .c27_13_i        (c_scalar_i[27][13]),
    .c27_14_i        (c_scalar_i[27][14]),
    .c27_15_i        (c_scalar_i[27][15]),
    .c27_16_i        (c_scalar_i[27][16]),
    .c27_17_i        (c_scalar_i[27][17]),
    .c27_18_i        (c_scalar_i[27][18]),
    .c27_19_i        (c_scalar_i[27][19]),
    .c27_20_i        (c_scalar_i[27][20]),
    .c27_21_i        (c_scalar_i[27][21]),
    .c27_22_i        (c_scalar_i[27][22]),
    .c27_23_i        (c_scalar_i[27][23]),
    .c27_24_i        (c_scalar_i[27][24]),
    .c27_25_i        (c_scalar_i[27][25]),
    .c27_26_i        (c_scalar_i[27][26]),
    .c27_27_i        (c_scalar_i[27][27]),
    .c27_28_i        (c_scalar_i[27][28]),
    .c27_29_i        (c_scalar_i[27][29]),
    .c27_30_i        (c_scalar_i[27][30]),
    .c27_31_i        (c_scalar_i[27][31]),
    .c28_0_i        (c_scalar_i[28][0]),
    .c28_1_i        (c_scalar_i[28][1]),
    .c28_2_i        (c_scalar_i[28][2]),
    .c28_3_i        (c_scalar_i[28][3]),
    .c28_4_i        (c_scalar_i[28][4]),
    .c28_5_i        (c_scalar_i[28][5]),
    .c28_6_i        (c_scalar_i[28][6]),
    .c28_7_i        (c_scalar_i[28][7]),
    .c28_8_i        (c_scalar_i[28][8]),
    .c28_9_i        (c_scalar_i[28][9]),
    .c28_10_i        (c_scalar_i[28][10]),
    .c28_11_i        (c_scalar_i[28][11]),
    .c28_12_i        (c_scalar_i[28][12]),
    .c28_13_i        (c_scalar_i[28][13]),
    .c28_14_i        (c_scalar_i[28][14]),
    .c28_15_i        (c_scalar_i[28][15]),
    .c28_16_i        (c_scalar_i[28][16]),
    .c28_17_i        (c_scalar_i[28][17]),
    .c28_18_i        (c_scalar_i[28][18]),
    .c28_19_i        (c_scalar_i[28][19]),
    .c28_20_i        (c_scalar_i[28][20]),
    .c28_21_i        (c_scalar_i[28][21]),
    .c28_22_i        (c_scalar_i[28][22]),
    .c28_23_i        (c_scalar_i[28][23]),
    .c28_24_i        (c_scalar_i[28][24]),
    .c28_25_i        (c_scalar_i[28][25]),
    .c28_26_i        (c_scalar_i[28][26]),
    .c28_27_i        (c_scalar_i[28][27]),
    .c28_28_i        (c_scalar_i[28][28]),
    .c28_29_i        (c_scalar_i[28][29]),
    .c28_30_i        (c_scalar_i[28][30]),
    .c28_31_i        (c_scalar_i[28][31]),
    .c29_0_i        (c_scalar_i[29][0]),
    .c29_1_i        (c_scalar_i[29][1]),
    .c29_2_i        (c_scalar_i[29][2]),
    .c29_3_i        (c_scalar_i[29][3]),
    .c29_4_i        (c_scalar_i[29][4]),
    .c29_5_i        (c_scalar_i[29][5]),
    .c29_6_i        (c_scalar_i[29][6]),
    .c29_7_i        (c_scalar_i[29][7]),
    .c29_8_i        (c_scalar_i[29][8]),
    .c29_9_i        (c_scalar_i[29][9]),
    .c29_10_i        (c_scalar_i[29][10]),
    .c29_11_i        (c_scalar_i[29][11]),
    .c29_12_i        (c_scalar_i[29][12]),
    .c29_13_i        (c_scalar_i[29][13]),
    .c29_14_i        (c_scalar_i[29][14]),
    .c29_15_i        (c_scalar_i[29][15]),
    .c29_16_i        (c_scalar_i[29][16]),
    .c29_17_i        (c_scalar_i[29][17]),
    .c29_18_i        (c_scalar_i[29][18]),
    .c29_19_i        (c_scalar_i[29][19]),
    .c29_20_i        (c_scalar_i[29][20]),
    .c29_21_i        (c_scalar_i[29][21]),
    .c29_22_i        (c_scalar_i[29][22]),
    .c29_23_i        (c_scalar_i[29][23]),
    .c29_24_i        (c_scalar_i[29][24]),
    .c29_25_i        (c_scalar_i[29][25]),
    .c29_26_i        (c_scalar_i[29][26]),
    .c29_27_i        (c_scalar_i[29][27]),
    .c29_28_i        (c_scalar_i[29][28]),
    .c29_29_i        (c_scalar_i[29][29]),
    .c29_30_i        (c_scalar_i[29][30]),
    .c29_31_i        (c_scalar_i[29][31]),
    .c30_0_i        (c_scalar_i[30][0]),
    .c30_1_i        (c_scalar_i[30][1]),
    .c30_2_i        (c_scalar_i[30][2]),
    .c30_3_i        (c_scalar_i[30][3]),
    .c30_4_i        (c_scalar_i[30][4]),
    .c30_5_i        (c_scalar_i[30][5]),
    .c30_6_i        (c_scalar_i[30][6]),
    .c30_7_i        (c_scalar_i[30][7]),
    .c30_8_i        (c_scalar_i[30][8]),
    .c30_9_i        (c_scalar_i[30][9]),
    .c30_10_i        (c_scalar_i[30][10]),
    .c30_11_i        (c_scalar_i[30][11]),
    .c30_12_i        (c_scalar_i[30][12]),
    .c30_13_i        (c_scalar_i[30][13]),
    .c30_14_i        (c_scalar_i[30][14]),
    .c30_15_i        (c_scalar_i[30][15]),
    .c30_16_i        (c_scalar_i[30][16]),
    .c30_17_i        (c_scalar_i[30][17]),
    .c30_18_i        (c_scalar_i[30][18]),
    .c30_19_i        (c_scalar_i[30][19]),
    .c30_20_i        (c_scalar_i[30][20]),
    .c30_21_i        (c_scalar_i[30][21]),
    .c30_22_i        (c_scalar_i[30][22]),
    .c30_23_i        (c_scalar_i[30][23]),
    .c30_24_i        (c_scalar_i[30][24]),
    .c30_25_i        (c_scalar_i[30][25]),
    .c30_26_i        (c_scalar_i[30][26]),
    .c30_27_i        (c_scalar_i[30][27]),
    .c30_28_i        (c_scalar_i[30][28]),
    .c30_29_i        (c_scalar_i[30][29]),
    .c30_30_i        (c_scalar_i[30][30]),
    .c30_31_i        (c_scalar_i[30][31]),
    .c31_0_i        (c_scalar_i[31][0]),
    .c31_1_i        (c_scalar_i[31][1]),
    .c31_2_i        (c_scalar_i[31][2]),
    .c31_3_i        (c_scalar_i[31][3]),
    .c31_4_i        (c_scalar_i[31][4]),
    .c31_5_i        (c_scalar_i[31][5]),
    .c31_6_i        (c_scalar_i[31][6]),
    .c31_7_i        (c_scalar_i[31][7]),
    .c31_8_i        (c_scalar_i[31][8]),
    .c31_9_i        (c_scalar_i[31][9]),
    .c31_10_i        (c_scalar_i[31][10]),
    .c31_11_i        (c_scalar_i[31][11]),
    .c31_12_i        (c_scalar_i[31][12]),
    .c31_13_i        (c_scalar_i[31][13]),
    .c31_14_i        (c_scalar_i[31][14]),
    .c31_15_i        (c_scalar_i[31][15]),
    .c31_16_i        (c_scalar_i[31][16]),
    .c31_17_i        (c_scalar_i[31][17]),
    .c31_18_i        (c_scalar_i[31][18]),
    .c31_19_i        (c_scalar_i[31][19]),
    .c31_20_i        (c_scalar_i[31][20]),
    .c31_21_i        (c_scalar_i[31][21]),
    .c31_22_i        (c_scalar_i[31][22]),
    .c31_23_i        (c_scalar_i[31][23]),
    .c31_24_i        (c_scalar_i[31][24]),
    .c31_25_i        (c_scalar_i[31][25]),
    .c31_26_i        (c_scalar_i[31][26]),
    .c31_27_i        (c_scalar_i[31][27]),
    .c31_28_i        (c_scalar_i[31][28]),
    .c31_29_i        (c_scalar_i[31][29]),
    .c31_30_i        (c_scalar_i[31][30]),
    .c31_31_i        (c_scalar_i[31][31]),
    .m_axi_awaddr_o  (m_axi_awaddr_o),
    .m_axi_awlen_o   (m_axi_awlen_o),
    .m_axi_awsize_o  (m_axi_awsize_o),
    .m_axi_awburst_o (m_axi_awburst_o),
    .m_axi_awvalid_o (m_axi_awvalid_o),
    .m_axi_awready_i (m_axi_awready_i),
    .m_axi_wdata_o   (m_axi_wdata_o),
    .m_axi_wstrb_o   (m_axi_wstrb_o),
    .m_axi_wlast_o   (m_axi_wlast_o),
    .m_axi_wvalid_o  (m_axi_wvalid_o),
    .m_axi_wready_i  (m_axi_wready_i),
    .m_axi_bvalid_i  (m_axi_bvalid_i),
    .m_axi_bready_o  (m_axi_bready_o)
  );

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // ---- BFM AXI4 chi-ghi (AW+W+B), non-outstanding - khop dung DUT chi 1 giao dich/lan ----
  // Mo phong DDR bang mang byte, khoi tao sentinel 8'hFF (khac 0) de phat hien duoc neu DUT
  // ghi thua ra ngoai vung hop le (test bien valid_rows/valid_cols < 32).
  localparam int DDR_BYTES = 65536;
  logic [7:0] ddr_mem [0:DDR_BYTES-1];

  typedef enum logic [1:0] {BFM_IDLE, BFM_W, BFM_B} bfm_state_e;
  bfm_state_e        bfm_state_q;
  logic [AWIDTH-1:0] bfm_addr_q;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      bfm_state_q     <= BFM_IDLE;
      m_axi_awready_i <= 1'b1;
      m_axi_wready_i  <= 1'b0;
      m_axi_bvalid_i  <= 1'b0;
    end else begin
      case (bfm_state_q)
        BFM_IDLE: begin
          m_axi_awready_i <= 1'b1;
          if (m_axi_awvalid_o && m_axi_awready_i) begin
            bfm_addr_q      <= m_axi_awaddr_o;
            m_axi_awready_i <= 1'b0;
            m_axi_wready_i  <= 1'b1;
            bfm_state_q     <= BFM_W;
          end
        end
        // [SUA - 2026-08-23] DUT gio gop toi da 32 beat/burst (1 hang tile) - phai lap nhan
        // tung beat, tu tang dia chi +4 sau moi beat (INCR), chi chuyen sang B khi thay
        // WLAST=1 o beat vua nhan (khop dung FSM ST_W moi cua axi4_c_writer.v).
        BFM_W: begin
          if (m_axi_wvalid_o && m_axi_wready_i) begin
            for (int b = 0; b < 4; b++)
              if (m_axi_wstrb_o[b]) ddr_mem[bfm_addr_q + b] <= m_axi_wdata_o[b*8 +: 8];
            if (m_axi_wlast_o) begin
              m_axi_wready_i <= 1'b0;
              m_axi_bvalid_i <= 1'b1;
              bfm_state_q    <= BFM_B;
            end else begin
              bfm_addr_q <= bfm_addr_q + 4;
            end
          end
        end
        BFM_B: begin
          if (m_axi_bvalid_i && m_axi_bready_o) begin
            m_axi_bvalid_i  <= 1'b0;
            m_axi_awready_i <= 1'b1;
            bfm_state_q     <= BFM_IDLE;
          end
        end
        default: bfm_state_q <= BFM_IDLE;
      endcase
    end
  end

  // Gan gia tri test cho 1 phan tu c_data_i[row][col].
  task automatic set_c_elem(input int row, input int col, input logic [31:0] val);
    c_data_i[(row * ARR_SIZE + col) * 32 +: 32] = val;
  endtask

  // [2026-08-23] Debug tam - chi con dung 1/1024 sai (ii=0,jj=0 cua lan ghi DAU TIEN trong ca
  // mo phong) - bam sat 40 cycle dau tien sau khi Test 1 pulse tile_valid_i, in trang thai
  // AW/W handshake + gia tri wdata_o + dia chi BFM moi cycle de xac dinh chinh xac dang mat o
  // dau (khong doan mo). Tat sau 40 cycle de khong lam log qua dai.
  int probe1_cyc_count = -1;
  always @(posedge clk_i) begin
    if (tile_valid_i && probe1_cyc_count == -1) probe1_cyc_count = 0;
    if (probe1_cyc_count >= 0 && probe1_cyc_count < 40) begin
      $display("[PROBE1] cyc=%0d state=%0d AW=%b/%b addr_o=%0h W=%b/%b WLAST=%b wdata=%0d bfm_addr=%0h bfm_state=%0d",
                probe1_cyc_count, dut.state_q,
                m_axi_awvalid_o, m_axi_awready_i, m_axi_awaddr_o,
                m_axi_wvalid_o, m_axi_wready_i, m_axi_wlast_o, m_axi_wdata_o,
                bfm_addr_q, bfm_state_q);
      probe1_cyc_count++;
    end
  end

  // Cho c_write_done_o len 1, co watchdog (1 tile toi da 32*32*3 ~ 3072 cycle giao dich AXI,
  // dat du du 20000 de an toan).
  task automatic wait_c_write_done(input string tag);
    automatic int cyc = 0;
    automatic bit timed_out = 1'b0;
    while (!c_write_done_o) begin
      @(posedge clk_i);
      #1; // triet tieu race condition voi always @(posedge clk_i) noi bo AXI4_C_WRITER/BFM
      cyc++;
      if (cyc >= 20_000) begin
        timed_out = 1'b1;
        break;
      end
    end
    if (timed_out) begin
      fail_count++;
      $display("[FAIL] %s: TIMEOUT cho c_write_done_o sau %0d cycle", tag, cyc);
    end else begin
      pass_count++;
      $display("[PASS] %s: c_write_done_o len 1 sau %0d cycle", tag, cyc);
    end
  endtask

  // Doi chieu 1 tile da ghi: dung cong thuc RTL that
  // addr = base + (i0+ii)*stride*4 + (j0+jj)*4, chi kiem tra ii<valid_rows && jj<valid_cols.
  // outside_sentinel: neu != 0, kiem tra them 1 vong bien ngay ngoai valid_rows/valid_cols
  // van con nguyen gia tri sentinel (khong bi ghi thua).
  task automatic verify_tile(input logic [AWIDTH-1:0] base, input logic [AWIDTH-1:0] stride,
                              input int i0, input int j0, input int valid_rows,
                              input int valid_cols, input string tag,
                              input bit check_no_overwrite);
    automatic int mismatch = 0;
    automatic int overwritten = 0;
    for (int ii = 0; ii < ARR_SIZE; ii++) begin
      for (int jj = 0; jj < ARR_SIZE; jj++) begin
        automatic logic [AWIDTH-1:0] addr = base + (i0 + ii) * stride * 4 + (j0 + jj) * 4;
        automatic logic [31:0] got = {ddr_mem[addr+3], ddr_mem[addr+2],
                                        ddr_mem[addr+1], ddr_mem[addr+0]};
        if (ii < valid_rows && jj < valid_cols) begin
          automatic logic [31:0] expected;
          expected = c_data_i[(ii * ARR_SIZE + jj) * 32 +: 32];
          if (got !== expected) begin
            mismatch++;
            if (mismatch <= 10)
              $display("[FAIL] %s: ii=%0d jj=%0d gia tri=%0d (ky vong %0d)",
                        tag, ii, jj, got, expected);
          end
        end else if (check_no_overwrite) begin
          if (got !== 32'hFFFFFFFF) begin
            overwritten++;
            if (overwritten <= 10)
              $display("[FAIL] %s: ii=%0d jj=%0d (ngoai valid_rows/cols) bi ghi thua = %0d",
                        tag, ii, jj, got);
          end
        end
      end
    end
    if (mismatch == 0 && overwritten == 0) begin
      pass_count++;
      $display("[PASS] %s: %0dx%0d phan tu hop le khop dung, khong ghi thua ra ngoai",
                tag, valid_rows, valid_cols);
    end else begin
      fail_count++;
      $display("[FAIL] %s: %0d gia tri sai, %0d o bi ghi thua", tag, mismatch, overwritten);
    end
  endtask

  initial begin
    clk_i          = 1'b0;
    rst_ni         = 1'b0;
    c_base_addr_i  = '0;
    c_row_stride_i = '0;
    c_global_i0_i  = '0;
    c_global_j0_i  = '0;
    c_valid_rows_i = '0;
    c_valid_cols_i = '0;
    tile_valid_i   = 1'b0;
    tile_done_i    = 1'b0;
    c_data_i       = '0;
    for (int i = 0; i < DDR_BYTES; i++) ddr_mem[i] = 8'hFF;

    repeat (5) @(posedge clk_i);
    #1;
    rst_ni = 1'b1;
    repeat (2) @(posedge clk_i);
    #1;

    // ---- Test 1: tile day du 32x32, i0=10, j0=20, stride=100, base=0x1000 ----
    for (int r = 0; r < ARR_SIZE; r++)
      for (int c = 0; c < ARR_SIZE; c++)
        set_c_elem(r, c, 32'(unsigned'(1000 + r * ARR_SIZE + c)) ^ 32'h5A5A0000);

    c_base_addr_i  = 32'h0000_1000;
    c_row_stride_i = 32'd100;
    c_global_i0_i  = 16'd10;
    c_global_j0_i  = 16'd20;
    c_valid_rows_i = 16'd32;
    c_valid_cols_i = 16'd32;

    tile_valid_i = 1'b1;
    @(posedge clk_i);
    #1;
    tile_done_i = 1'b1;
    @(posedge clk_i);
    #1;
    tile_done_i = 1'b0;

    wait_c_write_done("Test 1: tile day du 32x32");
    verify_tile(32'h0000_1000, 32'd100, 10, 20, 32, 32, "Test 1", 1'b0);

    // Ha tile_valid_i giua 2 tile (dung protocol that: mmult_accel ha tile_valid_o sau
    // tile_done_i, truoc khi bao tile ke tiep - xem comment ST_IDLE trong axi4_c_writer.v).
    tile_valid_i = 1'b0;
    @(posedge clk_i);
    #1;

    // ---- Test 2: tile bien (valid_rows=5, valid_cols=7 < 32), i0=0, j0=0, stride=50 ----
    // Xac nhan khong ghi thua ra ngoai vung hop le (ddr_mem van con sentinel 8'hFF).
    // [2026-08-18] Base 0x8000 (thay vi 0x2000 cu) - Test 1 (base=0x1000,i0=10,stride=100)
    // ghi rai rac theo stride LON (400 byte/hang), dau chan thuc te trai tu ~0x1FF0 den
    // ~0x50DC, DE LEN vung 0x2000 cu (gay FALSE FAIL: doc phai du lieu Test 1 de lai, tuong
    // nham la "ghi thua"). 0x8000 nam ngoai dau chan ca Test 1 (~0x50DC) lan Test 3
    // (0x3000..0x5FFC, xem duoi) - an toan, van trong DDR_BYTES=65536.
    for (int r = 0; r < ARR_SIZE; r++)
      for (int c = 0; c < ARR_SIZE; c++)
        set_c_elem(r, c, 32'(unsigned'(2000 + r * ARR_SIZE + c)));

    c_base_addr_i  = 32'h0000_8000;
    c_row_stride_i = 32'd50;
    c_global_i0_i  = 16'd0;
    c_global_j0_i  = 16'd0;
    c_valid_rows_i = 16'd5;
    c_valid_cols_i = 16'd7;

    // Xac nhan c_write_done_o tut ve 0 dung luc khi tile_valid_i len cho tile moi (khong giu
    // muc 1 tu tile truoc).
    tile_valid_i = 1'b1;
    @(posedge clk_i);
    #1;
    if (!c_write_done_o) begin
      pass_count++;
      $display("[PASS] Test 2: c_write_done_o tut ve 0 dung luc tile_valid_i len cho tile moi");
    end else begin
      fail_count++;
      $display("[FAIL] Test 2: c_write_done_o van con 1 sau khi tile_valid_i len cho tile moi");
    end

    tile_done_i = 1'b1;
    @(posedge clk_i);
    #1;
    tile_done_i = 1'b0;

    wait_c_write_done("Test 2: tile bien valid_rows=5 valid_cols=7");
    verify_tile(32'h0000_8000, 32'd50, 0, 0, 5, 7, "Test 2", 1'b1);

    tile_valid_i = 1'b0;
    @(posedge clk_i);
    #1;

    // ---- Test 3: nhieu tile lien tiep (doi i0/j0/du lieu moi lan) ----
    for (int t = 0; t < 3; t++) begin
      automatic int i0 = t * 32;
      automatic int j0 = 0;
      for (int r = 0; r < ARR_SIZE; r++)
        for (int c = 0; c < ARR_SIZE; c++)
          set_c_elem(r, c, 32'(unsigned'(3000 + t * 10000 + r * ARR_SIZE + c)));

      c_base_addr_i  = 32'h0000_3000;
      c_row_stride_i = 32'd32;
      c_global_i0_i  = i0[CNT_W-1:0];
      c_global_j0_i  = j0[CNT_W-1:0];
      c_valid_rows_i = 16'd32;
      c_valid_cols_i = 16'd32;

      tile_valid_i = 1'b1;
      @(posedge clk_i);
      #1;
      tile_done_i = 1'b1;
      @(posedge clk_i);
      #1;
      tile_done_i = 1'b0;

      wait_c_write_done($sformatf("Test 3: tile lien tiep #%0d", t));
      verify_tile(32'h0000_3000, 32'd32, i0, j0, 32, 32,
                   $sformatf("Test 3 tile #%0d", t), 1'b0);

      tile_valid_i = 1'b0;
      @(posedge clk_i);
      #1;
    end

    $display("========================================");
    $display("tb_axi4_c_writer: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_axi4_c_writer: ALL TESTS PASSED");
    else $display("tb_axi4_c_writer: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
