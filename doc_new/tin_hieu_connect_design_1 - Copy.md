
## 4. Bó dây điều khiển/bắt tay (`mmult_accel_0` → 4 module)

Cả 4 bó dây đều xuất phát từ `mmult_accel_0`, chỉ khác đích đến và số lượng tín hiệu.

### `A_CONNECT` — 3 tín hiệu (↔ `AXI4_A_READER`)

| Tín hiệu phía `mmult_accel_0` | Tín hiệu phía `AXI4_A_READER` | Chiều | Ý nghĩa |
|---|---|---|---|
| `a_base_addr_o` | `a_base_addr_i` | ra | địa chỉ gốc DDR của A |
| `a_reload_req_o` | `a_reload_req_i` | ra (xung 1 chu kỳ) | báo bắt đầu nạp lại A |
| `a_loaded_i` | `a_loaded_o` | vào (mức) | báo đã nạp xong, giữ tới lần reload kế |

### `B_CONNECT` — 6 tín hiệu (↔ `AXI4_B_READER`)

| Tín hiệu phía `mmult_accel_0` | Tín hiệu phía `AXI4_B_READER` | Chiều | Ý nghĩa |
|---|---|---|---|
| `b_base_addr_o` | `b_base_addr_i` | ra | địa chỉ gốc DDR của block B hiện tại |
| `b_row_stride_o` | `b_row_stride_i` | ra | = M, bước nhảy địa chỉ giữa các hàng |
| `b_num_rows_o` | `b_num_rows_i` | ra | = K, số hàng cần đọc |
| `b_block_width_o` | `b_block_width_i` | ra | = current_block_M (≤256), độ rộng block |
| `b_reload_req_o` | `b_reload_req_i` | ra (xung 1 chu kỳ) | báo bắt đầu nạp lại B |
| `b_loaded_i` | `b_loaded_o` | vào (mức) | báo đã nạp xong block hiện tại |

### `TILE_CONTROL` — 3 tín hiệu (↔ `SYSTOLIC_CORE_TOP`)

| Tín hiệu phía `mmult_accel_0` | Tín hiệu phía `SYSTOLIC_CORE_TOP` | Chiều | Ý nghĩa |
|---|---|---|---|
| `tile_valid_o` | `tile_valid_i` | ra (mức) | báo tile mới bắt đầu tính |
| `tile_ready_i` | `tile_ready_o` | vào (mức) | báo rảnh, sẵn sàng nhận tile |
| `tile_done_i` | `tile_done_o` | vào (xung 1 chu kỳ) | báo tính xong tile |

### `C_CONTROL` — 7 tín hiệu (↔ `AXI4_C_WRITER`)

| Tín hiệu phía `mmult_accel_0` | Tín hiệu phía `AXI4_C_WRITER` | Chiều | Ý nghĩa |
|---|---|---|---|
| `c_base_addr_o` | `c_base_addr_i` | ra | địa chỉ gốc DDR của C |
| `c_row_stride_o` | `c_row_stride_i` | ra | = M, số cột 1 hàng C |
| `c_global_i0_o` | `c_global_i0_i` | ra | hàng bắt đầu của tile |
| `c_global_j0_o` | `c_global_j0_i` | ra | cột bắt đầu của tile |
| `c_valid_rows_o` | `c_valid_rows_i` | ra | số hàng hợp lệ trong tile (≤32) |
| `c_valid_cols_o` | `c_valid_cols_i` | ra | số cột hợp lệ trong tile (≤32) |
| `c_write_done_i` | `c_write_done_o` | vào (mức) | báo đã ghi xong C của tile |

**Ghi chú quan trọng**: `tile_valid_i`/`tile_done_i` của `AXI4_C_WRITER` (trong `C_CONTROL`) thực
chất **fan-out từ chính bó `TILE_CONTROL`** (cùng dây với `mmult_accel_0`↔`SYSTOLIC_CORE_TOP`),
không phải đường bắt tay riêng — `AXI4_C_WRITER` chỉ "nghe lén" 2 tín hiệu đó để biết khi nào tile
bắt đầu/xong, còn phần địa chỉ/kích thước ghi (`c_base_addr_o`...) mới là đường thật của `C_CONTROL`.


