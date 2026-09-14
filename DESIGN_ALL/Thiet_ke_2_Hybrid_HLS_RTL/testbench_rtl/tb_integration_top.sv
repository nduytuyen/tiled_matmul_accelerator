`timescale 1ns / 1ps

// tb_integration_top.sv -- Stage 2 (docs/task.md muc E, checklist uu tien)
//
// Stage 1 (theo doi tile_ready_o cua SYSTOLIC_CORE_TOP mot minh) da PASS - loai tru nghi
// van #2 (handshake/reset). Stage 2 nay dung UNG cho nghi van #1: dung du 3 loai module
// that (mmult_accel RTL export tu HLS + SYSTOLIC_CORE_TOP + 96x DUAL_PORT_BRAM_8B), noi day
// dung nhu se noi trong Block Design that (xem docs/task.md muc "Boi canh"), roi dieu khien
// qua AXI4-Lite (s_axi_control) + AXI4 slave/memory gia lap cho gmemA/gmemB/gmemC.
//
// [SUA - 2026-08-18, SUA LAN 16] mmult_accel KHONG CON ghi C qua m_axi/c_arr nua (bo hoan
// toan sau 3 lan sua Vitis HLS deu that bai cho writeC/capture_c, xem docs/task.md muc SUA
// LAN 13-15 va 01_design/docs/modules/axi4_c_writer.md) - C gio duoc ghi boi AXI4_C_WRITER
// (RTL tu viet, src/axi4_c_writer.v), doc truc tiep c_o tu SYSTOLIC_CORE_TOP ngay luc
// tile_done_o. mmult_accel chi con xuat c_base_addr_o/c_row_stride_o/c_global_i0_o/
// c_global_j0_o/c_valid_rows_o/c_valid_cols_o + bat tay c_write_done_i voi AXI4_C_WRITER.
//
// [SUA - 2026-08-17, Huong B] mmult_accel KHONG CON doc A qua m_axi nua (bo hoan toan
// m_axi_gmemA + 64 tham so a_bank<n> sau 9 lan sua deu treo, xem docs/task.md muc C4/SUA LAN
// 10) - A gio duoc doc boi 1 module RTL rieng, tu viet: AXI4_A_READER (src/axi4_a_reader.v),
// AXI4 master CHI DOC (khong outstanding), ghi thang vao 64 bank A qua bus gop. mmult_accel chi
// con xuat dia chi A qua a_base_addr_o + bat tay a_reload_req_o/a_loaded_i voi AXI4_A_READER.
//
// [SUA - 2026-08-17, SUA LAN 12] Cung ly do/cach lam, mmult_accel KHONG CON doc B qua m_axi nua
// (bo hoan toan m_axi_gmemB + 32 tham so b_bank<n> - copy_B_block bi HLS lap lich chong lap voi
// tile_i, xem docs/task.md muc SUA LAN 12) - B gio duoc doc boi AXI4_B_READER (RTL tu viet,
// src/axi4_b_reader.v), doc lai MOI LAN doi j_block (K/do rong block runtime, khac A chi doc 1
// lan/call). mmult_accel chi con xuat b_base_addr_o/b_row_stride_o/b_num_rows_o/b_block_width_o
// + bat tay b_reload_req_o/b_loaded_i voi AXI4_B_READER.
//
// Test case: N=64, K=768 (BAT BUOC =768, tham so kien truc co dinh - xem
// interface_contract.md dong 8, K<768 se doc rac trong bank), M=64 (nho, 1 tile_j) -
// khop bench/golden_model.py case "case_integration". 2 tile_i (i0=0,32) x 1 tile_j (j0=0).
//
// Port list cua mmult_accel/SYSTOLIC_CORE_TOP duoc SINH TU DONG bang script Python doc truc
// tiep file RTL that (khong go tay) - xem
// AppData/.../scratchpad/gen_tb_integration_stage2*.py (khong commit vao repo, chi de tham
// khao lai cach sinh neu can lam lai). Ban noi day thu cong duy nhat la 96 instance
// DUAL_PORT_BRAM_8B (ten port khong duy nhat giua cac instance nen khong dung `.*` duoc) va
// 1024+5 dong "assign" cau noi giua cac cap port cung y nghia nhung khac ten
// (vd tile_valid_o cua mmult_accel <-> tile_valid_i cua SYSTOLIC_CORE_TOP).
module tb_integration_top;

  // ---- Tham so test case (case_integration, khop golden_model.py) ----
  localparam int TEST_N = 64;
  localparam int TEST_K = 768;
  localparam int TEST_M = 64;
  localparam int MAX_N  = 64;

  // ---- Dia chi thanh ghi AXI4-Lite (tu xmmult_accel_hw.h, da xac nhan dung) ----
  // [SUA - 2026-08-18, SUA LAN 16] C_addr gio cung la 1 thanh ghi 32-bit duy nhat (giong
  // A_addr/B_addr, khong con LO/HI 64-bit) - keo theo N/K/M/update_A dich dia chi xuong 4
  // byte moi thanh ghi so voi ban truoc. Xem xmmult_accel_hw.h da re-export sau SUA LAN 16.
  localparam logic [6:0] REG_AP_CTRL   = 7'h00;
  localparam logic [6:0] REG_A_ADDR    = 7'h10;
  localparam logic [6:0] REG_B_ADDR    = 7'h18;
  localparam logic [6:0] REG_C_ADDR    = 7'h20;
  localparam logic [6:0] REG_N         = 7'h28;
  localparam logic [6:0] REG_K         = 7'h30;
  localparam logic [6:0] REG_M         = 7'h38;
  localparam logic [6:0] REG_UPDATE_A  = 7'h40;

  // Watchdog: uoc luong ~100k-150k cycle can thiet that (copy_A_banks ~49152 cycle doc AXI +
  // copy_B_block ~49152+6144 cycle + 2 tile compute ~833*2 cycle + chi phi AXI). Dat du du de
  // khong bao PASS gia neu cham nhung van dung, nhung van huu han de bat duoc treo that.
  // [SUA - 2026-08-17, theo task Design "pivot Huong B"] Giam tu 1_000_000 -> 100_000: toan bo
  // lich su debug (SUA LAN 1-9) xac nhan neu treo, luon treo trong khoang cycle ~40.000-50.000
  // (doc xong A roi ket truoc khi vao B) - 100_000 du gap doi bien do quan sat duoc, giam ~10 lan
  // thoi gian cho moi lan chay chan doan that bai.
  // [SUA - 2026-08-17, SUA LAN 12, chay Stage 2 lan 3] 100_000 KHONG CON DU - log that xac nhan
  // A_reader xong dung luc (~cyc 51500), B_reader chay dung, KHONG treo, nhung tai cyc=100000
  // moi doc duoc ~661/768 hang (~86%, ~73 cycle/hang do B_READER can 8 chu ky ghi/hang thay vi 1
  // nhu A) - can them ~8000-10000 cycle nua moi xong B, cong them 2 tile compute+writeC+AXI-Lite
  // overhead. Tang len 200_000 (van gap ~2x uoc luong can thiet ~110k, du an toan, van nhanh hon
  // nhieu so voi 1_000_000 cu).
  localparam int WATCHDOG_CYCLES = 200_000;
  localparam int POLL_INTERVAL   = 500;

  logic clk_i;
  logic rst_ni;
  logic ap_clk;
  logic ap_rst_n;
  assign ap_clk   = clk_i;
  assign ap_rst_n = rst_ni;

  // ---- Tin hieu trung ten port mmult_accel (sinh tu dong, xem ghi chu tren) ----
  // [SUA - 2026-08-17, Huong B] 3 port moi cua mmult_accel (thay the m_axi_gmemA/64 a_bank<n>) -
  // PHAI khai bao tuong minh du rong dung (khong de `.*` tu suy - neu khong se bi khai bao ngam
  // thanh wire 1-bit mac dinh khi dung trong 'assign' o duoi, gay sai/cat cut dia chi 32-bit).
  logic [31:0] a_base_addr_o;
  logic        a_reload_req_o;
  logic        a_loaded_i;
  // [SUA - 2026-08-17, SUA LAN 12] 6 port moi cua mmult_accel (thay the m_axi_gmemB/32
  // b_bank<n>) - cung ly do PHAI khai bao tuong minh du rong dung nhu a_base_addr_o o tren.
  logic [31:0] b_base_addr_o;
  logic [31:0] b_row_stride_o;
  logic [15:0] b_num_rows_o;
  logic [15:0] b_block_width_o;
  logic        b_reload_req_o;
  logic        b_loaded_i;

  // ---- Tin hieu AXI4_A_READER (Huong B - thay the hoan toan m_axi_gmemA cua mmult_accel) ----
  // Bat tay voi mmult_accel (ten khac nhau ca 2 phia - can 'assign' cau noi, xem cuoi khoi nay).
  logic [31:0] a_base_addr_i;
  logic        a_reload_req_i;
  logic        a_loaded_o;
  // AXI4 master CHI DOC cua AXI4_A_READER (khong AW/W/B, khong ID/LOCK/CACHE/PROT/QOS/REGION/
  // USER - module tu viet don gian hon nhieu so voi bundle HLS tu sinh cho gmemB/gmemC).
  logic [31:0] m_axi_araddr_o;
  logic [7:0]  m_axi_arlen_o;
  logic [2:0]  m_axi_arsize_o;
  logic [1:0]  m_axi_arburst_o;
  logic        m_axi_arvalid_o;
  logic        m_axi_arready_i;
  // [SUA - 2026-08-21] AXI4_A_READER doc 32-bit/beat (4 byte/beat) - xem
  // 01_design/docs/modules/axi4_a_reader.md muc "SUA - 2026-08-21".
  logic [31:0] m_axi_rdata_i;
  logic        m_axi_rvalid_i;
  logic        m_axi_rlast_i;
  logic        m_axi_rready_o;
  // Bus gop ghi 64 bank A (tach bit khi noi vao 64 khoi DUAL_PORT_BRAM_8B ben duoi).
  logic [9:0] bank0_addr_o;
  logic       bank0_en_o;
  logic       bank0_we_o;
  logic [7:0] bank0_din_o;
  logic [9:0] bank1_addr_o;
  logic       bank1_en_o;
  logic       bank1_we_o;
  logic [7:0] bank1_din_o;
  logic [9:0] bank2_addr_o;
  logic       bank2_en_o;
  logic       bank2_we_o;
  logic [7:0] bank2_din_o;
  logic [9:0] bank3_addr_o;
  logic       bank3_en_o;
  logic       bank3_we_o;
  logic [7:0] bank3_din_o;
  logic [9:0] bank4_addr_o;
  logic       bank4_en_o;
  logic       bank4_we_o;
  logic [7:0] bank4_din_o;
  logic [9:0] bank5_addr_o;
  logic       bank5_en_o;
  logic       bank5_we_o;
  logic [7:0] bank5_din_o;
  logic [9:0] bank6_addr_o;
  logic       bank6_en_o;
  logic       bank6_we_o;
  logic [7:0] bank6_din_o;
  logic [9:0] bank7_addr_o;
  logic       bank7_en_o;
  logic       bank7_we_o;
  logic [7:0] bank7_din_o;
  logic [9:0] bank8_addr_o;
  logic       bank8_en_o;
  logic       bank8_we_o;
  logic [7:0] bank8_din_o;
  logic [9:0] bank9_addr_o;
  logic       bank9_en_o;
  logic       bank9_we_o;
  logic [7:0] bank9_din_o;
  logic [9:0] bank10_addr_o;
  logic       bank10_en_o;
  logic       bank10_we_o;
  logic [7:0] bank10_din_o;
  logic [9:0] bank11_addr_o;
  logic       bank11_en_o;
  logic       bank11_we_o;
  logic [7:0] bank11_din_o;
  logic [9:0] bank12_addr_o;
  logic       bank12_en_o;
  logic       bank12_we_o;
  logic [7:0] bank12_din_o;
  logic [9:0] bank13_addr_o;
  logic       bank13_en_o;
  logic       bank13_we_o;
  logic [7:0] bank13_din_o;
  logic [9:0] bank14_addr_o;
  logic       bank14_en_o;
  logic       bank14_we_o;
  logic [7:0] bank14_din_o;
  logic [9:0] bank15_addr_o;
  logic       bank15_en_o;
  logic       bank15_we_o;
  logic [7:0] bank15_din_o;
  logic [9:0] bank16_addr_o;
  logic       bank16_en_o;
  logic       bank16_we_o;
  logic [7:0] bank16_din_o;
  logic [9:0] bank17_addr_o;
  logic       bank17_en_o;
  logic       bank17_we_o;
  logic [7:0] bank17_din_o;
  logic [9:0] bank18_addr_o;
  logic       bank18_en_o;
  logic       bank18_we_o;
  logic [7:0] bank18_din_o;
  logic [9:0] bank19_addr_o;
  logic       bank19_en_o;
  logic       bank19_we_o;
  logic [7:0] bank19_din_o;
  logic [9:0] bank20_addr_o;
  logic       bank20_en_o;
  logic       bank20_we_o;
  logic [7:0] bank20_din_o;
  logic [9:0] bank21_addr_o;
  logic       bank21_en_o;
  logic       bank21_we_o;
  logic [7:0] bank21_din_o;
  logic [9:0] bank22_addr_o;
  logic       bank22_en_o;
  logic       bank22_we_o;
  logic [7:0] bank22_din_o;
  logic [9:0] bank23_addr_o;
  logic       bank23_en_o;
  logic       bank23_we_o;
  logic [7:0] bank23_din_o;
  logic [9:0] bank24_addr_o;
  logic       bank24_en_o;
  logic       bank24_we_o;
  logic [7:0] bank24_din_o;
  logic [9:0] bank25_addr_o;
  logic       bank25_en_o;
  logic       bank25_we_o;
  logic [7:0] bank25_din_o;
  logic [9:0] bank26_addr_o;
  logic       bank26_en_o;
  logic       bank26_we_o;
  logic [7:0] bank26_din_o;
  logic [9:0] bank27_addr_o;
  logic       bank27_en_o;
  logic       bank27_we_o;
  logic [7:0] bank27_din_o;
  logic [9:0] bank28_addr_o;
  logic       bank28_en_o;
  logic       bank28_we_o;
  logic [7:0] bank28_din_o;
  logic [9:0] bank29_addr_o;
  logic       bank29_en_o;
  logic       bank29_we_o;
  logic [7:0] bank29_din_o;
  logic [9:0] bank30_addr_o;
  logic       bank30_en_o;
  logic       bank30_we_o;
  logic [7:0] bank30_din_o;
  logic [9:0] bank31_addr_o;
  logic       bank31_en_o;
  logic       bank31_we_o;
  logic [7:0] bank31_din_o;
  logic [9:0] bank32_addr_o;
  logic       bank32_en_o;
  logic       bank32_we_o;
  logic [7:0] bank32_din_o;
  logic [9:0] bank33_addr_o;
  logic       bank33_en_o;
  logic       bank33_we_o;
  logic [7:0] bank33_din_o;
  logic [9:0] bank34_addr_o;
  logic       bank34_en_o;
  logic       bank34_we_o;
  logic [7:0] bank34_din_o;
  logic [9:0] bank35_addr_o;
  logic       bank35_en_o;
  logic       bank35_we_o;
  logic [7:0] bank35_din_o;
  logic [9:0] bank36_addr_o;
  logic       bank36_en_o;
  logic       bank36_we_o;
  logic [7:0] bank36_din_o;
  logic [9:0] bank37_addr_o;
  logic       bank37_en_o;
  logic       bank37_we_o;
  logic [7:0] bank37_din_o;
  logic [9:0] bank38_addr_o;
  logic       bank38_en_o;
  logic       bank38_we_o;
  logic [7:0] bank38_din_o;
  logic [9:0] bank39_addr_o;
  logic       bank39_en_o;
  logic       bank39_we_o;
  logic [7:0] bank39_din_o;
  logic [9:0] bank40_addr_o;
  logic       bank40_en_o;
  logic       bank40_we_o;
  logic [7:0] bank40_din_o;
  logic [9:0] bank41_addr_o;
  logic       bank41_en_o;
  logic       bank41_we_o;
  logic [7:0] bank41_din_o;
  logic [9:0] bank42_addr_o;
  logic       bank42_en_o;
  logic       bank42_we_o;
  logic [7:0] bank42_din_o;
  logic [9:0] bank43_addr_o;
  logic       bank43_en_o;
  logic       bank43_we_o;
  logic [7:0] bank43_din_o;
  logic [9:0] bank44_addr_o;
  logic       bank44_en_o;
  logic       bank44_we_o;
  logic [7:0] bank44_din_o;
  logic [9:0] bank45_addr_o;
  logic       bank45_en_o;
  logic       bank45_we_o;
  logic [7:0] bank45_din_o;
  logic [9:0] bank46_addr_o;
  logic       bank46_en_o;
  logic       bank46_we_o;
  logic [7:0] bank46_din_o;
  logic [9:0] bank47_addr_o;
  logic       bank47_en_o;
  logic       bank47_we_o;
  logic [7:0] bank47_din_o;
  logic [9:0] bank48_addr_o;
  logic       bank48_en_o;
  logic       bank48_we_o;
  logic [7:0] bank48_din_o;
  logic [9:0] bank49_addr_o;
  logic       bank49_en_o;
  logic       bank49_we_o;
  logic [7:0] bank49_din_o;
  logic [9:0] bank50_addr_o;
  logic       bank50_en_o;
  logic       bank50_we_o;
  logic [7:0] bank50_din_o;
  logic [9:0] bank51_addr_o;
  logic       bank51_en_o;
  logic       bank51_we_o;
  logic [7:0] bank51_din_o;
  logic [9:0] bank52_addr_o;
  logic       bank52_en_o;
  logic       bank52_we_o;
  logic [7:0] bank52_din_o;
  logic [9:0] bank53_addr_o;
  logic       bank53_en_o;
  logic       bank53_we_o;
  logic [7:0] bank53_din_o;
  logic [9:0] bank54_addr_o;
  logic       bank54_en_o;
  logic       bank54_we_o;
  logic [7:0] bank54_din_o;
  logic [9:0] bank55_addr_o;
  logic       bank55_en_o;
  logic       bank55_we_o;
  logic [7:0] bank55_din_o;
  logic [9:0] bank56_addr_o;
  logic       bank56_en_o;
  logic       bank56_we_o;
  logic [7:0] bank56_din_o;
  logic [9:0] bank57_addr_o;
  logic       bank57_en_o;
  logic       bank57_we_o;
  logic [7:0] bank57_din_o;
  logic [9:0] bank58_addr_o;
  logic       bank58_en_o;
  logic       bank58_we_o;
  logic [7:0] bank58_din_o;
  logic [9:0] bank59_addr_o;
  logic       bank59_en_o;
  logic       bank59_we_o;
  logic [7:0] bank59_din_o;
  logic [9:0] bank60_addr_o;
  logic       bank60_en_o;
  logic       bank60_we_o;
  logic [7:0] bank60_din_o;
  logic [9:0] bank61_addr_o;
  logic       bank61_en_o;
  logic       bank61_we_o;
  logic [7:0] bank61_din_o;
  logic [9:0] bank62_addr_o;
  logic       bank62_en_o;
  logic       bank62_we_o;
  logic [7:0] bank62_din_o;
  logic [9:0] bank63_addr_o;
  logic       bank63_en_o;
  logic       bank63_we_o;
  logic [7:0] bank63_din_o;
  // ---- Tin hieu AXI4_B_READER (SUA LAN 12 - thay the hoan toan m_axi_gmemB cua mmult_accel) ----
  // Bat tay voi mmult_accel (ten khac nhau ca 2 phia - can 'assign' cau noi).
  logic [31:0] b_base_addr_i;
  logic [31:0] b_row_stride_i;
  logic [9:0]  b_num_rows_i;    // ROW_CNT_W=10 ($clog2(768))
  logic [8:0]  b_block_width_i; // WIDTH_CNT_W=9 (0..256)
  logic        b_loaded_o;
  // AXI4 master CHI DOC cua AXI4_B_READER - CHU Y: cung ten port voi AXI4_A_READER
  // (m_axi_araddr_o/bank_addr_o/...) nen KHONG dung `.*` duoc cho instance nay (se dinh
  // nham voi tin hieu cua AXI4_A_READER da khai bao o tren) - phai khai bao rieng tien to
  // "b_" + noi tuong minh khi instantiate (xem duoi).
  logic [31:0] b_m_axi_araddr_o;
  logic [7:0]  b_m_axi_arlen_o;
  logic [2:0]  b_m_axi_arsize_o;
  logic [1:0]  b_m_axi_arburst_o;
  logic        b_m_axi_arvalid_o;
  logic        b_m_axi_arready_i;
  // [SUA - 2026-08-21] AXI4_B_READER doc 32-bit/beat (4 byte/beat) - xem
  // 01_design/docs/modules/axi4_b_reader.md muc "SUA - 2026-08-21".
  logic [31:0] b_m_axi_rdata_i;
  logic        b_m_axi_rvalid_i;
  logic        b_m_axi_rlast_i;
  logic        b_m_axi_rready_o;
  // Bus gop ghi 32 bank B (tach bit khi noi vao 32 khoi DUAL_PORT_BRAM_8B ben duoi).
  logic [12:0] b_bank0_addr_o;
  logic        b_bank0_en_o;
  logic        b_bank0_we_o;
  logic [7:0]  b_bank0_din_o;
  logic [12:0] b_bank1_addr_o;
  logic        b_bank1_en_o;
  logic        b_bank1_we_o;
  logic [7:0]  b_bank1_din_o;
  logic [12:0] b_bank2_addr_o;
  logic        b_bank2_en_o;
  logic        b_bank2_we_o;
  logic [7:0]  b_bank2_din_o;
  logic [12:0] b_bank3_addr_o;
  logic        b_bank3_en_o;
  logic        b_bank3_we_o;
  logic [7:0]  b_bank3_din_o;
  logic [12:0] b_bank4_addr_o;
  logic        b_bank4_en_o;
  logic        b_bank4_we_o;
  logic [7:0]  b_bank4_din_o;
  logic [12:0] b_bank5_addr_o;
  logic        b_bank5_en_o;
  logic        b_bank5_we_o;
  logic [7:0]  b_bank5_din_o;
  logic [12:0] b_bank6_addr_o;
  logic        b_bank6_en_o;
  logic        b_bank6_we_o;
  logic [7:0]  b_bank6_din_o;
  logic [12:0] b_bank7_addr_o;
  logic        b_bank7_en_o;
  logic        b_bank7_we_o;
  logic [7:0]  b_bank7_din_o;
  logic [12:0] b_bank8_addr_o;
  logic        b_bank8_en_o;
  logic        b_bank8_we_o;
  logic [7:0]  b_bank8_din_o;
  logic [12:0] b_bank9_addr_o;
  logic        b_bank9_en_o;
  logic        b_bank9_we_o;
  logic [7:0]  b_bank9_din_o;
  logic [12:0] b_bank10_addr_o;
  logic        b_bank10_en_o;
  logic        b_bank10_we_o;
  logic [7:0]  b_bank10_din_o;
  logic [12:0] b_bank11_addr_o;
  logic        b_bank11_en_o;
  logic        b_bank11_we_o;
  logic [7:0]  b_bank11_din_o;
  logic [12:0] b_bank12_addr_o;
  logic        b_bank12_en_o;
  logic        b_bank12_we_o;
  logic [7:0]  b_bank12_din_o;
  logic [12:0] b_bank13_addr_o;
  logic        b_bank13_en_o;
  logic        b_bank13_we_o;
  logic [7:0]  b_bank13_din_o;
  logic [12:0] b_bank14_addr_o;
  logic        b_bank14_en_o;
  logic        b_bank14_we_o;
  logic [7:0]  b_bank14_din_o;
  logic [12:0] b_bank15_addr_o;
  logic        b_bank15_en_o;
  logic        b_bank15_we_o;
  logic [7:0]  b_bank15_din_o;
  logic [12:0] b_bank16_addr_o;
  logic        b_bank16_en_o;
  logic        b_bank16_we_o;
  logic [7:0]  b_bank16_din_o;
  logic [12:0] b_bank17_addr_o;
  logic        b_bank17_en_o;
  logic        b_bank17_we_o;
  logic [7:0]  b_bank17_din_o;
  logic [12:0] b_bank18_addr_o;
  logic        b_bank18_en_o;
  logic        b_bank18_we_o;
  logic [7:0]  b_bank18_din_o;
  logic [12:0] b_bank19_addr_o;
  logic        b_bank19_en_o;
  logic        b_bank19_we_o;
  logic [7:0]  b_bank19_din_o;
  logic [12:0] b_bank20_addr_o;
  logic        b_bank20_en_o;
  logic        b_bank20_we_o;
  logic [7:0]  b_bank20_din_o;
  logic [12:0] b_bank21_addr_o;
  logic        b_bank21_en_o;
  logic        b_bank21_we_o;
  logic [7:0]  b_bank21_din_o;
  logic [12:0] b_bank22_addr_o;
  logic        b_bank22_en_o;
  logic        b_bank22_we_o;
  logic [7:0]  b_bank22_din_o;
  logic [12:0] b_bank23_addr_o;
  logic        b_bank23_en_o;
  logic        b_bank23_we_o;
  logic [7:0]  b_bank23_din_o;
  logic [12:0] b_bank24_addr_o;
  logic        b_bank24_en_o;
  logic        b_bank24_we_o;
  logic [7:0]  b_bank24_din_o;
  logic [12:0] b_bank25_addr_o;
  logic        b_bank25_en_o;
  logic        b_bank25_we_o;
  logic [7:0]  b_bank25_din_o;
  logic [12:0] b_bank26_addr_o;
  logic        b_bank26_en_o;
  logic        b_bank26_we_o;
  logic [7:0]  b_bank26_din_o;
  logic [12:0] b_bank27_addr_o;
  logic        b_bank27_en_o;
  logic        b_bank27_we_o;
  logic [7:0]  b_bank27_din_o;
  logic [12:0] b_bank28_addr_o;
  logic        b_bank28_en_o;
  logic        b_bank28_we_o;
  logic [7:0]  b_bank28_din_o;
  logic [12:0] b_bank29_addr_o;
  logic        b_bank29_en_o;
  logic        b_bank29_we_o;
  logic [7:0]  b_bank29_din_o;
  logic [12:0] b_bank30_addr_o;
  logic        b_bank30_en_o;
  logic        b_bank30_we_o;
  logic [7:0]  b_bank30_din_o;
  logic [12:0] b_bank31_addr_o;
  logic        b_bank31_en_o;
  logic        b_bank31_we_o;
  logic [7:0]  b_bank31_din_o;
  // ---- Tin hieu mmult_accel <-> AXI4_C_WRITER (SUA LAN 16, 2026-08-18 - thay the hoan toan
  // m_axi_gmemC/c_arr cua mmult_accel cu, xem 01_design/docs/modules/axi4_c_writer.md) ----
  // Phia mmult_accel (port ten "_o"/"c_write_done_i", bind qua `.*` tren dut_mmult).
  logic [31:0] c_base_addr_o;
  logic [31:0] c_row_stride_o;
  logic [15:0] c_global_i0_o;
  logic [15:0] c_global_j0_o;
  logic [15:0] c_valid_rows_o;
  logic [15:0] c_valid_cols_o;
  logic        c_write_done_i;
  // Phia AXI4_C_WRITER (port ten "_i"/"c_write_done_o", bind qua `.*` tren dut_axi4_c_writer).
  // Ten khac nhau ca 2 phia nen can cau noi tuong minh (xem cac dong `assign` canh instance).
  logic [31:0] c_base_addr_i;
  logic [31:0] c_row_stride_i;
  logic [15:0] c_global_i0_i;
  logic [15:0] c_global_j0_i;
  logic [15:0] c_valid_rows_i;
  logic [15:0] c_valid_cols_i;
  logic        c_write_done_o;
  // [SUA - 2026-08-21] AXI4_C_WRITER doi tu 1 cong bus "c_data_i" sang 1024 cong scalar
  // rieng "c<row>_<col>_i" (cung ly do bit-select voi bank<n>_* ben duoi) - xem 1024 khai
  // bao + assign ngay truoc khoi instantiate AXI4_C_WRITER phia duoi.
  // AXI4 master CHI GHI cua AXI4_C_WRITER (khong AR/R, khong ID/LOCK/CACHE/PROT/QOS/REGION/
  // USER - module tu viet don gian hon nhieu so voi bundle HLS tu sinh cho gmemC cu).
  logic [31:0] m_axi_awaddr_o;
  logic [7:0]  m_axi_awlen_o;
  logic [2:0]  m_axi_awsize_o;
  logic [1:0]  m_axi_awburst_o;
  logic        m_axi_awvalid_o;
  logic        m_axi_awready_i;
  logic [31:0] m_axi_wdata_o;
  logic [3:0]  m_axi_wstrb_o;
  logic        m_axi_wlast_o;
  logic        m_axi_wvalid_o;
  logic        m_axi_wready_i;
  logic        m_axi_bvalid_i;
  logic        m_axi_bready_o;
  // [SUA - 2026-08-17, Huong B] Da xoa toan bo khai bao a_bank<n>_* (448 dong) - khong
  // con la port cua mmult_accel nua (chuyen sang AXI4_A_READER, dung bus_addr_o/en_o/we_o/
  // din_o o tren). Ket noi Cong A cua 64 khoi DUAL_PORT_BRAM_8B (dpb_a<n>) da doi sang lay
  // truc tiep tu bus do, xem duoi.
  logic [0:0] tile_i_sel_o;
  // [SUA - 2026-08-17, SUA LAN 12] Da xoa toan bo khai bao b_bank<n>_* (224 dong) - khong
  // con la port cua mmult_accel nua (chuyen sang AXI4_B_READER, dung b_bank_addr_o/en_o/we_o/
  // din_o o tren). Ket noi Cong A cua 32 khoi DUAL_PORT_BRAM_8B (dpb_b<n>) da doi sang lay
  // truc tiep tu bus do, xem duoi.
  logic [2:0] tile_j_sel_o;
  logic [31:0] c_arr_0_0;
  logic [31:0] c_arr_0_1;
  logic [31:0] c_arr_0_2;
  logic [31:0] c_arr_0_3;
  logic [31:0] c_arr_0_4;
  logic [31:0] c_arr_0_5;
  logic [31:0] c_arr_0_6;
  logic [31:0] c_arr_0_7;
  logic [31:0] c_arr_0_8;
  logic [31:0] c_arr_0_9;
  logic [31:0] c_arr_0_10;
  logic [31:0] c_arr_0_11;
  logic [31:0] c_arr_0_12;
  logic [31:0] c_arr_0_13;
  logic [31:0] c_arr_0_14;
  logic [31:0] c_arr_0_15;
  logic [31:0] c_arr_0_16;
  logic [31:0] c_arr_0_17;
  logic [31:0] c_arr_0_18;
  logic [31:0] c_arr_0_19;
  logic [31:0] c_arr_0_20;
  logic [31:0] c_arr_0_21;
  logic [31:0] c_arr_0_22;
  logic [31:0] c_arr_0_23;
  logic [31:0] c_arr_0_24;
  logic [31:0] c_arr_0_25;
  logic [31:0] c_arr_0_26;
  logic [31:0] c_arr_0_27;
  logic [31:0] c_arr_0_28;
  logic [31:0] c_arr_0_29;
  logic [31:0] c_arr_0_30;
  logic [31:0] c_arr_0_31;
  logic [31:0] c_arr_1_0;
  logic [31:0] c_arr_1_1;
  logic [31:0] c_arr_1_2;
  logic [31:0] c_arr_1_3;
  logic [31:0] c_arr_1_4;
  logic [31:0] c_arr_1_5;
  logic [31:0] c_arr_1_6;
  logic [31:0] c_arr_1_7;
  logic [31:0] c_arr_1_8;
  logic [31:0] c_arr_1_9;
  logic [31:0] c_arr_1_10;
  logic [31:0] c_arr_1_11;
  logic [31:0] c_arr_1_12;
  logic [31:0] c_arr_1_13;
  logic [31:0] c_arr_1_14;
  logic [31:0] c_arr_1_15;
  logic [31:0] c_arr_1_16;
  logic [31:0] c_arr_1_17;
  logic [31:0] c_arr_1_18;
  logic [31:0] c_arr_1_19;
  logic [31:0] c_arr_1_20;
  logic [31:0] c_arr_1_21;
  logic [31:0] c_arr_1_22;
  logic [31:0] c_arr_1_23;
  logic [31:0] c_arr_1_24;
  logic [31:0] c_arr_1_25;
  logic [31:0] c_arr_1_26;
  logic [31:0] c_arr_1_27;
  logic [31:0] c_arr_1_28;
  logic [31:0] c_arr_1_29;
  logic [31:0] c_arr_1_30;
  logic [31:0] c_arr_1_31;
  logic [31:0] c_arr_2_0;
  logic [31:0] c_arr_2_1;
  logic [31:0] c_arr_2_2;
  logic [31:0] c_arr_2_3;
  logic [31:0] c_arr_2_4;
  logic [31:0] c_arr_2_5;
  logic [31:0] c_arr_2_6;
  logic [31:0] c_arr_2_7;
  logic [31:0] c_arr_2_8;
  logic [31:0] c_arr_2_9;
  logic [31:0] c_arr_2_10;
  logic [31:0] c_arr_2_11;
  logic [31:0] c_arr_2_12;
  logic [31:0] c_arr_2_13;
  logic [31:0] c_arr_2_14;
  logic [31:0] c_arr_2_15;
  logic [31:0] c_arr_2_16;
  logic [31:0] c_arr_2_17;
  logic [31:0] c_arr_2_18;
  logic [31:0] c_arr_2_19;
  logic [31:0] c_arr_2_20;
  logic [31:0] c_arr_2_21;
  logic [31:0] c_arr_2_22;
  logic [31:0] c_arr_2_23;
  logic [31:0] c_arr_2_24;
  logic [31:0] c_arr_2_25;
  logic [31:0] c_arr_2_26;
  logic [31:0] c_arr_2_27;
  logic [31:0] c_arr_2_28;
  logic [31:0] c_arr_2_29;
  logic [31:0] c_arr_2_30;
  logic [31:0] c_arr_2_31;
  logic [31:0] c_arr_3_0;
  logic [31:0] c_arr_3_1;
  logic [31:0] c_arr_3_2;
  logic [31:0] c_arr_3_3;
  logic [31:0] c_arr_3_4;
  logic [31:0] c_arr_3_5;
  logic [31:0] c_arr_3_6;
  logic [31:0] c_arr_3_7;
  logic [31:0] c_arr_3_8;
  logic [31:0] c_arr_3_9;
  logic [31:0] c_arr_3_10;
  logic [31:0] c_arr_3_11;
  logic [31:0] c_arr_3_12;
  logic [31:0] c_arr_3_13;
  logic [31:0] c_arr_3_14;
  logic [31:0] c_arr_3_15;
  logic [31:0] c_arr_3_16;
  logic [31:0] c_arr_3_17;
  logic [31:0] c_arr_3_18;
  logic [31:0] c_arr_3_19;
  logic [31:0] c_arr_3_20;
  logic [31:0] c_arr_3_21;
  logic [31:0] c_arr_3_22;
  logic [31:0] c_arr_3_23;
  logic [31:0] c_arr_3_24;
  logic [31:0] c_arr_3_25;
  logic [31:0] c_arr_3_26;
  logic [31:0] c_arr_3_27;
  logic [31:0] c_arr_3_28;
  logic [31:0] c_arr_3_29;
  logic [31:0] c_arr_3_30;
  logic [31:0] c_arr_3_31;
  logic [31:0] c_arr_4_0;
  logic [31:0] c_arr_4_1;
  logic [31:0] c_arr_4_2;
  logic [31:0] c_arr_4_3;
  logic [31:0] c_arr_4_4;
  logic [31:0] c_arr_4_5;
  logic [31:0] c_arr_4_6;
  logic [31:0] c_arr_4_7;
  logic [31:0] c_arr_4_8;
  logic [31:0] c_arr_4_9;
  logic [31:0] c_arr_4_10;
  logic [31:0] c_arr_4_11;
  logic [31:0] c_arr_4_12;
  logic [31:0] c_arr_4_13;
  logic [31:0] c_arr_4_14;
  logic [31:0] c_arr_4_15;
  logic [31:0] c_arr_4_16;
  logic [31:0] c_arr_4_17;
  logic [31:0] c_arr_4_18;
  logic [31:0] c_arr_4_19;
  logic [31:0] c_arr_4_20;
  logic [31:0] c_arr_4_21;
  logic [31:0] c_arr_4_22;
  logic [31:0] c_arr_4_23;
  logic [31:0] c_arr_4_24;
  logic [31:0] c_arr_4_25;
  logic [31:0] c_arr_4_26;
  logic [31:0] c_arr_4_27;
  logic [31:0] c_arr_4_28;
  logic [31:0] c_arr_4_29;
  logic [31:0] c_arr_4_30;
  logic [31:0] c_arr_4_31;
  logic [31:0] c_arr_5_0;
  logic [31:0] c_arr_5_1;
  logic [31:0] c_arr_5_2;
  logic [31:0] c_arr_5_3;
  logic [31:0] c_arr_5_4;
  logic [31:0] c_arr_5_5;
  logic [31:0] c_arr_5_6;
  logic [31:0] c_arr_5_7;
  logic [31:0] c_arr_5_8;
  logic [31:0] c_arr_5_9;
  logic [31:0] c_arr_5_10;
  logic [31:0] c_arr_5_11;
  logic [31:0] c_arr_5_12;
  logic [31:0] c_arr_5_13;
  logic [31:0] c_arr_5_14;
  logic [31:0] c_arr_5_15;
  logic [31:0] c_arr_5_16;
  logic [31:0] c_arr_5_17;
  logic [31:0] c_arr_5_18;
  logic [31:0] c_arr_5_19;
  logic [31:0] c_arr_5_20;
  logic [31:0] c_arr_5_21;
  logic [31:0] c_arr_5_22;
  logic [31:0] c_arr_5_23;
  logic [31:0] c_arr_5_24;
  logic [31:0] c_arr_5_25;
  logic [31:0] c_arr_5_26;
  logic [31:0] c_arr_5_27;
  logic [31:0] c_arr_5_28;
  logic [31:0] c_arr_5_29;
  logic [31:0] c_arr_5_30;
  logic [31:0] c_arr_5_31;
  logic [31:0] c_arr_6_0;
  logic [31:0] c_arr_6_1;
  logic [31:0] c_arr_6_2;
  logic [31:0] c_arr_6_3;
  logic [31:0] c_arr_6_4;
  logic [31:0] c_arr_6_5;
  logic [31:0] c_arr_6_6;
  logic [31:0] c_arr_6_7;
  logic [31:0] c_arr_6_8;
  logic [31:0] c_arr_6_9;
  logic [31:0] c_arr_6_10;
  logic [31:0] c_arr_6_11;
  logic [31:0] c_arr_6_12;
  logic [31:0] c_arr_6_13;
  logic [31:0] c_arr_6_14;
  logic [31:0] c_arr_6_15;
  logic [31:0] c_arr_6_16;
  logic [31:0] c_arr_6_17;
  logic [31:0] c_arr_6_18;
  logic [31:0] c_arr_6_19;
  logic [31:0] c_arr_6_20;
  logic [31:0] c_arr_6_21;
  logic [31:0] c_arr_6_22;
  logic [31:0] c_arr_6_23;
  logic [31:0] c_arr_6_24;
  logic [31:0] c_arr_6_25;
  logic [31:0] c_arr_6_26;
  logic [31:0] c_arr_6_27;
  logic [31:0] c_arr_6_28;
  logic [31:0] c_arr_6_29;
  logic [31:0] c_arr_6_30;
  logic [31:0] c_arr_6_31;
  logic [31:0] c_arr_7_0;
  logic [31:0] c_arr_7_1;
  logic [31:0] c_arr_7_2;
  logic [31:0] c_arr_7_3;
  logic [31:0] c_arr_7_4;
  logic [31:0] c_arr_7_5;
  logic [31:0] c_arr_7_6;
  logic [31:0] c_arr_7_7;
  logic [31:0] c_arr_7_8;
  logic [31:0] c_arr_7_9;
  logic [31:0] c_arr_7_10;
  logic [31:0] c_arr_7_11;
  logic [31:0] c_arr_7_12;
  logic [31:0] c_arr_7_13;
  logic [31:0] c_arr_7_14;
  logic [31:0] c_arr_7_15;
  logic [31:0] c_arr_7_16;
  logic [31:0] c_arr_7_17;
  logic [31:0] c_arr_7_18;
  logic [31:0] c_arr_7_19;
  logic [31:0] c_arr_7_20;
  logic [31:0] c_arr_7_21;
  logic [31:0] c_arr_7_22;
  logic [31:0] c_arr_7_23;
  logic [31:0] c_arr_7_24;
  logic [31:0] c_arr_7_25;
  logic [31:0] c_arr_7_26;
  logic [31:0] c_arr_7_27;
  logic [31:0] c_arr_7_28;
  logic [31:0] c_arr_7_29;
  logic [31:0] c_arr_7_30;
  logic [31:0] c_arr_7_31;
  logic [31:0] c_arr_8_0;
  logic [31:0] c_arr_8_1;
  logic [31:0] c_arr_8_2;
  logic [31:0] c_arr_8_3;
  logic [31:0] c_arr_8_4;
  logic [31:0] c_arr_8_5;
  logic [31:0] c_arr_8_6;
  logic [31:0] c_arr_8_7;
  logic [31:0] c_arr_8_8;
  logic [31:0] c_arr_8_9;
  logic [31:0] c_arr_8_10;
  logic [31:0] c_arr_8_11;
  logic [31:0] c_arr_8_12;
  logic [31:0] c_arr_8_13;
  logic [31:0] c_arr_8_14;
  logic [31:0] c_arr_8_15;
  logic [31:0] c_arr_8_16;
  logic [31:0] c_arr_8_17;
  logic [31:0] c_arr_8_18;
  logic [31:0] c_arr_8_19;
  logic [31:0] c_arr_8_20;
  logic [31:0] c_arr_8_21;
  logic [31:0] c_arr_8_22;
  logic [31:0] c_arr_8_23;
  logic [31:0] c_arr_8_24;
  logic [31:0] c_arr_8_25;
  logic [31:0] c_arr_8_26;
  logic [31:0] c_arr_8_27;
  logic [31:0] c_arr_8_28;
  logic [31:0] c_arr_8_29;
  logic [31:0] c_arr_8_30;
  logic [31:0] c_arr_8_31;
  logic [31:0] c_arr_9_0;
  logic [31:0] c_arr_9_1;
  logic [31:0] c_arr_9_2;
  logic [31:0] c_arr_9_3;
  logic [31:0] c_arr_9_4;
  logic [31:0] c_arr_9_5;
  logic [31:0] c_arr_9_6;
  logic [31:0] c_arr_9_7;
  logic [31:0] c_arr_9_8;
  logic [31:0] c_arr_9_9;
  logic [31:0] c_arr_9_10;
  logic [31:0] c_arr_9_11;
  logic [31:0] c_arr_9_12;
  logic [31:0] c_arr_9_13;
  logic [31:0] c_arr_9_14;
  logic [31:0] c_arr_9_15;
  logic [31:0] c_arr_9_16;
  logic [31:0] c_arr_9_17;
  logic [31:0] c_arr_9_18;
  logic [31:0] c_arr_9_19;
  logic [31:0] c_arr_9_20;
  logic [31:0] c_arr_9_21;
  logic [31:0] c_arr_9_22;
  logic [31:0] c_arr_9_23;
  logic [31:0] c_arr_9_24;
  logic [31:0] c_arr_9_25;
  logic [31:0] c_arr_9_26;
  logic [31:0] c_arr_9_27;
  logic [31:0] c_arr_9_28;
  logic [31:0] c_arr_9_29;
  logic [31:0] c_arr_9_30;
  logic [31:0] c_arr_9_31;
  logic [31:0] c_arr_10_0;
  logic [31:0] c_arr_10_1;
  logic [31:0] c_arr_10_2;
  logic [31:0] c_arr_10_3;
  logic [31:0] c_arr_10_4;
  logic [31:0] c_arr_10_5;
  logic [31:0] c_arr_10_6;
  logic [31:0] c_arr_10_7;
  logic [31:0] c_arr_10_8;
  logic [31:0] c_arr_10_9;
  logic [31:0] c_arr_10_10;
  logic [31:0] c_arr_10_11;
  logic [31:0] c_arr_10_12;
  logic [31:0] c_arr_10_13;
  logic [31:0] c_arr_10_14;
  logic [31:0] c_arr_10_15;
  logic [31:0] c_arr_10_16;
  logic [31:0] c_arr_10_17;
  logic [31:0] c_arr_10_18;
  logic [31:0] c_arr_10_19;
  logic [31:0] c_arr_10_20;
  logic [31:0] c_arr_10_21;
  logic [31:0] c_arr_10_22;
  logic [31:0] c_arr_10_23;
  logic [31:0] c_arr_10_24;
  logic [31:0] c_arr_10_25;
  logic [31:0] c_arr_10_26;
  logic [31:0] c_arr_10_27;
  logic [31:0] c_arr_10_28;
  logic [31:0] c_arr_10_29;
  logic [31:0] c_arr_10_30;
  logic [31:0] c_arr_10_31;
  logic [31:0] c_arr_11_0;
  logic [31:0] c_arr_11_1;
  logic [31:0] c_arr_11_2;
  logic [31:0] c_arr_11_3;
  logic [31:0] c_arr_11_4;
  logic [31:0] c_arr_11_5;
  logic [31:0] c_arr_11_6;
  logic [31:0] c_arr_11_7;
  logic [31:0] c_arr_11_8;
  logic [31:0] c_arr_11_9;
  logic [31:0] c_arr_11_10;
  logic [31:0] c_arr_11_11;
  logic [31:0] c_arr_11_12;
  logic [31:0] c_arr_11_13;
  logic [31:0] c_arr_11_14;
  logic [31:0] c_arr_11_15;
  logic [31:0] c_arr_11_16;
  logic [31:0] c_arr_11_17;
  logic [31:0] c_arr_11_18;
  logic [31:0] c_arr_11_19;
  logic [31:0] c_arr_11_20;
  logic [31:0] c_arr_11_21;
  logic [31:0] c_arr_11_22;
  logic [31:0] c_arr_11_23;
  logic [31:0] c_arr_11_24;
  logic [31:0] c_arr_11_25;
  logic [31:0] c_arr_11_26;
  logic [31:0] c_arr_11_27;
  logic [31:0] c_arr_11_28;
  logic [31:0] c_arr_11_29;
  logic [31:0] c_arr_11_30;
  logic [31:0] c_arr_11_31;
  logic [31:0] c_arr_12_0;
  logic [31:0] c_arr_12_1;
  logic [31:0] c_arr_12_2;
  logic [31:0] c_arr_12_3;
  logic [31:0] c_arr_12_4;
  logic [31:0] c_arr_12_5;
  logic [31:0] c_arr_12_6;
  logic [31:0] c_arr_12_7;
  logic [31:0] c_arr_12_8;
  logic [31:0] c_arr_12_9;
  logic [31:0] c_arr_12_10;
  logic [31:0] c_arr_12_11;
  logic [31:0] c_arr_12_12;
  logic [31:0] c_arr_12_13;
  logic [31:0] c_arr_12_14;
  logic [31:0] c_arr_12_15;
  logic [31:0] c_arr_12_16;
  logic [31:0] c_arr_12_17;
  logic [31:0] c_arr_12_18;
  logic [31:0] c_arr_12_19;
  logic [31:0] c_arr_12_20;
  logic [31:0] c_arr_12_21;
  logic [31:0] c_arr_12_22;
  logic [31:0] c_arr_12_23;
  logic [31:0] c_arr_12_24;
  logic [31:0] c_arr_12_25;
  logic [31:0] c_arr_12_26;
  logic [31:0] c_arr_12_27;
  logic [31:0] c_arr_12_28;
  logic [31:0] c_arr_12_29;
  logic [31:0] c_arr_12_30;
  logic [31:0] c_arr_12_31;
  logic [31:0] c_arr_13_0;
  logic [31:0] c_arr_13_1;
  logic [31:0] c_arr_13_2;
  logic [31:0] c_arr_13_3;
  logic [31:0] c_arr_13_4;
  logic [31:0] c_arr_13_5;
  logic [31:0] c_arr_13_6;
  logic [31:0] c_arr_13_7;
  logic [31:0] c_arr_13_8;
  logic [31:0] c_arr_13_9;
  logic [31:0] c_arr_13_10;
  logic [31:0] c_arr_13_11;
  logic [31:0] c_arr_13_12;
  logic [31:0] c_arr_13_13;
  logic [31:0] c_arr_13_14;
  logic [31:0] c_arr_13_15;
  logic [31:0] c_arr_13_16;
  logic [31:0] c_arr_13_17;
  logic [31:0] c_arr_13_18;
  logic [31:0] c_arr_13_19;
  logic [31:0] c_arr_13_20;
  logic [31:0] c_arr_13_21;
  logic [31:0] c_arr_13_22;
  logic [31:0] c_arr_13_23;
  logic [31:0] c_arr_13_24;
  logic [31:0] c_arr_13_25;
  logic [31:0] c_arr_13_26;
  logic [31:0] c_arr_13_27;
  logic [31:0] c_arr_13_28;
  logic [31:0] c_arr_13_29;
  logic [31:0] c_arr_13_30;
  logic [31:0] c_arr_13_31;
  logic [31:0] c_arr_14_0;
  logic [31:0] c_arr_14_1;
  logic [31:0] c_arr_14_2;
  logic [31:0] c_arr_14_3;
  logic [31:0] c_arr_14_4;
  logic [31:0] c_arr_14_5;
  logic [31:0] c_arr_14_6;
  logic [31:0] c_arr_14_7;
  logic [31:0] c_arr_14_8;
  logic [31:0] c_arr_14_9;
  logic [31:0] c_arr_14_10;
  logic [31:0] c_arr_14_11;
  logic [31:0] c_arr_14_12;
  logic [31:0] c_arr_14_13;
  logic [31:0] c_arr_14_14;
  logic [31:0] c_arr_14_15;
  logic [31:0] c_arr_14_16;
  logic [31:0] c_arr_14_17;
  logic [31:0] c_arr_14_18;
  logic [31:0] c_arr_14_19;
  logic [31:0] c_arr_14_20;
  logic [31:0] c_arr_14_21;
  logic [31:0] c_arr_14_22;
  logic [31:0] c_arr_14_23;
  logic [31:0] c_arr_14_24;
  logic [31:0] c_arr_14_25;
  logic [31:0] c_arr_14_26;
  logic [31:0] c_arr_14_27;
  logic [31:0] c_arr_14_28;
  logic [31:0] c_arr_14_29;
  logic [31:0] c_arr_14_30;
  logic [31:0] c_arr_14_31;
  logic [31:0] c_arr_15_0;
  logic [31:0] c_arr_15_1;
  logic [31:0] c_arr_15_2;
  logic [31:0] c_arr_15_3;
  logic [31:0] c_arr_15_4;
  logic [31:0] c_arr_15_5;
  logic [31:0] c_arr_15_6;
  logic [31:0] c_arr_15_7;
  logic [31:0] c_arr_15_8;
  logic [31:0] c_arr_15_9;
  logic [31:0] c_arr_15_10;
  logic [31:0] c_arr_15_11;
  logic [31:0] c_arr_15_12;
  logic [31:0] c_arr_15_13;
  logic [31:0] c_arr_15_14;
  logic [31:0] c_arr_15_15;
  logic [31:0] c_arr_15_16;
  logic [31:0] c_arr_15_17;
  logic [31:0] c_arr_15_18;
  logic [31:0] c_arr_15_19;
  logic [31:0] c_arr_15_20;
  logic [31:0] c_arr_15_21;
  logic [31:0] c_arr_15_22;
  logic [31:0] c_arr_15_23;
  logic [31:0] c_arr_15_24;
  logic [31:0] c_arr_15_25;
  logic [31:0] c_arr_15_26;
  logic [31:0] c_arr_15_27;
  logic [31:0] c_arr_15_28;
  logic [31:0] c_arr_15_29;
  logic [31:0] c_arr_15_30;
  logic [31:0] c_arr_15_31;
  logic [31:0] c_arr_16_0;
  logic [31:0] c_arr_16_1;
  logic [31:0] c_arr_16_2;
  logic [31:0] c_arr_16_3;
  logic [31:0] c_arr_16_4;
  logic [31:0] c_arr_16_5;
  logic [31:0] c_arr_16_6;
  logic [31:0] c_arr_16_7;
  logic [31:0] c_arr_16_8;
  logic [31:0] c_arr_16_9;
  logic [31:0] c_arr_16_10;
  logic [31:0] c_arr_16_11;
  logic [31:0] c_arr_16_12;
  logic [31:0] c_arr_16_13;
  logic [31:0] c_arr_16_14;
  logic [31:0] c_arr_16_15;
  logic [31:0] c_arr_16_16;
  logic [31:0] c_arr_16_17;
  logic [31:0] c_arr_16_18;
  logic [31:0] c_arr_16_19;
  logic [31:0] c_arr_16_20;
  logic [31:0] c_arr_16_21;
  logic [31:0] c_arr_16_22;
  logic [31:0] c_arr_16_23;
  logic [31:0] c_arr_16_24;
  logic [31:0] c_arr_16_25;
  logic [31:0] c_arr_16_26;
  logic [31:0] c_arr_16_27;
  logic [31:0] c_arr_16_28;
  logic [31:0] c_arr_16_29;
  logic [31:0] c_arr_16_30;
  logic [31:0] c_arr_16_31;
  logic [31:0] c_arr_17_0;
  logic [31:0] c_arr_17_1;
  logic [31:0] c_arr_17_2;
  logic [31:0] c_arr_17_3;
  logic [31:0] c_arr_17_4;
  logic [31:0] c_arr_17_5;
  logic [31:0] c_arr_17_6;
  logic [31:0] c_arr_17_7;
  logic [31:0] c_arr_17_8;
  logic [31:0] c_arr_17_9;
  logic [31:0] c_arr_17_10;
  logic [31:0] c_arr_17_11;
  logic [31:0] c_arr_17_12;
  logic [31:0] c_arr_17_13;
  logic [31:0] c_arr_17_14;
  logic [31:0] c_arr_17_15;
  logic [31:0] c_arr_17_16;
  logic [31:0] c_arr_17_17;
  logic [31:0] c_arr_17_18;
  logic [31:0] c_arr_17_19;
  logic [31:0] c_arr_17_20;
  logic [31:0] c_arr_17_21;
  logic [31:0] c_arr_17_22;
  logic [31:0] c_arr_17_23;
  logic [31:0] c_arr_17_24;
  logic [31:0] c_arr_17_25;
  logic [31:0] c_arr_17_26;
  logic [31:0] c_arr_17_27;
  logic [31:0] c_arr_17_28;
  logic [31:0] c_arr_17_29;
  logic [31:0] c_arr_17_30;
  logic [31:0] c_arr_17_31;
  logic [31:0] c_arr_18_0;
  logic [31:0] c_arr_18_1;
  logic [31:0] c_arr_18_2;
  logic [31:0] c_arr_18_3;
  logic [31:0] c_arr_18_4;
  logic [31:0] c_arr_18_5;
  logic [31:0] c_arr_18_6;
  logic [31:0] c_arr_18_7;
  logic [31:0] c_arr_18_8;
  logic [31:0] c_arr_18_9;
  logic [31:0] c_arr_18_10;
  logic [31:0] c_arr_18_11;
  logic [31:0] c_arr_18_12;
  logic [31:0] c_arr_18_13;
  logic [31:0] c_arr_18_14;
  logic [31:0] c_arr_18_15;
  logic [31:0] c_arr_18_16;
  logic [31:0] c_arr_18_17;
  logic [31:0] c_arr_18_18;
  logic [31:0] c_arr_18_19;
  logic [31:0] c_arr_18_20;
  logic [31:0] c_arr_18_21;
  logic [31:0] c_arr_18_22;
  logic [31:0] c_arr_18_23;
  logic [31:0] c_arr_18_24;
  logic [31:0] c_arr_18_25;
  logic [31:0] c_arr_18_26;
  logic [31:0] c_arr_18_27;
  logic [31:0] c_arr_18_28;
  logic [31:0] c_arr_18_29;
  logic [31:0] c_arr_18_30;
  logic [31:0] c_arr_18_31;
  logic [31:0] c_arr_19_0;
  logic [31:0] c_arr_19_1;
  logic [31:0] c_arr_19_2;
  logic [31:0] c_arr_19_3;
  logic [31:0] c_arr_19_4;
  logic [31:0] c_arr_19_5;
  logic [31:0] c_arr_19_6;
  logic [31:0] c_arr_19_7;
  logic [31:0] c_arr_19_8;
  logic [31:0] c_arr_19_9;
  logic [31:0] c_arr_19_10;
  logic [31:0] c_arr_19_11;
  logic [31:0] c_arr_19_12;
  logic [31:0] c_arr_19_13;
  logic [31:0] c_arr_19_14;
  logic [31:0] c_arr_19_15;
  logic [31:0] c_arr_19_16;
  logic [31:0] c_arr_19_17;
  logic [31:0] c_arr_19_18;
  logic [31:0] c_arr_19_19;
  logic [31:0] c_arr_19_20;
  logic [31:0] c_arr_19_21;
  logic [31:0] c_arr_19_22;
  logic [31:0] c_arr_19_23;
  logic [31:0] c_arr_19_24;
  logic [31:0] c_arr_19_25;
  logic [31:0] c_arr_19_26;
  logic [31:0] c_arr_19_27;
  logic [31:0] c_arr_19_28;
  logic [31:0] c_arr_19_29;
  logic [31:0] c_arr_19_30;
  logic [31:0] c_arr_19_31;
  logic [31:0] c_arr_20_0;
  logic [31:0] c_arr_20_1;
  logic [31:0] c_arr_20_2;
  logic [31:0] c_arr_20_3;
  logic [31:0] c_arr_20_4;
  logic [31:0] c_arr_20_5;
  logic [31:0] c_arr_20_6;
  logic [31:0] c_arr_20_7;
  logic [31:0] c_arr_20_8;
  logic [31:0] c_arr_20_9;
  logic [31:0] c_arr_20_10;
  logic [31:0] c_arr_20_11;
  logic [31:0] c_arr_20_12;
  logic [31:0] c_arr_20_13;
  logic [31:0] c_arr_20_14;
  logic [31:0] c_arr_20_15;
  logic [31:0] c_arr_20_16;
  logic [31:0] c_arr_20_17;
  logic [31:0] c_arr_20_18;
  logic [31:0] c_arr_20_19;
  logic [31:0] c_arr_20_20;
  logic [31:0] c_arr_20_21;
  logic [31:0] c_arr_20_22;
  logic [31:0] c_arr_20_23;
  logic [31:0] c_arr_20_24;
  logic [31:0] c_arr_20_25;
  logic [31:0] c_arr_20_26;
  logic [31:0] c_arr_20_27;
  logic [31:0] c_arr_20_28;
  logic [31:0] c_arr_20_29;
  logic [31:0] c_arr_20_30;
  logic [31:0] c_arr_20_31;
  logic [31:0] c_arr_21_0;
  logic [31:0] c_arr_21_1;
  logic [31:0] c_arr_21_2;
  logic [31:0] c_arr_21_3;
  logic [31:0] c_arr_21_4;
  logic [31:0] c_arr_21_5;
  logic [31:0] c_arr_21_6;
  logic [31:0] c_arr_21_7;
  logic [31:0] c_arr_21_8;
  logic [31:0] c_arr_21_9;
  logic [31:0] c_arr_21_10;
  logic [31:0] c_arr_21_11;
  logic [31:0] c_arr_21_12;
  logic [31:0] c_arr_21_13;
  logic [31:0] c_arr_21_14;
  logic [31:0] c_arr_21_15;
  logic [31:0] c_arr_21_16;
  logic [31:0] c_arr_21_17;
  logic [31:0] c_arr_21_18;
  logic [31:0] c_arr_21_19;
  logic [31:0] c_arr_21_20;
  logic [31:0] c_arr_21_21;
  logic [31:0] c_arr_21_22;
  logic [31:0] c_arr_21_23;
  logic [31:0] c_arr_21_24;
  logic [31:0] c_arr_21_25;
  logic [31:0] c_arr_21_26;
  logic [31:0] c_arr_21_27;
  logic [31:0] c_arr_21_28;
  logic [31:0] c_arr_21_29;
  logic [31:0] c_arr_21_30;
  logic [31:0] c_arr_21_31;
  logic [31:0] c_arr_22_0;
  logic [31:0] c_arr_22_1;
  logic [31:0] c_arr_22_2;
  logic [31:0] c_arr_22_3;
  logic [31:0] c_arr_22_4;
  logic [31:0] c_arr_22_5;
  logic [31:0] c_arr_22_6;
  logic [31:0] c_arr_22_7;
  logic [31:0] c_arr_22_8;
  logic [31:0] c_arr_22_9;
  logic [31:0] c_arr_22_10;
  logic [31:0] c_arr_22_11;
  logic [31:0] c_arr_22_12;
  logic [31:0] c_arr_22_13;
  logic [31:0] c_arr_22_14;
  logic [31:0] c_arr_22_15;
  logic [31:0] c_arr_22_16;
  logic [31:0] c_arr_22_17;
  logic [31:0] c_arr_22_18;
  logic [31:0] c_arr_22_19;
  logic [31:0] c_arr_22_20;
  logic [31:0] c_arr_22_21;
  logic [31:0] c_arr_22_22;
  logic [31:0] c_arr_22_23;
  logic [31:0] c_arr_22_24;
  logic [31:0] c_arr_22_25;
  logic [31:0] c_arr_22_26;
  logic [31:0] c_arr_22_27;
  logic [31:0] c_arr_22_28;
  logic [31:0] c_arr_22_29;
  logic [31:0] c_arr_22_30;
  logic [31:0] c_arr_22_31;
  logic [31:0] c_arr_23_0;
  logic [31:0] c_arr_23_1;
  logic [31:0] c_arr_23_2;
  logic [31:0] c_arr_23_3;
  logic [31:0] c_arr_23_4;
  logic [31:0] c_arr_23_5;
  logic [31:0] c_arr_23_6;
  logic [31:0] c_arr_23_7;
  logic [31:0] c_arr_23_8;
  logic [31:0] c_arr_23_9;
  logic [31:0] c_arr_23_10;
  logic [31:0] c_arr_23_11;
  logic [31:0] c_arr_23_12;
  logic [31:0] c_arr_23_13;
  logic [31:0] c_arr_23_14;
  logic [31:0] c_arr_23_15;
  logic [31:0] c_arr_23_16;
  logic [31:0] c_arr_23_17;
  logic [31:0] c_arr_23_18;
  logic [31:0] c_arr_23_19;
  logic [31:0] c_arr_23_20;
  logic [31:0] c_arr_23_21;
  logic [31:0] c_arr_23_22;
  logic [31:0] c_arr_23_23;
  logic [31:0] c_arr_23_24;
  logic [31:0] c_arr_23_25;
  logic [31:0] c_arr_23_26;
  logic [31:0] c_arr_23_27;
  logic [31:0] c_arr_23_28;
  logic [31:0] c_arr_23_29;
  logic [31:0] c_arr_23_30;
  logic [31:0] c_arr_23_31;
  logic [31:0] c_arr_24_0;
  logic [31:0] c_arr_24_1;
  logic [31:0] c_arr_24_2;
  logic [31:0] c_arr_24_3;
  logic [31:0] c_arr_24_4;
  logic [31:0] c_arr_24_5;
  logic [31:0] c_arr_24_6;
  logic [31:0] c_arr_24_7;
  logic [31:0] c_arr_24_8;
  logic [31:0] c_arr_24_9;
  logic [31:0] c_arr_24_10;
  logic [31:0] c_arr_24_11;
  logic [31:0] c_arr_24_12;
  logic [31:0] c_arr_24_13;
  logic [31:0] c_arr_24_14;
  logic [31:0] c_arr_24_15;
  logic [31:0] c_arr_24_16;
  logic [31:0] c_arr_24_17;
  logic [31:0] c_arr_24_18;
  logic [31:0] c_arr_24_19;
  logic [31:0] c_arr_24_20;
  logic [31:0] c_arr_24_21;
  logic [31:0] c_arr_24_22;
  logic [31:0] c_arr_24_23;
  logic [31:0] c_arr_24_24;
  logic [31:0] c_arr_24_25;
  logic [31:0] c_arr_24_26;
  logic [31:0] c_arr_24_27;
  logic [31:0] c_arr_24_28;
  logic [31:0] c_arr_24_29;
  logic [31:0] c_arr_24_30;
  logic [31:0] c_arr_24_31;
  logic [31:0] c_arr_25_0;
  logic [31:0] c_arr_25_1;
  logic [31:0] c_arr_25_2;
  logic [31:0] c_arr_25_3;
  logic [31:0] c_arr_25_4;
  logic [31:0] c_arr_25_5;
  logic [31:0] c_arr_25_6;
  logic [31:0] c_arr_25_7;
  logic [31:0] c_arr_25_8;
  logic [31:0] c_arr_25_9;
  logic [31:0] c_arr_25_10;
  logic [31:0] c_arr_25_11;
  logic [31:0] c_arr_25_12;
  logic [31:0] c_arr_25_13;
  logic [31:0] c_arr_25_14;
  logic [31:0] c_arr_25_15;
  logic [31:0] c_arr_25_16;
  logic [31:0] c_arr_25_17;
  logic [31:0] c_arr_25_18;
  logic [31:0] c_arr_25_19;
  logic [31:0] c_arr_25_20;
  logic [31:0] c_arr_25_21;
  logic [31:0] c_arr_25_22;
  logic [31:0] c_arr_25_23;
  logic [31:0] c_arr_25_24;
  logic [31:0] c_arr_25_25;
  logic [31:0] c_arr_25_26;
  logic [31:0] c_arr_25_27;
  logic [31:0] c_arr_25_28;
  logic [31:0] c_arr_25_29;
  logic [31:0] c_arr_25_30;
  logic [31:0] c_arr_25_31;
  logic [31:0] c_arr_26_0;
  logic [31:0] c_arr_26_1;
  logic [31:0] c_arr_26_2;
  logic [31:0] c_arr_26_3;
  logic [31:0] c_arr_26_4;
  logic [31:0] c_arr_26_5;
  logic [31:0] c_arr_26_6;
  logic [31:0] c_arr_26_7;
  logic [31:0] c_arr_26_8;
  logic [31:0] c_arr_26_9;
  logic [31:0] c_arr_26_10;
  logic [31:0] c_arr_26_11;
  logic [31:0] c_arr_26_12;
  logic [31:0] c_arr_26_13;
  logic [31:0] c_arr_26_14;
  logic [31:0] c_arr_26_15;
  logic [31:0] c_arr_26_16;
  logic [31:0] c_arr_26_17;
  logic [31:0] c_arr_26_18;
  logic [31:0] c_arr_26_19;
  logic [31:0] c_arr_26_20;
  logic [31:0] c_arr_26_21;
  logic [31:0] c_arr_26_22;
  logic [31:0] c_arr_26_23;
  logic [31:0] c_arr_26_24;
  logic [31:0] c_arr_26_25;
  logic [31:0] c_arr_26_26;
  logic [31:0] c_arr_26_27;
  logic [31:0] c_arr_26_28;
  logic [31:0] c_arr_26_29;
  logic [31:0] c_arr_26_30;
  logic [31:0] c_arr_26_31;
  logic [31:0] c_arr_27_0;
  logic [31:0] c_arr_27_1;
  logic [31:0] c_arr_27_2;
  logic [31:0] c_arr_27_3;
  logic [31:0] c_arr_27_4;
  logic [31:0] c_arr_27_5;
  logic [31:0] c_arr_27_6;
  logic [31:0] c_arr_27_7;
  logic [31:0] c_arr_27_8;
  logic [31:0] c_arr_27_9;
  logic [31:0] c_arr_27_10;
  logic [31:0] c_arr_27_11;
  logic [31:0] c_arr_27_12;
  logic [31:0] c_arr_27_13;
  logic [31:0] c_arr_27_14;
  logic [31:0] c_arr_27_15;
  logic [31:0] c_arr_27_16;
  logic [31:0] c_arr_27_17;
  logic [31:0] c_arr_27_18;
  logic [31:0] c_arr_27_19;
  logic [31:0] c_arr_27_20;
  logic [31:0] c_arr_27_21;
  logic [31:0] c_arr_27_22;
  logic [31:0] c_arr_27_23;
  logic [31:0] c_arr_27_24;
  logic [31:0] c_arr_27_25;
  logic [31:0] c_arr_27_26;
  logic [31:0] c_arr_27_27;
  logic [31:0] c_arr_27_28;
  logic [31:0] c_arr_27_29;
  logic [31:0] c_arr_27_30;
  logic [31:0] c_arr_27_31;
  logic [31:0] c_arr_28_0;
  logic [31:0] c_arr_28_1;
  logic [31:0] c_arr_28_2;
  logic [31:0] c_arr_28_3;
  logic [31:0] c_arr_28_4;
  logic [31:0] c_arr_28_5;
  logic [31:0] c_arr_28_6;
  logic [31:0] c_arr_28_7;
  logic [31:0] c_arr_28_8;
  logic [31:0] c_arr_28_9;
  logic [31:0] c_arr_28_10;
  logic [31:0] c_arr_28_11;
  logic [31:0] c_arr_28_12;
  logic [31:0] c_arr_28_13;
  logic [31:0] c_arr_28_14;
  logic [31:0] c_arr_28_15;
  logic [31:0] c_arr_28_16;
  logic [31:0] c_arr_28_17;
  logic [31:0] c_arr_28_18;
  logic [31:0] c_arr_28_19;
  logic [31:0] c_arr_28_20;
  logic [31:0] c_arr_28_21;
  logic [31:0] c_arr_28_22;
  logic [31:0] c_arr_28_23;
  logic [31:0] c_arr_28_24;
  logic [31:0] c_arr_28_25;
  logic [31:0] c_arr_28_26;
  logic [31:0] c_arr_28_27;
  logic [31:0] c_arr_28_28;
  logic [31:0] c_arr_28_29;
  logic [31:0] c_arr_28_30;
  logic [31:0] c_arr_28_31;
  logic [31:0] c_arr_29_0;
  logic [31:0] c_arr_29_1;
  logic [31:0] c_arr_29_2;
  logic [31:0] c_arr_29_3;
  logic [31:0] c_arr_29_4;
  logic [31:0] c_arr_29_5;
  logic [31:0] c_arr_29_6;
  logic [31:0] c_arr_29_7;
  logic [31:0] c_arr_29_8;
  logic [31:0] c_arr_29_9;
  logic [31:0] c_arr_29_10;
  logic [31:0] c_arr_29_11;
  logic [31:0] c_arr_29_12;
  logic [31:0] c_arr_29_13;
  logic [31:0] c_arr_29_14;
  logic [31:0] c_arr_29_15;
  logic [31:0] c_arr_29_16;
  logic [31:0] c_arr_29_17;
  logic [31:0] c_arr_29_18;
  logic [31:0] c_arr_29_19;
  logic [31:0] c_arr_29_20;
  logic [31:0] c_arr_29_21;
  logic [31:0] c_arr_29_22;
  logic [31:0] c_arr_29_23;
  logic [31:0] c_arr_29_24;
  logic [31:0] c_arr_29_25;
  logic [31:0] c_arr_29_26;
  logic [31:0] c_arr_29_27;
  logic [31:0] c_arr_29_28;
  logic [31:0] c_arr_29_29;
  logic [31:0] c_arr_29_30;
  logic [31:0] c_arr_29_31;
  logic [31:0] c_arr_30_0;
  logic [31:0] c_arr_30_1;
  logic [31:0] c_arr_30_2;
  logic [31:0] c_arr_30_3;
  logic [31:0] c_arr_30_4;
  logic [31:0] c_arr_30_5;
  logic [31:0] c_arr_30_6;
  logic [31:0] c_arr_30_7;
  logic [31:0] c_arr_30_8;
  logic [31:0] c_arr_30_9;
  logic [31:0] c_arr_30_10;
  logic [31:0] c_arr_30_11;
  logic [31:0] c_arr_30_12;
  logic [31:0] c_arr_30_13;
  logic [31:0] c_arr_30_14;
  logic [31:0] c_arr_30_15;
  logic [31:0] c_arr_30_16;
  logic [31:0] c_arr_30_17;
  logic [31:0] c_arr_30_18;
  logic [31:0] c_arr_30_19;
  logic [31:0] c_arr_30_20;
  logic [31:0] c_arr_30_21;
  logic [31:0] c_arr_30_22;
  logic [31:0] c_arr_30_23;
  logic [31:0] c_arr_30_24;
  logic [31:0] c_arr_30_25;
  logic [31:0] c_arr_30_26;
  logic [31:0] c_arr_30_27;
  logic [31:0] c_arr_30_28;
  logic [31:0] c_arr_30_29;
  logic [31:0] c_arr_30_30;
  logic [31:0] c_arr_30_31;
  logic [31:0] c_arr_31_0;
  logic [31:0] c_arr_31_1;
  logic [31:0] c_arr_31_2;
  logic [31:0] c_arr_31_3;
  logic [31:0] c_arr_31_4;
  logic [31:0] c_arr_31_5;
  logic [31:0] c_arr_31_6;
  logic [31:0] c_arr_31_7;
  logic [31:0] c_arr_31_8;
  logic [31:0] c_arr_31_9;
  logic [31:0] c_arr_31_10;
  logic [31:0] c_arr_31_11;
  logic [31:0] c_arr_31_12;
  logic [31:0] c_arr_31_13;
  logic [31:0] c_arr_31_14;
  logic [31:0] c_arr_31_15;
  logic [31:0] c_arr_31_16;
  logic [31:0] c_arr_31_17;
  logic [31:0] c_arr_31_18;
  logic [31:0] c_arr_31_19;
  logic [31:0] c_arr_31_20;
  logic [31:0] c_arr_31_21;
  logic [31:0] c_arr_31_22;
  logic [31:0] c_arr_31_23;
  logic [31:0] c_arr_31_24;
  logic [31:0] c_arr_31_25;
  logic [31:0] c_arr_31_26;
  logic [31:0] c_arr_31_27;
  logic [31:0] c_arr_31_28;
  logic [31:0] c_arr_31_29;
  logic [31:0] c_arr_31_30;
  logic [31:0] c_arr_31_31;
  logic [0:0] tile_valid_o;
  logic [0:0] tile_ready_i;
  logic [0:0] tile_done_i;
  logic s_axi_control_AWVALID;
  logic s_axi_control_AWREADY;
  logic [6:0] s_axi_control_AWADDR;
  logic s_axi_control_WVALID;
  logic s_axi_control_WREADY;
  logic [31:0] s_axi_control_WDATA;
  logic [3:0] s_axi_control_WSTRB;
  logic s_axi_control_ARVALID;
  logic s_axi_control_ARREADY;
  logic [6:0] s_axi_control_ARADDR;
  logic s_axi_control_RVALID;
  logic s_axi_control_RREADY;
  logic [31:0] s_axi_control_RDATA;
  logic [1:0] s_axi_control_RRESP;
  logic s_axi_control_BVALID;
  logic s_axi_control_BREADY;
  logic [1:0] s_axi_control_BRESP;
  logic interrupt;

  // ---- Tin hieu trung ten port SYSTOLIC_CORE_TOP (sinh tu dong) ----
  logic tile_valid_i;
  logic tile_ready_o;
  logic tile_done_o;
  logic tile_i_sel_i;
  logic [2:0] tile_j_sel_i;
  logic [9:0] bram_a0_addr_o;
  logic bram_a0_en_o;
  logic signed [7:0] bram_a0_dout_i;
  logic [9:0] bram_a1_addr_o;
  logic bram_a1_en_o;
  logic signed [7:0] bram_a1_dout_i;
  logic [9:0] bram_a2_addr_o;
  logic bram_a2_en_o;
  logic signed [7:0] bram_a2_dout_i;
  logic [9:0] bram_a3_addr_o;
  logic bram_a3_en_o;
  logic signed [7:0] bram_a3_dout_i;
  logic [9:0] bram_a4_addr_o;
  logic bram_a4_en_o;
  logic signed [7:0] bram_a4_dout_i;
  logic [9:0] bram_a5_addr_o;
  logic bram_a5_en_o;
  logic signed [7:0] bram_a5_dout_i;
  logic [9:0] bram_a6_addr_o;
  logic bram_a6_en_o;
  logic signed [7:0] bram_a6_dout_i;
  logic [9:0] bram_a7_addr_o;
  logic bram_a7_en_o;
  logic signed [7:0] bram_a7_dout_i;
  logic [9:0] bram_a8_addr_o;
  logic bram_a8_en_o;
  logic signed [7:0] bram_a8_dout_i;
  logic [9:0] bram_a9_addr_o;
  logic bram_a9_en_o;
  logic signed [7:0] bram_a9_dout_i;
  logic [9:0] bram_a10_addr_o;
  logic bram_a10_en_o;
  logic signed [7:0] bram_a10_dout_i;
  logic [9:0] bram_a11_addr_o;
  logic bram_a11_en_o;
  logic signed [7:0] bram_a11_dout_i;
  logic [9:0] bram_a12_addr_o;
  logic bram_a12_en_o;
  logic signed [7:0] bram_a12_dout_i;
  logic [9:0] bram_a13_addr_o;
  logic bram_a13_en_o;
  logic signed [7:0] bram_a13_dout_i;
  logic [9:0] bram_a14_addr_o;
  logic bram_a14_en_o;
  logic signed [7:0] bram_a14_dout_i;
  logic [9:0] bram_a15_addr_o;
  logic bram_a15_en_o;
  logic signed [7:0] bram_a15_dout_i;
  logic [9:0] bram_a16_addr_o;
  logic bram_a16_en_o;
  logic signed [7:0] bram_a16_dout_i;
  logic [9:0] bram_a17_addr_o;
  logic bram_a17_en_o;
  logic signed [7:0] bram_a17_dout_i;
  logic [9:0] bram_a18_addr_o;
  logic bram_a18_en_o;
  logic signed [7:0] bram_a18_dout_i;
  logic [9:0] bram_a19_addr_o;
  logic bram_a19_en_o;
  logic signed [7:0] bram_a19_dout_i;
  logic [9:0] bram_a20_addr_o;
  logic bram_a20_en_o;
  logic signed [7:0] bram_a20_dout_i;
  logic [9:0] bram_a21_addr_o;
  logic bram_a21_en_o;
  logic signed [7:0] bram_a21_dout_i;
  logic [9:0] bram_a22_addr_o;
  logic bram_a22_en_o;
  logic signed [7:0] bram_a22_dout_i;
  logic [9:0] bram_a23_addr_o;
  logic bram_a23_en_o;
  logic signed [7:0] bram_a23_dout_i;
  logic [9:0] bram_a24_addr_o;
  logic bram_a24_en_o;
  logic signed [7:0] bram_a24_dout_i;
  logic [9:0] bram_a25_addr_o;
  logic bram_a25_en_o;
  logic signed [7:0] bram_a25_dout_i;
  logic [9:0] bram_a26_addr_o;
  logic bram_a26_en_o;
  logic signed [7:0] bram_a26_dout_i;
  logic [9:0] bram_a27_addr_o;
  logic bram_a27_en_o;
  logic signed [7:0] bram_a27_dout_i;
  logic [9:0] bram_a28_addr_o;
  logic bram_a28_en_o;
  logic signed [7:0] bram_a28_dout_i;
  logic [9:0] bram_a29_addr_o;
  logic bram_a29_en_o;
  logic signed [7:0] bram_a29_dout_i;
  logic [9:0] bram_a30_addr_o;
  logic bram_a30_en_o;
  logic signed [7:0] bram_a30_dout_i;
  logic [9:0] bram_a31_addr_o;
  logic bram_a31_en_o;
  logic signed [7:0] bram_a31_dout_i;
  logic [9:0] bram_a32_addr_o;
  logic bram_a32_en_o;
  logic signed [7:0] bram_a32_dout_i;
  logic [9:0] bram_a33_addr_o;
  logic bram_a33_en_o;
  logic signed [7:0] bram_a33_dout_i;
  logic [9:0] bram_a34_addr_o;
  logic bram_a34_en_o;
  logic signed [7:0] bram_a34_dout_i;
  logic [9:0] bram_a35_addr_o;
  logic bram_a35_en_o;
  logic signed [7:0] bram_a35_dout_i;
  logic [9:0] bram_a36_addr_o;
  logic bram_a36_en_o;
  logic signed [7:0] bram_a36_dout_i;
  logic [9:0] bram_a37_addr_o;
  logic bram_a37_en_o;
  logic signed [7:0] bram_a37_dout_i;
  logic [9:0] bram_a38_addr_o;
  logic bram_a38_en_o;
  logic signed [7:0] bram_a38_dout_i;
  logic [9:0] bram_a39_addr_o;
  logic bram_a39_en_o;
  logic signed [7:0] bram_a39_dout_i;
  logic [9:0] bram_a40_addr_o;
  logic bram_a40_en_o;
  logic signed [7:0] bram_a40_dout_i;
  logic [9:0] bram_a41_addr_o;
  logic bram_a41_en_o;
  logic signed [7:0] bram_a41_dout_i;
  logic [9:0] bram_a42_addr_o;
  logic bram_a42_en_o;
  logic signed [7:0] bram_a42_dout_i;
  logic [9:0] bram_a43_addr_o;
  logic bram_a43_en_o;
  logic signed [7:0] bram_a43_dout_i;
  logic [9:0] bram_a44_addr_o;
  logic bram_a44_en_o;
  logic signed [7:0] bram_a44_dout_i;
  logic [9:0] bram_a45_addr_o;
  logic bram_a45_en_o;
  logic signed [7:0] bram_a45_dout_i;
  logic [9:0] bram_a46_addr_o;
  logic bram_a46_en_o;
  logic signed [7:0] bram_a46_dout_i;
  logic [9:0] bram_a47_addr_o;
  logic bram_a47_en_o;
  logic signed [7:0] bram_a47_dout_i;
  logic [9:0] bram_a48_addr_o;
  logic bram_a48_en_o;
  logic signed [7:0] bram_a48_dout_i;
  logic [9:0] bram_a49_addr_o;
  logic bram_a49_en_o;
  logic signed [7:0] bram_a49_dout_i;
  logic [9:0] bram_a50_addr_o;
  logic bram_a50_en_o;
  logic signed [7:0] bram_a50_dout_i;
  logic [9:0] bram_a51_addr_o;
  logic bram_a51_en_o;
  logic signed [7:0] bram_a51_dout_i;
  logic [9:0] bram_a52_addr_o;
  logic bram_a52_en_o;
  logic signed [7:0] bram_a52_dout_i;
  logic [9:0] bram_a53_addr_o;
  logic bram_a53_en_o;
  logic signed [7:0] bram_a53_dout_i;
  logic [9:0] bram_a54_addr_o;
  logic bram_a54_en_o;
  logic signed [7:0] bram_a54_dout_i;
  logic [9:0] bram_a55_addr_o;
  logic bram_a55_en_o;
  logic signed [7:0] bram_a55_dout_i;
  logic [9:0] bram_a56_addr_o;
  logic bram_a56_en_o;
  logic signed [7:0] bram_a56_dout_i;
  logic [9:0] bram_a57_addr_o;
  logic bram_a57_en_o;
  logic signed [7:0] bram_a57_dout_i;
  logic [9:0] bram_a58_addr_o;
  logic bram_a58_en_o;
  logic signed [7:0] bram_a58_dout_i;
  logic [9:0] bram_a59_addr_o;
  logic bram_a59_en_o;
  logic signed [7:0] bram_a59_dout_i;
  logic [9:0] bram_a60_addr_o;
  logic bram_a60_en_o;
  logic signed [7:0] bram_a60_dout_i;
  logic [9:0] bram_a61_addr_o;
  logic bram_a61_en_o;
  logic signed [7:0] bram_a61_dout_i;
  logic [9:0] bram_a62_addr_o;
  logic bram_a62_en_o;
  logic signed [7:0] bram_a62_dout_i;
  logic [9:0] bram_a63_addr_o;
  logic bram_a63_en_o;
  logic signed [7:0] bram_a63_dout_i;
  logic [12:0] bram_b0_addr_o;
  logic bram_b0_en_o;
  logic signed [7:0] bram_b0_dout_i;
  logic [12:0] bram_b1_addr_o;
  logic bram_b1_en_o;
  logic signed [7:0] bram_b1_dout_i;
  logic [12:0] bram_b2_addr_o;
  logic bram_b2_en_o;
  logic signed [7:0] bram_b2_dout_i;
  logic [12:0] bram_b3_addr_o;
  logic bram_b3_en_o;
  logic signed [7:0] bram_b3_dout_i;
  logic [12:0] bram_b4_addr_o;
  logic bram_b4_en_o;
  logic signed [7:0] bram_b4_dout_i;
  logic [12:0] bram_b5_addr_o;
  logic bram_b5_en_o;
  logic signed [7:0] bram_b5_dout_i;
  logic [12:0] bram_b6_addr_o;
  logic bram_b6_en_o;
  logic signed [7:0] bram_b6_dout_i;
  logic [12:0] bram_b7_addr_o;
  logic bram_b7_en_o;
  logic signed [7:0] bram_b7_dout_i;
  logic [12:0] bram_b8_addr_o;
  logic bram_b8_en_o;
  logic signed [7:0] bram_b8_dout_i;
  logic [12:0] bram_b9_addr_o;
  logic bram_b9_en_o;
  logic signed [7:0] bram_b9_dout_i;
  logic [12:0] bram_b10_addr_o;
  logic bram_b10_en_o;
  logic signed [7:0] bram_b10_dout_i;
  logic [12:0] bram_b11_addr_o;
  logic bram_b11_en_o;
  logic signed [7:0] bram_b11_dout_i;
  logic [12:0] bram_b12_addr_o;
  logic bram_b12_en_o;
  logic signed [7:0] bram_b12_dout_i;
  logic [12:0] bram_b13_addr_o;
  logic bram_b13_en_o;
  logic signed [7:0] bram_b13_dout_i;
  logic [12:0] bram_b14_addr_o;
  logic bram_b14_en_o;
  logic signed [7:0] bram_b14_dout_i;
  logic [12:0] bram_b15_addr_o;
  logic bram_b15_en_o;
  logic signed [7:0] bram_b15_dout_i;
  logic [12:0] bram_b16_addr_o;
  logic bram_b16_en_o;
  logic signed [7:0] bram_b16_dout_i;
  logic [12:0] bram_b17_addr_o;
  logic bram_b17_en_o;
  logic signed [7:0] bram_b17_dout_i;
  logic [12:0] bram_b18_addr_o;
  logic bram_b18_en_o;
  logic signed [7:0] bram_b18_dout_i;
  logic [12:0] bram_b19_addr_o;
  logic bram_b19_en_o;
  logic signed [7:0] bram_b19_dout_i;
  logic [12:0] bram_b20_addr_o;
  logic bram_b20_en_o;
  logic signed [7:0] bram_b20_dout_i;
  logic [12:0] bram_b21_addr_o;
  logic bram_b21_en_o;
  logic signed [7:0] bram_b21_dout_i;
  logic [12:0] bram_b22_addr_o;
  logic bram_b22_en_o;
  logic signed [7:0] bram_b22_dout_i;
  logic [12:0] bram_b23_addr_o;
  logic bram_b23_en_o;
  logic signed [7:0] bram_b23_dout_i;
  logic [12:0] bram_b24_addr_o;
  logic bram_b24_en_o;
  logic signed [7:0] bram_b24_dout_i;
  logic [12:0] bram_b25_addr_o;
  logic bram_b25_en_o;
  logic signed [7:0] bram_b25_dout_i;
  logic [12:0] bram_b26_addr_o;
  logic bram_b26_en_o;
  logic signed [7:0] bram_b26_dout_i;
  logic [12:0] bram_b27_addr_o;
  logic bram_b27_en_o;
  logic signed [7:0] bram_b27_dout_i;
  logic [12:0] bram_b28_addr_o;
  logic bram_b28_en_o;
  logic signed [7:0] bram_b28_dout_i;
  logic [12:0] bram_b29_addr_o;
  logic bram_b29_en_o;
  logic signed [7:0] bram_b29_dout_i;
  logic [12:0] bram_b30_addr_o;
  logic bram_b30_en_o;
  logic signed [7:0] bram_b30_dout_i;
  logic [12:0] bram_b31_addr_o;
  logic bram_b31_en_o;
  logic signed [7:0] bram_b31_dout_i;
  logic signed [31:0] c0_0_o;
  logic signed [31:0] c0_1_o;
  logic signed [31:0] c0_2_o;
  logic signed [31:0] c0_3_o;
  logic signed [31:0] c0_4_o;
  logic signed [31:0] c0_5_o;
  logic signed [31:0] c0_6_o;
  logic signed [31:0] c0_7_o;
  logic signed [31:0] c0_8_o;
  logic signed [31:0] c0_9_o;
  logic signed [31:0] c0_10_o;
  logic signed [31:0] c0_11_o;
  logic signed [31:0] c0_12_o;
  logic signed [31:0] c0_13_o;
  logic signed [31:0] c0_14_o;
  logic signed [31:0] c0_15_o;
  logic signed [31:0] c0_16_o;
  logic signed [31:0] c0_17_o;
  logic signed [31:0] c0_18_o;
  logic signed [31:0] c0_19_o;
  logic signed [31:0] c0_20_o;
  logic signed [31:0] c0_21_o;
  logic signed [31:0] c0_22_o;
  logic signed [31:0] c0_23_o;
  logic signed [31:0] c0_24_o;
  logic signed [31:0] c0_25_o;
  logic signed [31:0] c0_26_o;
  logic signed [31:0] c0_27_o;
  logic signed [31:0] c0_28_o;
  logic signed [31:0] c0_29_o;
  logic signed [31:0] c0_30_o;
  logic signed [31:0] c0_31_o;
  logic signed [31:0] c1_0_o;
  logic signed [31:0] c1_1_o;
  logic signed [31:0] c1_2_o;
  logic signed [31:0] c1_3_o;
  logic signed [31:0] c1_4_o;
  logic signed [31:0] c1_5_o;
  logic signed [31:0] c1_6_o;
  logic signed [31:0] c1_7_o;
  logic signed [31:0] c1_8_o;
  logic signed [31:0] c1_9_o;
  logic signed [31:0] c1_10_o;
  logic signed [31:0] c1_11_o;
  logic signed [31:0] c1_12_o;
  logic signed [31:0] c1_13_o;
  logic signed [31:0] c1_14_o;
  logic signed [31:0] c1_15_o;
  logic signed [31:0] c1_16_o;
  logic signed [31:0] c1_17_o;
  logic signed [31:0] c1_18_o;
  logic signed [31:0] c1_19_o;
  logic signed [31:0] c1_20_o;
  logic signed [31:0] c1_21_o;
  logic signed [31:0] c1_22_o;
  logic signed [31:0] c1_23_o;
  logic signed [31:0] c1_24_o;
  logic signed [31:0] c1_25_o;
  logic signed [31:0] c1_26_o;
  logic signed [31:0] c1_27_o;
  logic signed [31:0] c1_28_o;
  logic signed [31:0] c1_29_o;
  logic signed [31:0] c1_30_o;
  logic signed [31:0] c1_31_o;
  logic signed [31:0] c2_0_o;
  logic signed [31:0] c2_1_o;
  logic signed [31:0] c2_2_o;
  logic signed [31:0] c2_3_o;
  logic signed [31:0] c2_4_o;
  logic signed [31:0] c2_5_o;
  logic signed [31:0] c2_6_o;
  logic signed [31:0] c2_7_o;
  logic signed [31:0] c2_8_o;
  logic signed [31:0] c2_9_o;
  logic signed [31:0] c2_10_o;
  logic signed [31:0] c2_11_o;
  logic signed [31:0] c2_12_o;
  logic signed [31:0] c2_13_o;
  logic signed [31:0] c2_14_o;
  logic signed [31:0] c2_15_o;
  logic signed [31:0] c2_16_o;
  logic signed [31:0] c2_17_o;
  logic signed [31:0] c2_18_o;
  logic signed [31:0] c2_19_o;
  logic signed [31:0] c2_20_o;
  logic signed [31:0] c2_21_o;
  logic signed [31:0] c2_22_o;
  logic signed [31:0] c2_23_o;
  logic signed [31:0] c2_24_o;
  logic signed [31:0] c2_25_o;
  logic signed [31:0] c2_26_o;
  logic signed [31:0] c2_27_o;
  logic signed [31:0] c2_28_o;
  logic signed [31:0] c2_29_o;
  logic signed [31:0] c2_30_o;
  logic signed [31:0] c2_31_o;
  logic signed [31:0] c3_0_o;
  logic signed [31:0] c3_1_o;
  logic signed [31:0] c3_2_o;
  logic signed [31:0] c3_3_o;
  logic signed [31:0] c3_4_o;
  logic signed [31:0] c3_5_o;
  logic signed [31:0] c3_6_o;
  logic signed [31:0] c3_7_o;
  logic signed [31:0] c3_8_o;
  logic signed [31:0] c3_9_o;
  logic signed [31:0] c3_10_o;
  logic signed [31:0] c3_11_o;
  logic signed [31:0] c3_12_o;
  logic signed [31:0] c3_13_o;
  logic signed [31:0] c3_14_o;
  logic signed [31:0] c3_15_o;
  logic signed [31:0] c3_16_o;
  logic signed [31:0] c3_17_o;
  logic signed [31:0] c3_18_o;
  logic signed [31:0] c3_19_o;
  logic signed [31:0] c3_20_o;
  logic signed [31:0] c3_21_o;
  logic signed [31:0] c3_22_o;
  logic signed [31:0] c3_23_o;
  logic signed [31:0] c3_24_o;
  logic signed [31:0] c3_25_o;
  logic signed [31:0] c3_26_o;
  logic signed [31:0] c3_27_o;
  logic signed [31:0] c3_28_o;
  logic signed [31:0] c3_29_o;
  logic signed [31:0] c3_30_o;
  logic signed [31:0] c3_31_o;
  logic signed [31:0] c4_0_o;
  logic signed [31:0] c4_1_o;
  logic signed [31:0] c4_2_o;
  logic signed [31:0] c4_3_o;
  logic signed [31:0] c4_4_o;
  logic signed [31:0] c4_5_o;
  logic signed [31:0] c4_6_o;
  logic signed [31:0] c4_7_o;
  logic signed [31:0] c4_8_o;
  logic signed [31:0] c4_9_o;
  logic signed [31:0] c4_10_o;
  logic signed [31:0] c4_11_o;
  logic signed [31:0] c4_12_o;
  logic signed [31:0] c4_13_o;
  logic signed [31:0] c4_14_o;
  logic signed [31:0] c4_15_o;
  logic signed [31:0] c4_16_o;
  logic signed [31:0] c4_17_o;
  logic signed [31:0] c4_18_o;
  logic signed [31:0] c4_19_o;
  logic signed [31:0] c4_20_o;
  logic signed [31:0] c4_21_o;
  logic signed [31:0] c4_22_o;
  logic signed [31:0] c4_23_o;
  logic signed [31:0] c4_24_o;
  logic signed [31:0] c4_25_o;
  logic signed [31:0] c4_26_o;
  logic signed [31:0] c4_27_o;
  logic signed [31:0] c4_28_o;
  logic signed [31:0] c4_29_o;
  logic signed [31:0] c4_30_o;
  logic signed [31:0] c4_31_o;
  logic signed [31:0] c5_0_o;
  logic signed [31:0] c5_1_o;
  logic signed [31:0] c5_2_o;
  logic signed [31:0] c5_3_o;
  logic signed [31:0] c5_4_o;
  logic signed [31:0] c5_5_o;
  logic signed [31:0] c5_6_o;
  logic signed [31:0] c5_7_o;
  logic signed [31:0] c5_8_o;
  logic signed [31:0] c5_9_o;
  logic signed [31:0] c5_10_o;
  logic signed [31:0] c5_11_o;
  logic signed [31:0] c5_12_o;
  logic signed [31:0] c5_13_o;
  logic signed [31:0] c5_14_o;
  logic signed [31:0] c5_15_o;
  logic signed [31:0] c5_16_o;
  logic signed [31:0] c5_17_o;
  logic signed [31:0] c5_18_o;
  logic signed [31:0] c5_19_o;
  logic signed [31:0] c5_20_o;
  logic signed [31:0] c5_21_o;
  logic signed [31:0] c5_22_o;
  logic signed [31:0] c5_23_o;
  logic signed [31:0] c5_24_o;
  logic signed [31:0] c5_25_o;
  logic signed [31:0] c5_26_o;
  logic signed [31:0] c5_27_o;
  logic signed [31:0] c5_28_o;
  logic signed [31:0] c5_29_o;
  logic signed [31:0] c5_30_o;
  logic signed [31:0] c5_31_o;
  logic signed [31:0] c6_0_o;
  logic signed [31:0] c6_1_o;
  logic signed [31:0] c6_2_o;
  logic signed [31:0] c6_3_o;
  logic signed [31:0] c6_4_o;
  logic signed [31:0] c6_5_o;
  logic signed [31:0] c6_6_o;
  logic signed [31:0] c6_7_o;
  logic signed [31:0] c6_8_o;
  logic signed [31:0] c6_9_o;
  logic signed [31:0] c6_10_o;
  logic signed [31:0] c6_11_o;
  logic signed [31:0] c6_12_o;
  logic signed [31:0] c6_13_o;
  logic signed [31:0] c6_14_o;
  logic signed [31:0] c6_15_o;
  logic signed [31:0] c6_16_o;
  logic signed [31:0] c6_17_o;
  logic signed [31:0] c6_18_o;
  logic signed [31:0] c6_19_o;
  logic signed [31:0] c6_20_o;
  logic signed [31:0] c6_21_o;
  logic signed [31:0] c6_22_o;
  logic signed [31:0] c6_23_o;
  logic signed [31:0] c6_24_o;
  logic signed [31:0] c6_25_o;
  logic signed [31:0] c6_26_o;
  logic signed [31:0] c6_27_o;
  logic signed [31:0] c6_28_o;
  logic signed [31:0] c6_29_o;
  logic signed [31:0] c6_30_o;
  logic signed [31:0] c6_31_o;
  logic signed [31:0] c7_0_o;
  logic signed [31:0] c7_1_o;
  logic signed [31:0] c7_2_o;
  logic signed [31:0] c7_3_o;
  logic signed [31:0] c7_4_o;
  logic signed [31:0] c7_5_o;
  logic signed [31:0] c7_6_o;
  logic signed [31:0] c7_7_o;
  logic signed [31:0] c7_8_o;
  logic signed [31:0] c7_9_o;
  logic signed [31:0] c7_10_o;
  logic signed [31:0] c7_11_o;
  logic signed [31:0] c7_12_o;
  logic signed [31:0] c7_13_o;
  logic signed [31:0] c7_14_o;
  logic signed [31:0] c7_15_o;
  logic signed [31:0] c7_16_o;
  logic signed [31:0] c7_17_o;
  logic signed [31:0] c7_18_o;
  logic signed [31:0] c7_19_o;
  logic signed [31:0] c7_20_o;
  logic signed [31:0] c7_21_o;
  logic signed [31:0] c7_22_o;
  logic signed [31:0] c7_23_o;
  logic signed [31:0] c7_24_o;
  logic signed [31:0] c7_25_o;
  logic signed [31:0] c7_26_o;
  logic signed [31:0] c7_27_o;
  logic signed [31:0] c7_28_o;
  logic signed [31:0] c7_29_o;
  logic signed [31:0] c7_30_o;
  logic signed [31:0] c7_31_o;
  logic signed [31:0] c8_0_o;
  logic signed [31:0] c8_1_o;
  logic signed [31:0] c8_2_o;
  logic signed [31:0] c8_3_o;
  logic signed [31:0] c8_4_o;
  logic signed [31:0] c8_5_o;
  logic signed [31:0] c8_6_o;
  logic signed [31:0] c8_7_o;
  logic signed [31:0] c8_8_o;
  logic signed [31:0] c8_9_o;
  logic signed [31:0] c8_10_o;
  logic signed [31:0] c8_11_o;
  logic signed [31:0] c8_12_o;
  logic signed [31:0] c8_13_o;
  logic signed [31:0] c8_14_o;
  logic signed [31:0] c8_15_o;
  logic signed [31:0] c8_16_o;
  logic signed [31:0] c8_17_o;
  logic signed [31:0] c8_18_o;
  logic signed [31:0] c8_19_o;
  logic signed [31:0] c8_20_o;
  logic signed [31:0] c8_21_o;
  logic signed [31:0] c8_22_o;
  logic signed [31:0] c8_23_o;
  logic signed [31:0] c8_24_o;
  logic signed [31:0] c8_25_o;
  logic signed [31:0] c8_26_o;
  logic signed [31:0] c8_27_o;
  logic signed [31:0] c8_28_o;
  logic signed [31:0] c8_29_o;
  logic signed [31:0] c8_30_o;
  logic signed [31:0] c8_31_o;
  logic signed [31:0] c9_0_o;
  logic signed [31:0] c9_1_o;
  logic signed [31:0] c9_2_o;
  logic signed [31:0] c9_3_o;
  logic signed [31:0] c9_4_o;
  logic signed [31:0] c9_5_o;
  logic signed [31:0] c9_6_o;
  logic signed [31:0] c9_7_o;
  logic signed [31:0] c9_8_o;
  logic signed [31:0] c9_9_o;
  logic signed [31:0] c9_10_o;
  logic signed [31:0] c9_11_o;
  logic signed [31:0] c9_12_o;
  logic signed [31:0] c9_13_o;
  logic signed [31:0] c9_14_o;
  logic signed [31:0] c9_15_o;
  logic signed [31:0] c9_16_o;
  logic signed [31:0] c9_17_o;
  logic signed [31:0] c9_18_o;
  logic signed [31:0] c9_19_o;
  logic signed [31:0] c9_20_o;
  logic signed [31:0] c9_21_o;
  logic signed [31:0] c9_22_o;
  logic signed [31:0] c9_23_o;
  logic signed [31:0] c9_24_o;
  logic signed [31:0] c9_25_o;
  logic signed [31:0] c9_26_o;
  logic signed [31:0] c9_27_o;
  logic signed [31:0] c9_28_o;
  logic signed [31:0] c9_29_o;
  logic signed [31:0] c9_30_o;
  logic signed [31:0] c9_31_o;
  logic signed [31:0] c10_0_o;
  logic signed [31:0] c10_1_o;
  logic signed [31:0] c10_2_o;
  logic signed [31:0] c10_3_o;
  logic signed [31:0] c10_4_o;
  logic signed [31:0] c10_5_o;
  logic signed [31:0] c10_6_o;
  logic signed [31:0] c10_7_o;
  logic signed [31:0] c10_8_o;
  logic signed [31:0] c10_9_o;
  logic signed [31:0] c10_10_o;
  logic signed [31:0] c10_11_o;
  logic signed [31:0] c10_12_o;
  logic signed [31:0] c10_13_o;
  logic signed [31:0] c10_14_o;
  logic signed [31:0] c10_15_o;
  logic signed [31:0] c10_16_o;
  logic signed [31:0] c10_17_o;
  logic signed [31:0] c10_18_o;
  logic signed [31:0] c10_19_o;
  logic signed [31:0] c10_20_o;
  logic signed [31:0] c10_21_o;
  logic signed [31:0] c10_22_o;
  logic signed [31:0] c10_23_o;
  logic signed [31:0] c10_24_o;
  logic signed [31:0] c10_25_o;
  logic signed [31:0] c10_26_o;
  logic signed [31:0] c10_27_o;
  logic signed [31:0] c10_28_o;
  logic signed [31:0] c10_29_o;
  logic signed [31:0] c10_30_o;
  logic signed [31:0] c10_31_o;
  logic signed [31:0] c11_0_o;
  logic signed [31:0] c11_1_o;
  logic signed [31:0] c11_2_o;
  logic signed [31:0] c11_3_o;
  logic signed [31:0] c11_4_o;
  logic signed [31:0] c11_5_o;
  logic signed [31:0] c11_6_o;
  logic signed [31:0] c11_7_o;
  logic signed [31:0] c11_8_o;
  logic signed [31:0] c11_9_o;
  logic signed [31:0] c11_10_o;
  logic signed [31:0] c11_11_o;
  logic signed [31:0] c11_12_o;
  logic signed [31:0] c11_13_o;
  logic signed [31:0] c11_14_o;
  logic signed [31:0] c11_15_o;
  logic signed [31:0] c11_16_o;
  logic signed [31:0] c11_17_o;
  logic signed [31:0] c11_18_o;
  logic signed [31:0] c11_19_o;
  logic signed [31:0] c11_20_o;
  logic signed [31:0] c11_21_o;
  logic signed [31:0] c11_22_o;
  logic signed [31:0] c11_23_o;
  logic signed [31:0] c11_24_o;
  logic signed [31:0] c11_25_o;
  logic signed [31:0] c11_26_o;
  logic signed [31:0] c11_27_o;
  logic signed [31:0] c11_28_o;
  logic signed [31:0] c11_29_o;
  logic signed [31:0] c11_30_o;
  logic signed [31:0] c11_31_o;
  logic signed [31:0] c12_0_o;
  logic signed [31:0] c12_1_o;
  logic signed [31:0] c12_2_o;
  logic signed [31:0] c12_3_o;
  logic signed [31:0] c12_4_o;
  logic signed [31:0] c12_5_o;
  logic signed [31:0] c12_6_o;
  logic signed [31:0] c12_7_o;
  logic signed [31:0] c12_8_o;
  logic signed [31:0] c12_9_o;
  logic signed [31:0] c12_10_o;
  logic signed [31:0] c12_11_o;
  logic signed [31:0] c12_12_o;
  logic signed [31:0] c12_13_o;
  logic signed [31:0] c12_14_o;
  logic signed [31:0] c12_15_o;
  logic signed [31:0] c12_16_o;
  logic signed [31:0] c12_17_o;
  logic signed [31:0] c12_18_o;
  logic signed [31:0] c12_19_o;
  logic signed [31:0] c12_20_o;
  logic signed [31:0] c12_21_o;
  logic signed [31:0] c12_22_o;
  logic signed [31:0] c12_23_o;
  logic signed [31:0] c12_24_o;
  logic signed [31:0] c12_25_o;
  logic signed [31:0] c12_26_o;
  logic signed [31:0] c12_27_o;
  logic signed [31:0] c12_28_o;
  logic signed [31:0] c12_29_o;
  logic signed [31:0] c12_30_o;
  logic signed [31:0] c12_31_o;
  logic signed [31:0] c13_0_o;
  logic signed [31:0] c13_1_o;
  logic signed [31:0] c13_2_o;
  logic signed [31:0] c13_3_o;
  logic signed [31:0] c13_4_o;
  logic signed [31:0] c13_5_o;
  logic signed [31:0] c13_6_o;
  logic signed [31:0] c13_7_o;
  logic signed [31:0] c13_8_o;
  logic signed [31:0] c13_9_o;
  logic signed [31:0] c13_10_o;
  logic signed [31:0] c13_11_o;
  logic signed [31:0] c13_12_o;
  logic signed [31:0] c13_13_o;
  logic signed [31:0] c13_14_o;
  logic signed [31:0] c13_15_o;
  logic signed [31:0] c13_16_o;
  logic signed [31:0] c13_17_o;
  logic signed [31:0] c13_18_o;
  logic signed [31:0] c13_19_o;
  logic signed [31:0] c13_20_o;
  logic signed [31:0] c13_21_o;
  logic signed [31:0] c13_22_o;
  logic signed [31:0] c13_23_o;
  logic signed [31:0] c13_24_o;
  logic signed [31:0] c13_25_o;
  logic signed [31:0] c13_26_o;
  logic signed [31:0] c13_27_o;
  logic signed [31:0] c13_28_o;
  logic signed [31:0] c13_29_o;
  logic signed [31:0] c13_30_o;
  logic signed [31:0] c13_31_o;
  logic signed [31:0] c14_0_o;
  logic signed [31:0] c14_1_o;
  logic signed [31:0] c14_2_o;
  logic signed [31:0] c14_3_o;
  logic signed [31:0] c14_4_o;
  logic signed [31:0] c14_5_o;
  logic signed [31:0] c14_6_o;
  logic signed [31:0] c14_7_o;
  logic signed [31:0] c14_8_o;
  logic signed [31:0] c14_9_o;
  logic signed [31:0] c14_10_o;
  logic signed [31:0] c14_11_o;
  logic signed [31:0] c14_12_o;
  logic signed [31:0] c14_13_o;
  logic signed [31:0] c14_14_o;
  logic signed [31:0] c14_15_o;
  logic signed [31:0] c14_16_o;
  logic signed [31:0] c14_17_o;
  logic signed [31:0] c14_18_o;
  logic signed [31:0] c14_19_o;
  logic signed [31:0] c14_20_o;
  logic signed [31:0] c14_21_o;
  logic signed [31:0] c14_22_o;
  logic signed [31:0] c14_23_o;
  logic signed [31:0] c14_24_o;
  logic signed [31:0] c14_25_o;
  logic signed [31:0] c14_26_o;
  logic signed [31:0] c14_27_o;
  logic signed [31:0] c14_28_o;
  logic signed [31:0] c14_29_o;
  logic signed [31:0] c14_30_o;
  logic signed [31:0] c14_31_o;
  logic signed [31:0] c15_0_o;
  logic signed [31:0] c15_1_o;
  logic signed [31:0] c15_2_o;
  logic signed [31:0] c15_3_o;
  logic signed [31:0] c15_4_o;
  logic signed [31:0] c15_5_o;
  logic signed [31:0] c15_6_o;
  logic signed [31:0] c15_7_o;
  logic signed [31:0] c15_8_o;
  logic signed [31:0] c15_9_o;
  logic signed [31:0] c15_10_o;
  logic signed [31:0] c15_11_o;
  logic signed [31:0] c15_12_o;
  logic signed [31:0] c15_13_o;
  logic signed [31:0] c15_14_o;
  logic signed [31:0] c15_15_o;
  logic signed [31:0] c15_16_o;
  logic signed [31:0] c15_17_o;
  logic signed [31:0] c15_18_o;
  logic signed [31:0] c15_19_o;
  logic signed [31:0] c15_20_o;
  logic signed [31:0] c15_21_o;
  logic signed [31:0] c15_22_o;
  logic signed [31:0] c15_23_o;
  logic signed [31:0] c15_24_o;
  logic signed [31:0] c15_25_o;
  logic signed [31:0] c15_26_o;
  logic signed [31:0] c15_27_o;
  logic signed [31:0] c15_28_o;
  logic signed [31:0] c15_29_o;
  logic signed [31:0] c15_30_o;
  logic signed [31:0] c15_31_o;
  logic signed [31:0] c16_0_o;
  logic signed [31:0] c16_1_o;
  logic signed [31:0] c16_2_o;
  logic signed [31:0] c16_3_o;
  logic signed [31:0] c16_4_o;
  logic signed [31:0] c16_5_o;
  logic signed [31:0] c16_6_o;
  logic signed [31:0] c16_7_o;
  logic signed [31:0] c16_8_o;
  logic signed [31:0] c16_9_o;
  logic signed [31:0] c16_10_o;
  logic signed [31:0] c16_11_o;
  logic signed [31:0] c16_12_o;
  logic signed [31:0] c16_13_o;
  logic signed [31:0] c16_14_o;
  logic signed [31:0] c16_15_o;
  logic signed [31:0] c16_16_o;
  logic signed [31:0] c16_17_o;
  logic signed [31:0] c16_18_o;
  logic signed [31:0] c16_19_o;
  logic signed [31:0] c16_20_o;
  logic signed [31:0] c16_21_o;
  logic signed [31:0] c16_22_o;
  logic signed [31:0] c16_23_o;
  logic signed [31:0] c16_24_o;
  logic signed [31:0] c16_25_o;
  logic signed [31:0] c16_26_o;
  logic signed [31:0] c16_27_o;
  logic signed [31:0] c16_28_o;
  logic signed [31:0] c16_29_o;
  logic signed [31:0] c16_30_o;
  logic signed [31:0] c16_31_o;
  logic signed [31:0] c17_0_o;
  logic signed [31:0] c17_1_o;
  logic signed [31:0] c17_2_o;
  logic signed [31:0] c17_3_o;
  logic signed [31:0] c17_4_o;
  logic signed [31:0] c17_5_o;
  logic signed [31:0] c17_6_o;
  logic signed [31:0] c17_7_o;
  logic signed [31:0] c17_8_o;
  logic signed [31:0] c17_9_o;
  logic signed [31:0] c17_10_o;
  logic signed [31:0] c17_11_o;
  logic signed [31:0] c17_12_o;
  logic signed [31:0] c17_13_o;
  logic signed [31:0] c17_14_o;
  logic signed [31:0] c17_15_o;
  logic signed [31:0] c17_16_o;
  logic signed [31:0] c17_17_o;
  logic signed [31:0] c17_18_o;
  logic signed [31:0] c17_19_o;
  logic signed [31:0] c17_20_o;
  logic signed [31:0] c17_21_o;
  logic signed [31:0] c17_22_o;
  logic signed [31:0] c17_23_o;
  logic signed [31:0] c17_24_o;
  logic signed [31:0] c17_25_o;
  logic signed [31:0] c17_26_o;
  logic signed [31:0] c17_27_o;
  logic signed [31:0] c17_28_o;
  logic signed [31:0] c17_29_o;
  logic signed [31:0] c17_30_o;
  logic signed [31:0] c17_31_o;
  logic signed [31:0] c18_0_o;
  logic signed [31:0] c18_1_o;
  logic signed [31:0] c18_2_o;
  logic signed [31:0] c18_3_o;
  logic signed [31:0] c18_4_o;
  logic signed [31:0] c18_5_o;
  logic signed [31:0] c18_6_o;
  logic signed [31:0] c18_7_o;
  logic signed [31:0] c18_8_o;
  logic signed [31:0] c18_9_o;
  logic signed [31:0] c18_10_o;
  logic signed [31:0] c18_11_o;
  logic signed [31:0] c18_12_o;
  logic signed [31:0] c18_13_o;
  logic signed [31:0] c18_14_o;
  logic signed [31:0] c18_15_o;
  logic signed [31:0] c18_16_o;
  logic signed [31:0] c18_17_o;
  logic signed [31:0] c18_18_o;
  logic signed [31:0] c18_19_o;
  logic signed [31:0] c18_20_o;
  logic signed [31:0] c18_21_o;
  logic signed [31:0] c18_22_o;
  logic signed [31:0] c18_23_o;
  logic signed [31:0] c18_24_o;
  logic signed [31:0] c18_25_o;
  logic signed [31:0] c18_26_o;
  logic signed [31:0] c18_27_o;
  logic signed [31:0] c18_28_o;
  logic signed [31:0] c18_29_o;
  logic signed [31:0] c18_30_o;
  logic signed [31:0] c18_31_o;
  logic signed [31:0] c19_0_o;
  logic signed [31:0] c19_1_o;
  logic signed [31:0] c19_2_o;
  logic signed [31:0] c19_3_o;
  logic signed [31:0] c19_4_o;
  logic signed [31:0] c19_5_o;
  logic signed [31:0] c19_6_o;
  logic signed [31:0] c19_7_o;
  logic signed [31:0] c19_8_o;
  logic signed [31:0] c19_9_o;
  logic signed [31:0] c19_10_o;
  logic signed [31:0] c19_11_o;
  logic signed [31:0] c19_12_o;
  logic signed [31:0] c19_13_o;
  logic signed [31:0] c19_14_o;
  logic signed [31:0] c19_15_o;
  logic signed [31:0] c19_16_o;
  logic signed [31:0] c19_17_o;
  logic signed [31:0] c19_18_o;
  logic signed [31:0] c19_19_o;
  logic signed [31:0] c19_20_o;
  logic signed [31:0] c19_21_o;
  logic signed [31:0] c19_22_o;
  logic signed [31:0] c19_23_o;
  logic signed [31:0] c19_24_o;
  logic signed [31:0] c19_25_o;
  logic signed [31:0] c19_26_o;
  logic signed [31:0] c19_27_o;
  logic signed [31:0] c19_28_o;
  logic signed [31:0] c19_29_o;
  logic signed [31:0] c19_30_o;
  logic signed [31:0] c19_31_o;
  logic signed [31:0] c20_0_o;
  logic signed [31:0] c20_1_o;
  logic signed [31:0] c20_2_o;
  logic signed [31:0] c20_3_o;
  logic signed [31:0] c20_4_o;
  logic signed [31:0] c20_5_o;
  logic signed [31:0] c20_6_o;
  logic signed [31:0] c20_7_o;
  logic signed [31:0] c20_8_o;
  logic signed [31:0] c20_9_o;
  logic signed [31:0] c20_10_o;
  logic signed [31:0] c20_11_o;
  logic signed [31:0] c20_12_o;
  logic signed [31:0] c20_13_o;
  logic signed [31:0] c20_14_o;
  logic signed [31:0] c20_15_o;
  logic signed [31:0] c20_16_o;
  logic signed [31:0] c20_17_o;
  logic signed [31:0] c20_18_o;
  logic signed [31:0] c20_19_o;
  logic signed [31:0] c20_20_o;
  logic signed [31:0] c20_21_o;
  logic signed [31:0] c20_22_o;
  logic signed [31:0] c20_23_o;
  logic signed [31:0] c20_24_o;
  logic signed [31:0] c20_25_o;
  logic signed [31:0] c20_26_o;
  logic signed [31:0] c20_27_o;
  logic signed [31:0] c20_28_o;
  logic signed [31:0] c20_29_o;
  logic signed [31:0] c20_30_o;
  logic signed [31:0] c20_31_o;
  logic signed [31:0] c21_0_o;
  logic signed [31:0] c21_1_o;
  logic signed [31:0] c21_2_o;
  logic signed [31:0] c21_3_o;
  logic signed [31:0] c21_4_o;
  logic signed [31:0] c21_5_o;
  logic signed [31:0] c21_6_o;
  logic signed [31:0] c21_7_o;
  logic signed [31:0] c21_8_o;
  logic signed [31:0] c21_9_o;
  logic signed [31:0] c21_10_o;
  logic signed [31:0] c21_11_o;
  logic signed [31:0] c21_12_o;
  logic signed [31:0] c21_13_o;
  logic signed [31:0] c21_14_o;
  logic signed [31:0] c21_15_o;
  logic signed [31:0] c21_16_o;
  logic signed [31:0] c21_17_o;
  logic signed [31:0] c21_18_o;
  logic signed [31:0] c21_19_o;
  logic signed [31:0] c21_20_o;
  logic signed [31:0] c21_21_o;
  logic signed [31:0] c21_22_o;
  logic signed [31:0] c21_23_o;
  logic signed [31:0] c21_24_o;
  logic signed [31:0] c21_25_o;
  logic signed [31:0] c21_26_o;
  logic signed [31:0] c21_27_o;
  logic signed [31:0] c21_28_o;
  logic signed [31:0] c21_29_o;
  logic signed [31:0] c21_30_o;
  logic signed [31:0] c21_31_o;
  logic signed [31:0] c22_0_o;
  logic signed [31:0] c22_1_o;
  logic signed [31:0] c22_2_o;
  logic signed [31:0] c22_3_o;
  logic signed [31:0] c22_4_o;
  logic signed [31:0] c22_5_o;
  logic signed [31:0] c22_6_o;
  logic signed [31:0] c22_7_o;
  logic signed [31:0] c22_8_o;
  logic signed [31:0] c22_9_o;
  logic signed [31:0] c22_10_o;
  logic signed [31:0] c22_11_o;
  logic signed [31:0] c22_12_o;
  logic signed [31:0] c22_13_o;
  logic signed [31:0] c22_14_o;
  logic signed [31:0] c22_15_o;
  logic signed [31:0] c22_16_o;
  logic signed [31:0] c22_17_o;
  logic signed [31:0] c22_18_o;
  logic signed [31:0] c22_19_o;
  logic signed [31:0] c22_20_o;
  logic signed [31:0] c22_21_o;
  logic signed [31:0] c22_22_o;
  logic signed [31:0] c22_23_o;
  logic signed [31:0] c22_24_o;
  logic signed [31:0] c22_25_o;
  logic signed [31:0] c22_26_o;
  logic signed [31:0] c22_27_o;
  logic signed [31:0] c22_28_o;
  logic signed [31:0] c22_29_o;
  logic signed [31:0] c22_30_o;
  logic signed [31:0] c22_31_o;
  logic signed [31:0] c23_0_o;
  logic signed [31:0] c23_1_o;
  logic signed [31:0] c23_2_o;
  logic signed [31:0] c23_3_o;
  logic signed [31:0] c23_4_o;
  logic signed [31:0] c23_5_o;
  logic signed [31:0] c23_6_o;
  logic signed [31:0] c23_7_o;
  logic signed [31:0] c23_8_o;
  logic signed [31:0] c23_9_o;
  logic signed [31:0] c23_10_o;
  logic signed [31:0] c23_11_o;
  logic signed [31:0] c23_12_o;
  logic signed [31:0] c23_13_o;
  logic signed [31:0] c23_14_o;
  logic signed [31:0] c23_15_o;
  logic signed [31:0] c23_16_o;
  logic signed [31:0] c23_17_o;
  logic signed [31:0] c23_18_o;
  logic signed [31:0] c23_19_o;
  logic signed [31:0] c23_20_o;
  logic signed [31:0] c23_21_o;
  logic signed [31:0] c23_22_o;
  logic signed [31:0] c23_23_o;
  logic signed [31:0] c23_24_o;
  logic signed [31:0] c23_25_o;
  logic signed [31:0] c23_26_o;
  logic signed [31:0] c23_27_o;
  logic signed [31:0] c23_28_o;
  logic signed [31:0] c23_29_o;
  logic signed [31:0] c23_30_o;
  logic signed [31:0] c23_31_o;
  logic signed [31:0] c24_0_o;
  logic signed [31:0] c24_1_o;
  logic signed [31:0] c24_2_o;
  logic signed [31:0] c24_3_o;
  logic signed [31:0] c24_4_o;
  logic signed [31:0] c24_5_o;
  logic signed [31:0] c24_6_o;
  logic signed [31:0] c24_7_o;
  logic signed [31:0] c24_8_o;
  logic signed [31:0] c24_9_o;
  logic signed [31:0] c24_10_o;
  logic signed [31:0] c24_11_o;
  logic signed [31:0] c24_12_o;
  logic signed [31:0] c24_13_o;
  logic signed [31:0] c24_14_o;
  logic signed [31:0] c24_15_o;
  logic signed [31:0] c24_16_o;
  logic signed [31:0] c24_17_o;
  logic signed [31:0] c24_18_o;
  logic signed [31:0] c24_19_o;
  logic signed [31:0] c24_20_o;
  logic signed [31:0] c24_21_o;
  logic signed [31:0] c24_22_o;
  logic signed [31:0] c24_23_o;
  logic signed [31:0] c24_24_o;
  logic signed [31:0] c24_25_o;
  logic signed [31:0] c24_26_o;
  logic signed [31:0] c24_27_o;
  logic signed [31:0] c24_28_o;
  logic signed [31:0] c24_29_o;
  logic signed [31:0] c24_30_o;
  logic signed [31:0] c24_31_o;
  logic signed [31:0] c25_0_o;
  logic signed [31:0] c25_1_o;
  logic signed [31:0] c25_2_o;
  logic signed [31:0] c25_3_o;
  logic signed [31:0] c25_4_o;
  logic signed [31:0] c25_5_o;
  logic signed [31:0] c25_6_o;
  logic signed [31:0] c25_7_o;
  logic signed [31:0] c25_8_o;
  logic signed [31:0] c25_9_o;
  logic signed [31:0] c25_10_o;
  logic signed [31:0] c25_11_o;
  logic signed [31:0] c25_12_o;
  logic signed [31:0] c25_13_o;
  logic signed [31:0] c25_14_o;
  logic signed [31:0] c25_15_o;
  logic signed [31:0] c25_16_o;
  logic signed [31:0] c25_17_o;
  logic signed [31:0] c25_18_o;
  logic signed [31:0] c25_19_o;
  logic signed [31:0] c25_20_o;
  logic signed [31:0] c25_21_o;
  logic signed [31:0] c25_22_o;
  logic signed [31:0] c25_23_o;
  logic signed [31:0] c25_24_o;
  logic signed [31:0] c25_25_o;
  logic signed [31:0] c25_26_o;
  logic signed [31:0] c25_27_o;
  logic signed [31:0] c25_28_o;
  logic signed [31:0] c25_29_o;
  logic signed [31:0] c25_30_o;
  logic signed [31:0] c25_31_o;
  logic signed [31:0] c26_0_o;
  logic signed [31:0] c26_1_o;
  logic signed [31:0] c26_2_o;
  logic signed [31:0] c26_3_o;
  logic signed [31:0] c26_4_o;
  logic signed [31:0] c26_5_o;
  logic signed [31:0] c26_6_o;
  logic signed [31:0] c26_7_o;
  logic signed [31:0] c26_8_o;
  logic signed [31:0] c26_9_o;
  logic signed [31:0] c26_10_o;
  logic signed [31:0] c26_11_o;
  logic signed [31:0] c26_12_o;
  logic signed [31:0] c26_13_o;
  logic signed [31:0] c26_14_o;
  logic signed [31:0] c26_15_o;
  logic signed [31:0] c26_16_o;
  logic signed [31:0] c26_17_o;
  logic signed [31:0] c26_18_o;
  logic signed [31:0] c26_19_o;
  logic signed [31:0] c26_20_o;
  logic signed [31:0] c26_21_o;
  logic signed [31:0] c26_22_o;
  logic signed [31:0] c26_23_o;
  logic signed [31:0] c26_24_o;
  logic signed [31:0] c26_25_o;
  logic signed [31:0] c26_26_o;
  logic signed [31:0] c26_27_o;
  logic signed [31:0] c26_28_o;
  logic signed [31:0] c26_29_o;
  logic signed [31:0] c26_30_o;
  logic signed [31:0] c26_31_o;
  logic signed [31:0] c27_0_o;
  logic signed [31:0] c27_1_o;
  logic signed [31:0] c27_2_o;
  logic signed [31:0] c27_3_o;
  logic signed [31:0] c27_4_o;
  logic signed [31:0] c27_5_o;
  logic signed [31:0] c27_6_o;
  logic signed [31:0] c27_7_o;
  logic signed [31:0] c27_8_o;
  logic signed [31:0] c27_9_o;
  logic signed [31:0] c27_10_o;
  logic signed [31:0] c27_11_o;
  logic signed [31:0] c27_12_o;
  logic signed [31:0] c27_13_o;
  logic signed [31:0] c27_14_o;
  logic signed [31:0] c27_15_o;
  logic signed [31:0] c27_16_o;
  logic signed [31:0] c27_17_o;
  logic signed [31:0] c27_18_o;
  logic signed [31:0] c27_19_o;
  logic signed [31:0] c27_20_o;
  logic signed [31:0] c27_21_o;
  logic signed [31:0] c27_22_o;
  logic signed [31:0] c27_23_o;
  logic signed [31:0] c27_24_o;
  logic signed [31:0] c27_25_o;
  logic signed [31:0] c27_26_o;
  logic signed [31:0] c27_27_o;
  logic signed [31:0] c27_28_o;
  logic signed [31:0] c27_29_o;
  logic signed [31:0] c27_30_o;
  logic signed [31:0] c27_31_o;
  logic signed [31:0] c28_0_o;
  logic signed [31:0] c28_1_o;
  logic signed [31:0] c28_2_o;
  logic signed [31:0] c28_3_o;
  logic signed [31:0] c28_4_o;
  logic signed [31:0] c28_5_o;
  logic signed [31:0] c28_6_o;
  logic signed [31:0] c28_7_o;
  logic signed [31:0] c28_8_o;
  logic signed [31:0] c28_9_o;
  logic signed [31:0] c28_10_o;
  logic signed [31:0] c28_11_o;
  logic signed [31:0] c28_12_o;
  logic signed [31:0] c28_13_o;
  logic signed [31:0] c28_14_o;
  logic signed [31:0] c28_15_o;
  logic signed [31:0] c28_16_o;
  logic signed [31:0] c28_17_o;
  logic signed [31:0] c28_18_o;
  logic signed [31:0] c28_19_o;
  logic signed [31:0] c28_20_o;
  logic signed [31:0] c28_21_o;
  logic signed [31:0] c28_22_o;
  logic signed [31:0] c28_23_o;
  logic signed [31:0] c28_24_o;
  logic signed [31:0] c28_25_o;
  logic signed [31:0] c28_26_o;
  logic signed [31:0] c28_27_o;
  logic signed [31:0] c28_28_o;
  logic signed [31:0] c28_29_o;
  logic signed [31:0] c28_30_o;
  logic signed [31:0] c28_31_o;
  logic signed [31:0] c29_0_o;
  logic signed [31:0] c29_1_o;
  logic signed [31:0] c29_2_o;
  logic signed [31:0] c29_3_o;
  logic signed [31:0] c29_4_o;
  logic signed [31:0] c29_5_o;
  logic signed [31:0] c29_6_o;
  logic signed [31:0] c29_7_o;
  logic signed [31:0] c29_8_o;
  logic signed [31:0] c29_9_o;
  logic signed [31:0] c29_10_o;
  logic signed [31:0] c29_11_o;
  logic signed [31:0] c29_12_o;
  logic signed [31:0] c29_13_o;
  logic signed [31:0] c29_14_o;
  logic signed [31:0] c29_15_o;
  logic signed [31:0] c29_16_o;
  logic signed [31:0] c29_17_o;
  logic signed [31:0] c29_18_o;
  logic signed [31:0] c29_19_o;
  logic signed [31:0] c29_20_o;
  logic signed [31:0] c29_21_o;
  logic signed [31:0] c29_22_o;
  logic signed [31:0] c29_23_o;
  logic signed [31:0] c29_24_o;
  logic signed [31:0] c29_25_o;
  logic signed [31:0] c29_26_o;
  logic signed [31:0] c29_27_o;
  logic signed [31:0] c29_28_o;
  logic signed [31:0] c29_29_o;
  logic signed [31:0] c29_30_o;
  logic signed [31:0] c29_31_o;
  logic signed [31:0] c30_0_o;
  logic signed [31:0] c30_1_o;
  logic signed [31:0] c30_2_o;
  logic signed [31:0] c30_3_o;
  logic signed [31:0] c30_4_o;
  logic signed [31:0] c30_5_o;
  logic signed [31:0] c30_6_o;
  logic signed [31:0] c30_7_o;
  logic signed [31:0] c30_8_o;
  logic signed [31:0] c30_9_o;
  logic signed [31:0] c30_10_o;
  logic signed [31:0] c30_11_o;
  logic signed [31:0] c30_12_o;
  logic signed [31:0] c30_13_o;
  logic signed [31:0] c30_14_o;
  logic signed [31:0] c30_15_o;
  logic signed [31:0] c30_16_o;
  logic signed [31:0] c30_17_o;
  logic signed [31:0] c30_18_o;
  logic signed [31:0] c30_19_o;
  logic signed [31:0] c30_20_o;
  logic signed [31:0] c30_21_o;
  logic signed [31:0] c30_22_o;
  logic signed [31:0] c30_23_o;
  logic signed [31:0] c30_24_o;
  logic signed [31:0] c30_25_o;
  logic signed [31:0] c30_26_o;
  logic signed [31:0] c30_27_o;
  logic signed [31:0] c30_28_o;
  logic signed [31:0] c30_29_o;
  logic signed [31:0] c30_30_o;
  logic signed [31:0] c30_31_o;
  logic signed [31:0] c31_0_o;
  logic signed [31:0] c31_1_o;
  logic signed [31:0] c31_2_o;
  logic signed [31:0] c31_3_o;
  logic signed [31:0] c31_4_o;
  logic signed [31:0] c31_5_o;
  logic signed [31:0] c31_6_o;
  logic signed [31:0] c31_7_o;
  logic signed [31:0] c31_8_o;
  logic signed [31:0] c31_9_o;
  logic signed [31:0] c31_10_o;
  logic signed [31:0] c31_11_o;
  logic signed [31:0] c31_12_o;
  logic signed [31:0] c31_13_o;
  logic signed [31:0] c31_14_o;
  logic signed [31:0] c31_15_o;
  logic signed [31:0] c31_16_o;
  logic signed [31:0] c31_17_o;
  logic signed [31:0] c31_18_o;
  logic signed [31:0] c31_19_o;
  logic signed [31:0] c31_20_o;
  logic signed [31:0] c31_21_o;
  logic signed [31:0] c31_22_o;
  logic signed [31:0] c31_23_o;
  logic signed [31:0] c31_24_o;
  logic signed [31:0] c31_25_o;
  logic signed [31:0] c31_26_o;
  logic signed [31:0] c31_27_o;
  logic signed [31:0] c31_28_o;
  logic signed [31:0] c31_29_o;
  logic signed [31:0] c31_30_o;
  logic signed [31:0] c31_31_o;


  // ---- AXI4_A_READER (Huong B) + BFM AXI4 chi-doc phuc vu no (thay hoan toan gmemA) ----
  // AXI4_A_READER la AXI4 master CHI DOC, non-outstanding (1 burst tai 1 thoi diem - cho RLAST
  // xong moi phat AR ke tiep) - BFM don gian hon nhieu so voi gmemC (khong AW/W/B, khong
  // hang doi nhieu giao dich). Da kiem chung dung mau nay o bench/tb_axi4_a_reader.sv (PASS
  // toan bo, xem docs/task.md).
  logic [7:0] mem_a_reader [0:49151];

  typedef enum logic [0:0] {A_BFM_IDLE, A_BFM_R} a_bfm_state_e;
  a_bfm_state_e a_bfm_state_q;
  logic [31:0]  a_bfm_addr_q;
  logic [7:0]   a_bfm_len_q;
  logic [7:0]   a_bfm_beat_q;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      a_bfm_state_q   <= A_BFM_IDLE;
      m_axi_arready_i <= 1'b1;
      a_bfm_addr_q    <= '0;
      a_bfm_len_q     <= '0;
      a_bfm_beat_q    <= '0;
    end else begin
      case (a_bfm_state_q)
        A_BFM_IDLE: begin
          m_axi_arready_i <= 1'b1;
          if (m_axi_arvalid_o && m_axi_arready_i) begin
            a_bfm_addr_q    <= m_axi_araddr_o;
            a_bfm_len_q     <= m_axi_arlen_o;
            a_bfm_beat_q    <= 8'd0;
            m_axi_arready_i <= 1'b0;
            a_bfm_state_q   <= A_BFM_R;
          end
        end
        A_BFM_R: begin
          if (m_axi_rvalid_i && m_axi_rready_o) begin
            if (a_bfm_beat_q == a_bfm_len_q) begin
              a_bfm_state_q   <= A_BFM_IDLE;
              m_axi_arready_i <= 1'b1;
            end else begin
              a_bfm_beat_q <= a_bfm_beat_q + 1'b1;
            end
          end
        end
        default: a_bfm_state_q <= A_BFM_IDLE;
      endcase
    end
  end

  // [SUA - 2026-08-21] AXI4_A_READER doc 32-bit/beat (4 byte/beat) - dong goi 4 byte lien tiep
  // tu mem_a_reader thanh 1 tu theo dung little-endian AXI (byte dau tien o bit [7:0]), khop
  // dung cach da lam trong bench/tb_axi4_a_reader.sv.
  wire [31:0] a_bfm_word_base = a_bfm_addr_q + (a_bfm_beat_q * 4);
  assign m_axi_rvalid_i = (a_bfm_state_q == A_BFM_R);
  assign m_axi_rdata_i  = {mem_a_reader[a_bfm_word_base+3], mem_a_reader[a_bfm_word_base+2],
                            mem_a_reader[a_bfm_word_base+1], mem_a_reader[a_bfm_word_base]};
  assign m_axi_rlast_i  = (a_bfm_beat_q == a_bfm_len_q);

  AXI4_A_READER dut_axi4_a_reader (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .*
  );

  // Bat tay mmult_accel <-> AXI4_A_READER (ten khac nhau ca 2 phia, can cau noi tuong minh -
  // cung mau da dung cho tile_valid_o/tile_ready_o/... giua mmult_accel/SYSTOLIC_CORE_TOP).
  assign a_base_addr_i  = a_base_addr_o;
  assign a_reload_req_i = a_reload_req_o;
  assign a_loaded_i     = a_loaded_o;

  // ---- AXI4_B_READER (SUA LAN 12) + BFM AXI4 chi-doc phuc vu no (thay hoan toan gmemB) ----
  // AXI4_B_READER la AXI4 master CHI DOC, non-outstanding (giong AXI4_A_READER) - BFM don gian
  // hon nhieu so voi gmemC (khong AW/W/B, khong hang doi nhieu giao dich). Da kiem chung dung
  // mau nay o bench/tb_axi4_b_reader.sv (PASS toan bo, xem docs/task.md).
  logic [7:0] mem_b_reader [0:49151];

  typedef enum logic [0:0] {B_BFM_IDLE, B_BFM_R} b_bfm_state_e;
  b_bfm_state_e b_bfm_state_q;
  logic [31:0]  b_bfm_addr_q;
  logic [7:0]   b_bfm_len_q;
  logic [7:0]   b_bfm_beat_q;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      b_bfm_state_q     <= B_BFM_IDLE;
      b_m_axi_arready_i <= 1'b1;
      b_bfm_addr_q      <= '0;
      b_bfm_len_q       <= '0;
      b_bfm_beat_q      <= '0;
    end else begin
      case (b_bfm_state_q)
        B_BFM_IDLE: begin
          b_m_axi_arready_i <= 1'b1;
          if (b_m_axi_arvalid_o && b_m_axi_arready_i) begin
            b_bfm_addr_q      <= b_m_axi_araddr_o;
            b_bfm_len_q       <= b_m_axi_arlen_o;
            b_bfm_beat_q      <= 8'd0;
            b_m_axi_arready_i <= 1'b0;
            b_bfm_state_q     <= B_BFM_R;
          end
        end
        B_BFM_R: begin
          if (b_m_axi_rvalid_i && b_m_axi_rready_o) begin
            if (b_bfm_beat_q == b_bfm_len_q) begin
              b_bfm_state_q     <= B_BFM_IDLE;
              b_m_axi_arready_i <= 1'b1;
            end else begin
              b_bfm_beat_q <= b_bfm_beat_q + 1'b1;
            end
          end
        end
        default: b_bfm_state_q <= B_BFM_IDLE;
      endcase
    end
  end

  // [SUA - 2026-08-21] AXI4_B_READER doc 32-bit/beat (4 byte/beat) - dong goi 4 byte lien tiep
  // tu mem_b_reader thanh 1 tu theo dung little-endian AXI, khop dung cach da lam trong
  // bench/tb_axi4_b_reader.sv.
  wire [31:0] b_bfm_word_base = b_bfm_addr_q + (b_bfm_beat_q * 4);
  assign b_m_axi_rvalid_i = (b_bfm_state_q == B_BFM_R);
  assign b_m_axi_rdata_i  = {mem_b_reader[b_bfm_word_base+3], mem_b_reader[b_bfm_word_base+2],
                              mem_b_reader[b_bfm_word_base+1], mem_b_reader[b_bfm_word_base]};
  assign b_m_axi_rlast_i  = (b_bfm_beat_q == b_bfm_len_q);

  // AXI4_B_READER co ten port TRUNG voi AXI4_A_READER (m_axi_araddr_o/bank_addr_o/...) - KHONG
  // dung `.*` duoc, phai noi tuong minh tung port sang tin hieu rieng tien to "b_" da khai bao.
  AXI4_B_READER dut_axi4_b_reader (
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),
    .b_reload_req_i  (b_reload_req_i),
    .b_base_addr_i   (b_base_addr_i),
    .b_row_stride_i  (b_row_stride_i),
    .b_num_rows_i    (b_num_rows_i),
    .b_block_width_i (b_block_width_i),
    .b_loaded_o      (b_loaded_o),
    .m_axi_araddr_o  (b_m_axi_araddr_o),
    .m_axi_arlen_o   (b_m_axi_arlen_o),
    .m_axi_arsize_o  (b_m_axi_arsize_o),
    .m_axi_arburst_o (b_m_axi_arburst_o),
    .m_axi_arvalid_o (b_m_axi_arvalid_o),
    .m_axi_arready_i (b_m_axi_arready_i),
    .m_axi_rdata_i   (b_m_axi_rdata_i),
    .m_axi_rvalid_i  (b_m_axi_rvalid_i),
    .m_axi_rlast_i   (b_m_axi_rlast_i),
    .m_axi_rready_o  (b_m_axi_rready_o),
    .bank0_addr_o  (b_bank0_addr_o),
    .bank0_en_o    (b_bank0_en_o),
    .bank0_we_o    (b_bank0_we_o),
    .bank0_din_o   (b_bank0_din_o),
    .bank1_addr_o  (b_bank1_addr_o),
    .bank1_en_o    (b_bank1_en_o),
    .bank1_we_o    (b_bank1_we_o),
    .bank1_din_o   (b_bank1_din_o),
    .bank2_addr_o  (b_bank2_addr_o),
    .bank2_en_o    (b_bank2_en_o),
    .bank2_we_o    (b_bank2_we_o),
    .bank2_din_o   (b_bank2_din_o),
    .bank3_addr_o  (b_bank3_addr_o),
    .bank3_en_o    (b_bank3_en_o),
    .bank3_we_o    (b_bank3_we_o),
    .bank3_din_o   (b_bank3_din_o),
    .bank4_addr_o  (b_bank4_addr_o),
    .bank4_en_o    (b_bank4_en_o),
    .bank4_we_o    (b_bank4_we_o),
    .bank4_din_o   (b_bank4_din_o),
    .bank5_addr_o  (b_bank5_addr_o),
    .bank5_en_o    (b_bank5_en_o),
    .bank5_we_o    (b_bank5_we_o),
    .bank5_din_o   (b_bank5_din_o),
    .bank6_addr_o  (b_bank6_addr_o),
    .bank6_en_o    (b_bank6_en_o),
    .bank6_we_o    (b_bank6_we_o),
    .bank6_din_o   (b_bank6_din_o),
    .bank7_addr_o  (b_bank7_addr_o),
    .bank7_en_o    (b_bank7_en_o),
    .bank7_we_o    (b_bank7_we_o),
    .bank7_din_o   (b_bank7_din_o),
    .bank8_addr_o  (b_bank8_addr_o),
    .bank8_en_o    (b_bank8_en_o),
    .bank8_we_o    (b_bank8_we_o),
    .bank8_din_o   (b_bank8_din_o),
    .bank9_addr_o  (b_bank9_addr_o),
    .bank9_en_o    (b_bank9_en_o),
    .bank9_we_o    (b_bank9_we_o),
    .bank9_din_o   (b_bank9_din_o),
    .bank10_addr_o  (b_bank10_addr_o),
    .bank10_en_o    (b_bank10_en_o),
    .bank10_we_o    (b_bank10_we_o),
    .bank10_din_o   (b_bank10_din_o),
    .bank11_addr_o  (b_bank11_addr_o),
    .bank11_en_o    (b_bank11_en_o),
    .bank11_we_o    (b_bank11_we_o),
    .bank11_din_o   (b_bank11_din_o),
    .bank12_addr_o  (b_bank12_addr_o),
    .bank12_en_o    (b_bank12_en_o),
    .bank12_we_o    (b_bank12_we_o),
    .bank12_din_o   (b_bank12_din_o),
    .bank13_addr_o  (b_bank13_addr_o),
    .bank13_en_o    (b_bank13_en_o),
    .bank13_we_o    (b_bank13_we_o),
    .bank13_din_o   (b_bank13_din_o),
    .bank14_addr_o  (b_bank14_addr_o),
    .bank14_en_o    (b_bank14_en_o),
    .bank14_we_o    (b_bank14_we_o),
    .bank14_din_o   (b_bank14_din_o),
    .bank15_addr_o  (b_bank15_addr_o),
    .bank15_en_o    (b_bank15_en_o),
    .bank15_we_o    (b_bank15_we_o),
    .bank15_din_o   (b_bank15_din_o),
    .bank16_addr_o  (b_bank16_addr_o),
    .bank16_en_o    (b_bank16_en_o),
    .bank16_we_o    (b_bank16_we_o),
    .bank16_din_o   (b_bank16_din_o),
    .bank17_addr_o  (b_bank17_addr_o),
    .bank17_en_o    (b_bank17_en_o),
    .bank17_we_o    (b_bank17_we_o),
    .bank17_din_o   (b_bank17_din_o),
    .bank18_addr_o  (b_bank18_addr_o),
    .bank18_en_o    (b_bank18_en_o),
    .bank18_we_o    (b_bank18_we_o),
    .bank18_din_o   (b_bank18_din_o),
    .bank19_addr_o  (b_bank19_addr_o),
    .bank19_en_o    (b_bank19_en_o),
    .bank19_we_o    (b_bank19_we_o),
    .bank19_din_o   (b_bank19_din_o),
    .bank20_addr_o  (b_bank20_addr_o),
    .bank20_en_o    (b_bank20_en_o),
    .bank20_we_o    (b_bank20_we_o),
    .bank20_din_o   (b_bank20_din_o),
    .bank21_addr_o  (b_bank21_addr_o),
    .bank21_en_o    (b_bank21_en_o),
    .bank21_we_o    (b_bank21_we_o),
    .bank21_din_o   (b_bank21_din_o),
    .bank22_addr_o  (b_bank22_addr_o),
    .bank22_en_o    (b_bank22_en_o),
    .bank22_we_o    (b_bank22_we_o),
    .bank22_din_o   (b_bank22_din_o),
    .bank23_addr_o  (b_bank23_addr_o),
    .bank23_en_o    (b_bank23_en_o),
    .bank23_we_o    (b_bank23_we_o),
    .bank23_din_o   (b_bank23_din_o),
    .bank24_addr_o  (b_bank24_addr_o),
    .bank24_en_o    (b_bank24_en_o),
    .bank24_we_o    (b_bank24_we_o),
    .bank24_din_o   (b_bank24_din_o),
    .bank25_addr_o  (b_bank25_addr_o),
    .bank25_en_o    (b_bank25_en_o),
    .bank25_we_o    (b_bank25_we_o),
    .bank25_din_o   (b_bank25_din_o),
    .bank26_addr_o  (b_bank26_addr_o),
    .bank26_en_o    (b_bank26_en_o),
    .bank26_we_o    (b_bank26_we_o),
    .bank26_din_o   (b_bank26_din_o),
    .bank27_addr_o  (b_bank27_addr_o),
    .bank27_en_o    (b_bank27_en_o),
    .bank27_we_o    (b_bank27_we_o),
    .bank27_din_o   (b_bank27_din_o),
    .bank28_addr_o  (b_bank28_addr_o),
    .bank28_en_o    (b_bank28_en_o),
    .bank28_we_o    (b_bank28_we_o),
    .bank28_din_o   (b_bank28_din_o),
    .bank29_addr_o  (b_bank29_addr_o),
    .bank29_en_o    (b_bank29_en_o),
    .bank29_we_o    (b_bank29_we_o),
    .bank29_din_o   (b_bank29_din_o),
    .bank30_addr_o  (b_bank30_addr_o),
    .bank30_en_o    (b_bank30_en_o),
    .bank30_we_o    (b_bank30_we_o),
    .bank30_din_o   (b_bank30_din_o),
    .bank31_addr_o  (b_bank31_addr_o),
    .bank31_en_o    (b_bank31_en_o),
    .bank31_we_o    (b_bank31_we_o),
    .bank31_din_o   (b_bank31_din_o)
  );

  // Bat tay mmult_accel <-> AXI4_B_READER (ten khac nhau ca 2 phia, can cau noi tuong minh).
  assign b_base_addr_i   = b_base_addr_o;
  assign b_row_stride_i  = b_row_stride_o;
  assign b_num_rows_i    = b_num_rows_o;
  assign b_block_width_i = b_block_width_o;
  assign b_reload_req_i  = b_reload_req_o;
  assign b_loaded_i      = b_loaded_o;

  // ---- AXI4_C_WRITER (SUA LAN 16, 2026-08-18) + BFM AXI4 chi-ghi phuc vu no (thay hoan toan
  // gmemC/c_arr cu cua mmult_accel) ----
  // AXI4_C_WRITER la AXI4 master CHI GHI (AW+W+B, khong AR/R), non-outstanding (1 giao dich tai
  // 1 thoi diem, giong AXI4_A_READER/AXI4_B_READER). BFM dung style dang ky
  // (always @(posedge clk_i), nonblocking - AN TOAN khong can #1, khac han kieu task/blocking
  // cua gmemC cu) - da kiem chung dung 100% o bench/tb_axi4_c_writer.sv (PASS 11/11), tai su
  // dung nguyen logic FSM BFM_IDLE/BFM_W/BFM_B.
  logic [7:0] mem_gmemC [0:16383];

  typedef enum logic [1:0] {C_BFM_IDLE, C_BFM_W, C_BFM_B} c_bfm_state_e;
  c_bfm_state_e c_bfm_state_q;
  logic [31:0]  c_bfm_addr_q;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      c_bfm_state_q   <= C_BFM_IDLE;
      m_axi_awready_i <= 1'b1;
      m_axi_wready_i  <= 1'b0;
      m_axi_bvalid_i  <= 1'b0;
    end else begin
      case (c_bfm_state_q)
        C_BFM_IDLE: begin
          m_axi_awready_i <= 1'b1;
          if (m_axi_awvalid_o && m_axi_awready_i) begin
            c_bfm_addr_q    <= m_axi_awaddr_o;
            m_axi_awready_i <= 1'b0;
            m_axi_wready_i  <= 1'b1;
            c_bfm_state_q   <= C_BFM_W;

            gmemC_aw_burst_count++;
            $display("[GMEMC-AW] burst#%0d t=%0t addr=%0d", gmemC_aw_burst_count, $time,
                      m_axi_awaddr_o);
          end
        end
        // [SUA - 2026-08-23] AXI4_C_WRITER gio gop toi da 32 beat/burst (1 hang tile) thay vi
        // 1 beat/burst co dinh - phai lap nhan tung beat, tu tang dia chi +4 sau moi beat
        // (INCR), chi chuyen sang B khi thay WLAST=1 o beat vua nhan (khop dung FSM ST_W moi
        // cua axi4_c_writer.v, da kiem chung dung o bench/tb_axi4_c_writer.sv).
        C_BFM_W: begin
          if (m_axi_wvalid_o && m_axi_wready_i) begin
            for (int b = 0; b < 4; b++)
              if (m_axi_wstrb_o[b]) begin
                mem_gmemC[c_bfm_addr_q + b] <= m_axi_wdata_o[b*8 +: 8];
                gmemC_bytes_written++;
              end
            // In gia tri WDATA that cho burst dau tien (C[0][0], addr 0..3) de xac nhan gia
            // tri ghi that co dung khop [TILE-CAPTURE] pulse#0 hay khong.
            if (c_bfm_addr_q < 4)
              $display("[GMEMC-WDATA] t=%0t addr=%0d WSTRB=%b WDATA=%08h",
                        $time, c_bfm_addr_q, m_axi_wstrb_o, m_axi_wdata_o);
            if (m_axi_wlast_o) begin
              m_axi_wready_i <= 1'b0;
              m_axi_bvalid_i <= 1'b1;
              c_bfm_state_q  <= C_BFM_B;
            end else begin
              c_bfm_addr_q <= c_bfm_addr_q + 4;
            end
          end
        end
        C_BFM_B: begin
          if (m_axi_bvalid_i && m_axi_bready_o) begin
            m_axi_bvalid_i  <= 1'b0;
            m_axi_awready_i <= 1'b1;
            c_bfm_state_q   <= C_BFM_IDLE;
          end
        end
        default: c_bfm_state_q <= C_BFM_IDLE;
      endcase
    end
  end

  logic [31:0] c0_0_i;
  logic [31:0] c0_1_i;
  logic [31:0] c0_2_i;
  logic [31:0] c0_3_i;
  logic [31:0] c0_4_i;
  logic [31:0] c0_5_i;
  logic [31:0] c0_6_i;
  logic [31:0] c0_7_i;
  logic [31:0] c0_8_i;
  logic [31:0] c0_9_i;
  logic [31:0] c0_10_i;
  logic [31:0] c0_11_i;
  logic [31:0] c0_12_i;
  logic [31:0] c0_13_i;
  logic [31:0] c0_14_i;
  logic [31:0] c0_15_i;
  logic [31:0] c0_16_i;
  logic [31:0] c0_17_i;
  logic [31:0] c0_18_i;
  logic [31:0] c0_19_i;
  logic [31:0] c0_20_i;
  logic [31:0] c0_21_i;
  logic [31:0] c0_22_i;
  logic [31:0] c0_23_i;
  logic [31:0] c0_24_i;
  logic [31:0] c0_25_i;
  logic [31:0] c0_26_i;
  logic [31:0] c0_27_i;
  logic [31:0] c0_28_i;
  logic [31:0] c0_29_i;
  logic [31:0] c0_30_i;
  logic [31:0] c0_31_i;
  logic [31:0] c1_0_i;
  logic [31:0] c1_1_i;
  logic [31:0] c1_2_i;
  logic [31:0] c1_3_i;
  logic [31:0] c1_4_i;
  logic [31:0] c1_5_i;
  logic [31:0] c1_6_i;
  logic [31:0] c1_7_i;
  logic [31:0] c1_8_i;
  logic [31:0] c1_9_i;
  logic [31:0] c1_10_i;
  logic [31:0] c1_11_i;
  logic [31:0] c1_12_i;
  logic [31:0] c1_13_i;
  logic [31:0] c1_14_i;
  logic [31:0] c1_15_i;
  logic [31:0] c1_16_i;
  logic [31:0] c1_17_i;
  logic [31:0] c1_18_i;
  logic [31:0] c1_19_i;
  logic [31:0] c1_20_i;
  logic [31:0] c1_21_i;
  logic [31:0] c1_22_i;
  logic [31:0] c1_23_i;
  logic [31:0] c1_24_i;
  logic [31:0] c1_25_i;
  logic [31:0] c1_26_i;
  logic [31:0] c1_27_i;
  logic [31:0] c1_28_i;
  logic [31:0] c1_29_i;
  logic [31:0] c1_30_i;
  logic [31:0] c1_31_i;
  logic [31:0] c2_0_i;
  logic [31:0] c2_1_i;
  logic [31:0] c2_2_i;
  logic [31:0] c2_3_i;
  logic [31:0] c2_4_i;
  logic [31:0] c2_5_i;
  logic [31:0] c2_6_i;
  logic [31:0] c2_7_i;
  logic [31:0] c2_8_i;
  logic [31:0] c2_9_i;
  logic [31:0] c2_10_i;
  logic [31:0] c2_11_i;
  logic [31:0] c2_12_i;
  logic [31:0] c2_13_i;
  logic [31:0] c2_14_i;
  logic [31:0] c2_15_i;
  logic [31:0] c2_16_i;
  logic [31:0] c2_17_i;
  logic [31:0] c2_18_i;
  logic [31:0] c2_19_i;
  logic [31:0] c2_20_i;
  logic [31:0] c2_21_i;
  logic [31:0] c2_22_i;
  logic [31:0] c2_23_i;
  logic [31:0] c2_24_i;
  logic [31:0] c2_25_i;
  logic [31:0] c2_26_i;
  logic [31:0] c2_27_i;
  logic [31:0] c2_28_i;
  logic [31:0] c2_29_i;
  logic [31:0] c2_30_i;
  logic [31:0] c2_31_i;
  logic [31:0] c3_0_i;
  logic [31:0] c3_1_i;
  logic [31:0] c3_2_i;
  logic [31:0] c3_3_i;
  logic [31:0] c3_4_i;
  logic [31:0] c3_5_i;
  logic [31:0] c3_6_i;
  logic [31:0] c3_7_i;
  logic [31:0] c3_8_i;
  logic [31:0] c3_9_i;
  logic [31:0] c3_10_i;
  logic [31:0] c3_11_i;
  logic [31:0] c3_12_i;
  logic [31:0] c3_13_i;
  logic [31:0] c3_14_i;
  logic [31:0] c3_15_i;
  logic [31:0] c3_16_i;
  logic [31:0] c3_17_i;
  logic [31:0] c3_18_i;
  logic [31:0] c3_19_i;
  logic [31:0] c3_20_i;
  logic [31:0] c3_21_i;
  logic [31:0] c3_22_i;
  logic [31:0] c3_23_i;
  logic [31:0] c3_24_i;
  logic [31:0] c3_25_i;
  logic [31:0] c3_26_i;
  logic [31:0] c3_27_i;
  logic [31:0] c3_28_i;
  logic [31:0] c3_29_i;
  logic [31:0] c3_30_i;
  logic [31:0] c3_31_i;
  logic [31:0] c4_0_i;
  logic [31:0] c4_1_i;
  logic [31:0] c4_2_i;
  logic [31:0] c4_3_i;
  logic [31:0] c4_4_i;
  logic [31:0] c4_5_i;
  logic [31:0] c4_6_i;
  logic [31:0] c4_7_i;
  logic [31:0] c4_8_i;
  logic [31:0] c4_9_i;
  logic [31:0] c4_10_i;
  logic [31:0] c4_11_i;
  logic [31:0] c4_12_i;
  logic [31:0] c4_13_i;
  logic [31:0] c4_14_i;
  logic [31:0] c4_15_i;
  logic [31:0] c4_16_i;
  logic [31:0] c4_17_i;
  logic [31:0] c4_18_i;
  logic [31:0] c4_19_i;
  logic [31:0] c4_20_i;
  logic [31:0] c4_21_i;
  logic [31:0] c4_22_i;
  logic [31:0] c4_23_i;
  logic [31:0] c4_24_i;
  logic [31:0] c4_25_i;
  logic [31:0] c4_26_i;
  logic [31:0] c4_27_i;
  logic [31:0] c4_28_i;
  logic [31:0] c4_29_i;
  logic [31:0] c4_30_i;
  logic [31:0] c4_31_i;
  logic [31:0] c5_0_i;
  logic [31:0] c5_1_i;
  logic [31:0] c5_2_i;
  logic [31:0] c5_3_i;
  logic [31:0] c5_4_i;
  logic [31:0] c5_5_i;
  logic [31:0] c5_6_i;
  logic [31:0] c5_7_i;
  logic [31:0] c5_8_i;
  logic [31:0] c5_9_i;
  logic [31:0] c5_10_i;
  logic [31:0] c5_11_i;
  logic [31:0] c5_12_i;
  logic [31:0] c5_13_i;
  logic [31:0] c5_14_i;
  logic [31:0] c5_15_i;
  logic [31:0] c5_16_i;
  logic [31:0] c5_17_i;
  logic [31:0] c5_18_i;
  logic [31:0] c5_19_i;
  logic [31:0] c5_20_i;
  logic [31:0] c5_21_i;
  logic [31:0] c5_22_i;
  logic [31:0] c5_23_i;
  logic [31:0] c5_24_i;
  logic [31:0] c5_25_i;
  logic [31:0] c5_26_i;
  logic [31:0] c5_27_i;
  logic [31:0] c5_28_i;
  logic [31:0] c5_29_i;
  logic [31:0] c5_30_i;
  logic [31:0] c5_31_i;
  logic [31:0] c6_0_i;
  logic [31:0] c6_1_i;
  logic [31:0] c6_2_i;
  logic [31:0] c6_3_i;
  logic [31:0] c6_4_i;
  logic [31:0] c6_5_i;
  logic [31:0] c6_6_i;
  logic [31:0] c6_7_i;
  logic [31:0] c6_8_i;
  logic [31:0] c6_9_i;
  logic [31:0] c6_10_i;
  logic [31:0] c6_11_i;
  logic [31:0] c6_12_i;
  logic [31:0] c6_13_i;
  logic [31:0] c6_14_i;
  logic [31:0] c6_15_i;
  logic [31:0] c6_16_i;
  logic [31:0] c6_17_i;
  logic [31:0] c6_18_i;
  logic [31:0] c6_19_i;
  logic [31:0] c6_20_i;
  logic [31:0] c6_21_i;
  logic [31:0] c6_22_i;
  logic [31:0] c6_23_i;
  logic [31:0] c6_24_i;
  logic [31:0] c6_25_i;
  logic [31:0] c6_26_i;
  logic [31:0] c6_27_i;
  logic [31:0] c6_28_i;
  logic [31:0] c6_29_i;
  logic [31:0] c6_30_i;
  logic [31:0] c6_31_i;
  logic [31:0] c7_0_i;
  logic [31:0] c7_1_i;
  logic [31:0] c7_2_i;
  logic [31:0] c7_3_i;
  logic [31:0] c7_4_i;
  logic [31:0] c7_5_i;
  logic [31:0] c7_6_i;
  logic [31:0] c7_7_i;
  logic [31:0] c7_8_i;
  logic [31:0] c7_9_i;
  logic [31:0] c7_10_i;
  logic [31:0] c7_11_i;
  logic [31:0] c7_12_i;
  logic [31:0] c7_13_i;
  logic [31:0] c7_14_i;
  logic [31:0] c7_15_i;
  logic [31:0] c7_16_i;
  logic [31:0] c7_17_i;
  logic [31:0] c7_18_i;
  logic [31:0] c7_19_i;
  logic [31:0] c7_20_i;
  logic [31:0] c7_21_i;
  logic [31:0] c7_22_i;
  logic [31:0] c7_23_i;
  logic [31:0] c7_24_i;
  logic [31:0] c7_25_i;
  logic [31:0] c7_26_i;
  logic [31:0] c7_27_i;
  logic [31:0] c7_28_i;
  logic [31:0] c7_29_i;
  logic [31:0] c7_30_i;
  logic [31:0] c7_31_i;
  logic [31:0] c8_0_i;
  logic [31:0] c8_1_i;
  logic [31:0] c8_2_i;
  logic [31:0] c8_3_i;
  logic [31:0] c8_4_i;
  logic [31:0] c8_5_i;
  logic [31:0] c8_6_i;
  logic [31:0] c8_7_i;
  logic [31:0] c8_8_i;
  logic [31:0] c8_9_i;
  logic [31:0] c8_10_i;
  logic [31:0] c8_11_i;
  logic [31:0] c8_12_i;
  logic [31:0] c8_13_i;
  logic [31:0] c8_14_i;
  logic [31:0] c8_15_i;
  logic [31:0] c8_16_i;
  logic [31:0] c8_17_i;
  logic [31:0] c8_18_i;
  logic [31:0] c8_19_i;
  logic [31:0] c8_20_i;
  logic [31:0] c8_21_i;
  logic [31:0] c8_22_i;
  logic [31:0] c8_23_i;
  logic [31:0] c8_24_i;
  logic [31:0] c8_25_i;
  logic [31:0] c8_26_i;
  logic [31:0] c8_27_i;
  logic [31:0] c8_28_i;
  logic [31:0] c8_29_i;
  logic [31:0] c8_30_i;
  logic [31:0] c8_31_i;
  logic [31:0] c9_0_i;
  logic [31:0] c9_1_i;
  logic [31:0] c9_2_i;
  logic [31:0] c9_3_i;
  logic [31:0] c9_4_i;
  logic [31:0] c9_5_i;
  logic [31:0] c9_6_i;
  logic [31:0] c9_7_i;
  logic [31:0] c9_8_i;
  logic [31:0] c9_9_i;
  logic [31:0] c9_10_i;
  logic [31:0] c9_11_i;
  logic [31:0] c9_12_i;
  logic [31:0] c9_13_i;
  logic [31:0] c9_14_i;
  logic [31:0] c9_15_i;
  logic [31:0] c9_16_i;
  logic [31:0] c9_17_i;
  logic [31:0] c9_18_i;
  logic [31:0] c9_19_i;
  logic [31:0] c9_20_i;
  logic [31:0] c9_21_i;
  logic [31:0] c9_22_i;
  logic [31:0] c9_23_i;
  logic [31:0] c9_24_i;
  logic [31:0] c9_25_i;
  logic [31:0] c9_26_i;
  logic [31:0] c9_27_i;
  logic [31:0] c9_28_i;
  logic [31:0] c9_29_i;
  logic [31:0] c9_30_i;
  logic [31:0] c9_31_i;
  logic [31:0] c10_0_i;
  logic [31:0] c10_1_i;
  logic [31:0] c10_2_i;
  logic [31:0] c10_3_i;
  logic [31:0] c10_4_i;
  logic [31:0] c10_5_i;
  logic [31:0] c10_6_i;
  logic [31:0] c10_7_i;
  logic [31:0] c10_8_i;
  logic [31:0] c10_9_i;
  logic [31:0] c10_10_i;
  logic [31:0] c10_11_i;
  logic [31:0] c10_12_i;
  logic [31:0] c10_13_i;
  logic [31:0] c10_14_i;
  logic [31:0] c10_15_i;
  logic [31:0] c10_16_i;
  logic [31:0] c10_17_i;
  logic [31:0] c10_18_i;
  logic [31:0] c10_19_i;
  logic [31:0] c10_20_i;
  logic [31:0] c10_21_i;
  logic [31:0] c10_22_i;
  logic [31:0] c10_23_i;
  logic [31:0] c10_24_i;
  logic [31:0] c10_25_i;
  logic [31:0] c10_26_i;
  logic [31:0] c10_27_i;
  logic [31:0] c10_28_i;
  logic [31:0] c10_29_i;
  logic [31:0] c10_30_i;
  logic [31:0] c10_31_i;
  logic [31:0] c11_0_i;
  logic [31:0] c11_1_i;
  logic [31:0] c11_2_i;
  logic [31:0] c11_3_i;
  logic [31:0] c11_4_i;
  logic [31:0] c11_5_i;
  logic [31:0] c11_6_i;
  logic [31:0] c11_7_i;
  logic [31:0] c11_8_i;
  logic [31:0] c11_9_i;
  logic [31:0] c11_10_i;
  logic [31:0] c11_11_i;
  logic [31:0] c11_12_i;
  logic [31:0] c11_13_i;
  logic [31:0] c11_14_i;
  logic [31:0] c11_15_i;
  logic [31:0] c11_16_i;
  logic [31:0] c11_17_i;
  logic [31:0] c11_18_i;
  logic [31:0] c11_19_i;
  logic [31:0] c11_20_i;
  logic [31:0] c11_21_i;
  logic [31:0] c11_22_i;
  logic [31:0] c11_23_i;
  logic [31:0] c11_24_i;
  logic [31:0] c11_25_i;
  logic [31:0] c11_26_i;
  logic [31:0] c11_27_i;
  logic [31:0] c11_28_i;
  logic [31:0] c11_29_i;
  logic [31:0] c11_30_i;
  logic [31:0] c11_31_i;
  logic [31:0] c12_0_i;
  logic [31:0] c12_1_i;
  logic [31:0] c12_2_i;
  logic [31:0] c12_3_i;
  logic [31:0] c12_4_i;
  logic [31:0] c12_5_i;
  logic [31:0] c12_6_i;
  logic [31:0] c12_7_i;
  logic [31:0] c12_8_i;
  logic [31:0] c12_9_i;
  logic [31:0] c12_10_i;
  logic [31:0] c12_11_i;
  logic [31:0] c12_12_i;
  logic [31:0] c12_13_i;
  logic [31:0] c12_14_i;
  logic [31:0] c12_15_i;
  logic [31:0] c12_16_i;
  logic [31:0] c12_17_i;
  logic [31:0] c12_18_i;
  logic [31:0] c12_19_i;
  logic [31:0] c12_20_i;
  logic [31:0] c12_21_i;
  logic [31:0] c12_22_i;
  logic [31:0] c12_23_i;
  logic [31:0] c12_24_i;
  logic [31:0] c12_25_i;
  logic [31:0] c12_26_i;
  logic [31:0] c12_27_i;
  logic [31:0] c12_28_i;
  logic [31:0] c12_29_i;
  logic [31:0] c12_30_i;
  logic [31:0] c12_31_i;
  logic [31:0] c13_0_i;
  logic [31:0] c13_1_i;
  logic [31:0] c13_2_i;
  logic [31:0] c13_3_i;
  logic [31:0] c13_4_i;
  logic [31:0] c13_5_i;
  logic [31:0] c13_6_i;
  logic [31:0] c13_7_i;
  logic [31:0] c13_8_i;
  logic [31:0] c13_9_i;
  logic [31:0] c13_10_i;
  logic [31:0] c13_11_i;
  logic [31:0] c13_12_i;
  logic [31:0] c13_13_i;
  logic [31:0] c13_14_i;
  logic [31:0] c13_15_i;
  logic [31:0] c13_16_i;
  logic [31:0] c13_17_i;
  logic [31:0] c13_18_i;
  logic [31:0] c13_19_i;
  logic [31:0] c13_20_i;
  logic [31:0] c13_21_i;
  logic [31:0] c13_22_i;
  logic [31:0] c13_23_i;
  logic [31:0] c13_24_i;
  logic [31:0] c13_25_i;
  logic [31:0] c13_26_i;
  logic [31:0] c13_27_i;
  logic [31:0] c13_28_i;
  logic [31:0] c13_29_i;
  logic [31:0] c13_30_i;
  logic [31:0] c13_31_i;
  logic [31:0] c14_0_i;
  logic [31:0] c14_1_i;
  logic [31:0] c14_2_i;
  logic [31:0] c14_3_i;
  logic [31:0] c14_4_i;
  logic [31:0] c14_5_i;
  logic [31:0] c14_6_i;
  logic [31:0] c14_7_i;
  logic [31:0] c14_8_i;
  logic [31:0] c14_9_i;
  logic [31:0] c14_10_i;
  logic [31:0] c14_11_i;
  logic [31:0] c14_12_i;
  logic [31:0] c14_13_i;
  logic [31:0] c14_14_i;
  logic [31:0] c14_15_i;
  logic [31:0] c14_16_i;
  logic [31:0] c14_17_i;
  logic [31:0] c14_18_i;
  logic [31:0] c14_19_i;
  logic [31:0] c14_20_i;
  logic [31:0] c14_21_i;
  logic [31:0] c14_22_i;
  logic [31:0] c14_23_i;
  logic [31:0] c14_24_i;
  logic [31:0] c14_25_i;
  logic [31:0] c14_26_i;
  logic [31:0] c14_27_i;
  logic [31:0] c14_28_i;
  logic [31:0] c14_29_i;
  logic [31:0] c14_30_i;
  logic [31:0] c14_31_i;
  logic [31:0] c15_0_i;
  logic [31:0] c15_1_i;
  logic [31:0] c15_2_i;
  logic [31:0] c15_3_i;
  logic [31:0] c15_4_i;
  logic [31:0] c15_5_i;
  logic [31:0] c15_6_i;
  logic [31:0] c15_7_i;
  logic [31:0] c15_8_i;
  logic [31:0] c15_9_i;
  logic [31:0] c15_10_i;
  logic [31:0] c15_11_i;
  logic [31:0] c15_12_i;
  logic [31:0] c15_13_i;
  logic [31:0] c15_14_i;
  logic [31:0] c15_15_i;
  logic [31:0] c15_16_i;
  logic [31:0] c15_17_i;
  logic [31:0] c15_18_i;
  logic [31:0] c15_19_i;
  logic [31:0] c15_20_i;
  logic [31:0] c15_21_i;
  logic [31:0] c15_22_i;
  logic [31:0] c15_23_i;
  logic [31:0] c15_24_i;
  logic [31:0] c15_25_i;
  logic [31:0] c15_26_i;
  logic [31:0] c15_27_i;
  logic [31:0] c15_28_i;
  logic [31:0] c15_29_i;
  logic [31:0] c15_30_i;
  logic [31:0] c15_31_i;
  logic [31:0] c16_0_i;
  logic [31:0] c16_1_i;
  logic [31:0] c16_2_i;
  logic [31:0] c16_3_i;
  logic [31:0] c16_4_i;
  logic [31:0] c16_5_i;
  logic [31:0] c16_6_i;
  logic [31:0] c16_7_i;
  logic [31:0] c16_8_i;
  logic [31:0] c16_9_i;
  logic [31:0] c16_10_i;
  logic [31:0] c16_11_i;
  logic [31:0] c16_12_i;
  logic [31:0] c16_13_i;
  logic [31:0] c16_14_i;
  logic [31:0] c16_15_i;
  logic [31:0] c16_16_i;
  logic [31:0] c16_17_i;
  logic [31:0] c16_18_i;
  logic [31:0] c16_19_i;
  logic [31:0] c16_20_i;
  logic [31:0] c16_21_i;
  logic [31:0] c16_22_i;
  logic [31:0] c16_23_i;
  logic [31:0] c16_24_i;
  logic [31:0] c16_25_i;
  logic [31:0] c16_26_i;
  logic [31:0] c16_27_i;
  logic [31:0] c16_28_i;
  logic [31:0] c16_29_i;
  logic [31:0] c16_30_i;
  logic [31:0] c16_31_i;
  logic [31:0] c17_0_i;
  logic [31:0] c17_1_i;
  logic [31:0] c17_2_i;
  logic [31:0] c17_3_i;
  logic [31:0] c17_4_i;
  logic [31:0] c17_5_i;
  logic [31:0] c17_6_i;
  logic [31:0] c17_7_i;
  logic [31:0] c17_8_i;
  logic [31:0] c17_9_i;
  logic [31:0] c17_10_i;
  logic [31:0] c17_11_i;
  logic [31:0] c17_12_i;
  logic [31:0] c17_13_i;
  logic [31:0] c17_14_i;
  logic [31:0] c17_15_i;
  logic [31:0] c17_16_i;
  logic [31:0] c17_17_i;
  logic [31:0] c17_18_i;
  logic [31:0] c17_19_i;
  logic [31:0] c17_20_i;
  logic [31:0] c17_21_i;
  logic [31:0] c17_22_i;
  logic [31:0] c17_23_i;
  logic [31:0] c17_24_i;
  logic [31:0] c17_25_i;
  logic [31:0] c17_26_i;
  logic [31:0] c17_27_i;
  logic [31:0] c17_28_i;
  logic [31:0] c17_29_i;
  logic [31:0] c17_30_i;
  logic [31:0] c17_31_i;
  logic [31:0] c18_0_i;
  logic [31:0] c18_1_i;
  logic [31:0] c18_2_i;
  logic [31:0] c18_3_i;
  logic [31:0] c18_4_i;
  logic [31:0] c18_5_i;
  logic [31:0] c18_6_i;
  logic [31:0] c18_7_i;
  logic [31:0] c18_8_i;
  logic [31:0] c18_9_i;
  logic [31:0] c18_10_i;
  logic [31:0] c18_11_i;
  logic [31:0] c18_12_i;
  logic [31:0] c18_13_i;
  logic [31:0] c18_14_i;
  logic [31:0] c18_15_i;
  logic [31:0] c18_16_i;
  logic [31:0] c18_17_i;
  logic [31:0] c18_18_i;
  logic [31:0] c18_19_i;
  logic [31:0] c18_20_i;
  logic [31:0] c18_21_i;
  logic [31:0] c18_22_i;
  logic [31:0] c18_23_i;
  logic [31:0] c18_24_i;
  logic [31:0] c18_25_i;
  logic [31:0] c18_26_i;
  logic [31:0] c18_27_i;
  logic [31:0] c18_28_i;
  logic [31:0] c18_29_i;
  logic [31:0] c18_30_i;
  logic [31:0] c18_31_i;
  logic [31:0] c19_0_i;
  logic [31:0] c19_1_i;
  logic [31:0] c19_2_i;
  logic [31:0] c19_3_i;
  logic [31:0] c19_4_i;
  logic [31:0] c19_5_i;
  logic [31:0] c19_6_i;
  logic [31:0] c19_7_i;
  logic [31:0] c19_8_i;
  logic [31:0] c19_9_i;
  logic [31:0] c19_10_i;
  logic [31:0] c19_11_i;
  logic [31:0] c19_12_i;
  logic [31:0] c19_13_i;
  logic [31:0] c19_14_i;
  logic [31:0] c19_15_i;
  logic [31:0] c19_16_i;
  logic [31:0] c19_17_i;
  logic [31:0] c19_18_i;
  logic [31:0] c19_19_i;
  logic [31:0] c19_20_i;
  logic [31:0] c19_21_i;
  logic [31:0] c19_22_i;
  logic [31:0] c19_23_i;
  logic [31:0] c19_24_i;
  logic [31:0] c19_25_i;
  logic [31:0] c19_26_i;
  logic [31:0] c19_27_i;
  logic [31:0] c19_28_i;
  logic [31:0] c19_29_i;
  logic [31:0] c19_30_i;
  logic [31:0] c19_31_i;
  logic [31:0] c20_0_i;
  logic [31:0] c20_1_i;
  logic [31:0] c20_2_i;
  logic [31:0] c20_3_i;
  logic [31:0] c20_4_i;
  logic [31:0] c20_5_i;
  logic [31:0] c20_6_i;
  logic [31:0] c20_7_i;
  logic [31:0] c20_8_i;
  logic [31:0] c20_9_i;
  logic [31:0] c20_10_i;
  logic [31:0] c20_11_i;
  logic [31:0] c20_12_i;
  logic [31:0] c20_13_i;
  logic [31:0] c20_14_i;
  logic [31:0] c20_15_i;
  logic [31:0] c20_16_i;
  logic [31:0] c20_17_i;
  logic [31:0] c20_18_i;
  logic [31:0] c20_19_i;
  logic [31:0] c20_20_i;
  logic [31:0] c20_21_i;
  logic [31:0] c20_22_i;
  logic [31:0] c20_23_i;
  logic [31:0] c20_24_i;
  logic [31:0] c20_25_i;
  logic [31:0] c20_26_i;
  logic [31:0] c20_27_i;
  logic [31:0] c20_28_i;
  logic [31:0] c20_29_i;
  logic [31:0] c20_30_i;
  logic [31:0] c20_31_i;
  logic [31:0] c21_0_i;
  logic [31:0] c21_1_i;
  logic [31:0] c21_2_i;
  logic [31:0] c21_3_i;
  logic [31:0] c21_4_i;
  logic [31:0] c21_5_i;
  logic [31:0] c21_6_i;
  logic [31:0] c21_7_i;
  logic [31:0] c21_8_i;
  logic [31:0] c21_9_i;
  logic [31:0] c21_10_i;
  logic [31:0] c21_11_i;
  logic [31:0] c21_12_i;
  logic [31:0] c21_13_i;
  logic [31:0] c21_14_i;
  logic [31:0] c21_15_i;
  logic [31:0] c21_16_i;
  logic [31:0] c21_17_i;
  logic [31:0] c21_18_i;
  logic [31:0] c21_19_i;
  logic [31:0] c21_20_i;
  logic [31:0] c21_21_i;
  logic [31:0] c21_22_i;
  logic [31:0] c21_23_i;
  logic [31:0] c21_24_i;
  logic [31:0] c21_25_i;
  logic [31:0] c21_26_i;
  logic [31:0] c21_27_i;
  logic [31:0] c21_28_i;
  logic [31:0] c21_29_i;
  logic [31:0] c21_30_i;
  logic [31:0] c21_31_i;
  logic [31:0] c22_0_i;
  logic [31:0] c22_1_i;
  logic [31:0] c22_2_i;
  logic [31:0] c22_3_i;
  logic [31:0] c22_4_i;
  logic [31:0] c22_5_i;
  logic [31:0] c22_6_i;
  logic [31:0] c22_7_i;
  logic [31:0] c22_8_i;
  logic [31:0] c22_9_i;
  logic [31:0] c22_10_i;
  logic [31:0] c22_11_i;
  logic [31:0] c22_12_i;
  logic [31:0] c22_13_i;
  logic [31:0] c22_14_i;
  logic [31:0] c22_15_i;
  logic [31:0] c22_16_i;
  logic [31:0] c22_17_i;
  logic [31:0] c22_18_i;
  logic [31:0] c22_19_i;
  logic [31:0] c22_20_i;
  logic [31:0] c22_21_i;
  logic [31:0] c22_22_i;
  logic [31:0] c22_23_i;
  logic [31:0] c22_24_i;
  logic [31:0] c22_25_i;
  logic [31:0] c22_26_i;
  logic [31:0] c22_27_i;
  logic [31:0] c22_28_i;
  logic [31:0] c22_29_i;
  logic [31:0] c22_30_i;
  logic [31:0] c22_31_i;
  logic [31:0] c23_0_i;
  logic [31:0] c23_1_i;
  logic [31:0] c23_2_i;
  logic [31:0] c23_3_i;
  logic [31:0] c23_4_i;
  logic [31:0] c23_5_i;
  logic [31:0] c23_6_i;
  logic [31:0] c23_7_i;
  logic [31:0] c23_8_i;
  logic [31:0] c23_9_i;
  logic [31:0] c23_10_i;
  logic [31:0] c23_11_i;
  logic [31:0] c23_12_i;
  logic [31:0] c23_13_i;
  logic [31:0] c23_14_i;
  logic [31:0] c23_15_i;
  logic [31:0] c23_16_i;
  logic [31:0] c23_17_i;
  logic [31:0] c23_18_i;
  logic [31:0] c23_19_i;
  logic [31:0] c23_20_i;
  logic [31:0] c23_21_i;
  logic [31:0] c23_22_i;
  logic [31:0] c23_23_i;
  logic [31:0] c23_24_i;
  logic [31:0] c23_25_i;
  logic [31:0] c23_26_i;
  logic [31:0] c23_27_i;
  logic [31:0] c23_28_i;
  logic [31:0] c23_29_i;
  logic [31:0] c23_30_i;
  logic [31:0] c23_31_i;
  logic [31:0] c24_0_i;
  logic [31:0] c24_1_i;
  logic [31:0] c24_2_i;
  logic [31:0] c24_3_i;
  logic [31:0] c24_4_i;
  logic [31:0] c24_5_i;
  logic [31:0] c24_6_i;
  logic [31:0] c24_7_i;
  logic [31:0] c24_8_i;
  logic [31:0] c24_9_i;
  logic [31:0] c24_10_i;
  logic [31:0] c24_11_i;
  logic [31:0] c24_12_i;
  logic [31:0] c24_13_i;
  logic [31:0] c24_14_i;
  logic [31:0] c24_15_i;
  logic [31:0] c24_16_i;
  logic [31:0] c24_17_i;
  logic [31:0] c24_18_i;
  logic [31:0] c24_19_i;
  logic [31:0] c24_20_i;
  logic [31:0] c24_21_i;
  logic [31:0] c24_22_i;
  logic [31:0] c24_23_i;
  logic [31:0] c24_24_i;
  logic [31:0] c24_25_i;
  logic [31:0] c24_26_i;
  logic [31:0] c24_27_i;
  logic [31:0] c24_28_i;
  logic [31:0] c24_29_i;
  logic [31:0] c24_30_i;
  logic [31:0] c24_31_i;
  logic [31:0] c25_0_i;
  logic [31:0] c25_1_i;
  logic [31:0] c25_2_i;
  logic [31:0] c25_3_i;
  logic [31:0] c25_4_i;
  logic [31:0] c25_5_i;
  logic [31:0] c25_6_i;
  logic [31:0] c25_7_i;
  logic [31:0] c25_8_i;
  logic [31:0] c25_9_i;
  logic [31:0] c25_10_i;
  logic [31:0] c25_11_i;
  logic [31:0] c25_12_i;
  logic [31:0] c25_13_i;
  logic [31:0] c25_14_i;
  logic [31:0] c25_15_i;
  logic [31:0] c25_16_i;
  logic [31:0] c25_17_i;
  logic [31:0] c25_18_i;
  logic [31:0] c25_19_i;
  logic [31:0] c25_20_i;
  logic [31:0] c25_21_i;
  logic [31:0] c25_22_i;
  logic [31:0] c25_23_i;
  logic [31:0] c25_24_i;
  logic [31:0] c25_25_i;
  logic [31:0] c25_26_i;
  logic [31:0] c25_27_i;
  logic [31:0] c25_28_i;
  logic [31:0] c25_29_i;
  logic [31:0] c25_30_i;
  logic [31:0] c25_31_i;
  logic [31:0] c26_0_i;
  logic [31:0] c26_1_i;
  logic [31:0] c26_2_i;
  logic [31:0] c26_3_i;
  logic [31:0] c26_4_i;
  logic [31:0] c26_5_i;
  logic [31:0] c26_6_i;
  logic [31:0] c26_7_i;
  logic [31:0] c26_8_i;
  logic [31:0] c26_9_i;
  logic [31:0] c26_10_i;
  logic [31:0] c26_11_i;
  logic [31:0] c26_12_i;
  logic [31:0] c26_13_i;
  logic [31:0] c26_14_i;
  logic [31:0] c26_15_i;
  logic [31:0] c26_16_i;
  logic [31:0] c26_17_i;
  logic [31:0] c26_18_i;
  logic [31:0] c26_19_i;
  logic [31:0] c26_20_i;
  logic [31:0] c26_21_i;
  logic [31:0] c26_22_i;
  logic [31:0] c26_23_i;
  logic [31:0] c26_24_i;
  logic [31:0] c26_25_i;
  logic [31:0] c26_26_i;
  logic [31:0] c26_27_i;
  logic [31:0] c26_28_i;
  logic [31:0] c26_29_i;
  logic [31:0] c26_30_i;
  logic [31:0] c26_31_i;
  logic [31:0] c27_0_i;
  logic [31:0] c27_1_i;
  logic [31:0] c27_2_i;
  logic [31:0] c27_3_i;
  logic [31:0] c27_4_i;
  logic [31:0] c27_5_i;
  logic [31:0] c27_6_i;
  logic [31:0] c27_7_i;
  logic [31:0] c27_8_i;
  logic [31:0] c27_9_i;
  logic [31:0] c27_10_i;
  logic [31:0] c27_11_i;
  logic [31:0] c27_12_i;
  logic [31:0] c27_13_i;
  logic [31:0] c27_14_i;
  logic [31:0] c27_15_i;
  logic [31:0] c27_16_i;
  logic [31:0] c27_17_i;
  logic [31:0] c27_18_i;
  logic [31:0] c27_19_i;
  logic [31:0] c27_20_i;
  logic [31:0] c27_21_i;
  logic [31:0] c27_22_i;
  logic [31:0] c27_23_i;
  logic [31:0] c27_24_i;
  logic [31:0] c27_25_i;
  logic [31:0] c27_26_i;
  logic [31:0] c27_27_i;
  logic [31:0] c27_28_i;
  logic [31:0] c27_29_i;
  logic [31:0] c27_30_i;
  logic [31:0] c27_31_i;
  logic [31:0] c28_0_i;
  logic [31:0] c28_1_i;
  logic [31:0] c28_2_i;
  logic [31:0] c28_3_i;
  logic [31:0] c28_4_i;
  logic [31:0] c28_5_i;
  logic [31:0] c28_6_i;
  logic [31:0] c28_7_i;
  logic [31:0] c28_8_i;
  logic [31:0] c28_9_i;
  logic [31:0] c28_10_i;
  logic [31:0] c28_11_i;
  logic [31:0] c28_12_i;
  logic [31:0] c28_13_i;
  logic [31:0] c28_14_i;
  logic [31:0] c28_15_i;
  logic [31:0] c28_16_i;
  logic [31:0] c28_17_i;
  logic [31:0] c28_18_i;
  logic [31:0] c28_19_i;
  logic [31:0] c28_20_i;
  logic [31:0] c28_21_i;
  logic [31:0] c28_22_i;
  logic [31:0] c28_23_i;
  logic [31:0] c28_24_i;
  logic [31:0] c28_25_i;
  logic [31:0] c28_26_i;
  logic [31:0] c28_27_i;
  logic [31:0] c28_28_i;
  logic [31:0] c28_29_i;
  logic [31:0] c28_30_i;
  logic [31:0] c28_31_i;
  logic [31:0] c29_0_i;
  logic [31:0] c29_1_i;
  logic [31:0] c29_2_i;
  logic [31:0] c29_3_i;
  logic [31:0] c29_4_i;
  logic [31:0] c29_5_i;
  logic [31:0] c29_6_i;
  logic [31:0] c29_7_i;
  logic [31:0] c29_8_i;
  logic [31:0] c29_9_i;
  logic [31:0] c29_10_i;
  logic [31:0] c29_11_i;
  logic [31:0] c29_12_i;
  logic [31:0] c29_13_i;
  logic [31:0] c29_14_i;
  logic [31:0] c29_15_i;
  logic [31:0] c29_16_i;
  logic [31:0] c29_17_i;
  logic [31:0] c29_18_i;
  logic [31:0] c29_19_i;
  logic [31:0] c29_20_i;
  logic [31:0] c29_21_i;
  logic [31:0] c29_22_i;
  logic [31:0] c29_23_i;
  logic [31:0] c29_24_i;
  logic [31:0] c29_25_i;
  logic [31:0] c29_26_i;
  logic [31:0] c29_27_i;
  logic [31:0] c29_28_i;
  logic [31:0] c29_29_i;
  logic [31:0] c29_30_i;
  logic [31:0] c29_31_i;
  logic [31:0] c30_0_i;
  logic [31:0] c30_1_i;
  logic [31:0] c30_2_i;
  logic [31:0] c30_3_i;
  logic [31:0] c30_4_i;
  logic [31:0] c30_5_i;
  logic [31:0] c30_6_i;
  logic [31:0] c30_7_i;
  logic [31:0] c30_8_i;
  logic [31:0] c30_9_i;
  logic [31:0] c30_10_i;
  logic [31:0] c30_11_i;
  logic [31:0] c30_12_i;
  logic [31:0] c30_13_i;
  logic [31:0] c30_14_i;
  logic [31:0] c30_15_i;
  logic [31:0] c30_16_i;
  logic [31:0] c30_17_i;
  logic [31:0] c30_18_i;
  logic [31:0] c30_19_i;
  logic [31:0] c30_20_i;
  logic [31:0] c30_21_i;
  logic [31:0] c30_22_i;
  logic [31:0] c30_23_i;
  logic [31:0] c30_24_i;
  logic [31:0] c30_25_i;
  logic [31:0] c30_26_i;
  logic [31:0] c30_27_i;
  logic [31:0] c30_28_i;
  logic [31:0] c30_29_i;
  logic [31:0] c30_30_i;
  logic [31:0] c30_31_i;
  logic [31:0] c31_0_i;
  logic [31:0] c31_1_i;
  logic [31:0] c31_2_i;
  logic [31:0] c31_3_i;
  logic [31:0] c31_4_i;
  logic [31:0] c31_5_i;
  logic [31:0] c31_6_i;
  logic [31:0] c31_7_i;
  logic [31:0] c31_8_i;
  logic [31:0] c31_9_i;
  logic [31:0] c31_10_i;
  logic [31:0] c31_11_i;
  logic [31:0] c31_12_i;
  logic [31:0] c31_13_i;
  logic [31:0] c31_14_i;
  logic [31:0] c31_15_i;
  logic [31:0] c31_16_i;
  logic [31:0] c31_17_i;
  logic [31:0] c31_18_i;
  logic [31:0] c31_19_i;
  logic [31:0] c31_20_i;
  logic [31:0] c31_21_i;
  logic [31:0] c31_22_i;
  logic [31:0] c31_23_i;
  logic [31:0] c31_24_i;
  logic [31:0] c31_25_i;
  logic [31:0] c31_26_i;
  logic [31:0] c31_27_i;
  logic [31:0] c31_28_i;
  logic [31:0] c31_29_i;
  logic [31:0] c31_30_i;
  logic [31:0] c31_31_i;

  assign c0_0_i = c_arr_0_0;
  assign c0_1_i = c_arr_0_1;
  assign c0_2_i = c_arr_0_2;
  assign c0_3_i = c_arr_0_3;
  assign c0_4_i = c_arr_0_4;
  assign c0_5_i = c_arr_0_5;
  assign c0_6_i = c_arr_0_6;
  assign c0_7_i = c_arr_0_7;
  assign c0_8_i = c_arr_0_8;
  assign c0_9_i = c_arr_0_9;
  assign c0_10_i = c_arr_0_10;
  assign c0_11_i = c_arr_0_11;
  assign c0_12_i = c_arr_0_12;
  assign c0_13_i = c_arr_0_13;
  assign c0_14_i = c_arr_0_14;
  assign c0_15_i = c_arr_0_15;
  assign c0_16_i = c_arr_0_16;
  assign c0_17_i = c_arr_0_17;
  assign c0_18_i = c_arr_0_18;
  assign c0_19_i = c_arr_0_19;
  assign c0_20_i = c_arr_0_20;
  assign c0_21_i = c_arr_0_21;
  assign c0_22_i = c_arr_0_22;
  assign c0_23_i = c_arr_0_23;
  assign c0_24_i = c_arr_0_24;
  assign c0_25_i = c_arr_0_25;
  assign c0_26_i = c_arr_0_26;
  assign c0_27_i = c_arr_0_27;
  assign c0_28_i = c_arr_0_28;
  assign c0_29_i = c_arr_0_29;
  assign c0_30_i = c_arr_0_30;
  assign c0_31_i = c_arr_0_31;
  assign c1_0_i = c_arr_1_0;
  assign c1_1_i = c_arr_1_1;
  assign c1_2_i = c_arr_1_2;
  assign c1_3_i = c_arr_1_3;
  assign c1_4_i = c_arr_1_4;
  assign c1_5_i = c_arr_1_5;
  assign c1_6_i = c_arr_1_6;
  assign c1_7_i = c_arr_1_7;
  assign c1_8_i = c_arr_1_8;
  assign c1_9_i = c_arr_1_9;
  assign c1_10_i = c_arr_1_10;
  assign c1_11_i = c_arr_1_11;
  assign c1_12_i = c_arr_1_12;
  assign c1_13_i = c_arr_1_13;
  assign c1_14_i = c_arr_1_14;
  assign c1_15_i = c_arr_1_15;
  assign c1_16_i = c_arr_1_16;
  assign c1_17_i = c_arr_1_17;
  assign c1_18_i = c_arr_1_18;
  assign c1_19_i = c_arr_1_19;
  assign c1_20_i = c_arr_1_20;
  assign c1_21_i = c_arr_1_21;
  assign c1_22_i = c_arr_1_22;
  assign c1_23_i = c_arr_1_23;
  assign c1_24_i = c_arr_1_24;
  assign c1_25_i = c_arr_1_25;
  assign c1_26_i = c_arr_1_26;
  assign c1_27_i = c_arr_1_27;
  assign c1_28_i = c_arr_1_28;
  assign c1_29_i = c_arr_1_29;
  assign c1_30_i = c_arr_1_30;
  assign c1_31_i = c_arr_1_31;
  assign c2_0_i = c_arr_2_0;
  assign c2_1_i = c_arr_2_1;
  assign c2_2_i = c_arr_2_2;
  assign c2_3_i = c_arr_2_3;
  assign c2_4_i = c_arr_2_4;
  assign c2_5_i = c_arr_2_5;
  assign c2_6_i = c_arr_2_6;
  assign c2_7_i = c_arr_2_7;
  assign c2_8_i = c_arr_2_8;
  assign c2_9_i = c_arr_2_9;
  assign c2_10_i = c_arr_2_10;
  assign c2_11_i = c_arr_2_11;
  assign c2_12_i = c_arr_2_12;
  assign c2_13_i = c_arr_2_13;
  assign c2_14_i = c_arr_2_14;
  assign c2_15_i = c_arr_2_15;
  assign c2_16_i = c_arr_2_16;
  assign c2_17_i = c_arr_2_17;
  assign c2_18_i = c_arr_2_18;
  assign c2_19_i = c_arr_2_19;
  assign c2_20_i = c_arr_2_20;
  assign c2_21_i = c_arr_2_21;
  assign c2_22_i = c_arr_2_22;
  assign c2_23_i = c_arr_2_23;
  assign c2_24_i = c_arr_2_24;
  assign c2_25_i = c_arr_2_25;
  assign c2_26_i = c_arr_2_26;
  assign c2_27_i = c_arr_2_27;
  assign c2_28_i = c_arr_2_28;
  assign c2_29_i = c_arr_2_29;
  assign c2_30_i = c_arr_2_30;
  assign c2_31_i = c_arr_2_31;
  assign c3_0_i = c_arr_3_0;
  assign c3_1_i = c_arr_3_1;
  assign c3_2_i = c_arr_3_2;
  assign c3_3_i = c_arr_3_3;
  assign c3_4_i = c_arr_3_4;
  assign c3_5_i = c_arr_3_5;
  assign c3_6_i = c_arr_3_6;
  assign c3_7_i = c_arr_3_7;
  assign c3_8_i = c_arr_3_8;
  assign c3_9_i = c_arr_3_9;
  assign c3_10_i = c_arr_3_10;
  assign c3_11_i = c_arr_3_11;
  assign c3_12_i = c_arr_3_12;
  assign c3_13_i = c_arr_3_13;
  assign c3_14_i = c_arr_3_14;
  assign c3_15_i = c_arr_3_15;
  assign c3_16_i = c_arr_3_16;
  assign c3_17_i = c_arr_3_17;
  assign c3_18_i = c_arr_3_18;
  assign c3_19_i = c_arr_3_19;
  assign c3_20_i = c_arr_3_20;
  assign c3_21_i = c_arr_3_21;
  assign c3_22_i = c_arr_3_22;
  assign c3_23_i = c_arr_3_23;
  assign c3_24_i = c_arr_3_24;
  assign c3_25_i = c_arr_3_25;
  assign c3_26_i = c_arr_3_26;
  assign c3_27_i = c_arr_3_27;
  assign c3_28_i = c_arr_3_28;
  assign c3_29_i = c_arr_3_29;
  assign c3_30_i = c_arr_3_30;
  assign c3_31_i = c_arr_3_31;
  assign c4_0_i = c_arr_4_0;
  assign c4_1_i = c_arr_4_1;
  assign c4_2_i = c_arr_4_2;
  assign c4_3_i = c_arr_4_3;
  assign c4_4_i = c_arr_4_4;
  assign c4_5_i = c_arr_4_5;
  assign c4_6_i = c_arr_4_6;
  assign c4_7_i = c_arr_4_7;
  assign c4_8_i = c_arr_4_8;
  assign c4_9_i = c_arr_4_9;
  assign c4_10_i = c_arr_4_10;
  assign c4_11_i = c_arr_4_11;
  assign c4_12_i = c_arr_4_12;
  assign c4_13_i = c_arr_4_13;
  assign c4_14_i = c_arr_4_14;
  assign c4_15_i = c_arr_4_15;
  assign c4_16_i = c_arr_4_16;
  assign c4_17_i = c_arr_4_17;
  assign c4_18_i = c_arr_4_18;
  assign c4_19_i = c_arr_4_19;
  assign c4_20_i = c_arr_4_20;
  assign c4_21_i = c_arr_4_21;
  assign c4_22_i = c_arr_4_22;
  assign c4_23_i = c_arr_4_23;
  assign c4_24_i = c_arr_4_24;
  assign c4_25_i = c_arr_4_25;
  assign c4_26_i = c_arr_4_26;
  assign c4_27_i = c_arr_4_27;
  assign c4_28_i = c_arr_4_28;
  assign c4_29_i = c_arr_4_29;
  assign c4_30_i = c_arr_4_30;
  assign c4_31_i = c_arr_4_31;
  assign c5_0_i = c_arr_5_0;
  assign c5_1_i = c_arr_5_1;
  assign c5_2_i = c_arr_5_2;
  assign c5_3_i = c_arr_5_3;
  assign c5_4_i = c_arr_5_4;
  assign c5_5_i = c_arr_5_5;
  assign c5_6_i = c_arr_5_6;
  assign c5_7_i = c_arr_5_7;
  assign c5_8_i = c_arr_5_8;
  assign c5_9_i = c_arr_5_9;
  assign c5_10_i = c_arr_5_10;
  assign c5_11_i = c_arr_5_11;
  assign c5_12_i = c_arr_5_12;
  assign c5_13_i = c_arr_5_13;
  assign c5_14_i = c_arr_5_14;
  assign c5_15_i = c_arr_5_15;
  assign c5_16_i = c_arr_5_16;
  assign c5_17_i = c_arr_5_17;
  assign c5_18_i = c_arr_5_18;
  assign c5_19_i = c_arr_5_19;
  assign c5_20_i = c_arr_5_20;
  assign c5_21_i = c_arr_5_21;
  assign c5_22_i = c_arr_5_22;
  assign c5_23_i = c_arr_5_23;
  assign c5_24_i = c_arr_5_24;
  assign c5_25_i = c_arr_5_25;
  assign c5_26_i = c_arr_5_26;
  assign c5_27_i = c_arr_5_27;
  assign c5_28_i = c_arr_5_28;
  assign c5_29_i = c_arr_5_29;
  assign c5_30_i = c_arr_5_30;
  assign c5_31_i = c_arr_5_31;
  assign c6_0_i = c_arr_6_0;
  assign c6_1_i = c_arr_6_1;
  assign c6_2_i = c_arr_6_2;
  assign c6_3_i = c_arr_6_3;
  assign c6_4_i = c_arr_6_4;
  assign c6_5_i = c_arr_6_5;
  assign c6_6_i = c_arr_6_6;
  assign c6_7_i = c_arr_6_7;
  assign c6_8_i = c_arr_6_8;
  assign c6_9_i = c_arr_6_9;
  assign c6_10_i = c_arr_6_10;
  assign c6_11_i = c_arr_6_11;
  assign c6_12_i = c_arr_6_12;
  assign c6_13_i = c_arr_6_13;
  assign c6_14_i = c_arr_6_14;
  assign c6_15_i = c_arr_6_15;
  assign c6_16_i = c_arr_6_16;
  assign c6_17_i = c_arr_6_17;
  assign c6_18_i = c_arr_6_18;
  assign c6_19_i = c_arr_6_19;
  assign c6_20_i = c_arr_6_20;
  assign c6_21_i = c_arr_6_21;
  assign c6_22_i = c_arr_6_22;
  assign c6_23_i = c_arr_6_23;
  assign c6_24_i = c_arr_6_24;
  assign c6_25_i = c_arr_6_25;
  assign c6_26_i = c_arr_6_26;
  assign c6_27_i = c_arr_6_27;
  assign c6_28_i = c_arr_6_28;
  assign c6_29_i = c_arr_6_29;
  assign c6_30_i = c_arr_6_30;
  assign c6_31_i = c_arr_6_31;
  assign c7_0_i = c_arr_7_0;
  assign c7_1_i = c_arr_7_1;
  assign c7_2_i = c_arr_7_2;
  assign c7_3_i = c_arr_7_3;
  assign c7_4_i = c_arr_7_4;
  assign c7_5_i = c_arr_7_5;
  assign c7_6_i = c_arr_7_6;
  assign c7_7_i = c_arr_7_7;
  assign c7_8_i = c_arr_7_8;
  assign c7_9_i = c_arr_7_9;
  assign c7_10_i = c_arr_7_10;
  assign c7_11_i = c_arr_7_11;
  assign c7_12_i = c_arr_7_12;
  assign c7_13_i = c_arr_7_13;
  assign c7_14_i = c_arr_7_14;
  assign c7_15_i = c_arr_7_15;
  assign c7_16_i = c_arr_7_16;
  assign c7_17_i = c_arr_7_17;
  assign c7_18_i = c_arr_7_18;
  assign c7_19_i = c_arr_7_19;
  assign c7_20_i = c_arr_7_20;
  assign c7_21_i = c_arr_7_21;
  assign c7_22_i = c_arr_7_22;
  assign c7_23_i = c_arr_7_23;
  assign c7_24_i = c_arr_7_24;
  assign c7_25_i = c_arr_7_25;
  assign c7_26_i = c_arr_7_26;
  assign c7_27_i = c_arr_7_27;
  assign c7_28_i = c_arr_7_28;
  assign c7_29_i = c_arr_7_29;
  assign c7_30_i = c_arr_7_30;
  assign c7_31_i = c_arr_7_31;
  assign c8_0_i = c_arr_8_0;
  assign c8_1_i = c_arr_8_1;
  assign c8_2_i = c_arr_8_2;
  assign c8_3_i = c_arr_8_3;
  assign c8_4_i = c_arr_8_4;
  assign c8_5_i = c_arr_8_5;
  assign c8_6_i = c_arr_8_6;
  assign c8_7_i = c_arr_8_7;
  assign c8_8_i = c_arr_8_8;
  assign c8_9_i = c_arr_8_9;
  assign c8_10_i = c_arr_8_10;
  assign c8_11_i = c_arr_8_11;
  assign c8_12_i = c_arr_8_12;
  assign c8_13_i = c_arr_8_13;
  assign c8_14_i = c_arr_8_14;
  assign c8_15_i = c_arr_8_15;
  assign c8_16_i = c_arr_8_16;
  assign c8_17_i = c_arr_8_17;
  assign c8_18_i = c_arr_8_18;
  assign c8_19_i = c_arr_8_19;
  assign c8_20_i = c_arr_8_20;
  assign c8_21_i = c_arr_8_21;
  assign c8_22_i = c_arr_8_22;
  assign c8_23_i = c_arr_8_23;
  assign c8_24_i = c_arr_8_24;
  assign c8_25_i = c_arr_8_25;
  assign c8_26_i = c_arr_8_26;
  assign c8_27_i = c_arr_8_27;
  assign c8_28_i = c_arr_8_28;
  assign c8_29_i = c_arr_8_29;
  assign c8_30_i = c_arr_8_30;
  assign c8_31_i = c_arr_8_31;
  assign c9_0_i = c_arr_9_0;
  assign c9_1_i = c_arr_9_1;
  assign c9_2_i = c_arr_9_2;
  assign c9_3_i = c_arr_9_3;
  assign c9_4_i = c_arr_9_4;
  assign c9_5_i = c_arr_9_5;
  assign c9_6_i = c_arr_9_6;
  assign c9_7_i = c_arr_9_7;
  assign c9_8_i = c_arr_9_8;
  assign c9_9_i = c_arr_9_9;
  assign c9_10_i = c_arr_9_10;
  assign c9_11_i = c_arr_9_11;
  assign c9_12_i = c_arr_9_12;
  assign c9_13_i = c_arr_9_13;
  assign c9_14_i = c_arr_9_14;
  assign c9_15_i = c_arr_9_15;
  assign c9_16_i = c_arr_9_16;
  assign c9_17_i = c_arr_9_17;
  assign c9_18_i = c_arr_9_18;
  assign c9_19_i = c_arr_9_19;
  assign c9_20_i = c_arr_9_20;
  assign c9_21_i = c_arr_9_21;
  assign c9_22_i = c_arr_9_22;
  assign c9_23_i = c_arr_9_23;
  assign c9_24_i = c_arr_9_24;
  assign c9_25_i = c_arr_9_25;
  assign c9_26_i = c_arr_9_26;
  assign c9_27_i = c_arr_9_27;
  assign c9_28_i = c_arr_9_28;
  assign c9_29_i = c_arr_9_29;
  assign c9_30_i = c_arr_9_30;
  assign c9_31_i = c_arr_9_31;
  assign c10_0_i = c_arr_10_0;
  assign c10_1_i = c_arr_10_1;
  assign c10_2_i = c_arr_10_2;
  assign c10_3_i = c_arr_10_3;
  assign c10_4_i = c_arr_10_4;
  assign c10_5_i = c_arr_10_5;
  assign c10_6_i = c_arr_10_6;
  assign c10_7_i = c_arr_10_7;
  assign c10_8_i = c_arr_10_8;
  assign c10_9_i = c_arr_10_9;
  assign c10_10_i = c_arr_10_10;
  assign c10_11_i = c_arr_10_11;
  assign c10_12_i = c_arr_10_12;
  assign c10_13_i = c_arr_10_13;
  assign c10_14_i = c_arr_10_14;
  assign c10_15_i = c_arr_10_15;
  assign c10_16_i = c_arr_10_16;
  assign c10_17_i = c_arr_10_17;
  assign c10_18_i = c_arr_10_18;
  assign c10_19_i = c_arr_10_19;
  assign c10_20_i = c_arr_10_20;
  assign c10_21_i = c_arr_10_21;
  assign c10_22_i = c_arr_10_22;
  assign c10_23_i = c_arr_10_23;
  assign c10_24_i = c_arr_10_24;
  assign c10_25_i = c_arr_10_25;
  assign c10_26_i = c_arr_10_26;
  assign c10_27_i = c_arr_10_27;
  assign c10_28_i = c_arr_10_28;
  assign c10_29_i = c_arr_10_29;
  assign c10_30_i = c_arr_10_30;
  assign c10_31_i = c_arr_10_31;
  assign c11_0_i = c_arr_11_0;
  assign c11_1_i = c_arr_11_1;
  assign c11_2_i = c_arr_11_2;
  assign c11_3_i = c_arr_11_3;
  assign c11_4_i = c_arr_11_4;
  assign c11_5_i = c_arr_11_5;
  assign c11_6_i = c_arr_11_6;
  assign c11_7_i = c_arr_11_7;
  assign c11_8_i = c_arr_11_8;
  assign c11_9_i = c_arr_11_9;
  assign c11_10_i = c_arr_11_10;
  assign c11_11_i = c_arr_11_11;
  assign c11_12_i = c_arr_11_12;
  assign c11_13_i = c_arr_11_13;
  assign c11_14_i = c_arr_11_14;
  assign c11_15_i = c_arr_11_15;
  assign c11_16_i = c_arr_11_16;
  assign c11_17_i = c_arr_11_17;
  assign c11_18_i = c_arr_11_18;
  assign c11_19_i = c_arr_11_19;
  assign c11_20_i = c_arr_11_20;
  assign c11_21_i = c_arr_11_21;
  assign c11_22_i = c_arr_11_22;
  assign c11_23_i = c_arr_11_23;
  assign c11_24_i = c_arr_11_24;
  assign c11_25_i = c_arr_11_25;
  assign c11_26_i = c_arr_11_26;
  assign c11_27_i = c_arr_11_27;
  assign c11_28_i = c_arr_11_28;
  assign c11_29_i = c_arr_11_29;
  assign c11_30_i = c_arr_11_30;
  assign c11_31_i = c_arr_11_31;
  assign c12_0_i = c_arr_12_0;
  assign c12_1_i = c_arr_12_1;
  assign c12_2_i = c_arr_12_2;
  assign c12_3_i = c_arr_12_3;
  assign c12_4_i = c_arr_12_4;
  assign c12_5_i = c_arr_12_5;
  assign c12_6_i = c_arr_12_6;
  assign c12_7_i = c_arr_12_7;
  assign c12_8_i = c_arr_12_8;
  assign c12_9_i = c_arr_12_9;
  assign c12_10_i = c_arr_12_10;
  assign c12_11_i = c_arr_12_11;
  assign c12_12_i = c_arr_12_12;
  assign c12_13_i = c_arr_12_13;
  assign c12_14_i = c_arr_12_14;
  assign c12_15_i = c_arr_12_15;
  assign c12_16_i = c_arr_12_16;
  assign c12_17_i = c_arr_12_17;
  assign c12_18_i = c_arr_12_18;
  assign c12_19_i = c_arr_12_19;
  assign c12_20_i = c_arr_12_20;
  assign c12_21_i = c_arr_12_21;
  assign c12_22_i = c_arr_12_22;
  assign c12_23_i = c_arr_12_23;
  assign c12_24_i = c_arr_12_24;
  assign c12_25_i = c_arr_12_25;
  assign c12_26_i = c_arr_12_26;
  assign c12_27_i = c_arr_12_27;
  assign c12_28_i = c_arr_12_28;
  assign c12_29_i = c_arr_12_29;
  assign c12_30_i = c_arr_12_30;
  assign c12_31_i = c_arr_12_31;
  assign c13_0_i = c_arr_13_0;
  assign c13_1_i = c_arr_13_1;
  assign c13_2_i = c_arr_13_2;
  assign c13_3_i = c_arr_13_3;
  assign c13_4_i = c_arr_13_4;
  assign c13_5_i = c_arr_13_5;
  assign c13_6_i = c_arr_13_6;
  assign c13_7_i = c_arr_13_7;
  assign c13_8_i = c_arr_13_8;
  assign c13_9_i = c_arr_13_9;
  assign c13_10_i = c_arr_13_10;
  assign c13_11_i = c_arr_13_11;
  assign c13_12_i = c_arr_13_12;
  assign c13_13_i = c_arr_13_13;
  assign c13_14_i = c_arr_13_14;
  assign c13_15_i = c_arr_13_15;
  assign c13_16_i = c_arr_13_16;
  assign c13_17_i = c_arr_13_17;
  assign c13_18_i = c_arr_13_18;
  assign c13_19_i = c_arr_13_19;
  assign c13_20_i = c_arr_13_20;
  assign c13_21_i = c_arr_13_21;
  assign c13_22_i = c_arr_13_22;
  assign c13_23_i = c_arr_13_23;
  assign c13_24_i = c_arr_13_24;
  assign c13_25_i = c_arr_13_25;
  assign c13_26_i = c_arr_13_26;
  assign c13_27_i = c_arr_13_27;
  assign c13_28_i = c_arr_13_28;
  assign c13_29_i = c_arr_13_29;
  assign c13_30_i = c_arr_13_30;
  assign c13_31_i = c_arr_13_31;
  assign c14_0_i = c_arr_14_0;
  assign c14_1_i = c_arr_14_1;
  assign c14_2_i = c_arr_14_2;
  assign c14_3_i = c_arr_14_3;
  assign c14_4_i = c_arr_14_4;
  assign c14_5_i = c_arr_14_5;
  assign c14_6_i = c_arr_14_6;
  assign c14_7_i = c_arr_14_7;
  assign c14_8_i = c_arr_14_8;
  assign c14_9_i = c_arr_14_9;
  assign c14_10_i = c_arr_14_10;
  assign c14_11_i = c_arr_14_11;
  assign c14_12_i = c_arr_14_12;
  assign c14_13_i = c_arr_14_13;
  assign c14_14_i = c_arr_14_14;
  assign c14_15_i = c_arr_14_15;
  assign c14_16_i = c_arr_14_16;
  assign c14_17_i = c_arr_14_17;
  assign c14_18_i = c_arr_14_18;
  assign c14_19_i = c_arr_14_19;
  assign c14_20_i = c_arr_14_20;
  assign c14_21_i = c_arr_14_21;
  assign c14_22_i = c_arr_14_22;
  assign c14_23_i = c_arr_14_23;
  assign c14_24_i = c_arr_14_24;
  assign c14_25_i = c_arr_14_25;
  assign c14_26_i = c_arr_14_26;
  assign c14_27_i = c_arr_14_27;
  assign c14_28_i = c_arr_14_28;
  assign c14_29_i = c_arr_14_29;
  assign c14_30_i = c_arr_14_30;
  assign c14_31_i = c_arr_14_31;
  assign c15_0_i = c_arr_15_0;
  assign c15_1_i = c_arr_15_1;
  assign c15_2_i = c_arr_15_2;
  assign c15_3_i = c_arr_15_3;
  assign c15_4_i = c_arr_15_4;
  assign c15_5_i = c_arr_15_5;
  assign c15_6_i = c_arr_15_6;
  assign c15_7_i = c_arr_15_7;
  assign c15_8_i = c_arr_15_8;
  assign c15_9_i = c_arr_15_9;
  assign c15_10_i = c_arr_15_10;
  assign c15_11_i = c_arr_15_11;
  assign c15_12_i = c_arr_15_12;
  assign c15_13_i = c_arr_15_13;
  assign c15_14_i = c_arr_15_14;
  assign c15_15_i = c_arr_15_15;
  assign c15_16_i = c_arr_15_16;
  assign c15_17_i = c_arr_15_17;
  assign c15_18_i = c_arr_15_18;
  assign c15_19_i = c_arr_15_19;
  assign c15_20_i = c_arr_15_20;
  assign c15_21_i = c_arr_15_21;
  assign c15_22_i = c_arr_15_22;
  assign c15_23_i = c_arr_15_23;
  assign c15_24_i = c_arr_15_24;
  assign c15_25_i = c_arr_15_25;
  assign c15_26_i = c_arr_15_26;
  assign c15_27_i = c_arr_15_27;
  assign c15_28_i = c_arr_15_28;
  assign c15_29_i = c_arr_15_29;
  assign c15_30_i = c_arr_15_30;
  assign c15_31_i = c_arr_15_31;
  assign c16_0_i = c_arr_16_0;
  assign c16_1_i = c_arr_16_1;
  assign c16_2_i = c_arr_16_2;
  assign c16_3_i = c_arr_16_3;
  assign c16_4_i = c_arr_16_4;
  assign c16_5_i = c_arr_16_5;
  assign c16_6_i = c_arr_16_6;
  assign c16_7_i = c_arr_16_7;
  assign c16_8_i = c_arr_16_8;
  assign c16_9_i = c_arr_16_9;
  assign c16_10_i = c_arr_16_10;
  assign c16_11_i = c_arr_16_11;
  assign c16_12_i = c_arr_16_12;
  assign c16_13_i = c_arr_16_13;
  assign c16_14_i = c_arr_16_14;
  assign c16_15_i = c_arr_16_15;
  assign c16_16_i = c_arr_16_16;
  assign c16_17_i = c_arr_16_17;
  assign c16_18_i = c_arr_16_18;
  assign c16_19_i = c_arr_16_19;
  assign c16_20_i = c_arr_16_20;
  assign c16_21_i = c_arr_16_21;
  assign c16_22_i = c_arr_16_22;
  assign c16_23_i = c_arr_16_23;
  assign c16_24_i = c_arr_16_24;
  assign c16_25_i = c_arr_16_25;
  assign c16_26_i = c_arr_16_26;
  assign c16_27_i = c_arr_16_27;
  assign c16_28_i = c_arr_16_28;
  assign c16_29_i = c_arr_16_29;
  assign c16_30_i = c_arr_16_30;
  assign c16_31_i = c_arr_16_31;
  assign c17_0_i = c_arr_17_0;
  assign c17_1_i = c_arr_17_1;
  assign c17_2_i = c_arr_17_2;
  assign c17_3_i = c_arr_17_3;
  assign c17_4_i = c_arr_17_4;
  assign c17_5_i = c_arr_17_5;
  assign c17_6_i = c_arr_17_6;
  assign c17_7_i = c_arr_17_7;
  assign c17_8_i = c_arr_17_8;
  assign c17_9_i = c_arr_17_9;
  assign c17_10_i = c_arr_17_10;
  assign c17_11_i = c_arr_17_11;
  assign c17_12_i = c_arr_17_12;
  assign c17_13_i = c_arr_17_13;
  assign c17_14_i = c_arr_17_14;
  assign c17_15_i = c_arr_17_15;
  assign c17_16_i = c_arr_17_16;
  assign c17_17_i = c_arr_17_17;
  assign c17_18_i = c_arr_17_18;
  assign c17_19_i = c_arr_17_19;
  assign c17_20_i = c_arr_17_20;
  assign c17_21_i = c_arr_17_21;
  assign c17_22_i = c_arr_17_22;
  assign c17_23_i = c_arr_17_23;
  assign c17_24_i = c_arr_17_24;
  assign c17_25_i = c_arr_17_25;
  assign c17_26_i = c_arr_17_26;
  assign c17_27_i = c_arr_17_27;
  assign c17_28_i = c_arr_17_28;
  assign c17_29_i = c_arr_17_29;
  assign c17_30_i = c_arr_17_30;
  assign c17_31_i = c_arr_17_31;
  assign c18_0_i = c_arr_18_0;
  assign c18_1_i = c_arr_18_1;
  assign c18_2_i = c_arr_18_2;
  assign c18_3_i = c_arr_18_3;
  assign c18_4_i = c_arr_18_4;
  assign c18_5_i = c_arr_18_5;
  assign c18_6_i = c_arr_18_6;
  assign c18_7_i = c_arr_18_7;
  assign c18_8_i = c_arr_18_8;
  assign c18_9_i = c_arr_18_9;
  assign c18_10_i = c_arr_18_10;
  assign c18_11_i = c_arr_18_11;
  assign c18_12_i = c_arr_18_12;
  assign c18_13_i = c_arr_18_13;
  assign c18_14_i = c_arr_18_14;
  assign c18_15_i = c_arr_18_15;
  assign c18_16_i = c_arr_18_16;
  assign c18_17_i = c_arr_18_17;
  assign c18_18_i = c_arr_18_18;
  assign c18_19_i = c_arr_18_19;
  assign c18_20_i = c_arr_18_20;
  assign c18_21_i = c_arr_18_21;
  assign c18_22_i = c_arr_18_22;
  assign c18_23_i = c_arr_18_23;
  assign c18_24_i = c_arr_18_24;
  assign c18_25_i = c_arr_18_25;
  assign c18_26_i = c_arr_18_26;
  assign c18_27_i = c_arr_18_27;
  assign c18_28_i = c_arr_18_28;
  assign c18_29_i = c_arr_18_29;
  assign c18_30_i = c_arr_18_30;
  assign c18_31_i = c_arr_18_31;
  assign c19_0_i = c_arr_19_0;
  assign c19_1_i = c_arr_19_1;
  assign c19_2_i = c_arr_19_2;
  assign c19_3_i = c_arr_19_3;
  assign c19_4_i = c_arr_19_4;
  assign c19_5_i = c_arr_19_5;
  assign c19_6_i = c_arr_19_6;
  assign c19_7_i = c_arr_19_7;
  assign c19_8_i = c_arr_19_8;
  assign c19_9_i = c_arr_19_9;
  assign c19_10_i = c_arr_19_10;
  assign c19_11_i = c_arr_19_11;
  assign c19_12_i = c_arr_19_12;
  assign c19_13_i = c_arr_19_13;
  assign c19_14_i = c_arr_19_14;
  assign c19_15_i = c_arr_19_15;
  assign c19_16_i = c_arr_19_16;
  assign c19_17_i = c_arr_19_17;
  assign c19_18_i = c_arr_19_18;
  assign c19_19_i = c_arr_19_19;
  assign c19_20_i = c_arr_19_20;
  assign c19_21_i = c_arr_19_21;
  assign c19_22_i = c_arr_19_22;
  assign c19_23_i = c_arr_19_23;
  assign c19_24_i = c_arr_19_24;
  assign c19_25_i = c_arr_19_25;
  assign c19_26_i = c_arr_19_26;
  assign c19_27_i = c_arr_19_27;
  assign c19_28_i = c_arr_19_28;
  assign c19_29_i = c_arr_19_29;
  assign c19_30_i = c_arr_19_30;
  assign c19_31_i = c_arr_19_31;
  assign c20_0_i = c_arr_20_0;
  assign c20_1_i = c_arr_20_1;
  assign c20_2_i = c_arr_20_2;
  assign c20_3_i = c_arr_20_3;
  assign c20_4_i = c_arr_20_4;
  assign c20_5_i = c_arr_20_5;
  assign c20_6_i = c_arr_20_6;
  assign c20_7_i = c_arr_20_7;
  assign c20_8_i = c_arr_20_8;
  assign c20_9_i = c_arr_20_9;
  assign c20_10_i = c_arr_20_10;
  assign c20_11_i = c_arr_20_11;
  assign c20_12_i = c_arr_20_12;
  assign c20_13_i = c_arr_20_13;
  assign c20_14_i = c_arr_20_14;
  assign c20_15_i = c_arr_20_15;
  assign c20_16_i = c_arr_20_16;
  assign c20_17_i = c_arr_20_17;
  assign c20_18_i = c_arr_20_18;
  assign c20_19_i = c_arr_20_19;
  assign c20_20_i = c_arr_20_20;
  assign c20_21_i = c_arr_20_21;
  assign c20_22_i = c_arr_20_22;
  assign c20_23_i = c_arr_20_23;
  assign c20_24_i = c_arr_20_24;
  assign c20_25_i = c_arr_20_25;
  assign c20_26_i = c_arr_20_26;
  assign c20_27_i = c_arr_20_27;
  assign c20_28_i = c_arr_20_28;
  assign c20_29_i = c_arr_20_29;
  assign c20_30_i = c_arr_20_30;
  assign c20_31_i = c_arr_20_31;
  assign c21_0_i = c_arr_21_0;
  assign c21_1_i = c_arr_21_1;
  assign c21_2_i = c_arr_21_2;
  assign c21_3_i = c_arr_21_3;
  assign c21_4_i = c_arr_21_4;
  assign c21_5_i = c_arr_21_5;
  assign c21_6_i = c_arr_21_6;
  assign c21_7_i = c_arr_21_7;
  assign c21_8_i = c_arr_21_8;
  assign c21_9_i = c_arr_21_9;
  assign c21_10_i = c_arr_21_10;
  assign c21_11_i = c_arr_21_11;
  assign c21_12_i = c_arr_21_12;
  assign c21_13_i = c_arr_21_13;
  assign c21_14_i = c_arr_21_14;
  assign c21_15_i = c_arr_21_15;
  assign c21_16_i = c_arr_21_16;
  assign c21_17_i = c_arr_21_17;
  assign c21_18_i = c_arr_21_18;
  assign c21_19_i = c_arr_21_19;
  assign c21_20_i = c_arr_21_20;
  assign c21_21_i = c_arr_21_21;
  assign c21_22_i = c_arr_21_22;
  assign c21_23_i = c_arr_21_23;
  assign c21_24_i = c_arr_21_24;
  assign c21_25_i = c_arr_21_25;
  assign c21_26_i = c_arr_21_26;
  assign c21_27_i = c_arr_21_27;
  assign c21_28_i = c_arr_21_28;
  assign c21_29_i = c_arr_21_29;
  assign c21_30_i = c_arr_21_30;
  assign c21_31_i = c_arr_21_31;
  assign c22_0_i = c_arr_22_0;
  assign c22_1_i = c_arr_22_1;
  assign c22_2_i = c_arr_22_2;
  assign c22_3_i = c_arr_22_3;
  assign c22_4_i = c_arr_22_4;
  assign c22_5_i = c_arr_22_5;
  assign c22_6_i = c_arr_22_6;
  assign c22_7_i = c_arr_22_7;
  assign c22_8_i = c_arr_22_8;
  assign c22_9_i = c_arr_22_9;
  assign c22_10_i = c_arr_22_10;
  assign c22_11_i = c_arr_22_11;
  assign c22_12_i = c_arr_22_12;
  assign c22_13_i = c_arr_22_13;
  assign c22_14_i = c_arr_22_14;
  assign c22_15_i = c_arr_22_15;
  assign c22_16_i = c_arr_22_16;
  assign c22_17_i = c_arr_22_17;
  assign c22_18_i = c_arr_22_18;
  assign c22_19_i = c_arr_22_19;
  assign c22_20_i = c_arr_22_20;
  assign c22_21_i = c_arr_22_21;
  assign c22_22_i = c_arr_22_22;
  assign c22_23_i = c_arr_22_23;
  assign c22_24_i = c_arr_22_24;
  assign c22_25_i = c_arr_22_25;
  assign c22_26_i = c_arr_22_26;
  assign c22_27_i = c_arr_22_27;
  assign c22_28_i = c_arr_22_28;
  assign c22_29_i = c_arr_22_29;
  assign c22_30_i = c_arr_22_30;
  assign c22_31_i = c_arr_22_31;
  assign c23_0_i = c_arr_23_0;
  assign c23_1_i = c_arr_23_1;
  assign c23_2_i = c_arr_23_2;
  assign c23_3_i = c_arr_23_3;
  assign c23_4_i = c_arr_23_4;
  assign c23_5_i = c_arr_23_5;
  assign c23_6_i = c_arr_23_6;
  assign c23_7_i = c_arr_23_7;
  assign c23_8_i = c_arr_23_8;
  assign c23_9_i = c_arr_23_9;
  assign c23_10_i = c_arr_23_10;
  assign c23_11_i = c_arr_23_11;
  assign c23_12_i = c_arr_23_12;
  assign c23_13_i = c_arr_23_13;
  assign c23_14_i = c_arr_23_14;
  assign c23_15_i = c_arr_23_15;
  assign c23_16_i = c_arr_23_16;
  assign c23_17_i = c_arr_23_17;
  assign c23_18_i = c_arr_23_18;
  assign c23_19_i = c_arr_23_19;
  assign c23_20_i = c_arr_23_20;
  assign c23_21_i = c_arr_23_21;
  assign c23_22_i = c_arr_23_22;
  assign c23_23_i = c_arr_23_23;
  assign c23_24_i = c_arr_23_24;
  assign c23_25_i = c_arr_23_25;
  assign c23_26_i = c_arr_23_26;
  assign c23_27_i = c_arr_23_27;
  assign c23_28_i = c_arr_23_28;
  assign c23_29_i = c_arr_23_29;
  assign c23_30_i = c_arr_23_30;
  assign c23_31_i = c_arr_23_31;
  assign c24_0_i = c_arr_24_0;
  assign c24_1_i = c_arr_24_1;
  assign c24_2_i = c_arr_24_2;
  assign c24_3_i = c_arr_24_3;
  assign c24_4_i = c_arr_24_4;
  assign c24_5_i = c_arr_24_5;
  assign c24_6_i = c_arr_24_6;
  assign c24_7_i = c_arr_24_7;
  assign c24_8_i = c_arr_24_8;
  assign c24_9_i = c_arr_24_9;
  assign c24_10_i = c_arr_24_10;
  assign c24_11_i = c_arr_24_11;
  assign c24_12_i = c_arr_24_12;
  assign c24_13_i = c_arr_24_13;
  assign c24_14_i = c_arr_24_14;
  assign c24_15_i = c_arr_24_15;
  assign c24_16_i = c_arr_24_16;
  assign c24_17_i = c_arr_24_17;
  assign c24_18_i = c_arr_24_18;
  assign c24_19_i = c_arr_24_19;
  assign c24_20_i = c_arr_24_20;
  assign c24_21_i = c_arr_24_21;
  assign c24_22_i = c_arr_24_22;
  assign c24_23_i = c_arr_24_23;
  assign c24_24_i = c_arr_24_24;
  assign c24_25_i = c_arr_24_25;
  assign c24_26_i = c_arr_24_26;
  assign c24_27_i = c_arr_24_27;
  assign c24_28_i = c_arr_24_28;
  assign c24_29_i = c_arr_24_29;
  assign c24_30_i = c_arr_24_30;
  assign c24_31_i = c_arr_24_31;
  assign c25_0_i = c_arr_25_0;
  assign c25_1_i = c_arr_25_1;
  assign c25_2_i = c_arr_25_2;
  assign c25_3_i = c_arr_25_3;
  assign c25_4_i = c_arr_25_4;
  assign c25_5_i = c_arr_25_5;
  assign c25_6_i = c_arr_25_6;
  assign c25_7_i = c_arr_25_7;
  assign c25_8_i = c_arr_25_8;
  assign c25_9_i = c_arr_25_9;
  assign c25_10_i = c_arr_25_10;
  assign c25_11_i = c_arr_25_11;
  assign c25_12_i = c_arr_25_12;
  assign c25_13_i = c_arr_25_13;
  assign c25_14_i = c_arr_25_14;
  assign c25_15_i = c_arr_25_15;
  assign c25_16_i = c_arr_25_16;
  assign c25_17_i = c_arr_25_17;
  assign c25_18_i = c_arr_25_18;
  assign c25_19_i = c_arr_25_19;
  assign c25_20_i = c_arr_25_20;
  assign c25_21_i = c_arr_25_21;
  assign c25_22_i = c_arr_25_22;
  assign c25_23_i = c_arr_25_23;
  assign c25_24_i = c_arr_25_24;
  assign c25_25_i = c_arr_25_25;
  assign c25_26_i = c_arr_25_26;
  assign c25_27_i = c_arr_25_27;
  assign c25_28_i = c_arr_25_28;
  assign c25_29_i = c_arr_25_29;
  assign c25_30_i = c_arr_25_30;
  assign c25_31_i = c_arr_25_31;
  assign c26_0_i = c_arr_26_0;
  assign c26_1_i = c_arr_26_1;
  assign c26_2_i = c_arr_26_2;
  assign c26_3_i = c_arr_26_3;
  assign c26_4_i = c_arr_26_4;
  assign c26_5_i = c_arr_26_5;
  assign c26_6_i = c_arr_26_6;
  assign c26_7_i = c_arr_26_7;
  assign c26_8_i = c_arr_26_8;
  assign c26_9_i = c_arr_26_9;
  assign c26_10_i = c_arr_26_10;
  assign c26_11_i = c_arr_26_11;
  assign c26_12_i = c_arr_26_12;
  assign c26_13_i = c_arr_26_13;
  assign c26_14_i = c_arr_26_14;
  assign c26_15_i = c_arr_26_15;
  assign c26_16_i = c_arr_26_16;
  assign c26_17_i = c_arr_26_17;
  assign c26_18_i = c_arr_26_18;
  assign c26_19_i = c_arr_26_19;
  assign c26_20_i = c_arr_26_20;
  assign c26_21_i = c_arr_26_21;
  assign c26_22_i = c_arr_26_22;
  assign c26_23_i = c_arr_26_23;
  assign c26_24_i = c_arr_26_24;
  assign c26_25_i = c_arr_26_25;
  assign c26_26_i = c_arr_26_26;
  assign c26_27_i = c_arr_26_27;
  assign c26_28_i = c_arr_26_28;
  assign c26_29_i = c_arr_26_29;
  assign c26_30_i = c_arr_26_30;
  assign c26_31_i = c_arr_26_31;
  assign c27_0_i = c_arr_27_0;
  assign c27_1_i = c_arr_27_1;
  assign c27_2_i = c_arr_27_2;
  assign c27_3_i = c_arr_27_3;
  assign c27_4_i = c_arr_27_4;
  assign c27_5_i = c_arr_27_5;
  assign c27_6_i = c_arr_27_6;
  assign c27_7_i = c_arr_27_7;
  assign c27_8_i = c_arr_27_8;
  assign c27_9_i = c_arr_27_9;
  assign c27_10_i = c_arr_27_10;
  assign c27_11_i = c_arr_27_11;
  assign c27_12_i = c_arr_27_12;
  assign c27_13_i = c_arr_27_13;
  assign c27_14_i = c_arr_27_14;
  assign c27_15_i = c_arr_27_15;
  assign c27_16_i = c_arr_27_16;
  assign c27_17_i = c_arr_27_17;
  assign c27_18_i = c_arr_27_18;
  assign c27_19_i = c_arr_27_19;
  assign c27_20_i = c_arr_27_20;
  assign c27_21_i = c_arr_27_21;
  assign c27_22_i = c_arr_27_22;
  assign c27_23_i = c_arr_27_23;
  assign c27_24_i = c_arr_27_24;
  assign c27_25_i = c_arr_27_25;
  assign c27_26_i = c_arr_27_26;
  assign c27_27_i = c_arr_27_27;
  assign c27_28_i = c_arr_27_28;
  assign c27_29_i = c_arr_27_29;
  assign c27_30_i = c_arr_27_30;
  assign c27_31_i = c_arr_27_31;
  assign c28_0_i = c_arr_28_0;
  assign c28_1_i = c_arr_28_1;
  assign c28_2_i = c_arr_28_2;
  assign c28_3_i = c_arr_28_3;
  assign c28_4_i = c_arr_28_4;
  assign c28_5_i = c_arr_28_5;
  assign c28_6_i = c_arr_28_6;
  assign c28_7_i = c_arr_28_7;
  assign c28_8_i = c_arr_28_8;
  assign c28_9_i = c_arr_28_9;
  assign c28_10_i = c_arr_28_10;
  assign c28_11_i = c_arr_28_11;
  assign c28_12_i = c_arr_28_12;
  assign c28_13_i = c_arr_28_13;
  assign c28_14_i = c_arr_28_14;
  assign c28_15_i = c_arr_28_15;
  assign c28_16_i = c_arr_28_16;
  assign c28_17_i = c_arr_28_17;
  assign c28_18_i = c_arr_28_18;
  assign c28_19_i = c_arr_28_19;
  assign c28_20_i = c_arr_28_20;
  assign c28_21_i = c_arr_28_21;
  assign c28_22_i = c_arr_28_22;
  assign c28_23_i = c_arr_28_23;
  assign c28_24_i = c_arr_28_24;
  assign c28_25_i = c_arr_28_25;
  assign c28_26_i = c_arr_28_26;
  assign c28_27_i = c_arr_28_27;
  assign c28_28_i = c_arr_28_28;
  assign c28_29_i = c_arr_28_29;
  assign c28_30_i = c_arr_28_30;
  assign c28_31_i = c_arr_28_31;
  assign c29_0_i = c_arr_29_0;
  assign c29_1_i = c_arr_29_1;
  assign c29_2_i = c_arr_29_2;
  assign c29_3_i = c_arr_29_3;
  assign c29_4_i = c_arr_29_4;
  assign c29_5_i = c_arr_29_5;
  assign c29_6_i = c_arr_29_6;
  assign c29_7_i = c_arr_29_7;
  assign c29_8_i = c_arr_29_8;
  assign c29_9_i = c_arr_29_9;
  assign c29_10_i = c_arr_29_10;
  assign c29_11_i = c_arr_29_11;
  assign c29_12_i = c_arr_29_12;
  assign c29_13_i = c_arr_29_13;
  assign c29_14_i = c_arr_29_14;
  assign c29_15_i = c_arr_29_15;
  assign c29_16_i = c_arr_29_16;
  assign c29_17_i = c_arr_29_17;
  assign c29_18_i = c_arr_29_18;
  assign c29_19_i = c_arr_29_19;
  assign c29_20_i = c_arr_29_20;
  assign c29_21_i = c_arr_29_21;
  assign c29_22_i = c_arr_29_22;
  assign c29_23_i = c_arr_29_23;
  assign c29_24_i = c_arr_29_24;
  assign c29_25_i = c_arr_29_25;
  assign c29_26_i = c_arr_29_26;
  assign c29_27_i = c_arr_29_27;
  assign c29_28_i = c_arr_29_28;
  assign c29_29_i = c_arr_29_29;
  assign c29_30_i = c_arr_29_30;
  assign c29_31_i = c_arr_29_31;
  assign c30_0_i = c_arr_30_0;
  assign c30_1_i = c_arr_30_1;
  assign c30_2_i = c_arr_30_2;
  assign c30_3_i = c_arr_30_3;
  assign c30_4_i = c_arr_30_4;
  assign c30_5_i = c_arr_30_5;
  assign c30_6_i = c_arr_30_6;
  assign c30_7_i = c_arr_30_7;
  assign c30_8_i = c_arr_30_8;
  assign c30_9_i = c_arr_30_9;
  assign c30_10_i = c_arr_30_10;
  assign c30_11_i = c_arr_30_11;
  assign c30_12_i = c_arr_30_12;
  assign c30_13_i = c_arr_30_13;
  assign c30_14_i = c_arr_30_14;
  assign c30_15_i = c_arr_30_15;
  assign c30_16_i = c_arr_30_16;
  assign c30_17_i = c_arr_30_17;
  assign c30_18_i = c_arr_30_18;
  assign c30_19_i = c_arr_30_19;
  assign c30_20_i = c_arr_30_20;
  assign c30_21_i = c_arr_30_21;
  assign c30_22_i = c_arr_30_22;
  assign c30_23_i = c_arr_30_23;
  assign c30_24_i = c_arr_30_24;
  assign c30_25_i = c_arr_30_25;
  assign c30_26_i = c_arr_30_26;
  assign c30_27_i = c_arr_30_27;
  assign c30_28_i = c_arr_30_28;
  assign c30_29_i = c_arr_30_29;
  assign c30_30_i = c_arr_30_30;
  assign c30_31_i = c_arr_30_31;
  assign c31_0_i = c_arr_31_0;
  assign c31_1_i = c_arr_31_1;
  assign c31_2_i = c_arr_31_2;
  assign c31_3_i = c_arr_31_3;
  assign c31_4_i = c_arr_31_4;
  assign c31_5_i = c_arr_31_5;
  assign c31_6_i = c_arr_31_6;
  assign c31_7_i = c_arr_31_7;
  assign c31_8_i = c_arr_31_8;
  assign c31_9_i = c_arr_31_9;
  assign c31_10_i = c_arr_31_10;
  assign c31_11_i = c_arr_31_11;
  assign c31_12_i = c_arr_31_12;
  assign c31_13_i = c_arr_31_13;
  assign c31_14_i = c_arr_31_14;
  assign c31_15_i = c_arr_31_15;
  assign c31_16_i = c_arr_31_16;
  assign c31_17_i = c_arr_31_17;
  assign c31_18_i = c_arr_31_18;
  assign c31_19_i = c_arr_31_19;
  assign c31_20_i = c_arr_31_20;
  assign c31_21_i = c_arr_31_21;
  assign c31_22_i = c_arr_31_22;
  assign c31_23_i = c_arr_31_23;
  assign c31_24_i = c_arr_31_24;
  assign c31_25_i = c_arr_31_25;
  assign c31_26_i = c_arr_31_26;
  assign c31_27_i = c_arr_31_27;
  assign c31_28_i = c_arr_31_28;
  assign c31_29_i = c_arr_31_29;
  assign c31_30_i = c_arr_31_30;
  assign c31_31_i = c_arr_31_31;

  AXI4_C_WRITER dut_axi4_c_writer (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .*
  );

  // Bat tay mmult_accel <-> AXI4_C_WRITER (ten khac nhau ca 2 phia, can cau noi tuong minh).
  // tile_valid_i/tile_done_i KHONG can cau noi rieng o day - da la dung tin hieu fan-out tu
  // mmult_accel_0/tile_valid_o va SYSTOLIC_CORE_TOP_0/tile_done_o (assign o tren, gan
  // tile_valid_i=tile_valid_o/tile_done_i=tile_done_o cho SYSTOLIC_CORE_TOP) - AXI4_C_WRITER
  // dung `.*` se tu bind dung 2 tin hieu nay.
  assign c_base_addr_i  = c_base_addr_o;
  assign c_row_stride_i = c_row_stride_o;
  assign c_global_i0_i  = c_global_i0_o;
  assign c_global_j0_i  = c_global_j0_o;
  assign c_valid_rows_i = c_valid_rows_o;
  assign c_valid_cols_i = c_valid_cols_o;
  assign c_write_done_i = c_write_done_o;


  // ---- AXI4-Lite driver (dieu khien s_axi_control cua mmult_accel) ----
  task automatic axil_write(input logic [6:0] addr, input logic [31:0] data);
    logic aw_done, w_done;
    automatic int wait_cyc = 0;
    aw_done = 1'b0;
    w_done  = 1'b0;
    s_axi_control_AWADDR  = addr;
    s_axi_control_AWVALID = 1'b1;
    s_axi_control_WDATA   = data;
    s_axi_control_WSTRB   = 4'hF;
    s_axi_control_WVALID  = 1'b1;
    s_axi_control_BREADY  = 1'b1;
    // [2026-08-18] KHONG dung #1 o day (khac gmemC) -- control_s_axi (Vitis HLS) la FSM
    // WRIDLE/WRDATA/WRRESP: AWREADY/WREADY/BVALID = f(wstate), wstate<=wnext cap nhat qua NBA
    // dung tai canh xung. Doc AWREADY/WREADY *ngay tai* canh xung (khong doi #1, o vung Active,
    // TRUOC khi NBA cua DUT tuc thi) moi bat dung gia tri "truoc khi chuyen trang thai" ma DUT
    // dung de quyet dinh wnext -- day la gia tri CAN de phat hien dung luc handshake xay ra. Neu
    // doi #1 (sau khi NBA da chay xong), se doc phai gia tri "DA chuyen trang thai" (cham 1 nhip),
    // lam viec phat hien AW/W/B bi lech pha, dropped VALID sai luc -> deadlock that (da xac nhan
    // qua log: them #1 vao day gay treo thuc su tai axil_write dau tien, dau du sua o gmemC dung
    // vi ly do khac - gmemC la du lieu WDATA bi race gia tri thuc, khong phai FSM 3 trang thai
    // nay). Giu nguyen logic goc: ha AWVALID/WVALID rieng le ngay khi tung kenh xong.
    while (!(aw_done && w_done)) begin
      @(posedge ap_clk);
      if (s_axi_control_AWVALID && s_axi_control_AWREADY) begin
        s_axi_control_AWVALID = 1'b0;
        aw_done = 1'b1;
      end
      if (s_axi_control_WVALID && s_axi_control_WREADY) begin
        s_axi_control_WVALID = 1'b0;
        w_done = 1'b1;
      end
      wait_cyc++;
      if (wait_cyc % 200 == 0)
        $display("[AXIL-W] t=%0t van cho AW/W: aw_done=%b w_done=%b AWVALID=%b AWREADY=%b WVALID=%b WREADY=%b",
                  $time, aw_done, w_done, s_axi_control_AWVALID, s_axi_control_AWREADY,
                  s_axi_control_WVALID, s_axi_control_WREADY);
    end
    wait_cyc = 0;
    while (!s_axi_control_BVALID) begin
      @(posedge ap_clk);
      wait_cyc++;
      if (wait_cyc % 200 == 0)
        $display("[AXIL-W] t=%0t van cho BVALID=%b BREADY=%b", $time, s_axi_control_BVALID, s_axi_control_BREADY);
    end
    s_axi_control_BREADY = 1'b0;
  endtask

  task automatic axil_read(input logic [6:0] addr, output logic [31:0] data);
    logic ar_done;
    ar_done = 1'b0;
    s_axi_control_ARADDR  = addr;
    s_axi_control_ARVALID = 1'b1;
    s_axi_control_RREADY  = 1'b1;
    // [2026-08-18] Cung ly do nhu axil_write - khong dung #1 o day.
    while (!ar_done) begin
      @(posedge ap_clk);
      if (s_axi_control_ARVALID && s_axi_control_ARREADY) begin
        s_axi_control_ARVALID = 1'b0;
        ar_done = 1'b1;
      end
    end
    while (!s_axi_control_RVALID) @(posedge ap_clk);
    data = s_axi_control_RDATA;
    s_axi_control_RREADY = 1'b0;
  endtask


  // ---- 96 bank DUAL_PORT_BRAM_8B (noi day tuong minh, xem docs/task.md muc "Boi canh") ----
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a0 (
    .clk_i    (clk_i),
    .addr_a_i (bank0_addr_o),
    .en_a_i   (bank0_en_o),
    .we_a_i   (bank0_we_o),
    .din_a_i  (bank0_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a0_addr_o),
    .en_b_i   (bram_a0_en_o),
    .dout_b_o (bram_a0_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a1 (
    .clk_i    (clk_i),
    .addr_a_i (bank1_addr_o),
    .en_a_i   (bank1_en_o),
    .we_a_i   (bank1_we_o),
    .din_a_i  (bank1_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a1_addr_o),
    .en_b_i   (bram_a1_en_o),
    .dout_b_o (bram_a1_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a2 (
    .clk_i    (clk_i),
    .addr_a_i (bank2_addr_o),
    .en_a_i   (bank2_en_o),
    .we_a_i   (bank2_we_o),
    .din_a_i  (bank2_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a2_addr_o),
    .en_b_i   (bram_a2_en_o),
    .dout_b_o (bram_a2_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a3 (
    .clk_i    (clk_i),
    .addr_a_i (bank3_addr_o),
    .en_a_i   (bank3_en_o),
    .we_a_i   (bank3_we_o),
    .din_a_i  (bank3_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a3_addr_o),
    .en_b_i   (bram_a3_en_o),
    .dout_b_o (bram_a3_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a4 (
    .clk_i    (clk_i),
    .addr_a_i (bank4_addr_o),
    .en_a_i   (bank4_en_o),
    .we_a_i   (bank4_we_o),
    .din_a_i  (bank4_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a4_addr_o),
    .en_b_i   (bram_a4_en_o),
    .dout_b_o (bram_a4_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a5 (
    .clk_i    (clk_i),
    .addr_a_i (bank5_addr_o),
    .en_a_i   (bank5_en_o),
    .we_a_i   (bank5_we_o),
    .din_a_i  (bank5_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a5_addr_o),
    .en_b_i   (bram_a5_en_o),
    .dout_b_o (bram_a5_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a6 (
    .clk_i    (clk_i),
    .addr_a_i (bank6_addr_o),
    .en_a_i   (bank6_en_o),
    .we_a_i   (bank6_we_o),
    .din_a_i  (bank6_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a6_addr_o),
    .en_b_i   (bram_a6_en_o),
    .dout_b_o (bram_a6_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a7 (
    .clk_i    (clk_i),
    .addr_a_i (bank7_addr_o),
    .en_a_i   (bank7_en_o),
    .we_a_i   (bank7_we_o),
    .din_a_i  (bank7_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a7_addr_o),
    .en_b_i   (bram_a7_en_o),
    .dout_b_o (bram_a7_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a8 (
    .clk_i    (clk_i),
    .addr_a_i (bank8_addr_o),
    .en_a_i   (bank8_en_o),
    .we_a_i   (bank8_we_o),
    .din_a_i  (bank8_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a8_addr_o),
    .en_b_i   (bram_a8_en_o),
    .dout_b_o (bram_a8_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a9 (
    .clk_i    (clk_i),
    .addr_a_i (bank9_addr_o),
    .en_a_i   (bank9_en_o),
    .we_a_i   (bank9_we_o),
    .din_a_i  (bank9_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a9_addr_o),
    .en_b_i   (bram_a9_en_o),
    .dout_b_o (bram_a9_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a10 (
    .clk_i    (clk_i),
    .addr_a_i (bank10_addr_o),
    .en_a_i   (bank10_en_o),
    .we_a_i   (bank10_we_o),
    .din_a_i  (bank10_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a10_addr_o),
    .en_b_i   (bram_a10_en_o),
    .dout_b_o (bram_a10_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a11 (
    .clk_i    (clk_i),
    .addr_a_i (bank11_addr_o),
    .en_a_i   (bank11_en_o),
    .we_a_i   (bank11_we_o),
    .din_a_i  (bank11_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a11_addr_o),
    .en_b_i   (bram_a11_en_o),
    .dout_b_o (bram_a11_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a12 (
    .clk_i    (clk_i),
    .addr_a_i (bank12_addr_o),
    .en_a_i   (bank12_en_o),
    .we_a_i   (bank12_we_o),
    .din_a_i  (bank12_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a12_addr_o),
    .en_b_i   (bram_a12_en_o),
    .dout_b_o (bram_a12_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a13 (
    .clk_i    (clk_i),
    .addr_a_i (bank13_addr_o),
    .en_a_i   (bank13_en_o),
    .we_a_i   (bank13_we_o),
    .din_a_i  (bank13_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a13_addr_o),
    .en_b_i   (bram_a13_en_o),
    .dout_b_o (bram_a13_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a14 (
    .clk_i    (clk_i),
    .addr_a_i (bank14_addr_o),
    .en_a_i   (bank14_en_o),
    .we_a_i   (bank14_we_o),
    .din_a_i  (bank14_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a14_addr_o),
    .en_b_i   (bram_a14_en_o),
    .dout_b_o (bram_a14_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a15 (
    .clk_i    (clk_i),
    .addr_a_i (bank15_addr_o),
    .en_a_i   (bank15_en_o),
    .we_a_i   (bank15_we_o),
    .din_a_i  (bank15_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a15_addr_o),
    .en_b_i   (bram_a15_en_o),
    .dout_b_o (bram_a15_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a16 (
    .clk_i    (clk_i),
    .addr_a_i (bank16_addr_o),
    .en_a_i   (bank16_en_o),
    .we_a_i   (bank16_we_o),
    .din_a_i  (bank16_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a16_addr_o),
    .en_b_i   (bram_a16_en_o),
    .dout_b_o (bram_a16_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a17 (
    .clk_i    (clk_i),
    .addr_a_i (bank17_addr_o),
    .en_a_i   (bank17_en_o),
    .we_a_i   (bank17_we_o),
    .din_a_i  (bank17_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a17_addr_o),
    .en_b_i   (bram_a17_en_o),
    .dout_b_o (bram_a17_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a18 (
    .clk_i    (clk_i),
    .addr_a_i (bank18_addr_o),
    .en_a_i   (bank18_en_o),
    .we_a_i   (bank18_we_o),
    .din_a_i  (bank18_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a18_addr_o),
    .en_b_i   (bram_a18_en_o),
    .dout_b_o (bram_a18_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a19 (
    .clk_i    (clk_i),
    .addr_a_i (bank19_addr_o),
    .en_a_i   (bank19_en_o),
    .we_a_i   (bank19_we_o),
    .din_a_i  (bank19_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a19_addr_o),
    .en_b_i   (bram_a19_en_o),
    .dout_b_o (bram_a19_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a20 (
    .clk_i    (clk_i),
    .addr_a_i (bank20_addr_o),
    .en_a_i   (bank20_en_o),
    .we_a_i   (bank20_we_o),
    .din_a_i  (bank20_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a20_addr_o),
    .en_b_i   (bram_a20_en_o),
    .dout_b_o (bram_a20_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a21 (
    .clk_i    (clk_i),
    .addr_a_i (bank21_addr_o),
    .en_a_i   (bank21_en_o),
    .we_a_i   (bank21_we_o),
    .din_a_i  (bank21_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a21_addr_o),
    .en_b_i   (bram_a21_en_o),
    .dout_b_o (bram_a21_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a22 (
    .clk_i    (clk_i),
    .addr_a_i (bank22_addr_o),
    .en_a_i   (bank22_en_o),
    .we_a_i   (bank22_we_o),
    .din_a_i  (bank22_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a22_addr_o),
    .en_b_i   (bram_a22_en_o),
    .dout_b_o (bram_a22_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a23 (
    .clk_i    (clk_i),
    .addr_a_i (bank23_addr_o),
    .en_a_i   (bank23_en_o),
    .we_a_i   (bank23_we_o),
    .din_a_i  (bank23_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a23_addr_o),
    .en_b_i   (bram_a23_en_o),
    .dout_b_o (bram_a23_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a24 (
    .clk_i    (clk_i),
    .addr_a_i (bank24_addr_o),
    .en_a_i   (bank24_en_o),
    .we_a_i   (bank24_we_o),
    .din_a_i  (bank24_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a24_addr_o),
    .en_b_i   (bram_a24_en_o),
    .dout_b_o (bram_a24_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a25 (
    .clk_i    (clk_i),
    .addr_a_i (bank25_addr_o),
    .en_a_i   (bank25_en_o),
    .we_a_i   (bank25_we_o),
    .din_a_i  (bank25_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a25_addr_o),
    .en_b_i   (bram_a25_en_o),
    .dout_b_o (bram_a25_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a26 (
    .clk_i    (clk_i),
    .addr_a_i (bank26_addr_o),
    .en_a_i   (bank26_en_o),
    .we_a_i   (bank26_we_o),
    .din_a_i  (bank26_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a26_addr_o),
    .en_b_i   (bram_a26_en_o),
    .dout_b_o (bram_a26_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a27 (
    .clk_i    (clk_i),
    .addr_a_i (bank27_addr_o),
    .en_a_i   (bank27_en_o),
    .we_a_i   (bank27_we_o),
    .din_a_i  (bank27_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a27_addr_o),
    .en_b_i   (bram_a27_en_o),
    .dout_b_o (bram_a27_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a28 (
    .clk_i    (clk_i),
    .addr_a_i (bank28_addr_o),
    .en_a_i   (bank28_en_o),
    .we_a_i   (bank28_we_o),
    .din_a_i  (bank28_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a28_addr_o),
    .en_b_i   (bram_a28_en_o),
    .dout_b_o (bram_a28_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a29 (
    .clk_i    (clk_i),
    .addr_a_i (bank29_addr_o),
    .en_a_i   (bank29_en_o),
    .we_a_i   (bank29_we_o),
    .din_a_i  (bank29_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a29_addr_o),
    .en_b_i   (bram_a29_en_o),
    .dout_b_o (bram_a29_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a30 (
    .clk_i    (clk_i),
    .addr_a_i (bank30_addr_o),
    .en_a_i   (bank30_en_o),
    .we_a_i   (bank30_we_o),
    .din_a_i  (bank30_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a30_addr_o),
    .en_b_i   (bram_a30_en_o),
    .dout_b_o (bram_a30_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a31 (
    .clk_i    (clk_i),
    .addr_a_i (bank31_addr_o),
    .en_a_i   (bank31_en_o),
    .we_a_i   (bank31_we_o),
    .din_a_i  (bank31_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a31_addr_o),
    .en_b_i   (bram_a31_en_o),
    .dout_b_o (bram_a31_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a32 (
    .clk_i    (clk_i),
    .addr_a_i (bank32_addr_o),
    .en_a_i   (bank32_en_o),
    .we_a_i   (bank32_we_o),
    .din_a_i  (bank32_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a32_addr_o),
    .en_b_i   (bram_a32_en_o),
    .dout_b_o (bram_a32_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a33 (
    .clk_i    (clk_i),
    .addr_a_i (bank33_addr_o),
    .en_a_i   (bank33_en_o),
    .we_a_i   (bank33_we_o),
    .din_a_i  (bank33_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a33_addr_o),
    .en_b_i   (bram_a33_en_o),
    .dout_b_o (bram_a33_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a34 (
    .clk_i    (clk_i),
    .addr_a_i (bank34_addr_o),
    .en_a_i   (bank34_en_o),
    .we_a_i   (bank34_we_o),
    .din_a_i  (bank34_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a34_addr_o),
    .en_b_i   (bram_a34_en_o),
    .dout_b_o (bram_a34_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a35 (
    .clk_i    (clk_i),
    .addr_a_i (bank35_addr_o),
    .en_a_i   (bank35_en_o),
    .we_a_i   (bank35_we_o),
    .din_a_i  (bank35_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a35_addr_o),
    .en_b_i   (bram_a35_en_o),
    .dout_b_o (bram_a35_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a36 (
    .clk_i    (clk_i),
    .addr_a_i (bank36_addr_o),
    .en_a_i   (bank36_en_o),
    .we_a_i   (bank36_we_o),
    .din_a_i  (bank36_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a36_addr_o),
    .en_b_i   (bram_a36_en_o),
    .dout_b_o (bram_a36_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a37 (
    .clk_i    (clk_i),
    .addr_a_i (bank37_addr_o),
    .en_a_i   (bank37_en_o),
    .we_a_i   (bank37_we_o),
    .din_a_i  (bank37_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a37_addr_o),
    .en_b_i   (bram_a37_en_o),
    .dout_b_o (bram_a37_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a38 (
    .clk_i    (clk_i),
    .addr_a_i (bank38_addr_o),
    .en_a_i   (bank38_en_o),
    .we_a_i   (bank38_we_o),
    .din_a_i  (bank38_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a38_addr_o),
    .en_b_i   (bram_a38_en_o),
    .dout_b_o (bram_a38_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a39 (
    .clk_i    (clk_i),
    .addr_a_i (bank39_addr_o),
    .en_a_i   (bank39_en_o),
    .we_a_i   (bank39_we_o),
    .din_a_i  (bank39_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a39_addr_o),
    .en_b_i   (bram_a39_en_o),
    .dout_b_o (bram_a39_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a40 (
    .clk_i    (clk_i),
    .addr_a_i (bank40_addr_o),
    .en_a_i   (bank40_en_o),
    .we_a_i   (bank40_we_o),
    .din_a_i  (bank40_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a40_addr_o),
    .en_b_i   (bram_a40_en_o),
    .dout_b_o (bram_a40_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a41 (
    .clk_i    (clk_i),
    .addr_a_i (bank41_addr_o),
    .en_a_i   (bank41_en_o),
    .we_a_i   (bank41_we_o),
    .din_a_i  (bank41_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a41_addr_o),
    .en_b_i   (bram_a41_en_o),
    .dout_b_o (bram_a41_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a42 (
    .clk_i    (clk_i),
    .addr_a_i (bank42_addr_o),
    .en_a_i   (bank42_en_o),
    .we_a_i   (bank42_we_o),
    .din_a_i  (bank42_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a42_addr_o),
    .en_b_i   (bram_a42_en_o),
    .dout_b_o (bram_a42_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a43 (
    .clk_i    (clk_i),
    .addr_a_i (bank43_addr_o),
    .en_a_i   (bank43_en_o),
    .we_a_i   (bank43_we_o),
    .din_a_i  (bank43_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a43_addr_o),
    .en_b_i   (bram_a43_en_o),
    .dout_b_o (bram_a43_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a44 (
    .clk_i    (clk_i),
    .addr_a_i (bank44_addr_o),
    .en_a_i   (bank44_en_o),
    .we_a_i   (bank44_we_o),
    .din_a_i  (bank44_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a44_addr_o),
    .en_b_i   (bram_a44_en_o),
    .dout_b_o (bram_a44_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a45 (
    .clk_i    (clk_i),
    .addr_a_i (bank45_addr_o),
    .en_a_i   (bank45_en_o),
    .we_a_i   (bank45_we_o),
    .din_a_i  (bank45_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a45_addr_o),
    .en_b_i   (bram_a45_en_o),
    .dout_b_o (bram_a45_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a46 (
    .clk_i    (clk_i),
    .addr_a_i (bank46_addr_o),
    .en_a_i   (bank46_en_o),
    .we_a_i   (bank46_we_o),
    .din_a_i  (bank46_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a46_addr_o),
    .en_b_i   (bram_a46_en_o),
    .dout_b_o (bram_a46_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a47 (
    .clk_i    (clk_i),
    .addr_a_i (bank47_addr_o),
    .en_a_i   (bank47_en_o),
    .we_a_i   (bank47_we_o),
    .din_a_i  (bank47_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a47_addr_o),
    .en_b_i   (bram_a47_en_o),
    .dout_b_o (bram_a47_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a48 (
    .clk_i    (clk_i),
    .addr_a_i (bank48_addr_o),
    .en_a_i   (bank48_en_o),
    .we_a_i   (bank48_we_o),
    .din_a_i  (bank48_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a48_addr_o),
    .en_b_i   (bram_a48_en_o),
    .dout_b_o (bram_a48_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a49 (
    .clk_i    (clk_i),
    .addr_a_i (bank49_addr_o),
    .en_a_i   (bank49_en_o),
    .we_a_i   (bank49_we_o),
    .din_a_i  (bank49_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a49_addr_o),
    .en_b_i   (bram_a49_en_o),
    .dout_b_o (bram_a49_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a50 (
    .clk_i    (clk_i),
    .addr_a_i (bank50_addr_o),
    .en_a_i   (bank50_en_o),
    .we_a_i   (bank50_we_o),
    .din_a_i  (bank50_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a50_addr_o),
    .en_b_i   (bram_a50_en_o),
    .dout_b_o (bram_a50_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a51 (
    .clk_i    (clk_i),
    .addr_a_i (bank51_addr_o),
    .en_a_i   (bank51_en_o),
    .we_a_i   (bank51_we_o),
    .din_a_i  (bank51_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a51_addr_o),
    .en_b_i   (bram_a51_en_o),
    .dout_b_o (bram_a51_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a52 (
    .clk_i    (clk_i),
    .addr_a_i (bank52_addr_o),
    .en_a_i   (bank52_en_o),
    .we_a_i   (bank52_we_o),
    .din_a_i  (bank52_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a52_addr_o),
    .en_b_i   (bram_a52_en_o),
    .dout_b_o (bram_a52_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a53 (
    .clk_i    (clk_i),
    .addr_a_i (bank53_addr_o),
    .en_a_i   (bank53_en_o),
    .we_a_i   (bank53_we_o),
    .din_a_i  (bank53_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a53_addr_o),
    .en_b_i   (bram_a53_en_o),
    .dout_b_o (bram_a53_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a54 (
    .clk_i    (clk_i),
    .addr_a_i (bank54_addr_o),
    .en_a_i   (bank54_en_o),
    .we_a_i   (bank54_we_o),
    .din_a_i  (bank54_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a54_addr_o),
    .en_b_i   (bram_a54_en_o),
    .dout_b_o (bram_a54_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a55 (
    .clk_i    (clk_i),
    .addr_a_i (bank55_addr_o),
    .en_a_i   (bank55_en_o),
    .we_a_i   (bank55_we_o),
    .din_a_i  (bank55_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a55_addr_o),
    .en_b_i   (bram_a55_en_o),
    .dout_b_o (bram_a55_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a56 (
    .clk_i    (clk_i),
    .addr_a_i (bank56_addr_o),
    .en_a_i   (bank56_en_o),
    .we_a_i   (bank56_we_o),
    .din_a_i  (bank56_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a56_addr_o),
    .en_b_i   (bram_a56_en_o),
    .dout_b_o (bram_a56_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a57 (
    .clk_i    (clk_i),
    .addr_a_i (bank57_addr_o),
    .en_a_i   (bank57_en_o),
    .we_a_i   (bank57_we_o),
    .din_a_i  (bank57_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a57_addr_o),
    .en_b_i   (bram_a57_en_o),
    .dout_b_o (bram_a57_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a58 (
    .clk_i    (clk_i),
    .addr_a_i (bank58_addr_o),
    .en_a_i   (bank58_en_o),
    .we_a_i   (bank58_we_o),
    .din_a_i  (bank58_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a58_addr_o),
    .en_b_i   (bram_a58_en_o),
    .dout_b_o (bram_a58_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a59 (
    .clk_i    (clk_i),
    .addr_a_i (bank59_addr_o),
    .en_a_i   (bank59_en_o),
    .we_a_i   (bank59_we_o),
    .din_a_i  (bank59_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a59_addr_o),
    .en_b_i   (bram_a59_en_o),
    .dout_b_o (bram_a59_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a60 (
    .clk_i    (clk_i),
    .addr_a_i (bank60_addr_o),
    .en_a_i   (bank60_en_o),
    .we_a_i   (bank60_we_o),
    .din_a_i  (bank60_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a60_addr_o),
    .en_b_i   (bram_a60_en_o),
    .dout_b_o (bram_a60_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a61 (
    .clk_i    (clk_i),
    .addr_a_i (bank61_addr_o),
    .en_a_i   (bank61_en_o),
    .we_a_i   (bank61_we_o),
    .din_a_i  (bank61_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a61_addr_o),
    .en_b_i   (bram_a61_en_o),
    .dout_b_o (bram_a61_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a62 (
    .clk_i    (clk_i),
    .addr_a_i (bank62_addr_o),
    .en_a_i   (bank62_en_o),
    .we_a_i   (bank62_we_o),
    .din_a_i  (bank62_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a62_addr_o),
    .en_b_i   (bram_a62_en_o),
    .dout_b_o (bram_a62_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(768)) dpb_a63 (
    .clk_i    (clk_i),
    .addr_a_i (bank63_addr_o),
    .en_a_i   (bank63_en_o),
    .we_a_i   (bank63_we_o),
    .din_a_i  (bank63_din_o),
    .dout_a_o (),
    .addr_b_i (bram_a63_addr_o),
    .en_b_i   (bram_a63_en_o),
    .dout_b_o (bram_a63_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b0 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank0_addr_o),
    .en_a_i   (b_bank0_en_o),
    .we_a_i   (b_bank0_we_o),
    .din_a_i  (b_bank0_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b0_addr_o),
    .en_b_i   (bram_b0_en_o),
    .dout_b_o (bram_b0_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b1 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank1_addr_o),
    .en_a_i   (b_bank1_en_o),
    .we_a_i   (b_bank1_we_o),
    .din_a_i  (b_bank1_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b1_addr_o),
    .en_b_i   (bram_b1_en_o),
    .dout_b_o (bram_b1_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b2 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank2_addr_o),
    .en_a_i   (b_bank2_en_o),
    .we_a_i   (b_bank2_we_o),
    .din_a_i  (b_bank2_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b2_addr_o),
    .en_b_i   (bram_b2_en_o),
    .dout_b_o (bram_b2_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b3 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank3_addr_o),
    .en_a_i   (b_bank3_en_o),
    .we_a_i   (b_bank3_we_o),
    .din_a_i  (b_bank3_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b3_addr_o),
    .en_b_i   (bram_b3_en_o),
    .dout_b_o (bram_b3_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b4 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank4_addr_o),
    .en_a_i   (b_bank4_en_o),
    .we_a_i   (b_bank4_we_o),
    .din_a_i  (b_bank4_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b4_addr_o),
    .en_b_i   (bram_b4_en_o),
    .dout_b_o (bram_b4_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b5 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank5_addr_o),
    .en_a_i   (b_bank5_en_o),
    .we_a_i   (b_bank5_we_o),
    .din_a_i  (b_bank5_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b5_addr_o),
    .en_b_i   (bram_b5_en_o),
    .dout_b_o (bram_b5_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b6 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank6_addr_o),
    .en_a_i   (b_bank6_en_o),
    .we_a_i   (b_bank6_we_o),
    .din_a_i  (b_bank6_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b6_addr_o),
    .en_b_i   (bram_b6_en_o),
    .dout_b_o (bram_b6_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b7 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank7_addr_o),
    .en_a_i   (b_bank7_en_o),
    .we_a_i   (b_bank7_we_o),
    .din_a_i  (b_bank7_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b7_addr_o),
    .en_b_i   (bram_b7_en_o),
    .dout_b_o (bram_b7_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b8 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank8_addr_o),
    .en_a_i   (b_bank8_en_o),
    .we_a_i   (b_bank8_we_o),
    .din_a_i  (b_bank8_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b8_addr_o),
    .en_b_i   (bram_b8_en_o),
    .dout_b_o (bram_b8_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b9 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank9_addr_o),
    .en_a_i   (b_bank9_en_o),
    .we_a_i   (b_bank9_we_o),
    .din_a_i  (b_bank9_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b9_addr_o),
    .en_b_i   (bram_b9_en_o),
    .dout_b_o (bram_b9_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b10 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank10_addr_o),
    .en_a_i   (b_bank10_en_o),
    .we_a_i   (b_bank10_we_o),
    .din_a_i  (b_bank10_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b10_addr_o),
    .en_b_i   (bram_b10_en_o),
    .dout_b_o (bram_b10_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b11 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank11_addr_o),
    .en_a_i   (b_bank11_en_o),
    .we_a_i   (b_bank11_we_o),
    .din_a_i  (b_bank11_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b11_addr_o),
    .en_b_i   (bram_b11_en_o),
    .dout_b_o (bram_b11_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b12 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank12_addr_o),
    .en_a_i   (b_bank12_en_o),
    .we_a_i   (b_bank12_we_o),
    .din_a_i  (b_bank12_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b12_addr_o),
    .en_b_i   (bram_b12_en_o),
    .dout_b_o (bram_b12_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b13 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank13_addr_o),
    .en_a_i   (b_bank13_en_o),
    .we_a_i   (b_bank13_we_o),
    .din_a_i  (b_bank13_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b13_addr_o),
    .en_b_i   (bram_b13_en_o),
    .dout_b_o (bram_b13_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b14 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank14_addr_o),
    .en_a_i   (b_bank14_en_o),
    .we_a_i   (b_bank14_we_o),
    .din_a_i  (b_bank14_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b14_addr_o),
    .en_b_i   (bram_b14_en_o),
    .dout_b_o (bram_b14_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b15 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank15_addr_o),
    .en_a_i   (b_bank15_en_o),
    .we_a_i   (b_bank15_we_o),
    .din_a_i  (b_bank15_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b15_addr_o),
    .en_b_i   (bram_b15_en_o),
    .dout_b_o (bram_b15_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b16 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank16_addr_o),
    .en_a_i   (b_bank16_en_o),
    .we_a_i   (b_bank16_we_o),
    .din_a_i  (b_bank16_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b16_addr_o),
    .en_b_i   (bram_b16_en_o),
    .dout_b_o (bram_b16_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b17 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank17_addr_o),
    .en_a_i   (b_bank17_en_o),
    .we_a_i   (b_bank17_we_o),
    .din_a_i  (b_bank17_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b17_addr_o),
    .en_b_i   (bram_b17_en_o),
    .dout_b_o (bram_b17_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b18 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank18_addr_o),
    .en_a_i   (b_bank18_en_o),
    .we_a_i   (b_bank18_we_o),
    .din_a_i  (b_bank18_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b18_addr_o),
    .en_b_i   (bram_b18_en_o),
    .dout_b_o (bram_b18_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b19 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank19_addr_o),
    .en_a_i   (b_bank19_en_o),
    .we_a_i   (b_bank19_we_o),
    .din_a_i  (b_bank19_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b19_addr_o),
    .en_b_i   (bram_b19_en_o),
    .dout_b_o (bram_b19_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b20 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank20_addr_o),
    .en_a_i   (b_bank20_en_o),
    .we_a_i   (b_bank20_we_o),
    .din_a_i  (b_bank20_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b20_addr_o),
    .en_b_i   (bram_b20_en_o),
    .dout_b_o (bram_b20_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b21 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank21_addr_o),
    .en_a_i   (b_bank21_en_o),
    .we_a_i   (b_bank21_we_o),
    .din_a_i  (b_bank21_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b21_addr_o),
    .en_b_i   (bram_b21_en_o),
    .dout_b_o (bram_b21_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b22 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank22_addr_o),
    .en_a_i   (b_bank22_en_o),
    .we_a_i   (b_bank22_we_o),
    .din_a_i  (b_bank22_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b22_addr_o),
    .en_b_i   (bram_b22_en_o),
    .dout_b_o (bram_b22_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b23 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank23_addr_o),
    .en_a_i   (b_bank23_en_o),
    .we_a_i   (b_bank23_we_o),
    .din_a_i  (b_bank23_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b23_addr_o),
    .en_b_i   (bram_b23_en_o),
    .dout_b_o (bram_b23_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b24 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank24_addr_o),
    .en_a_i   (b_bank24_en_o),
    .we_a_i   (b_bank24_we_o),
    .din_a_i  (b_bank24_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b24_addr_o),
    .en_b_i   (bram_b24_en_o),
    .dout_b_o (bram_b24_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b25 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank25_addr_o),
    .en_a_i   (b_bank25_en_o),
    .we_a_i   (b_bank25_we_o),
    .din_a_i  (b_bank25_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b25_addr_o),
    .en_b_i   (bram_b25_en_o),
    .dout_b_o (bram_b25_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b26 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank26_addr_o),
    .en_a_i   (b_bank26_en_o),
    .we_a_i   (b_bank26_we_o),
    .din_a_i  (b_bank26_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b26_addr_o),
    .en_b_i   (bram_b26_en_o),
    .dout_b_o (bram_b26_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b27 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank27_addr_o),
    .en_a_i   (b_bank27_en_o),
    .we_a_i   (b_bank27_we_o),
    .din_a_i  (b_bank27_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b27_addr_o),
    .en_b_i   (bram_b27_en_o),
    .dout_b_o (bram_b27_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b28 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank28_addr_o),
    .en_a_i   (b_bank28_en_o),
    .we_a_i   (b_bank28_we_o),
    .din_a_i  (b_bank28_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b28_addr_o),
    .en_b_i   (bram_b28_en_o),
    .dout_b_o (bram_b28_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b29 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank29_addr_o),
    .en_a_i   (b_bank29_en_o),
    .we_a_i   (b_bank29_we_o),
    .din_a_i  (b_bank29_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b29_addr_o),
    .en_b_i   (bram_b29_en_o),
    .dout_b_o (bram_b29_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b30 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank30_addr_o),
    .en_a_i   (b_bank30_en_o),
    .we_a_i   (b_bank30_we_o),
    .din_a_i  (b_bank30_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b30_addr_o),
    .en_b_i   (bram_b30_en_o),
    .dout_b_o (bram_b30_dout_i)
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(6144)) dpb_b31 (
    .clk_i    (clk_i),
    .addr_a_i (b_bank31_addr_o),
    .en_a_i   (b_bank31_en_o),
    .we_a_i   (b_bank31_we_o),
    .din_a_i  (b_bank31_din_o),
    .dout_a_o (),
    .addr_b_i (bram_b31_addr_o),
    .en_b_i   (bram_b31_en_o),
    .dout_b_o (bram_b31_dout_i)
  );

  // ---- Cau tin hieu dieu khien/mux giua mmult_accel va SYSTOLIC_CORE_TOP (ten khac nhau) ----
  assign tile_valid_i = tile_valid_o;  // core.input <= mmult.output
  assign tile_ready_i = tile_ready_o;  // mmult.input <= core.output
  assign tile_done_i  = tile_done_o;   // mmult.input <= core.output
  assign tile_i_sel_i = tile_i_sel_o;  // core.input <= mmult.output
  assign tile_j_sel_i = tile_j_sel_o;  // core.input <= mmult.output
  // ---- Cau 1024 tin hieu C: c_arr_<r>_<c> (mmult_accel, input) <= c<r>_<c>_o (core, output) ----
  assign c_arr_0_0 = c0_0_o;
  assign c_arr_0_1 = c0_1_o;
  assign c_arr_0_2 = c0_2_o;
  assign c_arr_0_3 = c0_3_o;
  assign c_arr_0_4 = c0_4_o;
  assign c_arr_0_5 = c0_5_o;
  assign c_arr_0_6 = c0_6_o;
  assign c_arr_0_7 = c0_7_o;
  assign c_arr_0_8 = c0_8_o;
  assign c_arr_0_9 = c0_9_o;
  assign c_arr_0_10 = c0_10_o;
  assign c_arr_0_11 = c0_11_o;
  assign c_arr_0_12 = c0_12_o;
  assign c_arr_0_13 = c0_13_o;
  assign c_arr_0_14 = c0_14_o;
  assign c_arr_0_15 = c0_15_o;
  assign c_arr_0_16 = c0_16_o;
  assign c_arr_0_17 = c0_17_o;
  assign c_arr_0_18 = c0_18_o;
  assign c_arr_0_19 = c0_19_o;
  assign c_arr_0_20 = c0_20_o;
  assign c_arr_0_21 = c0_21_o;
  assign c_arr_0_22 = c0_22_o;
  assign c_arr_0_23 = c0_23_o;
  assign c_arr_0_24 = c0_24_o;
  assign c_arr_0_25 = c0_25_o;
  assign c_arr_0_26 = c0_26_o;
  assign c_arr_0_27 = c0_27_o;
  assign c_arr_0_28 = c0_28_o;
  assign c_arr_0_29 = c0_29_o;
  assign c_arr_0_30 = c0_30_o;
  assign c_arr_0_31 = c0_31_o;
  assign c_arr_1_0 = c1_0_o;
  assign c_arr_1_1 = c1_1_o;
  assign c_arr_1_2 = c1_2_o;
  assign c_arr_1_3 = c1_3_o;
  assign c_arr_1_4 = c1_4_o;
  assign c_arr_1_5 = c1_5_o;
  assign c_arr_1_6 = c1_6_o;
  assign c_arr_1_7 = c1_7_o;
  assign c_arr_1_8 = c1_8_o;
  assign c_arr_1_9 = c1_9_o;
  assign c_arr_1_10 = c1_10_o;
  assign c_arr_1_11 = c1_11_o;
  assign c_arr_1_12 = c1_12_o;
  assign c_arr_1_13 = c1_13_o;
  assign c_arr_1_14 = c1_14_o;
  assign c_arr_1_15 = c1_15_o;
  assign c_arr_1_16 = c1_16_o;
  assign c_arr_1_17 = c1_17_o;
  assign c_arr_1_18 = c1_18_o;
  assign c_arr_1_19 = c1_19_o;
  assign c_arr_1_20 = c1_20_o;
  assign c_arr_1_21 = c1_21_o;
  assign c_arr_1_22 = c1_22_o;
  assign c_arr_1_23 = c1_23_o;
  assign c_arr_1_24 = c1_24_o;
  assign c_arr_1_25 = c1_25_o;
  assign c_arr_1_26 = c1_26_o;
  assign c_arr_1_27 = c1_27_o;
  assign c_arr_1_28 = c1_28_o;
  assign c_arr_1_29 = c1_29_o;
  assign c_arr_1_30 = c1_30_o;
  assign c_arr_1_31 = c1_31_o;
  assign c_arr_2_0 = c2_0_o;
  assign c_arr_2_1 = c2_1_o;
  assign c_arr_2_2 = c2_2_o;
  assign c_arr_2_3 = c2_3_o;
  assign c_arr_2_4 = c2_4_o;
  assign c_arr_2_5 = c2_5_o;
  assign c_arr_2_6 = c2_6_o;
  assign c_arr_2_7 = c2_7_o;
  assign c_arr_2_8 = c2_8_o;
  assign c_arr_2_9 = c2_9_o;
  assign c_arr_2_10 = c2_10_o;
  assign c_arr_2_11 = c2_11_o;
  assign c_arr_2_12 = c2_12_o;
  assign c_arr_2_13 = c2_13_o;
  assign c_arr_2_14 = c2_14_o;
  assign c_arr_2_15 = c2_15_o;
  assign c_arr_2_16 = c2_16_o;
  assign c_arr_2_17 = c2_17_o;
  assign c_arr_2_18 = c2_18_o;
  assign c_arr_2_19 = c2_19_o;
  assign c_arr_2_20 = c2_20_o;
  assign c_arr_2_21 = c2_21_o;
  assign c_arr_2_22 = c2_22_o;
  assign c_arr_2_23 = c2_23_o;
  assign c_arr_2_24 = c2_24_o;
  assign c_arr_2_25 = c2_25_o;
  assign c_arr_2_26 = c2_26_o;
  assign c_arr_2_27 = c2_27_o;
  assign c_arr_2_28 = c2_28_o;
  assign c_arr_2_29 = c2_29_o;
  assign c_arr_2_30 = c2_30_o;
  assign c_arr_2_31 = c2_31_o;
  assign c_arr_3_0 = c3_0_o;
  assign c_arr_3_1 = c3_1_o;
  assign c_arr_3_2 = c3_2_o;
  assign c_arr_3_3 = c3_3_o;
  assign c_arr_3_4 = c3_4_o;
  assign c_arr_3_5 = c3_5_o;
  assign c_arr_3_6 = c3_6_o;
  assign c_arr_3_7 = c3_7_o;
  assign c_arr_3_8 = c3_8_o;
  assign c_arr_3_9 = c3_9_o;
  assign c_arr_3_10 = c3_10_o;
  assign c_arr_3_11 = c3_11_o;
  assign c_arr_3_12 = c3_12_o;
  assign c_arr_3_13 = c3_13_o;
  assign c_arr_3_14 = c3_14_o;
  assign c_arr_3_15 = c3_15_o;
  assign c_arr_3_16 = c3_16_o;
  assign c_arr_3_17 = c3_17_o;
  assign c_arr_3_18 = c3_18_o;
  assign c_arr_3_19 = c3_19_o;
  assign c_arr_3_20 = c3_20_o;
  assign c_arr_3_21 = c3_21_o;
  assign c_arr_3_22 = c3_22_o;
  assign c_arr_3_23 = c3_23_o;
  assign c_arr_3_24 = c3_24_o;
  assign c_arr_3_25 = c3_25_o;
  assign c_arr_3_26 = c3_26_o;
  assign c_arr_3_27 = c3_27_o;
  assign c_arr_3_28 = c3_28_o;
  assign c_arr_3_29 = c3_29_o;
  assign c_arr_3_30 = c3_30_o;
  assign c_arr_3_31 = c3_31_o;
  assign c_arr_4_0 = c4_0_o;
  assign c_arr_4_1 = c4_1_o;
  assign c_arr_4_2 = c4_2_o;
  assign c_arr_4_3 = c4_3_o;
  assign c_arr_4_4 = c4_4_o;
  assign c_arr_4_5 = c4_5_o;
  assign c_arr_4_6 = c4_6_o;
  assign c_arr_4_7 = c4_7_o;
  assign c_arr_4_8 = c4_8_o;
  assign c_arr_4_9 = c4_9_o;
  assign c_arr_4_10 = c4_10_o;
  assign c_arr_4_11 = c4_11_o;
  assign c_arr_4_12 = c4_12_o;
  assign c_arr_4_13 = c4_13_o;
  assign c_arr_4_14 = c4_14_o;
  assign c_arr_4_15 = c4_15_o;
  assign c_arr_4_16 = c4_16_o;
  assign c_arr_4_17 = c4_17_o;
  assign c_arr_4_18 = c4_18_o;
  assign c_arr_4_19 = c4_19_o;
  assign c_arr_4_20 = c4_20_o;
  assign c_arr_4_21 = c4_21_o;
  assign c_arr_4_22 = c4_22_o;
  assign c_arr_4_23 = c4_23_o;
  assign c_arr_4_24 = c4_24_o;
  assign c_arr_4_25 = c4_25_o;
  assign c_arr_4_26 = c4_26_o;
  assign c_arr_4_27 = c4_27_o;
  assign c_arr_4_28 = c4_28_o;
  assign c_arr_4_29 = c4_29_o;
  assign c_arr_4_30 = c4_30_o;
  assign c_arr_4_31 = c4_31_o;
  assign c_arr_5_0 = c5_0_o;
  assign c_arr_5_1 = c5_1_o;
  assign c_arr_5_2 = c5_2_o;
  assign c_arr_5_3 = c5_3_o;
  assign c_arr_5_4 = c5_4_o;
  assign c_arr_5_5 = c5_5_o;
  assign c_arr_5_6 = c5_6_o;
  assign c_arr_5_7 = c5_7_o;
  assign c_arr_5_8 = c5_8_o;
  assign c_arr_5_9 = c5_9_o;
  assign c_arr_5_10 = c5_10_o;
  assign c_arr_5_11 = c5_11_o;
  assign c_arr_5_12 = c5_12_o;
  assign c_arr_5_13 = c5_13_o;
  assign c_arr_5_14 = c5_14_o;
  assign c_arr_5_15 = c5_15_o;
  assign c_arr_5_16 = c5_16_o;
  assign c_arr_5_17 = c5_17_o;
  assign c_arr_5_18 = c5_18_o;
  assign c_arr_5_19 = c5_19_o;
  assign c_arr_5_20 = c5_20_o;
  assign c_arr_5_21 = c5_21_o;
  assign c_arr_5_22 = c5_22_o;
  assign c_arr_5_23 = c5_23_o;
  assign c_arr_5_24 = c5_24_o;
  assign c_arr_5_25 = c5_25_o;
  assign c_arr_5_26 = c5_26_o;
  assign c_arr_5_27 = c5_27_o;
  assign c_arr_5_28 = c5_28_o;
  assign c_arr_5_29 = c5_29_o;
  assign c_arr_5_30 = c5_30_o;
  assign c_arr_5_31 = c5_31_o;
  assign c_arr_6_0 = c6_0_o;
  assign c_arr_6_1 = c6_1_o;
  assign c_arr_6_2 = c6_2_o;
  assign c_arr_6_3 = c6_3_o;
  assign c_arr_6_4 = c6_4_o;
  assign c_arr_6_5 = c6_5_o;
  assign c_arr_6_6 = c6_6_o;
  assign c_arr_6_7 = c6_7_o;
  assign c_arr_6_8 = c6_8_o;
  assign c_arr_6_9 = c6_9_o;
  assign c_arr_6_10 = c6_10_o;
  assign c_arr_6_11 = c6_11_o;
  assign c_arr_6_12 = c6_12_o;
  assign c_arr_6_13 = c6_13_o;
  assign c_arr_6_14 = c6_14_o;
  assign c_arr_6_15 = c6_15_o;
  assign c_arr_6_16 = c6_16_o;
  assign c_arr_6_17 = c6_17_o;
  assign c_arr_6_18 = c6_18_o;
  assign c_arr_6_19 = c6_19_o;
  assign c_arr_6_20 = c6_20_o;
  assign c_arr_6_21 = c6_21_o;
  assign c_arr_6_22 = c6_22_o;
  assign c_arr_6_23 = c6_23_o;
  assign c_arr_6_24 = c6_24_o;
  assign c_arr_6_25 = c6_25_o;
  assign c_arr_6_26 = c6_26_o;
  assign c_arr_6_27 = c6_27_o;
  assign c_arr_6_28 = c6_28_o;
  assign c_arr_6_29 = c6_29_o;
  assign c_arr_6_30 = c6_30_o;
  assign c_arr_6_31 = c6_31_o;
  assign c_arr_7_0 = c7_0_o;
  assign c_arr_7_1 = c7_1_o;
  assign c_arr_7_2 = c7_2_o;
  assign c_arr_7_3 = c7_3_o;
  assign c_arr_7_4 = c7_4_o;
  assign c_arr_7_5 = c7_5_o;
  assign c_arr_7_6 = c7_6_o;
  assign c_arr_7_7 = c7_7_o;
  assign c_arr_7_8 = c7_8_o;
  assign c_arr_7_9 = c7_9_o;
  assign c_arr_7_10 = c7_10_o;
  assign c_arr_7_11 = c7_11_o;
  assign c_arr_7_12 = c7_12_o;
  assign c_arr_7_13 = c7_13_o;
  assign c_arr_7_14 = c7_14_o;
  assign c_arr_7_15 = c7_15_o;
  assign c_arr_7_16 = c7_16_o;
  assign c_arr_7_17 = c7_17_o;
  assign c_arr_7_18 = c7_18_o;
  assign c_arr_7_19 = c7_19_o;
  assign c_arr_7_20 = c7_20_o;
  assign c_arr_7_21 = c7_21_o;
  assign c_arr_7_22 = c7_22_o;
  assign c_arr_7_23 = c7_23_o;
  assign c_arr_7_24 = c7_24_o;
  assign c_arr_7_25 = c7_25_o;
  assign c_arr_7_26 = c7_26_o;
  assign c_arr_7_27 = c7_27_o;
  assign c_arr_7_28 = c7_28_o;
  assign c_arr_7_29 = c7_29_o;
  assign c_arr_7_30 = c7_30_o;
  assign c_arr_7_31 = c7_31_o;
  assign c_arr_8_0 = c8_0_o;
  assign c_arr_8_1 = c8_1_o;
  assign c_arr_8_2 = c8_2_o;
  assign c_arr_8_3 = c8_3_o;
  assign c_arr_8_4 = c8_4_o;
  assign c_arr_8_5 = c8_5_o;
  assign c_arr_8_6 = c8_6_o;
  assign c_arr_8_7 = c8_7_o;
  assign c_arr_8_8 = c8_8_o;
  assign c_arr_8_9 = c8_9_o;
  assign c_arr_8_10 = c8_10_o;
  assign c_arr_8_11 = c8_11_o;
  assign c_arr_8_12 = c8_12_o;
  assign c_arr_8_13 = c8_13_o;
  assign c_arr_8_14 = c8_14_o;
  assign c_arr_8_15 = c8_15_o;
  assign c_arr_8_16 = c8_16_o;
  assign c_arr_8_17 = c8_17_o;
  assign c_arr_8_18 = c8_18_o;
  assign c_arr_8_19 = c8_19_o;
  assign c_arr_8_20 = c8_20_o;
  assign c_arr_8_21 = c8_21_o;
  assign c_arr_8_22 = c8_22_o;
  assign c_arr_8_23 = c8_23_o;
  assign c_arr_8_24 = c8_24_o;
  assign c_arr_8_25 = c8_25_o;
  assign c_arr_8_26 = c8_26_o;
  assign c_arr_8_27 = c8_27_o;
  assign c_arr_8_28 = c8_28_o;
  assign c_arr_8_29 = c8_29_o;
  assign c_arr_8_30 = c8_30_o;
  assign c_arr_8_31 = c8_31_o;
  assign c_arr_9_0 = c9_0_o;
  assign c_arr_9_1 = c9_1_o;
  assign c_arr_9_2 = c9_2_o;
  assign c_arr_9_3 = c9_3_o;
  assign c_arr_9_4 = c9_4_o;
  assign c_arr_9_5 = c9_5_o;
  assign c_arr_9_6 = c9_6_o;
  assign c_arr_9_7 = c9_7_o;
  assign c_arr_9_8 = c9_8_o;
  assign c_arr_9_9 = c9_9_o;
  assign c_arr_9_10 = c9_10_o;
  assign c_arr_9_11 = c9_11_o;
  assign c_arr_9_12 = c9_12_o;
  assign c_arr_9_13 = c9_13_o;
  assign c_arr_9_14 = c9_14_o;
  assign c_arr_9_15 = c9_15_o;
  assign c_arr_9_16 = c9_16_o;
  assign c_arr_9_17 = c9_17_o;
  assign c_arr_9_18 = c9_18_o;
  assign c_arr_9_19 = c9_19_o;
  assign c_arr_9_20 = c9_20_o;
  assign c_arr_9_21 = c9_21_o;
  assign c_arr_9_22 = c9_22_o;
  assign c_arr_9_23 = c9_23_o;
  assign c_arr_9_24 = c9_24_o;
  assign c_arr_9_25 = c9_25_o;
  assign c_arr_9_26 = c9_26_o;
  assign c_arr_9_27 = c9_27_o;
  assign c_arr_9_28 = c9_28_o;
  assign c_arr_9_29 = c9_29_o;
  assign c_arr_9_30 = c9_30_o;
  assign c_arr_9_31 = c9_31_o;
  assign c_arr_10_0 = c10_0_o;
  assign c_arr_10_1 = c10_1_o;
  assign c_arr_10_2 = c10_2_o;
  assign c_arr_10_3 = c10_3_o;
  assign c_arr_10_4 = c10_4_o;
  assign c_arr_10_5 = c10_5_o;
  assign c_arr_10_6 = c10_6_o;
  assign c_arr_10_7 = c10_7_o;
  assign c_arr_10_8 = c10_8_o;
  assign c_arr_10_9 = c10_9_o;
  assign c_arr_10_10 = c10_10_o;
  assign c_arr_10_11 = c10_11_o;
  assign c_arr_10_12 = c10_12_o;
  assign c_arr_10_13 = c10_13_o;
  assign c_arr_10_14 = c10_14_o;
  assign c_arr_10_15 = c10_15_o;
  assign c_arr_10_16 = c10_16_o;
  assign c_arr_10_17 = c10_17_o;
  assign c_arr_10_18 = c10_18_o;
  assign c_arr_10_19 = c10_19_o;
  assign c_arr_10_20 = c10_20_o;
  assign c_arr_10_21 = c10_21_o;
  assign c_arr_10_22 = c10_22_o;
  assign c_arr_10_23 = c10_23_o;
  assign c_arr_10_24 = c10_24_o;
  assign c_arr_10_25 = c10_25_o;
  assign c_arr_10_26 = c10_26_o;
  assign c_arr_10_27 = c10_27_o;
  assign c_arr_10_28 = c10_28_o;
  assign c_arr_10_29 = c10_29_o;
  assign c_arr_10_30 = c10_30_o;
  assign c_arr_10_31 = c10_31_o;
  assign c_arr_11_0 = c11_0_o;
  assign c_arr_11_1 = c11_1_o;
  assign c_arr_11_2 = c11_2_o;
  assign c_arr_11_3 = c11_3_o;
  assign c_arr_11_4 = c11_4_o;
  assign c_arr_11_5 = c11_5_o;
  assign c_arr_11_6 = c11_6_o;
  assign c_arr_11_7 = c11_7_o;
  assign c_arr_11_8 = c11_8_o;
  assign c_arr_11_9 = c11_9_o;
  assign c_arr_11_10 = c11_10_o;
  assign c_arr_11_11 = c11_11_o;
  assign c_arr_11_12 = c11_12_o;
  assign c_arr_11_13 = c11_13_o;
  assign c_arr_11_14 = c11_14_o;
  assign c_arr_11_15 = c11_15_o;
  assign c_arr_11_16 = c11_16_o;
  assign c_arr_11_17 = c11_17_o;
  assign c_arr_11_18 = c11_18_o;
  assign c_arr_11_19 = c11_19_o;
  assign c_arr_11_20 = c11_20_o;
  assign c_arr_11_21 = c11_21_o;
  assign c_arr_11_22 = c11_22_o;
  assign c_arr_11_23 = c11_23_o;
  assign c_arr_11_24 = c11_24_o;
  assign c_arr_11_25 = c11_25_o;
  assign c_arr_11_26 = c11_26_o;
  assign c_arr_11_27 = c11_27_o;
  assign c_arr_11_28 = c11_28_o;
  assign c_arr_11_29 = c11_29_o;
  assign c_arr_11_30 = c11_30_o;
  assign c_arr_11_31 = c11_31_o;
  assign c_arr_12_0 = c12_0_o;
  assign c_arr_12_1 = c12_1_o;
  assign c_arr_12_2 = c12_2_o;
  assign c_arr_12_3 = c12_3_o;
  assign c_arr_12_4 = c12_4_o;
  assign c_arr_12_5 = c12_5_o;
  assign c_arr_12_6 = c12_6_o;
  assign c_arr_12_7 = c12_7_o;
  assign c_arr_12_8 = c12_8_o;
  assign c_arr_12_9 = c12_9_o;
  assign c_arr_12_10 = c12_10_o;
  assign c_arr_12_11 = c12_11_o;
  assign c_arr_12_12 = c12_12_o;
  assign c_arr_12_13 = c12_13_o;
  assign c_arr_12_14 = c12_14_o;
  assign c_arr_12_15 = c12_15_o;
  assign c_arr_12_16 = c12_16_o;
  assign c_arr_12_17 = c12_17_o;
  assign c_arr_12_18 = c12_18_o;
  assign c_arr_12_19 = c12_19_o;
  assign c_arr_12_20 = c12_20_o;
  assign c_arr_12_21 = c12_21_o;
  assign c_arr_12_22 = c12_22_o;
  assign c_arr_12_23 = c12_23_o;
  assign c_arr_12_24 = c12_24_o;
  assign c_arr_12_25 = c12_25_o;
  assign c_arr_12_26 = c12_26_o;
  assign c_arr_12_27 = c12_27_o;
  assign c_arr_12_28 = c12_28_o;
  assign c_arr_12_29 = c12_29_o;
  assign c_arr_12_30 = c12_30_o;
  assign c_arr_12_31 = c12_31_o;
  assign c_arr_13_0 = c13_0_o;
  assign c_arr_13_1 = c13_1_o;
  assign c_arr_13_2 = c13_2_o;
  assign c_arr_13_3 = c13_3_o;
  assign c_arr_13_4 = c13_4_o;
  assign c_arr_13_5 = c13_5_o;
  assign c_arr_13_6 = c13_6_o;
  assign c_arr_13_7 = c13_7_o;
  assign c_arr_13_8 = c13_8_o;
  assign c_arr_13_9 = c13_9_o;
  assign c_arr_13_10 = c13_10_o;
  assign c_arr_13_11 = c13_11_o;
  assign c_arr_13_12 = c13_12_o;
  assign c_arr_13_13 = c13_13_o;
  assign c_arr_13_14 = c13_14_o;
  assign c_arr_13_15 = c13_15_o;
  assign c_arr_13_16 = c13_16_o;
  assign c_arr_13_17 = c13_17_o;
  assign c_arr_13_18 = c13_18_o;
  assign c_arr_13_19 = c13_19_o;
  assign c_arr_13_20 = c13_20_o;
  assign c_arr_13_21 = c13_21_o;
  assign c_arr_13_22 = c13_22_o;
  assign c_arr_13_23 = c13_23_o;
  assign c_arr_13_24 = c13_24_o;
  assign c_arr_13_25 = c13_25_o;
  assign c_arr_13_26 = c13_26_o;
  assign c_arr_13_27 = c13_27_o;
  assign c_arr_13_28 = c13_28_o;
  assign c_arr_13_29 = c13_29_o;
  assign c_arr_13_30 = c13_30_o;
  assign c_arr_13_31 = c13_31_o;
  assign c_arr_14_0 = c14_0_o;
  assign c_arr_14_1 = c14_1_o;
  assign c_arr_14_2 = c14_2_o;
  assign c_arr_14_3 = c14_3_o;
  assign c_arr_14_4 = c14_4_o;
  assign c_arr_14_5 = c14_5_o;
  assign c_arr_14_6 = c14_6_o;
  assign c_arr_14_7 = c14_7_o;
  assign c_arr_14_8 = c14_8_o;
  assign c_arr_14_9 = c14_9_o;
  assign c_arr_14_10 = c14_10_o;
  assign c_arr_14_11 = c14_11_o;
  assign c_arr_14_12 = c14_12_o;
  assign c_arr_14_13 = c14_13_o;
  assign c_arr_14_14 = c14_14_o;
  assign c_arr_14_15 = c14_15_o;
  assign c_arr_14_16 = c14_16_o;
  assign c_arr_14_17 = c14_17_o;
  assign c_arr_14_18 = c14_18_o;
  assign c_arr_14_19 = c14_19_o;
  assign c_arr_14_20 = c14_20_o;
  assign c_arr_14_21 = c14_21_o;
  assign c_arr_14_22 = c14_22_o;
  assign c_arr_14_23 = c14_23_o;
  assign c_arr_14_24 = c14_24_o;
  assign c_arr_14_25 = c14_25_o;
  assign c_arr_14_26 = c14_26_o;
  assign c_arr_14_27 = c14_27_o;
  assign c_arr_14_28 = c14_28_o;
  assign c_arr_14_29 = c14_29_o;
  assign c_arr_14_30 = c14_30_o;
  assign c_arr_14_31 = c14_31_o;
  assign c_arr_15_0 = c15_0_o;
  assign c_arr_15_1 = c15_1_o;
  assign c_arr_15_2 = c15_2_o;
  assign c_arr_15_3 = c15_3_o;
  assign c_arr_15_4 = c15_4_o;
  assign c_arr_15_5 = c15_5_o;
  assign c_arr_15_6 = c15_6_o;
  assign c_arr_15_7 = c15_7_o;
  assign c_arr_15_8 = c15_8_o;
  assign c_arr_15_9 = c15_9_o;
  assign c_arr_15_10 = c15_10_o;
  assign c_arr_15_11 = c15_11_o;
  assign c_arr_15_12 = c15_12_o;
  assign c_arr_15_13 = c15_13_o;
  assign c_arr_15_14 = c15_14_o;
  assign c_arr_15_15 = c15_15_o;
  assign c_arr_15_16 = c15_16_o;
  assign c_arr_15_17 = c15_17_o;
  assign c_arr_15_18 = c15_18_o;
  assign c_arr_15_19 = c15_19_o;
  assign c_arr_15_20 = c15_20_o;
  assign c_arr_15_21 = c15_21_o;
  assign c_arr_15_22 = c15_22_o;
  assign c_arr_15_23 = c15_23_o;
  assign c_arr_15_24 = c15_24_o;
  assign c_arr_15_25 = c15_25_o;
  assign c_arr_15_26 = c15_26_o;
  assign c_arr_15_27 = c15_27_o;
  assign c_arr_15_28 = c15_28_o;
  assign c_arr_15_29 = c15_29_o;
  assign c_arr_15_30 = c15_30_o;
  assign c_arr_15_31 = c15_31_o;
  assign c_arr_16_0 = c16_0_o;
  assign c_arr_16_1 = c16_1_o;
  assign c_arr_16_2 = c16_2_o;
  assign c_arr_16_3 = c16_3_o;
  assign c_arr_16_4 = c16_4_o;
  assign c_arr_16_5 = c16_5_o;
  assign c_arr_16_6 = c16_6_o;
  assign c_arr_16_7 = c16_7_o;
  assign c_arr_16_8 = c16_8_o;
  assign c_arr_16_9 = c16_9_o;
  assign c_arr_16_10 = c16_10_o;
  assign c_arr_16_11 = c16_11_o;
  assign c_arr_16_12 = c16_12_o;
  assign c_arr_16_13 = c16_13_o;
  assign c_arr_16_14 = c16_14_o;
  assign c_arr_16_15 = c16_15_o;
  assign c_arr_16_16 = c16_16_o;
  assign c_arr_16_17 = c16_17_o;
  assign c_arr_16_18 = c16_18_o;
  assign c_arr_16_19 = c16_19_o;
  assign c_arr_16_20 = c16_20_o;
  assign c_arr_16_21 = c16_21_o;
  assign c_arr_16_22 = c16_22_o;
  assign c_arr_16_23 = c16_23_o;
  assign c_arr_16_24 = c16_24_o;
  assign c_arr_16_25 = c16_25_o;
  assign c_arr_16_26 = c16_26_o;
  assign c_arr_16_27 = c16_27_o;
  assign c_arr_16_28 = c16_28_o;
  assign c_arr_16_29 = c16_29_o;
  assign c_arr_16_30 = c16_30_o;
  assign c_arr_16_31 = c16_31_o;
  assign c_arr_17_0 = c17_0_o;
  assign c_arr_17_1 = c17_1_o;
  assign c_arr_17_2 = c17_2_o;
  assign c_arr_17_3 = c17_3_o;
  assign c_arr_17_4 = c17_4_o;
  assign c_arr_17_5 = c17_5_o;
  assign c_arr_17_6 = c17_6_o;
  assign c_arr_17_7 = c17_7_o;
  assign c_arr_17_8 = c17_8_o;
  assign c_arr_17_9 = c17_9_o;
  assign c_arr_17_10 = c17_10_o;
  assign c_arr_17_11 = c17_11_o;
  assign c_arr_17_12 = c17_12_o;
  assign c_arr_17_13 = c17_13_o;
  assign c_arr_17_14 = c17_14_o;
  assign c_arr_17_15 = c17_15_o;
  assign c_arr_17_16 = c17_16_o;
  assign c_arr_17_17 = c17_17_o;
  assign c_arr_17_18 = c17_18_o;
  assign c_arr_17_19 = c17_19_o;
  assign c_arr_17_20 = c17_20_o;
  assign c_arr_17_21 = c17_21_o;
  assign c_arr_17_22 = c17_22_o;
  assign c_arr_17_23 = c17_23_o;
  assign c_arr_17_24 = c17_24_o;
  assign c_arr_17_25 = c17_25_o;
  assign c_arr_17_26 = c17_26_o;
  assign c_arr_17_27 = c17_27_o;
  assign c_arr_17_28 = c17_28_o;
  assign c_arr_17_29 = c17_29_o;
  assign c_arr_17_30 = c17_30_o;
  assign c_arr_17_31 = c17_31_o;
  assign c_arr_18_0 = c18_0_o;
  assign c_arr_18_1 = c18_1_o;
  assign c_arr_18_2 = c18_2_o;
  assign c_arr_18_3 = c18_3_o;
  assign c_arr_18_4 = c18_4_o;
  assign c_arr_18_5 = c18_5_o;
  assign c_arr_18_6 = c18_6_o;
  assign c_arr_18_7 = c18_7_o;
  assign c_arr_18_8 = c18_8_o;
  assign c_arr_18_9 = c18_9_o;
  assign c_arr_18_10 = c18_10_o;
  assign c_arr_18_11 = c18_11_o;
  assign c_arr_18_12 = c18_12_o;
  assign c_arr_18_13 = c18_13_o;
  assign c_arr_18_14 = c18_14_o;
  assign c_arr_18_15 = c18_15_o;
  assign c_arr_18_16 = c18_16_o;
  assign c_arr_18_17 = c18_17_o;
  assign c_arr_18_18 = c18_18_o;
  assign c_arr_18_19 = c18_19_o;
  assign c_arr_18_20 = c18_20_o;
  assign c_arr_18_21 = c18_21_o;
  assign c_arr_18_22 = c18_22_o;
  assign c_arr_18_23 = c18_23_o;
  assign c_arr_18_24 = c18_24_o;
  assign c_arr_18_25 = c18_25_o;
  assign c_arr_18_26 = c18_26_o;
  assign c_arr_18_27 = c18_27_o;
  assign c_arr_18_28 = c18_28_o;
  assign c_arr_18_29 = c18_29_o;
  assign c_arr_18_30 = c18_30_o;
  assign c_arr_18_31 = c18_31_o;
  assign c_arr_19_0 = c19_0_o;
  assign c_arr_19_1 = c19_1_o;
  assign c_arr_19_2 = c19_2_o;
  assign c_arr_19_3 = c19_3_o;
  assign c_arr_19_4 = c19_4_o;
  assign c_arr_19_5 = c19_5_o;
  assign c_arr_19_6 = c19_6_o;
  assign c_arr_19_7 = c19_7_o;
  assign c_arr_19_8 = c19_8_o;
  assign c_arr_19_9 = c19_9_o;
  assign c_arr_19_10 = c19_10_o;
  assign c_arr_19_11 = c19_11_o;
  assign c_arr_19_12 = c19_12_o;
  assign c_arr_19_13 = c19_13_o;
  assign c_arr_19_14 = c19_14_o;
  assign c_arr_19_15 = c19_15_o;
  assign c_arr_19_16 = c19_16_o;
  assign c_arr_19_17 = c19_17_o;
  assign c_arr_19_18 = c19_18_o;
  assign c_arr_19_19 = c19_19_o;
  assign c_arr_19_20 = c19_20_o;
  assign c_arr_19_21 = c19_21_o;
  assign c_arr_19_22 = c19_22_o;
  assign c_arr_19_23 = c19_23_o;
  assign c_arr_19_24 = c19_24_o;
  assign c_arr_19_25 = c19_25_o;
  assign c_arr_19_26 = c19_26_o;
  assign c_arr_19_27 = c19_27_o;
  assign c_arr_19_28 = c19_28_o;
  assign c_arr_19_29 = c19_29_o;
  assign c_arr_19_30 = c19_30_o;
  assign c_arr_19_31 = c19_31_o;
  assign c_arr_20_0 = c20_0_o;
  assign c_arr_20_1 = c20_1_o;
  assign c_arr_20_2 = c20_2_o;
  assign c_arr_20_3 = c20_3_o;
  assign c_arr_20_4 = c20_4_o;
  assign c_arr_20_5 = c20_5_o;
  assign c_arr_20_6 = c20_6_o;
  assign c_arr_20_7 = c20_7_o;
  assign c_arr_20_8 = c20_8_o;
  assign c_arr_20_9 = c20_9_o;
  assign c_arr_20_10 = c20_10_o;
  assign c_arr_20_11 = c20_11_o;
  assign c_arr_20_12 = c20_12_o;
  assign c_arr_20_13 = c20_13_o;
  assign c_arr_20_14 = c20_14_o;
  assign c_arr_20_15 = c20_15_o;
  assign c_arr_20_16 = c20_16_o;
  assign c_arr_20_17 = c20_17_o;
  assign c_arr_20_18 = c20_18_o;
  assign c_arr_20_19 = c20_19_o;
  assign c_arr_20_20 = c20_20_o;
  assign c_arr_20_21 = c20_21_o;
  assign c_arr_20_22 = c20_22_o;
  assign c_arr_20_23 = c20_23_o;
  assign c_arr_20_24 = c20_24_o;
  assign c_arr_20_25 = c20_25_o;
  assign c_arr_20_26 = c20_26_o;
  assign c_arr_20_27 = c20_27_o;
  assign c_arr_20_28 = c20_28_o;
  assign c_arr_20_29 = c20_29_o;
  assign c_arr_20_30 = c20_30_o;
  assign c_arr_20_31 = c20_31_o;
  assign c_arr_21_0 = c21_0_o;
  assign c_arr_21_1 = c21_1_o;
  assign c_arr_21_2 = c21_2_o;
  assign c_arr_21_3 = c21_3_o;
  assign c_arr_21_4 = c21_4_o;
  assign c_arr_21_5 = c21_5_o;
  assign c_arr_21_6 = c21_6_o;
  assign c_arr_21_7 = c21_7_o;
  assign c_arr_21_8 = c21_8_o;
  assign c_arr_21_9 = c21_9_o;
  assign c_arr_21_10 = c21_10_o;
  assign c_arr_21_11 = c21_11_o;
  assign c_arr_21_12 = c21_12_o;
  assign c_arr_21_13 = c21_13_o;
  assign c_arr_21_14 = c21_14_o;
  assign c_arr_21_15 = c21_15_o;
  assign c_arr_21_16 = c21_16_o;
  assign c_arr_21_17 = c21_17_o;
  assign c_arr_21_18 = c21_18_o;
  assign c_arr_21_19 = c21_19_o;
  assign c_arr_21_20 = c21_20_o;
  assign c_arr_21_21 = c21_21_o;
  assign c_arr_21_22 = c21_22_o;
  assign c_arr_21_23 = c21_23_o;
  assign c_arr_21_24 = c21_24_o;
  assign c_arr_21_25 = c21_25_o;
  assign c_arr_21_26 = c21_26_o;
  assign c_arr_21_27 = c21_27_o;
  assign c_arr_21_28 = c21_28_o;
  assign c_arr_21_29 = c21_29_o;
  assign c_arr_21_30 = c21_30_o;
  assign c_arr_21_31 = c21_31_o;
  assign c_arr_22_0 = c22_0_o;
  assign c_arr_22_1 = c22_1_o;
  assign c_arr_22_2 = c22_2_o;
  assign c_arr_22_3 = c22_3_o;
  assign c_arr_22_4 = c22_4_o;
  assign c_arr_22_5 = c22_5_o;
  assign c_arr_22_6 = c22_6_o;
  assign c_arr_22_7 = c22_7_o;
  assign c_arr_22_8 = c22_8_o;
  assign c_arr_22_9 = c22_9_o;
  assign c_arr_22_10 = c22_10_o;
  assign c_arr_22_11 = c22_11_o;
  assign c_arr_22_12 = c22_12_o;
  assign c_arr_22_13 = c22_13_o;
  assign c_arr_22_14 = c22_14_o;
  assign c_arr_22_15 = c22_15_o;
  assign c_arr_22_16 = c22_16_o;
  assign c_arr_22_17 = c22_17_o;
  assign c_arr_22_18 = c22_18_o;
  assign c_arr_22_19 = c22_19_o;
  assign c_arr_22_20 = c22_20_o;
  assign c_arr_22_21 = c22_21_o;
  assign c_arr_22_22 = c22_22_o;
  assign c_arr_22_23 = c22_23_o;
  assign c_arr_22_24 = c22_24_o;
  assign c_arr_22_25 = c22_25_o;
  assign c_arr_22_26 = c22_26_o;
  assign c_arr_22_27 = c22_27_o;
  assign c_arr_22_28 = c22_28_o;
  assign c_arr_22_29 = c22_29_o;
  assign c_arr_22_30 = c22_30_o;
  assign c_arr_22_31 = c22_31_o;
  assign c_arr_23_0 = c23_0_o;
  assign c_arr_23_1 = c23_1_o;
  assign c_arr_23_2 = c23_2_o;
  assign c_arr_23_3 = c23_3_o;
  assign c_arr_23_4 = c23_4_o;
  assign c_arr_23_5 = c23_5_o;
  assign c_arr_23_6 = c23_6_o;
  assign c_arr_23_7 = c23_7_o;
  assign c_arr_23_8 = c23_8_o;
  assign c_arr_23_9 = c23_9_o;
  assign c_arr_23_10 = c23_10_o;
  assign c_arr_23_11 = c23_11_o;
  assign c_arr_23_12 = c23_12_o;
  assign c_arr_23_13 = c23_13_o;
  assign c_arr_23_14 = c23_14_o;
  assign c_arr_23_15 = c23_15_o;
  assign c_arr_23_16 = c23_16_o;
  assign c_arr_23_17 = c23_17_o;
  assign c_arr_23_18 = c23_18_o;
  assign c_arr_23_19 = c23_19_o;
  assign c_arr_23_20 = c23_20_o;
  assign c_arr_23_21 = c23_21_o;
  assign c_arr_23_22 = c23_22_o;
  assign c_arr_23_23 = c23_23_o;
  assign c_arr_23_24 = c23_24_o;
  assign c_arr_23_25 = c23_25_o;
  assign c_arr_23_26 = c23_26_o;
  assign c_arr_23_27 = c23_27_o;
  assign c_arr_23_28 = c23_28_o;
  assign c_arr_23_29 = c23_29_o;
  assign c_arr_23_30 = c23_30_o;
  assign c_arr_23_31 = c23_31_o;
  assign c_arr_24_0 = c24_0_o;
  assign c_arr_24_1 = c24_1_o;
  assign c_arr_24_2 = c24_2_o;
  assign c_arr_24_3 = c24_3_o;
  assign c_arr_24_4 = c24_4_o;
  assign c_arr_24_5 = c24_5_o;
  assign c_arr_24_6 = c24_6_o;
  assign c_arr_24_7 = c24_7_o;
  assign c_arr_24_8 = c24_8_o;
  assign c_arr_24_9 = c24_9_o;
  assign c_arr_24_10 = c24_10_o;
  assign c_arr_24_11 = c24_11_o;
  assign c_arr_24_12 = c24_12_o;
  assign c_arr_24_13 = c24_13_o;
  assign c_arr_24_14 = c24_14_o;
  assign c_arr_24_15 = c24_15_o;
  assign c_arr_24_16 = c24_16_o;
  assign c_arr_24_17 = c24_17_o;
  assign c_arr_24_18 = c24_18_o;
  assign c_arr_24_19 = c24_19_o;
  assign c_arr_24_20 = c24_20_o;
  assign c_arr_24_21 = c24_21_o;
  assign c_arr_24_22 = c24_22_o;
  assign c_arr_24_23 = c24_23_o;
  assign c_arr_24_24 = c24_24_o;
  assign c_arr_24_25 = c24_25_o;
  assign c_arr_24_26 = c24_26_o;
  assign c_arr_24_27 = c24_27_o;
  assign c_arr_24_28 = c24_28_o;
  assign c_arr_24_29 = c24_29_o;
  assign c_arr_24_30 = c24_30_o;
  assign c_arr_24_31 = c24_31_o;
  assign c_arr_25_0 = c25_0_o;
  assign c_arr_25_1 = c25_1_o;
  assign c_arr_25_2 = c25_2_o;
  assign c_arr_25_3 = c25_3_o;
  assign c_arr_25_4 = c25_4_o;
  assign c_arr_25_5 = c25_5_o;
  assign c_arr_25_6 = c25_6_o;
  assign c_arr_25_7 = c25_7_o;
  assign c_arr_25_8 = c25_8_o;
  assign c_arr_25_9 = c25_9_o;
  assign c_arr_25_10 = c25_10_o;
  assign c_arr_25_11 = c25_11_o;
  assign c_arr_25_12 = c25_12_o;
  assign c_arr_25_13 = c25_13_o;
  assign c_arr_25_14 = c25_14_o;
  assign c_arr_25_15 = c25_15_o;
  assign c_arr_25_16 = c25_16_o;
  assign c_arr_25_17 = c25_17_o;
  assign c_arr_25_18 = c25_18_o;
  assign c_arr_25_19 = c25_19_o;
  assign c_arr_25_20 = c25_20_o;
  assign c_arr_25_21 = c25_21_o;
  assign c_arr_25_22 = c25_22_o;
  assign c_arr_25_23 = c25_23_o;
  assign c_arr_25_24 = c25_24_o;
  assign c_arr_25_25 = c25_25_o;
  assign c_arr_25_26 = c25_26_o;
  assign c_arr_25_27 = c25_27_o;
  assign c_arr_25_28 = c25_28_o;
  assign c_arr_25_29 = c25_29_o;
  assign c_arr_25_30 = c25_30_o;
  assign c_arr_25_31 = c25_31_o;
  assign c_arr_26_0 = c26_0_o;
  assign c_arr_26_1 = c26_1_o;
  assign c_arr_26_2 = c26_2_o;
  assign c_arr_26_3 = c26_3_o;
  assign c_arr_26_4 = c26_4_o;
  assign c_arr_26_5 = c26_5_o;
  assign c_arr_26_6 = c26_6_o;
  assign c_arr_26_7 = c26_7_o;
  assign c_arr_26_8 = c26_8_o;
  assign c_arr_26_9 = c26_9_o;
  assign c_arr_26_10 = c26_10_o;
  assign c_arr_26_11 = c26_11_o;
  assign c_arr_26_12 = c26_12_o;
  assign c_arr_26_13 = c26_13_o;
  assign c_arr_26_14 = c26_14_o;
  assign c_arr_26_15 = c26_15_o;
  assign c_arr_26_16 = c26_16_o;
  assign c_arr_26_17 = c26_17_o;
  assign c_arr_26_18 = c26_18_o;
  assign c_arr_26_19 = c26_19_o;
  assign c_arr_26_20 = c26_20_o;
  assign c_arr_26_21 = c26_21_o;
  assign c_arr_26_22 = c26_22_o;
  assign c_arr_26_23 = c26_23_o;
  assign c_arr_26_24 = c26_24_o;
  assign c_arr_26_25 = c26_25_o;
  assign c_arr_26_26 = c26_26_o;
  assign c_arr_26_27 = c26_27_o;
  assign c_arr_26_28 = c26_28_o;
  assign c_arr_26_29 = c26_29_o;
  assign c_arr_26_30 = c26_30_o;
  assign c_arr_26_31 = c26_31_o;
  assign c_arr_27_0 = c27_0_o;
  assign c_arr_27_1 = c27_1_o;
  assign c_arr_27_2 = c27_2_o;
  assign c_arr_27_3 = c27_3_o;
  assign c_arr_27_4 = c27_4_o;
  assign c_arr_27_5 = c27_5_o;
  assign c_arr_27_6 = c27_6_o;
  assign c_arr_27_7 = c27_7_o;
  assign c_arr_27_8 = c27_8_o;
  assign c_arr_27_9 = c27_9_o;
  assign c_arr_27_10 = c27_10_o;
  assign c_arr_27_11 = c27_11_o;
  assign c_arr_27_12 = c27_12_o;
  assign c_arr_27_13 = c27_13_o;
  assign c_arr_27_14 = c27_14_o;
  assign c_arr_27_15 = c27_15_o;
  assign c_arr_27_16 = c27_16_o;
  assign c_arr_27_17 = c27_17_o;
  assign c_arr_27_18 = c27_18_o;
  assign c_arr_27_19 = c27_19_o;
  assign c_arr_27_20 = c27_20_o;
  assign c_arr_27_21 = c27_21_o;
  assign c_arr_27_22 = c27_22_o;
  assign c_arr_27_23 = c27_23_o;
  assign c_arr_27_24 = c27_24_o;
  assign c_arr_27_25 = c27_25_o;
  assign c_arr_27_26 = c27_26_o;
  assign c_arr_27_27 = c27_27_o;
  assign c_arr_27_28 = c27_28_o;
  assign c_arr_27_29 = c27_29_o;
  assign c_arr_27_30 = c27_30_o;
  assign c_arr_27_31 = c27_31_o;
  assign c_arr_28_0 = c28_0_o;
  assign c_arr_28_1 = c28_1_o;
  assign c_arr_28_2 = c28_2_o;
  assign c_arr_28_3 = c28_3_o;
  assign c_arr_28_4 = c28_4_o;
  assign c_arr_28_5 = c28_5_o;
  assign c_arr_28_6 = c28_6_o;
  assign c_arr_28_7 = c28_7_o;
  assign c_arr_28_8 = c28_8_o;
  assign c_arr_28_9 = c28_9_o;
  assign c_arr_28_10 = c28_10_o;
  assign c_arr_28_11 = c28_11_o;
  assign c_arr_28_12 = c28_12_o;
  assign c_arr_28_13 = c28_13_o;
  assign c_arr_28_14 = c28_14_o;
  assign c_arr_28_15 = c28_15_o;
  assign c_arr_28_16 = c28_16_o;
  assign c_arr_28_17 = c28_17_o;
  assign c_arr_28_18 = c28_18_o;
  assign c_arr_28_19 = c28_19_o;
  assign c_arr_28_20 = c28_20_o;
  assign c_arr_28_21 = c28_21_o;
  assign c_arr_28_22 = c28_22_o;
  assign c_arr_28_23 = c28_23_o;
  assign c_arr_28_24 = c28_24_o;
  assign c_arr_28_25 = c28_25_o;
  assign c_arr_28_26 = c28_26_o;
  assign c_arr_28_27 = c28_27_o;
  assign c_arr_28_28 = c28_28_o;
  assign c_arr_28_29 = c28_29_o;
  assign c_arr_28_30 = c28_30_o;
  assign c_arr_28_31 = c28_31_o;
  assign c_arr_29_0 = c29_0_o;
  assign c_arr_29_1 = c29_1_o;
  assign c_arr_29_2 = c29_2_o;
  assign c_arr_29_3 = c29_3_o;
  assign c_arr_29_4 = c29_4_o;
  assign c_arr_29_5 = c29_5_o;
  assign c_arr_29_6 = c29_6_o;
  assign c_arr_29_7 = c29_7_o;
  assign c_arr_29_8 = c29_8_o;
  assign c_arr_29_9 = c29_9_o;
  assign c_arr_29_10 = c29_10_o;
  assign c_arr_29_11 = c29_11_o;
  assign c_arr_29_12 = c29_12_o;
  assign c_arr_29_13 = c29_13_o;
  assign c_arr_29_14 = c29_14_o;
  assign c_arr_29_15 = c29_15_o;
  assign c_arr_29_16 = c29_16_o;
  assign c_arr_29_17 = c29_17_o;
  assign c_arr_29_18 = c29_18_o;
  assign c_arr_29_19 = c29_19_o;
  assign c_arr_29_20 = c29_20_o;
  assign c_arr_29_21 = c29_21_o;
  assign c_arr_29_22 = c29_22_o;
  assign c_arr_29_23 = c29_23_o;
  assign c_arr_29_24 = c29_24_o;
  assign c_arr_29_25 = c29_25_o;
  assign c_arr_29_26 = c29_26_o;
  assign c_arr_29_27 = c29_27_o;
  assign c_arr_29_28 = c29_28_o;
  assign c_arr_29_29 = c29_29_o;
  assign c_arr_29_30 = c29_30_o;
  assign c_arr_29_31 = c29_31_o;
  assign c_arr_30_0 = c30_0_o;
  assign c_arr_30_1 = c30_1_o;
  assign c_arr_30_2 = c30_2_o;
  assign c_arr_30_3 = c30_3_o;
  assign c_arr_30_4 = c30_4_o;
  assign c_arr_30_5 = c30_5_o;
  assign c_arr_30_6 = c30_6_o;
  assign c_arr_30_7 = c30_7_o;
  assign c_arr_30_8 = c30_8_o;
  assign c_arr_30_9 = c30_9_o;
  assign c_arr_30_10 = c30_10_o;
  assign c_arr_30_11 = c30_11_o;
  assign c_arr_30_12 = c30_12_o;
  assign c_arr_30_13 = c30_13_o;
  assign c_arr_30_14 = c30_14_o;
  assign c_arr_30_15 = c30_15_o;
  assign c_arr_30_16 = c30_16_o;
  assign c_arr_30_17 = c30_17_o;
  assign c_arr_30_18 = c30_18_o;
  assign c_arr_30_19 = c30_19_o;
  assign c_arr_30_20 = c30_20_o;
  assign c_arr_30_21 = c30_21_o;
  assign c_arr_30_22 = c30_22_o;
  assign c_arr_30_23 = c30_23_o;
  assign c_arr_30_24 = c30_24_o;
  assign c_arr_30_25 = c30_25_o;
  assign c_arr_30_26 = c30_26_o;
  assign c_arr_30_27 = c30_27_o;
  assign c_arr_30_28 = c30_28_o;
  assign c_arr_30_29 = c30_29_o;
  assign c_arr_30_30 = c30_30_o;
  assign c_arr_30_31 = c30_31_o;
  assign c_arr_31_0 = c31_0_o;
  assign c_arr_31_1 = c31_1_o;
  assign c_arr_31_2 = c31_2_o;
  assign c_arr_31_3 = c31_3_o;
  assign c_arr_31_4 = c31_4_o;
  assign c_arr_31_5 = c31_5_o;
  assign c_arr_31_6 = c31_6_o;
  assign c_arr_31_7 = c31_7_o;
  assign c_arr_31_8 = c31_8_o;
  assign c_arr_31_9 = c31_9_o;
  assign c_arr_31_10 = c31_10_o;
  assign c_arr_31_11 = c31_11_o;
  assign c_arr_31_12 = c31_12_o;
  assign c_arr_31_13 = c31_13_o;
  assign c_arr_31_14 = c31_14_o;
  assign c_arr_31_15 = c31_15_o;
  assign c_arr_31_16 = c31_16_o;
  assign c_arr_31_17 = c31_17_o;
  assign c_arr_31_18 = c31_18_o;
  assign c_arr_31_19 = c31_19_o;
  assign c_arr_31_20 = c31_20_o;
  assign c_arr_31_21 = c31_21_o;
  assign c_arr_31_22 = c31_22_o;
  assign c_arr_31_23 = c31_23_o;
  assign c_arr_31_24 = c31_24_o;
  assign c_arr_31_25 = c31_25_o;
  assign c_arr_31_26 = c31_26_o;
  assign c_arr_31_27 = c31_27_o;
  assign c_arr_31_28 = c31_28_o;
  assign c_arr_31_29 = c31_29_o;
  assign c_arr_31_30 = c31_30_o;
  assign c_arr_31_31 = c31_31_o;

  // ---- Bus gop c_data_i cho AXI4_C_WRITER (SUA LAN 16, 2026-08-18) - tach tu
  // c_arr_<row>_<col> da co san o tren (cung nguon c<row>_<col>_o tu SYSTOLIC_CORE_TOP).
  // Cong thuc khop dung axi4_c_writer.v: phan tu [row][col] chiem bit
  // [(row*32+col)*32+31 : (row*32+col)*32].

  // [SUA - 2026-08-17, SUA LAN 12] a_bank<n>/b_bank<n> khong con la port cua mmult_accel nua
  // (ca 2 da chuyen sang AXI4_A_READER/AXI4_B_READER) - ghi chu cu ve Clk_A/Rst_A khong con
  // ap dung, da bo.

  SYSTOLIC_CORE_TOP dut_core (.*);

  // ap_clk/ap_rst_n khong trung ten voi clk_i/rst_ni cua testbench (khac tien to) nen
  // can override tuong minh; phan con lai (c_arr/tile_*/a_base_addr_o/a_reload_req_o/
  // a_loaded_i/b_base_addr_o/b_row_stride_o/b_num_rows_o/b_block_width_o/b_reload_req_o/
  // b_loaded_i) dung `.*`.

  mmult_accel dut_mmult (
    .ap_clk   (ap_clk),
    .ap_rst_n (ap_rst_n),
    .*
  );

  // ---- Clock: TAO TREN clk_i (ap_clk chi suy ra qua assign o header, khong duoc
  // toggle truc tiep - toggle ca 2 se gay loi "multiple drivers" tren ap_clk). ----
  initial clk_i = 1'b0;
  always #5ns clk_i = ~clk_i;

  // [LICH SU] Cac probe cu (PROBE2 + thanh ghi sticky, tung bam truc tiep vao sub-module noi bo
  // cua Vitis HLS de dieu tra bug off-by-one trong copy_A_banks qua SUA LAN 1-9) da bi xoa het -
  // kien truc do khong con ton tai (Huong B da bo hoan toan viec doc A qua Vitis HLS, chuyen
  // sang AXI4_A_READER tu viet, xem docs/task.md muc C4/SUA LAN 10 va bench/tb_axi4_a_reader.sv).

  // [LICH SU] PROBE3 (2026-08-17) tung bam Outline_copy_B_block/Outline_tile_i de dieu
  // tra bug HLS lap lich chong lap A/tile - da xoa vi kien truc do khong con ton tai (SUA LAN
  // 12 da bo han copy_B_block khoi HLS, chuyen sang AXI4_B_READER tu viet, xem docs/task.md).

  // ---- Du lieu test + expected (tinh bang vong lap SV, khong qua RTL) ----
  logic signed [7:0]  A_orig [0:TEST_N-1][0:TEST_K-1];
  logic signed [7:0]  B_orig [0:TEST_K-1][0:TEST_M-1];
  logic signed [31:0] C_expected [0:TEST_N-1][0:TEST_M-1];

  int pass_count = 0;
  int fail_count = 0;

  // ---- [DEM SU KIEN, 2026-08-17] C doc lai toan bo = 0 sau khi AP_DONE=1 (het treo that, xem
  // docs/task.md) - can biet tile_valid_o/tile_done_o co thuc su pulse hay khong (polling 500
  // cycle/lan da biet khong dang tin cho tin hieu dang xung ngan, xem bai hoc bug tile_valid_o
  // cu) va gmemC co thuc su nhan du byte hay khong - dung edge-detect + dem, khong doan mo.
  int tile_valid_pulse_count;
  int tile_done_pulse_count;
  longint unsigned gmemC_bytes_written;
  int gmemC_aw_burst_count;
  logic prev_tile_valid_o, prev_tile_done_o;

  initial begin
    tile_valid_pulse_count = 0;
    tile_done_pulse_count  = 0;
    gmemC_bytes_written    = 0;
    gmemC_aw_burst_count   = 0;
    prev_tile_valid_o = 1'bx;
    prev_tile_done_o  = 1'bx;
  end

  always @(posedge clk_i) begin
    if (tile_valid_o === 1'b1 && prev_tile_valid_o !== 1'b1) tile_valid_pulse_count <= tile_valid_pulse_count + 1;
    prev_tile_valid_o <= tile_valid_o;
    if (tile_done_o === 1'b1 && prev_tile_done_o !== 1'b1) tile_done_pulse_count <= tile_done_pulse_count + 1;
    prev_tile_done_o <= tile_done_o;
  end

  // ---- [2026-08-18] Dem su kien khop du lieu (4/4 pulse, 16384/16384 byte) nhung C van doc
  // ra toan 0 - can khoanh vung tiep: (a) du lieu THAT trong bank A/B co dung khong (doc truc
  // tiep dpb_a<n>.mem[]/dpb_b<n>.mem[] qua duong dan phan cap - chi doc, khong sua RTL), (b)
  // c_arr co dung gia tri THAT tai dung luc tile_done_o pulse hay khong (chup lai gia tri ngay
  // tai canh xung, tranh sai lech do doc muon).
  logic bank_check_done;
  initial bank_check_done = 1'b0;
  always @(posedge clk_i) begin
    if (!bank_check_done && a_loaded_i && b_loaded_i) begin
      bank_check_done <= 1'b1;
      $display("[BANK-CHECK] t=%0t -- kiem tra du lieu that trong vai bank dai dien", $time);
      $display("[BANK-CHECK] dpb_a0.mem[0]=%0d (ky vong A_orig[0][0]=%0d)",
                $signed(dpb_a0.mem[0]), A_orig[0][0]);
      $display("[BANK-CHECK] dpb_a0.mem[767]=%0d (ky vong A_orig[0][767]=%0d)",
                $signed(dpb_a0.mem[767]), A_orig[0][767]);
      $display("[BANK-CHECK] dpb_a63.mem[0]=%0d (ky vong A_orig[63][0]=%0d)",
                $signed(dpb_a63.mem[0]), A_orig[63][0]);
      $display("[BANK-CHECK] dpb_b0.mem[0]=%0d (ky vong B_orig[0][0]=%0d)",
                $signed(dpb_b0.mem[0]), B_orig[0][0]);
      $display("[BANK-CHECK] dpb_b0.mem[1]=%0d (ky vong B_orig[0][32]=%0d)",
                $signed(dpb_b0.mem[1]), B_orig[0][32]);
      $display("[BANK-CHECK] dpb_b31.mem[0]=%0d (ky vong B_orig[0][31]=%0d)",
                $signed(dpb_b31.mem[0]), B_orig[0][31]);
      $display("[BANK-CHECK] dpb_b31.mem[1]=%0d (ky vong B_orig[0][63]=%0d)",
                $signed(dpb_b31.mem[1]), B_orig[0][63]);
    end
  end

  int tile_capture_idx;
  initial tile_capture_idx = 0;
  always @(posedge clk_i) begin
    if (tile_done_o === 1'b1 && prev_tile_done_o !== 1'b1) begin
      automatic int cap_i0 = tile_i_sel_o ? 32 : 0;
      automatic int cap_j0 = tile_j_sel_o * 32;
      $display("[TILE-CAPTURE] pulse#%0d t=%0t i0=%0d j0=%0d c_arr_0_0=%0d (ky vong C_expected[i0][j0]=%0d)",
                tile_capture_idx, $time, cap_i0, cap_j0, $signed(c_arr_0_0), C_expected[cap_i0][cap_j0]);
      tile_capture_idx <= tile_capture_idx + 1;
    end
  end

  initial begin
    int n, k, m;
    int elapsed_cycles;
    logic [31:0] ap_ctrl_val;
    logic timed_out;

    // ---- Khoi tao tin hieu dieu khien AXI4-Lite ve 0 truoc reset ----
    s_axi_control_AWVALID = 1'b0;
    s_axi_control_AWADDR  = '0;
    s_axi_control_WVALID  = 1'b0;
    s_axi_control_WDATA   = '0;
    s_axi_control_WSTRB   = '0;
    s_axi_control_ARVALID = 1'b0;
    s_axi_control_ARADDR  = '0;
    s_axi_control_RREADY  = 1'b0;
    s_axi_control_BREADY  = 1'b0;

    // ---- Reset dong bo (giong Stage 1) ----
    // LUU Y: KHONG gan tile_i_sel_i/tile_j_sel_i/tile_valid_i/tile_ready_i/tile_done_i thu
    // cong o day - cac tin hieu nay da duoc noi bang "assign" (cau noi voi mmult_accel) o
    // tren, gan thu cong them se gay loi "multiple drivers" khi bien dich.
    rst_ni = 1'b0;
    repeat (5) @(posedge ap_clk);
    rst_ni = 1'b1;
    $display("[TB] t=%0t rst_ni da tha (len 1)", $time);

    // ---- Sinh du lieu ngau nhien seed co dinh, nap vao mem_a_reader (da transpose)/mem_b_reader ----
    $srandom(32'hDEADBEEF);
    for (n = 0; n < TEST_N; n++)
      for (k = 0; k < TEST_K; k++)
        A_orig[n][k] = $urandom_range(0, 255) - 128;
    for (k = 0; k < TEST_K; k++)
      for (m = 0; m < TEST_M; m++)
        B_orig[k][m] = $urandom_range(0, 255) - 128;

    // [SUA - 2026-08-17, Huong B] A gio duoc AXI4_A_READER doc truc tiep (khong qua m_axi cua
    // mmult_accel nua) - mem_a_reader la "DDR gia lap" rieng phuc vu no, dia chi doc =
    // a_base_addr_i + k*64 (dung cong thuc that trong axi4_a_reader.v), khop dung layout
    // A_col[k][n] da transpose nhu truoc (khong doi yeu cau doi voi driver PYNQ that).
    $display("[TB] dang nap A (da transpose) vao mem_a_reader (phuc vu AXI4_A_READER)...");
    for (k = 0; k < TEST_K; k++)
      for (n = 0; n < TEST_N; n++)
        mem_a_reader[k * MAX_N + n] = A_orig[n][k];
    // n>=TEST_N (neu co) giu nguyen X - khong dung toi vi MAX_N=TEST_N=64 trong case nay.

    // [SUA - 2026-08-17, SUA LAN 12] B gio duoc AXI4_B_READER doc truc tiep (khong qua m_axi
    // cua mmult_accel nua) - mem_b_reader la "DDR gia lap" rieng phuc vu no, dia chi doc =
    // b_base_addr_i + k*b_row_stride_i + col (dung cong thuc that trong axi4_b_reader.v), voi
    // b_base_addr_i=B_addr+j_block=0 (chi 1 j_block vi TEST_M=64<BLOCK_M=256) va
    // b_row_stride_i=M - khop dung layout row-major goc nhu truoc (B khong can transpose).
    $display("[TB] dang nap B (row-major goc) vao mem_b_reader (phuc vu AXI4_B_READER)...");
    for (k = 0; k < TEST_K; k++)
      for (m = 0; m < TEST_M; m++)
        mem_b_reader[k * TEST_M + m] = B_orig[k][m];

    $display("[TB] dang tinh C_expected bang vong lap SV...");
    for (n = 0; n < TEST_N; n++) begin
      for (m = 0; m < TEST_M; m++) begin
        automatic logic signed [31:0] acc = 32'sd0;
        for (k = 0; k < TEST_K; k++)
          acc = acc + $signed(A_orig[n][k]) * $signed(B_orig[k][m]);
        C_expected[n][m] = acc;
      end
    end
    $display("[TB] xong chuan bi du lieu, bat dau lap trinh thanh ghi AXI4-Lite...");

    // ---- Lap trinh thanh ghi qua AXI4-Lite (con tro = 0, moi bundle gmem doc lap dia chi) ----
    // A_addr/B_addr/C_addr gio deu la 1 thanh ghi 32-bit duy nhat (SUA LAN 11/12/16, khong
    // con LO/HI 64-bit nao ca).
    axil_write(REG_A_ADDR, 32'h0);
    axil_write(REG_B_ADDR, 32'h0);
    axil_write(REG_C_ADDR, 32'h0);
    axil_write(REG_N, TEST_N[31:0]);
    axil_write(REG_K, TEST_K[31:0]);
    axil_write(REG_M, TEST_M[31:0]);
    axil_write(REG_UPDATE_A, 32'h1);

    $display("[TB] t=%0t bat AP_START...", $time);
    axil_write(REG_AP_CTRL, 32'h1); // bit0 = ap_start

    // ---- Poll AP_CTRL cho toi ap_done (bit1) hoac het watchdog ----
    elapsed_cycles = 0;
    timed_out = 1'b0;
    forever begin
      repeat (POLL_INTERVAL) @(posedge ap_clk);
      elapsed_cycles += POLL_INTERVAL;
      axil_read(REG_AP_CTRL, ap_ctrl_val);
      // [DEBUG - chan doan treo] in trang thai cac kenh AXI/handshake moi lan poll, de xac
      // dinh dang ket o dau - xoa sau khi tim ra nguyen nhan.
      $display("[DEBUG] t=%0t cyc=%0d ap_ctrl=%b | A_reader AR=%b/%b addr=%0d R=%b a_reload=%b a_loaded=%b | B_reader AR=%b/%b addr=%0d R=%b b_reload=%b b_loaded=%b | C_writer AW=%b/%b W=%b B=%b done=%b | tile_valid_o=%b tile_ready_o=%b tile_done_o=%b tile_i_sel_o=%b tile_j_sel_o=%0d",
                $time, elapsed_cycles, ap_ctrl_val[3:0],
                m_axi_arvalid_o, m_axi_arready_i, m_axi_araddr_o, m_axi_rvalid_i,
                a_reload_req_o, a_loaded_i,
                b_m_axi_arvalid_o, b_m_axi_arready_i, b_m_axi_araddr_o, b_m_axi_rvalid_i,
                b_reload_req_o, b_loaded_i,
                m_axi_awvalid_o, m_axi_awready_i, m_axi_wvalid_o, m_axi_bvalid_i, c_write_done_o,
                tile_valid_o, tile_ready_o, tile_done_o, tile_i_sel_o, tile_j_sel_o);
      if (ap_ctrl_val[1]) begin
        $display("[TB] ap_done=1 sau ~%0d cycle (t=%0t)", elapsed_cycles, $time);
        break;
      end
      if (elapsed_cycles >= WATCHDOG_CYCLES) begin
        timed_out = 1'b1;
        break;
      end
    end

    if (timed_out) begin
      $display("[FAIL] TIMEOUT -- AP_DONE khong bao gio len 1 sau %0d cycle tu luc AP_START.",
                WATCHDOG_CYCLES);
      $display("[FAIL] Van treo ke ca sau khi Design chuyen sang Huong B ca A lan B (AXI4_A_READER +");
      $display("[FAIL] AXI4_B_READER tu viet, bo han Vitis HLS doc A/B) - xem docs/feedback_to_spec.md");
      $display("[FAIL] de bao lai Design.");
      fail_count++;
    end else begin
      // ---- Doc lai gmemC, so voi C_expected ----
      automatic int mismatch = 0;
      automatic longint unsigned byte_off;
      automatic logic signed [31:0] c_val;
      // [2026-08-18] In ngay mem_gmemC[0..3] tai thoi diem ap_done=1, TRUOC vong check --
      // de doi chieu voi [GMEMC-WDATA] (in luc ghi burst dau tien) xem co bi ghi de ve 0
      // giua chung hay khong.
      $display("[GMEMC-READBACK-T0] t=%0t mem_gmemC[0..3]=%0d,%0d,%0d,%0d assembled=%0d (ky vong C[0][0]=%0d)",
                $time, mem_gmemC[0], mem_gmemC[1], mem_gmemC[2], mem_gmemC[3],
                $signed({mem_gmemC[3], mem_gmemC[2], mem_gmemC[1], mem_gmemC[0]}),
                C_expected[0][0]);
      for (n = 0; n < TEST_N; n++) begin
        for (m = 0; m < TEST_M; m++) begin
          byte_off = (longint'(n) * TEST_M + m) * 4;
          c_val = $signed({mem_gmemC[byte_off+3], mem_gmemC[byte_off+2],
                            mem_gmemC[byte_off+1], mem_gmemC[byte_off+0]});
          if (c_val !== C_expected[n][m]) begin
            mismatch++;
            if (mismatch <= 10)
              $display("[FAIL] C[%0d][%0d]=%0d (ky vong %0d)", n, m, c_val, C_expected[n][m]);
          end
        end
      end
      if (mismatch == 0) begin
        $display("[PASS] Tich hop toan he thong: toan bo %0dx%0d phan tu C khop expected.",
                  TEST_N, TEST_M);
        pass_count++;
      end else begin
        $display("[FAIL] Tich hop toan he thong: %0d/%0d phan tu C sai.",
                  mismatch, TEST_N * TEST_M);
        fail_count++;
      end
    end

    $display("[DEM SU KIEN] tile_valid_o pulse = %0d lan (ky vong 4, ung 2 tile_i x 2 tile_j vi",
              tile_valid_pulse_count);
    $display("[DEM SU KIEN] N=M=64=2x32); tile_done_o pulse = %0d lan (ky vong khop tile_valid_o);",
              tile_done_pulse_count);
    $display("[DEM SU KIEN] gmemC_bytes_written = %0d byte (ky vong %0d = N*M*4)",
              gmemC_bytes_written, TEST_N * TEST_M * 4);

    $display("========================================");
    $display("tb_integration_top: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_integration_top: ALL TESTS PASSED");
    else $display("tb_integration_top: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
