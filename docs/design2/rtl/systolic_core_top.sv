module SYSTOLIC_CORE_TOP #(
  parameter int ARR_SIZE = 32,
  parameter int A_ROWS   = 64,
  parameter int DATA_W   = 8,
  parameter int ACC_W    = 32,
  parameter int K_DEPTH  = 768
) (
  input  logic clk_i,
  // Reset đồng bộ (xem docs/task.md mục B1): mọi always_ff trong file này/
  // SYSTOLIC_PE_ARRAY/PE chỉ nhạy cạnh clk_i, không còn "or negedge rst_ni"
  // — bắt buộc để PE.acc_q map được vào DSP48E2 (UG579: DSP slice không có
  // chân reset bất đồng bộ). Nguồn rst_ni đã được đồng bộ hoá sẵn từ
  // rst_ps8_0_99M (Processor System Reset) ở Block Design D1, không cần
  // thêm synchronizer nào trong module này.
  input  logic rst_ni,

  input  logic tile_valid_i,
  output logic tile_ready_o,
  output logic tile_done_o,

  input  logic       tile_i_sel_i,
  input  logic [2:0] tile_j_sel_i,

  // [Sửa lỗi lệch kiểu cổng — xem docs/feedback_to_spec.md/task.md D1] Vitis HLS
  // xuất a_bank0..63/b_bank0..31 thành 64/32 bộ cổng phẳng riêng biệt (vì đó
  // là 64/32 tham số C++ riêng biệt), không phải 1 cổng mảng — Vivado IP
  // Integrator không nối được cổng mảng unpacked SV với các cổng phẳng đó.
  // Đổi toàn bộ A/B sang cổng phẳng đặt tên riêng, khớp 1-1 với HLS.
  output logic [9:0]              bram_a0_addr_o,
  output logic                    bram_a0_en_o,
  input  logic signed [DATA_W-1:0] bram_a0_dout_i,
  output logic [9:0]              bram_a1_addr_o,
  output logic                    bram_a1_en_o,
  input  logic signed [DATA_W-1:0] bram_a1_dout_i,
  output logic [9:0]              bram_a2_addr_o,
  output logic                    bram_a2_en_o,
  input  logic signed [DATA_W-1:0] bram_a2_dout_i,
  output logic [9:0]              bram_a3_addr_o,
  output logic                    bram_a3_en_o,
  input  logic signed [DATA_W-1:0] bram_a3_dout_i,
  output logic [9:0]              bram_a4_addr_o,
  output logic                    bram_a4_en_o,
  input  logic signed [DATA_W-1:0] bram_a4_dout_i,
  output logic [9:0]              bram_a5_addr_o,
  output logic                    bram_a5_en_o,
  input  logic signed [DATA_W-1:0] bram_a5_dout_i,
  output logic [9:0]              bram_a6_addr_o,
  output logic                    bram_a6_en_o,
  input  logic signed [DATA_W-1:0] bram_a6_dout_i,
  output logic [9:0]              bram_a7_addr_o,
  output logic                    bram_a7_en_o,
  input  logic signed [DATA_W-1:0] bram_a7_dout_i,
  output logic [9:0]              bram_a8_addr_o,
  output logic                    bram_a8_en_o,
  input  logic signed [DATA_W-1:0] bram_a8_dout_i,
  output logic [9:0]              bram_a9_addr_o,
  output logic                    bram_a9_en_o,
  input  logic signed [DATA_W-1:0] bram_a9_dout_i,
  output logic [9:0]              bram_a10_addr_o,
  output logic                    bram_a10_en_o,
  input  logic signed [DATA_W-1:0] bram_a10_dout_i,
  output logic [9:0]              bram_a11_addr_o,
  output logic                    bram_a11_en_o,
  input  logic signed [DATA_W-1:0] bram_a11_dout_i,
  output logic [9:0]              bram_a12_addr_o,
  output logic                    bram_a12_en_o,
  input  logic signed [DATA_W-1:0] bram_a12_dout_i,
  output logic [9:0]              bram_a13_addr_o,
  output logic                    bram_a13_en_o,
  input  logic signed [DATA_W-1:0] bram_a13_dout_i,
  output logic [9:0]              bram_a14_addr_o,
  output logic                    bram_a14_en_o,
  input  logic signed [DATA_W-1:0] bram_a14_dout_i,
  output logic [9:0]              bram_a15_addr_o,
  output logic                    bram_a15_en_o,
  input  logic signed [DATA_W-1:0] bram_a15_dout_i,
  output logic [9:0]              bram_a16_addr_o,
  output logic                    bram_a16_en_o,
  input  logic signed [DATA_W-1:0] bram_a16_dout_i,
  output logic [9:0]              bram_a17_addr_o,
  output logic                    bram_a17_en_o,
  input  logic signed [DATA_W-1:0] bram_a17_dout_i,
  output logic [9:0]              bram_a18_addr_o,
  output logic                    bram_a18_en_o,
  input  logic signed [DATA_W-1:0] bram_a18_dout_i,
  output logic [9:0]              bram_a19_addr_o,
  output logic                    bram_a19_en_o,
  input  logic signed [DATA_W-1:0] bram_a19_dout_i,
  output logic [9:0]              bram_a20_addr_o,
  output logic                    bram_a20_en_o,
  input  logic signed [DATA_W-1:0] bram_a20_dout_i,
  output logic [9:0]              bram_a21_addr_o,
  output logic                    bram_a21_en_o,
  input  logic signed [DATA_W-1:0] bram_a21_dout_i,
  output logic [9:0]              bram_a22_addr_o,
  output logic                    bram_a22_en_o,
  input  logic signed [DATA_W-1:0] bram_a22_dout_i,
  output logic [9:0]              bram_a23_addr_o,
  output logic                    bram_a23_en_o,
  input  logic signed [DATA_W-1:0] bram_a23_dout_i,
  output logic [9:0]              bram_a24_addr_o,
  output logic                    bram_a24_en_o,
  input  logic signed [DATA_W-1:0] bram_a24_dout_i,
  output logic [9:0]              bram_a25_addr_o,
  output logic                    bram_a25_en_o,
  input  logic signed [DATA_W-1:0] bram_a25_dout_i,
  output logic [9:0]              bram_a26_addr_o,
  output logic                    bram_a26_en_o,
  input  logic signed [DATA_W-1:0] bram_a26_dout_i,
  output logic [9:0]              bram_a27_addr_o,
  output logic                    bram_a27_en_o,
  input  logic signed [DATA_W-1:0] bram_a27_dout_i,
  output logic [9:0]              bram_a28_addr_o,
  output logic                    bram_a28_en_o,
  input  logic signed [DATA_W-1:0] bram_a28_dout_i,
  output logic [9:0]              bram_a29_addr_o,
  output logic                    bram_a29_en_o,
  input  logic signed [DATA_W-1:0] bram_a29_dout_i,
  output logic [9:0]              bram_a30_addr_o,
  output logic                    bram_a30_en_o,
  input  logic signed [DATA_W-1:0] bram_a30_dout_i,
  output logic [9:0]              bram_a31_addr_o,
  output logic                    bram_a31_en_o,
  input  logic signed [DATA_W-1:0] bram_a31_dout_i,
  output logic [9:0]              bram_a32_addr_o,
  output logic                    bram_a32_en_o,
  input  logic signed [DATA_W-1:0] bram_a32_dout_i,
  output logic [9:0]              bram_a33_addr_o,
  output logic                    bram_a33_en_o,
  input  logic signed [DATA_W-1:0] bram_a33_dout_i,
  output logic [9:0]              bram_a34_addr_o,
  output logic                    bram_a34_en_o,
  input  logic signed [DATA_W-1:0] bram_a34_dout_i,
  output logic [9:0]              bram_a35_addr_o,
  output logic                    bram_a35_en_o,
  input  logic signed [DATA_W-1:0] bram_a35_dout_i,
  output logic [9:0]              bram_a36_addr_o,
  output logic                    bram_a36_en_o,
  input  logic signed [DATA_W-1:0] bram_a36_dout_i,
  output logic [9:0]              bram_a37_addr_o,
  output logic                    bram_a37_en_o,
  input  logic signed [DATA_W-1:0] bram_a37_dout_i,
  output logic [9:0]              bram_a38_addr_o,
  output logic                    bram_a38_en_o,
  input  logic signed [DATA_W-1:0] bram_a38_dout_i,
  output logic [9:0]              bram_a39_addr_o,
  output logic                    bram_a39_en_o,
  input  logic signed [DATA_W-1:0] bram_a39_dout_i,
  output logic [9:0]              bram_a40_addr_o,
  output logic                    bram_a40_en_o,
  input  logic signed [DATA_W-1:0] bram_a40_dout_i,
  output logic [9:0]              bram_a41_addr_o,
  output logic                    bram_a41_en_o,
  input  logic signed [DATA_W-1:0] bram_a41_dout_i,
  output logic [9:0]              bram_a42_addr_o,
  output logic                    bram_a42_en_o,
  input  logic signed [DATA_W-1:0] bram_a42_dout_i,
  output logic [9:0]              bram_a43_addr_o,
  output logic                    bram_a43_en_o,
  input  logic signed [DATA_W-1:0] bram_a43_dout_i,
  output logic [9:0]              bram_a44_addr_o,
  output logic                    bram_a44_en_o,
  input  logic signed [DATA_W-1:0] bram_a44_dout_i,
  output logic [9:0]              bram_a45_addr_o,
  output logic                    bram_a45_en_o,
  input  logic signed [DATA_W-1:0] bram_a45_dout_i,
  output logic [9:0]              bram_a46_addr_o,
  output logic                    bram_a46_en_o,
  input  logic signed [DATA_W-1:0] bram_a46_dout_i,
  output logic [9:0]              bram_a47_addr_o,
  output logic                    bram_a47_en_o,
  input  logic signed [DATA_W-1:0] bram_a47_dout_i,
  output logic [9:0]              bram_a48_addr_o,
  output logic                    bram_a48_en_o,
  input  logic signed [DATA_W-1:0] bram_a48_dout_i,
  output logic [9:0]              bram_a49_addr_o,
  output logic                    bram_a49_en_o,
  input  logic signed [DATA_W-1:0] bram_a49_dout_i,
  output logic [9:0]              bram_a50_addr_o,
  output logic                    bram_a50_en_o,
  input  logic signed [DATA_W-1:0] bram_a50_dout_i,
  output logic [9:0]              bram_a51_addr_o,
  output logic                    bram_a51_en_o,
  input  logic signed [DATA_W-1:0] bram_a51_dout_i,
  output logic [9:0]              bram_a52_addr_o,
  output logic                    bram_a52_en_o,
  input  logic signed [DATA_W-1:0] bram_a52_dout_i,
  output logic [9:0]              bram_a53_addr_o,
  output logic                    bram_a53_en_o,
  input  logic signed [DATA_W-1:0] bram_a53_dout_i,
  output logic [9:0]              bram_a54_addr_o,
  output logic                    bram_a54_en_o,
  input  logic signed [DATA_W-1:0] bram_a54_dout_i,
  output logic [9:0]              bram_a55_addr_o,
  output logic                    bram_a55_en_o,
  input  logic signed [DATA_W-1:0] bram_a55_dout_i,
  output logic [9:0]              bram_a56_addr_o,
  output logic                    bram_a56_en_o,
  input  logic signed [DATA_W-1:0] bram_a56_dout_i,
  output logic [9:0]              bram_a57_addr_o,
  output logic                    bram_a57_en_o,
  input  logic signed [DATA_W-1:0] bram_a57_dout_i,
  output logic [9:0]              bram_a58_addr_o,
  output logic                    bram_a58_en_o,
  input  logic signed [DATA_W-1:0] bram_a58_dout_i,
  output logic [9:0]              bram_a59_addr_o,
  output logic                    bram_a59_en_o,
  input  logic signed [DATA_W-1:0] bram_a59_dout_i,
  output logic [9:0]              bram_a60_addr_o,
  output logic                    bram_a60_en_o,
  input  logic signed [DATA_W-1:0] bram_a60_dout_i,
  output logic [9:0]              bram_a61_addr_o,
  output logic                    bram_a61_en_o,
  input  logic signed [DATA_W-1:0] bram_a61_dout_i,
  output logic [9:0]              bram_a62_addr_o,
  output logic                    bram_a62_en_o,
  input  logic signed [DATA_W-1:0] bram_a62_dout_i,
  output logic [9:0]              bram_a63_addr_o,
  output logic                    bram_a63_en_o,
  input  logic signed [DATA_W-1:0] bram_a63_dout_i,

  output logic [12:0]             bram_b0_addr_o,
  output logic                    bram_b0_en_o,
  input  logic signed [DATA_W-1:0] bram_b0_dout_i,
  output logic [12:0]             bram_b1_addr_o,
  output logic                    bram_b1_en_o,
  input  logic signed [DATA_W-1:0] bram_b1_dout_i,
  output logic [12:0]             bram_b2_addr_o,
  output logic                    bram_b2_en_o,
  input  logic signed [DATA_W-1:0] bram_b2_dout_i,
  output logic [12:0]             bram_b3_addr_o,
  output logic                    bram_b3_en_o,
  input  logic signed [DATA_W-1:0] bram_b3_dout_i,
  output logic [12:0]             bram_b4_addr_o,
  output logic                    bram_b4_en_o,
  input  logic signed [DATA_W-1:0] bram_b4_dout_i,
  output logic [12:0]             bram_b5_addr_o,
  output logic                    bram_b5_en_o,
  input  logic signed [DATA_W-1:0] bram_b5_dout_i,
  output logic [12:0]             bram_b6_addr_o,
  output logic                    bram_b6_en_o,
  input  logic signed [DATA_W-1:0] bram_b6_dout_i,
  output logic [12:0]             bram_b7_addr_o,
  output logic                    bram_b7_en_o,
  input  logic signed [DATA_W-1:0] bram_b7_dout_i,
  output logic [12:0]             bram_b8_addr_o,
  output logic                    bram_b8_en_o,
  input  logic signed [DATA_W-1:0] bram_b8_dout_i,
  output logic [12:0]             bram_b9_addr_o,
  output logic                    bram_b9_en_o,
  input  logic signed [DATA_W-1:0] bram_b9_dout_i,
  output logic [12:0]             bram_b10_addr_o,
  output logic                    bram_b10_en_o,
  input  logic signed [DATA_W-1:0] bram_b10_dout_i,
  output logic [12:0]             bram_b11_addr_o,
  output logic                    bram_b11_en_o,
  input  logic signed [DATA_W-1:0] bram_b11_dout_i,
  output logic [12:0]             bram_b12_addr_o,
  output logic                    bram_b12_en_o,
  input  logic signed [DATA_W-1:0] bram_b12_dout_i,
  output logic [12:0]             bram_b13_addr_o,
  output logic                    bram_b13_en_o,
  input  logic signed [DATA_W-1:0] bram_b13_dout_i,
  output logic [12:0]             bram_b14_addr_o,
  output logic                    bram_b14_en_o,
  input  logic signed [DATA_W-1:0] bram_b14_dout_i,
  output logic [12:0]             bram_b15_addr_o,
  output logic                    bram_b15_en_o,
  input  logic signed [DATA_W-1:0] bram_b15_dout_i,
  output logic [12:0]             bram_b16_addr_o,
  output logic                    bram_b16_en_o,
  input  logic signed [DATA_W-1:0] bram_b16_dout_i,
  output logic [12:0]             bram_b17_addr_o,
  output logic                    bram_b17_en_o,
  input  logic signed [DATA_W-1:0] bram_b17_dout_i,
  output logic [12:0]             bram_b18_addr_o,
  output logic                    bram_b18_en_o,
  input  logic signed [DATA_W-1:0] bram_b18_dout_i,
  output logic [12:0]             bram_b19_addr_o,
  output logic                    bram_b19_en_o,
  input  logic signed [DATA_W-1:0] bram_b19_dout_i,
  output logic [12:0]             bram_b20_addr_o,
  output logic                    bram_b20_en_o,
  input  logic signed [DATA_W-1:0] bram_b20_dout_i,
  output logic [12:0]             bram_b21_addr_o,
  output logic                    bram_b21_en_o,
  input  logic signed [DATA_W-1:0] bram_b21_dout_i,
  output logic [12:0]             bram_b22_addr_o,
  output logic                    bram_b22_en_o,
  input  logic signed [DATA_W-1:0] bram_b22_dout_i,
  output logic [12:0]             bram_b23_addr_o,
  output logic                    bram_b23_en_o,
  input  logic signed [DATA_W-1:0] bram_b23_dout_i,
  output logic [12:0]             bram_b24_addr_o,
  output logic                    bram_b24_en_o,
  input  logic signed [DATA_W-1:0] bram_b24_dout_i,
  output logic [12:0]             bram_b25_addr_o,
  output logic                    bram_b25_en_o,
  input  logic signed [DATA_W-1:0] bram_b25_dout_i,
  output logic [12:0]             bram_b26_addr_o,
  output logic                    bram_b26_en_o,
  input  logic signed [DATA_W-1:0] bram_b26_dout_i,
  output logic [12:0]             bram_b27_addr_o,
  output logic                    bram_b27_en_o,
  input  logic signed [DATA_W-1:0] bram_b27_dout_i,
  output logic [12:0]             bram_b28_addr_o,
  output logic                    bram_b28_en_o,
  input  logic signed [DATA_W-1:0] bram_b28_dout_i,
  output logic [12:0]             bram_b29_addr_o,
  output logic                    bram_b29_en_o,
  input  logic signed [DATA_W-1:0] bram_b29_dout_i,
  output logic [12:0]             bram_b30_addr_o,
  output logic                    bram_b30_en_o,
  input  logic signed [DATA_W-1:0] bram_b30_dout_i,
  output logic [12:0]             bram_b31_addr_o,
  output logic                    bram_b31_en_o,
  input  logic signed [DATA_W-1:0] bram_b31_dout_i,

  output logic signed [ACC_W-1:0] c0_0_o,
  output logic signed [ACC_W-1:0] c0_1_o,
  output logic signed [ACC_W-1:0] c0_2_o,
  output logic signed [ACC_W-1:0] c0_3_o,
  output logic signed [ACC_W-1:0] c0_4_o,
  output logic signed [ACC_W-1:0] c0_5_o,
  output logic signed [ACC_W-1:0] c0_6_o,
  output logic signed [ACC_W-1:0] c0_7_o,
  output logic signed [ACC_W-1:0] c0_8_o,
  output logic signed [ACC_W-1:0] c0_9_o,
  output logic signed [ACC_W-1:0] c0_10_o,
  output logic signed [ACC_W-1:0] c0_11_o,
  output logic signed [ACC_W-1:0] c0_12_o,
  output logic signed [ACC_W-1:0] c0_13_o,
  output logic signed [ACC_W-1:0] c0_14_o,
  output logic signed [ACC_W-1:0] c0_15_o,
  output logic signed [ACC_W-1:0] c0_16_o,
  output logic signed [ACC_W-1:0] c0_17_o,
  output logic signed [ACC_W-1:0] c0_18_o,
  output logic signed [ACC_W-1:0] c0_19_o,
  output logic signed [ACC_W-1:0] c0_20_o,
  output logic signed [ACC_W-1:0] c0_21_o,
  output logic signed [ACC_W-1:0] c0_22_o,
  output logic signed [ACC_W-1:0] c0_23_o,
  output logic signed [ACC_W-1:0] c0_24_o,
  output logic signed [ACC_W-1:0] c0_25_o,
  output logic signed [ACC_W-1:0] c0_26_o,
  output logic signed [ACC_W-1:0] c0_27_o,
  output logic signed [ACC_W-1:0] c0_28_o,
  output logic signed [ACC_W-1:0] c0_29_o,
  output logic signed [ACC_W-1:0] c0_30_o,
  output logic signed [ACC_W-1:0] c0_31_o,
  output logic signed [ACC_W-1:0] c1_0_o,
  output logic signed [ACC_W-1:0] c1_1_o,
  output logic signed [ACC_W-1:0] c1_2_o,
  output logic signed [ACC_W-1:0] c1_3_o,
  output logic signed [ACC_W-1:0] c1_4_o,
  output logic signed [ACC_W-1:0] c1_5_o,
  output logic signed [ACC_W-1:0] c1_6_o,
  output logic signed [ACC_W-1:0] c1_7_o,
  output logic signed [ACC_W-1:0] c1_8_o,
  output logic signed [ACC_W-1:0] c1_9_o,
  output logic signed [ACC_W-1:0] c1_10_o,
  output logic signed [ACC_W-1:0] c1_11_o,
  output logic signed [ACC_W-1:0] c1_12_o,
  output logic signed [ACC_W-1:0] c1_13_o,
  output logic signed [ACC_W-1:0] c1_14_o,
  output logic signed [ACC_W-1:0] c1_15_o,
  output logic signed [ACC_W-1:0] c1_16_o,
  output logic signed [ACC_W-1:0] c1_17_o,
  output logic signed [ACC_W-1:0] c1_18_o,
  output logic signed [ACC_W-1:0] c1_19_o,
  output logic signed [ACC_W-1:0] c1_20_o,
  output logic signed [ACC_W-1:0] c1_21_o,
  output logic signed [ACC_W-1:0] c1_22_o,
  output logic signed [ACC_W-1:0] c1_23_o,
  output logic signed [ACC_W-1:0] c1_24_o,
  output logic signed [ACC_W-1:0] c1_25_o,
  output logic signed [ACC_W-1:0] c1_26_o,
  output logic signed [ACC_W-1:0] c1_27_o,
  output logic signed [ACC_W-1:0] c1_28_o,
  output logic signed [ACC_W-1:0] c1_29_o,
  output logic signed [ACC_W-1:0] c1_30_o,
  output logic signed [ACC_W-1:0] c1_31_o,
  output logic signed [ACC_W-1:0] c2_0_o,
  output logic signed [ACC_W-1:0] c2_1_o,
  output logic signed [ACC_W-1:0] c2_2_o,
  output logic signed [ACC_W-1:0] c2_3_o,
  output logic signed [ACC_W-1:0] c2_4_o,
  output logic signed [ACC_W-1:0] c2_5_o,
  output logic signed [ACC_W-1:0] c2_6_o,
  output logic signed [ACC_W-1:0] c2_7_o,
  output logic signed [ACC_W-1:0] c2_8_o,
  output logic signed [ACC_W-1:0] c2_9_o,
  output logic signed [ACC_W-1:0] c2_10_o,
  output logic signed [ACC_W-1:0] c2_11_o,
  output logic signed [ACC_W-1:0] c2_12_o,
  output logic signed [ACC_W-1:0] c2_13_o,
  output logic signed [ACC_W-1:0] c2_14_o,
  output logic signed [ACC_W-1:0] c2_15_o,
  output logic signed [ACC_W-1:0] c2_16_o,
  output logic signed [ACC_W-1:0] c2_17_o,
  output logic signed [ACC_W-1:0] c2_18_o,
  output logic signed [ACC_W-1:0] c2_19_o,
  output logic signed [ACC_W-1:0] c2_20_o,
  output logic signed [ACC_W-1:0] c2_21_o,
  output logic signed [ACC_W-1:0] c2_22_o,
  output logic signed [ACC_W-1:0] c2_23_o,
  output logic signed [ACC_W-1:0] c2_24_o,
  output logic signed [ACC_W-1:0] c2_25_o,
  output logic signed [ACC_W-1:0] c2_26_o,
  output logic signed [ACC_W-1:0] c2_27_o,
  output logic signed [ACC_W-1:0] c2_28_o,
  output logic signed [ACC_W-1:0] c2_29_o,
  output logic signed [ACC_W-1:0] c2_30_o,
  output logic signed [ACC_W-1:0] c2_31_o,
  output logic signed [ACC_W-1:0] c3_0_o,
  output logic signed [ACC_W-1:0] c3_1_o,
  output logic signed [ACC_W-1:0] c3_2_o,
  output logic signed [ACC_W-1:0] c3_3_o,
  output logic signed [ACC_W-1:0] c3_4_o,
  output logic signed [ACC_W-1:0] c3_5_o,
  output logic signed [ACC_W-1:0] c3_6_o,
  output logic signed [ACC_W-1:0] c3_7_o,
  output logic signed [ACC_W-1:0] c3_8_o,
  output logic signed [ACC_W-1:0] c3_9_o,
  output logic signed [ACC_W-1:0] c3_10_o,
  output logic signed [ACC_W-1:0] c3_11_o,
  output logic signed [ACC_W-1:0] c3_12_o,
  output logic signed [ACC_W-1:0] c3_13_o,
  output logic signed [ACC_W-1:0] c3_14_o,
  output logic signed [ACC_W-1:0] c3_15_o,
  output logic signed [ACC_W-1:0] c3_16_o,
  output logic signed [ACC_W-1:0] c3_17_o,
  output logic signed [ACC_W-1:0] c3_18_o,
  output logic signed [ACC_W-1:0] c3_19_o,
  output logic signed [ACC_W-1:0] c3_20_o,
  output logic signed [ACC_W-1:0] c3_21_o,
  output logic signed [ACC_W-1:0] c3_22_o,
  output logic signed [ACC_W-1:0] c3_23_o,
  output logic signed [ACC_W-1:0] c3_24_o,
  output logic signed [ACC_W-1:0] c3_25_o,
  output logic signed [ACC_W-1:0] c3_26_o,
  output logic signed [ACC_W-1:0] c3_27_o,
  output logic signed [ACC_W-1:0] c3_28_o,
  output logic signed [ACC_W-1:0] c3_29_o,
  output logic signed [ACC_W-1:0] c3_30_o,
  output logic signed [ACC_W-1:0] c3_31_o,
  output logic signed [ACC_W-1:0] c4_0_o,
  output logic signed [ACC_W-1:0] c4_1_o,
  output logic signed [ACC_W-1:0] c4_2_o,
  output logic signed [ACC_W-1:0] c4_3_o,
  output logic signed [ACC_W-1:0] c4_4_o,
  output logic signed [ACC_W-1:0] c4_5_o,
  output logic signed [ACC_W-1:0] c4_6_o,
  output logic signed [ACC_W-1:0] c4_7_o,
  output logic signed [ACC_W-1:0] c4_8_o,
  output logic signed [ACC_W-1:0] c4_9_o,
  output logic signed [ACC_W-1:0] c4_10_o,
  output logic signed [ACC_W-1:0] c4_11_o,
  output logic signed [ACC_W-1:0] c4_12_o,
  output logic signed [ACC_W-1:0] c4_13_o,
  output logic signed [ACC_W-1:0] c4_14_o,
  output logic signed [ACC_W-1:0] c4_15_o,
  output logic signed [ACC_W-1:0] c4_16_o,
  output logic signed [ACC_W-1:0] c4_17_o,
  output logic signed [ACC_W-1:0] c4_18_o,
  output logic signed [ACC_W-1:0] c4_19_o,
  output logic signed [ACC_W-1:0] c4_20_o,
  output logic signed [ACC_W-1:0] c4_21_o,
  output logic signed [ACC_W-1:0] c4_22_o,
  output logic signed [ACC_W-1:0] c4_23_o,
  output logic signed [ACC_W-1:0] c4_24_o,
  output logic signed [ACC_W-1:0] c4_25_o,
  output logic signed [ACC_W-1:0] c4_26_o,
  output logic signed [ACC_W-1:0] c4_27_o,
  output logic signed [ACC_W-1:0] c4_28_o,
  output logic signed [ACC_W-1:0] c4_29_o,
  output logic signed [ACC_W-1:0] c4_30_o,
  output logic signed [ACC_W-1:0] c4_31_o,
  output logic signed [ACC_W-1:0] c5_0_o,
  output logic signed [ACC_W-1:0] c5_1_o,
  output logic signed [ACC_W-1:0] c5_2_o,
  output logic signed [ACC_W-1:0] c5_3_o,
  output logic signed [ACC_W-1:0] c5_4_o,
  output logic signed [ACC_W-1:0] c5_5_o,
  output logic signed [ACC_W-1:0] c5_6_o,
  output logic signed [ACC_W-1:0] c5_7_o,
  output logic signed [ACC_W-1:0] c5_8_o,
  output logic signed [ACC_W-1:0] c5_9_o,
  output logic signed [ACC_W-1:0] c5_10_o,
  output logic signed [ACC_W-1:0] c5_11_o,
  output logic signed [ACC_W-1:0] c5_12_o,
  output logic signed [ACC_W-1:0] c5_13_o,
  output logic signed [ACC_W-1:0] c5_14_o,
  output logic signed [ACC_W-1:0] c5_15_o,
  output logic signed [ACC_W-1:0] c5_16_o,
  output logic signed [ACC_W-1:0] c5_17_o,
  output logic signed [ACC_W-1:0] c5_18_o,
  output logic signed [ACC_W-1:0] c5_19_o,
  output logic signed [ACC_W-1:0] c5_20_o,
  output logic signed [ACC_W-1:0] c5_21_o,
  output logic signed [ACC_W-1:0] c5_22_o,
  output logic signed [ACC_W-1:0] c5_23_o,
  output logic signed [ACC_W-1:0] c5_24_o,
  output logic signed [ACC_W-1:0] c5_25_o,
  output logic signed [ACC_W-1:0] c5_26_o,
  output logic signed [ACC_W-1:0] c5_27_o,
  output logic signed [ACC_W-1:0] c5_28_o,
  output logic signed [ACC_W-1:0] c5_29_o,
  output logic signed [ACC_W-1:0] c5_30_o,
  output logic signed [ACC_W-1:0] c5_31_o,
  output logic signed [ACC_W-1:0] c6_0_o,
  output logic signed [ACC_W-1:0] c6_1_o,
  output logic signed [ACC_W-1:0] c6_2_o,
  output logic signed [ACC_W-1:0] c6_3_o,
  output logic signed [ACC_W-1:0] c6_4_o,
  output logic signed [ACC_W-1:0] c6_5_o,
  output logic signed [ACC_W-1:0] c6_6_o,
  output logic signed [ACC_W-1:0] c6_7_o,
  output logic signed [ACC_W-1:0] c6_8_o,
  output logic signed [ACC_W-1:0] c6_9_o,
  output logic signed [ACC_W-1:0] c6_10_o,
  output logic signed [ACC_W-1:0] c6_11_o,
  output logic signed [ACC_W-1:0] c6_12_o,
  output logic signed [ACC_W-1:0] c6_13_o,
  output logic signed [ACC_W-1:0] c6_14_o,
  output logic signed [ACC_W-1:0] c6_15_o,
  output logic signed [ACC_W-1:0] c6_16_o,
  output logic signed [ACC_W-1:0] c6_17_o,
  output logic signed [ACC_W-1:0] c6_18_o,
  output logic signed [ACC_W-1:0] c6_19_o,
  output logic signed [ACC_W-1:0] c6_20_o,
  output logic signed [ACC_W-1:0] c6_21_o,
  output logic signed [ACC_W-1:0] c6_22_o,
  output logic signed [ACC_W-1:0] c6_23_o,
  output logic signed [ACC_W-1:0] c6_24_o,
  output logic signed [ACC_W-1:0] c6_25_o,
  output logic signed [ACC_W-1:0] c6_26_o,
  output logic signed [ACC_W-1:0] c6_27_o,
  output logic signed [ACC_W-1:0] c6_28_o,
  output logic signed [ACC_W-1:0] c6_29_o,
  output logic signed [ACC_W-1:0] c6_30_o,
  output logic signed [ACC_W-1:0] c6_31_o,
  output logic signed [ACC_W-1:0] c7_0_o,
  output logic signed [ACC_W-1:0] c7_1_o,
  output logic signed [ACC_W-1:0] c7_2_o,
  output logic signed [ACC_W-1:0] c7_3_o,
  output logic signed [ACC_W-1:0] c7_4_o,
  output logic signed [ACC_W-1:0] c7_5_o,
  output logic signed [ACC_W-1:0] c7_6_o,
  output logic signed [ACC_W-1:0] c7_7_o,
  output logic signed [ACC_W-1:0] c7_8_o,
  output logic signed [ACC_W-1:0] c7_9_o,
  output logic signed [ACC_W-1:0] c7_10_o,
  output logic signed [ACC_W-1:0] c7_11_o,
  output logic signed [ACC_W-1:0] c7_12_o,
  output logic signed [ACC_W-1:0] c7_13_o,
  output logic signed [ACC_W-1:0] c7_14_o,
  output logic signed [ACC_W-1:0] c7_15_o,
  output logic signed [ACC_W-1:0] c7_16_o,
  output logic signed [ACC_W-1:0] c7_17_o,
  output logic signed [ACC_W-1:0] c7_18_o,
  output logic signed [ACC_W-1:0] c7_19_o,
  output logic signed [ACC_W-1:0] c7_20_o,
  output logic signed [ACC_W-1:0] c7_21_o,
  output logic signed [ACC_W-1:0] c7_22_o,
  output logic signed [ACC_W-1:0] c7_23_o,
  output logic signed [ACC_W-1:0] c7_24_o,
  output logic signed [ACC_W-1:0] c7_25_o,
  output logic signed [ACC_W-1:0] c7_26_o,
  output logic signed [ACC_W-1:0] c7_27_o,
  output logic signed [ACC_W-1:0] c7_28_o,
  output logic signed [ACC_W-1:0] c7_29_o,
  output logic signed [ACC_W-1:0] c7_30_o,
  output logic signed [ACC_W-1:0] c7_31_o,
  output logic signed [ACC_W-1:0] c8_0_o,
  output logic signed [ACC_W-1:0] c8_1_o,
  output logic signed [ACC_W-1:0] c8_2_o,
  output logic signed [ACC_W-1:0] c8_3_o,
  output logic signed [ACC_W-1:0] c8_4_o,
  output logic signed [ACC_W-1:0] c8_5_o,
  output logic signed [ACC_W-1:0] c8_6_o,
  output logic signed [ACC_W-1:0] c8_7_o,
  output logic signed [ACC_W-1:0] c8_8_o,
  output logic signed [ACC_W-1:0] c8_9_o,
  output logic signed [ACC_W-1:0] c8_10_o,
  output logic signed [ACC_W-1:0] c8_11_o,
  output logic signed [ACC_W-1:0] c8_12_o,
  output logic signed [ACC_W-1:0] c8_13_o,
  output logic signed [ACC_W-1:0] c8_14_o,
  output logic signed [ACC_W-1:0] c8_15_o,
  output logic signed [ACC_W-1:0] c8_16_o,
  output logic signed [ACC_W-1:0] c8_17_o,
  output logic signed [ACC_W-1:0] c8_18_o,
  output logic signed [ACC_W-1:0] c8_19_o,
  output logic signed [ACC_W-1:0] c8_20_o,
  output logic signed [ACC_W-1:0] c8_21_o,
  output logic signed [ACC_W-1:0] c8_22_o,
  output logic signed [ACC_W-1:0] c8_23_o,
  output logic signed [ACC_W-1:0] c8_24_o,
  output logic signed [ACC_W-1:0] c8_25_o,
  output logic signed [ACC_W-1:0] c8_26_o,
  output logic signed [ACC_W-1:0] c8_27_o,
  output logic signed [ACC_W-1:0] c8_28_o,
  output logic signed [ACC_W-1:0] c8_29_o,
  output logic signed [ACC_W-1:0] c8_30_o,
  output logic signed [ACC_W-1:0] c8_31_o,
  output logic signed [ACC_W-1:0] c9_0_o,
  output logic signed [ACC_W-1:0] c9_1_o,
  output logic signed [ACC_W-1:0] c9_2_o,
  output logic signed [ACC_W-1:0] c9_3_o,
  output logic signed [ACC_W-1:0] c9_4_o,
  output logic signed [ACC_W-1:0] c9_5_o,
  output logic signed [ACC_W-1:0] c9_6_o,
  output logic signed [ACC_W-1:0] c9_7_o,
  output logic signed [ACC_W-1:0] c9_8_o,
  output logic signed [ACC_W-1:0] c9_9_o,
  output logic signed [ACC_W-1:0] c9_10_o,
  output logic signed [ACC_W-1:0] c9_11_o,
  output logic signed [ACC_W-1:0] c9_12_o,
  output logic signed [ACC_W-1:0] c9_13_o,
  output logic signed [ACC_W-1:0] c9_14_o,
  output logic signed [ACC_W-1:0] c9_15_o,
  output logic signed [ACC_W-1:0] c9_16_o,
  output logic signed [ACC_W-1:0] c9_17_o,
  output logic signed [ACC_W-1:0] c9_18_o,
  output logic signed [ACC_W-1:0] c9_19_o,
  output logic signed [ACC_W-1:0] c9_20_o,
  output logic signed [ACC_W-1:0] c9_21_o,
  output logic signed [ACC_W-1:0] c9_22_o,
  output logic signed [ACC_W-1:0] c9_23_o,
  output logic signed [ACC_W-1:0] c9_24_o,
  output logic signed [ACC_W-1:0] c9_25_o,
  output logic signed [ACC_W-1:0] c9_26_o,
  output logic signed [ACC_W-1:0] c9_27_o,
  output logic signed [ACC_W-1:0] c9_28_o,
  output logic signed [ACC_W-1:0] c9_29_o,
  output logic signed [ACC_W-1:0] c9_30_o,
  output logic signed [ACC_W-1:0] c9_31_o,
  output logic signed [ACC_W-1:0] c10_0_o,
  output logic signed [ACC_W-1:0] c10_1_o,
  output logic signed [ACC_W-1:0] c10_2_o,
  output logic signed [ACC_W-1:0] c10_3_o,
  output logic signed [ACC_W-1:0] c10_4_o,
  output logic signed [ACC_W-1:0] c10_5_o,
  output logic signed [ACC_W-1:0] c10_6_o,
  output logic signed [ACC_W-1:0] c10_7_o,
  output logic signed [ACC_W-1:0] c10_8_o,
  output logic signed [ACC_W-1:0] c10_9_o,
  output logic signed [ACC_W-1:0] c10_10_o,
  output logic signed [ACC_W-1:0] c10_11_o,
  output logic signed [ACC_W-1:0] c10_12_o,
  output logic signed [ACC_W-1:0] c10_13_o,
  output logic signed [ACC_W-1:0] c10_14_o,
  output logic signed [ACC_W-1:0] c10_15_o,
  output logic signed [ACC_W-1:0] c10_16_o,
  output logic signed [ACC_W-1:0] c10_17_o,
  output logic signed [ACC_W-1:0] c10_18_o,
  output logic signed [ACC_W-1:0] c10_19_o,
  output logic signed [ACC_W-1:0] c10_20_o,
  output logic signed [ACC_W-1:0] c10_21_o,
  output logic signed [ACC_W-1:0] c10_22_o,
  output logic signed [ACC_W-1:0] c10_23_o,
  output logic signed [ACC_W-1:0] c10_24_o,
  output logic signed [ACC_W-1:0] c10_25_o,
  output logic signed [ACC_W-1:0] c10_26_o,
  output logic signed [ACC_W-1:0] c10_27_o,
  output logic signed [ACC_W-1:0] c10_28_o,
  output logic signed [ACC_W-1:0] c10_29_o,
  output logic signed [ACC_W-1:0] c10_30_o,
  output logic signed [ACC_W-1:0] c10_31_o,
  output logic signed [ACC_W-1:0] c11_0_o,
  output logic signed [ACC_W-1:0] c11_1_o,
  output logic signed [ACC_W-1:0] c11_2_o,
  output logic signed [ACC_W-1:0] c11_3_o,
  output logic signed [ACC_W-1:0] c11_4_o,
  output logic signed [ACC_W-1:0] c11_5_o,
  output logic signed [ACC_W-1:0] c11_6_o,
  output logic signed [ACC_W-1:0] c11_7_o,
  output logic signed [ACC_W-1:0] c11_8_o,
  output logic signed [ACC_W-1:0] c11_9_o,
  output logic signed [ACC_W-1:0] c11_10_o,
  output logic signed [ACC_W-1:0] c11_11_o,
  output logic signed [ACC_W-1:0] c11_12_o,
  output logic signed [ACC_W-1:0] c11_13_o,
  output logic signed [ACC_W-1:0] c11_14_o,
  output logic signed [ACC_W-1:0] c11_15_o,
  output logic signed [ACC_W-1:0] c11_16_o,
  output logic signed [ACC_W-1:0] c11_17_o,
  output logic signed [ACC_W-1:0] c11_18_o,
  output logic signed [ACC_W-1:0] c11_19_o,
  output logic signed [ACC_W-1:0] c11_20_o,
  output logic signed [ACC_W-1:0] c11_21_o,
  output logic signed [ACC_W-1:0] c11_22_o,
  output logic signed [ACC_W-1:0] c11_23_o,
  output logic signed [ACC_W-1:0] c11_24_o,
  output logic signed [ACC_W-1:0] c11_25_o,
  output logic signed [ACC_W-1:0] c11_26_o,
  output logic signed [ACC_W-1:0] c11_27_o,
  output logic signed [ACC_W-1:0] c11_28_o,
  output logic signed [ACC_W-1:0] c11_29_o,
  output logic signed [ACC_W-1:0] c11_30_o,
  output logic signed [ACC_W-1:0] c11_31_o,
  output logic signed [ACC_W-1:0] c12_0_o,
  output logic signed [ACC_W-1:0] c12_1_o,
  output logic signed [ACC_W-1:0] c12_2_o,
  output logic signed [ACC_W-1:0] c12_3_o,
  output logic signed [ACC_W-1:0] c12_4_o,
  output logic signed [ACC_W-1:0] c12_5_o,
  output logic signed [ACC_W-1:0] c12_6_o,
  output logic signed [ACC_W-1:0] c12_7_o,
  output logic signed [ACC_W-1:0] c12_8_o,
  output logic signed [ACC_W-1:0] c12_9_o,
  output logic signed [ACC_W-1:0] c12_10_o,
  output logic signed [ACC_W-1:0] c12_11_o,
  output logic signed [ACC_W-1:0] c12_12_o,
  output logic signed [ACC_W-1:0] c12_13_o,
  output logic signed [ACC_W-1:0] c12_14_o,
  output logic signed [ACC_W-1:0] c12_15_o,
  output logic signed [ACC_W-1:0] c12_16_o,
  output logic signed [ACC_W-1:0] c12_17_o,
  output logic signed [ACC_W-1:0] c12_18_o,
  output logic signed [ACC_W-1:0] c12_19_o,
  output logic signed [ACC_W-1:0] c12_20_o,
  output logic signed [ACC_W-1:0] c12_21_o,
  output logic signed [ACC_W-1:0] c12_22_o,
  output logic signed [ACC_W-1:0] c12_23_o,
  output logic signed [ACC_W-1:0] c12_24_o,
  output logic signed [ACC_W-1:0] c12_25_o,
  output logic signed [ACC_W-1:0] c12_26_o,
  output logic signed [ACC_W-1:0] c12_27_o,
  output logic signed [ACC_W-1:0] c12_28_o,
  output logic signed [ACC_W-1:0] c12_29_o,
  output logic signed [ACC_W-1:0] c12_30_o,
  output logic signed [ACC_W-1:0] c12_31_o,
  output logic signed [ACC_W-1:0] c13_0_o,
  output logic signed [ACC_W-1:0] c13_1_o,
  output logic signed [ACC_W-1:0] c13_2_o,
  output logic signed [ACC_W-1:0] c13_3_o,
  output logic signed [ACC_W-1:0] c13_4_o,
  output logic signed [ACC_W-1:0] c13_5_o,
  output logic signed [ACC_W-1:0] c13_6_o,
  output logic signed [ACC_W-1:0] c13_7_o,
  output logic signed [ACC_W-1:0] c13_8_o,
  output logic signed [ACC_W-1:0] c13_9_o,
  output logic signed [ACC_W-1:0] c13_10_o,
  output logic signed [ACC_W-1:0] c13_11_o,
  output logic signed [ACC_W-1:0] c13_12_o,
  output logic signed [ACC_W-1:0] c13_13_o,
  output logic signed [ACC_W-1:0] c13_14_o,
  output logic signed [ACC_W-1:0] c13_15_o,
  output logic signed [ACC_W-1:0] c13_16_o,
  output logic signed [ACC_W-1:0] c13_17_o,
  output logic signed [ACC_W-1:0] c13_18_o,
  output logic signed [ACC_W-1:0] c13_19_o,
  output logic signed [ACC_W-1:0] c13_20_o,
  output logic signed [ACC_W-1:0] c13_21_o,
  output logic signed [ACC_W-1:0] c13_22_o,
  output logic signed [ACC_W-1:0] c13_23_o,
  output logic signed [ACC_W-1:0] c13_24_o,
  output logic signed [ACC_W-1:0] c13_25_o,
  output logic signed [ACC_W-1:0] c13_26_o,
  output logic signed [ACC_W-1:0] c13_27_o,
  output logic signed [ACC_W-1:0] c13_28_o,
  output logic signed [ACC_W-1:0] c13_29_o,
  output logic signed [ACC_W-1:0] c13_30_o,
  output logic signed [ACC_W-1:0] c13_31_o,
  output logic signed [ACC_W-1:0] c14_0_o,
  output logic signed [ACC_W-1:0] c14_1_o,
  output logic signed [ACC_W-1:0] c14_2_o,
  output logic signed [ACC_W-1:0] c14_3_o,
  output logic signed [ACC_W-1:0] c14_4_o,
  output logic signed [ACC_W-1:0] c14_5_o,
  output logic signed [ACC_W-1:0] c14_6_o,
  output logic signed [ACC_W-1:0] c14_7_o,
  output logic signed [ACC_W-1:0] c14_8_o,
  output logic signed [ACC_W-1:0] c14_9_o,
  output logic signed [ACC_W-1:0] c14_10_o,
  output logic signed [ACC_W-1:0] c14_11_o,
  output logic signed [ACC_W-1:0] c14_12_o,
  output logic signed [ACC_W-1:0] c14_13_o,
  output logic signed [ACC_W-1:0] c14_14_o,
  output logic signed [ACC_W-1:0] c14_15_o,
  output logic signed [ACC_W-1:0] c14_16_o,
  output logic signed [ACC_W-1:0] c14_17_o,
  output logic signed [ACC_W-1:0] c14_18_o,
  output logic signed [ACC_W-1:0] c14_19_o,
  output logic signed [ACC_W-1:0] c14_20_o,
  output logic signed [ACC_W-1:0] c14_21_o,
  output logic signed [ACC_W-1:0] c14_22_o,
  output logic signed [ACC_W-1:0] c14_23_o,
  output logic signed [ACC_W-1:0] c14_24_o,
  output logic signed [ACC_W-1:0] c14_25_o,
  output logic signed [ACC_W-1:0] c14_26_o,
  output logic signed [ACC_W-1:0] c14_27_o,
  output logic signed [ACC_W-1:0] c14_28_o,
  output logic signed [ACC_W-1:0] c14_29_o,
  output logic signed [ACC_W-1:0] c14_30_o,
  output logic signed [ACC_W-1:0] c14_31_o,
  output logic signed [ACC_W-1:0] c15_0_o,
  output logic signed [ACC_W-1:0] c15_1_o,
  output logic signed [ACC_W-1:0] c15_2_o,
  output logic signed [ACC_W-1:0] c15_3_o,
  output logic signed [ACC_W-1:0] c15_4_o,
  output logic signed [ACC_W-1:0] c15_5_o,
  output logic signed [ACC_W-1:0] c15_6_o,
  output logic signed [ACC_W-1:0] c15_7_o,
  output logic signed [ACC_W-1:0] c15_8_o,
  output logic signed [ACC_W-1:0] c15_9_o,
  output logic signed [ACC_W-1:0] c15_10_o,
  output logic signed [ACC_W-1:0] c15_11_o,
  output logic signed [ACC_W-1:0] c15_12_o,
  output logic signed [ACC_W-1:0] c15_13_o,
  output logic signed [ACC_W-1:0] c15_14_o,
  output logic signed [ACC_W-1:0] c15_15_o,
  output logic signed [ACC_W-1:0] c15_16_o,
  output logic signed [ACC_W-1:0] c15_17_o,
  output logic signed [ACC_W-1:0] c15_18_o,
  output logic signed [ACC_W-1:0] c15_19_o,
  output logic signed [ACC_W-1:0] c15_20_o,
  output logic signed [ACC_W-1:0] c15_21_o,
  output logic signed [ACC_W-1:0] c15_22_o,
  output logic signed [ACC_W-1:0] c15_23_o,
  output logic signed [ACC_W-1:0] c15_24_o,
  output logic signed [ACC_W-1:0] c15_25_o,
  output logic signed [ACC_W-1:0] c15_26_o,
  output logic signed [ACC_W-1:0] c15_27_o,
  output logic signed [ACC_W-1:0] c15_28_o,
  output logic signed [ACC_W-1:0] c15_29_o,
  output logic signed [ACC_W-1:0] c15_30_o,
  output logic signed [ACC_W-1:0] c15_31_o,
  output logic signed [ACC_W-1:0] c16_0_o,
  output logic signed [ACC_W-1:0] c16_1_o,
  output logic signed [ACC_W-1:0] c16_2_o,
  output logic signed [ACC_W-1:0] c16_3_o,
  output logic signed [ACC_W-1:0] c16_4_o,
  output logic signed [ACC_W-1:0] c16_5_o,
  output logic signed [ACC_W-1:0] c16_6_o,
  output logic signed [ACC_W-1:0] c16_7_o,
  output logic signed [ACC_W-1:0] c16_8_o,
  output logic signed [ACC_W-1:0] c16_9_o,
  output logic signed [ACC_W-1:0] c16_10_o,
  output logic signed [ACC_W-1:0] c16_11_o,
  output logic signed [ACC_W-1:0] c16_12_o,
  output logic signed [ACC_W-1:0] c16_13_o,
  output logic signed [ACC_W-1:0] c16_14_o,
  output logic signed [ACC_W-1:0] c16_15_o,
  output logic signed [ACC_W-1:0] c16_16_o,
  output logic signed [ACC_W-1:0] c16_17_o,
  output logic signed [ACC_W-1:0] c16_18_o,
  output logic signed [ACC_W-1:0] c16_19_o,
  output logic signed [ACC_W-1:0] c16_20_o,
  output logic signed [ACC_W-1:0] c16_21_o,
  output logic signed [ACC_W-1:0] c16_22_o,
  output logic signed [ACC_W-1:0] c16_23_o,
  output logic signed [ACC_W-1:0] c16_24_o,
  output logic signed [ACC_W-1:0] c16_25_o,
  output logic signed [ACC_W-1:0] c16_26_o,
  output logic signed [ACC_W-1:0] c16_27_o,
  output logic signed [ACC_W-1:0] c16_28_o,
  output logic signed [ACC_W-1:0] c16_29_o,
  output logic signed [ACC_W-1:0] c16_30_o,
  output logic signed [ACC_W-1:0] c16_31_o,
  output logic signed [ACC_W-1:0] c17_0_o,
  output logic signed [ACC_W-1:0] c17_1_o,
  output logic signed [ACC_W-1:0] c17_2_o,
  output logic signed [ACC_W-1:0] c17_3_o,
  output logic signed [ACC_W-1:0] c17_4_o,
  output logic signed [ACC_W-1:0] c17_5_o,
  output logic signed [ACC_W-1:0] c17_6_o,
  output logic signed [ACC_W-1:0] c17_7_o,
  output logic signed [ACC_W-1:0] c17_8_o,
  output logic signed [ACC_W-1:0] c17_9_o,
  output logic signed [ACC_W-1:0] c17_10_o,
  output logic signed [ACC_W-1:0] c17_11_o,
  output logic signed [ACC_W-1:0] c17_12_o,
  output logic signed [ACC_W-1:0] c17_13_o,
  output logic signed [ACC_W-1:0] c17_14_o,
  output logic signed [ACC_W-1:0] c17_15_o,
  output logic signed [ACC_W-1:0] c17_16_o,
  output logic signed [ACC_W-1:0] c17_17_o,
  output logic signed [ACC_W-1:0] c17_18_o,
  output logic signed [ACC_W-1:0] c17_19_o,
  output logic signed [ACC_W-1:0] c17_20_o,
  output logic signed [ACC_W-1:0] c17_21_o,
  output logic signed [ACC_W-1:0] c17_22_o,
  output logic signed [ACC_W-1:0] c17_23_o,
  output logic signed [ACC_W-1:0] c17_24_o,
  output logic signed [ACC_W-1:0] c17_25_o,
  output logic signed [ACC_W-1:0] c17_26_o,
  output logic signed [ACC_W-1:0] c17_27_o,
  output logic signed [ACC_W-1:0] c17_28_o,
  output logic signed [ACC_W-1:0] c17_29_o,
  output logic signed [ACC_W-1:0] c17_30_o,
  output logic signed [ACC_W-1:0] c17_31_o,
  output logic signed [ACC_W-1:0] c18_0_o,
  output logic signed [ACC_W-1:0] c18_1_o,
  output logic signed [ACC_W-1:0] c18_2_o,
  output logic signed [ACC_W-1:0] c18_3_o,
  output logic signed [ACC_W-1:0] c18_4_o,
  output logic signed [ACC_W-1:0] c18_5_o,
  output logic signed [ACC_W-1:0] c18_6_o,
  output logic signed [ACC_W-1:0] c18_7_o,
  output logic signed [ACC_W-1:0] c18_8_o,
  output logic signed [ACC_W-1:0] c18_9_o,
  output logic signed [ACC_W-1:0] c18_10_o,
  output logic signed [ACC_W-1:0] c18_11_o,
  output logic signed [ACC_W-1:0] c18_12_o,
  output logic signed [ACC_W-1:0] c18_13_o,
  output logic signed [ACC_W-1:0] c18_14_o,
  output logic signed [ACC_W-1:0] c18_15_o,
  output logic signed [ACC_W-1:0] c18_16_o,
  output logic signed [ACC_W-1:0] c18_17_o,
  output logic signed [ACC_W-1:0] c18_18_o,
  output logic signed [ACC_W-1:0] c18_19_o,
  output logic signed [ACC_W-1:0] c18_20_o,
  output logic signed [ACC_W-1:0] c18_21_o,
  output logic signed [ACC_W-1:0] c18_22_o,
  output logic signed [ACC_W-1:0] c18_23_o,
  output logic signed [ACC_W-1:0] c18_24_o,
  output logic signed [ACC_W-1:0] c18_25_o,
  output logic signed [ACC_W-1:0] c18_26_o,
  output logic signed [ACC_W-1:0] c18_27_o,
  output logic signed [ACC_W-1:0] c18_28_o,
  output logic signed [ACC_W-1:0] c18_29_o,
  output logic signed [ACC_W-1:0] c18_30_o,
  output logic signed [ACC_W-1:0] c18_31_o,
  output logic signed [ACC_W-1:0] c19_0_o,
  output logic signed [ACC_W-1:0] c19_1_o,
  output logic signed [ACC_W-1:0] c19_2_o,
  output logic signed [ACC_W-1:0] c19_3_o,
  output logic signed [ACC_W-1:0] c19_4_o,
  output logic signed [ACC_W-1:0] c19_5_o,
  output logic signed [ACC_W-1:0] c19_6_o,
  output logic signed [ACC_W-1:0] c19_7_o,
  output logic signed [ACC_W-1:0] c19_8_o,
  output logic signed [ACC_W-1:0] c19_9_o,
  output logic signed [ACC_W-1:0] c19_10_o,
  output logic signed [ACC_W-1:0] c19_11_o,
  output logic signed [ACC_W-1:0] c19_12_o,
  output logic signed [ACC_W-1:0] c19_13_o,
  output logic signed [ACC_W-1:0] c19_14_o,
  output logic signed [ACC_W-1:0] c19_15_o,
  output logic signed [ACC_W-1:0] c19_16_o,
  output logic signed [ACC_W-1:0] c19_17_o,
  output logic signed [ACC_W-1:0] c19_18_o,
  output logic signed [ACC_W-1:0] c19_19_o,
  output logic signed [ACC_W-1:0] c19_20_o,
  output logic signed [ACC_W-1:0] c19_21_o,
  output logic signed [ACC_W-1:0] c19_22_o,
  output logic signed [ACC_W-1:0] c19_23_o,
  output logic signed [ACC_W-1:0] c19_24_o,
  output logic signed [ACC_W-1:0] c19_25_o,
  output logic signed [ACC_W-1:0] c19_26_o,
  output logic signed [ACC_W-1:0] c19_27_o,
  output logic signed [ACC_W-1:0] c19_28_o,
  output logic signed [ACC_W-1:0] c19_29_o,
  output logic signed [ACC_W-1:0] c19_30_o,
  output logic signed [ACC_W-1:0] c19_31_o,
  output logic signed [ACC_W-1:0] c20_0_o,
  output logic signed [ACC_W-1:0] c20_1_o,
  output logic signed [ACC_W-1:0] c20_2_o,
  output logic signed [ACC_W-1:0] c20_3_o,
  output logic signed [ACC_W-1:0] c20_4_o,
  output logic signed [ACC_W-1:0] c20_5_o,
  output logic signed [ACC_W-1:0] c20_6_o,
  output logic signed [ACC_W-1:0] c20_7_o,
  output logic signed [ACC_W-1:0] c20_8_o,
  output logic signed [ACC_W-1:0] c20_9_o,
  output logic signed [ACC_W-1:0] c20_10_o,
  output logic signed [ACC_W-1:0] c20_11_o,
  output logic signed [ACC_W-1:0] c20_12_o,
  output logic signed [ACC_W-1:0] c20_13_o,
  output logic signed [ACC_W-1:0] c20_14_o,
  output logic signed [ACC_W-1:0] c20_15_o,
  output logic signed [ACC_W-1:0] c20_16_o,
  output logic signed [ACC_W-1:0] c20_17_o,
  output logic signed [ACC_W-1:0] c20_18_o,
  output logic signed [ACC_W-1:0] c20_19_o,
  output logic signed [ACC_W-1:0] c20_20_o,
  output logic signed [ACC_W-1:0] c20_21_o,
  output logic signed [ACC_W-1:0] c20_22_o,
  output logic signed [ACC_W-1:0] c20_23_o,
  output logic signed [ACC_W-1:0] c20_24_o,
  output logic signed [ACC_W-1:0] c20_25_o,
  output logic signed [ACC_W-1:0] c20_26_o,
  output logic signed [ACC_W-1:0] c20_27_o,
  output logic signed [ACC_W-1:0] c20_28_o,
  output logic signed [ACC_W-1:0] c20_29_o,
  output logic signed [ACC_W-1:0] c20_30_o,
  output logic signed [ACC_W-1:0] c20_31_o,
  output logic signed [ACC_W-1:0] c21_0_o,
  output logic signed [ACC_W-1:0] c21_1_o,
  output logic signed [ACC_W-1:0] c21_2_o,
  output logic signed [ACC_W-1:0] c21_3_o,
  output logic signed [ACC_W-1:0] c21_4_o,
  output logic signed [ACC_W-1:0] c21_5_o,
  output logic signed [ACC_W-1:0] c21_6_o,
  output logic signed [ACC_W-1:0] c21_7_o,
  output logic signed [ACC_W-1:0] c21_8_o,
  output logic signed [ACC_W-1:0] c21_9_o,
  output logic signed [ACC_W-1:0] c21_10_o,
  output logic signed [ACC_W-1:0] c21_11_o,
  output logic signed [ACC_W-1:0] c21_12_o,
  output logic signed [ACC_W-1:0] c21_13_o,
  output logic signed [ACC_W-1:0] c21_14_o,
  output logic signed [ACC_W-1:0] c21_15_o,
  output logic signed [ACC_W-1:0] c21_16_o,
  output logic signed [ACC_W-1:0] c21_17_o,
  output logic signed [ACC_W-1:0] c21_18_o,
  output logic signed [ACC_W-1:0] c21_19_o,
  output logic signed [ACC_W-1:0] c21_20_o,
  output logic signed [ACC_W-1:0] c21_21_o,
  output logic signed [ACC_W-1:0] c21_22_o,
  output logic signed [ACC_W-1:0] c21_23_o,
  output logic signed [ACC_W-1:0] c21_24_o,
  output logic signed [ACC_W-1:0] c21_25_o,
  output logic signed [ACC_W-1:0] c21_26_o,
  output logic signed [ACC_W-1:0] c21_27_o,
  output logic signed [ACC_W-1:0] c21_28_o,
  output logic signed [ACC_W-1:0] c21_29_o,
  output logic signed [ACC_W-1:0] c21_30_o,
  output logic signed [ACC_W-1:0] c21_31_o,
  output logic signed [ACC_W-1:0] c22_0_o,
  output logic signed [ACC_W-1:0] c22_1_o,
  output logic signed [ACC_W-1:0] c22_2_o,
  output logic signed [ACC_W-1:0] c22_3_o,
  output logic signed [ACC_W-1:0] c22_4_o,
  output logic signed [ACC_W-1:0] c22_5_o,
  output logic signed [ACC_W-1:0] c22_6_o,
  output logic signed [ACC_W-1:0] c22_7_o,
  output logic signed [ACC_W-1:0] c22_8_o,
  output logic signed [ACC_W-1:0] c22_9_o,
  output logic signed [ACC_W-1:0] c22_10_o,
  output logic signed [ACC_W-1:0] c22_11_o,
  output logic signed [ACC_W-1:0] c22_12_o,
  output logic signed [ACC_W-1:0] c22_13_o,
  output logic signed [ACC_W-1:0] c22_14_o,
  output logic signed [ACC_W-1:0] c22_15_o,
  output logic signed [ACC_W-1:0] c22_16_o,
  output logic signed [ACC_W-1:0] c22_17_o,
  output logic signed [ACC_W-1:0] c22_18_o,
  output logic signed [ACC_W-1:0] c22_19_o,
  output logic signed [ACC_W-1:0] c22_20_o,
  output logic signed [ACC_W-1:0] c22_21_o,
  output logic signed [ACC_W-1:0] c22_22_o,
  output logic signed [ACC_W-1:0] c22_23_o,
  output logic signed [ACC_W-1:0] c22_24_o,
  output logic signed [ACC_W-1:0] c22_25_o,
  output logic signed [ACC_W-1:0] c22_26_o,
  output logic signed [ACC_W-1:0] c22_27_o,
  output logic signed [ACC_W-1:0] c22_28_o,
  output logic signed [ACC_W-1:0] c22_29_o,
  output logic signed [ACC_W-1:0] c22_30_o,
  output logic signed [ACC_W-1:0] c22_31_o,
  output logic signed [ACC_W-1:0] c23_0_o,
  output logic signed [ACC_W-1:0] c23_1_o,
  output logic signed [ACC_W-1:0] c23_2_o,
  output logic signed [ACC_W-1:0] c23_3_o,
  output logic signed [ACC_W-1:0] c23_4_o,
  output logic signed [ACC_W-1:0] c23_5_o,
  output logic signed [ACC_W-1:0] c23_6_o,
  output logic signed [ACC_W-1:0] c23_7_o,
  output logic signed [ACC_W-1:0] c23_8_o,
  output logic signed [ACC_W-1:0] c23_9_o,
  output logic signed [ACC_W-1:0] c23_10_o,
  output logic signed [ACC_W-1:0] c23_11_o,
  output logic signed [ACC_W-1:0] c23_12_o,
  output logic signed [ACC_W-1:0] c23_13_o,
  output logic signed [ACC_W-1:0] c23_14_o,
  output logic signed [ACC_W-1:0] c23_15_o,
  output logic signed [ACC_W-1:0] c23_16_o,
  output logic signed [ACC_W-1:0] c23_17_o,
  output logic signed [ACC_W-1:0] c23_18_o,
  output logic signed [ACC_W-1:0] c23_19_o,
  output logic signed [ACC_W-1:0] c23_20_o,
  output logic signed [ACC_W-1:0] c23_21_o,
  output logic signed [ACC_W-1:0] c23_22_o,
  output logic signed [ACC_W-1:0] c23_23_o,
  output logic signed [ACC_W-1:0] c23_24_o,
  output logic signed [ACC_W-1:0] c23_25_o,
  output logic signed [ACC_W-1:0] c23_26_o,
  output logic signed [ACC_W-1:0] c23_27_o,
  output logic signed [ACC_W-1:0] c23_28_o,
  output logic signed [ACC_W-1:0] c23_29_o,
  output logic signed [ACC_W-1:0] c23_30_o,
  output logic signed [ACC_W-1:0] c23_31_o,
  output logic signed [ACC_W-1:0] c24_0_o,
  output logic signed [ACC_W-1:0] c24_1_o,
  output logic signed [ACC_W-1:0] c24_2_o,
  output logic signed [ACC_W-1:0] c24_3_o,
  output logic signed [ACC_W-1:0] c24_4_o,
  output logic signed [ACC_W-1:0] c24_5_o,
  output logic signed [ACC_W-1:0] c24_6_o,
  output logic signed [ACC_W-1:0] c24_7_o,
  output logic signed [ACC_W-1:0] c24_8_o,
  output logic signed [ACC_W-1:0] c24_9_o,
  output logic signed [ACC_W-1:0] c24_10_o,
  output logic signed [ACC_W-1:0] c24_11_o,
  output logic signed [ACC_W-1:0] c24_12_o,
  output logic signed [ACC_W-1:0] c24_13_o,
  output logic signed [ACC_W-1:0] c24_14_o,
  output logic signed [ACC_W-1:0] c24_15_o,
  output logic signed [ACC_W-1:0] c24_16_o,
  output logic signed [ACC_W-1:0] c24_17_o,
  output logic signed [ACC_W-1:0] c24_18_o,
  output logic signed [ACC_W-1:0] c24_19_o,
  output logic signed [ACC_W-1:0] c24_20_o,
  output logic signed [ACC_W-1:0] c24_21_o,
  output logic signed [ACC_W-1:0] c24_22_o,
  output logic signed [ACC_W-1:0] c24_23_o,
  output logic signed [ACC_W-1:0] c24_24_o,
  output logic signed [ACC_W-1:0] c24_25_o,
  output logic signed [ACC_W-1:0] c24_26_o,
  output logic signed [ACC_W-1:0] c24_27_o,
  output logic signed [ACC_W-1:0] c24_28_o,
  output logic signed [ACC_W-1:0] c24_29_o,
  output logic signed [ACC_W-1:0] c24_30_o,
  output logic signed [ACC_W-1:0] c24_31_o,
  output logic signed [ACC_W-1:0] c25_0_o,
  output logic signed [ACC_W-1:0] c25_1_o,
  output logic signed [ACC_W-1:0] c25_2_o,
  output logic signed [ACC_W-1:0] c25_3_o,
  output logic signed [ACC_W-1:0] c25_4_o,
  output logic signed [ACC_W-1:0] c25_5_o,
  output logic signed [ACC_W-1:0] c25_6_o,
  output logic signed [ACC_W-1:0] c25_7_o,
  output logic signed [ACC_W-1:0] c25_8_o,
  output logic signed [ACC_W-1:0] c25_9_o,
  output logic signed [ACC_W-1:0] c25_10_o,
  output logic signed [ACC_W-1:0] c25_11_o,
  output logic signed [ACC_W-1:0] c25_12_o,
  output logic signed [ACC_W-1:0] c25_13_o,
  output logic signed [ACC_W-1:0] c25_14_o,
  output logic signed [ACC_W-1:0] c25_15_o,
  output logic signed [ACC_W-1:0] c25_16_o,
  output logic signed [ACC_W-1:0] c25_17_o,
  output logic signed [ACC_W-1:0] c25_18_o,
  output logic signed [ACC_W-1:0] c25_19_o,
  output logic signed [ACC_W-1:0] c25_20_o,
  output logic signed [ACC_W-1:0] c25_21_o,
  output logic signed [ACC_W-1:0] c25_22_o,
  output logic signed [ACC_W-1:0] c25_23_o,
  output logic signed [ACC_W-1:0] c25_24_o,
  output logic signed [ACC_W-1:0] c25_25_o,
  output logic signed [ACC_W-1:0] c25_26_o,
  output logic signed [ACC_W-1:0] c25_27_o,
  output logic signed [ACC_W-1:0] c25_28_o,
  output logic signed [ACC_W-1:0] c25_29_o,
  output logic signed [ACC_W-1:0] c25_30_o,
  output logic signed [ACC_W-1:0] c25_31_o,
  output logic signed [ACC_W-1:0] c26_0_o,
  output logic signed [ACC_W-1:0] c26_1_o,
  output logic signed [ACC_W-1:0] c26_2_o,
  output logic signed [ACC_W-1:0] c26_3_o,
  output logic signed [ACC_W-1:0] c26_4_o,
  output logic signed [ACC_W-1:0] c26_5_o,
  output logic signed [ACC_W-1:0] c26_6_o,
  output logic signed [ACC_W-1:0] c26_7_o,
  output logic signed [ACC_W-1:0] c26_8_o,
  output logic signed [ACC_W-1:0] c26_9_o,
  output logic signed [ACC_W-1:0] c26_10_o,
  output logic signed [ACC_W-1:0] c26_11_o,
  output logic signed [ACC_W-1:0] c26_12_o,
  output logic signed [ACC_W-1:0] c26_13_o,
  output logic signed [ACC_W-1:0] c26_14_o,
  output logic signed [ACC_W-1:0] c26_15_o,
  output logic signed [ACC_W-1:0] c26_16_o,
  output logic signed [ACC_W-1:0] c26_17_o,
  output logic signed [ACC_W-1:0] c26_18_o,
  output logic signed [ACC_W-1:0] c26_19_o,
  output logic signed [ACC_W-1:0] c26_20_o,
  output logic signed [ACC_W-1:0] c26_21_o,
  output logic signed [ACC_W-1:0] c26_22_o,
  output logic signed [ACC_W-1:0] c26_23_o,
  output logic signed [ACC_W-1:0] c26_24_o,
  output logic signed [ACC_W-1:0] c26_25_o,
  output logic signed [ACC_W-1:0] c26_26_o,
  output logic signed [ACC_W-1:0] c26_27_o,
  output logic signed [ACC_W-1:0] c26_28_o,
  output logic signed [ACC_W-1:0] c26_29_o,
  output logic signed [ACC_W-1:0] c26_30_o,
  output logic signed [ACC_W-1:0] c26_31_o,
  output logic signed [ACC_W-1:0] c27_0_o,
  output logic signed [ACC_W-1:0] c27_1_o,
  output logic signed [ACC_W-1:0] c27_2_o,
  output logic signed [ACC_W-1:0] c27_3_o,
  output logic signed [ACC_W-1:0] c27_4_o,
  output logic signed [ACC_W-1:0] c27_5_o,
  output logic signed [ACC_W-1:0] c27_6_o,
  output logic signed [ACC_W-1:0] c27_7_o,
  output logic signed [ACC_W-1:0] c27_8_o,
  output logic signed [ACC_W-1:0] c27_9_o,
  output logic signed [ACC_W-1:0] c27_10_o,
  output logic signed [ACC_W-1:0] c27_11_o,
  output logic signed [ACC_W-1:0] c27_12_o,
  output logic signed [ACC_W-1:0] c27_13_o,
  output logic signed [ACC_W-1:0] c27_14_o,
  output logic signed [ACC_W-1:0] c27_15_o,
  output logic signed [ACC_W-1:0] c27_16_o,
  output logic signed [ACC_W-1:0] c27_17_o,
  output logic signed [ACC_W-1:0] c27_18_o,
  output logic signed [ACC_W-1:0] c27_19_o,
  output logic signed [ACC_W-1:0] c27_20_o,
  output logic signed [ACC_W-1:0] c27_21_o,
  output logic signed [ACC_W-1:0] c27_22_o,
  output logic signed [ACC_W-1:0] c27_23_o,
  output logic signed [ACC_W-1:0] c27_24_o,
  output logic signed [ACC_W-1:0] c27_25_o,
  output logic signed [ACC_W-1:0] c27_26_o,
  output logic signed [ACC_W-1:0] c27_27_o,
  output logic signed [ACC_W-1:0] c27_28_o,
  output logic signed [ACC_W-1:0] c27_29_o,
  output logic signed [ACC_W-1:0] c27_30_o,
  output logic signed [ACC_W-1:0] c27_31_o,
  output logic signed [ACC_W-1:0] c28_0_o,
  output logic signed [ACC_W-1:0] c28_1_o,
  output logic signed [ACC_W-1:0] c28_2_o,
  output logic signed [ACC_W-1:0] c28_3_o,
  output logic signed [ACC_W-1:0] c28_4_o,
  output logic signed [ACC_W-1:0] c28_5_o,
  output logic signed [ACC_W-1:0] c28_6_o,
  output logic signed [ACC_W-1:0] c28_7_o,
  output logic signed [ACC_W-1:0] c28_8_o,
  output logic signed [ACC_W-1:0] c28_9_o,
  output logic signed [ACC_W-1:0] c28_10_o,
  output logic signed [ACC_W-1:0] c28_11_o,
  output logic signed [ACC_W-1:0] c28_12_o,
  output logic signed [ACC_W-1:0] c28_13_o,
  output logic signed [ACC_W-1:0] c28_14_o,
  output logic signed [ACC_W-1:0] c28_15_o,
  output logic signed [ACC_W-1:0] c28_16_o,
  output logic signed [ACC_W-1:0] c28_17_o,
  output logic signed [ACC_W-1:0] c28_18_o,
  output logic signed [ACC_W-1:0] c28_19_o,
  output logic signed [ACC_W-1:0] c28_20_o,
  output logic signed [ACC_W-1:0] c28_21_o,
  output logic signed [ACC_W-1:0] c28_22_o,
  output logic signed [ACC_W-1:0] c28_23_o,
  output logic signed [ACC_W-1:0] c28_24_o,
  output logic signed [ACC_W-1:0] c28_25_o,
  output logic signed [ACC_W-1:0] c28_26_o,
  output logic signed [ACC_W-1:0] c28_27_o,
  output logic signed [ACC_W-1:0] c28_28_o,
  output logic signed [ACC_W-1:0] c28_29_o,
  output logic signed [ACC_W-1:0] c28_30_o,
  output logic signed [ACC_W-1:0] c28_31_o,
  output logic signed [ACC_W-1:0] c29_0_o,
  output logic signed [ACC_W-1:0] c29_1_o,
  output logic signed [ACC_W-1:0] c29_2_o,
  output logic signed [ACC_W-1:0] c29_3_o,
  output logic signed [ACC_W-1:0] c29_4_o,
  output logic signed [ACC_W-1:0] c29_5_o,
  output logic signed [ACC_W-1:0] c29_6_o,
  output logic signed [ACC_W-1:0] c29_7_o,
  output logic signed [ACC_W-1:0] c29_8_o,
  output logic signed [ACC_W-1:0] c29_9_o,
  output logic signed [ACC_W-1:0] c29_10_o,
  output logic signed [ACC_W-1:0] c29_11_o,
  output logic signed [ACC_W-1:0] c29_12_o,
  output logic signed [ACC_W-1:0] c29_13_o,
  output logic signed [ACC_W-1:0] c29_14_o,
  output logic signed [ACC_W-1:0] c29_15_o,
  output logic signed [ACC_W-1:0] c29_16_o,
  output logic signed [ACC_W-1:0] c29_17_o,
  output logic signed [ACC_W-1:0] c29_18_o,
  output logic signed [ACC_W-1:0] c29_19_o,
  output logic signed [ACC_W-1:0] c29_20_o,
  output logic signed [ACC_W-1:0] c29_21_o,
  output logic signed [ACC_W-1:0] c29_22_o,
  output logic signed [ACC_W-1:0] c29_23_o,
  output logic signed [ACC_W-1:0] c29_24_o,
  output logic signed [ACC_W-1:0] c29_25_o,
  output logic signed [ACC_W-1:0] c29_26_o,
  output logic signed [ACC_W-1:0] c29_27_o,
  output logic signed [ACC_W-1:0] c29_28_o,
  output logic signed [ACC_W-1:0] c29_29_o,
  output logic signed [ACC_W-1:0] c29_30_o,
  output logic signed [ACC_W-1:0] c29_31_o,
  output logic signed [ACC_W-1:0] c30_0_o,
  output logic signed [ACC_W-1:0] c30_1_o,
  output logic signed [ACC_W-1:0] c30_2_o,
  output logic signed [ACC_W-1:0] c30_3_o,
  output logic signed [ACC_W-1:0] c30_4_o,
  output logic signed [ACC_W-1:0] c30_5_o,
  output logic signed [ACC_W-1:0] c30_6_o,
  output logic signed [ACC_W-1:0] c30_7_o,
  output logic signed [ACC_W-1:0] c30_8_o,
  output logic signed [ACC_W-1:0] c30_9_o,
  output logic signed [ACC_W-1:0] c30_10_o,
  output logic signed [ACC_W-1:0] c30_11_o,
  output logic signed [ACC_W-1:0] c30_12_o,
  output logic signed [ACC_W-1:0] c30_13_o,
  output logic signed [ACC_W-1:0] c30_14_o,
  output logic signed [ACC_W-1:0] c30_15_o,
  output logic signed [ACC_W-1:0] c30_16_o,
  output logic signed [ACC_W-1:0] c30_17_o,
  output logic signed [ACC_W-1:0] c30_18_o,
  output logic signed [ACC_W-1:0] c30_19_o,
  output logic signed [ACC_W-1:0] c30_20_o,
  output logic signed [ACC_W-1:0] c30_21_o,
  output logic signed [ACC_W-1:0] c30_22_o,
  output logic signed [ACC_W-1:0] c30_23_o,
  output logic signed [ACC_W-1:0] c30_24_o,
  output logic signed [ACC_W-1:0] c30_25_o,
  output logic signed [ACC_W-1:0] c30_26_o,
  output logic signed [ACC_W-1:0] c30_27_o,
  output logic signed [ACC_W-1:0] c30_28_o,
  output logic signed [ACC_W-1:0] c30_29_o,
  output logic signed [ACC_W-1:0] c30_30_o,
  output logic signed [ACC_W-1:0] c30_31_o,
  output logic signed [ACC_W-1:0] c31_0_o,
  output logic signed [ACC_W-1:0] c31_1_o,
  output logic signed [ACC_W-1:0] c31_2_o,
  output logic signed [ACC_W-1:0] c31_3_o,
  output logic signed [ACC_W-1:0] c31_4_o,
  output logic signed [ACC_W-1:0] c31_5_o,
  output logic signed [ACC_W-1:0] c31_6_o,
  output logic signed [ACC_W-1:0] c31_7_o,
  output logic signed [ACC_W-1:0] c31_8_o,
  output logic signed [ACC_W-1:0] c31_9_o,
  output logic signed [ACC_W-1:0] c31_10_o,
  output logic signed [ACC_W-1:0] c31_11_o,
  output logic signed [ACC_W-1:0] c31_12_o,
  output logic signed [ACC_W-1:0] c31_13_o,
  output logic signed [ACC_W-1:0] c31_14_o,
  output logic signed [ACC_W-1:0] c31_15_o,
  output logic signed [ACC_W-1:0] c31_16_o,
  output logic signed [ACC_W-1:0] c31_17_o,
  output logic signed [ACC_W-1:0] c31_18_o,
  output logic signed [ACC_W-1:0] c31_19_o,
  output logic signed [ACC_W-1:0] c31_20_o,
  output logic signed [ACC_W-1:0] c31_21_o,
  output logic signed [ACC_W-1:0] c31_22_o,
  output logic signed [ACC_W-1:0] c31_23_o,
  output logic signed [ACC_W-1:0] c31_24_o,
  output logic signed [ACC_W-1:0] c31_25_o,
  output logic signed [ACC_W-1:0] c31_26_o,
  output logic signed [ACC_W-1:0] c31_27_o,
  output logic signed [ACC_W-1:0] c31_28_o,
  output logic signed [ACC_W-1:0] c31_29_o,
  output logic signed [ACC_W-1:0] c31_30_o,
  output logic signed [ACC_W-1:0] c31_31_o
);

  // Lớp chuyển đổi: 64/32 cổng phẳng (khớp Vitis xuất a_bank0..63/b_bank0..31)
  // <-> mảng nội bộ (logic FSM/generate bên dưới giữ nguyên, không đổi).
  logic [9:0]               bram_a_addr_o [A_ROWS];
  logic                     bram_a_en_o   [A_ROWS];
  logic signed [DATA_W-1:0] bram_a_dout_i [A_ROWS];
  logic [12:0]              bram_b_addr_o [ARR_SIZE];
  logic                     bram_b_en_o   [ARR_SIZE];
  logic signed [DATA_W-1:0] bram_b_dout_i [ARR_SIZE];
  logic signed [ACC_W-1:0]  c_o [ARR_SIZE][ARR_SIZE]; // noi bo, xem lop chuyen doi ben duoi

  assign bram_a0_addr_o   = bram_a_addr_o[0];
  assign bram_a0_en_o     = bram_a_en_o[0];
  assign bram_a_dout_i[0] = bram_a0_dout_i;
  assign bram_a1_addr_o   = bram_a_addr_o[1];
  assign bram_a1_en_o     = bram_a_en_o[1];
  assign bram_a_dout_i[1] = bram_a1_dout_i;
  assign bram_a2_addr_o   = bram_a_addr_o[2];
  assign bram_a2_en_o     = bram_a_en_o[2];
  assign bram_a_dout_i[2] = bram_a2_dout_i;
  assign bram_a3_addr_o   = bram_a_addr_o[3];
  assign bram_a3_en_o     = bram_a_en_o[3];
  assign bram_a_dout_i[3] = bram_a3_dout_i;
  assign bram_a4_addr_o   = bram_a_addr_o[4];
  assign bram_a4_en_o     = bram_a_en_o[4];
  assign bram_a_dout_i[4] = bram_a4_dout_i;
  assign bram_a5_addr_o   = bram_a_addr_o[5];
  assign bram_a5_en_o     = bram_a_en_o[5];
  assign bram_a_dout_i[5] = bram_a5_dout_i;
  assign bram_a6_addr_o   = bram_a_addr_o[6];
  assign bram_a6_en_o     = bram_a_en_o[6];
  assign bram_a_dout_i[6] = bram_a6_dout_i;
  assign bram_a7_addr_o   = bram_a_addr_o[7];
  assign bram_a7_en_o     = bram_a_en_o[7];
  assign bram_a_dout_i[7] = bram_a7_dout_i;
  assign bram_a8_addr_o   = bram_a_addr_o[8];
  assign bram_a8_en_o     = bram_a_en_o[8];
  assign bram_a_dout_i[8] = bram_a8_dout_i;
  assign bram_a9_addr_o   = bram_a_addr_o[9];
  assign bram_a9_en_o     = bram_a_en_o[9];
  assign bram_a_dout_i[9] = bram_a9_dout_i;
  assign bram_a10_addr_o   = bram_a_addr_o[10];
  assign bram_a10_en_o     = bram_a_en_o[10];
  assign bram_a_dout_i[10] = bram_a10_dout_i;
  assign bram_a11_addr_o   = bram_a_addr_o[11];
  assign bram_a11_en_o     = bram_a_en_o[11];
  assign bram_a_dout_i[11] = bram_a11_dout_i;
  assign bram_a12_addr_o   = bram_a_addr_o[12];
  assign bram_a12_en_o     = bram_a_en_o[12];
  assign bram_a_dout_i[12] = bram_a12_dout_i;
  assign bram_a13_addr_o   = bram_a_addr_o[13];
  assign bram_a13_en_o     = bram_a_en_o[13];
  assign bram_a_dout_i[13] = bram_a13_dout_i;
  assign bram_a14_addr_o   = bram_a_addr_o[14];
  assign bram_a14_en_o     = bram_a_en_o[14];
  assign bram_a_dout_i[14] = bram_a14_dout_i;
  assign bram_a15_addr_o   = bram_a_addr_o[15];
  assign bram_a15_en_o     = bram_a_en_o[15];
  assign bram_a_dout_i[15] = bram_a15_dout_i;
  assign bram_a16_addr_o   = bram_a_addr_o[16];
  assign bram_a16_en_o     = bram_a_en_o[16];
  assign bram_a_dout_i[16] = bram_a16_dout_i;
  assign bram_a17_addr_o   = bram_a_addr_o[17];
  assign bram_a17_en_o     = bram_a_en_o[17];
  assign bram_a_dout_i[17] = bram_a17_dout_i;
  assign bram_a18_addr_o   = bram_a_addr_o[18];
  assign bram_a18_en_o     = bram_a_en_o[18];
  assign bram_a_dout_i[18] = bram_a18_dout_i;
  assign bram_a19_addr_o   = bram_a_addr_o[19];
  assign bram_a19_en_o     = bram_a_en_o[19];
  assign bram_a_dout_i[19] = bram_a19_dout_i;
  assign bram_a20_addr_o   = bram_a_addr_o[20];
  assign bram_a20_en_o     = bram_a_en_o[20];
  assign bram_a_dout_i[20] = bram_a20_dout_i;
  assign bram_a21_addr_o   = bram_a_addr_o[21];
  assign bram_a21_en_o     = bram_a_en_o[21];
  assign bram_a_dout_i[21] = bram_a21_dout_i;
  assign bram_a22_addr_o   = bram_a_addr_o[22];
  assign bram_a22_en_o     = bram_a_en_o[22];
  assign bram_a_dout_i[22] = bram_a22_dout_i;
  assign bram_a23_addr_o   = bram_a_addr_o[23];
  assign bram_a23_en_o     = bram_a_en_o[23];
  assign bram_a_dout_i[23] = bram_a23_dout_i;
  assign bram_a24_addr_o   = bram_a_addr_o[24];
  assign bram_a24_en_o     = bram_a_en_o[24];
  assign bram_a_dout_i[24] = bram_a24_dout_i;
  assign bram_a25_addr_o   = bram_a_addr_o[25];
  assign bram_a25_en_o     = bram_a_en_o[25];
  assign bram_a_dout_i[25] = bram_a25_dout_i;
  assign bram_a26_addr_o   = bram_a_addr_o[26];
  assign bram_a26_en_o     = bram_a_en_o[26];
  assign bram_a_dout_i[26] = bram_a26_dout_i;
  assign bram_a27_addr_o   = bram_a_addr_o[27];
  assign bram_a27_en_o     = bram_a_en_o[27];
  assign bram_a_dout_i[27] = bram_a27_dout_i;
  assign bram_a28_addr_o   = bram_a_addr_o[28];
  assign bram_a28_en_o     = bram_a_en_o[28];
  assign bram_a_dout_i[28] = bram_a28_dout_i;
  assign bram_a29_addr_o   = bram_a_addr_o[29];
  assign bram_a29_en_o     = bram_a_en_o[29];
  assign bram_a_dout_i[29] = bram_a29_dout_i;
  assign bram_a30_addr_o   = bram_a_addr_o[30];
  assign bram_a30_en_o     = bram_a_en_o[30];
  assign bram_a_dout_i[30] = bram_a30_dout_i;
  assign bram_a31_addr_o   = bram_a_addr_o[31];
  assign bram_a31_en_o     = bram_a_en_o[31];
  assign bram_a_dout_i[31] = bram_a31_dout_i;
  assign bram_a32_addr_o   = bram_a_addr_o[32];
  assign bram_a32_en_o     = bram_a_en_o[32];
  assign bram_a_dout_i[32] = bram_a32_dout_i;
  assign bram_a33_addr_o   = bram_a_addr_o[33];
  assign bram_a33_en_o     = bram_a_en_o[33];
  assign bram_a_dout_i[33] = bram_a33_dout_i;
  assign bram_a34_addr_o   = bram_a_addr_o[34];
  assign bram_a34_en_o     = bram_a_en_o[34];
  assign bram_a_dout_i[34] = bram_a34_dout_i;
  assign bram_a35_addr_o   = bram_a_addr_o[35];
  assign bram_a35_en_o     = bram_a_en_o[35];
  assign bram_a_dout_i[35] = bram_a35_dout_i;
  assign bram_a36_addr_o   = bram_a_addr_o[36];
  assign bram_a36_en_o     = bram_a_en_o[36];
  assign bram_a_dout_i[36] = bram_a36_dout_i;
  assign bram_a37_addr_o   = bram_a_addr_o[37];
  assign bram_a37_en_o     = bram_a_en_o[37];
  assign bram_a_dout_i[37] = bram_a37_dout_i;
  assign bram_a38_addr_o   = bram_a_addr_o[38];
  assign bram_a38_en_o     = bram_a_en_o[38];
  assign bram_a_dout_i[38] = bram_a38_dout_i;
  assign bram_a39_addr_o   = bram_a_addr_o[39];
  assign bram_a39_en_o     = bram_a_en_o[39];
  assign bram_a_dout_i[39] = bram_a39_dout_i;
  assign bram_a40_addr_o   = bram_a_addr_o[40];
  assign bram_a40_en_o     = bram_a_en_o[40];
  assign bram_a_dout_i[40] = bram_a40_dout_i;
  assign bram_a41_addr_o   = bram_a_addr_o[41];
  assign bram_a41_en_o     = bram_a_en_o[41];
  assign bram_a_dout_i[41] = bram_a41_dout_i;
  assign bram_a42_addr_o   = bram_a_addr_o[42];
  assign bram_a42_en_o     = bram_a_en_o[42];
  assign bram_a_dout_i[42] = bram_a42_dout_i;
  assign bram_a43_addr_o   = bram_a_addr_o[43];
  assign bram_a43_en_o     = bram_a_en_o[43];
  assign bram_a_dout_i[43] = bram_a43_dout_i;
  assign bram_a44_addr_o   = bram_a_addr_o[44];
  assign bram_a44_en_o     = bram_a_en_o[44];
  assign bram_a_dout_i[44] = bram_a44_dout_i;
  assign bram_a45_addr_o   = bram_a_addr_o[45];
  assign bram_a45_en_o     = bram_a_en_o[45];
  assign bram_a_dout_i[45] = bram_a45_dout_i;
  assign bram_a46_addr_o   = bram_a_addr_o[46];
  assign bram_a46_en_o     = bram_a_en_o[46];
  assign bram_a_dout_i[46] = bram_a46_dout_i;
  assign bram_a47_addr_o   = bram_a_addr_o[47];
  assign bram_a47_en_o     = bram_a_en_o[47];
  assign bram_a_dout_i[47] = bram_a47_dout_i;
  assign bram_a48_addr_o   = bram_a_addr_o[48];
  assign bram_a48_en_o     = bram_a_en_o[48];
  assign bram_a_dout_i[48] = bram_a48_dout_i;
  assign bram_a49_addr_o   = bram_a_addr_o[49];
  assign bram_a49_en_o     = bram_a_en_o[49];
  assign bram_a_dout_i[49] = bram_a49_dout_i;
  assign bram_a50_addr_o   = bram_a_addr_o[50];
  assign bram_a50_en_o     = bram_a_en_o[50];
  assign bram_a_dout_i[50] = bram_a50_dout_i;
  assign bram_a51_addr_o   = bram_a_addr_o[51];
  assign bram_a51_en_o     = bram_a_en_o[51];
  assign bram_a_dout_i[51] = bram_a51_dout_i;
  assign bram_a52_addr_o   = bram_a_addr_o[52];
  assign bram_a52_en_o     = bram_a_en_o[52];
  assign bram_a_dout_i[52] = bram_a52_dout_i;
  assign bram_a53_addr_o   = bram_a_addr_o[53];
  assign bram_a53_en_o     = bram_a_en_o[53];
  assign bram_a_dout_i[53] = bram_a53_dout_i;
  assign bram_a54_addr_o   = bram_a_addr_o[54];
  assign bram_a54_en_o     = bram_a_en_o[54];
  assign bram_a_dout_i[54] = bram_a54_dout_i;
  assign bram_a55_addr_o   = bram_a_addr_o[55];
  assign bram_a55_en_o     = bram_a_en_o[55];
  assign bram_a_dout_i[55] = bram_a55_dout_i;
  assign bram_a56_addr_o   = bram_a_addr_o[56];
  assign bram_a56_en_o     = bram_a_en_o[56];
  assign bram_a_dout_i[56] = bram_a56_dout_i;
  assign bram_a57_addr_o   = bram_a_addr_o[57];
  assign bram_a57_en_o     = bram_a_en_o[57];
  assign bram_a_dout_i[57] = bram_a57_dout_i;
  assign bram_a58_addr_o   = bram_a_addr_o[58];
  assign bram_a58_en_o     = bram_a_en_o[58];
  assign bram_a_dout_i[58] = bram_a58_dout_i;
  assign bram_a59_addr_o   = bram_a_addr_o[59];
  assign bram_a59_en_o     = bram_a_en_o[59];
  assign bram_a_dout_i[59] = bram_a59_dout_i;
  assign bram_a60_addr_o   = bram_a_addr_o[60];
  assign bram_a60_en_o     = bram_a_en_o[60];
  assign bram_a_dout_i[60] = bram_a60_dout_i;
  assign bram_a61_addr_o   = bram_a_addr_o[61];
  assign bram_a61_en_o     = bram_a_en_o[61];
  assign bram_a_dout_i[61] = bram_a61_dout_i;
  assign bram_a62_addr_o   = bram_a_addr_o[62];
  assign bram_a62_en_o     = bram_a_en_o[62];
  assign bram_a_dout_i[62] = bram_a62_dout_i;
  assign bram_a63_addr_o   = bram_a_addr_o[63];
  assign bram_a63_en_o     = bram_a_en_o[63];
  assign bram_a_dout_i[63] = bram_a63_dout_i;

  assign bram_b0_addr_o   = bram_b_addr_o[0];
  assign bram_b0_en_o     = bram_b_en_o[0];
  assign bram_b_dout_i[0] = bram_b0_dout_i;
  assign bram_b1_addr_o   = bram_b_addr_o[1];
  assign bram_b1_en_o     = bram_b_en_o[1];
  assign bram_b_dout_i[1] = bram_b1_dout_i;
  assign bram_b2_addr_o   = bram_b_addr_o[2];
  assign bram_b2_en_o     = bram_b_en_o[2];
  assign bram_b_dout_i[2] = bram_b2_dout_i;
  assign bram_b3_addr_o   = bram_b_addr_o[3];
  assign bram_b3_en_o     = bram_b_en_o[3];
  assign bram_b_dout_i[3] = bram_b3_dout_i;
  assign bram_b4_addr_o   = bram_b_addr_o[4];
  assign bram_b4_en_o     = bram_b_en_o[4];
  assign bram_b_dout_i[4] = bram_b4_dout_i;
  assign bram_b5_addr_o   = bram_b_addr_o[5];
  assign bram_b5_en_o     = bram_b_en_o[5];
  assign bram_b_dout_i[5] = bram_b5_dout_i;
  assign bram_b6_addr_o   = bram_b_addr_o[6];
  assign bram_b6_en_o     = bram_b_en_o[6];
  assign bram_b_dout_i[6] = bram_b6_dout_i;
  assign bram_b7_addr_o   = bram_b_addr_o[7];
  assign bram_b7_en_o     = bram_b_en_o[7];
  assign bram_b_dout_i[7] = bram_b7_dout_i;
  assign bram_b8_addr_o   = bram_b_addr_o[8];
  assign bram_b8_en_o     = bram_b_en_o[8];
  assign bram_b_dout_i[8] = bram_b8_dout_i;
  assign bram_b9_addr_o   = bram_b_addr_o[9];
  assign bram_b9_en_o     = bram_b_en_o[9];
  assign bram_b_dout_i[9] = bram_b9_dout_i;
  assign bram_b10_addr_o   = bram_b_addr_o[10];
  assign bram_b10_en_o     = bram_b_en_o[10];
  assign bram_b_dout_i[10] = bram_b10_dout_i;
  assign bram_b11_addr_o   = bram_b_addr_o[11];
  assign bram_b11_en_o     = bram_b_en_o[11];
  assign bram_b_dout_i[11] = bram_b11_dout_i;
  assign bram_b12_addr_o   = bram_b_addr_o[12];
  assign bram_b12_en_o     = bram_b_en_o[12];
  assign bram_b_dout_i[12] = bram_b12_dout_i;
  assign bram_b13_addr_o   = bram_b_addr_o[13];
  assign bram_b13_en_o     = bram_b_en_o[13];
  assign bram_b_dout_i[13] = bram_b13_dout_i;
  assign bram_b14_addr_o   = bram_b_addr_o[14];
  assign bram_b14_en_o     = bram_b_en_o[14];
  assign bram_b_dout_i[14] = bram_b14_dout_i;
  assign bram_b15_addr_o   = bram_b_addr_o[15];
  assign bram_b15_en_o     = bram_b_en_o[15];
  assign bram_b_dout_i[15] = bram_b15_dout_i;
  assign bram_b16_addr_o   = bram_b_addr_o[16];
  assign bram_b16_en_o     = bram_b_en_o[16];
  assign bram_b_dout_i[16] = bram_b16_dout_i;
  assign bram_b17_addr_o   = bram_b_addr_o[17];
  assign bram_b17_en_o     = bram_b_en_o[17];
  assign bram_b_dout_i[17] = bram_b17_dout_i;
  assign bram_b18_addr_o   = bram_b_addr_o[18];
  assign bram_b18_en_o     = bram_b_en_o[18];
  assign bram_b_dout_i[18] = bram_b18_dout_i;
  assign bram_b19_addr_o   = bram_b_addr_o[19];
  assign bram_b19_en_o     = bram_b_en_o[19];
  assign bram_b_dout_i[19] = bram_b19_dout_i;
  assign bram_b20_addr_o   = bram_b_addr_o[20];
  assign bram_b20_en_o     = bram_b_en_o[20];
  assign bram_b_dout_i[20] = bram_b20_dout_i;
  assign bram_b21_addr_o   = bram_b_addr_o[21];
  assign bram_b21_en_o     = bram_b_en_o[21];
  assign bram_b_dout_i[21] = bram_b21_dout_i;
  assign bram_b22_addr_o   = bram_b_addr_o[22];
  assign bram_b22_en_o     = bram_b_en_o[22];
  assign bram_b_dout_i[22] = bram_b22_dout_i;
  assign bram_b23_addr_o   = bram_b_addr_o[23];
  assign bram_b23_en_o     = bram_b_en_o[23];
  assign bram_b_dout_i[23] = bram_b23_dout_i;
  assign bram_b24_addr_o   = bram_b_addr_o[24];
  assign bram_b24_en_o     = bram_b_en_o[24];
  assign bram_b_dout_i[24] = bram_b24_dout_i;
  assign bram_b25_addr_o   = bram_b_addr_o[25];
  assign bram_b25_en_o     = bram_b_en_o[25];
  assign bram_b_dout_i[25] = bram_b25_dout_i;
  assign bram_b26_addr_o   = bram_b_addr_o[26];
  assign bram_b26_en_o     = bram_b_en_o[26];
  assign bram_b_dout_i[26] = bram_b26_dout_i;
  assign bram_b27_addr_o   = bram_b_addr_o[27];
  assign bram_b27_en_o     = bram_b_en_o[27];
  assign bram_b_dout_i[27] = bram_b27_dout_i;
  assign bram_b28_addr_o   = bram_b_addr_o[28];
  assign bram_b28_en_o     = bram_b_en_o[28];
  assign bram_b_dout_i[28] = bram_b28_dout_i;
  assign bram_b29_addr_o   = bram_b_addr_o[29];
  assign bram_b29_en_o     = bram_b_en_o[29];
  assign bram_b_dout_i[29] = bram_b29_dout_i;
  assign bram_b30_addr_o   = bram_b_addr_o[30];
  assign bram_b30_en_o     = bram_b_en_o[30];
  assign bram_b_dout_i[30] = bram_b30_dout_i;
  assign bram_b31_addr_o   = bram_b_addr_o[31];
  assign bram_b31_en_o     = bram_b_en_o[31];
  assign bram_b_dout_i[31] = bram_b31_dout_i;

  // [Bugfix — đồng bộ với sửa lỗi lệch 1 cycle trong SYSTOLIC_PE_ARRAY, xem
  // docs/task.md mục B2] SYSTOLIC_PE_ARRAY đã bỏ nhánh "không trễ" cho
  // hàng/cột 0, đổi fill latency từ (2*ARR_SIZE-1)=63 lên (2*ARR_SIZE)=64
  // cycle (mọi hàng/cột giờ đều qua ít nhất 1 tầng thanh ghi, kể cả hàng/cột
  // 0). Nếu chỉ sửa mảng mà quên sửa dòng dưới đây, tile_done_o sẽ phát sớm
  // 1 cycle, cắt mất phép tích lũy cuối cùng — lỗi mới ngay sau khi vừa sửa
  // lỗi cũ.
  // [Bugfix MỚI — BRAM đọc đồng bộ có độ trễ 1 cycle (addr+en tại cycle N ->
  // dout hợp lệ tại cycle N+1, đúng interface_contract.md mục 1) nhưng a_row/
  // b_col trước đây dùng addr_valid CÙNG cycle với lúc phát addr/en, tức đọc
  // dout TRƯỚC KHI nó kịp hợp lệ. Xác nhận bằng log Vivado thật (bench có mô
  // hình BRAM đồng bộ đầy đủ lần đầu tiên): mọi tile đều sai 1024/1024 phần
  // tử, tile đầu tiên toàn giá trị 'x' (lần đọc BRAM đầu tiên chưa có dữ liệu
  // hợp lệ). Bù bằng thêm 1 cycle (BRAM_READ_LATENCY) — xem data_valid_q bên
  // dưới.
  localparam int BRAM_READ_LATENCY = 1;
  localparam int ACC_CYCLES = (2 * ARR_SIZE) + K_DEPTH + BRAM_READ_LATENCY; // 64+768+1=833
  localparam int K_CNT_W    = $clog2(ACC_CYCLES);

  typedef enum logic {
    ST_IDLE,
    ST_LOAD
  } state_e;

  state_e state_d, state_q;
  logic [K_CNT_W-1:0] k_cnt_d, k_cnt_q;
  logic                tile_done_d, tile_done_q;
  logic                tile_i_sel_d, tile_i_sel_q;
  logic [2:0]           tile_j_sel_d, tile_j_sel_q;

  logic                     addr_valid;
  logic [12:0]              b_addr_base; // k_cnt_q*8, cộng tile_j_sel_q ra addr thật
  logic signed [DATA_W-1:0] a_row [ARR_SIZE];
  logic signed [DATA_W-1:0] b_col [ARR_SIZE];
  logic                     array_clear_acc;
  logic                     array_en;
  logic signed [ACC_W-1:0]  acc [ARR_SIZE][ARR_SIZE];

  assign addr_valid       = (k_cnt_q < K_DEPTH[K_CNT_W-1:0]);
  assign array_en         = (state_q == ST_LOAD);
  // [Bugfix — xem docs/task.md mục B2 "BUG MỚI phát sinh từ chính bugfix B2"]
  // Trước: clear pulse tại (state_q==ST_LOAD)&&(k_cnt_q=='0), trùng đúng cycle
  // dữ liệu k=0 thật lần đầu hợp lệ -> PE(0,0) (đường skew ngắn nhất, 1 tầng
  // thanh ghi) bị "nuốt" mất số hạng k=0 vì clear_acc_i ưu tiên hơn MAC trong
  // pe.sv. Sửa: dời clear sang cycle bắt tay ở ST_IDLE (khi tile_valid_i được
  // chấp nhận) — tách biệt hoàn toàn khỏi ST_LOAD nơi dữ liệu thật bắt đầu
  // chảy, không phụ thuộc khoảng-cách-skew tình cờ đủ lớn nữa. Không tốn thêm
  // cycle (ST_IDLE vốn đã ngoài ACC_CYCLES).
  assign array_clear_acc  = (state_q == ST_IDLE) && tile_valid_i;
  // K_CNT_W=10 -> {k_cnt_q,3'b000} = k_cnt_q*8, vừa khít 13 bit (mục 1 interface_contract.md)
  assign b_addr_base      = {k_cnt_q, 3'b000};

  // [Bugfix — xem chú thích ACC_CYCLES ở trên] data_valid_q = "addr+en của
  // cycle trước có phải là 1 lần đọc thật không", trễ đúng 1 cycle so với
  // addr_valid — dùng để gate a_row/b_col thay vì addr_valid trực tiếp, khớp
  // đúng lúc bram_a_dout_i/bram_b_dout_i thật sự hợp lệ.
  logic data_valid_q;
  always_ff @(posedge clk_i) begin
    if (!rst_ni) data_valid_q <= 1'b0;
    else         data_valid_q <= array_en && addr_valid;
  end

  // [Bugfix — xem docs/task.md B4] c_o gop thanh 1 bus 32768-bit khi Package IP,
  // lech kieu voi c_arr phia HLS (Vitis xuat 1024 cong rieng c_arr_<row>_<col>).
  // Doi sang 1024 cong phang rieng, khop 1-1 voi HLS, giong huong da lam cho A/B.
  assign c0_0_o = c_o[0][0];
  assign c0_1_o = c_o[0][1];
  assign c0_2_o = c_o[0][2];
  assign c0_3_o = c_o[0][3];
  assign c0_4_o = c_o[0][4];
  assign c0_5_o = c_o[0][5];
  assign c0_6_o = c_o[0][6];
  assign c0_7_o = c_o[0][7];
  assign c0_8_o = c_o[0][8];
  assign c0_9_o = c_o[0][9];
  assign c0_10_o = c_o[0][10];
  assign c0_11_o = c_o[0][11];
  assign c0_12_o = c_o[0][12];
  assign c0_13_o = c_o[0][13];
  assign c0_14_o = c_o[0][14];
  assign c0_15_o = c_o[0][15];
  assign c0_16_o = c_o[0][16];
  assign c0_17_o = c_o[0][17];
  assign c0_18_o = c_o[0][18];
  assign c0_19_o = c_o[0][19];
  assign c0_20_o = c_o[0][20];
  assign c0_21_o = c_o[0][21];
  assign c0_22_o = c_o[0][22];
  assign c0_23_o = c_o[0][23];
  assign c0_24_o = c_o[0][24];
  assign c0_25_o = c_o[0][25];
  assign c0_26_o = c_o[0][26];
  assign c0_27_o = c_o[0][27];
  assign c0_28_o = c_o[0][28];
  assign c0_29_o = c_o[0][29];
  assign c0_30_o = c_o[0][30];
  assign c0_31_o = c_o[0][31];
  assign c1_0_o = c_o[1][0];
  assign c1_1_o = c_o[1][1];
  assign c1_2_o = c_o[1][2];
  assign c1_3_o = c_o[1][3];
  assign c1_4_o = c_o[1][4];
  assign c1_5_o = c_o[1][5];
  assign c1_6_o = c_o[1][6];
  assign c1_7_o = c_o[1][7];
  assign c1_8_o = c_o[1][8];
  assign c1_9_o = c_o[1][9];
  assign c1_10_o = c_o[1][10];
  assign c1_11_o = c_o[1][11];
  assign c1_12_o = c_o[1][12];
  assign c1_13_o = c_o[1][13];
  assign c1_14_o = c_o[1][14];
  assign c1_15_o = c_o[1][15];
  assign c1_16_o = c_o[1][16];
  assign c1_17_o = c_o[1][17];
  assign c1_18_o = c_o[1][18];
  assign c1_19_o = c_o[1][19];
  assign c1_20_o = c_o[1][20];
  assign c1_21_o = c_o[1][21];
  assign c1_22_o = c_o[1][22];
  assign c1_23_o = c_o[1][23];
  assign c1_24_o = c_o[1][24];
  assign c1_25_o = c_o[1][25];
  assign c1_26_o = c_o[1][26];
  assign c1_27_o = c_o[1][27];
  assign c1_28_o = c_o[1][28];
  assign c1_29_o = c_o[1][29];
  assign c1_30_o = c_o[1][30];
  assign c1_31_o = c_o[1][31];
  assign c2_0_o = c_o[2][0];
  assign c2_1_o = c_o[2][1];
  assign c2_2_o = c_o[2][2];
  assign c2_3_o = c_o[2][3];
  assign c2_4_o = c_o[2][4];
  assign c2_5_o = c_o[2][5];
  assign c2_6_o = c_o[2][6];
  assign c2_7_o = c_o[2][7];
  assign c2_8_o = c_o[2][8];
  assign c2_9_o = c_o[2][9];
  assign c2_10_o = c_o[2][10];
  assign c2_11_o = c_o[2][11];
  assign c2_12_o = c_o[2][12];
  assign c2_13_o = c_o[2][13];
  assign c2_14_o = c_o[2][14];
  assign c2_15_o = c_o[2][15];
  assign c2_16_o = c_o[2][16];
  assign c2_17_o = c_o[2][17];
  assign c2_18_o = c_o[2][18];
  assign c2_19_o = c_o[2][19];
  assign c2_20_o = c_o[2][20];
  assign c2_21_o = c_o[2][21];
  assign c2_22_o = c_o[2][22];
  assign c2_23_o = c_o[2][23];
  assign c2_24_o = c_o[2][24];
  assign c2_25_o = c_o[2][25];
  assign c2_26_o = c_o[2][26];
  assign c2_27_o = c_o[2][27];
  assign c2_28_o = c_o[2][28];
  assign c2_29_o = c_o[2][29];
  assign c2_30_o = c_o[2][30];
  assign c2_31_o = c_o[2][31];
  assign c3_0_o = c_o[3][0];
  assign c3_1_o = c_o[3][1];
  assign c3_2_o = c_o[3][2];
  assign c3_3_o = c_o[3][3];
  assign c3_4_o = c_o[3][4];
  assign c3_5_o = c_o[3][5];
  assign c3_6_o = c_o[3][6];
  assign c3_7_o = c_o[3][7];
  assign c3_8_o = c_o[3][8];
  assign c3_9_o = c_o[3][9];
  assign c3_10_o = c_o[3][10];
  assign c3_11_o = c_o[3][11];
  assign c3_12_o = c_o[3][12];
  assign c3_13_o = c_o[3][13];
  assign c3_14_o = c_o[3][14];
  assign c3_15_o = c_o[3][15];
  assign c3_16_o = c_o[3][16];
  assign c3_17_o = c_o[3][17];
  assign c3_18_o = c_o[3][18];
  assign c3_19_o = c_o[3][19];
  assign c3_20_o = c_o[3][20];
  assign c3_21_o = c_o[3][21];
  assign c3_22_o = c_o[3][22];
  assign c3_23_o = c_o[3][23];
  assign c3_24_o = c_o[3][24];
  assign c3_25_o = c_o[3][25];
  assign c3_26_o = c_o[3][26];
  assign c3_27_o = c_o[3][27];
  assign c3_28_o = c_o[3][28];
  assign c3_29_o = c_o[3][29];
  assign c3_30_o = c_o[3][30];
  assign c3_31_o = c_o[3][31];
  assign c4_0_o = c_o[4][0];
  assign c4_1_o = c_o[4][1];
  assign c4_2_o = c_o[4][2];
  assign c4_3_o = c_o[4][3];
  assign c4_4_o = c_o[4][4];
  assign c4_5_o = c_o[4][5];
  assign c4_6_o = c_o[4][6];
  assign c4_7_o = c_o[4][7];
  assign c4_8_o = c_o[4][8];
  assign c4_9_o = c_o[4][9];
  assign c4_10_o = c_o[4][10];
  assign c4_11_o = c_o[4][11];
  assign c4_12_o = c_o[4][12];
  assign c4_13_o = c_o[4][13];
  assign c4_14_o = c_o[4][14];
  assign c4_15_o = c_o[4][15];
  assign c4_16_o = c_o[4][16];
  assign c4_17_o = c_o[4][17];
  assign c4_18_o = c_o[4][18];
  assign c4_19_o = c_o[4][19];
  assign c4_20_o = c_o[4][20];
  assign c4_21_o = c_o[4][21];
  assign c4_22_o = c_o[4][22];
  assign c4_23_o = c_o[4][23];
  assign c4_24_o = c_o[4][24];
  assign c4_25_o = c_o[4][25];
  assign c4_26_o = c_o[4][26];
  assign c4_27_o = c_o[4][27];
  assign c4_28_o = c_o[4][28];
  assign c4_29_o = c_o[4][29];
  assign c4_30_o = c_o[4][30];
  assign c4_31_o = c_o[4][31];
  assign c5_0_o = c_o[5][0];
  assign c5_1_o = c_o[5][1];
  assign c5_2_o = c_o[5][2];
  assign c5_3_o = c_o[5][3];
  assign c5_4_o = c_o[5][4];
  assign c5_5_o = c_o[5][5];
  assign c5_6_o = c_o[5][6];
  assign c5_7_o = c_o[5][7];
  assign c5_8_o = c_o[5][8];
  assign c5_9_o = c_o[5][9];
  assign c5_10_o = c_o[5][10];
  assign c5_11_o = c_o[5][11];
  assign c5_12_o = c_o[5][12];
  assign c5_13_o = c_o[5][13];
  assign c5_14_o = c_o[5][14];
  assign c5_15_o = c_o[5][15];
  assign c5_16_o = c_o[5][16];
  assign c5_17_o = c_o[5][17];
  assign c5_18_o = c_o[5][18];
  assign c5_19_o = c_o[5][19];
  assign c5_20_o = c_o[5][20];
  assign c5_21_o = c_o[5][21];
  assign c5_22_o = c_o[5][22];
  assign c5_23_o = c_o[5][23];
  assign c5_24_o = c_o[5][24];
  assign c5_25_o = c_o[5][25];
  assign c5_26_o = c_o[5][26];
  assign c5_27_o = c_o[5][27];
  assign c5_28_o = c_o[5][28];
  assign c5_29_o = c_o[5][29];
  assign c5_30_o = c_o[5][30];
  assign c5_31_o = c_o[5][31];
  assign c6_0_o = c_o[6][0];
  assign c6_1_o = c_o[6][1];
  assign c6_2_o = c_o[6][2];
  assign c6_3_o = c_o[6][3];
  assign c6_4_o = c_o[6][4];
  assign c6_5_o = c_o[6][5];
  assign c6_6_o = c_o[6][6];
  assign c6_7_o = c_o[6][7];
  assign c6_8_o = c_o[6][8];
  assign c6_9_o = c_o[6][9];
  assign c6_10_o = c_o[6][10];
  assign c6_11_o = c_o[6][11];
  assign c6_12_o = c_o[6][12];
  assign c6_13_o = c_o[6][13];
  assign c6_14_o = c_o[6][14];
  assign c6_15_o = c_o[6][15];
  assign c6_16_o = c_o[6][16];
  assign c6_17_o = c_o[6][17];
  assign c6_18_o = c_o[6][18];
  assign c6_19_o = c_o[6][19];
  assign c6_20_o = c_o[6][20];
  assign c6_21_o = c_o[6][21];
  assign c6_22_o = c_o[6][22];
  assign c6_23_o = c_o[6][23];
  assign c6_24_o = c_o[6][24];
  assign c6_25_o = c_o[6][25];
  assign c6_26_o = c_o[6][26];
  assign c6_27_o = c_o[6][27];
  assign c6_28_o = c_o[6][28];
  assign c6_29_o = c_o[6][29];
  assign c6_30_o = c_o[6][30];
  assign c6_31_o = c_o[6][31];
  assign c7_0_o = c_o[7][0];
  assign c7_1_o = c_o[7][1];
  assign c7_2_o = c_o[7][2];
  assign c7_3_o = c_o[7][3];
  assign c7_4_o = c_o[7][4];
  assign c7_5_o = c_o[7][5];
  assign c7_6_o = c_o[7][6];
  assign c7_7_o = c_o[7][7];
  assign c7_8_o = c_o[7][8];
  assign c7_9_o = c_o[7][9];
  assign c7_10_o = c_o[7][10];
  assign c7_11_o = c_o[7][11];
  assign c7_12_o = c_o[7][12];
  assign c7_13_o = c_o[7][13];
  assign c7_14_o = c_o[7][14];
  assign c7_15_o = c_o[7][15];
  assign c7_16_o = c_o[7][16];
  assign c7_17_o = c_o[7][17];
  assign c7_18_o = c_o[7][18];
  assign c7_19_o = c_o[7][19];
  assign c7_20_o = c_o[7][20];
  assign c7_21_o = c_o[7][21];
  assign c7_22_o = c_o[7][22];
  assign c7_23_o = c_o[7][23];
  assign c7_24_o = c_o[7][24];
  assign c7_25_o = c_o[7][25];
  assign c7_26_o = c_o[7][26];
  assign c7_27_o = c_o[7][27];
  assign c7_28_o = c_o[7][28];
  assign c7_29_o = c_o[7][29];
  assign c7_30_o = c_o[7][30];
  assign c7_31_o = c_o[7][31];
  assign c8_0_o = c_o[8][0];
  assign c8_1_o = c_o[8][1];
  assign c8_2_o = c_o[8][2];
  assign c8_3_o = c_o[8][3];
  assign c8_4_o = c_o[8][4];
  assign c8_5_o = c_o[8][5];
  assign c8_6_o = c_o[8][6];
  assign c8_7_o = c_o[8][7];
  assign c8_8_o = c_o[8][8];
  assign c8_9_o = c_o[8][9];
  assign c8_10_o = c_o[8][10];
  assign c8_11_o = c_o[8][11];
  assign c8_12_o = c_o[8][12];
  assign c8_13_o = c_o[8][13];
  assign c8_14_o = c_o[8][14];
  assign c8_15_o = c_o[8][15];
  assign c8_16_o = c_o[8][16];
  assign c8_17_o = c_o[8][17];
  assign c8_18_o = c_o[8][18];
  assign c8_19_o = c_o[8][19];
  assign c8_20_o = c_o[8][20];
  assign c8_21_o = c_o[8][21];
  assign c8_22_o = c_o[8][22];
  assign c8_23_o = c_o[8][23];
  assign c8_24_o = c_o[8][24];
  assign c8_25_o = c_o[8][25];
  assign c8_26_o = c_o[8][26];
  assign c8_27_o = c_o[8][27];
  assign c8_28_o = c_o[8][28];
  assign c8_29_o = c_o[8][29];
  assign c8_30_o = c_o[8][30];
  assign c8_31_o = c_o[8][31];
  assign c9_0_o = c_o[9][0];
  assign c9_1_o = c_o[9][1];
  assign c9_2_o = c_o[9][2];
  assign c9_3_o = c_o[9][3];
  assign c9_4_o = c_o[9][4];
  assign c9_5_o = c_o[9][5];
  assign c9_6_o = c_o[9][6];
  assign c9_7_o = c_o[9][7];
  assign c9_8_o = c_o[9][8];
  assign c9_9_o = c_o[9][9];
  assign c9_10_o = c_o[9][10];
  assign c9_11_o = c_o[9][11];
  assign c9_12_o = c_o[9][12];
  assign c9_13_o = c_o[9][13];
  assign c9_14_o = c_o[9][14];
  assign c9_15_o = c_o[9][15];
  assign c9_16_o = c_o[9][16];
  assign c9_17_o = c_o[9][17];
  assign c9_18_o = c_o[9][18];
  assign c9_19_o = c_o[9][19];
  assign c9_20_o = c_o[9][20];
  assign c9_21_o = c_o[9][21];
  assign c9_22_o = c_o[9][22];
  assign c9_23_o = c_o[9][23];
  assign c9_24_o = c_o[9][24];
  assign c9_25_o = c_o[9][25];
  assign c9_26_o = c_o[9][26];
  assign c9_27_o = c_o[9][27];
  assign c9_28_o = c_o[9][28];
  assign c9_29_o = c_o[9][29];
  assign c9_30_o = c_o[9][30];
  assign c9_31_o = c_o[9][31];
  assign c10_0_o = c_o[10][0];
  assign c10_1_o = c_o[10][1];
  assign c10_2_o = c_o[10][2];
  assign c10_3_o = c_o[10][3];
  assign c10_4_o = c_o[10][4];
  assign c10_5_o = c_o[10][5];
  assign c10_6_o = c_o[10][6];
  assign c10_7_o = c_o[10][7];
  assign c10_8_o = c_o[10][8];
  assign c10_9_o = c_o[10][9];
  assign c10_10_o = c_o[10][10];
  assign c10_11_o = c_o[10][11];
  assign c10_12_o = c_o[10][12];
  assign c10_13_o = c_o[10][13];
  assign c10_14_o = c_o[10][14];
  assign c10_15_o = c_o[10][15];
  assign c10_16_o = c_o[10][16];
  assign c10_17_o = c_o[10][17];
  assign c10_18_o = c_o[10][18];
  assign c10_19_o = c_o[10][19];
  assign c10_20_o = c_o[10][20];
  assign c10_21_o = c_o[10][21];
  assign c10_22_o = c_o[10][22];
  assign c10_23_o = c_o[10][23];
  assign c10_24_o = c_o[10][24];
  assign c10_25_o = c_o[10][25];
  assign c10_26_o = c_o[10][26];
  assign c10_27_o = c_o[10][27];
  assign c10_28_o = c_o[10][28];
  assign c10_29_o = c_o[10][29];
  assign c10_30_o = c_o[10][30];
  assign c10_31_o = c_o[10][31];
  assign c11_0_o = c_o[11][0];
  assign c11_1_o = c_o[11][1];
  assign c11_2_o = c_o[11][2];
  assign c11_3_o = c_o[11][3];
  assign c11_4_o = c_o[11][4];
  assign c11_5_o = c_o[11][5];
  assign c11_6_o = c_o[11][6];
  assign c11_7_o = c_o[11][7];
  assign c11_8_o = c_o[11][8];
  assign c11_9_o = c_o[11][9];
  assign c11_10_o = c_o[11][10];
  assign c11_11_o = c_o[11][11];
  assign c11_12_o = c_o[11][12];
  assign c11_13_o = c_o[11][13];
  assign c11_14_o = c_o[11][14];
  assign c11_15_o = c_o[11][15];
  assign c11_16_o = c_o[11][16];
  assign c11_17_o = c_o[11][17];
  assign c11_18_o = c_o[11][18];
  assign c11_19_o = c_o[11][19];
  assign c11_20_o = c_o[11][20];
  assign c11_21_o = c_o[11][21];
  assign c11_22_o = c_o[11][22];
  assign c11_23_o = c_o[11][23];
  assign c11_24_o = c_o[11][24];
  assign c11_25_o = c_o[11][25];
  assign c11_26_o = c_o[11][26];
  assign c11_27_o = c_o[11][27];
  assign c11_28_o = c_o[11][28];
  assign c11_29_o = c_o[11][29];
  assign c11_30_o = c_o[11][30];
  assign c11_31_o = c_o[11][31];
  assign c12_0_o = c_o[12][0];
  assign c12_1_o = c_o[12][1];
  assign c12_2_o = c_o[12][2];
  assign c12_3_o = c_o[12][3];
  assign c12_4_o = c_o[12][4];
  assign c12_5_o = c_o[12][5];
  assign c12_6_o = c_o[12][6];
  assign c12_7_o = c_o[12][7];
  assign c12_8_o = c_o[12][8];
  assign c12_9_o = c_o[12][9];
  assign c12_10_o = c_o[12][10];
  assign c12_11_o = c_o[12][11];
  assign c12_12_o = c_o[12][12];
  assign c12_13_o = c_o[12][13];
  assign c12_14_o = c_o[12][14];
  assign c12_15_o = c_o[12][15];
  assign c12_16_o = c_o[12][16];
  assign c12_17_o = c_o[12][17];
  assign c12_18_o = c_o[12][18];
  assign c12_19_o = c_o[12][19];
  assign c12_20_o = c_o[12][20];
  assign c12_21_o = c_o[12][21];
  assign c12_22_o = c_o[12][22];
  assign c12_23_o = c_o[12][23];
  assign c12_24_o = c_o[12][24];
  assign c12_25_o = c_o[12][25];
  assign c12_26_o = c_o[12][26];
  assign c12_27_o = c_o[12][27];
  assign c12_28_o = c_o[12][28];
  assign c12_29_o = c_o[12][29];
  assign c12_30_o = c_o[12][30];
  assign c12_31_o = c_o[12][31];
  assign c13_0_o = c_o[13][0];
  assign c13_1_o = c_o[13][1];
  assign c13_2_o = c_o[13][2];
  assign c13_3_o = c_o[13][3];
  assign c13_4_o = c_o[13][4];
  assign c13_5_o = c_o[13][5];
  assign c13_6_o = c_o[13][6];
  assign c13_7_o = c_o[13][7];
  assign c13_8_o = c_o[13][8];
  assign c13_9_o = c_o[13][9];
  assign c13_10_o = c_o[13][10];
  assign c13_11_o = c_o[13][11];
  assign c13_12_o = c_o[13][12];
  assign c13_13_o = c_o[13][13];
  assign c13_14_o = c_o[13][14];
  assign c13_15_o = c_o[13][15];
  assign c13_16_o = c_o[13][16];
  assign c13_17_o = c_o[13][17];
  assign c13_18_o = c_o[13][18];
  assign c13_19_o = c_o[13][19];
  assign c13_20_o = c_o[13][20];
  assign c13_21_o = c_o[13][21];
  assign c13_22_o = c_o[13][22];
  assign c13_23_o = c_o[13][23];
  assign c13_24_o = c_o[13][24];
  assign c13_25_o = c_o[13][25];
  assign c13_26_o = c_o[13][26];
  assign c13_27_o = c_o[13][27];
  assign c13_28_o = c_o[13][28];
  assign c13_29_o = c_o[13][29];
  assign c13_30_o = c_o[13][30];
  assign c13_31_o = c_o[13][31];
  assign c14_0_o = c_o[14][0];
  assign c14_1_o = c_o[14][1];
  assign c14_2_o = c_o[14][2];
  assign c14_3_o = c_o[14][3];
  assign c14_4_o = c_o[14][4];
  assign c14_5_o = c_o[14][5];
  assign c14_6_o = c_o[14][6];
  assign c14_7_o = c_o[14][7];
  assign c14_8_o = c_o[14][8];
  assign c14_9_o = c_o[14][9];
  assign c14_10_o = c_o[14][10];
  assign c14_11_o = c_o[14][11];
  assign c14_12_o = c_o[14][12];
  assign c14_13_o = c_o[14][13];
  assign c14_14_o = c_o[14][14];
  assign c14_15_o = c_o[14][15];
  assign c14_16_o = c_o[14][16];
  assign c14_17_o = c_o[14][17];
  assign c14_18_o = c_o[14][18];
  assign c14_19_o = c_o[14][19];
  assign c14_20_o = c_o[14][20];
  assign c14_21_o = c_o[14][21];
  assign c14_22_o = c_o[14][22];
  assign c14_23_o = c_o[14][23];
  assign c14_24_o = c_o[14][24];
  assign c14_25_o = c_o[14][25];
  assign c14_26_o = c_o[14][26];
  assign c14_27_o = c_o[14][27];
  assign c14_28_o = c_o[14][28];
  assign c14_29_o = c_o[14][29];
  assign c14_30_o = c_o[14][30];
  assign c14_31_o = c_o[14][31];
  assign c15_0_o = c_o[15][0];
  assign c15_1_o = c_o[15][1];
  assign c15_2_o = c_o[15][2];
  assign c15_3_o = c_o[15][3];
  assign c15_4_o = c_o[15][4];
  assign c15_5_o = c_o[15][5];
  assign c15_6_o = c_o[15][6];
  assign c15_7_o = c_o[15][7];
  assign c15_8_o = c_o[15][8];
  assign c15_9_o = c_o[15][9];
  assign c15_10_o = c_o[15][10];
  assign c15_11_o = c_o[15][11];
  assign c15_12_o = c_o[15][12];
  assign c15_13_o = c_o[15][13];
  assign c15_14_o = c_o[15][14];
  assign c15_15_o = c_o[15][15];
  assign c15_16_o = c_o[15][16];
  assign c15_17_o = c_o[15][17];
  assign c15_18_o = c_o[15][18];
  assign c15_19_o = c_o[15][19];
  assign c15_20_o = c_o[15][20];
  assign c15_21_o = c_o[15][21];
  assign c15_22_o = c_o[15][22];
  assign c15_23_o = c_o[15][23];
  assign c15_24_o = c_o[15][24];
  assign c15_25_o = c_o[15][25];
  assign c15_26_o = c_o[15][26];
  assign c15_27_o = c_o[15][27];
  assign c15_28_o = c_o[15][28];
  assign c15_29_o = c_o[15][29];
  assign c15_30_o = c_o[15][30];
  assign c15_31_o = c_o[15][31];
  assign c16_0_o = c_o[16][0];
  assign c16_1_o = c_o[16][1];
  assign c16_2_o = c_o[16][2];
  assign c16_3_o = c_o[16][3];
  assign c16_4_o = c_o[16][4];
  assign c16_5_o = c_o[16][5];
  assign c16_6_o = c_o[16][6];
  assign c16_7_o = c_o[16][7];
  assign c16_8_o = c_o[16][8];
  assign c16_9_o = c_o[16][9];
  assign c16_10_o = c_o[16][10];
  assign c16_11_o = c_o[16][11];
  assign c16_12_o = c_o[16][12];
  assign c16_13_o = c_o[16][13];
  assign c16_14_o = c_o[16][14];
  assign c16_15_o = c_o[16][15];
  assign c16_16_o = c_o[16][16];
  assign c16_17_o = c_o[16][17];
  assign c16_18_o = c_o[16][18];
  assign c16_19_o = c_o[16][19];
  assign c16_20_o = c_o[16][20];
  assign c16_21_o = c_o[16][21];
  assign c16_22_o = c_o[16][22];
  assign c16_23_o = c_o[16][23];
  assign c16_24_o = c_o[16][24];
  assign c16_25_o = c_o[16][25];
  assign c16_26_o = c_o[16][26];
  assign c16_27_o = c_o[16][27];
  assign c16_28_o = c_o[16][28];
  assign c16_29_o = c_o[16][29];
  assign c16_30_o = c_o[16][30];
  assign c16_31_o = c_o[16][31];
  assign c17_0_o = c_o[17][0];
  assign c17_1_o = c_o[17][1];
  assign c17_2_o = c_o[17][2];
  assign c17_3_o = c_o[17][3];
  assign c17_4_o = c_o[17][4];
  assign c17_5_o = c_o[17][5];
  assign c17_6_o = c_o[17][6];
  assign c17_7_o = c_o[17][7];
  assign c17_8_o = c_o[17][8];
  assign c17_9_o = c_o[17][9];
  assign c17_10_o = c_o[17][10];
  assign c17_11_o = c_o[17][11];
  assign c17_12_o = c_o[17][12];
  assign c17_13_o = c_o[17][13];
  assign c17_14_o = c_o[17][14];
  assign c17_15_o = c_o[17][15];
  assign c17_16_o = c_o[17][16];
  assign c17_17_o = c_o[17][17];
  assign c17_18_o = c_o[17][18];
  assign c17_19_o = c_o[17][19];
  assign c17_20_o = c_o[17][20];
  assign c17_21_o = c_o[17][21];
  assign c17_22_o = c_o[17][22];
  assign c17_23_o = c_o[17][23];
  assign c17_24_o = c_o[17][24];
  assign c17_25_o = c_o[17][25];
  assign c17_26_o = c_o[17][26];
  assign c17_27_o = c_o[17][27];
  assign c17_28_o = c_o[17][28];
  assign c17_29_o = c_o[17][29];
  assign c17_30_o = c_o[17][30];
  assign c17_31_o = c_o[17][31];
  assign c18_0_o = c_o[18][0];
  assign c18_1_o = c_o[18][1];
  assign c18_2_o = c_o[18][2];
  assign c18_3_o = c_o[18][3];
  assign c18_4_o = c_o[18][4];
  assign c18_5_o = c_o[18][5];
  assign c18_6_o = c_o[18][6];
  assign c18_7_o = c_o[18][7];
  assign c18_8_o = c_o[18][8];
  assign c18_9_o = c_o[18][9];
  assign c18_10_o = c_o[18][10];
  assign c18_11_o = c_o[18][11];
  assign c18_12_o = c_o[18][12];
  assign c18_13_o = c_o[18][13];
  assign c18_14_o = c_o[18][14];
  assign c18_15_o = c_o[18][15];
  assign c18_16_o = c_o[18][16];
  assign c18_17_o = c_o[18][17];
  assign c18_18_o = c_o[18][18];
  assign c18_19_o = c_o[18][19];
  assign c18_20_o = c_o[18][20];
  assign c18_21_o = c_o[18][21];
  assign c18_22_o = c_o[18][22];
  assign c18_23_o = c_o[18][23];
  assign c18_24_o = c_o[18][24];
  assign c18_25_o = c_o[18][25];
  assign c18_26_o = c_o[18][26];
  assign c18_27_o = c_o[18][27];
  assign c18_28_o = c_o[18][28];
  assign c18_29_o = c_o[18][29];
  assign c18_30_o = c_o[18][30];
  assign c18_31_o = c_o[18][31];
  assign c19_0_o = c_o[19][0];
  assign c19_1_o = c_o[19][1];
  assign c19_2_o = c_o[19][2];
  assign c19_3_o = c_o[19][3];
  assign c19_4_o = c_o[19][4];
  assign c19_5_o = c_o[19][5];
  assign c19_6_o = c_o[19][6];
  assign c19_7_o = c_o[19][7];
  assign c19_8_o = c_o[19][8];
  assign c19_9_o = c_o[19][9];
  assign c19_10_o = c_o[19][10];
  assign c19_11_o = c_o[19][11];
  assign c19_12_o = c_o[19][12];
  assign c19_13_o = c_o[19][13];
  assign c19_14_o = c_o[19][14];
  assign c19_15_o = c_o[19][15];
  assign c19_16_o = c_o[19][16];
  assign c19_17_o = c_o[19][17];
  assign c19_18_o = c_o[19][18];
  assign c19_19_o = c_o[19][19];
  assign c19_20_o = c_o[19][20];
  assign c19_21_o = c_o[19][21];
  assign c19_22_o = c_o[19][22];
  assign c19_23_o = c_o[19][23];
  assign c19_24_o = c_o[19][24];
  assign c19_25_o = c_o[19][25];
  assign c19_26_o = c_o[19][26];
  assign c19_27_o = c_o[19][27];
  assign c19_28_o = c_o[19][28];
  assign c19_29_o = c_o[19][29];
  assign c19_30_o = c_o[19][30];
  assign c19_31_o = c_o[19][31];
  assign c20_0_o = c_o[20][0];
  assign c20_1_o = c_o[20][1];
  assign c20_2_o = c_o[20][2];
  assign c20_3_o = c_o[20][3];
  assign c20_4_o = c_o[20][4];
  assign c20_5_o = c_o[20][5];
  assign c20_6_o = c_o[20][6];
  assign c20_7_o = c_o[20][7];
  assign c20_8_o = c_o[20][8];
  assign c20_9_o = c_o[20][9];
  assign c20_10_o = c_o[20][10];
  assign c20_11_o = c_o[20][11];
  assign c20_12_o = c_o[20][12];
  assign c20_13_o = c_o[20][13];
  assign c20_14_o = c_o[20][14];
  assign c20_15_o = c_o[20][15];
  assign c20_16_o = c_o[20][16];
  assign c20_17_o = c_o[20][17];
  assign c20_18_o = c_o[20][18];
  assign c20_19_o = c_o[20][19];
  assign c20_20_o = c_o[20][20];
  assign c20_21_o = c_o[20][21];
  assign c20_22_o = c_o[20][22];
  assign c20_23_o = c_o[20][23];
  assign c20_24_o = c_o[20][24];
  assign c20_25_o = c_o[20][25];
  assign c20_26_o = c_o[20][26];
  assign c20_27_o = c_o[20][27];
  assign c20_28_o = c_o[20][28];
  assign c20_29_o = c_o[20][29];
  assign c20_30_o = c_o[20][30];
  assign c20_31_o = c_o[20][31];
  assign c21_0_o = c_o[21][0];
  assign c21_1_o = c_o[21][1];
  assign c21_2_o = c_o[21][2];
  assign c21_3_o = c_o[21][3];
  assign c21_4_o = c_o[21][4];
  assign c21_5_o = c_o[21][5];
  assign c21_6_o = c_o[21][6];
  assign c21_7_o = c_o[21][7];
  assign c21_8_o = c_o[21][8];
  assign c21_9_o = c_o[21][9];
  assign c21_10_o = c_o[21][10];
  assign c21_11_o = c_o[21][11];
  assign c21_12_o = c_o[21][12];
  assign c21_13_o = c_o[21][13];
  assign c21_14_o = c_o[21][14];
  assign c21_15_o = c_o[21][15];
  assign c21_16_o = c_o[21][16];
  assign c21_17_o = c_o[21][17];
  assign c21_18_o = c_o[21][18];
  assign c21_19_o = c_o[21][19];
  assign c21_20_o = c_o[21][20];
  assign c21_21_o = c_o[21][21];
  assign c21_22_o = c_o[21][22];
  assign c21_23_o = c_o[21][23];
  assign c21_24_o = c_o[21][24];
  assign c21_25_o = c_o[21][25];
  assign c21_26_o = c_o[21][26];
  assign c21_27_o = c_o[21][27];
  assign c21_28_o = c_o[21][28];
  assign c21_29_o = c_o[21][29];
  assign c21_30_o = c_o[21][30];
  assign c21_31_o = c_o[21][31];
  assign c22_0_o = c_o[22][0];
  assign c22_1_o = c_o[22][1];
  assign c22_2_o = c_o[22][2];
  assign c22_3_o = c_o[22][3];
  assign c22_4_o = c_o[22][4];
  assign c22_5_o = c_o[22][5];
  assign c22_6_o = c_o[22][6];
  assign c22_7_o = c_o[22][7];
  assign c22_8_o = c_o[22][8];
  assign c22_9_o = c_o[22][9];
  assign c22_10_o = c_o[22][10];
  assign c22_11_o = c_o[22][11];
  assign c22_12_o = c_o[22][12];
  assign c22_13_o = c_o[22][13];
  assign c22_14_o = c_o[22][14];
  assign c22_15_o = c_o[22][15];
  assign c22_16_o = c_o[22][16];
  assign c22_17_o = c_o[22][17];
  assign c22_18_o = c_o[22][18];
  assign c22_19_o = c_o[22][19];
  assign c22_20_o = c_o[22][20];
  assign c22_21_o = c_o[22][21];
  assign c22_22_o = c_o[22][22];
  assign c22_23_o = c_o[22][23];
  assign c22_24_o = c_o[22][24];
  assign c22_25_o = c_o[22][25];
  assign c22_26_o = c_o[22][26];
  assign c22_27_o = c_o[22][27];
  assign c22_28_o = c_o[22][28];
  assign c22_29_o = c_o[22][29];
  assign c22_30_o = c_o[22][30];
  assign c22_31_o = c_o[22][31];
  assign c23_0_o = c_o[23][0];
  assign c23_1_o = c_o[23][1];
  assign c23_2_o = c_o[23][2];
  assign c23_3_o = c_o[23][3];
  assign c23_4_o = c_o[23][4];
  assign c23_5_o = c_o[23][5];
  assign c23_6_o = c_o[23][6];
  assign c23_7_o = c_o[23][7];
  assign c23_8_o = c_o[23][8];
  assign c23_9_o = c_o[23][9];
  assign c23_10_o = c_o[23][10];
  assign c23_11_o = c_o[23][11];
  assign c23_12_o = c_o[23][12];
  assign c23_13_o = c_o[23][13];
  assign c23_14_o = c_o[23][14];
  assign c23_15_o = c_o[23][15];
  assign c23_16_o = c_o[23][16];
  assign c23_17_o = c_o[23][17];
  assign c23_18_o = c_o[23][18];
  assign c23_19_o = c_o[23][19];
  assign c23_20_o = c_o[23][20];
  assign c23_21_o = c_o[23][21];
  assign c23_22_o = c_o[23][22];
  assign c23_23_o = c_o[23][23];
  assign c23_24_o = c_o[23][24];
  assign c23_25_o = c_o[23][25];
  assign c23_26_o = c_o[23][26];
  assign c23_27_o = c_o[23][27];
  assign c23_28_o = c_o[23][28];
  assign c23_29_o = c_o[23][29];
  assign c23_30_o = c_o[23][30];
  assign c23_31_o = c_o[23][31];
  assign c24_0_o = c_o[24][0];
  assign c24_1_o = c_o[24][1];
  assign c24_2_o = c_o[24][2];
  assign c24_3_o = c_o[24][3];
  assign c24_4_o = c_o[24][4];
  assign c24_5_o = c_o[24][5];
  assign c24_6_o = c_o[24][6];
  assign c24_7_o = c_o[24][7];
  assign c24_8_o = c_o[24][8];
  assign c24_9_o = c_o[24][9];
  assign c24_10_o = c_o[24][10];
  assign c24_11_o = c_o[24][11];
  assign c24_12_o = c_o[24][12];
  assign c24_13_o = c_o[24][13];
  assign c24_14_o = c_o[24][14];
  assign c24_15_o = c_o[24][15];
  assign c24_16_o = c_o[24][16];
  assign c24_17_o = c_o[24][17];
  assign c24_18_o = c_o[24][18];
  assign c24_19_o = c_o[24][19];
  assign c24_20_o = c_o[24][20];
  assign c24_21_o = c_o[24][21];
  assign c24_22_o = c_o[24][22];
  assign c24_23_o = c_o[24][23];
  assign c24_24_o = c_o[24][24];
  assign c24_25_o = c_o[24][25];
  assign c24_26_o = c_o[24][26];
  assign c24_27_o = c_o[24][27];
  assign c24_28_o = c_o[24][28];
  assign c24_29_o = c_o[24][29];
  assign c24_30_o = c_o[24][30];
  assign c24_31_o = c_o[24][31];
  assign c25_0_o = c_o[25][0];
  assign c25_1_o = c_o[25][1];
  assign c25_2_o = c_o[25][2];
  assign c25_3_o = c_o[25][3];
  assign c25_4_o = c_o[25][4];
  assign c25_5_o = c_o[25][5];
  assign c25_6_o = c_o[25][6];
  assign c25_7_o = c_o[25][7];
  assign c25_8_o = c_o[25][8];
  assign c25_9_o = c_o[25][9];
  assign c25_10_o = c_o[25][10];
  assign c25_11_o = c_o[25][11];
  assign c25_12_o = c_o[25][12];
  assign c25_13_o = c_o[25][13];
  assign c25_14_o = c_o[25][14];
  assign c25_15_o = c_o[25][15];
  assign c25_16_o = c_o[25][16];
  assign c25_17_o = c_o[25][17];
  assign c25_18_o = c_o[25][18];
  assign c25_19_o = c_o[25][19];
  assign c25_20_o = c_o[25][20];
  assign c25_21_o = c_o[25][21];
  assign c25_22_o = c_o[25][22];
  assign c25_23_o = c_o[25][23];
  assign c25_24_o = c_o[25][24];
  assign c25_25_o = c_o[25][25];
  assign c25_26_o = c_o[25][26];
  assign c25_27_o = c_o[25][27];
  assign c25_28_o = c_o[25][28];
  assign c25_29_o = c_o[25][29];
  assign c25_30_o = c_o[25][30];
  assign c25_31_o = c_o[25][31];
  assign c26_0_o = c_o[26][0];
  assign c26_1_o = c_o[26][1];
  assign c26_2_o = c_o[26][2];
  assign c26_3_o = c_o[26][3];
  assign c26_4_o = c_o[26][4];
  assign c26_5_o = c_o[26][5];
  assign c26_6_o = c_o[26][6];
  assign c26_7_o = c_o[26][7];
  assign c26_8_o = c_o[26][8];
  assign c26_9_o = c_o[26][9];
  assign c26_10_o = c_o[26][10];
  assign c26_11_o = c_o[26][11];
  assign c26_12_o = c_o[26][12];
  assign c26_13_o = c_o[26][13];
  assign c26_14_o = c_o[26][14];
  assign c26_15_o = c_o[26][15];
  assign c26_16_o = c_o[26][16];
  assign c26_17_o = c_o[26][17];
  assign c26_18_o = c_o[26][18];
  assign c26_19_o = c_o[26][19];
  assign c26_20_o = c_o[26][20];
  assign c26_21_o = c_o[26][21];
  assign c26_22_o = c_o[26][22];
  assign c26_23_o = c_o[26][23];
  assign c26_24_o = c_o[26][24];
  assign c26_25_o = c_o[26][25];
  assign c26_26_o = c_o[26][26];
  assign c26_27_o = c_o[26][27];
  assign c26_28_o = c_o[26][28];
  assign c26_29_o = c_o[26][29];
  assign c26_30_o = c_o[26][30];
  assign c26_31_o = c_o[26][31];
  assign c27_0_o = c_o[27][0];
  assign c27_1_o = c_o[27][1];
  assign c27_2_o = c_o[27][2];
  assign c27_3_o = c_o[27][3];
  assign c27_4_o = c_o[27][4];
  assign c27_5_o = c_o[27][5];
  assign c27_6_o = c_o[27][6];
  assign c27_7_o = c_o[27][7];
  assign c27_8_o = c_o[27][8];
  assign c27_9_o = c_o[27][9];
  assign c27_10_o = c_o[27][10];
  assign c27_11_o = c_o[27][11];
  assign c27_12_o = c_o[27][12];
  assign c27_13_o = c_o[27][13];
  assign c27_14_o = c_o[27][14];
  assign c27_15_o = c_o[27][15];
  assign c27_16_o = c_o[27][16];
  assign c27_17_o = c_o[27][17];
  assign c27_18_o = c_o[27][18];
  assign c27_19_o = c_o[27][19];
  assign c27_20_o = c_o[27][20];
  assign c27_21_o = c_o[27][21];
  assign c27_22_o = c_o[27][22];
  assign c27_23_o = c_o[27][23];
  assign c27_24_o = c_o[27][24];
  assign c27_25_o = c_o[27][25];
  assign c27_26_o = c_o[27][26];
  assign c27_27_o = c_o[27][27];
  assign c27_28_o = c_o[27][28];
  assign c27_29_o = c_o[27][29];
  assign c27_30_o = c_o[27][30];
  assign c27_31_o = c_o[27][31];
  assign c28_0_o = c_o[28][0];
  assign c28_1_o = c_o[28][1];
  assign c28_2_o = c_o[28][2];
  assign c28_3_o = c_o[28][3];
  assign c28_4_o = c_o[28][4];
  assign c28_5_o = c_o[28][5];
  assign c28_6_o = c_o[28][6];
  assign c28_7_o = c_o[28][7];
  assign c28_8_o = c_o[28][8];
  assign c28_9_o = c_o[28][9];
  assign c28_10_o = c_o[28][10];
  assign c28_11_o = c_o[28][11];
  assign c28_12_o = c_o[28][12];
  assign c28_13_o = c_o[28][13];
  assign c28_14_o = c_o[28][14];
  assign c28_15_o = c_o[28][15];
  assign c28_16_o = c_o[28][16];
  assign c28_17_o = c_o[28][17];
  assign c28_18_o = c_o[28][18];
  assign c28_19_o = c_o[28][19];
  assign c28_20_o = c_o[28][20];
  assign c28_21_o = c_o[28][21];
  assign c28_22_o = c_o[28][22];
  assign c28_23_o = c_o[28][23];
  assign c28_24_o = c_o[28][24];
  assign c28_25_o = c_o[28][25];
  assign c28_26_o = c_o[28][26];
  assign c28_27_o = c_o[28][27];
  assign c28_28_o = c_o[28][28];
  assign c28_29_o = c_o[28][29];
  assign c28_30_o = c_o[28][30];
  assign c28_31_o = c_o[28][31];
  assign c29_0_o = c_o[29][0];
  assign c29_1_o = c_o[29][1];
  assign c29_2_o = c_o[29][2];
  assign c29_3_o = c_o[29][3];
  assign c29_4_o = c_o[29][4];
  assign c29_5_o = c_o[29][5];
  assign c29_6_o = c_o[29][6];
  assign c29_7_o = c_o[29][7];
  assign c29_8_o = c_o[29][8];
  assign c29_9_o = c_o[29][9];
  assign c29_10_o = c_o[29][10];
  assign c29_11_o = c_o[29][11];
  assign c29_12_o = c_o[29][12];
  assign c29_13_o = c_o[29][13];
  assign c29_14_o = c_o[29][14];
  assign c29_15_o = c_o[29][15];
  assign c29_16_o = c_o[29][16];
  assign c29_17_o = c_o[29][17];
  assign c29_18_o = c_o[29][18];
  assign c29_19_o = c_o[29][19];
  assign c29_20_o = c_o[29][20];
  assign c29_21_o = c_o[29][21];
  assign c29_22_o = c_o[29][22];
  assign c29_23_o = c_o[29][23];
  assign c29_24_o = c_o[29][24];
  assign c29_25_o = c_o[29][25];
  assign c29_26_o = c_o[29][26];
  assign c29_27_o = c_o[29][27];
  assign c29_28_o = c_o[29][28];
  assign c29_29_o = c_o[29][29];
  assign c29_30_o = c_o[29][30];
  assign c29_31_o = c_o[29][31];
  assign c30_0_o = c_o[30][0];
  assign c30_1_o = c_o[30][1];
  assign c30_2_o = c_o[30][2];
  assign c30_3_o = c_o[30][3];
  assign c30_4_o = c_o[30][4];
  assign c30_5_o = c_o[30][5];
  assign c30_6_o = c_o[30][6];
  assign c30_7_o = c_o[30][7];
  assign c30_8_o = c_o[30][8];
  assign c30_9_o = c_o[30][9];
  assign c30_10_o = c_o[30][10];
  assign c30_11_o = c_o[30][11];
  assign c30_12_o = c_o[30][12];
  assign c30_13_o = c_o[30][13];
  assign c30_14_o = c_o[30][14];
  assign c30_15_o = c_o[30][15];
  assign c30_16_o = c_o[30][16];
  assign c30_17_o = c_o[30][17];
  assign c30_18_o = c_o[30][18];
  assign c30_19_o = c_o[30][19];
  assign c30_20_o = c_o[30][20];
  assign c30_21_o = c_o[30][21];
  assign c30_22_o = c_o[30][22];
  assign c30_23_o = c_o[30][23];
  assign c30_24_o = c_o[30][24];
  assign c30_25_o = c_o[30][25];
  assign c30_26_o = c_o[30][26];
  assign c30_27_o = c_o[30][27];
  assign c30_28_o = c_o[30][28];
  assign c30_29_o = c_o[30][29];
  assign c30_30_o = c_o[30][30];
  assign c30_31_o = c_o[30][31];
  assign c31_0_o = c_o[31][0];
  assign c31_1_o = c_o[31][1];
  assign c31_2_o = c_o[31][2];
  assign c31_3_o = c_o[31][3];
  assign c31_4_o = c_o[31][4];
  assign c31_5_o = c_o[31][5];
  assign c31_6_o = c_o[31][6];
  assign c31_7_o = c_o[31][7];
  assign c31_8_o = c_o[31][8];
  assign c31_9_o = c_o[31][9];
  assign c31_10_o = c_o[31][10];
  assign c31_11_o = c_o[31][11];
  assign c31_12_o = c_o[31][12];
  assign c31_13_o = c_o[31][13];
  assign c31_14_o = c_o[31][14];
  assign c31_15_o = c_o[31][15];
  assign c31_16_o = c_o[31][16];
  assign c31_17_o = c_o[31][17];
  assign c31_18_o = c_o[31][18];
  assign c31_19_o = c_o[31][19];
  assign c31_20_o = c_o[31][20];
  assign c31_21_o = c_o[31][21];
  assign c31_22_o = c_o[31][22];
  assign c31_23_o = c_o[31][23];
  assign c31_24_o = c_o[31][24];
  assign c31_25_o = c_o[31][25];
  assign c31_26_o = c_o[31][26];
  assign c31_27_o = c_o[31][27];
  assign c31_28_o = c_o[31][28];
  assign c31_29_o = c_o[31][29];
  assign c31_30_o = c_o[31][30];
  assign c31_31_o = c_o[31][31];

  genvar gi, gj;
  generate
    // 64 cổng A cố định (1 cổng/hàng, không đổi vai trò theo tile) — RTL tự
    // mux tĩnh 64->32 bằng tile_i_sel_q, thay cho HLS copy cửa sổ A.
    for (gi = 0; gi < A_ROWS; gi++) begin : gen_a_read
      logic in_active_half;
      assign in_active_half   = tile_i_sel_q ? (gi >= ARR_SIZE) : (gi < ARR_SIZE);
      assign bram_a_addr_o[gi] = k_cnt_q[9:0];
      assign bram_a_en_o[gi]   = array_en && addr_valid && in_active_half;
    end

    for (gi = 0; gi < ARR_SIZE; gi++) begin : gen_ab_feed
      // addr = k_cnt_q*8 + tile_j_sel_q (nhóm cột đang xử lý trong block 256)
      assign bram_b_addr_o[gi] = b_addr_base + {10'b0, tile_j_sel_q};
      assign bram_b_en_o[gi]   = array_en && addr_valid;

      assign a_row[gi] = data_valid_q ? bram_a_dout_i[tile_i_sel_q ? (gi + ARR_SIZE) : gi] : '0;
      assign b_col[gi] = data_valid_q ? bram_b_dout_i[gi] : '0;
    end

    for (gi = 0; gi < ARR_SIZE; gi++) begin : gen_c_row
      for (gj = 0; gj < ARR_SIZE; gj++) begin : gen_c_col
        assign c_o[gi][gj] = acc[gi][gj];
      end
    end
  endgenerate

  always_comb begin
    state_d      = state_q;
    k_cnt_d      = k_cnt_q;
    tile_done_d  = 1'b0;
    tile_i_sel_d = tile_i_sel_q;
    tile_j_sel_d = tile_j_sel_q;

    unique case (state_q)
      ST_IDLE: begin
        if (tile_valid_i) begin
          state_d      = ST_LOAD;
          k_cnt_d      = '0;
          tile_i_sel_d = tile_i_sel_i;
          tile_j_sel_d = tile_j_sel_i;
        end
      end

      ST_LOAD: begin
        if (k_cnt_q == ACC_CYCLES[K_CNT_W-1:0] - 1'b1) begin
          state_d     = ST_IDLE;
          tile_done_d = 1'b1;
        end else begin
          k_cnt_d = k_cnt_q + 1'b1;
        end
      end

      default: state_d = ST_IDLE;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      state_q      <= ST_IDLE;
      k_cnt_q      <= '0;
      tile_done_q  <= 1'b0;
      tile_i_sel_q <= 1'b0;
      tile_j_sel_q <= 3'b000;
    end else begin
      state_q      <= state_d;
      k_cnt_q      <= k_cnt_d;
      tile_done_q  <= tile_done_d;
      tile_i_sel_q <= tile_i_sel_d;
      tile_j_sel_q <= tile_j_sel_d;
    end
  end

  assign tile_ready_o = (state_q == ST_IDLE);
  assign tile_done_o  = tile_done_q;

  SYSTOLIC_PE_ARRAY #(
    .ARR_SIZE (ARR_SIZE),
    .DATA_W   (DATA_W),
    .ACC_W    (ACC_W)
  ) u_systolic_pe_array (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .clear_acc_i  (array_clear_acc),
    .en_i         (array_en),
    .a_row_i      (a_row),
    .b_col_i      (b_col),
    .acc_o        (acc)
  );

endmodule
