#!/usr/bin/env bash
cache_dir="$(pwd)/cache"

#
# HELPER FUNCTIONS
#

help() {
  echo "
    Usage: ./tools/compare_pages.sh -l <language> -r <range> [OPTIONS]

    Mandatory Arguments:
      -l, --language <language>     Specify the language for comparison (en, de, es, fr, pl, ru, ua, cs, ...).
      -r, --range <range>           Provide comma-separated list of pages or range of pages you want to compare,
                                    with optional target page where the range was moved to.

    Optional Arguments:
      -p, --printable               Compares your build against 'printable' build.
      -s, --single-page             Combines all compared pages into a single image.

    Examples:
      ./tools/compare_pages.sh -l en -r 1
      ./tools/compare_pages.sh --language en --range 1

      ./tools/compare_pages.sh -l en -r 1,5-7,30 --single-page --printable
          - This will produce files 'en-01.png, en-05.png, en-06.png, en-07.png and en-30.png'.
          - Then because there is the '--single-page' parameter, it combines them to a single file 'en-all.png'.
          - It will use 'printable_en.pdf' from the repository as baseline because '--printable' was specified.
            It would use 'main_en.pdf' if this parameter was omitted.

      ./tools/compare_pages.sh -l en -r 2,5:7,8-9:6
          This will produce the following 4 images:
          - en-02.png with page 2 on the left and page 2 on the right,
          - en-05.png with page 5 on the left and page 7 on the right,
          - en-08.png with page 8 on the left and page 6 on the right,
          - en-09.png with page 9 on the left and page 7 on the right,
            as part of the same 8-9 range which was shifted to start at 6.
  "

  exit 2
}

file_type() {
  local printable="$1"
  [[ "$printable" -eq 1 ]] && echo "printable" || echo "main"
}

base_file_path() {
  local language="$1"
  local printable="$2"
  local type=$(file_type "$printable")

  echo "${cache_dir}/${type}_${language}.pdf"
}

download_base_file() {
  local language="$1"
  local printable="$2"
  local type=$(file_type "$printable")
  local url="https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/${language}/${type}_${language}.pdf"
  local output_file=$(base_file_path "$language" "$printable")

  mkdir -p "$cache_dir"
  curl -o "$output_file" "$url"
}

file_mod_time() {
  local file=$1
  if [[ "$(uname -s)" == "Darwin" ]]; then
    stat -f %m "$file"
  else
    stat -c %Y "$file"
  fi
}

# Check if cached PDF is up-to-date
is_pdf_current() {
  local pdf_file="$1"

  if [[ ! -f "$pdf_file" ]]; then
    return 1
  fi

  # First check: time-based check (fast)
  local mod_time now age
  mod_time=$(file_mod_time "$pdf_file")
  now=$(date +%s)
  age=$((now - mod_time))  # seconds

  # If file is newer than 3 hours, consider it current
  if [[ $age -le 10800 ]]; then
    return 0
  fi

  # File is older than 3 hours, check commit SHA using GitHub API
  if command -v pdftotext >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
    # Get latest commit SHA and check if it's in the PDF
    local latest_sha
    latest_sha=$(curl -s -f -H "Accept: application/vnd.github.VERSION.sha" "https://api.github.com/repos/Heegu-sama/Homm3BG/commits/main" 2>/dev/null)
    if [[ -n "$latest_sha" ]] && pdftotext "$pdf_file" - 2>/dev/null | grep -q "${latest_sha:0:7}"; then
      return 0
    fi
  fi
  return 1
}

# Only download a base file if it's not already present locally or
# is outdated based on age or commit SHA (with poppler).
ensure_base_file() {
  local language="$1"
  local printable="$2"
  local base_file=$(base_file_path "$language" "$printable")

  if ! is_pdf_current "$base_file"; then
    download_base_file "$language" "$printable"
  fi

  echo "$base_file"
}

# Parses the --range argument into an array of pages.
# e.g. '1,2,4-6,20' becomes [1,2,4,5,6,20]
parse_pages() {
  local range="$1"
  local -a parts
  local part
  local left
  local right
  local start
  local end
  local i

  IFS=',' read -ra parts <<< "$range"

  for part in "${parts[@]}"; do
    left=${part%%:*}
    right=$(echo ${part#*:} | cut -d"-" -f1)
    if [[ $left == *"-"* ]]; then
      start=$(echo "$left" | cut -d"-" -f1)
      end=$(echo "$left" | cut -d"-" -f2)
      for ((i=start; i<=end; i++)); do
        pages+=($i)
        if [[ -n $right ]]; then
          moved[$i]=$((i + right - start))
        fi
      done
    else
      pages+=($left)
      if [[ -n $right ]]; then
        moved[$left]=$right
      fi
    fi
  done
}

# Function to get the actual filename format used by pdftoppm
get_actual_filename() {
  local tmp_dir="$1"
  local prefix="$2"
  local page="$3"

  # Try zero-padded format first (aa-01.png)
  if [[ -f "${tmp_dir}/${prefix}-$(printf %02d $page).png" ]]; then
    echo "${prefix}-$(printf %02d $page).png"
  # Try single digit format (aa-1.png)
  elif [[ -f "${tmp_dir}/${prefix}-${page}.png" ]]; then
    echo "${prefix}-${page}.png"
  # Try three-digit format (aa-001.png) for very large PDFs
  elif [[ -f "${tmp_dir}/${prefix}-$(printf %03d $page).png" ]]; then
    echo "${prefix}-$(printf %03d $page).png"
  else
    echo ""
  fi
}

#
# MAIN FLOW
#

language=""
range=""
printable=0
single_page=0

while [[ "$1" != "" ]]; do
  case $1 in
    -l | --language )
      shift
      language=$1
      ;;
    -p | --printable )
      printable=1
      ;;
    -r | --range )
      shift
      range=$1
      ;;
    -s | --single-page )
      single_page=1
      ;;
    * )
      help
      ;;
  esac
  shift
done

if [[ -z "$language" || -z "$range" ]]; then
  help
fi

echo "Checking if there is the base file for comparison..."
base_file=$(ensure_base_file "$language" "$printable")

tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT

declare -A moved
declare -a pages
parse_pages "$range"

for page in "${pages[@]}"; do
  echo "Making images of ${base_file} and main_${language}.pdf for page ${page}..."
  pdftoppm "${base_file}" "${tmp_dir}/aa" -f "${page}" -l "${page}" -png &
  pdftoppm "main_${language}.pdf" "${tmp_dir}/bb" -f "${moved[${page}]:-${page}}" -l "${moved[${page}]:-${page}}" -png &
done

wait

for page in "${pages[@]}"; do
  echo "Combining pages $(printf %02d $page)..."

  # Get actual filenames generated by pdftoppm
  aa_file=$(get_actual_filename "$tmp_dir" "aa" "$page")
  bb_file=$(get_actual_filename "$tmp_dir" "bb" "${moved[${page}]:-${page}}")

  if [[ -n "$aa_file" && -n "$bb_file" ]]; then
    montage "${tmp_dir}/${aa_file}" "${tmp_dir}/${bb_file}" -tile 2x1 -geometry +0+0 "${tmp_dir}/${language}-$(printf %02d $page).png" && \
    rm "${tmp_dir}/${aa_file}" "${tmp_dir}/${bb_file}" &
  else
    echo "Warning: Could not find generated files for page $page"
  fi
done

if [[ "$single_page" -eq 1 ]]; then
  wait
  montage ${tmp_dir}/${language}* -tile "1x" -geometry +0+0 ${tmp_dir}/${language}-all.png
fi

wait

mkdir -p screenshots
mv ${tmp_dir}/${language}* screenshots

echo "Done. Images saved to screenshots directory."
