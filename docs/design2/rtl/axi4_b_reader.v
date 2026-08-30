// [Huong B (tiep) - xem docs/task.md muc "Stage 2 chay duoc - A het treo, lo ra bug MOI o B/tile"
// va docs/modules/axi4_b_reader.md] Sau khi AXI4_A_READER giai quyet dut diem bug treo cua A,
// Verification chay lai tb_integration_top.sv (Stage 2) va bam duoc bang chung RTL that: FSM tong
// cua mmult_accel khoi dong Outline_copy_B_block_ap_start VA Outline_tile_i_ap_start CUNG 1 cycle
// (t=514965000), trong khi copy_B_block khong bao gio bao ap_done that (chi phat dung 1 xung
// ARVALID roi im bat). Nguyen nhan: b_bank<n> la cong GHI THANG ra ngoai (interface bram, khong
// doc lai trong C++), nen voi phan tich phu thuoc du lieu cua Vitis HLS, copy_B_block (chi ghi
// b_bank<n>) va tile_i (khong dung b_bank<n> trong C++, chi cho tin hieu bat tay) KHONG co phu
// thuoc du lieu o muc C++ - HLS thay "duoc phep" chay song song, du thiet ke phan cung ngam dinh
// B phai ghi xong truoc khi RTL doc no qua tile handshake. Dung cung huong da lam cho A: bo han
// copy_B_block khoi Vitis HLS, tu viet RTL doc AXI4 rieng - loai tru toan bo lop loi "HLS tu lap
// lich sai vung outline" cho ca A lan B.
//
// Khac voi AXI4_A_READER (doc 1 lan/call, K=768 co dinh luc bien dich): AXI4_B_READER phai doc
// LAI moi lan doi j_block (outer_j_block lap M/BLOCK_M lan/call), va K/current_block_M la gia tri
// RUNTIME (khong co dinh) - nhan qua b_num_rows_i/b_block_width_i tu mmult_accel moi lan
// b_reload_req_i pulse. outer_j_block VAN o lai trong HLS (can phoi hop voi tile handshake ben
// SYSTOLIC_CORE_TOP), chi rieng phan doc AXI + ghi 32 bank moi j_block chuyen het sang day.
//
// 1 hang DDR cua block hien tai <= 256 byte (=BLOCK_M, vua khop 1 burst AXI4 toi da 64 beat x 4
// byte) -> 1 burst/hang, do dai bien doi theo b_block_width_i. Doc xong 1 hang -> ghi broadcast 32
// bank, nhung MOI bank can 8 phan tu/hang (=BLOCK_M/NUM_BANKS) nen can 8 chu ky ghi/hang
// (JJ_COUNT=8), khac A (1 chu ky ghi/hang vi 1 bank chi can 1 phan tu/hang).
//
// [SUA - 2026-08-21] Doi kenh doc AXI tu 8-bit/beat sang 32-bit/beat (4 byte/beat) - cung ly do
// + cung cach voi AXI4_A_READER (xem ghi chu dau axi4_a_reader.v). GIOI HAN: b_block_width_i
// (=current_block_M runtime) PHAI chia het cho 4 de tinh dung so beat - da ghi trong
// docs/modules/axi4_b_reader.md muc "GIOI HAN DA BIET", khong phat sinh gioi han moi (M=64 dang
// dung an toan).
module AXI4_B_READER #(
  parameter AWIDTH      = 32,   // do rong dia chi AXI (khop m_axi cua mmult_accel)
  parameter BANK_AWIDTH  = 13,   // $clog2(6144) - dia chi trong 1 bank B
  parameter NUM_BANKS    = 32,
  parameter MAX_BLOCK_M  = 256,  // = BLOCK_M, do dai toi da 1 burst (1 hang cua 1 block)
  parameter JJ_COUNT     = 8,    // = MAX_BLOCK_M / NUM_BANKS, so chu ky ghi/hang
  parameter ROW_CNT_W    = 10,   // $clog2(MAX_K=768) - du cho K runtime toi da 768
  parameter WIDTH_CNT_W  = 9     // du bieu dien gia tri 0..256
)(
  input  wire                              clk_i,
  input  wire                              rst_ni,

  // Dieu khien tu mmult_accel_0 (HLS) - xung 1 cycle MOI LAN doi j_block (khong chi 1 lan/call
  // nhu A). Cac gia tri kem theo phai on dinh tu luc pulse toi khi b_loaded_o len 1.
  input  wire                              b_reload_req_i,
  input  wire [AWIDTH-1:0]                 b_base_addr_i,   // = B_addr + j_block (offset phan tu, byte)
  input  wire [AWIDTH-1:0]                 b_row_stride_i,  // = M (so cot 1 hang DDR goc, de += moi hang)
  input  wire [ROW_CNT_W-1:0]              b_num_rows_i,    // = K (runtime)
  input  wire [WIDTH_CNT_W-1:0]            b_block_width_i, // = current_block_M (<=256, runtime)
  output reg                               b_loaded_o,      // muc: 1 = da nap xong block hien tai

  // AXI4 master - CHI DOC (khong AW/W/B, khong ghi DDR) - B goc la const, chi doc
  output reg  [AWIDTH-1:0]                 m_axi_araddr_o,
  output reg  [7:0]                        m_axi_arlen_o,   // bien doi theo b_block_width_i-1
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
  // (da xac nhan bang get_bd_pins that, xem docs/task.md muc BD 41-759) - doi 32
  // bank B tu 1 bus gop sang CONG PHANG rieng tung bank, giong AXI4_A_READER.
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
  output wire [7:0]                        bank31_din_o
);

  localparam ST_IDLE  = 3'd0;
  localparam ST_AR    = 3'd1;
  localparam ST_R     = 3'd2;
  localparam ST_WRITE = 3'd3;
  localparam ST_DONE  = 3'd4;

  reg [2:0]                     state_q;
  reg [ROW_CNT_W-1:0]           k_cnt_q;
  reg [WIDTH_CNT_W-1:0]         beat_cnt_q;      // dem beat trong burst hien tai (0..255)
  reg [AWIDTH-1:0]              row_addr_q;      // dia chi hang hien tai, += stride moi hang
  reg [$clog2(JJ_COUNT+1)-1:0]  jj_cnt_q;        // 0..7
  // [SUA - 2026-08-21] Doi tu mang (memory-style) sang vector phang + part-select
  // — cung ly do voi AXI4_A_READER (RAM suy luan vuot gioi han "too many ports
  // (16)" khi doc dong thoi NUM_BANKS lan/cycle o ST_WRITE, bi Vivado am tham
  // loai bo). Xem axi4_a_reader.v.
  reg [MAX_BLOCK_M*8-1:0]       row_buf_q;
  reg                           req_seen_q;      // chot b_reload_req_i (xung 1 cycle) den ST_DONE
  // Thanh ghi noi bo giu gia tri truoc khi tach ra 32 bo cong phang (xem
  // khoi assign unpack o cuoi file).
  reg [NUM_BANKS*BANK_AWIDTH-1:0]  bank_addr_q;
  reg [NUM_BANKS-1:0]              bank_en_q;
  reg [NUM_BANKS-1:0]              bank_we_q;
  reg [NUM_BANKS*8-1:0]            bank_din_q;

  // Chot lai luc bat dau block (b_reload_req_i chi dam bao hop le dung 1 cycle luc pulse).
  reg [AWIDTH-1:0]      row_stride_q;
  reg [ROW_CNT_W-1:0]   num_rows_q;
  reg [WIDTH_CNT_W-1:0] width_q;

  integer ii;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      state_q         <= ST_IDLE;
      k_cnt_q         <= 0;
      beat_cnt_q      <= 0;
      jj_cnt_q        <= 0;
      b_loaded_o      <= 1'b0;
      req_seen_q      <= 1'b0;
      m_axi_arvalid_o <= 1'b0;
      m_axi_rready_o  <= 1'b0;
      bank_en_q       <= 0;
      bank_we_q       <= 0;
    end else begin
      if (b_reload_req_i) req_seen_q <= 1'b1;

      // Mac dinh moi cycle: khong assert ghi bank (chi ST_WRITE moi bat).
      bank_en_q <= 0;
      bank_we_q <= 0;

      case (state_q)
        ST_IDLE: begin
          if (req_seen_q) begin
            b_loaded_o <= 1'b0;
            if (b_num_rows_i == 0) begin
              // K=0: khop dung "for(k=0;k<K;k++)" chay 0 lan trong C++ goc - khong doc gi ca.
              state_q <= ST_DONE;
            end else begin
              k_cnt_q      <= 0;
              row_addr_q   <= b_base_addr_i;
              row_stride_q <= b_row_stride_i;
              num_rows_q   <= b_num_rows_i;
              width_q      <= b_block_width_i;
              state_q      <= ST_AR;
            end
          end
        end

        ST_AR: begin
          m_axi_araddr_o  <= row_addr_q;
          // do dai bien doi theo so tu 32-bit (=width_q/4), toi da 63 (=64 beat x 4 byte=1 block)
          // - width_q phai chia het cho 4, xem GIOI HAN DA BIET trong axi4_b_reader.md
          m_axi_arlen_o   <= (width_q >> 2) - 1'b1;
          m_axi_arsize_o  <= 3'b010;          // 4 byte/beat (32-bit AXI)
          m_axi_arburst_o <= 2'b01;           // INCR
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
              jj_cnt_q       <= 0;
              state_q        <= ST_WRITE;
            end else begin
              beat_cnt_q <= beat_cnt_q + 1'b1;
            end
          end
        end

        ST_WRITE: begin
          // Moi cycle ghi dung 1 "jj" cho ca 32 bank cung luc (8 cycle/hang, vi 1 hang = 256
          // phan tu / 32 bank = 8 phan tu/bank). Cot >= width_q (phan duoi cua block cuoi, neu
          // current_block_M < BLOCK_M) ghi 0, khop dung padding "col < current_block_M ? .. : 0"
          // trong copy_B_block cu.
          for (ii = 0; ii < NUM_BANKS; ii = ii + 1) begin
            bank_addr_q[ii*BANK_AWIDTH +: BANK_AWIDTH] <= k_cnt_q * JJ_COUNT + jj_cnt_q;
            bank_din_q [ii*8           +: 8]           <=
              ((jj_cnt_q * NUM_BANKS + ii) < width_q)
                ? row_buf_q[(jj_cnt_q*NUM_BANKS + ii)*8 +: 8] : 8'h00;
          end
          bank_en_q <= {NUM_BANKS{1'b1}};
          bank_we_q <= {NUM_BANKS{1'b1}};

          if (jj_cnt_q == JJ_COUNT - 1) begin
            if (k_cnt_q == num_rows_q - 1'b1) begin
              state_q <= ST_DONE;
            end else begin
              k_cnt_q    <= k_cnt_q + 1'b1;
              row_addr_q <= row_addr_q + row_stride_q;
              jj_cnt_q   <= 0;
              state_q    <= ST_AR;
            end
          end else begin
            jj_cnt_q <= jj_cnt_q + 1'b1;
          end
        end

        ST_DONE: begin
          b_loaded_o <= 1'b1;
          req_seen_q <= 1'b0;
          state_q    <= ST_IDLE;
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  // [SUA - 2026-08-18] Tach bank_*_q (bus noi bo) ra 32 bo cong phang - xem
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

endmodule
