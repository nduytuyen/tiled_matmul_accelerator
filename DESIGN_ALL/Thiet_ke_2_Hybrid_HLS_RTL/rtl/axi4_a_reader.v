// [Huong B - xem docs/task.md muc C4 "Huong B: tu viet RTL doc AXI4 cho A", quyet
// dinh sau 9 lan thu sua mmult_accel.cpp (SUA LAN 1-9) deu treo tai dung 1 vi tri
// trong bo sinh RTL doc m_axi cua Vitis HLS, khong phu thuoc cach viet C++ - xem
// docs/modules/mmult_accel.md, docs/bug_history.md #22]
//
// Module nay THAY THE hoan toan copy_A_banks trong mmult_accel.cpp (HLS) - tu lam
// AXI4 master CHI DOC (kenh AR+R, khong can AW/W/B vi khong ghi DDR) de doc A tu
// DDR, ghi thang vao 64 khoi DUAL_PORT_BRAM_8B (bank A) - khong qua Vitis HLS,
// loai bo hoan toan bo sinh RTL tu dong dang gap loi. mmult_accel (HLS) chi con
// xu ly B, C, bat tay tile - xem mmult_accel.h/.cpp da sua tuong ung.
//
// Thiet ke don gian, uu tien DUNG truoc, nhanh sau: 1 burst = 16 beat x 4 byte
// = dung 1 hang A (64 byte, dia chi DDR da duoc driver PYNQ transpose thanh
// A_col[k][n], 64 phan tu cung k lien tuc - xem docs/task.md muc C4 cu, khong
// doi yeu cau nay). Doc xong 1 hang (64 byte) -> ghi broadcast ca 64 bank cung
// 1 cycle, cung dia chi k -> lap lai 768 lan (K=768). Khong dung nhieu giao
// dich AXI cung luc (khong outstanding) - don gian, de kiem chung dung, tranh
// dung phai co che "nhieu giao dich dang cho" da nghi ngo la nguon goc bug o
// ban HLS tu sinh.
//
// [SUA - 2026-08-21] Doi kenh doc AXI tu 8-bit/beat (1 byte/beat) sang 32-bit/
// beat (4 byte/beat) - Vivado AXI SmartConnect (axi_smc) tu choi Package IP
// AXI4 interface voi RDATA_WIDTH<32 (gia tri hop le chi 32/64/128/256/512/
// 1024) - can Package IP de co Address Space rieng cho A (xem docs/task.md
// muc "PHAT HIEN MOI - 2026-08-21", bug 2b: khong co Address Space rieng thi
// axi_smc_1 tra hang so 0 co dinh cho duong doc cua A). Chi doi cach van
// chuyen du lieu qua AXI (it beat hon, 4 byte/beat thay vi 1) - KHONG doi vi
// tri luu trong DDR, KHONG doi buoc broadcast ra 64 bank (van byte-level,
// giu nguyen 100%), KHONG doi FSM 5 trang thai.
//
// [SUA - 2026-08-18] Cong ghi 64 bank la 256 CONG PHANG rieng (bank0_addr_o..
// bank63_din_o), KHONG con la bus gop nhu ban dau - Vivado IPI khong ho tro
// bit-select tren cong vector cua module-reference cell qua Tcl (da xac nhan
// bang get_bd_pins that, xem docs/task.md muc BD 41-759). Logic FSM ben trong
// van dung bus noi bo (bank_addr_q/bank_en_q/bank_we_q/bank_din_q), chi tach
// ra cong phang qua khoi assign o cuoi file.
module AXI4_A_READER #(
  parameter AWIDTH      = 32,  // do rong dia chi AXI (khop m_axi cua mmult_accel)
  parameter BANK_AWIDTH  = 10,  // $clog2(768) - dia chi trong 1 bank A
  parameter NUM_BANKS    = 64,
  parameter NUM_ROWS     = 768  // = MAX_K, so hang A can doc
)(
  input  wire                              clk_i,
  input  wire                              rst_ni,

  // Dieu khien tu mmult_accel_0 (HLS) - xem mmult_accel.h port a_reload_req_o
  input  wire                              a_reload_req_i,  // xung 1 cycle, bao AP_START voi update_A=1
  input  wire [AWIDTH-1:0]                 a_base_addr_i,   // dia chi goc cua A trong DDR (tu thanh ghi AXI-Lite, qua mmult_accel_0)
  output reg                               a_loaded_o,      // muc: 1 = da nap xong, giu toi lan a_reload_req_i ke tiep

  // AXI4 master - CHI DOC (khong AW/W/B, khong ghi DDR)
  output reg  [AWIDTH-1:0]                 m_axi_araddr_o,
  output reg  [7:0]                        m_axi_arlen_o,
  output reg  [2:0]                        m_axi_arsize_o,
  output reg  [1:0]                        m_axi_arburst_o,
  output reg                               m_axi_arvalid_o,
  input  wire                              m_axi_arready_i,
  input  wire [31:0]                       m_axi_rdata_i,
  input  wire                              m_axi_rvalid_i,
  input  wire                              m_axi_rlast_i,
  output reg                               m_axi_rready_o,

  // [SUA - 2026-08-18] Vivado IPI KHONG ho tro bit-select (`pin[N]`/`pin[N:N]`)
  // tren cong vector cua module-reference cell qua Tcl connect_bd_net/get_bd_pins
  // (da xac nhan bang get_bd_pins that, xem docs/task.md muc BD 41-759) - doi 64
  // bank A tu 1 bus gop sang CONG PHANG rieng tung bank, giong dung cach da sua
  // cho SYSTOLIC_CORE_TOP (A/B/C, xem B3 sua lan 4 / B4 trong docs/task.md).
  output wire [BANK_AWIDTH-1:0]            bank0_addr_o,
  output wire                              bank0_en_o,
  output wire                              bank0_we_o,
  output wire [7:0]                        bank0_din_o,
  output wire [BANK_AWIDTH-1:0]            bank1_addr_o,
  output wire                              bank1_en_o,
  output wire                              bank1_we_o,
  output wire [7:0]                        bank1_din_o,
  output wire [BANK_AWIDTH-1:0]            bank2_addr_o,
  output wire                              bank2_en_o,
  output wire                              bank2_we_o,
  output wire [7:0]                        bank2_din_o,
  output wire [BANK_AWIDTH-1:0]            bank3_addr_o,
  output wire                              bank3_en_o,
  output wire                              bank3_we_o,
  output wire [7:0]                        bank3_din_o,
  output wire [BANK_AWIDTH-1:0]            bank4_addr_o,
  output wire                              bank4_en_o,
  output wire                              bank4_we_o,
  output wire [7:0]                        bank4_din_o,
  output wire [BANK_AWIDTH-1:0]            bank5_addr_o,
  output wire                              bank5_en_o,
  output wire                              bank5_we_o,
  output wire [7:0]                        bank5_din_o,
  output wire [BANK_AWIDTH-1:0]            bank6_addr_o,
  output wire                              bank6_en_o,
  output wire                              bank6_we_o,
  output wire [7:0]                        bank6_din_o,
  output wire [BANK_AWIDTH-1:0]            bank7_addr_o,
  output wire                              bank7_en_o,
  output wire                              bank7_we_o,
  output wire [7:0]                        bank7_din_o,
  output wire [BANK_AWIDTH-1:0]            bank8_addr_o,
  output wire                              bank8_en_o,
  output wire                              bank8_we_o,
  output wire [7:0]                        bank8_din_o,
  output wire [BANK_AWIDTH-1:0]            bank9_addr_o,
  output wire                              bank9_en_o,
  output wire                              bank9_we_o,
  output wire [7:0]                        bank9_din_o,
  output wire [BANK_AWIDTH-1:0]            bank10_addr_o,
  output wire                              bank10_en_o,
  output wire                              bank10_we_o,
  output wire [7:0]                        bank10_din_o,
  output wire [BANK_AWIDTH-1:0]            bank11_addr_o,
  output wire                              bank11_en_o,
  output wire                              bank11_we_o,
  output wire [7:0]                        bank11_din_o,
  output wire [BANK_AWIDTH-1:0]            bank12_addr_o,
  output wire                              bank12_en_o,
  output wire                              bank12_we_o,
  output wire [7:0]                        bank12_din_o,
  output wire [BANK_AWIDTH-1:0]            bank13_addr_o,
  output wire                              bank13_en_o,
  output wire                              bank13_we_o,
  output wire [7:0]                        bank13_din_o,
  output wire [BANK_AWIDTH-1:0]            bank14_addr_o,
  output wire                              bank14_en_o,
  output wire                              bank14_we_o,
  output wire [7:0]                        bank14_din_o,
  output wire [BANK_AWIDTH-1:0]            bank15_addr_o,
  output wire                              bank15_en_o,
  output wire                              bank15_we_o,
  output wire [7:0]                        bank15_din_o,
  output wire [BANK_AWIDTH-1:0]            bank16_addr_o,
  output wire                              bank16_en_o,
  output wire                              bank16_we_o,
  output wire [7:0]                        bank16_din_o,
  output wire [BANK_AWIDTH-1:0]            bank17_addr_o,
  output wire                              bank17_en_o,
  output wire                              bank17_we_o,
  output wire [7:0]                        bank17_din_o,
  output wire [BANK_AWIDTH-1:0]            bank18_addr_o,
  output wire                              bank18_en_o,
  output wire                              bank18_we_o,
  output wire [7:0]                        bank18_din_o,
  output wire [BANK_AWIDTH-1:0]            bank19_addr_o,
  output wire                              bank19_en_o,
  output wire                              bank19_we_o,
  output wire [7:0]                        bank19_din_o,
  output wire [BANK_AWIDTH-1:0]            bank20_addr_o,
  output wire                              bank20_en_o,
  output wire                              bank20_we_o,
  output wire [7:0]                        bank20_din_o,
  output wire [BANK_AWIDTH-1:0]            bank21_addr_o,
  output wire                              bank21_en_o,
  output wire                              bank21_we_o,
  output wire [7:0]                        bank21_din_o,
  output wire [BANK_AWIDTH-1:0]            bank22_addr_o,
  output wire                              bank22_en_o,
  output wire                              bank22_we_o,
  output wire [7:0]                        bank22_din_o,
  output wire [BANK_AWIDTH-1:0]            bank23_addr_o,
  output wire                              bank23_en_o,
  output wire                              bank23_we_o,
  output wire [7:0]                        bank23_din_o,
  output wire [BANK_AWIDTH-1:0]            bank24_addr_o,
  output wire                              bank24_en_o,
  output wire                              bank24_we_o,
  output wire [7:0]                        bank24_din_o,
  output wire [BANK_AWIDTH-1:0]            bank25_addr_o,
  output wire                              bank25_en_o,
  output wire                              bank25_we_o,
  output wire [7:0]                        bank25_din_o,
  output wire [BANK_AWIDTH-1:0]            bank26_addr_o,
  output wire                              bank26_en_o,
  output wire                              bank26_we_o,
  output wire [7:0]                        bank26_din_o,
  output wire [BANK_AWIDTH-1:0]            bank27_addr_o,
  output wire                              bank27_en_o,
  output wire                              bank27_we_o,
  output wire [7:0]                        bank27_din_o,
  output wire [BANK_AWIDTH-1:0]            bank28_addr_o,
  output wire                              bank28_en_o,
  output wire                              bank28_we_o,
  output wire [7:0]                        bank28_din_o,
  output wire [BANK_AWIDTH-1:0]            bank29_addr_o,
  output wire                              bank29_en_o,
  output wire                              bank29_we_o,
  output wire [7:0]                        bank29_din_o,
  output wire [BANK_AWIDTH-1:0]            bank30_addr_o,
  output wire                              bank30_en_o,
  output wire                              bank30_we_o,
  output wire [7:0]                        bank30_din_o,
  output wire [BANK_AWIDTH-1:0]            bank31_addr_o,
  output wire                              bank31_en_o,
  output wire                              bank31_we_o,
  output wire [7:0]                        bank31_din_o,
  output wire [BANK_AWIDTH-1:0]            bank32_addr_o,
  output wire                              bank32_en_o,
  output wire                              bank32_we_o,
  output wire [7:0]                        bank32_din_o,
  output wire [BANK_AWIDTH-1:0]            bank33_addr_o,
  output wire                              bank33_en_o,
  output wire                              bank33_we_o,
  output wire [7:0]                        bank33_din_o,
  output wire [BANK_AWIDTH-1:0]            bank34_addr_o,
  output wire                              bank34_en_o,
  output wire                              bank34_we_o,
  output wire [7:0]                        bank34_din_o,
  output wire [BANK_AWIDTH-1:0]            bank35_addr_o,
  output wire                              bank35_en_o,
  output wire                              bank35_we_o,
  output wire [7:0]                        bank35_din_o,
  output wire [BANK_AWIDTH-1:0]            bank36_addr_o,
  output wire                              bank36_en_o,
  output wire                              bank36_we_o,
  output wire [7:0]                        bank36_din_o,
  output wire [BANK_AWIDTH-1:0]            bank37_addr_o,
  output wire                              bank37_en_o,
  output wire                              bank37_we_o,
  output wire [7:0]                        bank37_din_o,
  output wire [BANK_AWIDTH-1:0]            bank38_addr_o,
  output wire                              bank38_en_o,
  output wire                              bank38_we_o,
  output wire [7:0]                        bank38_din_o,
  output wire [BANK_AWIDTH-1:0]            bank39_addr_o,
  output wire                              bank39_en_o,
  output wire                              bank39_we_o,
  output wire [7:0]                        bank39_din_o,
  output wire [BANK_AWIDTH-1:0]            bank40_addr_o,
  output wire                              bank40_en_o,
  output wire                              bank40_we_o,
  output wire [7:0]                        bank40_din_o,
  output wire [BANK_AWIDTH-1:0]            bank41_addr_o,
  output wire                              bank41_en_o,
  output wire                              bank41_we_o,
  output wire [7:0]                        bank41_din_o,
  output wire [BANK_AWIDTH-1:0]            bank42_addr_o,
  output wire                              bank42_en_o,
  output wire                              bank42_we_o,
  output wire [7:0]                        bank42_din_o,
  output wire [BANK_AWIDTH-1:0]            bank43_addr_o,
  output wire                              bank43_en_o,
  output wire                              bank43_we_o,
  output wire [7:0]                        bank43_din_o,
  output wire [BANK_AWIDTH-1:0]            bank44_addr_o,
  output wire                              bank44_en_o,
  output wire                              bank44_we_o,
  output wire [7:0]                        bank44_din_o,
  output wire [BANK_AWIDTH-1:0]            bank45_addr_o,
  output wire                              bank45_en_o,
  output wire                              bank45_we_o,
  output wire [7:0]                        bank45_din_o,
  output wire [BANK_AWIDTH-1:0]            bank46_addr_o,
  output wire                              bank46_en_o,
  output wire                              bank46_we_o,
  output wire [7:0]                        bank46_din_o,
  output wire [BANK_AWIDTH-1:0]            bank47_addr_o,
  output wire                              bank47_en_o,
  output wire                              bank47_we_o,
  output wire [7:0]                        bank47_din_o,
  output wire [BANK_AWIDTH-1:0]            bank48_addr_o,
  output wire                              bank48_en_o,
  output wire                              bank48_we_o,
  output wire [7:0]                        bank48_din_o,
  output wire [BANK_AWIDTH-1:0]            bank49_addr_o,
  output wire                              bank49_en_o,
  output wire                              bank49_we_o,
  output wire [7:0]                        bank49_din_o,
  output wire [BANK_AWIDTH-1:0]            bank50_addr_o,
  output wire                              bank50_en_o,
  output wire                              bank50_we_o,
  output wire [7:0]                        bank50_din_o,
  output wire [BANK_AWIDTH-1:0]            bank51_addr_o,
  output wire                              bank51_en_o,
  output wire                              bank51_we_o,
  output wire [7:0]                        bank51_din_o,
  output wire [BANK_AWIDTH-1:0]            bank52_addr_o,
  output wire                              bank52_en_o,
  output wire                              bank52_we_o,
  output wire [7:0]                        bank52_din_o,
  output wire [BANK_AWIDTH-1:0]            bank53_addr_o,
  output wire                              bank53_en_o,
  output wire                              bank53_we_o,
  output wire [7:0]                        bank53_din_o,
  output wire [BANK_AWIDTH-1:0]            bank54_addr_o,
  output wire                              bank54_en_o,
  output wire                              bank54_we_o,
  output wire [7:0]                        bank54_din_o,
  output wire [BANK_AWIDTH-1:0]            bank55_addr_o,
  output wire                              bank55_en_o,
  output wire                              bank55_we_o,
  output wire [7:0]                        bank55_din_o,
  output wire [BANK_AWIDTH-1:0]            bank56_addr_o,
  output wire                              bank56_en_o,
  output wire                              bank56_we_o,
  output wire [7:0]                        bank56_din_o,
  output wire [BANK_AWIDTH-1:0]            bank57_addr_o,
  output wire                              bank57_en_o,
  output wire                              bank57_we_o,
  output wire [7:0]                        bank57_din_o,
  output wire [BANK_AWIDTH-1:0]            bank58_addr_o,
  output wire                              bank58_en_o,
  output wire                              bank58_we_o,
  output wire [7:0]                        bank58_din_o,
  output wire [BANK_AWIDTH-1:0]            bank59_addr_o,
  output wire                              bank59_en_o,
  output wire                              bank59_we_o,
  output wire [7:0]                        bank59_din_o,
  output wire [BANK_AWIDTH-1:0]            bank60_addr_o,
  output wire                              bank60_en_o,
  output wire                              bank60_we_o,
  output wire [7:0]                        bank60_din_o,
  output wire [BANK_AWIDTH-1:0]            bank61_addr_o,
  output wire                              bank61_en_o,
  output wire                              bank61_we_o,
  output wire [7:0]                        bank61_din_o,
  output wire [BANK_AWIDTH-1:0]            bank62_addr_o,
  output wire                              bank62_en_o,
  output wire                              bank62_we_o,
  output wire [7:0]                        bank62_din_o,
  output wire [BANK_AWIDTH-1:0]            bank63_addr_o,
  output wire                              bank63_en_o,
  output wire                              bank63_we_o,
  output wire [7:0]                        bank63_din_o
);

  localparam ST_IDLE  = 3'd0;
  localparam ST_AR    = 3'd1;
  localparam ST_R     = 3'd2;
  localparam ST_WRITE = 3'd3;
  localparam ST_DONE  = 3'd4;

  localparam NUM_BEATS = NUM_BANKS / 4;  // 4 byte/beat (32-bit AXI)

  reg [2:0]                    state_q;
  reg [$clog2(NUM_ROWS)-1:0]   k_cnt_q;
  reg [$clog2(NUM_BEATS)-1:0]  beat_cnt_q;
  // [SUA - 2026-08-21] Doi tu mang (memory-style, "reg [7:0] row_buf_q [0:N-1]")
  // sang vector phang + part-select — mang kieu nay bi Vivado ap luat suy luan
  // RAM khi doc dong thoi NUM_BANKS lan/cycle o ST_WRITE, vuot gioi han cung
  // "RAM has too many ports (16)" (xem synth_1/runme.log that) -> toan bo logic
  // bi am tham loai bo, dpb_a*/din_a_i bi noi vao const0. Vector phang tranh
  // hoan toan luat nay (giong cach bank_addr_q/bank_din_q da dung dung tu dau).
  reg [NUM_BANKS*8-1:0]        row_buf_q;
  reg                          req_seen_q;  // chot a_reload_req_i (xung 1 cycle) den khi ST_DONE
  // Thanh ghi noi bo giu gia tri truoc khi tach ra 64 bo cong phang (xem
  // khoi assign unpack o cuoi file).
  reg [NUM_BANKS*BANK_AWIDTH-1:0]  bank_addr_q;
  reg [NUM_BANKS-1:0]              bank_en_q;
  reg [NUM_BANKS-1:0]              bank_we_q;
  reg [NUM_BANKS*8-1:0]            bank_din_q;

  integer ii;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      state_q         <= ST_IDLE;
      k_cnt_q         <= 0;
      beat_cnt_q      <= 0;
      a_loaded_o      <= 1'b0;
      req_seen_q      <= 1'b0;
      m_axi_arvalid_o <= 1'b0;
      m_axi_rready_o  <= 1'b0;
      bank_en_q       <= 0;
      bank_we_q       <= 0;
    end else begin
      if (a_reload_req_i) req_seen_q <= 1'b1;

      // Mac dinh moi cycle: khong assert ghi bank (chi ST_WRITE moi bat)
      bank_en_q <= 0;
      bank_we_q <= 0;

      case (state_q)
        ST_IDLE: begin
          if (req_seen_q) begin
            k_cnt_q    <= 0;
            a_loaded_o <= 1'b0;
            state_q    <= ST_AR;
          end
        end

        ST_AR: begin
          m_axi_araddr_o  <= a_base_addr_i + (k_cnt_q * NUM_BANKS);
          m_axi_arlen_o   <= NUM_BEATS - 1;  // 16 beat x 4 byte/burst = dung 1 hang A
          m_axi_arsize_o  <= 3'b010;         // 4 byte/beat (32-bit AXI)
          m_axi_arburst_o <= 2'b01;          // INCR
          m_axi_arvalid_o <= 1'b1;
          if (m_axi_arvalid_o && m_axi_arready_i) begin
            m_axi_arvalid_o <= 1'b0;
            beat_cnt_q      <= 0;
            m_axi_rready_o  <= 1'b1;
            state_q         <= ST_R;
          end
        end

        ST_R: begin
          if (m_axi_rvalid_i && m_axi_rready_o) begin
            row_buf_q[beat_cnt_q*32 +: 32] <= m_axi_rdata_i;
            if (m_axi_rlast_i) begin
              m_axi_rready_o <= 1'b0;
              state_q        <= ST_WRITE;
            end else begin
              beat_cnt_q <= beat_cnt_q + 1'b1;
            end
          end
        end

        ST_WRITE: begin
          // Ghi broadcast ca NUM_BANKS bank, cung dia chi k_cnt_q, dung 1 cycle.
          for (ii = 0; ii < NUM_BANKS; ii = ii + 1) begin
            bank_addr_q[ii*BANK_AWIDTH +: BANK_AWIDTH] <= k_cnt_q;
            bank_din_q [ii*8           +: 8]           <= row_buf_q[ii*8 +: 8];
          end
          bank_en_q <= {NUM_BANKS{1'b1}};
          bank_we_q <= {NUM_BANKS{1'b1}};

          if (k_cnt_q == NUM_ROWS - 1) begin
            state_q <= ST_DONE;
          end else begin
            k_cnt_q <= k_cnt_q + 1'b1;
            state_q <= ST_AR;
          end
        end

        ST_DONE: begin
          a_loaded_o <= 1'b1;
          req_seen_q <= 1'b0;
          state_q    <= ST_IDLE;
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  // [SUA - 2026-08-18] Tach bank_*_q (bus noi bo) ra 64 bo cong phang - xem
  // ghi chu o dau khoi khai bao cong phia tren.
  assign bank0_addr_o = bank_addr_q[0*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank0_en_o   = bank_en_q[0];
  assign bank0_we_o   = bank_we_q[0];
  assign bank0_din_o  = bank_din_q[0*8 +: 8];
  assign bank1_addr_o = bank_addr_q[1*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank1_en_o   = bank_en_q[1];
  assign bank1_we_o   = bank_we_q[1];
  assign bank1_din_o  = bank_din_q[1*8 +: 8];
  assign bank2_addr_o = bank_addr_q[2*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank2_en_o   = bank_en_q[2];
  assign bank2_we_o   = bank_we_q[2];
  assign bank2_din_o  = bank_din_q[2*8 +: 8];
  assign bank3_addr_o = bank_addr_q[3*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank3_en_o   = bank_en_q[3];
  assign bank3_we_o   = bank_we_q[3];
  assign bank3_din_o  = bank_din_q[3*8 +: 8];
  assign bank4_addr_o = bank_addr_q[4*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank4_en_o   = bank_en_q[4];
  assign bank4_we_o   = bank_we_q[4];
  assign bank4_din_o  = bank_din_q[4*8 +: 8];
  assign bank5_addr_o = bank_addr_q[5*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank5_en_o   = bank_en_q[5];
  assign bank5_we_o   = bank_we_q[5];
  assign bank5_din_o  = bank_din_q[5*8 +: 8];
  assign bank6_addr_o = bank_addr_q[6*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank6_en_o   = bank_en_q[6];
  assign bank6_we_o   = bank_we_q[6];
  assign bank6_din_o  = bank_din_q[6*8 +: 8];
  assign bank7_addr_o = bank_addr_q[7*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank7_en_o   = bank_en_q[7];
  assign bank7_we_o   = bank_we_q[7];
  assign bank7_din_o  = bank_din_q[7*8 +: 8];
  assign bank8_addr_o = bank_addr_q[8*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank8_en_o   = bank_en_q[8];
  assign bank8_we_o   = bank_we_q[8];
  assign bank8_din_o  = bank_din_q[8*8 +: 8];
  assign bank9_addr_o = bank_addr_q[9*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank9_en_o   = bank_en_q[9];
  assign bank9_we_o   = bank_we_q[9];
  assign bank9_din_o  = bank_din_q[9*8 +: 8];
  assign bank10_addr_o = bank_addr_q[10*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank10_en_o   = bank_en_q[10];
  assign bank10_we_o   = bank_we_q[10];
  assign bank10_din_o  = bank_din_q[10*8 +: 8];
  assign bank11_addr_o = bank_addr_q[11*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank11_en_o   = bank_en_q[11];
  assign bank11_we_o   = bank_we_q[11];
  assign bank11_din_o  = bank_din_q[11*8 +: 8];
  assign bank12_addr_o = bank_addr_q[12*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank12_en_o   = bank_en_q[12];
  assign bank12_we_o   = bank_we_q[12];
  assign bank12_din_o  = bank_din_q[12*8 +: 8];
  assign bank13_addr_o = bank_addr_q[13*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank13_en_o   = bank_en_q[13];
  assign bank13_we_o   = bank_we_q[13];
  assign bank13_din_o  = bank_din_q[13*8 +: 8];
  assign bank14_addr_o = bank_addr_q[14*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank14_en_o   = bank_en_q[14];
  assign bank14_we_o   = bank_we_q[14];
  assign bank14_din_o  = bank_din_q[14*8 +: 8];
  assign bank15_addr_o = bank_addr_q[15*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank15_en_o   = bank_en_q[15];
  assign bank15_we_o   = bank_we_q[15];
  assign bank15_din_o  = bank_din_q[15*8 +: 8];
  assign bank16_addr_o = bank_addr_q[16*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank16_en_o   = bank_en_q[16];
  assign bank16_we_o   = bank_we_q[16];
  assign bank16_din_o  = bank_din_q[16*8 +: 8];
  assign bank17_addr_o = bank_addr_q[17*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank17_en_o   = bank_en_q[17];
  assign bank17_we_o   = bank_we_q[17];
  assign bank17_din_o  = bank_din_q[17*8 +: 8];
  assign bank18_addr_o = bank_addr_q[18*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank18_en_o   = bank_en_q[18];
  assign bank18_we_o   = bank_we_q[18];
  assign bank18_din_o  = bank_din_q[18*8 +: 8];
  assign bank19_addr_o = bank_addr_q[19*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank19_en_o   = bank_en_q[19];
  assign bank19_we_o   = bank_we_q[19];
  assign bank19_din_o  = bank_din_q[19*8 +: 8];
  assign bank20_addr_o = bank_addr_q[20*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank20_en_o   = bank_en_q[20];
  assign bank20_we_o   = bank_we_q[20];
  assign bank20_din_o  = bank_din_q[20*8 +: 8];
  assign bank21_addr_o = bank_addr_q[21*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank21_en_o   = bank_en_q[21];
  assign bank21_we_o   = bank_we_q[21];
  assign bank21_din_o  = bank_din_q[21*8 +: 8];
  assign bank22_addr_o = bank_addr_q[22*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank22_en_o   = bank_en_q[22];
  assign bank22_we_o   = bank_we_q[22];
  assign bank22_din_o  = bank_din_q[22*8 +: 8];
  assign bank23_addr_o = bank_addr_q[23*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank23_en_o   = bank_en_q[23];
  assign bank23_we_o   = bank_we_q[23];
  assign bank23_din_o  = bank_din_q[23*8 +: 8];
  assign bank24_addr_o = bank_addr_q[24*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank24_en_o   = bank_en_q[24];
  assign bank24_we_o   = bank_we_q[24];
  assign bank24_din_o  = bank_din_q[24*8 +: 8];
  assign bank25_addr_o = bank_addr_q[25*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank25_en_o   = bank_en_q[25];
  assign bank25_we_o   = bank_we_q[25];
  assign bank25_din_o  = bank_din_q[25*8 +: 8];
  assign bank26_addr_o = bank_addr_q[26*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank26_en_o   = bank_en_q[26];
  assign bank26_we_o   = bank_we_q[26];
  assign bank26_din_o  = bank_din_q[26*8 +: 8];
  assign bank27_addr_o = bank_addr_q[27*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank27_en_o   = bank_en_q[27];
  assign bank27_we_o   = bank_we_q[27];
  assign bank27_din_o  = bank_din_q[27*8 +: 8];
  assign bank28_addr_o = bank_addr_q[28*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank28_en_o   = bank_en_q[28];
  assign bank28_we_o   = bank_we_q[28];
  assign bank28_din_o  = bank_din_q[28*8 +: 8];
  assign bank29_addr_o = bank_addr_q[29*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank29_en_o   = bank_en_q[29];
  assign bank29_we_o   = bank_we_q[29];
  assign bank29_din_o  = bank_din_q[29*8 +: 8];
  assign bank30_addr_o = bank_addr_q[30*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank30_en_o   = bank_en_q[30];
  assign bank30_we_o   = bank_we_q[30];
  assign bank30_din_o  = bank_din_q[30*8 +: 8];
  assign bank31_addr_o = bank_addr_q[31*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank31_en_o   = bank_en_q[31];
  assign bank31_we_o   = bank_we_q[31];
  assign bank31_din_o  = bank_din_q[31*8 +: 8];
  assign bank32_addr_o = bank_addr_q[32*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank32_en_o   = bank_en_q[32];
  assign bank32_we_o   = bank_we_q[32];
  assign bank32_din_o  = bank_din_q[32*8 +: 8];
  assign bank33_addr_o = bank_addr_q[33*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank33_en_o   = bank_en_q[33];
  assign bank33_we_o   = bank_we_q[33];
  assign bank33_din_o  = bank_din_q[33*8 +: 8];
  assign bank34_addr_o = bank_addr_q[34*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank34_en_o   = bank_en_q[34];
  assign bank34_we_o   = bank_we_q[34];
  assign bank34_din_o  = bank_din_q[34*8 +: 8];
  assign bank35_addr_o = bank_addr_q[35*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank35_en_o   = bank_en_q[35];
  assign bank35_we_o   = bank_we_q[35];
  assign bank35_din_o  = bank_din_q[35*8 +: 8];
  assign bank36_addr_o = bank_addr_q[36*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank36_en_o   = bank_en_q[36];
  assign bank36_we_o   = bank_we_q[36];
  assign bank36_din_o  = bank_din_q[36*8 +: 8];
  assign bank37_addr_o = bank_addr_q[37*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank37_en_o   = bank_en_q[37];
  assign bank37_we_o   = bank_we_q[37];
  assign bank37_din_o  = bank_din_q[37*8 +: 8];
  assign bank38_addr_o = bank_addr_q[38*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank38_en_o   = bank_en_q[38];
  assign bank38_we_o   = bank_we_q[38];
  assign bank38_din_o  = bank_din_q[38*8 +: 8];
  assign bank39_addr_o = bank_addr_q[39*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank39_en_o   = bank_en_q[39];
  assign bank39_we_o   = bank_we_q[39];
  assign bank39_din_o  = bank_din_q[39*8 +: 8];
  assign bank40_addr_o = bank_addr_q[40*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank40_en_o   = bank_en_q[40];
  assign bank40_we_o   = bank_we_q[40];
  assign bank40_din_o  = bank_din_q[40*8 +: 8];
  assign bank41_addr_o = bank_addr_q[41*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank41_en_o   = bank_en_q[41];
  assign bank41_we_o   = bank_we_q[41];
  assign bank41_din_o  = bank_din_q[41*8 +: 8];
  assign bank42_addr_o = bank_addr_q[42*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank42_en_o   = bank_en_q[42];
  assign bank42_we_o   = bank_we_q[42];
  assign bank42_din_o  = bank_din_q[42*8 +: 8];
  assign bank43_addr_o = bank_addr_q[43*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank43_en_o   = bank_en_q[43];
  assign bank43_we_o   = bank_we_q[43];
  assign bank43_din_o  = bank_din_q[43*8 +: 8];
  assign bank44_addr_o = bank_addr_q[44*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank44_en_o   = bank_en_q[44];
  assign bank44_we_o   = bank_we_q[44];
  assign bank44_din_o  = bank_din_q[44*8 +: 8];
  assign bank45_addr_o = bank_addr_q[45*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank45_en_o   = bank_en_q[45];
  assign bank45_we_o   = bank_we_q[45];
  assign bank45_din_o  = bank_din_q[45*8 +: 8];
  assign bank46_addr_o = bank_addr_q[46*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank46_en_o   = bank_en_q[46];
  assign bank46_we_o   = bank_we_q[46];
  assign bank46_din_o  = bank_din_q[46*8 +: 8];
  assign bank47_addr_o = bank_addr_q[47*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank47_en_o   = bank_en_q[47];
  assign bank47_we_o   = bank_we_q[47];
  assign bank47_din_o  = bank_din_q[47*8 +: 8];
  assign bank48_addr_o = bank_addr_q[48*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank48_en_o   = bank_en_q[48];
  assign bank48_we_o   = bank_we_q[48];
  assign bank48_din_o  = bank_din_q[48*8 +: 8];
  assign bank49_addr_o = bank_addr_q[49*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank49_en_o   = bank_en_q[49];
  assign bank49_we_o   = bank_we_q[49];
  assign bank49_din_o  = bank_din_q[49*8 +: 8];
  assign bank50_addr_o = bank_addr_q[50*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank50_en_o   = bank_en_q[50];
  assign bank50_we_o   = bank_we_q[50];
  assign bank50_din_o  = bank_din_q[50*8 +: 8];
  assign bank51_addr_o = bank_addr_q[51*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank51_en_o   = bank_en_q[51];
  assign bank51_we_o   = bank_we_q[51];
  assign bank51_din_o  = bank_din_q[51*8 +: 8];
  assign bank52_addr_o = bank_addr_q[52*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank52_en_o   = bank_en_q[52];
  assign bank52_we_o   = bank_we_q[52];
  assign bank52_din_o  = bank_din_q[52*8 +: 8];
  assign bank53_addr_o = bank_addr_q[53*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank53_en_o   = bank_en_q[53];
  assign bank53_we_o   = bank_we_q[53];
  assign bank53_din_o  = bank_din_q[53*8 +: 8];
  assign bank54_addr_o = bank_addr_q[54*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank54_en_o   = bank_en_q[54];
  assign bank54_we_o   = bank_we_q[54];
  assign bank54_din_o  = bank_din_q[54*8 +: 8];
  assign bank55_addr_o = bank_addr_q[55*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank55_en_o   = bank_en_q[55];
  assign bank55_we_o   = bank_we_q[55];
  assign bank55_din_o  = bank_din_q[55*8 +: 8];
  assign bank56_addr_o = bank_addr_q[56*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank56_en_o   = bank_en_q[56];
  assign bank56_we_o   = bank_we_q[56];
  assign bank56_din_o  = bank_din_q[56*8 +: 8];
  assign bank57_addr_o = bank_addr_q[57*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank57_en_o   = bank_en_q[57];
  assign bank57_we_o   = bank_we_q[57];
  assign bank57_din_o  = bank_din_q[57*8 +: 8];
  assign bank58_addr_o = bank_addr_q[58*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank58_en_o   = bank_en_q[58];
  assign bank58_we_o   = bank_we_q[58];
  assign bank58_din_o  = bank_din_q[58*8 +: 8];
  assign bank59_addr_o = bank_addr_q[59*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank59_en_o   = bank_en_q[59];
  assign bank59_we_o   = bank_we_q[59];
  assign bank59_din_o  = bank_din_q[59*8 +: 8];
  assign bank60_addr_o = bank_addr_q[60*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank60_en_o   = bank_en_q[60];
  assign bank60_we_o   = bank_we_q[60];
  assign bank60_din_o  = bank_din_q[60*8 +: 8];
  assign bank61_addr_o = bank_addr_q[61*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank61_en_o   = bank_en_q[61];
  assign bank61_we_o   = bank_we_q[61];
  assign bank61_din_o  = bank_din_q[61*8 +: 8];
  assign bank62_addr_o = bank_addr_q[62*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank62_en_o   = bank_en_q[62];
  assign bank62_we_o   = bank_we_q[62];
  assign bank62_din_o  = bank_din_q[62*8 +: 8];
  assign bank63_addr_o = bank_addr_q[63*BANK_AWIDTH +: BANK_AWIDTH];
  assign bank63_en_o   = bank_en_q[63];
  assign bank63_we_o   = bank_we_q[63];
  assign bank63_din_o  = bank_din_q[63*8 +: 8];

endmodule
