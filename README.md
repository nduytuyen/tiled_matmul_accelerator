# Tiled Matrix Multiplication Accelerator (FPGA – KV260)

Đồ án tốt nghiệp dựa trên bài báo **"Design and Implementation of an FPGA-Based
Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the
Xilinx KV260 SoM"** (Richie Li, Sicheng Chen, UC Irvine, [arXiv:2503.16731v3](https://arxiv.org/abs/2503.16731)).
PDF gốc: [`docs/`](docs/).

## Phạm vi

Accelerator này **chỉ tăng tốc phần Linear Projection Q, K, V** trong
Multi-Head Self-Attention của Transformer (ba phép nhân `X·Wq`, `X·Wk`,
`X·Wv`, kích thước `(64×768)·(768×768)`), triển khai trên FPGA Zynq
UltraScale+ (XCK26) của board Kria KV260.

Q·Kᵀ, Softmax, nhân V, và Feed-Forward Network **không** được tăng tốc — vẫn
chạy trên CPU ARM của KV260 (đúng như future work bài báo nêu, chưa làm).

## Kiến trúc

- **Two-level tiling**: Block Tiling (`BLOCK_M = 256`) chia cột ma trận B;
  Inner Tiling (`TILE_SIZE = 32`) chia tiếp thành tile nhỏ.
- Ma trận A nạp một lần vào BRAM, giữ cố định qua cờ `update_A` (tái sử dụng
  X cho cả 3 lần tính Q/K/V).
- Compute engine: 32×32 = 1024 đơn vị MAC song song, pipeline `II=1`.
- Giao tiếp AXI4 (3 cổng master cho A/B/C) + AXI4-Lite (cấu hình N, K, M,
  `update_A`, `start`).
- Clock mục tiêu: 100 MHz.

## Cấu trúc thư mục

```
mmult_accel.cpp / .hpp / _tb.cpp   Mã nguồn HLS (Vitis HLS)
mmult_accel_hls/                   Project Vitis HLS (C-sim, C-synth, export IP)
vivado_project/                    Project Vivado (Block Design, bitstream)
docs/                              PDF bài báo gốc + spec AXI (IHI0022E) + UG1037
scripts/update_readme.sh           Script cập nhật phần "Tài nguyên phần cứng" bên dưới
```

## Cách build

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
3. Chạy trên board KV260 qua **PYNQ** (Jupyter/Python).

<!-- AUTO:RESOURCES:START -->

## Tài nguyên phần cứng (C Synthesis - Vitis HLS)

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

## Tham khảo

- Bài báo gốc: arXiv:[2503.16731](https://arxiv.org/abs/2503.16731)
- Mã nguồn HLS gốc: [Richielee630/MatMul_SA](https://github.com/Richielee630/MatMul_SA)
- Benchmark/PYNQ gốc: [Richielee630/TMMA](https://github.com/Richielee630/TMMA)
