#!/usr/bin/env bash

# 功能：將大檔案（預設為 Xorg.0.log）依指定大小（MB）切割成多個小檔案

set -euo pipefail
IFS=$'\n\t'

# 預設每個 chunk 的大小（單位：MB）
DEFAULT_SIZE_MB=500

# 顯示使用說明
usage() {
  cat <<EOF
用法：$0 [-s SIZE_MB] [-h] 檔案路徑

  -s SIZE_MB   每個切割檔案最大大小，單位為 MB（預設：${DEFAULT_SIZE_MB}）
  -h           顯示此說明並離開

範例：
  $0 -s 100 Xorg.0.log    # 以 100MB 為單位切割 Xorg.0.log
EOF
  exit 1
}

# 解析參數
size_mb=${DEFAULT_SIZE_MB}
while getopts ":s:h" opt; do
  case "${opt}" in
    s)
      size_mb=${OPTARG}
      # 驗證是否為正整數
      if ! [[ "${size_mb}" =~ ^[0-9]+$ ]]; then
        echo "錯誤：SIZE_MB 必須為正整數（MB）" >&2
        exit 1
      fi
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# 檢查檔案參數
if [[ $# -ne 1 ]]; then
  usage
fi

file_path="$1"
if [[ ! -f "${file_path}" ]]; then
  echo "錯誤：找不到檔案：${file_path}" >&2
  exit 1
fi

# 取得檔名與目錄
base_name="$(basename "${file_path}")"
dir_name="$(dirname "${file_path}")"

# 切割後檔名前綴
prefix="${dir_name}/${base_name}.part_"

echo "開始將「${file_path}」依每塊 ${size_mb}MB 切割..."

# 執行切割
# -b 指定大小 (M=MB)
# -d 使用數字後綴
# --suffix-length=3 後綴長度固定為 3 位 (000,001,…)
split -b "${size_mb}M" -d --suffix-length=3 "${file_path}" "${prefix}"

echo "切割完成，已產生以下檔案："
ls -lh "${dir_name}/${base_name}.part_"*
