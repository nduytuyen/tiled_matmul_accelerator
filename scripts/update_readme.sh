#!/usr/bin/env bash
# Cap nhat phan "Tai nguyen phan cung" trong README.md tu bao cao C Synthesis
# moi nhat cua Vitis HLS. Khong goi AI - chay lai bat cu luc nao sau khi
# Run C Synthesis xong (Vitis HLS -> Project -> Run C Synthesis).
#
# Cach chay (trong Git Bash, tu thu muc goc project):
#   bash scripts/update_readme.sh
set -e
cd "$(dirname "$0")/.."

RPT="mmult_accel_hls/solution1/syn/report/mmult_accel_csynth.rpt"
README="README.md"

if [ ! -f "$RPT" ]; then
  echo "Khong tim thay $RPT"
  echo "Hay chay 'Run C Synthesis' trong Vitis HLS truoc, roi chay lai script nay."
  exit 1
fi

read -r _ BRAM_U DSP_U FF_U LUT_U _ <<< "$(grep '^|Total ' "$RPT" | tr -d '|')"
read -r _ BRAM_A DSP_A FF_A LUT_A _ <<< "$(grep '^|Available ' "$RPT" | tr -d '|')"
read -r _ _ BRAM_P DSP_P FF_P LUT_P _ <<< "$(grep '^|Utilization' "$RPT" | tr -d '|')"

EST_NS=$(grep -E '\|ap_clk[ ]*\|[ ]*[0-9]+\.[0-9]+ ns\|' "$RPT" | head -1 | awk -F'|' '{gsub(/[ ns]/,"",$4); print $4}')
FMAX=$(awk -v ns="$EST_NS" 'BEGIN{printf "%.2f", 1000/ns}')

COMMIT=$(git log -1 --format="%h (%ad)" --date=short 2>/dev/null || echo "chua co commit")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

TMP=$(mktemp)
awk -v bram_u="$BRAM_U" -v bram_a="$BRAM_A" -v bram_p="$BRAM_P" \
    -v dsp_u="$DSP_U" -v dsp_a="$DSP_A" -v dsp_p="$DSP_P" \
    -v ff_u="$FF_U" -v ff_a="$FF_A" -v ff_p="$FF_P" \
    -v lut_u="$LUT_U" -v lut_a="$LUT_A" -v lut_p="$LUT_P" \
    -v fmax="$FMAX" -v ts="$TIMESTAMP" -v commit="$COMMIT" '
  /<!-- AUTO:RESOURCES:START -->/ {
    print
    print ""
    print "## Tài nguyên phần cứng (C Synthesis - Vitis HLS)"
    print ""
    print "| Resource | Used | Available | Utilization | Bài báo (Table 1, sau Vivado implementation) |"
    print "|---|---|---|---|---|"
    print "| BRAM_18K | " bram_u " | " bram_a " | " bram_p "% | 126/144 (88%) |"
    print "| DSP | " dsp_u " | " dsp_a " | " dsp_p "% | 1040/1248 (83%) |"
    print "| FF | " ff_u " | " ff_a " | " ff_p "% | 102741/237600 (43%) |"
    print "| LUT | " lut_u " | " lut_a " | " lut_p "% | 71050/118800 (60%) |"
    print ""
    print "Estimated Fmax: **" fmax " MHz** (mục tiêu 100 MHz)"
    print ""
    print "_Số liệu HLS ước tính cho riêng IP core, chưa gồm hạ tầng AXI SmartConnect khi ráp vào Vivado. Số liệu đầy đủ (khớp Table 1 bài báo) chỉ có sau khi Generate Bitstream trong Vivado._"
    print ""
    print "_Cập nhật tự động lúc " ts ", commit " commit "._"
    skip=1
    next
  }
  /<!-- AUTO:RESOURCES:END -->/ { skip=0 }
  !skip { print }
' "$README" > "$TMP" && mv "$TMP" "$README"

echo "Da cap nhat $README (BRAM ${BRAM_P}%, DSP ${DSP_P}%, FF ${FF_P}%, LUT ${LUT_P}%, Fmax ${FMAX}MHz)"
