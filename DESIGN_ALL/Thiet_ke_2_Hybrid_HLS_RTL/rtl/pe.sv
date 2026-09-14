module PE #(
  parameter int DATA_W = 8,
  parameter int ACC_W  = 32
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  input  logic                     clear_acc_i,
  input  logic                     en_i,
  input  logic signed [DATA_W-1:0] a_in_i,
  input  logic signed [DATA_W-1:0] b_in_i,
  output logic signed [DATA_W-1:0] a_out_o,
  output logic signed [DATA_W-1:0] b_out_o,
  output logic signed [ACC_W-1:0]  acc_o
);

  logic signed [DATA_W-1:0] a_pass_d, a_pass_q;
  logic signed [DATA_W-1:0] b_pass_d, b_pass_q;
  logic signed [ACC_W-1:0]  acc_d;
  // Reset đồng bộ (xem docs/task.md mục B1) + ép map DSP48E2: DSP slice
  // (UG579) chỉ có chân reset đồng bộ ở cấp thanh ghi ALU/accumulator, nên
  // acc_q phải dùng always_ff không có negedge rst_ni trong sensitivity list.
  (* use_dsp = "yes" *) logic signed [ACC_W-1:0] acc_q;

  always_comb begin
    a_pass_d = a_in_i;
    b_pass_d = b_in_i;
    if (clear_acc_i)
      acc_d = '0;
    else if (en_i)
      acc_d = acc_q + (a_in_i * b_in_i);
    else
      acc_d = acc_q;
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      a_pass_q <= '0;
      b_pass_q <= '0;
      acc_q    <= '0;
    end else begin
      a_pass_q <= a_pass_d;
      b_pass_q <= b_pass_d;
      acc_q    <= acc_d;
    end
  end

  assign a_out_o = a_pass_q;
  assign b_out_o = b_pass_q;
  assign acc_o   = acc_q;

endmodule
