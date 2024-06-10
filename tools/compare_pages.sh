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
      -r, --range <range>           Provide comma-separated list of pages or range of pages you want to compare. 

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

# Only download a base file if it's not already present locally or
# is older than 1 hour. Otherwise we use the cached one to speed-up the workflow.
ensure_base_file() {
  local language="$1"
  local printable="$2"
  local base_file=$(base_file_path "$language" "$printable")

  if [[ -f $base_file ]]; then
    mod_time=$(file_mod_time "$base_file")
    now=$(date +%s)
    age=$((now - mod_time))  # seconds

    if [[ $age -gt 3600 ]]; then
      download_base_file "$language" "$printable"
    fi
  else
    download_base_file "$language" "$printable"
  fi

  echo "$base_file"
}

# Parses the --range argument into an array of pages.
# e.g. '1,2,4-6,20' becomes [1,2,4,5,6,20]
parse_pages() {
  local range="$1"
  local pages=()

  IFS=',' read -ra parts <<< "$range"

  for part in "${parts[@]}"; do
    if [[ $part == *"-"* ]]; then
      start=$(echo "$part" | cut -d"-" -f1)
      end=$(echo "$part" | cut -d"-" -f2)
      for ((i=start; i<=end; i++)); do
        pages+=($i)
      done
    else
      pages+=($part)
    fi
  done

  echo "${pages[@]}"
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

pages=$(parse_pages "$range")

for page in $pages; do
  echo "Making images of ${base_file} and main_${language}.pdf for page ${page}..."
  pdftoppm "${base_file}" "${tmp_dir}/aa" -f "${page}" -l "${page}" -png -progress &
  pdftoppm "main_${language}.pdf" "${tmp_dir}/bb" -f "${page}" -l "${page}" -png -progress &
done

wait

for page in $pages; do
  echo "Combining pages $(printf %02d $page)..."
  montage ${tmp_dir}/*$(printf %02d $page).png -tile 2x1 -geometry +0+0 ${tmp_dir}/${language}-$(printf %02d $page).png && \
  rm ${tmp_dir}/aa-$(printf %02d $page).png ${tmp_dir}/bb-$(printf %02d $page).png &
done


if [[ "$single_page" -eq 1 ]]; then
  wait
  montage ${tmp_dir}/${language}* -tile "1x" -geometry +0+0 ${tmp_dir}/${language}-all.png
fi

wait

mkdir -p screenshots
mv ${tmp_dir}/${language}* screenshots

echo "Done."
