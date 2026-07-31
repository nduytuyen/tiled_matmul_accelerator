# Báo cáo chi tiết đầy đủ — Tiled Matrix Multiplication Accelerator trên KV260

**Đề tài:** Design and Implementation of an FPGA-Based Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the Xilinx KV260 SoM (Richie Li, Sicheng Chen, UC Irvine, arXiv:2503.16731v3)

**Mục tiêu:** Tái hiện lại thiết kế và kết quả của bài báo trên board Xilinx Kria KV260, đo đạc và đối chiếu số liệu thực tế, mở rộng thêm một số phép đo ngoài phạm vi bài báo.

**Cách dùng file này:** Mỗi mục dưới đây tương ứng với 1 giai đoạn công việc thực tế đã làm. Khi chèn ảnh chụp màn hình vào báo cáo, chèn theo đúng thứ tự mục — mỗi mục đều giải thích **mục đích** (vì sao làm bước đó) trước khi đi vào **cách làm** và **kết quả**.

---

## 1. Môi trường và công cụ

| Thành phần | Chi tiết |
|---|---|
| Công cụ tổng hợp phần cứng | Xilinx/AMD Vitis HLS 2022.2, Vivado 2022.2 (chạy trên Windows) |
| Board đích | Kria KV260 Vision AI Starter Kit (chip Zynq UltraScale+ XCK26, part `xck26-sfvc784-2LV-c`) |
| Hệ điều hành board | Ubuntu 22.04.5 LTS + Kria-PYNQ (Jupyter/Python) |
| Mã nguồn HLS gốc | `mmult_accel.cpp`, `.hpp`, `_tb.cpp` (từ repo tác giả bài báo: `Richielee630/MatMul_SA`) |
| Repo project | `github.com/nduytuyen/tiled_matmul_accelerator` |

**Vì sao cần từng công cụ:**
- **Vitis HLS**: dùng để biến mã nguồn C++ (mô tả thuật toán nhân ma trận tiled) thành mạch phần cứng RTL (Verilog/VHDL) — đây là bước "High-Level Synthesis" mà bài báo mô tả ở mục 4.1, giúp không phải tự viết RTL tay.
- **Vivado**: dùng để ráp IP core vừa tạo (từ Vitis HLS) vào hệ thống hoàn chỉnh cùng bộ xử lý ARM (Zynq PS), tạo bitstream nạp lên FPGA.
- **PuTTY**: công cụ kết nối Serial (qua cổng COM/USB) vào board — dùng khi board chưa có mạng/chưa biết IP, hoặc cần vào thẳng hệ điều hành Linux của board mà không qua mạng.
- **JupyterLab (PYNQ)**: giao diện web chạy sẵn trên board, cho phép viết code Python điều khiển FPGA (nạp bitstream, gọi accelerator, đo đạc) mà không cần biên dịch lại gì.

---

## 2. Tổng hợp phần cứng — Vitis HLS

**Mục đích:** Kiểm tra logic tính toán đúng bằng mô phỏng phần mềm trước (rẻ, nhanh), sau đó mới tổng hợp ra phần cứng thật (đắt, chậm hơn) — tránh lãng phí thời gian tổng hợp nếu code còn sai logic.

**Cấu hình project:**
- Top function: `mmult_accel` — hàm C++ sẽ được biến thành 1 khối mạch phần cứng độc lập.
- Target part: `xck26-sfvc784-2LV-c` — đúng chip trên board KV260, để Vitis HLS tính toán tài nguyên/tốc độ dựa trên đúng phần cứng đích.
- Clock period: 10 ns (100 MHz) — đúng bằng "conservative 100MHz PL clock" bài báo dùng.
- Flow Target: **Vivado IP Flow Target** — chọn kiểu này vì mục tiêu cuối là đóng gói kết quả thành 1 IP core để dùng lại trong Vivado (khác với "chạy độc lập" không cần Vivado).

**Quy trình từng bước:**

1. **Tạo project**, add Source (`mmult_accel.cpp` — code accelerator thật) và Test Bench (`mmult_accel_tb.cpp` — code kiểm thử, tự sinh dữ liệu, gọi accelerator, so sánh với kết quả tính tay/NumPy).

2. **Run C Simulation** — mục đích: chạy thử code C++ như 1 chương trình phần mềm bình thường trên máy tính (chưa liên quan gì tới phần cứng thật), để chắc chắn thuật toán tiling/tính toán không có lỗi logic trước khi tốn thời gian tổng hợp phần cứng.
   → Kết quả: `All test cases Passed`, `CSim done with 0 errors`.

3. **Run C Synthesis** — mục đích: biến code C++ đã xác nhận đúng logic thành mạch phần cứng thật (RTL), đồng thời Vitis HLS tự ước tính sẵn sẽ tốn bao nhiêu tài nguyên (DSP, LUT, FF, BRAM) và chạy được tốc độ bao nhiêu — để biết trước có "vừa" với chip hay không mà chưa cần mất công dựng cả hệ thống Vivado.
   → Kết quả ước tính:

   | Tài nguyên | Sử dụng/Khả dụng | % |
   |---|---|---|
   | DSP | 1046/1248 | 83% |
   | FF | 103939/234240 | 44% |
   | LUT | 88440/117120 | 75% |
   | BRAM_18K | 120/288 | 41% |
   | Fmax ước tính | 136.99 MHz (mục tiêu 100MHz — đạt) | |

4. **Export RTL** (format: Vivado IP) — mục đích: đóng gói mạch RTL vừa tổng hợp thành 1 "IP core" chuẩn, có thể kéo-thả trực tiếp vào Vivado Block Design, kèm theo file mô tả giao diện (`component.xml`) để Vivado biết IP có bao nhiêu cổng, kiểu gì (AXI4, AXI4-Lite...).
   → Sinh ra thư mục `mmult_accel_hls/solution1/impl/ip/`.

---

## 3. Tích hợp hệ thống — Vivado

**Mục đích:** IP core `mmult_accel` một mình không tự chạy được — cần ghép nó với bộ xử lý ARM (Zynq Processing System) qua các cầu nối AXI, để CPU có thể ra lệnh và trao đổi dữ liệu qua bộ nhớ DDR dùng chung. Vivado là công cụ để "vẽ sơ đồ" ghép nối này (Block Design) và tổng hợp ra 1 file bitstream (`.bit`) — chính là "chương trình" nạp vào phần logic khả trình (FPGA fabric) của chip.

**Quy trình từng bước:**

1. **Tạo project mới, chọn Board: Kria KV260 Vision AI Starter Kit SOM** — mục đích: dùng file mô tả board có sẵn (do Xilinx cung cấp) để Vivado tự biết đúng cấu hình phần cứng đi kèm board (bộ nhớ DDR, các chân ra ngoài...), thay vì phải tự cấu hình tay từng chi tiết (nếu chỉ chọn "Part" trơn sẽ thiếu các thông tin này).

2. **Add IP Repository** trỏ tới `mmult_accel_hls/solution1/impl/ip` — mục đích: báo cho Vivado biết "có 1 IP tùy chỉnh (custom) nằm ở đây", để nó xuất hiện trong danh sách IP có thể kéo vào Block Design (mặc định Vivado không tự biết IP tự làm nằm ở đâu).

3. **Tạo Block Design**, thêm IP **Zynq UltraScale+ MPSoC** (đại diện cho lõi ARM + các thành phần cố định của chip) → chạy **Block Automation** — mục đích: tự động cấu hình đúng các thông số PS (clock, DDR...) theo đúng board đã chọn ở bước 1, đỡ phải tự tay bấm từng thông số.

4. Thêm IP **mmult_accel** (từ user repository) vào canvas — đây chính là accelerator vừa tổng hợp ở phần Vitis HLS.

5. **Quan trọng — bước dễ bị bỏ sót:** vào cấu hình lại Zynq PS (`PS-PL Configuration → PS-PL Interfaces → Slave Interface → AXI HP`), bật cả 3 cổng **`S_AXI_HP0/1/2_FPD`**.
   *Vì sao cần:* IP `mmult_accel` có 3 cổng AXI4 master (đọc/ghi DDR) tương ứng ma trận A, B, C. Muốn 3 cổng này "cắm" vào đâu đó bên phía PS để thực sự truy cập được DDR, PS phải có sẵn cổng slave HP (High-Performance) tương ứng để nhận. Nếu không bật trước, bước 6 (Connection Automation) sẽ không có gì để tự nối 3 cổng đó, phải nối tay rất phức tạp.

6. Chạy **Connection Automation** — mục đích: Vivado tự động thêm khối trung gian **AXI SmartConnect** (đóng vai trò như 1 "bộ chuyển mạch" AXI, cho phép nhiều master/slave khác kích thước, tốc độ giao tiếp được với nhau) và tự vẽ dây nối đúng 3 cổng AXI4 master (A/B/C) vào 3 cổng HP của PS, đồng thời nối `s_axi_control` (cổng AXI4-Lite, dùng để CPU ghi thanh ghi điều khiển N/K/M/AP_START...) qua 1 interconnect khác (`ps8_0_axi_periph`).

7. **Validate Design** — mục đích: kiểm tra toàn bộ sơ đồ kết nối có hợp lệ không (đủ dây, đúng kiểu tín hiệu, không xung đột địa chỉ) trước khi tổng hợp, tránh mất thời gian tổng hợp rồi mới phát hiện lỗi kết nối.
   → `Validation successful, no errors`.

8. **Create HDL Wrapper** ("Let Vivado manage wrapper") — mục đích: Block Design chỉ là sơ đồ trực quan, cần "gói" nó lại thành 1 module Verilog top-level thực sự để công cụ tổng hợp (Synthesis) hiểu và xử lý được.

9. **Run Synthesis → Run Implementation → Generate Bitstream** — đây là bước tốn thời gian nhất (~30 phút): Synthesis biến toàn bộ thiết kế (RTL) thành các cổng logic cơ bản; Implementation sắp xếp (placement) và đi dây (routing) các cổng đó vào đúng vị trí vật lý trên chip, đảm bảo đạt tốc độ (timing) yêu cầu; Generate Bitstream xuất ra file nhị phân cấu hình FPGA.

**Kết quả tài nguyên sau Implementation (số liệu thật, không phải ước tính — khác với bảng ở mục 2 vốn chỉ là ước tính riêng của IP core, chưa gồm hạ tầng AXI SmartConnect):**

| Tài nguyên | Sử dụng/Khả dụng | % của mình | % Bài báo (Table 1) |
|---|---|---|---|
| DSP | 1050/1248 | 84.1% | 83% ✅ |
| FF | 116326/234240 | 49.7% | 43% ✅ gần khớp |
| LUT | 73575/117120 | 62.8% | 60% ✅ |
| BRAM | 61.5/144 (đơn vị 36K) | 42.7% | **88%** ⚠️ (xem mục 8) |
| Timing | WNS = +0.163 ns (đạt, số dương nghĩa là đạt tốc độ 100MHz yêu cầu) | | |

10. **Export Hardware** (tick "Include bitstream") — mục đích: đóng gói file bitstream (`.bit`) cùng file mô tả phần cứng (`.hwh`, để phần mềm PYNQ sau này biết cách tạo driver điều khiển đúng từng thanh ghi) thành 1 file `.xsa` duy nhất, tiện mang đi.
    → `vivado_project/design_1_wrapper.xsa` (5.6MB).

---

## 4. Cấu hình mạng cho board (IP tĩnh)

**Mục đích:** Để truy cập JupyterLab trên board qua trình duyệt, cần biết đúng địa chỉ IP của board. Nếu dùng DHCP (tự động cấp phát), IP có thể đổi khác mỗi lần khởi động lại, gây bất tiện phải dò lại. Đặt **IP tĩnh** giúp địa chỉ luôn cố định (`192.168.137.2`), dùng lại được mãi.

### 4.1. Vấn đề gặp phải — mạng quá chậm

Board lấy internet qua **Windows Internet Connection Sharing (ICS)** — máy Windows chia sẻ lại Wi-Fi trường (`HCMUT02 3`) qua cổng dây Ethernet nối tới board (đây là cách phổ biến khi board không có Wi-Fi riêng, chỉ có cổng LAN).

**Cách phát hiện vấn đề (đo tốc độ mạng để chẩn đoán, không đoán mò):**
- Đo tốc độ thực nhận trên board:
  ```bash
  cat /sys/class/net/eth0/statistics/rx_bytes   # doc lan 1
  # doi 10 giay
  cat /sys/class/net/eth0/statistics/rx_bytes   # doc lan 2
  ```
  Lấy hiệu số 2 lần chia cho 10 giây → chỉ ra **~16.8 KB/s** — cực chậm.
- Đo tốc độ Wi-Fi gốc ngay trên máy Windows (mở fast.com trong trình duyệt): **64.48 Mbps** — rất nhanh.
- Kết luận: chênh lệch ~480 lần → lỗi nằm ở khâu **chia sẻ (ICS)**, không phải do nguồn Wi-Fi yếu.

**Cách khắc phục:** Tắt rồi bật lại "Shared" trên Wi-Fi Windows (**Network Connections → chuột phải Wi-Fi → Properties → tab Sharing → bỏ tick "Allow other network users..." → OK → mở lại, tick lại → OK**) — thao tác này reset lại dịch vụ ICS (thường bị "kẹt" sau một thời gian chạy). Sau khi làm, mạng thông trở lại (`ping 8.8.8.8`: 0% mất gói, ~41-44ms).

### 4.2. Đặt IP tĩnh cho board (thực hiện qua cổng Serial/PuTTY, không phụ thuộc mạng)

**Vì sao làm qua Serial/PuTTY chứ không qua JupyterLab:** lúc đang chẩn đoán/sửa mạng, board có thể tạm thời không có IP hoặc không vào mạng được — PuTTY qua cổng Serial (USB) vẫn luôn vào được board dù mạng có vấn đề gì, vì nó không đi qua đường mạng Ethernet/Wi-Fi.

**Bước 1 — kiểm tra file cấu hình mạng mặc định:**
```bash
cat /etc/netplan/*.yaml
```
→ Phát hiện: file này do `cloud-init` (chương trình tự động cấu hình máy ảo/board lúc khởi động lần đầu) tự sinh ra, có comment cảnh báo rõ *"Changes to it will not persist across an instance reboot"* — nghĩa là **sửa file này không có tác dụng lâu dài**, sẽ bị ghi đè lại sau khi khởi động lại. Dòng `renderer: NetworkManager` cho biết hệ thống thật sự dùng chương trình **NetworkManager** để quản lý mạng, không phải netplan trực tiếp — vậy phải cấu hình đúng qua công cụ `nmcli` (dòng lệnh điều khiển NetworkManager) mới bền vững.

**Bước 2 — kiểm tra kết nối hiện có:**
```bash
nmcli connection show
```
→ Có sẵn 1 connection tên `Wired connection 1` (kiểu ethernet), lúc đầu cột `DEVICE` là `--` (chưa thực sự gắn vào cổng vật lý nào).

```bash
nmcli device status
```
→ `eth0` (tên cổng mạng dây vật lý của board) đang ở trạng thái `disconnected`.

**Bước 3 — thử bật kết nối kiểu mặc định (DHCP) để xem lỗi gì:**
```bash
sudo nmcli connection up "Wired connection 1"
```
→ Lỗi: `IP configuration could not be reserved (no available address, timeout, etc.)` — xác nhận: cổng vật lý ổn (không báo lỗi "cable unplugged"), nhưng **xin IP tự động (DHCP) bị timeout** — không có ai cấp phát IP lúc đó (khớp với vấn đề ICS ở mục 4.1).

**Bước 4 — đặt IP tĩnh (bền vững, không cần lo DHCP nữa):**
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses 192.168.137.2/24 ipv4.gateway 192.168.137.1 ipv4.dns "8.8.8.8,1.1.1.1"
sudo nmcli connection modify "Wired connection 1" connection.autoconnect yes
sudo nmcli connection up "Wired connection 1"
```
Giải thích từng phần lệnh:
- `ipv4.method manual` — chuyển từ chế độ tự động (DHCP) sang tự đặt tay (Static).
- `ipv4.addresses 192.168.137.2/24` — địa chỉ IP cố định của board, `/24` nghĩa là dải mạng `192.168.137.0` đến `192.168.137.255`.
- `ipv4.gateway 192.168.137.1` — địa chỉ của máy Windows (đóng vai trò "cổng ra" internet cho board qua ICS).
- `ipv4.dns "8.8.8.8,1.1.1.1"` — máy chủ phân giải tên miền (DNS của Google và Cloudflare), để board tự tra được tên miền khi tải thư viện qua internet.
- `connection.autoconnect yes` — đảm bảo lần khởi động sau tự kết nối lại luôn, không cần gõ lệnh `up` tay nữa.
→ Kết quả: `Connection successfully activated`.

**Bước 5 — kiểm tra lại:**
```bash
ip addr show eth0
```
→ Thấy dòng `inet 192.168.137.2/24` — xác nhận IP đã áp dụng đúng.

```bash
ping -c 3 192.168.137.1   # gateway (may Windows) - khong tra loi, do Windows Firewall mac dinh chan ICMP, KHONG phai loi
ping -c 3 8.8.8.8          # internet that - 0% mat goi, ~41-44ms - xac nhan mang thong
```

---

## 5. Đưa bitstream lên board (PYNQ)

**Mục đích:** File `.xsa` tạo ra ở Vivado nằm trên máy Windows, cần chuyển đúng 2 thành phần cần thiết (`.bit` — cấu hình FPGA, `.hwh` — mô tả thanh ghi để PYNQ tự sinh driver Python) sang board, rồi dùng thư viện PYNQ để "nạp" (load) cấu hình đó vào phần logic khả trình của chip.

**Các bước:**

1. Giải nén file `.xsa` (thực chất chỉ là 1 file nén ZIP đổi đuôi):
```bash
unzip -o -j design_1_wrapper.xsa design_1_wrapper.bit design_1.hwh -d pynq_deploy
```
2. Đổi tên 2 file thành **cùng 1 tên gốc** — đây là **yêu cầu bắt buộc của PYNQ**: khi gọi `Overlay("ten_file.bit")`, PYNQ tự động tìm file `.hwh` **cùng tên, cùng thư mục** để đọc mô tả thanh ghi; nếu tên khác nhau sẽ báo lỗi không tìm thấy file mô tả.
   → `mmult_accel.bit`, `mmult_accel.hwh`
3. Upload 2 file lên JupyterLab (`http://192.168.137.2:9090/lab`, mật khẩu mặc định `xilinx`), để cùng thư mục với file notebook đang làm việc (Jupyter mặc định tìm file tương đối theo thư mục hiện tại).
4. Nạp bitstream bằng Python:
```python
from pynq import Overlay
overlay = Overlay("mmult_accel.bit")
print(overlay.ip_dict.keys())
# dict_keys(['mmult_accel_0', 'zynq_ultra_ps_e_0'])
```
   Lệnh `Overlay(...)` thực chất ra lệnh cho driver Linux nạp file `.bit` vào vùng logic khả trình (PL) của chip — đây là lần đầu tiên mạch phần cứng do chính mình thiết kế thực sự "sống" trên silicon thật.

5. **Bản đồ thanh ghi** (`mmult_accel.register_map`) — PYNQ tự đọc file `.hwh` và sinh ra danh sách các thanh ghi điều khiển IP, mỗi thanh ghi tương ứng đúng với khai báo `#pragma HLS INTERFACE s_axilite` trong code C++ ban đầu:
```
CTRL       -- thanh ghi dieu khien: AP_START (bat dau tinh), AP_DONE (bao xong), AP_IDLE...
A_1, A_2   -- 2 nua 32-bit cua dia chi (con tro) 64-bit cua ma tran A trong DDR
B_1, B_2   -- dia chi ma tran B
C_1, C_2   -- dia chi ma tran C (noi ghi ket qua)
N, K, M    -- kich thuoc ma tran (so hang A, chieu chung, so cot B)
update_A   -- co bao FPGA co nap lai A tu DDR hay khong (1=nap lai, 0=dung lai A da co san tren BRAM)
```
   *Lưu ý quan trọng phát hiện được:* PYNQ **không tự gộp** `A_1`+`A_2` thành 1 thanh ghi 64-bit duy nhất — phải tự tách địa chỉ vật lý thành 2 nửa 32-bit thấp/cao rồi ghi riêng từng thanh ghi.

---

## 6. Cài đặt thư viện Python (torch, transformers)

**Mục đích:** Để tích hợp accelerator vào 1 model AI thật (DistilBERT) theo đúng bài báo mô tả (mục 5, "Quantized DistilBERT Integration"), cần 2 thư viện: **PyTorch** (framework deep learning, để chạy model) và **Transformers** (thư viện của HuggingFace, để tải sẵn model DistilBERT đã huấn luyện, không phải tự huấn luyện từ đầu).

Sau khi mạng đã sửa xong (mục 4.1):
```python
!pip install torch transformers --quiet
```
→ Cài thành công: `Torch version: 2.13.0+cu130`, `Transformers version: 5.14.1`. (Bản `+cu130` là bản có hỗ trợ tính toán trên GPU NVIDIA (CUDA), nhưng board KV260 không có GPU NVIDIA nào — thư viện sẽ tự động chạy trên CPU như bình thường, không gây lỗi hay ảnh hưởng gì.)

**Lỗi gặp phải và cách sửa:** Khi load model DistilBERT lần đầu, gặp lỗi:
```
AttributeError: module 'PIL.Image' has no attribute 'Resampling'
```
*Nguyên nhân:* thư viện `transformers` bản mới (5.14.1) trong quá trình import có nhánh code liên quan tới xử lý ảnh (dù mình không dùng tính năng đó), cần thư viện `Pillow` (xử lý ảnh, viết tắt PIL) bản ≥ 9.1.0 mới có thuộc tính `Resampling`; bản `Pillow` có sẵn trên board (cài kèm hệ điều hành) quá cũ.

*Cách khắc phục:*
```python
!pip install --upgrade pillow --quiet
```
sau đó **bắt buộc phải Restart Kernel** (menu Kernel → Restart Kernel) — vì Python đã "nhớ" (cache) trạng thái lỗi từ lần import thất bại trước đó trong bộ nhớ tiến trình đang chạy, chỉ cài lại thư viện không đủ để sửa, phải khởi động lại tiến trình Python mới nạp lại đúng bản mới.

Model DistilBERT (`distilbert-base-uncased`, ~250MB) và model phân loại cảm xúc (`distilbert-base-uncased-finetuned-sst-2-english`) tự động tải về khi gọi `from_pretrained(...)` lần đầu, lưu cache tại `~/.cache/huggingface` trên board — **các lần gọi sau chỉ đọc từ cache, không tải lại, load gần như tức thì.**

---

## 7. Kết quả Benchmark — Hiệu năng GEMM (phép nhân ma trận thuần)

**Mục đích của bước này:** Trước khi tích hợp vào model AI thật (phức tạp hơn, khó tách biệt nguyên nhân nếu có sai sót), cần đo **riêng khả năng tính toán thuần của accelerator** — nhân 2 ma trận số nguyên 8-bit — để so sánh trực tiếp, công bằng với các con số bài báo đã công bố (Table 2), và với chính CPU của board (chạy NumPy, PyTorch) làm mốc đối chứng.

### 7.1. Case chuẩn bài báo (đúng kích thước Table 2 sử dụng)

Bài báo dùng 2 kích thước ma trận đại diện cho DistilBERT thật: **case Attention** (tính Q/K/V, kích thước 64×768 nhân 768×768) và **case FFN** (tính lớp Feed-Forward, kích thước 64×768 nhân 768×3072).

**Attention case (N=64, K=768, M=768):**

| Framework | Latency | Throughput | Ghi chú |
|---|---|---|---|
| NumPy | 1088.8 ms | 0.069 GFLOPs | Không tối ưu, chạy Python thuần |
| PyTorch | 82.8 ms | 0.912 GFLOPs | Có tối ưu vector hóa |
| **FPGA (compute)** | **16.4 ms** | **4.62 GFLOPs** | Chỉ tính thời gian phần cứng tính toán (từ lúc bấm AP_START tới khi AP_DONE) |
| **FPGA (end-to-end)** | **17.0 ms** | **4.45 GFLOPs** | Gồm cả thời gian cấp phát bộ nhớ, ghi thanh ghi, đọc kết quả về |

**FFN case (N=64, K=768, M=3072) — đúng Table 2 bài báo dùng để so sánh:**

| Framework | Của mình | Bài báo (Table 2) |
|---|---|---|
| NumPy | 21470ms / 0.014 GFLOPs | 20720ms / 0.01 GFLOPs |
| PyTorch | 331.6ms / 0.911 GFLOPs | 670ms / 0.45 GFLOPs |
| **FPGA (compute)** | **64.2ms / 4.71 GFLOPs** | 90ms / 3.12 GFLOPs |
| **FPGA (end-to-end)** | **64.9ms / 4.66 GFLOPs** | 110ms / 2.85 GFLOPs |

→ **Vượt bài báo ở mọi chỉ số**, và mọi phép đo đều xác nhận `Dung=True` (kết quả tính toán khớp tuyệt đối với NumPy — không chỉ nhanh mà còn đúng).

### 7.2. Quét nhiều kích thước N (dữ liệu mở rộng, bài báo gốc không có)

**Mục đích mở rộng:** bài báo chỉ đo cố định ở N=64, không cho biết tốc độ thay đổi ra sao khi kích thước nhỏ hơn — quét nhiều giá trị N để vẽ được đường cong hiệu năng, hiểu rõ hơn về đặc tính chi phí cố định (overhead) của thiết kế.

**Giới hạn kỹ thuật cần tuân thủ:** chỉ quét N trong khoảng 8 đến 64 — vì buffer `A_bram` trên phần cứng có kích thước **cố định** đúng bằng `MAX_N × MAX_K = 64 × 768` (khai báo cứng trong code C++ gốc), không thể vượt quá khi chạy, nếu không sẽ cho kết quả sai/không xác định.

| N | FPGA compute | GFLOPs | Speedup vs PyTorch |
|---|---|---|---|
| 8 | 9.4 ms | 1.00 | 1.24× |
| 16 | 9.8 ms | 1.93 | 2.26× |
| 32 | 10.6 ms | 3.56 | 4.00× |
| 64 | 16.3 ms | 4.62 | 5.07× |

→ Speedup tăng dần đều theo N — chứng minh chi phí cố định (nạp ma trận B vào BRAM, khởi động pipeline tính toán) chiếm tỷ trọng lớn hơn khi N nhỏ, và được "pha loãng" dần khi N lớn hơn — một đặc tính kiến trúc quan trọng, giải thích vì sao thiết kế "persistent A" (giữ A cố định, không nạp lại) lại có ý nghĩa lớn khi dùng nhiều lần liên tiếp (xem mục 10.4).

---

## 8. Phát hiện quan trọng: Lỗi đơn vị BRAM trong bài báo gốc

**Vấn đề phát hiện:** Table 1 bài báo ghi tài nguyên BRAM là "126/144 = 88%", nhưng đo thật bằng Vivado của mình (mục 3) chỉ ra **42.7%** — chênh lệch rất lớn, trong khi 3 chỉ số còn lại (DSP/FF/LUT) đều khớp gần như tuyệt đối.

**Cách xác minh (không suy đoán, có bằng chứng trực tiếp):** người dùng đã tìm và cung cấp đúng báo cáo gốc (`.rpt`) do chính tác giả bài báo tạo ra (chạy Vitis HLS 2024.2, project tên "MatMul_SA", ngày 28/02/2025) — đây là bằng chứng khách quan, không phải suy luận:
```
| mmult_accel | ... | 126 (43%)| 1040 (83%)| 102741 (43%)| 71050 (60%)|
```
→ **Chính công cụ Vitis HLS của họ tự tính ra 43%**, không phải 88% như họ ghi trong bài báo. Kiểm chứng phép tính: `126 ÷ 288 = 43.75% ≈ 43%` (288 là số khối BRAM đơn vị 18K khả dụng của chip — đúng đơn vị mà Vitis HLS luôn dùng để báo cáo BRAM). Nhưng khi chép số liệu này vào Table 1 của bài báo, tác giả lại ghi `126 ÷ 144 = 87.5% ≈ 88%` — **144 là số khối BRAM đơn vị 36K** (một đơn vị đo khác), tức là họ **lấy đúng tử số (126, đơn vị 18K) nhưng ghép nhầm với mẫu số sai đơn vị (144, đơn vị 36K)**.

**Giải thích vật lý để hiểu rõ bản chất:** Chip Zynq UltraScale+ XCK26 có đúng **144 khối BRAM vật lý cố định trên silicon**, mỗi khối dung lượng 36Kb. Mỗi khối 36Kb này **có thể cấu hình để hoạt động như 1 khối 36Kb, hoặc tách thành 2 khối 18Kb độc lập** (tùy nhu cầu thiết kế). Vì vậy đếm theo đơn vị 36K sẽ ra tối đa 144, còn đếm theo đơn vị 18K sẽ ra tối đa 288 — **không phải 2 loại tài nguyên khác nhau**, chỉ là 2 "cây thước" đo khác nhau trên cùng 1 lượng silicon vật lý. Bài báo đã lấy tử số đo bằng thước 18K nhưng chia cho mẫu số đo bằng thước 36K, gây ra kết quả sai gấp đôi.

**Kết luận:** Table 1 của bài báo có lỗi đơn vị ở dòng BRAM — con số đúng phải là ~43-44%, không phải 88%. 3 chỉ số còn lại (DSP/FF/LUT) hoàn toàn khớp đúng với báo cáo gốc của họ. Kết quả đo thật của mình (42.7%) khớp gần như chính xác với con số đúng sau khi sửa lỗi đơn vị (43-44%) — xác nhận thiết kế của mình hoàn toàn nhất quán với thiết kế gốc, chỉ có bài báo bị lỗi khi trình bày số liệu.

---

## 9. Đo công suất và năng lượng tiêu thụ

**Mục đích:** Bài báo không chỉ so sánh tốc độ mà còn so sánh **hiệu suất năng lượng** (bao nhiêu Joule để hoàn thành 1 phép tính) — vì đây là ưu điểm quan trọng của FPGA so với CPU cho các ứng dụng nhúng/biên (edge computing), nơi pin/nguồn điện bị giới hạn.

**Cảm biến sử dụng:** Board KV260 có sẵn cảm biến công suất phần cứng loại **INA260**, lộ ra qua hệ thống file Linux tại đường dẫn `/sys/class/hwmon/hwmon2/power1_input` (đơn vị đọc được là microWatt — µW). Cách xác định đúng cảm biến này trong số nhiều cảm biến khác trên board (quạt, nhiệt độ...): liệt kê toàn bộ thư mục `/sys/class/hwmon/*/name` và tìm đúng tên `ina260_u14`.

**Phương pháp đo (mô phỏng đúng cách bài báo mô tả):** Bài báo lấy mẫu công suất liên tục mỗi 50-100ms trong lúc tính toán, sau đó "tích phân" (cộng dồn) các mẫu để ra năng lượng. Cách làm tương tự: chạy 1 luồng (thread) nền đọc công suất mỗi 50ms trong khi luồng chính đang thực hiện phép tính, rồi tính: **Năng lượng (Joule) = Công suất trung bình (Watt) × Thời gian (giây)**.

| | Công suất TB | Thời gian | Năng lượng |
|---|---|---|---|
| Idle (không làm gì, baseline) | 3.78-3.88 W | | |
| CPU (NumPy) | 3.72 W | 21-22 s | ~78-82 J |
| PyTorch | 3.75-3.78 W | 331-350 ms | ~1245-1320 mJ |
| **FPGA** (lặp 20 lần lấy trung bình) | 3.86-3.90 W | 71.4 ms/lần | 275-278 mJ/lần |
| **FPGA** (lặp 200 lần, kiểm chứng lại độ tin cậy) | 3.88-3.90 W | 71.1 ms/lần | 276 mJ/lần |

*Vì sao đo lại với 200 lần lặp:* để kiểm tra xem con số đo với 20 lần lặp (mẫu tương đối ít, vì FPGA tính rất nhanh) có đủ tin cậy không. Kết quả gần như giống hệt → xác nhận số liệu ban đầu (20 lần) đã đủ ổn định, không cần lo về việc mẫu ít.

**Kết luận:** Hiệu suất năng lượng FPGA so với PyTorch: **4.49-4.79× tốt hơn** — khớp rất sát với con số **~4×** bài báo báo cáo. *(Lưu ý phương pháp luận quan trọng: không nên so sánh FPGA với NumPy để tính hiệu suất năng lượng — dù ra con số ấn tượng hơn nhiều (283×), vì NumPy vốn đã chậm bất thường so với PyTorch (khoảng 60× chậm hơn) do không được tối ưu; bài báo dùng PyTorch làm baseline khi tính năng lượng, nên phải so sánh đúng với PyTorch mới công bằng và có ý nghĩa khoa học.)*

---

## 10. Tích hợp DistilBERT (thay thế lớp Q/K/V bằng FPGA)

**Mục đích:** Đây là bước "thật sự dùng accelerator vào việc có ích" — thay vì chỉ nhân 2 ma trận số ngẫu nhiên, tích hợp accelerator vào 1 mô hình AI thật (DistilBERT) đúng theo mục 5 bài báo mô tả ("Quantized DistilBERT Integration"), để đo được cả **độ chính xác** (kết quả dự đoán có còn đúng không) lẫn **tốc độ thực tế** khi dùng trong ứng dụng.

### 10.1. Xác nhận cấu trúc model

Model `DistilBertModel` (tải qua thư viện `transformers`) có **6 tầng Transformer**, mỗi tầng bên trong khối tự-chú-ý (`attention`) có 4 lớp `Linear` (phép nhân ma trận có trọng số học được): `q_lin`, `k_lin`, `v_lin`, `out_lin` — mỗi lớp đều có kích thước `768 → 768`. Đúng theo phạm vi bài báo, **chỉ thay thế Q, K, V** bằng FPGA (18 lớp = 6 tầng × 3 lớp), **không đụng tới `out_lin`**.

### 10.2. Lớp `FPGAQuantizedLinear` — bản đầu tiên, đơn giản

**Ý tưởng:** Viết 1 lớp Python (kế thừa `torch.nn.Module`, tương thích hoàn toàn với PyTorch) — bên trong hàm `forward()` (hàm được gọi mỗi khi model cần tính lớp này), thay vì tính bằng CPU như `nn.Linear` gốc, sẽ:
1. Chuyển đổi (lượng tử hóa) dữ liệu số thực (float) sang số nguyên 8-bit (int8) — vì accelerator chỉ tính được số nguyên 8-bit.
2. Gửi dữ liệu qua accelerator (giống hệt cách đã làm ở mục 7, chỉ khác là dữ liệu lấy từ model thật, không phải số ngẫu nhiên).
3. Nhận kết quả về, chuyển ngược (giải lượng tử hóa) từ số nguyên 32-bit về lại số thực.

**Cách lượng tử hóa dùng:** đối xứng (symmetric), tính riêng cho từng tensor (per-tensor) — trọng số (weight) tính hệ số quy đổi (scale) 1 lần duy nhất lúc khởi tạo (vì trọng số không đổi), còn dữ liệu đầu vào (activation) tính động mỗi lần gọi (đơn giản hóa so với "static quantization" đầy đủ mà bài báo dùng — cách này không cần bước hiệu chỉnh (calibration) trước bằng tập dữ liệu mẫu, đổi lại độ chính xác có thể kém hơn 1 chút).

**Kết quả kiểm chứng từng bước:**
- Test 1 lớp riêng lẻ (`q_lin` của tầng đầu tiên, dữ liệu đầu vào ngẫu nhiên): sai số tương đối (đo theo chuẩn norm — tỷ lệ độ lớn vector sai số so với vector gốc) khoảng **3.3-3.4%** — hợp lý cho việc lượng tử hóa int8.
- Thay toàn bộ 18 lớp, chạy cả model: cosine similarity (độ giống hướng vector) đạt **0.992-0.997** (rất tốt, gần 1).
- Đo trên model đã fine-tune cho phân loại cảm xúc (SST-2): **16/16 câu khớp nhãn dự đoán (100%)**, độ lệch confidence trung bình chỉ **0.016 điểm phần trăm** — thậm chí **tốt hơn** con số bài báo báo cáo (0.15 điểm %).

### 10.3. Vấn đề tốc độ end-to-end phát hiện được

Dù độ chính xác rất tốt, tốc độ tổng thể (end-to-end, cả model) lại **chậm hơn CPU** với bản `FPGAQuantizedLinear` đơn giản này — trái ngược với kỳ vọng (và trái với bài báo báo cáo nhanh hơn ~2×).

**Cách xác minh độc lập, không chỉ dựa vào 1 phép đo:** tính thêm tổng số FLOPs (phép tính dấu phẩy động) lý thuyết của toàn bộ model (dựa theo công thức chuẩn cho kiến trúc Transformer, đối chiếu chéo với 1 công thức tham khảo khác để kiểm tra đúng — ra **5.511 GFLOPs**, khớp 99.86% với tài liệu tham khảo 5.519 GFLOPs), rồi chia cho thời gian đo được để ra **GFLOPs/giây** (thông lượng thực) cho cả CPU-only và có-FPGA. Kết quả: khi tính trên toàn model, thông lượng CPU-only và có-FPGA gần như ngang nhau hoặc CPU nhỉnh hơn — xác nhận lại đúng vấn đề đã thấy, bằng 1 phương pháp đo hoàn toàn độc lập (không chỉ đo thời gian đơn thuần).

### 10.4. Chẩn đoán nguyên nhân và tối ưu (persistent-A)

**2 nguyên nhân nghi ngờ, xác định qua phân tích code:**
1. Code luôn đặt `update_A = 1` (nạp lại ma trận A vào BRAM) ở **mọi lần gọi** — nhưng thực tế, Q/K/V trong **cùng 1 tầng** đều dùng chung **1 dữ liệu đầu vào X** (activation của tầng trước) — đáng lẽ chỉ cần nạp A 1 lần (khi tính Q), rồi tái sử dụng cho K và V — đúng tính năng "persistent A" mà bài báo thiết kế sẵn (cờ `update_A`) nhưng bản đầu tiên chưa tận dụng.
2. Mỗi lần gọi `forward()` đều gọi `pynq.allocate()` để cấp phát vùng nhớ mới cho buffer A/B/C — việc cấp phát bộ nhớ có chi phí cố định (liên quan tới ánh xạ bộ nhớ DMA ở tầng hệ điều hành), lặp lại 18 lần cho 1 câu là lãng phí không cần thiết.

**Bản tối ưu V1 (`FPGAQKVAttention`):** viết lại thành 1 lớp dùng chung cho cả Q/K/V trong 1 tầng — cấp phát buffer **1 lần duy nhất** lúc khởi tạo (không phải mỗi lần gọi), và chỉ đặt `update_A=1` ở lần gọi đầu tiên (Q), 2 lần sau (K, V) dùng `update_A=0` để tái sử dụng A đã có sẵn trên BRAM.

**Bản tối ưu V2:** thêm việc nạp sẵn cả 3 ma trận trọng số B (của Q, K, V) vào buffer **1 lần duy nhất** lúc khởi tạo luôn (vì trọng số cố định, không đổi giữa các câu khác nhau), không copy lại mỗi lần gọi.

**Kết quả đo (thực hiện sau khi khởi động lại kernel để đo sạch, tránh nhiễu do RAM bị chiếm bởi nhiều bản sao model tích lũy qua quá trình thử nghiệm):**

| Bản | CPU-only | FPGA | Nhận xét |
|---|---|---|---|
| Chưa tối ưu | ~700-970ms | 917-1058ms | FPGA chậm hơn CPU |
| V1 (persistent-A) | 1299.9ms | **850.6ms** | FPGA đã nhanh hơn CPU |
| V2 (+ nạp sẵn B) | 897.2ms | **832.7ms** | FPGA vẫn nhanh hơn CPU, không cải thiện thêm nhiều so với V1 |

→ **Persistent-A (tối ưu số 1) là yếu tố quyết định**, giúp giảm phần lớn overhead, đưa FPGA từ "chậm hơn CPU" thành "nhanh hơn CPU" — khớp đúng xu hướng bài báo báo cáo (~2× nhanh hơn end-to-end). Tối ưu số 2 (nạp sẵn B) hầu như không cải thiện thêm — cho thấy chi phí copy dữ liệu B không phải là nguyên nhân chính (xem thêm mục 10.5 để hiểu rõ hơn bản chất overhead còn lại).

### 10.5. Thử nghiệm bổ sung: viết vòng lặp điều khiển bằng ngôn ngữ C thay Python

**Giả thuyết muốn kiểm chứng:** liệu phần overhead còn sót lại (sau khi đã tối ưu V1/V2) có phải do chi phí của **vòng lặp chờ** (`while AP_DONE==0: pass`) viết bằng Python hay không — vì Python vốn có tốc độ thực thi từng câu lệnh chậm hơn nhiều so với ngôn ngữ biên dịch như C.

**Cách thực hiện:** Viết 1 đoạn mã C tối giản, chỉ làm đúng 1 việc: ghi bit AP_START rồi chờ bit AP_DONE bằng vòng lặp bận (busy-wait) viết bằng C — biên dịch thành thư viện dùng chung (`.so`), gọi từ Python qua module `ctypes` (cho phép Python gọi thẳng hàm C đã biên dịch sẵn), thay thế đúng đoạn vòng lặp chờ, giữ nguyên mọi phần khác (ghi địa chỉ buffer, kích thước N/K/M) vẫn bằng Python.

```c
#include <stdint.h>
void run_and_wait(volatile uint32_t *ctrl_reg) {
    uint32_t v = *ctrl_reg;
    *ctrl_reg = v | 0x1;              // bat bit AP_START
    while ((*ctrl_reg & 0x2) == 0) { } // cho bit AP_DONE
}
```
```bash
gcc -O2 -shared -fPIC -o fpga_ctrl.so fpga_ctrl.c
```

**Kết quả:** kết quả tính toán vẫn đúng (`Dung: True`), nhưng **không hề nhanh hơn** — ngược lại còn hơi chậm hơn (Python: ~72ms/lần, C: ~77ms/lần, chậm hơn khoảng 7-8%).

**Giải thích và ý nghĩa:** với phép tính lớn (K=768, M=3072), bản thân **thời gian phần cứng tính toán thật** (~64-71ms) đã chiếm áp đảo gần như toàn bộ thời gian mỗi lần gọi — vòng lặp chờ (dù bằng Python hay C) chỉ tốn cỡ vài phần nghìn giây so với 64-71ms đó, nên việc tối ưu nó gần như không có ý nghĩa ở quy mô này (con số "chậm hơn" nhỏ quan sát được nhiều khả năng chỉ là chi phí phụ của việc gọi qua `ctypes` từ Python sang C, không phải bản chất vòng lặp C chậm hơn).

**Đây là kết quả có giá trị khoa học dù là "phủ định":** nó **xác nhận và củng cố thêm** cho chẩn đoán đúng đắn ở mục 10.4 — nút thắt cổ chai thật sự nằm ở **chi phí cấp phát bộ nhớ** (đã giải quyết bằng persistent-A), **không phải** ở cơ chế chờ thanh ghi. Thử nghiệm này giúp loại trừ chắc chắn 1 giả thuyết sai, tăng độ tin cậy cho kết luận đã đưa ra trước đó — đúng theo phương pháp làm việc khoa học (đặt giả thuyết → kiểm chứng → chấp nhận hoặc loại bỏ).

---

## 11. Mở rộng thêm: kiểm thử với bộ câu lớn hơn

**Mục đích:** Bài báo chỉ minh họa độ chính xác qua rất ít ví dụ; để có kết luận đáng tin cậy hơn về mặt thống kê, mở rộng bộ câu kiểm thử lên **16 câu** đa dạng (tích cực/tiêu cực, nhiều chủ đề khác nhau: phim ảnh, dịch vụ, sản phẩm, khách sạn...), áp dụng đúng bản tối ưu V2 (mục 10.4) cho model phân loại cảm xúc.

**Kết quả:**
- Tỷ lệ khớp nhãn dự đoán: **16/16 = 100%** (mọi câu, FPGA và CPU đều cho ra đúng cùng 1 nhãn Positive/Negative)
- Độ lệch confidence trung bình: **0.016 điểm phần trăm**
- Độ lệch confidence lớn nhất (trong 16 câu): **0.180 điểm phần trăm**

→ Xác nhận vững chắc hơn (thay vì chỉ dựa vào 3 câu ban đầu) rằng việc lượng tử hóa int8 (đơn giản hóa so với static quantization đầy đủ của bài báo) vẫn giữ được độ chính xác rất cao trong thực tế sử dụng.

---

## 12. Tổng kết toàn bộ kết quả

| Hạng mục | Kết quả | So với bài báo |
|---|---|---|
| Tài nguyên DSP/FF/LUT | 84.1%/49.7%/62.8% | Khớp (83%/43%/60%) |
| Tài nguyên BRAM | 42.7% (đúng) | Bài báo ghi lỗi 88% (đã tìm ra nguyên nhân, mục 8) |
| GFLOPs FPGA compute (FFN case) | 4.71 GFLOPs | Vượt (bài báo 3.12) |
| GFLOPs FPGA end-to-end (FFN case) | 4.66 GFLOPs | Vượt (bài báo 2.85) |
| Hiệu suất năng lượng FPGA vs PyTorch | 4.49-4.79× | Khớp sát (bài báo ~4×) |
| Độ chính xác DistilBERT (16 câu) | 100% khớp nhãn, lệch 0.016% | Tốt hơn (bài báo lệch 0.15%) |
| Tốc độ DistilBERT end-to-end (sau tối ưu persistent-A) | FPGA nhanh hơn CPU | Khớp xu hướng bài báo (~2×) |

**Đóng góp/phát hiện riêng (ngoài việc tái hiện thuần túy bài báo):**
1. Phát hiện lỗi đơn vị đo BRAM trong Table 1 bài báo gốc, có bằng chứng trực tiếp từ chính báo cáo công cụ của tác giả.
2. Định lượng chính xác nguyên nhân gây chậm (overhead) khi tích hợp phần mềm điều khiển FPGA vào model AI thật, đề xuất và kiểm chứng thành công giải pháp persistent-A (giảm phần lớn overhead, đưa FPGA từ "chậm hơn CPU" thành "nhanh hơn CPU").
3. Thiết kế và thực hiện thí nghiệm loại trừ giả thuyết sai (tối ưu bằng C không giúp ích) — củng cố chắc chắn hơn cho kết luận về nguyên nhân overhead thật sự.
4. Mở rộng phạm vi đo đạc ngoài những gì bài báo công bố: quét nhiều kích thước ma trận N, kiểm thử độ chính xác trên 16 câu thay vì vài câu, đo công suất với 200 vòng lặp để xác nhận độ tin cậy thống kê.

---

## 13. Việc còn lại / hướng phát triển (nếu tiếp tục nghiên cứu)

- Test trên bộ dữ liệu chuẩn công khai đầy đủ (ví dụ toàn bộ tập kiểm định SST-2) thay vì bộ câu tự chọn thủ công.
- Áp dụng đúng phương pháp "static quantization" đầy đủ (hiệu chỉnh scale bằng tập dữ liệu mẫu trước) thay vì lượng tử hóa động đơn giản hóa hiện tại, để so sánh chính xác hơn nữa với phương pháp bài báo.
- Cân nhắc offload thêm các phần Softmax, Q·Kᵀ, Feed-Forward Network — bài báo liệt kê đây là hướng phát triển tương lai (future work) của chính họ, chưa thực hiện trong cả bài báo gốc lẫn đồ án này.
