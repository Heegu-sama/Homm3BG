#!/usr/bin/env bash

cache_dir="$(pwd)/cache"

#
# HELPER FUNCTIONS
#

help() {
  echo "Usage: $0 -l <language> [--language=<language>] [-p] [--printable] -r <range> [--range=<range>] [-s] [--single-page]"
  echo "-r, --range: use single page number or dash-separated range of pages"
  exit 2
}

url() {
  type=$([[ "$2" -eq 1 ]] && echo "printable" || echo "main")
  echo "https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/${1}/${type}_${1}.pdf"
}

file_type() {
  [[ "$1" -eq 1 ]] && echo "printable" || echo "main"
}

base_file_path() {
  local language="$1"
  local printable="$2"
  type=$(file_type $printable)

  echo "${cache_dir}/${type}_${language}.pdf"
}

download_base_file() {
  echo "Downloading base file..."

  local language="$1"
  local printable="$2"
  type=$(file_type "$printable")

  url="https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/${language}/${type}_${language}.pdf"
  curl -o "${cache_dir}/${type}_${language}.pdf" "$url"
}

file_mod_time() {
  local file=$1
  if [[ "$(uname)" == "Darwin" ]]; then
    stat -f %m "$file"
  else 
    stat -c %Y "$file"
  fi
}

ensure_base_file() {
  echo "Checking if there is the base file for comparison..."

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
}

#
# MAIN FLOW
#

language=""
printable=0
range=""
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

mkdir -p $cache_dir

ensure_base_file "$language" "$printable"
base_file=$(base_file_path "$language" "$printable")

first_page="$range"
last_page="$range"
if [[ $range == *"-"* ]]; then
  IFS="-" read -ra pages <<< "$range"
  first_page="${pages[0]}"
  last_page="${pages[1]}"
fi

random_dir="$(mktemp -d)"
trap 'rm -rf -- "$random_dir"' EXIT

echo "Making images of ${base_file} and main_${language}.pdf..."
pdftoppm "${base_file}" "${random_dir}/aa" -f "${first_page}" -l "${last_page}" -png -progress &
pdftoppm "main_${language}.pdf" "${random_dir}/bb" -f "${first_page}" -l "${last_page}" -png -progress &
wait

for page in $(seq ${first_page} ${last_page})
do
  echo "Combining pages $(printf %02d $page)..."
  montage ${random_dir}/*$(printf %02d $page).png -tile 2x1 -geometry +0+0 ${random_dir}/${language}-$(printf %02d $page).png && \
  rm ${random_dir}/aa-$(printf %02d $page).png ${random_dir}/bb-$(printf %02d $page).png &
done


if [[ "$single_page" -eq 1 ]]; then
  wait
  montage ${random_dir}/${language}* -tile "1x" -geometry +0+0 ${random_dir}/${language}-all.png
fi

wait
mv ${random_dir}/${language}* .
echo "Done."
