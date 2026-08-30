`timescale 1ns / 1ps

module tb_systolic_pe_array;

  localparam int ARR_SIZE = 32;
  localparam int DATA_W   = 8;
  localparam int ACC_W    = 32;
  // [Bugfix B2] Bo dac cach row/col==0 khong tre trong SYSTOLIC_PE_ARRAY - moi
  // hang/cot deu qua dung 1 tang thanh ghi (do tre = row+1/col+1), fill tang 63->64.
  localparam int FILL     = 2 * ARR_SIZE;    // 64
  localparam int LATENCY  = FILL + ARR_SIZE; // 96, cho tile K=ARR_SIZE
  localparam time CLK_PERIOD = 10ns;

  logic                     clk_i;
  logic                     rst_ni;
  logic                     clear_acc_i;
  logic                     en_i;
  logic signed [DATA_W-1:0] a_row_i [ARR_SIZE];
  logic signed [DATA_W-1:0] b_col_i [ARR_SIZE];
  logic signed [ACC_W-1:0]  acc_o   [ARR_SIZE][ARR_SIZE];

  int pass_count = 0;
  int fail_count = 0;

  SYSTOLIC_PE_ARRAY #(
    .ARR_SIZE (ARR_SIZE),
    .DATA_W   (DATA_W),
    .ACC_W    (ACC_W)
  ) dut (
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),
    .clear_acc_i (clear_acc_i),
    .en_i        (en_i),
    .a_row_i     (a_row_i),
    .b_col_i     (b_col_i),
    .acc_o       (acc_o)
  );

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // Chay 1 tile A[ARR_SIZE][ARR_SIZE] x B[ARR_SIZE][ARR_SIZE], so acc_o voi expected tinh tay.
  // debug_print: bat tam $display 10 cycle dau de chan doan bug hang0/cot0 (xem
  // 01_design/docs/task.md muc B2 "BUG THAT") - chi bat cho case "Tile ngau nhien",
  // khong sua RTL, se bo lai sau khi Design xac dinh xong nguyen nhan.
  task automatic run_tile(
      input logic signed [DATA_W-1:0] a_mat [ARR_SIZE][ARR_SIZE],
      input logic signed [DATA_W-1:0] b_mat [ARR_SIZE][ARR_SIZE],
      input string tag,
      input bit debug_print = 1'b0
  );
    logic signed [ACC_W-1:0] expected [ARR_SIZE][ARR_SIZE];
    int row, col, k;
    int t;
    int mismatch;

    // Tinh expected = A * B (tuong duong np.matmul), tinh tay bang vong lap.
    for (row = 0; row < ARR_SIZE; row++) begin
      for (col = 0; col < ARR_SIZE; col++) begin
        expected[row][col] = '0;
        for (k = 0; k < ARR_SIZE; k++) begin
          expected[row][col] = expected[row][col] +
              (ACC_W'(a_mat[row][k]) * ACC_W'(b_mat[k][col]));
        end
      end
    end

    // [Bugfix B2 - "BUG MOI"] Tach rieng pha "clear" khoi pha "nap du lieu k=0 that":
    // pulse clear_acc_i o 1 cycle rieng, du lieu con la 0, TRUOC khi bat dau vong lap
    // nap a_mat[row][0]/b_mat[0][col] that o t=0 - khong con trung cycle voi en_i+data
    // k=0 nhu truoc (gay mat so hang k=0 do clear "nuot" dung luc PE(0,0) tinh). Giao
    // thuc moi ap dung cho moi driver cua SYSTOLIC_PE_ARRAY (xem 01_design/docs/task.md
    // muc B2).
    for (row = 0; row < ARR_SIZE; row++) a_row_i[row] = '0;
    for (col = 0; col < ARR_SIZE; col++) b_col_i[col] = '0;
    clear_acc_i = 1'b1;
    en_i        = 1'b1;
    @(posedge clk_i);
    clear_acc_i = 1'b0;

    for (t = 0; t < LATENCY; t++) begin
      if (t < ARR_SIZE) begin
        for (row = 0; row < ARR_SIZE; row++) a_row_i[row] = a_mat[row][t];
        for (col = 0; col < ARR_SIZE; col++) b_col_i[col] = b_mat[t][col];
      end else begin
        for (row = 0; row < ARR_SIZE; row++) a_row_i[row] = '0;
        for (col = 0; col < ARR_SIZE; col++) b_col_i[col] = '0;
      end
      en_i        = 1'b1;
      @(posedge clk_i);
      // Full trace tu t=0 den khi on dinh (~t=36) - cung style voi trace acc01 da
      // gui truoc do, phuc vu doi chieu tay Sum a_rand[0][k]*b_rand[k][0] cho PE(0,0).
      if (debug_print && t <= 36) begin
        $display("[DEBUG] t=%0d clear=%b a_entry0=%0d b_entry0=%0d a_link00=%0d b_link00=%0d acc00=%0d",
                  t, dut.clear_acc_i, dut.a_entry[0], dut.b_entry[0],
                  dut.a_link[0][0], dut.b_link[0][0], dut.acc_o[0][0]);
      end
      // Khoang t=28..35 (thay vi 10 cycle dau) - PE(0,1) can du lieu nhan k tang dan
      // (~mat qua thanh ghi tre 1 tang tu b_entry[1]) de doi chieu chuoi tinh tay
      // A00xB01 + A01xB11 + ... - xem yeu cau Design/nguoi dung.
      if (debug_print && t >= 28 && t <= 35) begin
        $display("[DEBUG01] t=%0d clear=%b a_link01=%0d b_link01=%0d acc01=%0d",
                  t, dut.clear_acc_i, dut.a_link[0][1], dut.b_link[0][1], dut.acc_o[0][1]);
      end
    end
    clear_acc_i = 1'b0;
    #1;

    mismatch = 0;
    for (row = 0; row < ARR_SIZE; row++) begin
      for (col = 0; col < ARR_SIZE; col++) begin
        if (acc_o[row][col] !== expected[row][col]) begin
          mismatch++;
          $display("[FAIL] %s: acc_o[%0d][%0d]=%0d (expected %0d)",
                    tag, row, col, acc_o[row][col], expected[row][col]);
        end
      end
    end

    if (mismatch == 0) begin
      pass_count++;
      $display("[PASS] %s: toan bo %0dx%0d phan tu khop expected", tag, ARR_SIZE, ARR_SIZE);
    end else begin
      fail_count++;
      $display("[FAIL] %s: %0d/%0d phan tu sai", tag, mismatch, ARR_SIZE * ARR_SIZE);
    end
  endtask

  task automatic reset_dut();
    rst_ni      = 1'b0;
    en_i        = 1'b0;
    clear_acc_i = 1'b0;
    for (int i = 0; i < ARR_SIZE; i++) begin
      a_row_i[i] = '0;
      b_col_i[i] = '0;
    end
    repeat (2) @(posedge clk_i);
    rst_ni = 1'b1;
    @(posedge clk_i);
  endtask

  logic signed [DATA_W-1:0] a_rand [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] b_rand [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] a_zero [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] b_zero [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] a_min  [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] b_min  [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] a_max  [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] b_max  [ARR_SIZE][ARR_SIZE];

  initial begin
    clk_i = 1'b0;

    // Seed co dinh, tile 32x32 ngau nhien.
    $srandom(32'hC0FFEE);
    for (int i = 0; i < ARR_SIZE; i++) begin
      for (int j = 0; j < ARR_SIZE; j++) begin
        a_rand[i][j] = $random;
        b_rand[i][j] = $random;
        a_zero[i][j] = '0;
        b_zero[i][j] = '0;
        a_min[i][j]  = -128;
        b_min[i][j]  = -128;
        a_max[i][j]  = 127;
        b_max[i][j]  = 127;
      end
    end

    // In 1 lan duy nhat (khong phai moi cycle) toan bo du lieu goc dung cho o [0][1],
    // de doi chieu tay Sum a_rand[0][k]*b_rand[k][1] voi expected[0][1] va acc_o[0][1]
    // that - xem yeu cau Design.
    for (int k = 0; k < ARR_SIZE; k++)
      $display("a_rand[0][%0d]=%0d b_rand[%0d][1]=%0d", k, a_rand[0][k], k, b_rand[k][1]);

    // b_rand[0..31][0] (cot 0 cua B) - can them de doi chieu tay Sum a_rand[0][k]*
    // b_rand[k][0] cho o [0][0] (PE(0,0)), cung yeu cau voi trace acc00 day du ben duoi.
    for (int k = 0; k < ARR_SIZE; k++)
      $display("b_rand[%0d][0]=%0d", k, b_rand[k][0]);

    reset_dut();
    run_tile(a_rand, b_rand, "Tile 32x32 ngau nhien (seed 0xC0FFEE)", 1'b1);

    reset_dut();
    run_tile(a_zero, b_zero, "Tile toan 0");

    reset_dut();
    run_tile(a_min, b_min, "Tile bien: A=B=-128 (min int8)");

    reset_dut();
    run_tile(a_max, b_max, "Tile bien: A=B=127 (max int8)");

    $display("========================================");
    $display("tb_systolic_pe_array: %0d PASS, %0d FAIL (latency dung = %0d cycle)",
              pass_count, fail_count, LATENCY);
    if (fail_count == 0) $display("tb_systolic_pe_array: ALL TESTS PASSED");
    else $display("tb_systolic_pe_array: SOME TESTS FAILED");
    $display("========================================");

    $finish;
  end

endmodule
