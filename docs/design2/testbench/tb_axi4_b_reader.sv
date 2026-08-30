`timescale 1ns / 1ps

// Test module AXI4_B_READER (Huong B tiep - xem 01_design/docs/task.md muc "SUA LAN 12",
// 01_design/docs/modules/axi4_b_reader.md). Module la AXI4 master CHI DOC (AR+R,
// non-outstanding: chi phat 1 burst tai 1 thoi diem, cho RLAST xong moi phat burst ke
// tiep), doc lai MOI LAN doi j_block (K/do rong block la gia tri RUNTIME, khac
// AXI4_A_READER chi doc 1 lan/call voi K=768 co dinh luc bien dich). Doc 1 hang DDR (<=256
// phan tu = 1 burst) roi ghi 32 bank B qua 8 chu ky (JJ_COUNT=8, vi 1 hang 256 phan tu / 32
// bank = 8 phan tu/bank), lap lai K hang.
//
// Theo dung task: chi instantiate vai khoi DUAL_PORT_BRAM_8B DAI DIEN (khong can du 32) -
// dung bank 0, 1 (dau), 16 (giua), 31 (cuoi).
//
// [SUA - 2026-08-21] m_axi_rdata_i doi tu 8-bit sang 32-bit (4 byte/beat), cong phang ghi bank
// doi tu bus gop sang 128 cong rieng - xem docs/modules/axi4_b_reader.md muc "SUA - 2026-08-21"
// va "SUA - 2026-08-18". Ca 2 gia tri width dung trong test (256, 100) deu chia het cho 4 (dung
// gioi han da biet cua RTL) - khong can doi gia tri test.
module tb_axi4_b_reader;

  localparam time CLK_PERIOD = 10ns;

  localparam int AWIDTH      = 32;
  localparam int BANK_AWIDTH = 13;
  localparam int NUM_BANKS   = 32;
  localparam int MAX_BLOCK_M = 256;
  localparam int JJ_COUNT    = 8;
  localparam int ROW_CNT_W   = 10;
  localparam int WIDTH_CNT_W = 9;
  localparam int BANK_DEPTH  = 6144; // = MAX_K * (MAX_BLOCK_M/NUM_BANKS) = 768*8

  logic clk_i;
  logic rst_ni;
  int   pass_count = 0;
  int   fail_count = 0;

  // ---- Dieu khien tu mmult_accel_0 (mo phong) ----
  logic                    b_reload_req_i;
  logic [AWIDTH-1:0]       b_base_addr_i;
  logic [AWIDTH-1:0]       b_row_stride_i;
  logic [ROW_CNT_W-1:0]    b_num_rows_i;
  logic [WIDTH_CNT_W-1:0]  b_block_width_i;
  logic                    b_loaded_o;

  // ---- AXI4 master chi-doc cua DUT ----
  logic [AWIDTH-1:0] m_axi_araddr_o;
  logic [7:0]        m_axi_arlen_o;
  logic [2:0]        m_axi_arsize_o;
  logic [1:0]        m_axi_arburst_o;
  logic               m_axi_arvalid_o;
  logic               m_axi_arready_i;
  logic [31:0]        m_axi_rdata_i;
  logic               m_axi_rvalid_i;
  logic               m_axi_rlast_i;
  logic               m_axi_rready_o;

  // ---- 4 bo cong phang dai dien: bank 0, 1, 16, 31 (dau/giua/cuoi) ----
  wire [BANK_AWIDTH-1:0] bank0_addr_o,  bank1_addr_o,  bank16_addr_o,  bank31_addr_o;
  wire                    bank0_en_o,    bank1_en_o,    bank16_en_o,    bank31_en_o;
  wire                    bank0_we_o,    bank1_we_o,    bank16_we_o,    bank31_we_o;
  wire [7:0]              bank0_din_o,   bank1_din_o,   bank16_din_o,   bank31_din_o;

  AXI4_B_READER #(
    .AWIDTH      (AWIDTH),
    .BANK_AWIDTH (BANK_AWIDTH),
    .NUM_BANKS   (NUM_BANKS),
    .MAX_BLOCK_M (MAX_BLOCK_M),
    .JJ_COUNT    (JJ_COUNT),
    .ROW_CNT_W   (ROW_CNT_W),
    .WIDTH_CNT_W (WIDTH_CNT_W)
  ) dut (
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),
    .b_reload_req_i  (b_reload_req_i),
    .b_base_addr_i   (b_base_addr_i),
    .b_row_stride_i  (b_row_stride_i),
    .b_num_rows_i    (b_num_rows_i),
    .b_block_width_i (b_block_width_i),
    .b_loaded_o      (b_loaded_o),
    .m_axi_araddr_o  (m_axi_araddr_o),
    .m_axi_arlen_o   (m_axi_arlen_o),
    .m_axi_arsize_o  (m_axi_arsize_o),
    .m_axi_arburst_o (m_axi_arburst_o),
    .m_axi_arvalid_o (m_axi_arvalid_o),
    .m_axi_arready_i (m_axi_arready_i),
    .m_axi_rdata_i   (m_axi_rdata_i),
    .m_axi_rvalid_i  (m_axi_rvalid_i),
    .m_axi_rlast_i   (m_axi_rlast_i),
    .m_axi_rready_o  (m_axi_rready_o),
    .bank0_addr_o    (bank0_addr_o),
    .bank0_en_o      (bank0_en_o),
    .bank0_we_o      (bank0_we_o),
    .bank0_din_o     (bank0_din_o),
    .bank1_addr_o    (bank1_addr_o),
    .bank1_en_o      (bank1_en_o),
    .bank1_we_o      (bank1_we_o),
    .bank1_din_o     (bank1_din_o),
    .bank16_addr_o   (bank16_addr_o),
    .bank16_en_o     (bank16_en_o),
    .bank16_we_o     (bank16_we_o),
    .bank16_din_o    (bank16_din_o),
    .bank31_addr_o   (bank31_addr_o),
    .bank31_en_o     (bank31_en_o),
    .bank31_we_o     (bank31_we_o),
    .bank31_din_o    (bank31_din_o)
  );

  // ---- 4 khoi DUAL_PORT_BRAM_8B dai dien: bank 0, 1, 16, 31 ----
  localparam int REP_BANKS [0:3] = '{0, 1, 16, 31};

  logic [$clog2(BANK_DEPTH)-1:0] rep_addr_b_i [0:3];
  logic                          rep_en_b_i   [0:3];
  logic [7:0]                    rep_dout_b_o [0:3];

  DUAL_PORT_BRAM_8B #(.DEPTH(BANK_DEPTH)) dut_bank0 (
    .clk_i(clk_i), .addr_a_i(bank0_addr_o), .en_a_i(bank0_en_o), .we_a_i(bank0_we_o),
    .din_a_i(bank0_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[0]), .en_b_i(rep_en_b_i[0]), .dout_b_o(rep_dout_b_o[0])
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(BANK_DEPTH)) dut_bank1 (
    .clk_i(clk_i), .addr_a_i(bank1_addr_o), .en_a_i(bank1_en_o), .we_a_i(bank1_we_o),
    .din_a_i(bank1_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[1]), .en_b_i(rep_en_b_i[1]), .dout_b_o(rep_dout_b_o[1])
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(BANK_DEPTH)) dut_bank16 (
    .clk_i(clk_i), .addr_a_i(bank16_addr_o), .en_a_i(bank16_en_o), .we_a_i(bank16_we_o),
    .din_a_i(bank16_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[2]), .en_b_i(rep_en_b_i[2]), .dout_b_o(rep_dout_b_o[2])
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(BANK_DEPTH)) dut_bank31 (
    .clk_i(clk_i), .addr_a_i(bank31_addr_o), .en_a_i(bank31_en_o), .we_a_i(bank31_we_o),
    .din_a_i(bank31_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[3]), .en_b_i(rep_en_b_i[3]), .dout_b_o(rep_dout_b_o[3])
  );

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // ---- BFM AXI4 chi-doc (AR+R), non-outstanding - khop dung DUT chi phat 1 burst/lan ----
  // Mo phong DDR bang mang byte - du lon cho nhieu kich ban test lien tiep (dia chi base
  // khac nhau moi lan, xem cac task nap du lieu ben duoi).
  localparam int DDR_BYTES = 65536;
  logic [7:0] ddr_mem [0:DDR_BYTES-1];

  typedef enum logic [0:0] {BFM_IDLE, BFM_R} bfm_state_e;
  bfm_state_e         bfm_state_q;
  logic [AWIDTH-1:0]  bfm_addr_q;
  logic [7:0]         bfm_len_q;
  logic [7:0]         bfm_beat_q;

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      bfm_state_q     <= BFM_IDLE;
      m_axi_arready_i <= 1'b1;
      bfm_addr_q      <= '0;
      bfm_len_q       <= '0;
      bfm_beat_q      <= '0;
    end else begin
      case (bfm_state_q)
        BFM_IDLE: begin
          m_axi_arready_i <= 1'b1;
          if (m_axi_arvalid_o && m_axi_arready_i) begin
            bfm_addr_q      <= m_axi_araddr_o;
            bfm_len_q       <= m_axi_arlen_o;
            bfm_beat_q      <= 8'd0;
            m_axi_arready_i <= 1'b0;
            bfm_state_q     <= BFM_R;
          end
        end
        BFM_R: begin
          if (m_axi_rvalid_i && m_axi_rready_o) begin
            if (bfm_beat_q == bfm_len_q) begin
              bfm_state_q     <= BFM_IDLE;
              m_axi_arready_i <= 1'b1;
            end else begin
              bfm_beat_q <= bfm_beat_q + 1'b1;
            end
          end
        end
        default: bfm_state_q <= BFM_IDLE;
      endcase
    end
  end

  // [SUA - 2026-08-21] DUT nay doc 32-bit/beat (4 byte/beat) - dong goi 4 byte lien tiep tu
  // ddr_mem thanh 1 tu theo dung little-endian AXI (byte dau tien cua nhom o bit [7:0]).
  wire [AWIDTH-1:0] bfm_word_base = bfm_addr_q + (bfm_beat_q * 4);
  assign m_axi_rvalid_i = (bfm_state_q == BFM_R);
  assign m_axi_rdata_i  = {ddr_mem[bfm_word_base+3], ddr_mem[bfm_word_base+2],
                            ddr_mem[bfm_word_base+1], ddr_mem[bfm_word_base]};
  assign m_axi_rlast_i  = (bfm_beat_q == bfm_len_q);

  // Cho b_loaded_o len 1, co watchdog (toi da vai chuc hang x ~(2 AR + 256 R + 8 WRITE) cycle
  // ~ vai nghin cycle, dat du du 50000 de an toan).
  task automatic wait_b_loaded(input string tag);
    automatic int cyc = 0;
    automatic bit timed_out = 1'b0;
    while (!b_loaded_o) begin
      @(posedge clk_i);
      #1; // triet tieu race condition voi always @(posedge clk_i) noi bo AXI4_B_READER
      cyc++;
      if (cyc >= 50_000) begin
        timed_out = 1'b1;
        break;
      end
    end
    if (timed_out) begin
      fail_count++;
      $display("[FAIL] %s: TIMEOUT cho b_loaded_o sau %0d cycle", tag, cyc);
    end else begin
      pass_count++;
      $display("[PASS] %s: b_loaded_o len 1 sau %0d cycle", tag, cyc);
    end
  endtask

  // Doi chieu 1 block da nap: doc lai qua Cong B cua 4 bank dai dien, cho K hang, dung
  // dung cong thuc RTL that: addr=k*JJ_COUNT+jj, cot=jj*NUM_BANKS+bank, ghi 0 neu cot>=width.
  task automatic verify_block(input logic [AWIDTH-1:0] base_addr, input logic [AWIDTH-1:0] stride,
                               input int num_rows, input int width, input string tag);
    automatic int mismatch = 0;
    for (int k = 0; k < num_rows; k++) begin
      for (int jj = 0; jj < JJ_COUNT; jj++) begin
        automatic int addr = k * JJ_COUNT + jj;
        for (int b = 0; b < 4; b++) begin
          rep_addr_b_i[b] = addr[$clog2(BANK_DEPTH)-1:0];
          rep_en_b_i[b]   = 1'b1;
        end
        @(posedge clk_i);
        #1;
        for (int b = 0; b < 4; b++) begin
          automatic int col = jj * NUM_BANKS + REP_BANKS[b];
          automatic logic [7:0] expected =
            (col < width) ? ddr_mem[base_addr + k * stride + col] : 8'h00;
          if (rep_dout_b_o[b] !== expected) begin
            mismatch++;
            $display("[FAIL] %s: k=%0d jj=%0d bank=%0d gia tri=%0d (ky vong %0d)",
                      tag, k, jj, REP_BANKS[b], rep_dout_b_o[b], expected);
          end
        end
      end
    end
    for (int b = 0; b < 4; b++) rep_en_b_i[b] = 1'b0;

    if (mismatch == 0) begin
      pass_count++;
      $display("[PASS] %s: %0dx%0dx4 gia tri khop dung", tag, num_rows, JJ_COUNT);
    end else begin
      fail_count++;
      $display("[FAIL] %s: %0d gia tri SAI", tag, mismatch);
    end
  endtask

  initial begin
    clk_i           = 1'b0;
    rst_ni          = 1'b0;
    b_reload_req_i  = 1'b0;
    b_base_addr_i   = '0;
    b_row_stride_i  = '0;
    b_num_rows_i    = '0;
    b_block_width_i = '0;
    for (int b = 0; b < 4; b++) begin
      rep_addr_b_i[b] = '0;
      rep_en_b_i[b]   = 1'b0;
    end

    repeat (5) @(posedge clk_i);
    #1;
    rst_ni = 1'b1;
    repeat (2) @(posedge clk_i);
    #1;

    // ---- Test 1: block full-width (width=256=MAX_BLOCK_M), K=5, stride=300 (>width, mo
    // phong M=300>BLOCK_M that - xac nhan RTL dung dung stride, khong nham voi width) ----
    for (int k = 0; k < 5; k++)
      for (int col = 0; col < 300; col++)
        ddr_mem[k * 300 + col] = (k[7:0] ^ col[7:0]) ^ 8'hA5;

    b_base_addr_i   = 32'h0000_0000;
    b_row_stride_i  = 32'd300;
    b_num_rows_i    = 10'd5;
    b_block_width_i = 9'd256;
    b_reload_req_i  = 1'b1;
    @(posedge clk_i);
    #1;
    b_reload_req_i = 1'b0;

    wait_b_loaded("Test 1: block full-width K=5 stride=300");
    verify_block(32'h0000_0000, 32'd300, 5, 256, "Test 1");

    // ---- Test 2: block hep (width=100<256), K=3, stride=100(=width, M=100<BLOCK_M that) ----
    // Xac nhan padding 0 dung cho cot >= 100 (jj*32+bank >= 100).
    for (int k = 0; k < 3; k++)
      for (int col = 0; col < 100; col++)
        ddr_mem[32'h0000_1000 + k * 100 + col] = (k[7:0] + col[7:0]);

    b_base_addr_i   = 32'h0000_1000;
    b_row_stride_i  = 32'd100;
    b_num_rows_i    = 10'd3;
    b_block_width_i = 9'd100;
    b_reload_req_i  = 1'b1;
    @(posedge clk_i);
    #1;
    b_reload_req_i = 1'b0;

    // Xac nhan b_loaded_o tut ve 0 dung luc (trong cua so ngan sau pulse) - mo phong doi
    // j_block, khong chi lan nap dau tien.
    begin
      automatic int cyc = 0;
      automatic bit dropped = 1'b0;
      while (cyc < 20) begin
        @(posedge clk_i);
        #1;
        cyc++;
        if (!b_loaded_o) begin
          dropped = 1'b1;
          break;
        end
      end
      if (dropped) begin
        pass_count++;
        $display("[PASS] Test 2: b_loaded_o tut ve 0 dung luc sau %0d cycle tu luc pulse lan 2", cyc);
      end else begin
        fail_count++;
        $display("[FAIL] Test 2: b_loaded_o khong tut ve 0 sau 20 cycle tu luc pulse lan 2");
      end
    end

    wait_b_loaded("Test 2: block hep K=3 width=100 (mo phong doi j_block)");
    verify_block(32'h0000_1000, 32'd100, 3, 100, "Test 2 (xac nhan padding cot>=100 =0)");

    // ---- Test 3: bien K=0 - RTL phai bo qua, khong phat giao dich AXI nao, b_loaded_o len
    // 1 ngay (khop dung "for(k=0;k<K;k++)" chay 0 lan trong C++ goc) ----
    b_base_addr_i   = 32'h0000_2000;
    b_row_stride_i  = 32'd100;
    b_num_rows_i    = 10'd0;
    b_block_width_i = 9'd100;
    b_reload_req_i  = 1'b1;
    @(posedge clk_i);
    #1;
    b_reload_req_i = 1'b0;

    wait_b_loaded("Test 3: bien K=0");

    $display("========================================");
    $display("tb_axi4_b_reader: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_axi4_b_reader: ALL TESTS PASSED");
    else $display("tb_axi4_b_reader: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
