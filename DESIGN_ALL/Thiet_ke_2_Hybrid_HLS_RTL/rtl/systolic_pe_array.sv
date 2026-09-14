module SYSTOLIC_PE_ARRAY #(
  parameter int ARR_SIZE = 32,
  parameter int DATA_W   = 8,
  parameter int ACC_W    = 32
) (
  input  logic                     clk_i,
  // Reset đồng bộ (xem docs/task.md mục B1, comment đầy đủ ở
  // systolic_core_top.sv) — always_ff bên dưới chỉ nhạy cạnh clk_i.
  input  logic                     rst_ni,
  input  logic                     clear_acc_i,
  input  logic                     en_i,
  input  logic signed [DATA_W-1:0] a_row_i [ARR_SIZE],
  input  logic signed [DATA_W-1:0] b_col_i [ARR_SIZE],
  output logic signed [ACC_W-1:0]  acc_o   [ARR_SIZE][ARR_SIZE]
);

  // [Bugfix — xem docs/task.md mục B2, docs/modules/systolic_pe_array.md]
  // Bản trước có 2 nhánh đặc cách row==0/col==0 nối tổ hợp thuần (KHÔNG qua
  // thanh ghi), trong khi mọi hàng/cột khác qua ít nhất 1 tầng thanh ghi.
  // Chứng minh bằng số: PE(0,col>0) ghép nhầm a[k] với b[k+1] (lệch 1 cycle)
  // — Σa[k]·b[k]=23123 (đúng golden) nhưng RTL xuất Σa[k]·b[k+1]=-19947 (31
  // số hạng, mất hẳn b[0] và a[31]). Nguyên nhân: đường tổ hợp thuần
  // (assign) và đường thanh ghi (a_shift_q có điều kiện en_i, hay a_pass_q
  // trong PE vô điều kiện) là 2-3 loại mạch khác nhau, dễ lệch 1 cycle dù
  // đếm số tầng trên giấy ra khớp nhau.
  //
  // Sửa: BỎ HẲN nhánh đặc cách "không trễ" — mọi hàng/cột (kể cả 0) đều đi
  // qua CÙNG 1 loại thanh ghi (a_shift_q/b_shift_q), độ trễ = row+1 / col+1
  // (thay vì row/col cũ). Cái giá: fill latency tăng 63→64 cycle — ĐÃ sửa
  // đồng bộ `ACC_CYCLES` trong systolic_core_top.sv, không được sửa file này
  // mà quên sửa file kia (tile_done_o sẽ phát sớm 1 cycle, cắt mất phép
  // tích lũy cuối).
  localparam int SKEW_DEPTH = ARR_SIZE;

  // Skew: hàng/cột thứ n cần trễ (n+1) cycle trước khi vào rìa mảng — kể cả
  // n=0 cũng qua đúng 1 tầng thanh ghi, không còn đường tổ hợp thuần nào.
  logic signed [DATA_W-1:0] a_shift_q [ARR_SIZE][SKEW_DEPTH];
  logic signed [DATA_W-1:0] b_shift_q [ARR_SIZE][SKEW_DEPTH];
  logic signed [DATA_W-1:0] a_entry   [ARR_SIZE];
  logic signed [DATA_W-1:0] b_entry   [ARR_SIZE];

  genvar row, col, stage;

  generate
    for (row = 0; row < ARR_SIZE; row++) begin : gen_a_skew
      always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
          a_shift_q[row][0] <= '0;
        end else if (en_i) begin
          a_shift_q[row][0] <= a_row_i[row];
        end
      end
      for (stage = 1; stage <= row; stage++) begin : gen_a_stage
        always_ff @(posedge clk_i) begin
          if (!rst_ni) begin
            a_shift_q[row][stage] <= '0;
          end else if (en_i) begin
            a_shift_q[row][stage] <= a_shift_q[row][stage-1];
          end
        end
      end
      assign a_entry[row] = a_shift_q[row][row];
    end

    for (col = 0; col < ARR_SIZE; col++) begin : gen_b_skew
      always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
          b_shift_q[col][0] <= '0;
        end else if (en_i) begin
          b_shift_q[col][0] <= b_col_i[col];
        end
      end
      for (stage = 1; stage <= col; stage++) begin : gen_b_stage
        always_ff @(posedge clk_i) begin
          if (!rst_ni) begin
            b_shift_q[col][stage] <= '0;
          end else if (en_i) begin
            b_shift_q[col][stage] <= b_shift_q[col][stage-1];
          end
        end
      end
      assign b_entry[col] = b_shift_q[col][col];
    end
  endgenerate

  logic signed [DATA_W-1:0] a_link    [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] b_link    [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] a_out_grid [ARR_SIZE][ARR_SIZE];
  logic signed [DATA_W-1:0] b_out_grid [ARR_SIZE][ARR_SIZE];

  generate
    for (row = 0; row < ARR_SIZE; row++) begin : gen_row
      for (col = 0; col < ARR_SIZE; col++) begin : gen_col
        assign a_link[row][col] = (col == 0) ? a_entry[row] : a_out_grid[row][col-1];
        assign b_link[row][col] = (row == 0) ? b_entry[col] : b_out_grid[row-1][col];

        PE #(
          .DATA_W (DATA_W),
          .ACC_W  (ACC_W)
        ) u_pe (
          .clk_i        (clk_i),
          .rst_ni       (rst_ni),
          .clear_acc_i  (clear_acc_i),
          .en_i         (en_i),
          .a_in_i       (a_link[row][col]),
          .b_in_i       (b_link[row][col]),
          .a_out_o      (a_out_grid[row][col]),
          .b_out_o      (b_out_grid[row][col]),
          .acc_o        (acc_o[row][col])
        );
      end
    end
  endgenerate

endmodule
