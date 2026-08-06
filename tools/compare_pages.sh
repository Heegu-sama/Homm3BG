#!/usr/bin/env bash
cache_dir="$(pwd)/cache"
screenshots_dir="$(pwd)/screenshots"

source tools/.language_base.sh
mkdir -p "${screenshots_dir}"

# Two builds of the same page are never pixel-identical, so differences are
# judged by density: a real change is a solid blob, noise is scattered dust.
diff_sensitivity=10       # how strong a pixel difference has to be, in percent
diff_density=35           # how dense a neighbourhood has to be, in percent
diff_min_area_default=120 # smallest blob that is not noise, in pixels
diff_min_thickness=8      # thinnest blob that is not noise, in pixels

#
# HELPER FUNCTIONS
#

help() {
  echo "
    Usage: ./tools/compare_pages.sh <language> -r <range> [OPTIONS]

    Mandatory Arguments:
    <language>                      Specify the language for comparison (${valid_languages[*]}). Defaults to en.
      -r, --range <range>           Provide comma-separated list of pages or range of pages you want to compare,
                                    with optional target page where the range was moved to.
                                    Mutually exclusive with '--all'.
      -a, --all                     Compare every page of the document. Pages without a real difference
                                    are skipped, so only pages that actually changed end up in the output.
                                    Mutually exclusive with '--range'.

    Optional Arguments:
      -p, --printable               Compares your build against 'printable' build.
      -s, --single-page             Combines all compared pages into a single image.
      -o, --open                    Open directory with screenshots.
      -d, --debug                   Open every comparison in a viewer the moment it is ready, instead of
                                    waiting for the whole run to finish. One window per changed page.
      -g, --highlight               Mark the changed areas on your build with a translucent green wash.
                                    Off by default, the pages are left as they are.
      -t, --threshold <pixels>      Smallest area, in pixels, that counts as a real difference rather than
                                    rendering noise. Lower it if changes are missed, raise it if noise
                                    gets highlighted. Defaults to ${diff_min_area_default}.

    With '--highlight', changed areas are marked with a translucent green box on the right-hand
    (your build) page.

    Examples:
      ./tools/compare_pages.sh en -r 1
      ./tools/compare_pages.sh cs --range 1

      ./tools/compare_pages.sh -r 1,5-7,30 --single-page --printable
          - This will produce files 'en-01.png, en-05.png, en-06.png, en-07.png and en-30.png', becasue default English language will be used.
          - Then because there is the '--single-page' parameter, it combines them to a single file 'en-all.png'.
          - It will use 'printable_en.pdf' from the repository as baseline because '--printable' was specified.
            It would use 'main_en.pdf' if this parameter was omitted.

      ./tools/compare_pages.sh pl --all
          - This will render every page of both documents and save only the pages that
            actually differ, one image per page.

      ./tools/compare_pages.sh fr -r 2,5:7,8-9:6
          This will produce the following 4 images:
          - fr-02.png with page 2 on the left and page 2 on the right,
          - fr-05.png with page 5 on the left and page 7 on the right,
          - fr-08.png with page 8 on the left and page 6 on the right,
          - fr-09.png with page 9 on the left and page 7 on the right,
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

page_count() {
  pdfinfo "$1" 2>/dev/null | awk '/^Pages:/ {print $2}'
}

# Blocks until a page is fully rendered, then prints its filename. pdftoppm
# writes pages in order, so a page is done once the next one appears - and for
# the last page, once the renderer itself is gone.
wait_for_page() {
  local prefix="$1"
  local page="$2"
  local pid="$3"
  local still_rendering current next

  while :; do
    still_rendering=0
    kill -0 "$pid" 2>/dev/null && still_rendering=1

    current=$(get_actual_filename "$tmp_dir" "$prefix" "$page")
    next=$(get_actual_filename "$tmp_dir" "$prefix" $((page + 1)))

    if [[ -n "$current" && -n "$next" ]]; then
      echo "$current"
      return 0
    fi

    if [[ "$still_rendering" -eq 0 ]]; then
      echo "$current"
      [[ -n "$current" ]]
      return
    fi

    sleep 0.2
  done
}

# Prints the bounding box of every meaningful difference between two images, one
# 'WxH+X+Y' per line, or nothing when the pages are effectively the same.
#
# Both pages are blurred into ink-density maps *before* they are subtracted,
# which is the whole trick: subtracting sharp images only lights up the fringes
# of an edited word, since wherever old and new letters both put ink the
# difference is zero. Then: binarise -> close -> blur -> binarise -> blobs.
diff_regions() {
  local left="$1"
  local right="$2"
  local min_area="$3"

  magick \( "$left" -colorspace Gray -blur 0x2 \) \
         \( "$right" -colorspace Gray -blur 0x2 \) \
    -compose difference -composite \
    -threshold "${diff_sensitivity}%" \
    -morphology Close Disk:3 \
    -blur 0x3 -threshold "${diff_density}%" \
    -define connected-components:verbose=true \
    -define connected-components:mean-color=true \
    -define connected-components:area-threshold="${min_area}" \
    -connected-components 8 null: 2>/dev/null \
    | awk -v thickness="$diff_min_thickness" '
        $5 ~ /\(255,255,255\)|gray\(255\)|white/ {
          split($2, box, /[x+]/)
          if (box[1] >= thickness && box[2] >= thickness) {
            print $2
          }
        }'
}

# Paints a translucent green wash over the given regions. They are collected
# into a single mask first: drawing them one by one would make every overlap
# darker, which reads as "this bit changed more" while meaning nothing.
highlight_regions() {
  local source_image="$1"
  local output_image="$2"
  shift 2
  local -a draw_args
  local box width height rest x y padding=6
  local dimensions mask holes

  for box in "$@"; do
    width=${box%%x*}
    rest=${box#*x}
    height=${rest%%+*}
    rest=${rest#*+}
    x=${rest%%+*}
    y=${rest#*+}

    draw_args+=(-draw "rectangle $((x - padding)),$((y - padding)) $((x + width + padding)),$((y + height + padding))")
  done

  dimensions=$(magick identify -format '%wx%h' "$source_image")
  mask=$(mktemp "${tmp_dir}/mask-XXXXXX.png")
  holes=$(mktemp "${tmp_dir}/holes-XXXXXX.png")

  # White where something changed. The closing pulls in boxes that are merely
  # near each other, so slivers between them stop showing through.
  magick -size "$dimensions" xc:black -fill white "${draw_args[@]}" -alpha off \
    -morphology Close Disk:10 "$mask"

  # Flooding from the border paints everything the outside can reach; whatever
  # stays black is enclosed, which is exactly the set of holes to fill.
  magick "$mask" -bordercolor black -border 1 \
    -fill white -draw 'color 0,0 floodfill' \
    -negate -shave 1x1 "$holes"
  magick "$mask" "$holes" -compose lighten -composite "$mask"

  magick "$source_image" \
    \( -size "$dimensions" xc:'rgb(126,217,87)' "$mask" \
       -alpha off -compose copy_opacity -composite \
       -channel A -evaluate multiply 0.30 +channel \) \
    -compose over -composite \
    \( "$mask" -morphology EdgeOut Octagon:2 \
       -size "$dimensions" xc:'rgb(58,150,30)' +swap \
       -alpha off -compose copy_opacity -composite \) \
    -compose over -composite \
    "$output_image"

  rm -f "$mask" "$holes"
}

case "$(uname -s)" in
  Darwin*)
    open=open
    ;;
  Linux*)
    open=xdg-open
    ;;
  MINGW*|MSYS*|CYGWIN*)
    open=start
    ;;
esac

#
# MAIN FLOW
#

range=""
printable=0
single_page=0
open_directory=0
all_pages=0
debug=0
highlight=0
diff_min_area=$diff_min_area_default

while [[ "$1" != "" ]]; do
  case $1 in
    -p | --printable )
      printable=1
      ;;
    -r | --range )
      shift
      range=$1
      ;;
    -a | --all )
      all_pages=1
      ;;
    -t | --threshold )
      shift
      diff_min_area=$1
      ;;
    -s | --single-page )
      single_page=1
      ;;
    -o | --open )
      open_directory=1
      ;;
    -d | --debug )
      debug=1
      ;;
    -g | --highlight )
      highlight=1
      ;;
    * )
      help
      ;;
  esac
  shift
done

if [[ -z "$LANGUAGE" ]] || [[ -z "$range" && "$all_pages" -eq 0 ]]; then
  help
fi

if [[ -n "$range" && "$all_pages" -eq 1 ]]; then
  echo "Error: '--range' and '--all' cannot be used together."
  exit 2
fi

if [[ ! -f "main_${LANGUAGE}.pdf" ]]; then
  echo "❌ There is no 'main_${LANGUAGE}.pdf' to compare against. Build it first,"
  echo "   or pass the language you actually mean - without it '${LANGUAGE}' is assumed."
  exit 1
fi

echo "Checking if there is the base file for comparison..."
base_file=$(ensure_base_file "$LANGUAGE" "$printable")

tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT

declare -A moved
declare -a pages

if [[ "$all_pages" -eq 1 ]]; then
  base_pages=$(page_count "$base_file")
  own_pages=$(page_count "main_${LANGUAGE}.pdf")
  last_page=$(( base_pages < own_pages ? base_pages : own_pages ))

  if [[ "$base_pages" -ne "$own_pages" ]]; then
    echo "Note: base file has ${base_pages} pages, main_${LANGUAGE}.pdf has ${own_pages}. Comparing the first ${last_page}."
  fi

  for ((page=1; page<=last_page; page++)); do
    pages+=($page)
  done

  echo "Making images of ${base_file} and main_${LANGUAGE}.pdf for pages 1-${last_page}..."
  echo "Pages are compared as soon as they are rendered."
  pdftoppm "${base_file}" "${tmp_dir}/aa" -f 1 -l "${last_page}" -png &
  aa_pid=$!
  pdftoppm "main_${LANGUAGE}.pdf" "${tmp_dir}/bb" -f 1 -l "${last_page}" -png &
  bb_pid=$!
else
  parse_pages "$range"

  for page in "${pages[@]}"; do
    echo "Making images of ${base_file} and main_${LANGUAGE}.pdf for page ${page}..."
    pdftoppm "${base_file}" "${tmp_dir}/aa" -f "${page}" -l "${page}" -png &
    pdftoppm "main_${LANGUAGE}.pdf" "${tmp_dir}/bb" -f "${moved[${page}]:-${page}}" -l "${moved[${page}]:-${page}}" -png &
  done

  wait
fi

declare -a skipped_pages
declare -a changed_pages
page_index=0
page_total=${#pages[@]}

for page in "${pages[@]}"; do
  page_index=$((page_index + 1))

  if [[ "$all_pages" -eq 1 ]]; then
    aa_file=$(wait_for_page "aa" "$page" "$aa_pid")
    bb_file=$(wait_for_page "bb" "$page" "$bb_pid")
  else
    aa_file=$(get_actual_filename "$tmp_dir" "aa" "$page")
    bb_file=$(get_actual_filename "$tmp_dir" "bb" "${moved[${page}]:-${page}}")
  fi

  if [[ -z "$aa_file" || -z "$bb_file" ]]; then
    echo "⚠️ Could not find generated files for page $page"
    continue
  fi

  mapfile -t regions < <(diff_regions "${tmp_dir}/${aa_file}" "${tmp_dir}/${bb_file}" "$diff_min_area")

  if [[ "${#regions[@]}" -eq 0 ]]; then
    if [[ "$all_pages" -eq 1 ]]; then
      printf '[%d/%d] Page %02d: no differences ⏭️\n' "$page_index" "$page_total" "$page"
      skipped_pages+=($page)
      rm "${tmp_dir}/${aa_file}" "${tmp_dir}/${bb_file}"
      continue
    fi
    printf '[%d/%d] Page %02d: no differences, saved anyway ✅\n' "$page_index" "$page_total" "$page"
  else
    changed_pages+=($page)
    printf '[%d/%d] Page %02d: %d changed area(s) ✅\n' \
      "$page_index" "$page_total" "$page" "${#regions[@]}"

    [[ "$highlight" -eq 1 ]] && \
      highlight_regions "${tmp_dir}/${bb_file}" "${tmp_dir}/${bb_file}" "${regions[@]}"
  fi

  # Written straight to its final place, so that a page reported as saved is on
  # disk instead of waiting for the rest of the run to finish.
  comparison="${screenshots_dir}/${LANGUAGE}-$(printf %02d $page).png"

  {
    montage "${tmp_dir}/${aa_file}" "${tmp_dir}/${bb_file}" -tile 2x1 -geometry +0+0 "$comparison" && \
    rm "${tmp_dir}/${aa_file}" "${tmp_dir}/${bb_file}" && \
    [[ "$debug" -eq 1 ]] && ${open} "$comparison" >/dev/null 2>&1
  } &
done

wait

if [[ "$all_pages" -eq 1 ]]; then
  echo "Unchanged pages skipped (${#skipped_pages[@]}): ${skipped_pages[*]:-none}"
  echo "Pages with differences (${#changed_pages[@]}): ${changed_pages[*]:-none}"

  if [[ "${#changed_pages[@]}" -eq 0 ]]; then
    echo "Nothing to show, both documents look the same."
    exit 0
  fi
fi

if [[ "$single_page" -eq 1 ]]; then
  montage ${screenshots_dir}/${LANGUAGE}-[0-9]*.png -tile "1x" -geometry +0+0 ${screenshots_dir}/${LANGUAGE}-all.png
fi

echo "Done. Images saved to ${screenshots_dir} directory."

if [[ "$open_directory" -eq 1 ]]; then
  ${open} "${screenshots_dir}"
fi
