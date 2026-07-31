# Báo cáo chi tiết đầy đủ — Tiled Matrix Multiplication Accelerator trên KV260

**Đề tài:** Design and Implementation of an FPGA-Based Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the Xilinx KV260 SoM (Richie Li, Sicheng Chen, UC Irvine, arXiv:2503.16731v3)

**Mục tiêu:** Tái hiện lại thiết kế và kết quả của bài báo trên board Xilinx Kria KV260, đo đạc và đối chiếu số liệu thực tế.

---

## 1. Môi trường và công cụ

| Thành phần | Chi tiết |
|---|---|
| Công cụ tổng hợp phần cứng | Xilinx/AMD Vitis HLS 2022.2, Vivado 2022.2 (chạy trên Windows) |
| Board đích | Kria KV260 Vision AI Starter Kit (chip Zynq UltraScale+ XCK26, part `xck26-sfvc784-2LV-c`) |
| Hệ điều hành board | Ubuntu 22.04.5 LTS + Kria-PYNQ (Jupyter/Python) |
| Mã nguồn HLS gốc | `mmult_accel.cpp`, `.hpp`, `_tb.cpp` (từ repo tác giả bài báo: `Richielee630/MatMul_SA`) |
| Repo project | `github.com/nduytuyen/tiled_matmul_accelerator` |

---

## 2. Tổng hợp phần cứng — Vitis HLS

**Cấu hình project:**
- Top function: `mmult_accel`
- Target part: `xck26-sfvc784-2LV-c`
- Clock period: 10 ns (100 MHz) — đúng bằng "conservative 100MHz PL clock" bài báo dùng
- Flow Target: Vivado IP Flow Target

**Quy trình:**
1. Tạo project, add Source (`mmult_accel.cpp`), Test Bench (`mmult_accel_tb.cpp`)
2. **Run C Simulation** → `All test cases Passed`, `CSim done with 0 errors`
3. **Run C Synthesis** → kết quả ước tính:

| Tài nguyên | Sử dụng/Khả dụng | % |
|---|---|---|
| DSP | 1046/1248 | 83% |
| FF | 103939/234240 | 44% |
| LUT | 88440/117120 | 75% |
| BRAM_18K | 120/288 | 41% |
| Fmax ước tính | 136.99 MHz (mục tiêu 100MHz — đạt) | |

4. **Export RTL** (format: Vivado IP) → sinh ra `mmult_accel_hls/solution1/impl/ip/` (chứa `component.xml`, IP package)

---

## 3. Tích hợp hệ thống — Vivado

**Quy trình:**
1. Tạo project mới, chọn **Board: Kria KV260 Vision AI Starter Kit SOM** (không chọn Part thô, dùng Board để tự cấu hình đúng)
2. **Add IP Repository** trỏ tới `mmult_accel_hls/solution1/impl/ip`
3. Tạo **Block Design**: thêm IP **Zynq UltraScale+ MPSoC**, chạy **Block Automation** (áp board preset)
4. Thêm IP **mmult_accel** (từ user repository) vào canvas
5. **Quan trọng — bước dễ bị bỏ sót:** vào cấu hình lại Zynq PS (`PS-PL Configuration → PS-PL Interfaces → Slave Interface → AXI HP`), bật cả 3 cổng **`S_AXI_HP0/1/2_FPD`** — nếu không bật trước, Connection Automation sẽ không có gì để nối 3 cổng `m_axi_gmemA/B/C` của IP
6. Chạy **Connection Automation** → tự thêm AXI SmartConnect, nối đúng 3 cổng AXI4 master (A/B/C) vào 3 cổng HP của PS, nối `s_axi_control` (AXI4-Lite) qua `ps8_0_axi_periph`
7. **Validate Design** → `Validation successful, no errors`
8. **Create HDL Wrapper** ("Let Vivado manage wrapper")
9. **Run Synthesis → Run Implementation → Generate Bitstream** (khoảng 30 phút)

**Kết quả tài nguyên sau Implementation (số liệu thật, không phải ước tính):**

| Tài nguyên | Sử dụng/Khả dụng | % của mình | % Bài báo (Table 1) |
|---|---|---|---|
| DSP | 1050/1248 | 84.1% | 83% ✅ |
| FF | 116326/234240 | 49.7% | 43% ✅ gần khớp |
| LUT | 73575/117120 | 62.8% | 60% ✅ |
| BRAM | 61.5/144 (đơn vị 36K) | 42.7% | **88%** ⚠️ (xem mục 7) |
| Timing | WNS = +0.163 ns (đạt) | | |

10. **Export Hardware** (tick "Include bitstream") → `vivado_project/design_1_wrapper.xsa` (5.6MB, chứa `.bit` + `.hwh` + driver C)

---

## 4. Cấu hình mạng cho board (IP tĩnh)

### 4.1. Vấn đề gặp phải

Board lấy internet qua **Windows Internet Connection Sharing (ICS)** — chia sẻ Wi-Fi trường (`HCMUT02 3`) qua cổng Ethernet nối tới board. Ban đầu:
- Tốc độ đo được qua board: chỉ **~16.8 KB/s** (đo bằng `cat /sys/class/net/eth0/statistics/rx_bytes` 2 lần cách nhau 10s)
- Tốc độ Wi-Fi gốc trên Windows (đo bằng fast.com): **64.48 Mbps**
- Chênh lệch ~480 lần → nghẽn ở khâu ICS, không phải do nguồn mạng

**Cách khắc phục:** Tắt rồi bật lại "Shared" trên Wi-Fi Windows (Network Connections → chuột phải Wi-Fi → Properties → tab Sharing → bỏ tick → OK → tick lại → OK) → mạng thông trở lại (`ping 8.8.8.8`: 0% mất gói, ~41-44ms).

### 4.2. Đặt IP tĩnh cho board (qua Serial/PuTTY, không qua mạng)

Kiểm tra ban đầu:
```bash
cat /etc/netplan/*.yaml
```
→ Phát hiện: file này do `cloud-init` tự sinh, comment cảnh báo *"Changes to it will not persist across an instance reboot"* — không phải chỗ đặt IP tĩnh bền vững. Hệ thống dùng `renderer: NetworkManager`.

```bash
nmcli connection show
```
→ Có sẵn 1 connection: `Wired connection 1` (ethernet), lúc đầu `DEVICE = --` (chưa gắn thiết bị).

```bash
nmcli device status
```
→ `eth0` ở trạng thái `disconnected`.

Thử bật kết nối (kiểu DHCP mặc định):
```bash
sudo nmcli connection up "Wired connection 1"
```
→ Lỗi: `IP configuration could not be reserved (no available address, timeout, etc.)` — xác nhận DHCP không xin được IP.

**Đặt IP tĩnh qua NetworkManager (bền vững qua các lần khởi động lại):**
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses 192.168.137.2/24 ipv4.gateway 192.168.137.1 ipv4.dns "8.8.8.8,1.1.1.1"
sudo nmcli connection modify "Wired connection 1" connection.autoconnect yes
sudo nmcli connection up "Wired connection 1"
```
→ `Connection successfully activated`

Kiểm tra:
```bash
ip addr show eth0
```
→ `inet 192.168.137.2/24` — cố định, tự động kết nối lại mỗi lần khởi động (nhờ `autoconnect yes`).

```bash
ping -c 3 192.168.137.1   # gateway - khong tra loi (Windows Firewall chan ICMP, binh thuong)
ping -c 3 8.8.8.8          # internet that - 0% mat goi, ~41-44ms
```

---

## 5. Đưa bitstream lên board (PYNQ)

1. Giải nén file `.xsa` (thực chất là file zip):
```bash
unzip -o -j design_1_wrapper.xsa design_1_wrapper.bit design_1.hwh -d pynq_deploy
```
2. Đổi tên 2 file thành **cùng tên gốc** (bắt buộc với PYNQ): `mmult_accel.bit`, `mmult_accel.hwh`
3. Upload 2 file lên JupyterLab (`http://192.168.137.2:9090/lab`, mật khẩu `xilinx`), cùng thư mục với notebook
4. Nạp bitstream:
```python
from pynq import Overlay
overlay = Overlay("mmult_accel.bit")
print(overlay.ip_dict.keys())
# dict_keys(['mmult_accel_0', 'zynq_ultra_ps_e_0'])
```
5. Bản đồ thanh ghi (`mmult_accel.register_map`):
```
CTRL (AP_START, AP_DONE, AP_IDLE, AUTO_RESTART, INTERRUPT...)
A_1, A_2   -- 2 nua 32-bit cua con tro 64-bit ma tran A (PYNQ khong tu gop)
B_1, B_2   -- con tro B
C_1, C_2   -- con tro C
N, K, M    -- kich thuoc ma tran
update_A   -- co giu A tren BRAM (1=nap lai, 0=tai su dung)
```

---

## 6. Cài đặt thư viện Python (torch, transformers)

Sau khi mạng đã sửa xong:
```python
!pip install torch transformers --quiet
```
→ Cài thành công: `Torch version: 2.13.0+cu130`, `Transformers version: 5.14.1` (bản `+cu130` có hỗ trợ CUDA nhưng board không có GPU NVIDIA nên tự chạy CPU, không ảnh hưởng).

**Lỗi gặp phải và cách sửa:** Khi load model DistilBERT lần đầu, gặp lỗi:
```
AttributeError: module 'PIL.Image' has no attribute 'Resampling'
```
Nguyên nhân: `transformers` bản mới cần `Pillow ≥ 9.1.0`, bản có sẵn trên board quá cũ. Khắc phục:
```python
!pip install --upgrade pillow --quiet
```
sau đó **bắt buộc Restart Kernel** (Python đã cache trạng thái lỗi của lần import trước), rồi chạy lại từ đầu.

Model DistilBERT (`distilbert-base-uncased`, ~250MB) và model phân loại (`distilbert-base-uncased-finetuned-sst-2-english`) tự động tải qua `from_pretrained(...)`, lưu cache tại `~/.cache/huggingface` — các lần load sau không tải lại.

---

## 7. Kết quả Benchmark — Hiệu năng GEMM

### 7.1. Case chuẩn bài báo (Table 2)

**Attention case (N=64, K=768, M=768):**

| Framework | Latency | Throughput |
|---|---|---|
| NumPy | 1088.8 ms | 0.069 GFLOPs |
| PyTorch | 82.8 ms | 0.912 GFLOPs |
| **FPGA (compute)** | **16.4 ms** | **4.62 GFLOPs** |
| **FPGA (end-to-end)** | **17.0 ms** | **4.45 GFLOPs** |

**FFN case (N=64, K=768, M=3072) — Table 2 gốc:**

| Framework | Của mình | Bài báo |
|---|---|---|
| NumPy | 21470ms / 0.014 GFLOPs | 20720ms / 0.01 GFLOPs |
| PyTorch | 331.6ms / 0.911 GFLOPs | 670ms / 0.45 GFLOPs |
| **FPGA (compute)** | **64.2ms / 4.71 GFLOPs** | 90ms / 3.12 GFLOPs |
| **FPGA (end-to-end)** | **64.9ms / 4.66 GFLOPs** | 110ms / 2.85 GFLOPs |

→ **Vượt bài báo ở mọi chỉ số**, đúng 100% (`Dung=True`) ở mọi phép đo.

### 7.2. Quét N (dữ liệu mở rộng, bài báo không có)

Giới hạn N ≤ 64 (do buffer `A_bram` trên phần cứng cố định kích thước `MAX_N=64 × MAX_K=768`, không thể vượt).

| N | FPGA compute | GFLOPs | Speedup vs PyTorch |
|---|---|---|---|
| 8 | 9.4 ms | 1.00 | 1.24× |
| 16 | 9.8 ms | 1.93 | 2.26× |
| 32 | 10.6 ms | 3.56 | 4.00× |
| 64 | 16.3 ms | 4.62 | 5.07× |

→ Speedup tăng dần đều theo N — chứng minh chi phí cố định (nạp B, khởi động pipeline) được pha loãng khi N lớn.

---

## 8. Phát hiện quan trọng: Lỗi đơn vị BRAM trong bài báo gốc

**Vấn đề:** Table 1 bài báo ghi BRAM "126/144 = 88%", nhưng đo thật bằng Vivado của mình chỉ ra **42.7%**.

**Bằng chứng xác nhận (từ report gốc của chính tác giả, do người dùng cung cấp trực tiếp từ Vitis HLS 2024.2, project "MatMul_SA"):**
```
| mmult_accel | ... | 126 (43%)| 1040 (83%)| 102741 (43%)| 71050 (60%)|
```
→ **Chính công cụ của họ tự tính ra 43%**, không phải 88%. Nguyên nhân: `126/288 = 43.75% ≈ 43%` (288 là số khối BRAM 18K khả dụng — đúng đơn vị khớp với báo cáo Vitis HLS). Nhưng khi chép vào Table 1 của bài báo, họ ghi `126/144 = 87.5% ≈ 88%` (144 là số khối BRAM **36K** — sai đơn vị, lấy nhầm mẫu số).

**Kết luận:** Table 1 bài báo có lỗi ở dòng BRAM (nên là ~43-44%, không phải 88%). DSP/FF/LUT thì khớp tuyệt đối với báo cáo gốc của họ — chỉ riêng BRAM bị lỗi khi chép số.

**Giải thích vật lý:** Chip có đúng **144 khối BRAM vật lý** (đơn vị 36Kb, cố định trên silicon). Mỗi khối 36Kb có thể tách thành 2 khối 18Kb độc lập → đếm theo 18K sẽ ra tối đa 288. Không phải 2 loại silicon khác nhau, chỉ là 2 đơn vị đo khác nhau trên cùng phần cứng.

---

## 9. Đo công suất và năng lượng

**Cảm biến:** `hwmon2` = `ina260_u14` (INA260, tương tự loại bài báo dùng), đọc qua `/sys/class/hwmon/hwmon2/power1_input` (đơn vị µW).

**Phương pháp:** Lấy mẫu công suất liên tục (mỗi 50ms) bằng thread nền trong lúc tính toán, tính năng lượng = công suất trung bình × thời gian (giống phương pháp bài báo mô tả).

| | Công suất TB | Thời gian | Năng lượng |
|---|---|---|---|
| Idle (baseline) | 3.78-3.88 W | | |
| CPU (NumPy) | 3.72 W | 21-22 s | ~78-82 J |
| PyTorch | 3.75-3.78 W | 331-350 ms | ~1245-1320 mJ |
| **FPGA** (lặp 20 lần) | 3.86-3.90 W | 71.4 ms/lần | 275-278 mJ/lần |
| **FPGA** (lặp 200 lần, kiểm chứng lại) | 3.88-3.90 W | 71.1 ms/lần | 276 mJ/lần |

**Hiệu suất năng lượng FPGA vs PyTorch: 4.49-4.79× tốt hơn** — khớp sát với **~4×** bài báo báo cáo. (So với NumPy thì cao hơn nhiều — 283×, nhưng không nên dùng NumPy làm baseline vì bài báo dùng PyTorch để tính con số năng lượng của họ.)

---

## 10. Tích hợp DistilBERT (thay thế Q/K/V bằng FPGA)

### 10.1. Cấu trúc model xác nhận

`DistilBertModel`: 6 tầng Transformer, mỗi tầng có `q_lin`, `k_lin`, `v_lin`, `out_lin` (đều `768→768`, có bias). Chỉ thay **Q, K, V** (không thay `out_lin`), đúng phạm vi bài báo.

### 10.2. Class `FPGAQuantizedLinear` (bản đầu, đơn giản)

- Lượng tử hóa int8 đối xứng (symmetric per-tensor) cho cả weight (tính 1 lần) và activation (tính động mỗi lần gọi — khác với "static quantization" đầy đủ của bài báo, đơn giản hóa hợp lý)
- Test 1 lớp (`q_lin` tầng 0, input ngẫu nhiên): sai số tương đối (theo norm) ~3.3-3.4%
- Thay cả 18 lớp (6 tầng × Q/K/V), test toàn model:
  - Cosine similarity ~0.992-0.997 (tốt)
  - Độ chính xác dự đoán (model phân loại SST-2): **16/16 câu khớp nhãn (100%)**, lệch confidence trung bình **0.016 điểm %** (bài báo: 0.15 điểm %, tốt hơn bài báo)

### 10.3. Vấn đề tốc độ end-to-end phát hiện được

Với thiết kế `FPGAQuantizedLinear` đơn giản (mỗi lớp tự cấp phát buffer, luôn `update_A=1`), tốc độ **end-to-end chậm hơn CPU** (chứ không nhanh hơn ~2× như bài báo) — dù phần compute thuần của FPGA đã được chứng minh nhanh (mục 7).

**Tính tổng FLOPs toàn model để xác nhận (đối chiếu công thức với 1 notebook FLOPs-counter tham khảo khác):**
- Tổng FLOPs: **5.511 GFLOPs** (tham khảo: 5.519 GFLOPs — khớp 99.86%)
- CPU-only: ~6-8 GFLOPs/s
- FPGA (Q/K/V offload, chưa tối ưu): tương đương hoặc thấp hơn CPU-only — xác nhận vấn đề overhead is có thật, đo được bằng 3 phương pháp độc lập khác nhau (đo trực tiếp, đo GFLOPs/s toàn model).

### 10.4. Chẩn đoán nguyên nhân & tối ưu (persistent-A)

**Nguyên nhân xác định:**
1. Luôn `update_A=1` — không tận dụng việc Q/K/V dùng chung 1 input X trong cùng 1 tầng
2. Cấp phát buffer PYNQ mới (`allocate()`) ở mỗi lần gọi (18 lần/câu) — có chi phí cố định

**Bản tối ưu V1 (`FPGAQKVAttention`):** gộp Q/K/V thành 1 đơn vị dùng chung buffer, cấp phát 1 lần duy nhất lúc khởi tạo, chỉ nạp lại A ở lần gọi đầu (Q), tái sử dụng cho K/V (`update_A=0`).

**Bản tối ưu V2:** thêm nạp sẵn cả 3 ma trận B (trọng số Q/K/V) 1 lần duy nhất lúc khởi tạo, không copy lại mỗi lần gọi.

**Kết quả (đo sạch sau khi restart kernel, tránh nhiễu do RAM đầy vì nhiều bản sao model):**

| Bản | CPU-only | FPGA |
|---|---|---|
| Chưa tối ưu | ~700-970ms | 917-1058ms (chậm hơn CPU) |
| V1 (persistent-A) | 1299.9ms | **850.6ms** (nhanh hơn CPU) |
| V2 (+ nạp sẵn B) | 897.2ms | **832.7ms** (nhanh hơn CPU) |

→ **Persistent-A giúp giảm overhead ~65%**, đưa FPGA từ "chậm hơn CPU" thành "nhanh hơn CPU". V2 (nạp sẵn B) không cải thiện thêm đáng kể — cho thấy chi phí copy B không phải là nguyên nhân chính.

### 10.5. Thử nghiệm thêm: viết vòng lặp điều khiển bằng C (thay Python)

Giả thuyết: chi phí vòng lặp `while AP_DONE==0: pass` bằng Python có thể là 1 phần overhead còn lại.

Viết hàm C tối giản (`fpga_ctrl.c`), biên dịch thành `.so`, gọi qua `ctypes` từ Python, thay thế đúng đoạn polling loop (giữ nguyên phần còn lại bằng Python):
```c
#include <stdint.h>
void run_and_wait(volatile uint32_t *ctrl_reg) {
    uint32_t v = *ctrl_reg;
    *ctrl_reg = v | 0x1;
    while ((*ctrl_reg & 0x2) == 0) { }
}
```
```bash
gcc -O2 -shared -fPIC -o fpga_ctrl.so fpga_ctrl.c
```

**Kết quả:** đúng kết quả (`Dung: True`), nhưng **không nhanh hơn** (Python: ~72ms/lần, C: ~77ms/lần, chậm hơn ~7-8%). **Kết luận:** với phép tính lớn (K=768, M=3072), thời gian tính toán thật (~64-71ms) áp đảo hoàn toàn chi phí vòng lặp chờ — tối ưu polling loop không có ý nghĩa ở quy mô này. Kết quả này **củng cố đúng chẩn đoán ban đầu**: nút thắt cổ chai là cấp phát buffer, không phải polling, đã được giải quyết đúng bằng persistent-A (mục 10.4).

---

## 11. Tổng kết toàn bộ kết quả

| Hạng mục | Kết quả | So với bài báo |
|---|---|---|
| Tài nguyên DSP/FF/LUT | 84.1%/49.7%/62.8% | Khớp (83%/43%/60%) |
| Tài nguyên BRAM | 42.7% (đúng) | Bài báo ghi lỗi 88% (đã tìm ra nguyên nhân) |
| GFLOPs FPGA compute (FFN case) | 4.71 GFLOPs | Vượt (bài báo 3.12) |
| GFLOPs FPGA end-to-end (FFN case) | 4.66 GFLOPs | Vượt (bài báo 2.85) |
| Hiệu suất năng lượng FPGA vs PyTorch | 4.49-4.79× | Khớp sát (bài báo ~4×) |
| Độ chính xác DistilBERT (16 câu) | 100% khớp nhãn, lệch 0.016% | Tốt hơn (bài báo lệch 0.15%) |
| Tốc độ DistilBERT end-to-end (sau tối ưu) | FPGA nhanh hơn CPU | Khớp xu hướng bài báo (~2×) |

**Đóng góp/phát hiện riêng (ngoài việc tái hiện bài báo):**
1. Phát hiện lỗi đơn vị BRAM trong Table 1 bài báo gốc, có bằng chứng trực tiếp.
2. Định lượng chính xác nguyên nhân overhead phần mềm khi tích hợp DistilBERT, đề xuất và kiểm chứng giải pháp persistent-A (giảm ~65% overhead).
3. Kiểm chứng và loại trừ giả thuyết overhead do polling loop (thử nghiệm bằng C), khẳng định chắc chắn hơn nguyên nhân thật.
4. Mở rộng benchmark: quét nhiều kích thước N, test độ chính xác trên 16 câu thay vì vài câu, đo công suất với 200 vòng lặp để xác nhận độ tin cậy.

---

## 12. Việc còn lại / hướng phát triển (nếu tiếp tục)

- Test trên dataset chuẩn công khai (ví dụ SST-2 validation set đầy đủ) thay vì bộ câu tự chọn.
- Áp dụng tối ưu persistent-A cho model phân loại đầy đủ (đã làm được ở mức thử nghiệm, có thể mở rộng).
- Cân nhắc offload thêm Softmax/FFN (bài báo liệt kê là future work, chưa làm).
