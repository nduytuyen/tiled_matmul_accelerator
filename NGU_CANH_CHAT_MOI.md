# Ngữ cảnh đầy đủ — dùng để mở đoạn chat mới

**Mục đích file này:** Đoạn chat hiện tại đã gần đầy context window. File này ghi lại toàn bộ những gì đã làm, đã hỏi, và trạng thái hiện tại của đồ án, để khi mở đoạn chat mới, chỉ cần dán file này vào (hoặc nói "đọc file `NGU_CANH_CHAT_MOI.md` trong project trước khi hỗ trợ tiếp") là Claude có đủ ngữ cảnh tiếp tục ngay, không cần giải thích lại từ đầu.

*Lưu ý: file này chỉ để dùng cá nhân/tham khảo lại ngữ cảnh, không bắt buộc phải push lên GitHub công khai (khác với `BAO_CAO_CHI_TIET.md` vốn là báo cáo kỹ thuật dùng cho đồ án).*

---

## 1. Bối cảnh đồ án

- **Đề tài:** Design and Implementation of an FPGA-Based Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the Xilinx KV260 SoM (arXiv:2503.16731v3, tác giả Richie Li & Sicheng Chen, UC Irvine).
- **Mục tiêu:** Tái hiện lại toàn bộ thiết kế và kết quả của bài báo, đo đạc trên board thật, đối chiếu số liệu.
- **Board:** Xilinx Kria KV260 (chip Zynq UltraScale+ XCK26, part `xck26-sfvc784-2LV-c`), chạy Kria-PYNQ (Ubuntu + JupyterLab).
- **Công cụ:** Vitis HLS 2022.2 + Vivado 2022.2 (trên Windows), truy cập board qua JupyterLab (`http://192.168.137.2:9090/lab`, mật khẩu `xilinx`) hoặc PuTTY qua Serial/SSH.
- **Repo GitHub:** `github.com/nduytuyen/tiled_matmul_accelerator` — dùng GitHub Desktop để commit/push (Claude không tự push được, luôn cần người dùng bấm).
- **Người dùng:** sinh viên làm đồ án tốt nghiệp, không rành sâu về Vitis/Vivado/Linux — cần hướng dẫn cực kỳ chi tiết, từng bước, kiểu "chỉ chi tiết cho tôi copy". Luôn xác nhận từng bước xong ("rồi", "ok") trước khi qua bước kế.

## 2. Đã hoàn thành (KHÔNG cần làm lại)

1. ✅ **Vitis HLS**: C-Simulation → C-Synthesis → Export RTL. Project ở `mmult_accel_hls/` (không track git, quá nặng, xem `.gitignore`). Kết quả ước tính: DSP 83%, FF 44%, LUT 75%, Fmax 136.99MHz.
2. ✅ **Vivado**: Block Design (Zynq PS + IP `mmult_accel_0`, đã bật 3 cổng `S_AXI_HP0/1/2_FPD`) → Generate Bitstream → Export Hardware → `vivado_project/design_1_wrapper.xsa` (đã track git, 5.6MB). Kết quả thật: DSP 84.1%, FF 49.7%, LUT 62.8%, BRAM 42.7%, timing đạt (WNS +0.163ns).
3. ✅ **Deploy lên board qua PYNQ**: đổi tên `.bit`/`.hwh` cùng tên gốc (`mmult_accel.bit`/`.hwh`), upload JupyterLab, `Overlay("mmult_accel.bit")` chạy thành công, IP là `overlay.mmult_accel_0`.
4. ✅ **Sửa mạng board**: 2 vấn đề riêng biệt đã fix:
   - Windows ICS bị "kẹt" (tốc độ chỉ 16.8 KB/s dù Wi-Fi gốc 64Mbps) → fix bằng tắt/bật lại "Shared" trong Wi-Fi Properties → Sharing.
   - Đặt IP tĩnh bền vững cho board qua `nmcli` (không phải sửa `/etc/netplan/*.yaml` vì file đó do cloud-init tự sinh, không bền): `sudo nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses 192.168.137.2/24 ipv4.gateway 192.168.137.1 ipv4.dns "8.8.8.8,1.1.1.1"` + `connection.autoconnect yes`.
5. ✅ **Benchmark GEMM thuần** (đúng kích thước bài báo N=64,K=768,M=768 và M=3072): FPGA đúng 100%, **vượt bài báo** ở mọi chỉ số (compute 4.71 GFLOPs vs bài báo 3.12; end-to-end 4.66 vs 2.85). Có thêm quét N=8/16/32/64 (mở rộng, bài báo không có).
6. ✅ **Phát hiện lỗi Table 1 bài báo gốc**: dòng BRAM ghi 88% nhưng đúng ra phải là 43% — họ lấy tử số 126 (đơn vị BRAM_18K) chia nhầm cho mẫu số 144 (đơn vị BRAM_36K). Có bằng chứng trực tiếp: report gốc của chính tác giả (do người dùng cung cấp) tự in ra `126 (43%)`. Đo Vivado của mình cũng ra 42.7% — khớp con số đúng.
7. ✅ **Cài torch/transformers trên board**, fix lỗi Pillow (`AttributeError: PIL.Image.Resampling` → `pip install --upgrade pillow` + bắt buộc Restart Kernel).
8. ✅ **Đo công suất/năng lượng** (cảm biến INA260 qua `/sys/class/hwmon/hwmon2/power1_input`): FPGA hiệu suất năng lượng tốt hơn PyTorch 4.49-4.79× (khớp bài báo ~4×). Đã đo lại với 200 vòng lặp để xác nhận độ tin cậy.
9. ✅ **Tích hợp DistilBERT** (thay Q/K/V linear layers, 18 lớp = 6 tầng × 3):
   - Bản đầu `FPGAQuantizedLinear`: đúng 100% nhãn dự đoán, lệch confidence 0.016% (tốt hơn bài báo 0.15%) — nhưng **chậm hơn CPU** (ngược kỳ vọng).
   - Chẩn đoán nguyên nhân: (a) luôn `update_A=1` dù Q/K/V dùng chung input X; (b) `pynq.allocate()` gọi lại mỗi lần forward.
   - Viết `FPGAQKVAttention` (V1, persistent-A: chỉ nạp A ở lần Q, tái dùng cho K/V) → FPGA nhanh hơn CPU (850.6ms vs 1299.9ms).
   - Viết `FPGAQKVAttention` V2 (+ pre-load B 1 lần) → không cải thiện thêm nhiều (832.7ms vs 897.2ms) — kết quả "âm tính" nhưng có giá trị.
   - Thử nghiệm C-loop (`fpga_ctrl.c` biên dịch `.so`, gọi qua `ctypes` thay vòng lặp chờ Python) → không nhanh hơn, xác nhận overhead thật sự nằm ở cấp phát bộ nhớ (đã fix bằng persistent-A), không phải ở cơ chế polling.
10. ✅ **Mở rộng độ chính xác**: test 16 câu đa dạng thay vì vài câu → 16/16 khớp nhãn, lệch trung bình 0.016%.
11. ✅ **Dọn repo GitHub**: xóa nested folder trùng lặp, thêm `.gitignore` (loại `mmult_accel_hls/`, các thư mục build tự sinh của Vivado), `git rm -r --cached` gỡ ~590 file rác đã lỡ track, giữ lại 6 file có ý nghĩa (gồm `.xsa` 5.6MB). README.md có bảng tài nguyên tự cập nhật qua `scripts/update_readme.sh` (đọc trực tiếp report Vitis HLS, không tốn token AI).
12. ✅ **Viết báo cáo chi tiết** `BAO_CAO_CHI_TIET.md` (13 mục, có giải thích "vì sao/mục đích" từng bước, không chỉ số liệu — dùng để ghép cùng ảnh chụp màn hình cho báo cáo thật) — **vừa mới cập nhật xong trong phiên này, cần push lên GitHub qua GitHub Desktop.**

## 3. Trạng thái hiện tại / việc vừa làm xong trong phiên này

- Đã đọc lại toàn bộ nội dung cũ của `BAO_CAO_CHI_TIET.md` và viết lại bản MỞ RỘNG hơn nhiều — thêm phần giải thích mục đích/lý do ("Vì sao cần...", "Mục đích...") cho từng công cụ, từng lệnh, từng bước — để người dùng ghép cùng ảnh chụp màn hình khi viết báo cáo thật.
- Đã tạo file này (`NGU_CANH_CHAT_MOI.md`) để chuyển ngữ cảnh sang đoạn chat mới.
- **CHƯA LÀM:** chưa push 2 file này lên GitHub — người dùng cần tự mở GitHub Desktop, sẽ thấy 2 file thay đổi/mới (`BAO_CAO_CHI_TIET.md` cập nhật, `NGU_CANH_CHAT_MOI.md` mới), viết commit message rồi bấm "Push origin".

## 4. Việc còn lại / hướng phát triển tiếp theo (nếu làm thêm)

1. Test độ chính xác trên bộ dữ liệu chuẩn công khai đầy đủ (toàn bộ tập kiểm định SST-2) thay vì bộ câu tự chọn thủ công.
2. Áp dụng static quantization đầy đủ (hiệu chỉnh scale bằng tập dữ liệu mẫu) thay vì lượng tử hóa động đơn giản hóa hiện tại.
3. Offload thêm Softmax, Q·Kᵀ, FFN — bài báo liệt kê đây là hướng phát triển tương lai của chính họ, chưa ai làm (kể cả bài báo gốc).
4. Viết báo cáo đồ án thật (Word/LaTeX), chèn ảnh chụp màn hình dựa theo đúng thứ tự và nội dung giải thích trong `BAO_CAO_CHI_TIET.md`.
5. Nếu lên lab lại với board thật: có thể thử thêm tối ưu phần cứng (sửa lại HLS/Vivado, phải rebuild bitstream) — khác với các tối ưu đã làm (persistent-A, C-loop) là tối ưu phần mềm phía host, không cần rebuild bitstream.

## 5. Lưu ý quan trọng khi tiếp tục ở chat mới

- **Không cần làm lại HLS/Vivado** — đã xong, đã export bitstream, đã push GitHub (`vivado_project/design_1_wrapper.xsa`).
- **Không cần cài lại torch/transformers/pillow trên board** — đã cài xong, cache HuggingFace đã có sẵn (`~/.cache/huggingface`), load model gần như tức thì.
- **Mạng board đã ổn định** (IP tĩnh `192.168.137.2`, tự kết nối lại khi khởi động) — nếu gặp lại mạng chậm, kiểm tra lại Windows ICS trước (tắt/bật "Shared") trước khi nghi ngờ nguyên nhân khác.
- Code các class `FPGAQKVAttention`, `FPGAQKVWrapper`, hàm benchmark, hàm đo công suất... **chỉ tồn tại trong notebook Jupyter trên board** (`Untitled.ipynb`), KHÔNG có trong git repo — nếu kernel restart, các hàm/class này mất, cần dán lại code (có đầy đủ trong lịch sử chat cũ nếu cần tra lại, hoặc tóm tắt logic đã ghi ở mục 2.9 trên).
- Người dùng thích được hỏi xác nhận từng bước nhỏ trước khi làm bước tiếp theo, và luôn cần giải thích "vì sao" chứ không chỉ "làm gì".
- Claude không tự `git push` — luôn nhắc người dùng dùng GitHub Desktop để commit + push.

## 6. Số liệu tổng kết chính (để tra nhanh, không cần đọc lại cả báo cáo)

| Hạng mục | Kết quả |
|---|---|
| DSP / FF / LUT | 84.1% / 49.7% / 62.8% (khớp bài báo 83%/43%/60%) |
| BRAM | 42.7% (đúng — bài báo ghi lỗi 88%, đã chứng minh) |
| GFLOPs FPGA compute (FFN N=64,K=768,M=3072) | 4.71 (bài báo 3.12) |
| GFLOPs FPGA end-to-end | 4.66 (bài báo 2.85) |
| Hiệu suất năng lượng FPGA vs PyTorch | 4.49-4.79× (bài báo ~4×) |
| DistilBERT accuracy (16 câu) | 100% khớp nhãn, lệch 0.016% (bài báo lệch 0.15%) |
| DistilBERT tốc độ (sau tối ưu persistent-A) | FPGA nhanh hơn CPU (850.6ms vs 1299.9ms) |
