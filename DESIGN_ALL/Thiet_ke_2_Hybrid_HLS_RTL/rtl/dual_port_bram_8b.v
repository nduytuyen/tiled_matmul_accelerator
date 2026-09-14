// [Phuong an C - xem docs/task.md muc D1, docs/feedback_to_spec.md muc 2026-08-04]
// Block Memory Generator (IP dong goi, ban 8.4) khoa cung width toi thieu 32-bit
// cho True_Dual_Port_RAM, khong chap nhan 8-bit nhu A/B can (Simple_Dual_Port_RAM
// cung khong co trong danh sach hop le cua ban nay). Gioi han do chi nam o lop
// wrapper IP, khong phai gioi han phan cung BRAM that - module nay tu viet theo
// dung khuon mau suy luan dual-port RAM chuan (Xilinx UG901), de Vivado Synthesis
// tu map vao BRAM primitive that o 8-bit, 2 cong doc lap doc/ghi dong thoi that.
//
// [Sua - doi tu SystemVerilog (.sv) sang Verilog thuan (.v)] Vivado tu choi dung
// file SystemVerilog lam top file cho luong "module reference" trong Block Design
// (create_bd_cell -type module -reference) - bao loi filemgmt 56-195 "type is
// not allowed as the top file in the reference". Day la gioi han cua rieng luong
// module-reference trong IP Integrator, khong phai gioi han synthesis noi chung
// (file .sv van tong hop/mo phong binh thuong o moi noi khac). Chuyen sang cu
// phap Verilog thuan (IEEE 1364-2001, $clog2 van dung duoc) de dung duoc trong
// Block Design - hanh vi/logic khong doi so voi ban .sv truoc do.
//
// Cong A: phia ghi (noi vao Addr_A/EN_A/WEN_A/Din_A/Dout_A cua mmult_accel,
// HLS la master). Cong B: phia doc (noi vao SYSTOLIC_CORE_TOP, RTL la master).
// Dung chung 1 khoi cho moi bank A (DEPTH=768) hoac B (DEPTH=6144) - 96 khoi total.
//
// [SUA - 2026-08-17, chan doan theo de xuat nguoi dung, doi chieu mau tham khao
// github.com/AISeQLab/BASIC_SOC_COURSE.../Dual_Port_BRAM.v] tb_dual_port_bram_8b.sv
// (chay sau khi clean rebuild hoan toan, loai tru het kha nang stale build) van FAIL
// 7/10 case, tat ca deu la doc qua Cong B phu thuoc gia tri da ghi qua Cong A truoc
// do - trong khi 3 case Cong A (dout_a_o = hang so cung, khong phu thuoc mem[]) deu
// PASS. Suy luan: khong phai "doc ra X", ma la "ghi qua Cong A chua tung landing vao
// mem[]" - mem[] van giu X (chua khoi tao) vi phep ghi khong co tac dung. Trung khop
// dung nghi van cu chua giai quyet (docs/bug_history.md #15).
// Khac biet cu the doi chieu mau tham khao: (1) mau tham khao co thuoc tinh
// `(* ram_style = "block" *)` tren khai bao mem, ban nay truoc day KHONG co; (2) mau
// tham khao Cong A doc+ghi CUNG 1 khoi always (doi xung voi Cong B), ban nay truoc
// day da doi Cong A thanh CHI GHI de ne (khong giai quyet duoc goc re, chi ne trieu
// chung). Da thu quay lai dung cau truc doi xung + them ram_style="block", GIU
// NGUYEN 1 clock chung clk_i (thiet ke hien tai chi co 1 domain, khac mau tham khao
// dung 2 clock rieng clka/clkb) va giu nguyen ten/do rong cong ben ngoai (khong can
// sua Block Design da noi day). `dout_a_o` gio doc that tu mem[] (khac ham cung
// 8'h00 truoc day) - an toan vi HLS chua bao gio doc lai gia tri nay (da xac nhan
// nhieu lan, khong dung tro thanh phu thuoc chuc nang).
module DUAL_PORT_BRAM_8B #(
  parameter DEPTH = 6144
) (
  input  wire                      clk_i,

  input  wire [$clog2(DEPTH)-1:0]  addr_a_i,
  input  wire                      en_a_i,
  input  wire                      we_a_i,
  input  wire [7:0]                din_a_i,
  output reg  [7:0]                dout_a_o,

  input  wire [$clog2(DEPTH)-1:0]  addr_b_i,
  input  wire                      en_b_i,
  output reg  [7:0]                dout_b_o
);

  (* ram_style = "block" *) reg [7:0] mem [0:DEPTH-1];

  always @(posedge clk_i) begin
    if (en_a_i) begin
      if (we_a_i) mem[addr_a_i] <= din_a_i;
      dout_a_o <= mem[addr_a_i];
    end
  end

  always @(posedge clk_i) begin
    if (en_b_i) dout_b_o <= mem[addr_b_i];
  end

endmodule
