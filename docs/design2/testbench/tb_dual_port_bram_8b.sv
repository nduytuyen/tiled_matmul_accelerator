`timescale 1ns / 1ps

module tb_dual_port_bram_8b;

  localparam time CLK_PERIOD = 10ns;

  logic clk_i;
  int pass_count = 0;
  int fail_count = 0;

  // ---- DUT chinh: DEPTH=6144 (bank B) ------------
  localparam int DEPTH = 6144;
  logic [$clog2(DEPTH)-1:0] addr_a_i;
  logic                     en_a_i;
  logic                     we_a_i;
  logic [7:0]               din_a_i;
  logic [7:0]               dout_a_o;
  logic [$clog2(DEPTH)-1:0] addr_b_i;
  logic                     en_b_i;
  logic [7:0]               dout_b_o;

  DUAL_PORT_BRAM_8B #(.DEPTH(DEPTH)) dut (
    .clk_i    (clk_i),
    .addr_a_i (addr_a_i),
    .en_a_i   (en_a_i),
    .we_a_i   (we_a_i),
    .din_a_i  (din_a_i),
    .dout_a_o (dout_a_o),
    .addr_b_i (addr_b_i),
    .en_b_i   (en_b_i),
    .dout_b_o (dout_b_o)
  );

  // ---- DUT phu: DEPTH=768 (bank A) ----------------
  localparam int DEPTH_A = 768;
  logic [$clog2(DEPTH_A)-1:0] addr_a_i_a768;
  logic                       en_a_i_a768;
  logic                       we_a_i_a768;
  logic [7:0]                 din_a_i_a768;
  logic [7:0]                 dout_a_o_a768;
  logic [$clog2(DEPTH_A)-1:0] addr_b_i_a768;
  logic                       en_b_i_a768;
  logic [7:0]                 dout_b_o_a768;

  DUAL_PORT_BRAM_8B #(.DEPTH(DEPTH_A)) dut_depth768 (
    .clk_i    (clk_i),
    .addr_a_i (addr_a_i_a768),
    .en_a_i   (en_a_i_a768),
    .we_a_i   (we_a_i_a768),
    .din_a_i  (din_a_i_a768),
    .dout_a_o (dout_a_o_a768),
    .addr_b_i (addr_b_i_a768),
    .en_b_i   (en_b_i_a768),
    .dout_b_o (dout_b_o_a768)
  );

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  task automatic check(input logic [7:0] actual, input logic [7:0] expected, input string tag);
    if (actual === expected) begin
      pass_count++;
      $display("[PASS] %s: gia tri=%0d (dung ky vong %0d)", tag, actual, expected);
    end else begin
      fail_count++;
      $display("[FAIL] %s: gia tri=%0d (ky vong %0d)", tag, actual, expected);
    end
  endtask

  initial begin
    clk_i    = 1'b0;
    addr_a_i = '0;
    en_a_i   = 1'b0;
    we_a_i   = 1'b0;
    din_a_i  = '0;
    addr_b_i = '0;
    en_b_i   = 1'b0;

    addr_a_i_a768 = '0;
    en_a_i_a768   = 1'b0;
    we_a_i_a768   = 1'b0;
    din_a_i_a768  = '0;
    addr_b_i_a768 = '0;
    en_b_i_a768   = 1'b0;

    repeat (2) @(posedge clk_i);
    #1; // Dong bo sau reset

    // ---- Test 1: ghi cong A (Khong check dout_a_o vi HLS chi ghi) -----------
    addr_a_i = 10; en_a_i = 1'b1; we_a_i = 1'b1; din_a_i = 8'hA5;
    @(posedge clk_i);
    #1; // Delay triet tieu Race Condition
    
    addr_a_i = 20; din_a_i = 8'h5A; 
    @(posedge clk_i);
    #1;
    
    din_a_i = 8'h11;
    @(posedge clk_i);
    #1;
    we_a_i = 1'b0; en_a_i = 1'b0;
    $display("[INFO] Test 1 (Ghi Cong A) hoan tat.");

    // ---- Test 2: ghi cong A, doc cong B (khac cycle) -------------------------------
    addr_a_i = 30; en_a_i = 1'b1; we_a_i = 1'b1; din_a_i = 8'h33;
    @(posedge clk_i);
    #1;
    en_a_i = 1'b0; we_a_i = 1'b0;
    
    addr_b_i = 30; en_b_i = 1'b1;
    @(posedge clk_i);
    #1;
    check(dout_b_o, 8'h33, "Ghi cong A addr=30, doc cong B cung dia chi");
    en_b_i = 1'b0;

    // ---- Test 3: truy cap dong thoi 2 cong, khac dia chi ---------------------------
    addr_a_i = 50; en_a_i = 1'b1; we_a_i = 1'b1; din_a_i = 8'hCC;
    @(posedge clk_i);
    #1;
    we_a_i = 1'b0; en_a_i = 1'b0;
    
    @(posedge clk_i); // idle 1 cycle
    #1;
    
    addr_a_i = 60; en_a_i = 1'b1; we_a_i = 1'b1; din_a_i = 8'hDD;
    addr_b_i = 50; en_b_i = 1'b1;
    @(posedge clk_i);
    #1;
    we_a_i = 1'b0; en_a_i = 1'b0; en_b_i = 1'b0;
    check(dout_b_o, 8'hCC, "Dong thoi 2 cong khac dia chi: cong B doc dung addr=50, khong bi anh huong ghi addr=60");

    // ---- Test 4: bien dia chi tren DUT chinh (DEPTH=6144, bank B) ------------------
    addr_a_i = 0; en_a_i = 1'b1; we_a_i = 1'b1; din_a_i = 8'h01;
    @(posedge clk_i);
    #1;
    we_a_i = 1'b0; en_a_i = 1'b0;
    
    addr_b_i = 0; en_b_i = 1'b1;
    @(posedge clk_i);
    #1;
    check(dout_b_o, 8'h01, "Bien dia chi DEPTH=6144: addr=0");
    en_b_i = 1'b0;
    
    addr_a_i = DEPTH - 1; en_a_i = 1'b1; we_a_i = 1'b1; din_a_i = 8'hFE;
    @(posedge clk_i);
    #1;
    we_a_i = 1'b0; en_a_i = 1'b0;
    
    addr_b_i = DEPTH - 1; en_b_i = 1'b1;
    @(posedge clk_i);
    #1;
    check(dout_b_o, 8'hFE, "Bien dia chi DEPTH=6144: addr=DEPTH-1");
    en_b_i = 1'b0;

    // ---- Test 5: bien dia chi tren DUT phu (DEPTH=768, bank A) ---------------------
    addr_a_i_a768 = 0; en_a_i_a768 = 1'b1; we_a_i_a768 = 1'b1; din_a_i_a768 = 8'h7A;
    @(posedge clk_i);
    #1;
    we_a_i_a768 = 1'b0; en_a_i_a768 = 1'b0;
    
    addr_b_i_a768 = 0; en_b_i_a768 = 1'b1;
    @(posedge clk_i);
    #1;
    check(dout_b_o_a768, 8'h7A, "Bien dia chi DEPTH=768: addr=0");
    en_b_i_a768 = 1'b0;

    addr_a_i_a768 = DEPTH_A - 1; en_a_i_a768 = 1'b1; we_a_i_a768 = 1'b1; din_a_i_a768 = 8'hB7;
    @(posedge clk_i);
    #1;
    we_a_i_a768 = 1'b0; en_a_i_a768 = 1'b0;
    
    addr_b_i_a768 = DEPTH_A - 1; en_b_i_a768 = 1'b1;
    @(posedge clk_i);
    #1;
    check(dout_b_o_a768, 8'hB7, "Bien dia chi DEPTH=768: addr=DEPTH_A-1");
    en_b_i_a768 = 1'b0;

    // ---- Test 6: ghi don dap KHONG NGHI ---------------------
    begin
      automatic logic [7:0] expected_a768 [0:DEPTH_A-1];
      automatic int mismatch = 0;

      en_a_i_a768 = 1'b1;
      we_a_i_a768 = 1'b1;
      for (int addr = 0; addr < DEPTH_A; addr++) begin
        addr_a_i_a768 = addr[$clog2(DEPTH_A)-1:0];
        din_a_i_a768  = addr[7:0] ^ 8'hA5;
        expected_a768[addr] = addr[7:0] ^ 8'hA5;
        @(posedge clk_i);
        #1; // Bat buoc phai co delay de khong de dia chi
      end
      we_a_i_a768 = 1'b0;
      en_a_i_a768 = 1'b0;

      // Doc lai toan bo 768 dia chi
      en_b_i_a768 = 1'b1;
      for (int addr = 0; addr < DEPTH_A; addr++) begin
        addr_b_i_a768 = addr[$clog2(DEPTH_A)-1:0];
        @(posedge clk_i);
        #1;
        if (dout_b_o_a768 !== expected_a768[addr]) begin
          mismatch++;
          $display("[FAIL] Ghi don dap addr=%0d: gia tri=%0d (ky vong %0d)",
                    addr, dout_b_o_a768, expected_a768[addr]);
        end
      end
      en_b_i_a768 = 1'b0;

      if (mismatch == 0) begin
        pass_count++;
        $display("[PASS] Ghi don dap khong nghi cycle: 768/768 dia chi khop dung");
      end else begin
        fail_count++;
        $display("[FAIL] Ghi don dap khong nghi cycle: %0d/768 dia chi SAI", mismatch);
      end
    end

    $display("========================================");
    $display("tb_dual_port_bram_8b: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_dual_port_bram_8b: ALL TESTS PASSED");
    else $display("tb_dual_port_bram_8b: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule