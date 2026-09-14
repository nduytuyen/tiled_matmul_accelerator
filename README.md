# Tiled Matrix Multiplication Accelerator (FPGA – KV260)

Đồ án tốt nghiệp dựa trên bài báo **"Design and Implementation of an FPGA-Based
Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the
Xilinx KV260 SoM"** (Richie Li, Sicheng Chen, UC Irvine, [arXiv:2503.16731v3](https://arxiv.org/abs/2503.16731)).
PDF gốc: [`docs/`](docs/).

Đồ án tái hiện đầy đủ kiến trúc trong bài báo, sau đó **mở rộng thêm 1 kiến
trúc thứ hai tự thiết kế (Thiết kế 2)** để cải thiện hiệu năng so với bài báo
gốc. Repo này chứa **cả 2 thiết kế** — đọc kỹ mục "2 Thiết kế" dưới đây trước
khi tìm hiểu code, vì 2 thiết kế dùng module HLS/RTL khác nhau, nằm ở vị trí
khác nhau trong repo.

## Phạm vi

Accelerator (cả 2 thiết kế) **chỉ tăng tốc phần Linear Projection Q, K, V**
trong Multi-Head Self-Attention của Transformer (ba phép nhân `X·Wq`, `X·Wk`,
`X·Wv`), triển khai trên FPGA Zynq UltraScale+ (XCK26) của board Kria KV260.
Kích thước chuẩn dùng để so sánh với bài báo: `(64×768)·(768×768)`
("Attention case") và `(64×768)·(768×3072)` ("FFN case").

Q·Kᵀ, Softmax, nhân V, và phần còn lại của Feed-Forward Network **không**
được tăng tốc — vẫn chạy trên CPU ARM của KV260 (đúng như future work bài báo
nêu, chưa làm). Cả 2 thiết kế đã được tích hợp thực tế vào mô hình
**DistilBERT** (`distilbert-base-uncased-finetuned-sst-2-english`), thay 18
lớp Q/K/V (6 tầng × 3 lớp), kiểm chứng trên 16 câu tiếng Anh thật qua PYNQ.

## 2 Thiết kế

### Thiết kế 1 — Full HLS, kiến trúc Broadcast (tái hiện bài báo gốc)

Toàn bộ hiện thực bằng **Vitis HLS (C++)**, không có RTL viết tay. Ma trận A
nạp một lần vào BRAM và giữ cố định qua cờ `update_A` (tái sử dụng cho cả 3
lần tính Q/K/V). Compute engine: **1024 đơn vị MAC song song** (32×32,
`ARRAY_PARTITION` + `UNROLL`), pipeline `II=1`, phát tán (broadcast) dữ liệu
tới toàn bộ đơn vị MAC mỗi chu kỳ. Giao tiếp AXI4 (3 cổng master
`m_axi_gmemA/B/C`) + AXI4-Lite (cấu hình `N,K,M,update_A,start`). Clock mục
tiêu 100 MHz.

**Vị trí trong repo:** `mmult_accel.cpp` / `.hpp` / `_tb.cpp` (nguồn HLS),
`mmult_accel_hls/` (project Vitis HLS), `vivado_project/` (project Vivado +
bitstream, `pynq_deploy/mmult_accel.bit`).

### Thiết kế 2 — Hybrid HLS + RTL, kiến trúc Systolic (mở rộng tự thiết kế)

Xuất phát từ phát hiện: nút thắt hiệu năng chính của Thiết kế 1 là chi phí
**nạp lại thanh ghi cục bộ mỗi vòng lặp `k`** trong kiến trúc broadcast.
Thiết kế 2 giữ nguyên ý tưởng tiling 2 cấp nhưng thay lõi tính toán bằng
**mảng systolic 32×32 tự viết RTL** (kết nối nearest-neighbor giữa các PE,
dữ liệu "trôi" qua mảng thay vì broadcast lại mỗi chu kỳ), đồng thời viết lại
3 module đọc/ghi AXI4 (`A_reader`, `B_reader`, `C_writer`) bằng RTL để tự quản
lý địa chỉ hóa/giao thức tay, thay cho các cổng `m_axi` tự sinh của HLS. Phần
HLS còn lại chỉ giữ vai trò **tiling và điều phối bắt tay** (handshake) giữa
các module RTL, không còn đọc/ghi ma trận nào trực tiếp.

Bản `axi4_c_writer.v` đã qua 2 vòng tối ưu: (1) gộp burst theo hàng, (2) mở
rộng độ rộng ghi từ 32-bit → **128-bit/beat** (khớp độ rộng vật lý cổng
`S_AXI_HP_FPD`, loại bỏ chi phí Read-Modify-Write ở bộ điều khiển DDR) — đây
là bản mới nhất, đã thay cho bản 32-bit cũ.

**Vị trí trong repo (nguồn thật, dùng để build):** `docs/design2/rtl/*.v`,
`*.sv` (RTL: `axi4_a_reader.v`, `axi4_b_reader.v`, `axi4_c_writer.v`,
`dual_port_bram_8b.v`, `pe.sv`, `systolic_pe_array.sv`,
`systolic_core_top.sv`, `mmult_accel.cpp`/`.h` — phần HLS tiling còn lại) và
`docs/design2/testbench/*.sv` (10 testbench SystemVerilog/C++, kiểm chứng
bottom-up 7 cấp).

### Bản copy dễ đọc cho cả 2 thiết kế

`DESIGN_ALL/Thiet_ke_1_Full_HLS/` và `DESIGN_ALL/Thiet_ke_2_Hybrid_HLS_RTL/`
là **bản copy** (không dùng để build) tổ chức lại code của cả 2 thiết kế cho
dễ đọc/học, tách rõ HLS (`hls/`) khỏi RTL (`rtl/` hoặc `rtl_auto_generated/`
— Verilog do Vitis HLS tự sinh từ C++ của Thiết kế 1) và testbench
(`testbench*/`).

## Kết quả tổng hợp (case FFN, `(64×768)·(768×3072)`)

| Chỉ tiêu | Thiết kế 1 | Thiết kế 2 | Bài báo gốc |
|---|---|---|---|
| Độ chính xác | Tuyệt đối so với NumPy | Tuyệt đối so với NumPy | — |
| DSP / BRAM | 84.1% / 42.7% | 82% / 67% | 83% / 88%† |
| LUT / FF | 62.8% / 49.7% | 16% / 11% | 60% / 43% |
| Thời gian tính FFN (compute-only) | 64.147 ms | **16.200 ms** (~4× nhanh hơn TK1) | — |
| Tốc độ toàn mô hình DistilBERT vs CPU | 0.74× (chậm hơn CPU) | **~1.04–1.05×** (nhanh hơn CPU) | — |
| Độ chính xác phân loại (16 câu thật) | 16/16 khớp CPU | 16/16 khớp CPU | — |

† bài báo công bố số liệu sau Vivado implementation, TK1/TK2 ở đây là số của
nhóm tự đo. LUT/FF của Thiết kế 2 thấp hơn hẳn TK1 vì bỏ được phần lớn logic
điều khiển/mux/decoder diện rộng của kiến trúc broadcast; BRAM tăng vì cần 96
khối `DUAL_PORT_BRAM_8B` đệm trung gian giữa 3 module AXI4 và lõi systolic
(thay vì 1 cặp BRAM chung như TK1). Chi tiết đầy đủ, kèm số liệu case
"Attention", công suất tiêu thụ, và các bảng testbench: xem `docs/` hoặc bản
đồ án đầy đủ.

## Cấu trúc thư mục

```
mmult_accel.cpp / .hpp / _tb.cpp      Thiết kế 1 — mã nguồn HLS (Vitis HLS)
mmult_accel_hls/                      Thiết kế 1 — project Vitis HLS (C-sim, C-synth, export IP)
vivado_project/                       Thiết kế 1 — project Vivado (Block Design, bitstream, pynq_deploy/)
docs/design2/rtl/                     Thiết kế 2 — nguồn RTL + phần HLS tiling còn lại (dùng để build)
docs/design2/testbench/               Thiết kế 2 — 10 testbench SystemVerilog/C++
docs/tai_hien_do_an.ipynb             Notebook PYNQ thật: benchmark_gemm(), set_ptr(), đo công suất
docs/*.pdf                            Bài báo gốc + spec AXI (IHI0022E) + UG1037 + kết quả benchmark
docs/giaithuat/                       Minh họa thuật toán BRAM tiling
docs/a.drawio                         Nguồn vẽ hình minh họa tiling (dùng trong báo cáo)
DESIGN_ALL/                           Bản copy code dễ đọc, cả 2 thiết kế, tách HLS/RTL/testbench rõ ràng
doc_new/                              Tài liệu bổ sung của vòng update gần nhất (eval PDF, ảnh minh họa...)
scripts/update_readme.sh              Script tự cập nhật bảng "Tài nguyên phần cứng" (Thiết kế 1) bên dưới
AGENT_HANDOFF_PHAN_LOAI.md            Hướng dẫn phân loại file cho agent khác (spec vs design/code)
```

## Cách build

### Thiết kế 1

1. **Vitis HLS**: mở project `mmult_accel_hls`, top function `mmult_accel`,
   target part `xck26-sfvc784-2LV-c`, clock period 10 ns (100 MHz) →
   C Simulation → C Synthesis → Export RTL (format: Vivado IP).
2. **Vivado**: tạo project nhắm board **Kria KV260 Vision AI Starter Kit
   SOM** → Block Design → thêm Zynq UltraScale+ MPSoC + IP `mmult_accel`
   (add IP repository trỏ tới `mmult_accel_hls/solution1/impl/ip`) → Run
   Block/Connection Automation (nhớ bật `S_AXI_HP0/1/2_FPD` trên PS trước
   khi chạy Connection Automation cho 3 cổng `m_axi_gmemA/B/C`) → Validate
   Design → Create HDL Wrapper → Generate Bitstream → Export Hardware
   (`.xsa`).

### Thiết kế 2

1. **Vitis HLS**: build phần HLS tiling còn lại từ `docs/design2/rtl/mmult_accel.cpp`/`.h`
   (top function tương tự, nhưng không còn đọc/ghi ma trận trực tiếp — chỉ
   tiling + bắt tay với 3 module RTL qua tín hiệu `tile_valid/tile_done/
   a_loaded/b_loaded/c_write_done`) → Export RTL.
2. **Vivado**: thêm các module RTL trong `docs/design2/rtl/` (`axi4_a_reader.v`,
   `axi4_b_reader.v`, `axi4_c_writer.v`, `dual_port_bram_8b.v`, `pe.sv`,
   `systolic_pe_array.sv`, `systolic_core_top.sv`) làm source thường (không
   phải IP đóng gói) vào cùng Block Design với IP HLS ở bước 1, nối theo các
   bảng tín hiệu A_CONNECT/B_CONNECT/TILE_CONTROL/C_CONTROL → Generate
   Bitstream.

### Cả 2 thiết kế

Chạy trên board KV260 qua **PYNQ** (Jupyter/Python) — xem
`docs/tai_hien_do_an.ipynb` cho ví dụ nạp bitstream, `set_ptr()` ghi thanh
ghi con trỏ 64-bit, `benchmark_gemm()` so FPGA với NumPy/PyTorch, và đo công
suất qua `/sys/class/hwmon`.

<!-- AUTO:RESOURCES:START -->

## Tài nguyên phần cứng — Thiết kế 1 (C Synthesis - Vitis HLS)

| Resource | Used | Available | Utilization | Bài báo (Table 1, sau Vivado implementation) |
|---|---|---|---|---|
| BRAM_18K | 120 | 288 | 41% | 126/144 (88%) |
| DSP | 1046 | 1248 | 83% | 1040/1248 (83%) |
| FF | 103939 | 234240 | 44% | 102741/237600 (43%) |
| LUT | 88440 | 117120 | 75% | 71050/118800 (60%) |

Estimated Fmax: **136.99 MHz** (mục tiêu 100 MHz)

_Số liệu HLS ước tính cho riêng IP core, chưa gồm hạ tầng AXI SmartConnect khi ráp vào Vivado. Số liệu đầy đủ (khớp Table 1 bài báo) chỉ có sau khi Generate Bitstream trong Vivado._

_Cập nhật tự động lúc 2026-07-23 16:06, commit 0cdaa5f (2026-07-23)._
<!-- AUTO:RESOURCES:END -->

## Tài nguyên phần cứng — Thiết kế 2 (sau Vivado Implementation)

_Bảng này cập nhật thủ công, không nằm trong vùng script tự động ở trên._

| Resource | Thiết kế 2 | Thiết kế 1 (đối chiếu) |
|---|---|---|
| DSP | 82% | 84.1% |
| BRAM | 67% | 42.7% |
| LUT | 16% | 62.8% |
| LUTRAM | 3% | — |
| FF | 11% | 49.7% |

## Tham khảo

- Bài báo gốc: arXiv:[2503.16731](https://arxiv.org/abs/2503.16731)
- Mã nguồn HLS gốc: [Richielee630/MatMul_SA](https://github.com/Richielee630/MatMul_SA)
- Benchmark/PYNQ gốc: [Richielee630/TMMA](https://github.com/Richielee630/TMMA)
