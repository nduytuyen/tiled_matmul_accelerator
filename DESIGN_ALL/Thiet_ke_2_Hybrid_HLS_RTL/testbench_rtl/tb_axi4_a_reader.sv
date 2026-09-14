`timescale 1ns / 1ps

// Test module AXI4_A_READER (Huong B - xem 01_design/docs/task.md muc "[MOI - 2026-08-17]
// pivot sang Huong B", 01_design/docs/modules/axi4_a_reader.md). Module la AXI4 master CHI DOC
// (AR+R, non-outstanding: chi phat 1 burst tai 1 thoi diem, cho RLAST xong moi phat burst ke
// tiep), doc 768 hang A (moi hang 64 phan tu = 16 beat x 4 byte = 1 burst) roi ghi broadcast vao
// 64 bank DUAL_PORT_BRAM_8B qua 256 CONG PHANG rieng (bank<n>_addr_o/en_o/we_o/din_o, n=0..63 -
// xem docs/modules/axi4_a_reader.md muc "SUA - 2026-08-18": Vivado khong ho tro bit-select tren
// cong vector cua module-reference cell qua Tcl connect_bd_net).
//
// [SUA - 2026-08-21] m_axi_rdata_i doi tu 8-bit sang 32-bit (4 byte/beat) - xem
// docs/modules/axi4_a_reader.md muc "SUA - 2026-08-21". BFM duoi day da doi theo: doc 4 byte
// lien tiep tu ddr_mem, dong goi thanh 1 tu 32-bit theo dung little-endian AXI (byte dau tien
// trong burst nam o bit [7:0]).
//
// Theo dung task: chi instantiate vai khoi DUAL_PORT_BRAM_8B DAI DIEN (khong can du 64) - dung
// bank 0, 1 (dau), 32 (giua), 63 (cuoi) de xac nhan khong lech chi so ma khong ton thoi gian mo
// phong dung 64 khoi day du.
module tb_axi4_a_reader;

  localparam time CLK_PERIOD = 10ns;

  localparam int AWIDTH      = 32;
  localparam int BANK_AWIDTH = 10;
  localparam int NUM_BANKS   = 64;
  localparam int NUM_ROWS    = 768;
  localparam int ROW_BYTES   = NUM_BANKS; // 1 byte/phan tu (DTYPE_IN=int8)

  logic clk_i;
  logic rst_ni;
  int   pass_count = 0;
  int   fail_count = 0;

  // ---- Dieu khien tu mmult_accel_0 (mo phong) ----
  logic                    a_reload_req_i;
  logic [AWIDTH-1:0]       a_base_addr_i;
  logic                    a_loaded_o;

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

  // ---- 4 bo cong phang dai dien: bank 0, 1, 32, 63 (dau/giua/cuoi) ----
  // DUT co du 256 cong phang (64 bank x 4 tin hieu) - chi noi ten day cho 4 bank dai dien de
  // xac nhan khong lech chi so, cac cong con lai (256-16=240 tin hieu) de trong (khong noi trong
  // named port connection - hop le vi la output cua DUT).
  wire [BANK_AWIDTH-1:0] bank0_addr_o,  bank1_addr_o,  bank32_addr_o,  bank63_addr_o;
  wire                    bank0_en_o,    bank1_en_o,    bank32_en_o,    bank63_en_o;
  wire                    bank0_we_o,    bank1_we_o,    bank32_we_o,    bank63_we_o;
  wire [7:0]              bank0_din_o,   bank1_din_o,   bank32_din_o,   bank63_din_o;

  AXI4_A_READER #(
    .AWIDTH      (AWIDTH),
    .BANK_AWIDTH (BANK_AWIDTH),
    .NUM_BANKS   (NUM_BANKS),
    .NUM_ROWS    (NUM_ROWS)
  ) dut (
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),
    .a_reload_req_i  (a_reload_req_i),
    .a_base_addr_i   (a_base_addr_i),
    .a_loaded_o      (a_loaded_o),
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
    .bank32_addr_o   (bank32_addr_o),
    .bank32_en_o     (bank32_en_o),
    .bank32_we_o     (bank32_we_o),
    .bank32_din_o    (bank32_din_o),
    .bank63_addr_o   (bank63_addr_o),
    .bank63_en_o     (bank63_en_o),
    .bank63_we_o     (bank63_we_o),
    .bank63_din_o    (bank63_din_o)
  );

  // ---- 4 khoi DUAL_PORT_BRAM_8B dai dien: bank 0, 1, 32, 63 ----
  localparam int REP_BANKS [0:3] = '{0, 1, 32, 63};

  logic [$clog2(NUM_ROWS)-1:0] rep_addr_b_i [0:3];
  logic                        rep_en_b_i   [0:3];
  logic [7:0]                  rep_dout_b_o [0:3];

  DUAL_PORT_BRAM_8B #(.DEPTH(NUM_ROWS)) dut_bank0 (
    .clk_i(clk_i), .addr_a_i(bank0_addr_o), .en_a_i(bank0_en_o), .we_a_i(bank0_we_o),
    .din_a_i(bank0_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[0]), .en_b_i(rep_en_b_i[0]), .dout_b_o(rep_dout_b_o[0])
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(NUM_ROWS)) dut_bank1 (
    .clk_i(clk_i), .addr_a_i(bank1_addr_o), .en_a_i(bank1_en_o), .we_a_i(bank1_we_o),
    .din_a_i(bank1_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[1]), .en_b_i(rep_en_b_i[1]), .dout_b_o(rep_dout_b_o[1])
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(NUM_ROWS)) dut_bank32 (
    .clk_i(clk_i), .addr_a_i(bank32_addr_o), .en_a_i(bank32_en_o), .we_a_i(bank32_we_o),
    .din_a_i(bank32_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[2]), .en_b_i(rep_en_b_i[2]), .dout_b_o(rep_dout_b_o[2])
  );
  DUAL_PORT_BRAM_8B #(.DEPTH(NUM_ROWS)) dut_bank63 (
    .clk_i(clk_i), .addr_a_i(bank63_addr_o), .en_a_i(bank63_en_o), .we_a_i(bank63_we_o),
    .din_a_i(bank63_din_o), .dout_a_o(),
    .addr_b_i(rep_addr_b_i[3]), .en_b_i(rep_en_b_i[3]), .dout_b_o(rep_dout_b_o[3])
  );

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // ---- BFM AXI4 chi-doc (AR+R), non-outstanding - khop dung DUT chi phat 1 burst/lan ----
  // Mo phong DDR bang mang byte, du lon cho 2 lan nap du lieu test (768*64=49152 byte/lan).
  localparam int DDR_BYTES = 2 * NUM_ROWS * ROW_BYTES;
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

  // Doc lai toan bo 768 hang cho ca 4 bank dai dien, doi chieu voi ddr_mem tai base_addr da nap.
  task automatic verify_all_rows(input logic [AWIDTH-1:0] base_addr, input string tag);
    automatic int mismatch = 0;
    for (int k = 0; k < NUM_ROWS; k++) begin
      for (int b = 0; b < 4; b++) begin
        rep_addr_b_i[b] = k[$clog2(NUM_ROWS)-1:0];
        rep_en_b_i[b]   = 1'b1;
      end
      @(posedge clk_i);
      #1;
      for (int b = 0; b < 4; b++) begin
        automatic logic [7:0] expected = ddr_mem[base_addr + k * ROW_BYTES + REP_BANKS[b]];
        if (rep_dout_b_o[b] !== expected) begin
          mismatch++;
          $display("[FAIL] %s: k=%0d bank=%0d gia tri=%0d (ky vong %0d)",
                    tag, k, REP_BANKS[b], rep_dout_b_o[b], expected);
        end
      end
    end
    for (int b = 0; b < 4; b++) rep_en_b_i[b] = 1'b0;

    if (mismatch == 0) begin
      pass_count++;
      $display("[PASS] %s: 768x4=3072 gia tri khop dung", tag);
    end else begin
      fail_count++;
      $display("[FAIL] %s: %0d/3072 gia tri SAI", tag, mismatch);
    end
  endtask

  // Cho a_loaded_o len 1, co watchdog (768 hang x ~(2 AR + 64 R + 1 WRITE) cycle ~ 51000 cycle,
  // dat du du 200000 de an toan).
  task automatic wait_a_loaded(input string tag);
    automatic int cyc = 0;
    automatic bit timed_out = 1'b0;
    while (!a_loaded_o) begin
      @(posedge clk_i);
      #1; // triet tieu race condition voi always @(posedge clk_i) noi bo AXI4_A_READER
      cyc++;
      if (cyc >= 200_000) begin
        timed_out = 1'b1;
        break;
      end
    end
    if (timed_out) begin
      fail_count++;
      $display("[FAIL] %s: TIMEOUT cho a_loaded_o sau %0d cycle", tag, cyc);
    end else begin
      pass_count++;
      $display("[PASS] %s: a_loaded_o len 1 sau %0d cycle", tag, cyc);
    end
  endtask

  initial begin
    clk_i          = 1'b0;
    rst_ni         = 1'b0;
    a_reload_req_i = 1'b0;
    a_base_addr_i  = '0;
    for (int b = 0; b < 4; b++) begin
      rep_addr_b_i[b] = '0;
      rep_en_b_i[b]   = 1'b0;
    end

    repeat (5) @(posedge clk_i);
    #1;
    rst_ni = 1'b1;
    repeat (2) @(posedge clk_i);
    #1;

    // ---- Test 1: nap lan dau, du lieu pattern1 = (k ^ n ^ 8'h5A) ----
    for (int k = 0; k < NUM_ROWS; k++)
      for (int n = 0; n < NUM_BANKS; n++)
        ddr_mem[k * ROW_BYTES + n] = (k[7:0] ^ n[7:0]) ^ 8'h5A;

    a_base_addr_i  = 32'h0000_0000;
    a_reload_req_i = 1'b1;
    @(posedge clk_i);
    #1;
    a_reload_req_i = 1'b0;

    wait_a_loaded("Test 1: nap lan dau");
    verify_all_rows(32'h0000_0000, "Test 1: doc lai sau nap lan dau");

    // ---- Test 2: nap lan 2, du lieu pattern2 KHAC (k + n) tai CUNG dia chi goc ----
    // Xac nhan a_loaded_o tut ve 0 dung luc roi len lai, du lieu MOI khong dinh du lieu CU.
    for (int k = 0; k < NUM_ROWS; k++)
      for (int n = 0; n < NUM_BANKS; n++)
        ddr_mem[k * ROW_BYTES + n] = (k[7:0] + n[7:0]);

    a_reload_req_i = 1'b1;
    @(posedge clk_i);
    #1;
    a_reload_req_i = 1'b0;

    // a_loaded_o phai tut ve 0 trong vai cycle dau (FSM roi ST_IDLE) - kiem tra trong 1 cua so
    // ngan ngay sau khi pulse, truoc khi goi wait_a_loaded (se cho toi khi len lai 1).
    begin
      automatic int cyc = 0;
      automatic bit dropped = 1'b0;
      while (cyc < 20) begin
        @(posedge clk_i);
        #1;
        cyc++;
        if (!a_loaded_o) begin
          dropped = 1'b1;
          break;
        end
      end
      if (dropped) begin
        pass_count++;
        $display("[PASS] Test 2: a_loaded_o tut ve 0 dung luc sau %0d cycle tu luc pulse lan 2", cyc);
      end else begin
        fail_count++;
        $display("[FAIL] Test 2: a_loaded_o khong tut ve 0 sau 20 cycle tu luc pulse lan 2");
      end
    end

    wait_a_loaded("Test 2: nap lan 2 (du lieu moi)");
    verify_all_rows(32'h0000_0000, "Test 2: doc lai sau nap lan 2 - xac nhan du lieu MOI, khong dinh du lieu CU");

    $display("========================================");
    $display("tb_axi4_a_reader: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_axi4_a_reader: ALL TESTS PASSED");
    else $display("tb_axi4_a_reader: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
