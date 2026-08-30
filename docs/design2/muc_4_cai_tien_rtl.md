# Mục 4 — Cải tiến kiến trúc: tách phần tính toán sang RTL (Giai đoạn 2 — HLS + RTL)

## 4.1 Hướng cải tiến

Phân tích luồng dữ liệu của thiết kế thuần-HLS ở Giai đoạn 0, dựa trên số liệu chu kỳ thật trích xuất từ báo cáo tổng hợp Vitis HLS (case tham chiếu N=64, K=768, M=3072, tần số hoạt động 100MHz), cho thấy một lượt gọi hàm tiêu tốn tổng cộng 7.523.328 chu kỳ (~75,2 ms), phân bổ rất không đều giữa các tầng xử lý:

| Tầng | Số lần lặp | Chu kỳ/lần | Tổng chu kỳ | Thời gian | Tỉ lệ |
|---|---|---|---|---|---|
| Nạp A từ DDR vào BRAM (1 lần/lượt gọi) | 1 | 49.152 | 49.152 | 0,49 ms | 0,7% |
| Nạp 1 block B từ DDR vào BRAM (mỗi block cột) | 12 | 196.608 | 2.359.296 | 23,59 ms | 31,4% |
| Nạp A và B từ BRAM vào thanh ghi cục bộ (mỗi vòng k0) | 4.608 | 1.026 | 4.727.808 | 47,28 ms | 62,9% |
| Tích luỹ MAC thật (mỗi vòng k0) | 4.608 | 36 | 165.888 | 1,66 ms | 2,2% |
| Ghi C ra DDR (mỗi tile) | 192 | 1.032 | 198.144 | 1,98 ms | 2,6% |
| **Tổng** | | | **7.523.328** | **75,2 ms** | **100%** |

Con số đáng chú ý nhất là tầng nạp A và B từ BRAM on-chip vào thanh ghi cục bộ, chiếm tới 62,9% tổng thời gian — lớn hơn gấp gần 30 lần phần tính toán MAC thật diễn ra ngay sau đó (chỉ 2,2%). Tầng này lặp lại 4.608 lần cho toàn bộ lượt gọi (24 vòng k0 mỗi tile, nhân với 192 tile), mỗi lần tốn 1.026 chu kỳ để nạp lại 32×32 phần tử của A và 32×32 phần tử của B vào 2.048 thanh ghi cục bộ — dù dữ liệu này vốn đã nằm sẵn trong BRAM on-chip từ trước, kiến trúc broadcast của Giai đoạn 0 vẫn buộc phải đọc lại toàn bộ vào thanh ghi ở **mỗi** vòng k0 riêng lẻ, không có cơ chế nào tái sử dụng phần đã nạp giữa hai vòng liên tiếp. Gộp chung với phần tính toán ngay sau đó, cả cụm "nạp thanh ghi cục bộ + tích luỹ" chiếm 65,4% tổng thời gian một lượt gọi — đây là mục tiêu tối ưu số một của Giai đoạn 2.

Việc nạp block B từ DDR về BRAM, tuy chiếm tới 31,4%, chỉ đáng tối ưu tiếp bằng các kỹ thuật như ping-pong buffer hay mở rộng độ rộng burst AXI *sau khi* tầng 65,4% ở trên đã được giải quyết, vì hiệu quả thực tế của những kỹ thuật đó phụ thuộc trực tiếp vào tỉ lệ compute/load mới sau cải tiến — nếu phần tính toán trở nên quá nhanh so với phần nạp, chồng lấp bằng ping-pong sẽ không còn nhiều dư địa để che giấu độ trễ nạp. Hướng này được cân nhắc và chốt không thực hiện trong phạm vi Giai đoạn 2, dành cho hướng mở rộng về sau. Phần nạp A (0,7%) và ghi C ra DDR (2,6%), cộng lại chưa tới 3,3% tổng thời gian, không đáng ưu tiên tối ưu ở giai đoạn này.

Bên cạnh phân tích định lượng trên, kiến trúc broadcast nguyên bản của Giai đoạn 0 còn mang một hạn chế mang tính khả thi phần cứng, độc lập hoàn toàn với vấn đề chu kỳ vừa nêu: để nạp dữ liệu vào 1.024 thanh ghi cục bộ trong cùng 1 chu kỳ, mỗi giá trị của A hoặc B phải được phát tán (fan-out) đồng thời tới toàn bộ 32 bộ xử lý (PE) cùng hàng hoặc cùng cột. Với kích thước tile T=32 đang dùng, fan-out này đã đạt 1.024 điểm nhận (32×32); nếu tăng kích thước tile lên T=64 để tận dụng thêm độ song song — như một phương án từng được cân nhắc trong bài báo tham chiếu — fan-out sẽ vọt lên 4.096 điểm nhận trên cùng 1 nguồn phát, vượt quá khả năng lan truyền tín hiệu ổn định trong 1 chu kỳ đồng hồ ở tần số 100MHz và khiến thiết kế không đạt được timing closure. Đây là lý do thứ hai, mang tính cấu trúc chứ không chỉ hiệu năng thuần tuý: ngay cả khi bỏ qua chi phí chu kỳ, kiến trúc broadcast tự giới hạn khả năng mở rộng độ song song trong tương lai bởi chính cách nó phân phối dữ liệu.

Cả hai lý do — chi phí nạp lại lặp đi lặp lại theo từng vòng k0, và giới hạn fan-out của kiến trúc broadcast — cùng chỉ về một hướng giải quyết: thay thế lõi tính toán bằng kiến trúc **systolic** kiểu nearest-neighbor, nơi mỗi phần tử xử lý chỉ trao đổi dữ liệu với đúng một phần tử lân cận thay vì phát tán ra toàn mảng. Kiến trúc này giải quyết đồng thời cả hai vấn đề: loại bỏ hoàn toàn chi phí nạp lại theo từng vòng k0 bằng cách tích luỹ liên tục xuyên suốt chiều K ngay khi dữ liệu được đưa vào rìa mảng, đồng thời loại bỏ vấn đề fan-out bằng cách chỉ dùng kết nối cục bộ giữa các phần tử liền kề — mở đường cho khả năng mở rộng độ song song về sau mà không bị giới hạn bởi thời gian lan truyền tín hiệu tổ hợp trên diện rộng. Thiết kế chi tiết của lõi systolic được trình bày ở mục 4.3.

## 4.2 Kiến trúc lai HLS + RTL — sơ đồ tổng quan

Xuất phát từ hướng cải tiến trên, kiến trúc được tách lại thành 2 vai trò rõ ràng, khác hẳn khối HLS nguyên khối của Giai đoạn 0. Khối HLS (`mmult_accel`) chỉ còn giữ vai trò "ống dẫn dữ liệu" và điều khiển tiling — các vòng lặp `outer_j_block`/`tile_i`/`tile_j`, kiểm tra biên, và điều phối bắt tay giữa các khối RTL — không còn chứa bất kỳ vòng compute nào. Khối RTL (`SYSTOLIC_CORE_TOP`) là lõi tính toán 32×32 kiểu systolic, tích luỹ liên tục xuyên suốt vòng K, khác hẳn kiến trúc broadcast của Giai đoạn 0.

Giao diện giữa 2 khối ban đầu được thiết kế là 64 cổng bộ nhớ trong (32 cho A, 32 cho B, đọc trực tiếp không qua đóng gói giao thức hay AXI4-Stream) và 1 cổng vector C (1.024 tín hiệu tổ hợp, không địa chỉ hoá) — lựa chọn này xuất phát từ đặc điểm dữ liệu: kích thước tile cố định và biết trước, không cần cơ chế đóng gói burst hay handshake phức tạp của giao thức stream tổng quát. Trong quá trình hiện thực hoá thực tế, kiến trúc trên đã phải điều chỉnh thêm một lần nữa: cả 3 luồng dữ liệu A/B/C cuối cùng cũng phải rời khỏi Vitis HLS hoàn toàn, chuyển sang RTL tự viết tay — lý do và quá trình phát hiện được trình bày ở mục 4.4.

> 🖼️ **CHÈN HÌNH** — sơ đồ khối tổng quan: mmult_accel (tiling) ↔ 64 cổng bộ nhớ trong A/B + 1 cổng vector C ↔ SYSTOLIC_CORE_TOP, đối chiếu với khối HLS nguyên khối Giai đoạn 0

## 4.3 Lõi tính toán systolic — `SYSTOLIC_CORE_TOP`

### Chức năng

`SYSTOLIC_CORE_TOP` là lõi tính toán trung tâm của Giai đoạn 2, thay thế toàn bộ nhiệm vụ nạp thanh ghi cục bộ và tích luỹ MAC vốn được thực hiện tuần tự trong Vitis HLS ở Giai đoạn 0. Khối nhận vào chỉ số của 1 tile A (chọn ra từ 64 hàng có sẵn trong bộ nhớ trong) và 1 tile B (32×32 phần tử), tự động đọc dữ liệu và tích luỹ liên tục theo chiều K mà không cần điều khiển can thiệp giữa chừng, rồi xuất ra 1 tile kết quả C (32×32 giá trị, mỗi giá trị 32-bit) ngay khi quá trình tích luỹ hoàn tất.

### Giao diện tín hiệu

| Tên tín hiệu | Chiều | Ý nghĩa |
|---|---|---|
| `tile_valid_i` | vào | mức 1: bắt đầu tính 1 tile mới |
| `tile_ready_o` | ra | mức 1: khối đang rảnh, sẵn sàng nhận tile |
| `tile_done_o` | ra | xung 1 chu kỳ: tile vừa tính xong |
| `tile_i_sel_i` | vào | chọn 32 trong 64 hàng của A cho tile hiện tại |
| `tile_j_sel_i` | vào | chọn nhóm cột của B cho tile hiện tại |
| `bram_a0..63_dout_i` | vào | dữ liệu 64 hàng A, mỗi cổng 1 hàng |
| `bram_b0..31_dout_i` | vào | dữ liệu 32 cột B của nhóm cột hiện tại |
| `c0_0_o … c31_31_o` | ra | 1.024 tín hiệu, tổ hợp trực tiếp từ thanh ghi tích luỹ, hợp lệ khi `tile_done_o` lên mức cao |

### Nguyên lý hoạt động

`SYSTOLIC_CORE_TOP` chỉ có 2 trạng thái, đơn giản hơn hẳn khung nhiều trạng thái của Giai đoạn 0. Ở trạng thái chờ, khối vào ngay sau khi reset hoặc ngay sau khi tile trước vừa hoàn tất, phát tín hiệu báo rảnh rồi chờ tín hiệu bắt đầu tile mới; khi tín hiệu đó được chấp nhận, khối chốt lại lựa chọn hàng của A và nhóm cột của B cho tile này, đồng thời phát một xung xoá thanh ghi tích luỹ duy nhất cho toàn bộ mảng xử lý, rồi chuyển ngay sang trạng thái tích luỹ. Trong trạng thái tích luỹ, khối đọc tuần tự dữ liệu của cả A lẫn B theo từng bước của chiều K (768 bước), mảng xử lý tích luỹ liên tục không ngắt quãng — khác hẳn cách nạp-lại-rồi-tính-lại từng vòng riêng lẻ của Giai đoạn 0, ở đây dữ liệu chỉ được mồi vào rìa mảng đúng 1 lần khi bắt đầu tile, sau đó tự động lan truyền và tích luỹ theo cơ chế truyền tay giữa các phần tử lân cận. Khi đã đi hết toàn bộ chiều K cộng thêm số chu kỳ cần thiết để dữ liệu lan truyền hết chiều dài của mảng (giai đoạn mồi đường ống), khối phát ngay một xung báo tính xong — không có bước trung gian nào để rút dữ liệu ra tuần tự, vì toàn bộ 1.024 giá trị kết quả đã sẵn có dưới dạng tín hiệu tổ hợp ngay khi phép tích luỹ cuối cùng hoàn tất — rồi quay lại trạng thái chờ.

Tổng thời gian thực thi để hoàn tất tính toán một tile kết quả 32×32 được xác định theo công thức:

$$\text{Tổng chu kỳ} = T_{\text{fill}} + K + T_{\text{BRAM}} = 64 + 768 + 1 = 833 \text{ chu kỳ}$$

Trong đó:

- $T_{\text{fill}} = 2T = 64$ chu kỳ: độ trễ lan truyền lệch pha (skew) để dữ liệu đi từ rìa mảng tới phần tử xử lý xa nhất ở góc đối diện, qua đúng $T$ tầng thanh ghi mỗi hướng.
- $K = 768$ chu kỳ: số bước tích luỹ theo chiều sâu K, mỗi chu kỳ 1 cặp phần tử được bơm vào rìa mảng.
- $T_{\text{BRAM}} = 1$ chu kỳ: độ trễ đọc đồng bộ của bộ nhớ trong (dữ liệu chỉ hợp lệ đúng 1 chu kỳ sau khi địa chỉ và tín hiệu cho phép được phát ra), cần thêm 1 tầng thanh ghi để bù trước khi đưa vào mảng tính toán.

Đúng tại chu kỳ thứ 833, toàn bộ 1.024 giá trị của tile C đã được chốt hoàn tất trong các thanh ghi tích luỹ và xuất trực tiếp ra ngõ ra tổ hợp, đồng thời khối phát một xung `tile_done_o` tích cực mức cao trong đúng 1 chu kỳ để kích hoạt module ghi C bắt đầu giao dịch ghi ra DDR.

> 🖼️ **CHÈN HÌNH** — FSM 2 trạng thái của SYSTOLIC_CORE_TOP

### Cấu trúc nội bộ

Thành phần chính là mảng 32×32 phần tử xử lý (PE) kết nối theo kiểu nearest-neighbor: mỗi PE chỉ nhận dữ liệu từ đúng 1 PE lân cận (phía trái cho dòng dữ liệu của A, phía trên cho dòng dữ liệu của B), tự đẩy tiếp giá trị đã nhận sang PE bên phải hoặc bên dưới ở chu kỳ kế tiếp thông qua một thanh ghi trung gian — cơ chế này tạo ra độ trễ lệch pha (skew) giữa các hàng và cột khi dữ liệu được đưa vào rìa mảng, đảm bảo mỗi PE nhận đúng cặp giá trị cần nhân tại đúng thời điểm mà không cần bất kỳ đường dây phát tán diện rộng nào. Mỗi PE đơn tự thân chỉ gồm một bộ nhân-cộng và một thanh ghi tích luỹ, được đánh dấu tường minh để công cụ tổng hợp ánh xạ vào khối DSP chuyên dụng của FPGA thay vì dùng tài nguyên logic khả trình thông thường. Ngoài mảng PE, khối còn có một tầng ghép kênh tĩnh để chọn ra đúng 32 trong 64 hàng của A theo lựa chọn hiện tại, và một tầng cộng địa chỉ để tính offset nhóm cột cần đọc của B — cả hai đều là logic tổ hợp thuần tuý, không chiếm thêm chu kỳ nào để hoàn tất.
> 🖼️ **CHÈN HÌNH (2 hình)** — cấu trúc nội bộ SYSTOLIC_CORE_TOP
### Quyết định thiết kế và lý do

Việc chuyển từ kết nối broadcast sang nearest-neighbor là quyết định trung tâm của toàn bộ Giai đoạn 2, xuất phát trực tiếp từ 2 lý do đã phân tích ở mục 4.1: loại bỏ chi phí nạp lại 62,9% và loại bỏ giới hạn fan-out. Việc gộp bước đọc dữ liệu và bước tích luỹ vào chung 1 trạng thái duy nhất (thay vì tách riêng như Giai đoạn 0) là hệ quả tự nhiên của kiến trúc systolic: vì dữ liệu tự lan truyền và tích luỹ liên tục ngay khi được đưa vào, không còn lý do gì để tách biệt hai bước này thành 2 trạng thái riêng như khi còn phải nạp toàn bộ dữ liệu vào thanh ghi trước khi tính. Việc dùng ghép kênh tĩnh để chọn hàng A thay vì sao chép dữ liệu vào một vùng nhớ trung gian là lựa chọn có chủ đích: sao chép sẽ tốn thêm chu kỳ và tài nguyên bộ nhớ, trong khi ghép kênh tổ hợp đạt cùng hiệu quả mà không tốn phí gì thêm, vì việc chọn hàng chỉ cần ổn định trong suốt thời gian xử lý 1 tile chứ không đổi giữa chừng. Cuối cùng, việc để kết quả C ở dạng vector tổ hợp thay vì địa chỉ hoá như A và B là lựa chọn phù hợp với đặc điểm sử dụng: C chỉ cần đọc đúng 1 lần ngay khi tích luỹ xong, không có nhu cầu truy cập lặp lại hay truy cập ngẫu nhiên như A và B, nên việc địa chỉ hoá chỉ tạo thêm độ trễ không cần thiết cho bước cuối của mỗi tile.

## 4.4 Các module AXI4 tự viết tay

Ba luồng dữ liệu A, B, C được hiện thực hoá bằng 3 module RTL tự viết tay, thêm trực tiếp vào sơ đồ khối phần cứng, thay vì để Vitis HLS tự sinh. Khối HLS chỉ còn vai trò tiling và điều phối bắt tay giữa 4 khối RTL, không tự đọc hay ghi bất kỳ dữ liệu ma trận nào. Cả 3 module đều dùng chung một triết lý thiết kế: chỉ thực hiện đúng 1 giao dịch AXI tại 1 thời điểm, không cho phép nhiều giao dịch chồng lấp nhau — khác hẳn cơ chế nhiều giao dịch gối đầu đã dùng cho khối đọc A và B ở Giai đoạn 0.


### 4.4.1 Module đọc ma trận A

#### Chức năng

Module này đọc toàn bộ ma trận A từ bộ nhớ ngoài và ghi vào 64 khối bộ nhớ trong, đóng vai trò thay thế hoàn toàn cho bước nạp A bằng Vitis HLS ở Giai đoạn 0. Vì A không đổi trong suốt một lượt gọi và được ghi broadcast cùng lúc vào cả 64 khối, mảng tính toán phía sau chỉ cần đọc trực tiếp mà không cần biết gì về việc dữ liệu tới bằng đường AXI hay bằng cách nào khác.

> 🖼️ **CHÈN HÌNH** — module đọc ma trận A
#### Giao diện tín hiệu

| Tên tín hiệu | Chiều | Ý nghĩa |
|---|---|---|
| `a_reload_req_i` | vào | xung 1 chu kỳ, báo cần nạp lại A |
| `a_base_addr_i` | vào | địa chỉ gốc của A trong bộ nhớ ngoài |
| `a_loaded_o` | ra | mức 1, giữ tới lần `a_reload_req_i` kế tiếp |
| `m_axi_ar*_o` / `m_axi_r*_i` | ra/vào | kênh đọc AXI4 (địa chỉ + dữ liệu) |
| `bank0..63_addr_o/en_o/we_o/din_o` | ra | 256 cổng phẳng, mỗi 4 cổng nối trực tiếp 1 khối bộ nhớ trong |

#### Nguyên lý hoạt động

Module gồm 5 trạng thái, đơn giản hơn nhiều so với cơ chế hai tiến trình song song đã dùng cho khối đọc A ở Giai đoạn 0 — đúng chủ đích "1 giao dịch tại 1 thời điểm" đã nêu ở trên. Ở trạng thái chờ, module đứng yên đợi xung yêu cầu nạp lại; khi nhận được, chuyển sang trạng thái phát địa chỉ đọc cho 1 hàng của A. Sau khi địa chỉ được chấp nhận, module chuyển sang trạng thái nhận dữ liệu, gom đủ số phần tử của 1 hàng vào một thanh ghi đệm trung gian. Khi đã nhận đủ và thấy tín hiệu báo phần tử cuối cùng của burst, module chuyển sang trạng thái ghi, đưa toàn bộ dữ liệu vừa gom được ra ghi đồng thời vào cả 64 khối bộ nhớ trong trong đúng 1 chu kỳ duy nhất. Nếu còn hàng chưa đọc, module quay lại trạng thái phát địa chỉ để xử lý hàng kế tiếp; nếu đã đọc đủ toàn bộ số hàng của A, module chuyển sang trạng thái hoàn tất, phát cờ báo đã nạp xong rồi quay về trạng thái chờ.

#### Cấu trúc nội bộ

Thành phần trung tâm là một thanh ghi đệm dạng vector phẳng, đủ chỗ chứa toàn bộ 1 hàng dữ liệu đọc về từ 1 burst AXI. Vì mọi hàng của A đều có cùng độ dài cố định và số khối bộ nhớ trong đúng bằng độ dài đó, việc ghi từ thanh ghi đệm ra các khối bộ nhớ trong không cần bất kỳ bộ chọn kênh hay bộ giải mã địa chỉ nào — mỗi phần tử của thanh ghi đệm nối cứng, một-một, tới đúng 1 khối bộ nhớ trong tương ứng, cho phép toàn bộ 64 khối được ghi song song trong cùng 1 chu kỳ.

#### Quyết định thiết kế và lý do

Việc dùng một thanh ghi đệm trung gian, thay vì ghi trực tiếp từng phần tử dữ liệu đọc về vào bộ nhớ trong ngay khi nhận được, là lựa chọn bắt buộc bởi cách ghi broadcast: chỉ khi đã có đủ toàn bộ dữ liệu của 1 hàng mới có thể ghi đồng loạt vào tất cả các khối bộ nhớ trong trong cùng 1 chu kỳ, nếu ghi từng phần từng lúc sẽ phải địa chỉ hoá riêng cho từng khối, mất đi lợi thế tốc độ của cách ghi song song. Việc chọn cơ chế "1 giao dịch tại 1 thời điểm" thay vì khôi phục lại cơ chế nhiều giao dịch gối đầu của Giai đoạn 0 là đánh đổi có chủ đích: mục tiêu ưu tiên là có một thiết kế RTL hoạt động đúng và ổn định sau khi phần tương ứng trong Vitis HLS liên tục gặp lỗi không thể khắc phục, việc tối ưu thêm tốc độ đọc được xem là hướng cải thiện tiếp theo chứ không phải điều kiện bắt buộc ngay từ đầu.

### 4.4.2 Module đọc ma trận B

#### Chức năng

Module này đọc 1 khối cột của ma trận B từ bộ nhớ ngoài và ghi vào 32 khối bộ nhớ trong, được gọi lại nhiều lần trong một lượt gọi — mỗi lần ứng với 1 khối cột khác nhau của B, khác với module đọc A chỉ cần chạy tối đa 1 lần.

> 🖼️ **CHÈN HÌNH** — module đọc ma trận B
#### Giao diện tín hiệu

| Tên tín hiệu | Chiều | Ý nghĩa |
|---|---|---|
| `b_reload_req_i` | vào | xung 1 chu kỳ, báo cần nạp khối cột mới |
| `b_base_addr_i` | vào | địa chỉ gốc khối cột hiện tại, đổi mỗi lần gọi lại |
| `b_row_stride_i` | vào | bước nhảy địa chỉ giữa các hàng, bằng tổng số cột của B |
| `b_num_rows_i` | vào | số hàng cần đọc (runtime) |
| `b_block_width_i` | vào | độ rộng khối cột cần đọc (runtime, ≤256) |
| `b_loaded_o` | ra | mức 1, giữ tới lần `b_reload_req_i` kế tiếp |
| `m_axi_ar*_o` / `m_axi_r*_i` | ra/vào | kênh đọc AXI4 (địa chỉ + dữ liệu) |
| `bank0..31_addr_o/en_o/we_o/din_o` | ra | 128 cổng phẳng, mỗi 4 cổng nối trực tiếp 1 khối bộ nhớ trong |

#### Nguyên lý hoạt động

Cấu trúc trạng thái và kỹ thuật đệm trung gian giống hệt module đọc A, chỉ khác ở nội dung dữ liệu và số chu kỳ cần cho bước ghi. Vì số khối bộ nhớ trong (32) nhỏ hơn số phần tử tối đa trên 1 hàng của khối cột (có thể lên tới 256), mỗi khối bộ nhớ trong phải nhận nhiều hơn 1 phần tử cho mỗi hàng — việc ghi 1 hàng vào bộ nhớ trong vì vậy không thể hoàn tất trong 1 chu kỳ như module đọc A, mà phải lặp lại nhiều lần, mỗi lần ghi thêm 1 phần tử vào mỗi khối cho tới khi đủ. Địa chỉ ghi vào mỗi khối bộ nhớ trong được tính bằng tổ hợp giữa số thứ tự hàng hiện tại và số thứ tự lần lặp ghi trong hàng đó.

#### Cấu trúc nội bộ

Vẫn dùng một thanh ghi đệm dạng vector phẳng như module đọc A, nhưng có kích thước lớn hơn để chứa đủ độ rộng khối cột tối đa. Vì số khối bộ nhớ trong nhỏ hơn số phần tử trên 1 hàng, phần logic ghi cần thêm một bộ đếm phụ để xác định đang ghi tới lượt thứ mấy trong 1 hàng, dùng làm một phần của địa chỉ ghi vào bộ nhớ trong.

#### Quyết định thiết kế và lý do

Việc giữ nguyên khung 5 trạng thái và cơ chế đệm trung gian giống hệt module đọc A, thay vì thiết kế riêng một cấu trúc khác, là lựa chọn có chủ đích nhằm giữ tính nhất quán và giảm rủi ro thiết kế: hai module giải quyết cùng một loại bài toán (đọc tuần tự từ bộ nhớ ngoài, ghi broadcast vào một tập khối bộ nhớ trong), chỉ khác về kích thước và tính chất runtime của tham số, nên dùng chung một khuôn mẫu giúp việc kiểm chứng và bảo trì đơn giản hơn. Việc chấp nhận để bước ghi tốn nhiều chu kỳ hơn 1, thay vì tăng số khối bộ nhớ trong lên bằng độ rộng khối cột tối đa để giữ ghi trong 1 chu kỳ như module A, là đánh đổi giữa tài nguyên phần cứng và độ phức tạp: tăng số khối bộ nhớ trong lên hàng trăm sẽ tốn tài nguyên bộ nhớ trong đáng kể trong khi độ rộng khối cột tối đa chỉ được dùng ở một số trường hợp, không xứng đáng với chi phí tài nguyên bỏ ra so với việc chấp nhận vài chu kỳ ghi thêm cho mỗi hàng.

### 4.4.3 Module ghi ma trận C

#### Chức năng

Module này ghi 1 tile kết quả (32×32 giá trị), vừa được lõi tính toán systolic tích luỹ xong, ra đúng vị trí của nó trong ma trận C ở bộ nhớ ngoài. Đây là module duy nhất trong 3 module tự viết tay hoạt động theo chiều ghi thay vì đọc.

> 🖼️ **CHÈN HÌNH** — module ghi ma trận C
#### Giao diện tín hiệu

| Tên tín hiệu | Chiều | Ý nghĩa |
|---|---|---|
| `tile_valid_i` | vào | mức 1, dùng để xoá cờ báo xong của tile trước |
| `tile_done_i` | vào | xung 1 chu kỳ từ lõi tính toán, kích hoạt chốt tham số tile |
| `c_base_addr_i`, `c_row_stride_i` | vào | địa chỉ gốc C, bước nhảy địa chỉ giữa các hàng (=M) |
| `c_global_i0_i`, `c_global_j0_i` | vào | toạ độ tuyệt đối (hàng, cột) của tile trong ma trận C |
| `c_valid_rows_i`, `c_valid_cols_i` | vào | số hàng/cột thực sự hợp lệ trong tile (≤32) |
| `c_write_done_o` | ra | mức, dùng để mở đường cho tile kế tiếp |
| `m_axi_aw*_o`/`w*_o`/`b*_i` | ra/vào | kênh ghi AXI4 (địa chỉ, dữ liệu, phản hồi) |
| `c0_0_i … c31_31_i` | vào | 1.024 tín hiệu, lấy trực tiếp từ thanh ghi tích luỹ của lõi tính toán |

#### Nguyên lý hoạt động

Module gồm 5 trạng thái. Ở trạng thái chờ, mỗi khi thấy tín hiệu báo tile đang hợp lệ, module hạ cờ báo đã ghi xong của tile trước — chuẩn bị cho lượt ghi mới; khi thấy xung báo tile vừa tính xong, module chốt lại toàn bộ tham số của tile hiện tại, gồm toạ độ tuyệt đối và số hàng/cột thực sự hợp lệ (một tile ở biên ma trận có thể không đầy đủ 32×32). Nếu số hàng hoặc số cột hợp lệ bằng 0, module bỏ qua hoàn toàn việc ghi và chuyển thẳng sang trạng thái hoàn tất; ngược lại, module chuyển sang trạng thái phát địa chỉ ghi cho hàng đầu tiên. Ở trạng thái này, module tính địa chỉ ghi và gộp toàn bộ các phần tử của 1 hàng (tối đa 32 phần tử) thành 1 giao dịch ghi dài duy nhất, đồng thời chuẩn bị sẵn dữ liệu của phần tử đầu tiên. Sau khi địa chỉ được chấp nhận, module chuyển sang trạng thái phát dữ liệu, lần lượt đưa ra từng phần tử của hàng, mỗi lần chuẩn bị sẵn phần tử kế tiếp ngay khi phần tử hiện tại được chấp nhận. Sau khi phần tử cuối cùng của hàng được gửi đi, module chuyển sang trạng thái chờ phản hồi ghi từ bộ nhớ ngoài — bằng chứng cho thấy dữ liệu đã thực sự được lưu, không chỉ mới gửi đi. Nếu còn hàng chưa ghi hết, module cộng thêm bước nhảy địa chỉ và quay lại trạng thái phát địa chỉ để ghi hàng kế tiếp; nếu đã ghi hết toàn bộ số hàng hợp lệ, module chuyển sang trạng thái hoàn tất, phát cờ báo đã ghi xong rồi quay về trạng thái chờ.

#### Cấu trúc nội bộ

Không có thanh ghi đệm trung gian như 2 module đọc, vì nguồn dữ liệu ghi (1.024 tín hiệu kết quả từ lõi tính toán) đã sẵn sàng ngay lập tức dưới dạng tín hiệu tổ hợp, không mang độ trễ bất định như dữ liệu đọc về từ bộ nhớ ngoài. Thành phần chính là một cơ chế gom dữ liệu theo hàng: tại mỗi thời điểm, module chỉ cần trích ra đúng 32 giá trị thuộc hàng đang ghi từ toàn bộ 1.024 tín hiệu, dựa trên chỉ số hàng hiện tại đang được theo dõi bởi chính bộ đếm trạng thái của module.

#### Quyết định thiết kế và lý do

Việc gộp cả hàng tile (tối đa 32 phần tử liên tiếp) thành 1 giao dịch ghi dài, thay vì ghi từng phần tử riêng lẻ như phiên bản đầu tiên, là quyết định tối ưu quan trọng: phiên bản ghi từng phần tử một, đo thật trên phần cứng, cho thấy đây là nút thắt chiếm gần như toàn bộ thời gian một lượt gọi. Vì các phần tử trong cùng 1 hàng của ma trận C vốn đã liên tục nhau trong bộ nhớ ngoài (dữ liệu được lưu theo thứ tự hàng), việc gộp thành 1 burst dài là khả thi mà không cần thay đổi cách bố trí dữ liệu, và giúp giảm số lượng giao dịch ghi xuống còn đúng bằng số hàng của tile thay vì bằng tích số hàng và số cột. Việc dùng kỹ thuật chuẩn bị sẵn dữ liệu cho phần tử kế tiếp ngay tại lúc bắt tay phần tử hiện tại, thay vì để phần cứng tự tính toán tổ hợp dữ liệu cần gửi ở mỗi chu kỳ, là lựa chọn nhằm tránh một lớp lỗi lệch nhịp thời gian đã từng gặp phải trong quá trình phát triển: nếu để tính toán tổ hợp diễn ra ngay trong chu kỳ bắt tay, dữ liệu xuất hiện trên đường truyền sẽ luôn chậm hơn đúng 1 bước so với chỉ số thực tế đang xử lý.

## 4.5 Kết quả đo thật trên KV260

Khác với bản nháp trước đây (khi thiết kế còn đang trong quá trình sửa lỗi treo hệ thống), toàn bộ chuỗi thiết kế của Giai đoạn 2 nay đã chạy đúng hoàn toàn, cả trong mô phỏng lẫn trên phần cứng thật.

**Xác minh chức năng.** RTL lõi tính toán đã verify xong hoàn toàn qua testbench thật trên công cụ mô phỏng của Vivado: kiểm tra ở cấp phần tử xử lý đơn PASS 10/10, kiểm tra ở cấp mảng xử lý 32×32 PASS 1.024/1.024 phần tử (cả 4 trường hợp: ngẫu nhiên, toàn 0, biên min, biên max), kiểm tra ở cấp lõi tính toán đầy đủ PASS 6/6. Mô phỏng toàn hệ thống — bao gồm cả 3 module AXI4 tự viết cùng lõi tính toán — đạt PASS hoàn toàn, kết quả C khớp 100% mô hình đối chiếu. Sau khi tổng hợp và triển khai vật lý, thiết kế đạt được ràng buộc thời gian ở tần số 100MHz với biên độ dương (biên hold khá mỏng, cần lưu ý nếu về sau gặp lỗi ngẫu nhiên do nhiệt độ hoặc điện áp). Trên phần cứng KV260 thật, kết quả phép nhân ma trận khớp 100% với kết quả tính bằng thư viện số học chuẩn ở mọi kích thước đã kiểm tra, và ứng dụng phân loại cảm xúc câu văn dùng mô hình DistilBERT với 3 phép chiếu tuyến tính mỗi tầng được offload qua FPGA cũng cho kết quả đúng 16/16 câu so với chạy hoàn toàn trên CPU, lệch điểm tin cậy trung bình chỉ 0,016 điểm phần trăm.

**Hiệu năng tính toán thuần.** Với case tham chiếu (N=64, K=768, M=3072), thời gian tính toán thuần (không tính overhead phần mềm điều khiển) đo được là 66,229 ms — nhanh hơn thư viện tính toán số học đa luồng phổ biến 5,51 lần (bài báo tham chiếu công bố 7,01 lần) và nhanh hơn thư viện tính toán số học đơn luồng 317,93 lần (bài báo công bố 214,24 lần) — cạnh tranh tốt và đúng bậc độ lớn so với bài báo dù chưa vượt trội hoàn toàn.

**Nút thắt hiệu năng còn lại: module ghi C.** Gộp burst đã giảm số giao dịch ghi 32 lần, nhưng tổng thời gian một lượt gọi chỉ cải thiện ~1,1%. Đo cô lập từng module (mỗi module 1 mạch thử nghiệm riêng, không tranh chấp băng thông, 200 lần lặp lấy trung vị), quy đổi ra chi phí mỗi hàng:

| Module | Số hàng / lần đo | Thời gian đo được | Thời gian / hàng | So với module A |
|---|---|---|---|---|
| A (đọc) | 768 | 305,3 µs | 0,40 µs | 1× (chuẩn) |
| B (đọc) | 768 | 589,5 µs | 0,77 µs | ~1,9 lần |
| C (ghi) | 32 | 242,1 µs | 7,57 µs | ~19 lần |

Dù mang ít dữ liệu hơn cả B, mỗi hàng của module ghi C vẫn chậm hơn A khoảng 19 lần và B khoảng 10 lần. Nguyên nhân: cổng bộ nhớ cao tốc có độ rộng dữ liệu gốc gấp 4 lần độ rộng module ghi C đang dùng mỗi lần truyền — ghi hẹp hơn độ rộng gốc buộc bộ điều khiển bộ nhớ ngoài phải đọc-sửa-ghi, chi phí này chỉ phát sinh khi ghi nên chỉ ảnh hưởng riêng module C. Cộng thêm việc module này không cho phép giao dịch chồng lấp (mỗi hàng đợi trọn phản hồi mới phát hàng kế), chi phí bị nhân đúng theo số hàng mỗi tile. Hướng tối ưu còn để ngỏ: ghi ở độ rộng khớp cổng cao tốc, và cho phép giao dịch ghi chồng lấp.

**Đánh giá tích hợp với mô hình thực tế.** Khi offload 3 phép chiếu tuyến tính của cả 6 tầng mô hình DistilBERT qua FPGA (chiếm 24,7% tổng khối lượng tính toán mỗi tầng), thời gian chạy toàn bộ mô hình đo được chỉ bằng 0,74–0,75 lần so với chạy hoàn toàn trên CPU — tức chậm hơn, dù bản thân phép nhân ma trận trên FPGA nhanh hơn CPU nhiều lần như đã trình bày ở trên. Nguyên nhân là chiến lược offload theo từng tầng riêng lẻ gọi phần cứng 18 lần cho mỗi lượt suy luận, mỗi lần chỉ xử lý một khối lượng công việc nhỏ, trong khi chi phí đồng bộ hoá giữa phần mềm điều khiển và FPGA lại cố định cho mỗi lần gọi — kết luận này khớp với nhận định của chính bài báo tham chiếu về hạn chế của kiểu tích hợp đồng bộ hoá theo từng lớp. Đối chiếu lại, việc đọc trực tiếp mã nguồn thử nghiệm gốc của bài báo tham chiếu cũng cho thấy con số tăng tốc gấp đôi toàn hệ thống mà bài báo công bố không phải là phép đo end-to-end đúng nghĩa — họ chỉ so sánh thời gian chạy CPU, đo đúng và bọc toàn bộ lệnh gọi mô hình, với một biến đếm dồn thời gian tính toán bên trong hàm gọi FPGA, bỏ sót phần thời gian CPU còn lại và overhead phần mềm; đo lại đúng phương pháp trên chính kiến trúc gốc của bài báo cho kết quả trung vị chỉ khoảng 1,04 lần — gần như hoà, không phải 2 lần.

**Tài nguyên phần cứng.** Thiết kế cuối cùng sử dụng khoảng 82% số khối nhân chuyên dụng của chip (phần lớn dành cho mảng tính toán systolic 32×32), và khoảng 67% số khối bộ nhớ trong (dùng cho các khối bộ nhớ trung gian giữa các module đọc/ghi và lõi tính toán).

> 🖼️ **CHÈN HÌNH** — bảng/biểu đồ so sánh thời gian Giai đoạn 0 (~75,2 ms, ước tính từ báo cáo tổng hợp) vs Giai đoạn 2 (66,229 ms, đo thật trên KV260) vs bài báo tham chiếu (90 ms)

## 4.6 Tổng kết các điểm cải tiến

1. **Chuyển phần tính toán từ kiến trúc broadcast sang lõi systolic tự viết bằng RTL**, giải quyết đúng khoản chiếm 65,4% tổng thời gian đã xác định ở mục 4.1, đồng thời loại bỏ giới hạn khả năng mở rộng độ song song do fan-out của kiến trúc broadcast — thay việc nạp lại toàn bộ dữ liệu vào thanh ghi cục bộ ở mỗi vòng lặp con bằng cơ chế tích luỹ liên tục xuyên suốt cả chiều tích luỹ, chỉ mồi đường ống đúng 1 lần đầu mỗi tile.
2. **Giao diện giữa khối HLS và khối RTL dùng các cổng bộ nhớ trong đọc trực tiếp và 1 cổng vector kết quả tổ hợp**, không qua giao thức stream hay địa chỉ hoá — phù hợp với đặc điểm dữ liệu cố định kích thước và chỉ cần đọc 1 lần khi tính xong.
3. **Kỹ thuật ghép kênh tĩnh và cộng offset địa chỉ thay cho sao chép dữ liệu**, cho phép mảng systolic xử lý đúng ma trận A với số hàng lớn hơn kích thước tile và các nhóm cột của B mà không tốn thêm chu kỳ chuyển đổi.
4. **Bỏ hẳn việc đọc/ghi cả 3 luồng dữ liệu khỏi Vitis HLS, chuyển sang 3 module RTL tự viết tay** — đây là bài học kinh nghiệm lớn nhất của Giai đoạn 2: công cụ tổng hợp có giới hạn thật khi sinh phần cứng cho các mẫu hình vòng lặp lớn xen kẽ đọc bộ nhớ ngoài và ghi bộ nhớ trong, hoặc khi cưỡng chế lịch trình cứng cho một vòng lặp — quyết định chuyển hẳn sang RTL tự viết đã giải quyết dứt điểm, đổi lại phải tự quản lý toàn bộ giao thức và địa chỉ hoá bằng tay.
5. **Tối ưu gộp burst cho module ghi C**, giảm số giao dịch ghi 32 lần, nhưng qua đo đạc thật mới phát hiện mức cải thiện thực tế không tương xứng — dẫn tới việc xác định đúng nguyên nhân gốc là chi phí đọc-sửa-ghi do lệch độ rộng dữ liệu so với cổng cao tốc, một phát hiện quan trọng cho hướng tối ưu tiếp theo.
6. **Đối chiếu kết quả với bài báo tham chiếu bằng phương pháp đo đúng**, phát hiện bài báo gốc mắc lỗi phương pháp khi công bố mức tăng tốc end-to-end — một đóng góp về mặt đánh giá khoa học, không chỉ về mặt thiết kế phần cứng.
