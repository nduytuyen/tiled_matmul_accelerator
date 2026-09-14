# Hướng dẫn phân loại file — dành cho agent thực hiện copy

**Bối cảnh:** Đây là repo đồ án tốt nghiệp "Thiết kế và hiện thực bộ tăng tốc phép nhân ma trận lát gạch trên Xilinx KV260 SoM" (tái hiện bài báo arXiv:2503.16731), gồm **2 thiết kế**:
- **Thiết kế 1**: Full HLS (Vitis HLS, C++), kiến trúc broadcast.
- **Thiết kế 2**: Hybrid HLS+RTL, lõi tính toán là mảng systolic 32×32 tự viết RTL (Verilog/SystemVerilog).

Repo gốc nằm tại: `E:\CENTOS7\shared\tiled_matmul_accelerator\` (Windows, máy hiện tại).

**Trạng thái repo:** Toàn bộ nội dung đã được commit và push lên GitHub tại `https://github.com/nduytuyen/tiled_matmul_accelerator` (branch `main`). Nếu bạn (agent thực hiện copy) đang chạy trên máy khác hoặc không truy cập được đường dẫn Windows trên, có thể `git clone https://github.com/nduytuyen/tiled_matmul_accelerator.git` để lấy bản sao rồi copy từ đó — nội dung giống hệt.

> Lưu ý: các file bị flag "rác/leftover" ở mục 4 dưới đây (`docs/anhpdf/b`, `docs/anhpdf/c`, `docs/_cors_server.py`, `.claude/launch.json`, `docs/design2/rtl/axi4_c_writer.v.bak_before_128bit`) đã bị commit/push lên GitHub luôn (do GitHub Desktop tự gộp commit tất cả file còn lại). Chúng vẫn đang tồn tại trong repo — chỉ là **đừng copy chúng vào 2 thư mục agent**, không phải là chúng đã bị xóa khỏi repo gốc.

**Nhiệm vụ của bạn:** Copy các file từ repo gốc trên vào 2 thư mục đích theo danh sách dưới đây, giữ nguyên đường dẫn con (cấu trúc thư mục bên trong mỗi nhóm), **không xóa file gốc** (chỉ copy, không move) trừ khi được yêu cầu rõ. Nếu thư mục đích chưa tồn tại thì tạo mới.

- Thư mục đích 1: `agent_spec/` — dành cho agent chuyên về **đặc tả, tài liệu, báo cáo, kết quả đo đạc**.
- Thư mục đích 2: `agent_design_code/` — dành cho agent chuyên về **thiết kế phần cứng, code HLS/RTL, build, deploy**.

---

## 1. Copy vào `agent_spec/`

```
README.md
BAO_CAO_CHI_TIET.md
docs/Design and Implementation of an FPGA-Based Tiled Matrix Multiplication Accelerator for Transformer Self-Attention on the Xilinx KV260 SoM - 2503.16731v3.pdf
docs/IHI0022E_amba_axi_and_ace_protocol_spec.pdf
docs/UG1037-en-us.pdf
docs/benchmark_design2.pdf
docs/huong_phat_trien.docx
docs/muc_2_3_tai_hien.docx
docs/a.drawio
docs/giaithuat/                      (cả thư mục — 4 file PDF minh họa thuật toán BRAM)
docs/anhbosung/                      (cả thư mục — board.jpg)
doc_new/DistilBERT_FPGA_Eval.pdf
doc_new/Hinh_anh.docx
doc_new/hinhanh_media/               (cả thư mục — 5 ảnh image1-5.png)
```

**Lý do gộp nhóm:** đây là bài báo tham khảo, spec giao thức AXI/Xilinx, báo cáo, kết quả benchmark, ảnh minh họa cho tài liệu — không phải code.

---

## 2. Copy vào `agent_design_code/`

```
mmult_accel.cpp
mmult_accel.hpp
mmult_accel_tb.cpp
mmult_accel_hls/                     (cả thư mục — project Vitis HLS Thiết kế 1)
vitis_hls.log
vivado_project/                      (cả thư mục — project Vivado + bitstream Thiết kế 1, gồm pynq_deploy/mmult_accel.bit)
docs/design2/rtl/                    (cả thư mục — RTL nguồn thật Thiết kế 2)
docs/design2/testbench/              (cả thư mục — testbench SystemVerilog Thiết kế 2)
doc_new/axi4_c_writer.v              (bản RTL gốc đầu vào — nội dung đã có bản chính thức tại docs/design2/rtl/axi4_c_writer.v, copy để lưu vết thôi)
DESIGN_ALL/                          (cả thư mục — bản copy code dễ đọc, cả 2 thiết kế, đã tách HLS/RTL riêng)
docs/tai_hien_do_an.ipynb            (đã kiểm tra nội dung: đây là notebook PYNQ THẬT chạy trên board — set_ptr, benchmark_gemm, đọc công suất — không phải tài liệu, nên xếp vào code)
```

**Lý do gộp nhóm:** toàn bộ đây là mã nguồn HLS/RTL, project build (Vitis HLS + Vivado), bitstream deploy, và notebook thực thi thật trên phần cứng.

> **Xác nhận quan trọng:** `vivado_project/` chỉ đóng gói IP `mmult_accel` (đã grep trong `design_1.bd`, không thấy `systolic`/`axi4_c_writer`) → đây là project Vivado của **Thiết kế 1**, không phải Thiết kế 2. Thiết kế 2 hiện chưa có project Vivado riêng trong repo (nếu có ở máy khác, cần bổ sung thủ công).

---

## 3. CHƯA CHỐT — hỏi lại người dùng trước khi copy các file này

Người dùng (Nguyễn Duy Tuyên) chưa quyết định nhóm cho các file sau. Đừng tự quyết — hỏi trước khi copy:

| File | Ghi chú |
|---|---|
| `docs/access.docx` | Đã mở kiểm tra: ảnh chụp terminal PuTTY hướng dẫn cấu hình network cho board KV260 (không phải nội dung báo cáo, không phải code thiết kế) — có thể cần nhóm thứ 3 "setup/vận hành" hoặc gộp vào design_code. |
| `doc_new/tin_hieu_connect_design_1 - Copy.md` | Bảng tín hiệu kết nối RTL giữa các module Thiết kế 2 (đã đưa nội dung vào báo cáo §3.3.2) — vừa là tài liệu mô tả vừa sát nội dung thiết kế phần cứng. |
| `scripts/update_readme.sh` | Script đọc report Vitis HLS (phía code) để tự cập nhật README (phía spec) — thuộc cả 2 nhóm. |
| `.claude/launch.json`, `.claude/settings.local.json` | Config công cụ Claude Code, dùng chung toàn repo — có thể không cần copy vào agent nào, giữ ở root. |
| `CLAUDE.md` | Hướng dẫn hành vi Claude Code, không phải nội dung đồ án — có thể giữ dùng chung ở root của cả 2 thư mục agent (copy vào cả hai), hoặc không copy. |
| `NGU_CANH_CHAT_MOI.md` | File tóm tắt ngữ cảnh để mở chat mới — trộn cả nội dung spec và code. |

---

## 4. Nghi là rác/leftover — KHÔNG copy, hỏi người dùng có muốn xóa ở repo gốc không

```
docs/anhpdf/b       (trùng byte-for-byte với docs/anhpdf/b.png — file lặp thiếu đuôi do lệnh render cũ)
docs/anhpdf/c       (trùng byte-for-byte với docs/anhpdf/c.png — tương tự)
docs/extracted_images/   (thư mục trống)
docs/_cors_server.py     (script CORS-server bị bỏ dở, không còn dùng)
```

`docs/anhpdf/a.png` thì vẫn giữ lại như bình thường (không có bản lặp thiếu đuôi tương ứng) — chỉ `b`/`c` là rác.

---

## 5. Sau khi copy xong

- Kiểm tra lại bằng cách so sánh số file/kích thước giữa nguồn và đích để chắc không thiếu.
- Không sửa nội dung file trong lúc copy — đây chỉ là bước tổ chức lại thư mục, không phải chỉnh sửa nội dung.
