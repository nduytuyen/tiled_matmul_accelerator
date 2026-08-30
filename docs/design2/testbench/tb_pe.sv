`timescale 1ns / 1ps

module tb_pe;

  localparam int DATA_W = 8;
  localparam int ACC_W  = 32;
  localparam time CLK_PERIOD = 10ns;

  logic                     clk_i;
  logic                     rst_ni;
  logic                     clear_acc_i;
  logic                     en_i;
  logic signed [DATA_W-1:0] a_in_i;
  logic signed [DATA_W-1:0] b_in_i;
  logic signed [DATA_W-1:0] a_out_o;
  logic signed [DATA_W-1:0] b_out_o;
  logic signed [ACC_W-1:0]  acc_o;

  int pass_count = 0;
  int fail_count = 0;

  PE #(
    .DATA_W (DATA_W),
    .ACC_W  (ACC_W)
  ) dut (
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),
    .clear_acc_i (clear_acc_i),
    .en_i        (en_i),
    .a_in_i      (a_in_i),
    .b_in_i      (b_in_i),
    .a_out_o     (a_out_o),
    .b_out_o     (b_out_o),
    .acc_o       (acc_o)
  );

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  task automatic check_acc(input logic signed [ACC_W-1:0] expected, input string tag);
    if (acc_o === expected) begin
      pass_count++;
      $display("[PASS] %s: acc_o=%0d (expected %0d)", tag, acc_o, expected);
    end else begin
      fail_count++;
      $display("[FAIL] %s: acc_o=%0d (expected %0d)", tag, acc_o, expected);
    end
  endtask

  task automatic check_pass_through(
      input logic signed [DATA_W-1:0] expected_a,
      input logic signed [DATA_W-1:0] expected_b,
      input string tag
  );
    if (a_out_o === expected_a && b_out_o === expected_b) begin
      pass_count++;
      $display("[PASS] %s: a_out_o=%0d b_out_o=%0d (expected %0d/%0d)",
                tag, a_out_o, b_out_o, expected_a, expected_b);
    end else begin
      fail_count++;
      $display("[FAIL] %s: a_out_o=%0d b_out_o=%0d (expected %0d/%0d)",
                tag, a_out_o, b_out_o, expected_a, expected_b);
    end
  endtask

  task automatic do_mac(input logic signed [DATA_W-1:0] a, input logic signed [DATA_W-1:0] b);
    a_in_i = a;
    b_in_i = b;
    @(posedge clk_i);
  endtask

  task automatic pulse_clear();
    clear_acc_i = 1'b1;
    a_in_i      = '0;
    b_in_i      = '0;
    @(posedge clk_i);
    clear_acc_i = 1'b0;
  endtask

  initial begin
    clk_i       = 1'b0;
    rst_ni      = 1'b0;
    clear_acc_i = 1'b0;
    en_i        = 1'b1;
    a_in_i      = '0;
    b_in_i      = '0;

    repeat (2) @(posedge clk_i);
    rst_ni = 1'b1;
    @(posedge clk_i);
    #1 check_acc(0, "reset: acc_o=0");

    // Case tay: tich luy lien tiep khong clear giua cac buoc
    pulse_clear();
    #1 check_acc(0, "clear_acc: acc_o=0");

    do_mac(3, 4);
    #1 check_acc(12, "(3,4) acc=12");
    #1 check_pass_through(3, 4, "(3,4) pass-through 1 cycle sau");

    do_mac(-3, 4);
    #1 check_acc(12 + (-12), "(-3,4) acc=0 (12-12)");

    do_mac(-3, -4);
    #1 check_acc(0 + 12, "(-3,-4) acc=12 (0+12)");

    // Case bien: min int8 * min int8
    pulse_clear();
    #1 check_acc(0, "clear_acc truoc case bien min");

    do_mac(-128, -128);
    #1 check_acc(16384, "(-128,-128) acc=16384, khong tran");

    // Case bien: max int8 * max int8
    pulse_clear();
    #1 check_acc(0, "clear_acc truoc case bien max");

    do_mac(127, 127);
    #1 check_acc(16129, "(127,127) acc=16129, khong tran");

    $display("========================================");
    $display("tb_pe: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0) $display("tb_pe: ALL TESTS PASSED");
    else $display("tb_pe: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
