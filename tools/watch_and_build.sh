#!/usr/bin/env bash

LANGUAGE="en"
valid_languages=("en" "pl" "es" "fr" "ua" "ru" "cs" "he" "de")

is_valid_language() {
  local lang="$1"
  for valid_lang in "${valid_languages[@]}"; do
    if [[ "$lang" = "$valid_lang" ]]; then
      return 0
    fi
  done
  return 1
}

# Check if first argument is a language code
if [[ $1 =~ ^[a-z]{2}$ ]]; then
  if is_valid_language "$1"; then
    LANGUAGE="$1"
    shift
  else
    echo "Error: Invalid language code '$1'. Valid codes are: ${valid_languages[*]}" >&2
    exit 1
  fi
fi

usage() {
  echo "Usage: $0 [LANGUAGE] [--container|-c]"
  echo "Watch all sections/*.tex files and automatically rebuild when changed."
  echo "In case of non-English languages, watch po files instead."
  echo ""
  echo "Each file gets its own entr process, so editing sections/setup.tex triggers:"
  echo "  tools/build.sh -s setup --args \"-silent\""
  echo ""
  echo "Options:"
  echo "  LANGUAGE           Two-letter language code (default: en)"
  echo "  --container, -c    Run build.sh via ./run.sh container wrapper"
  echo "  --help, -h         Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0           # Watch English files"
  echo "  $0 fr -c     # Watch French translations, build in container"
  echo ""
  echo "Press Ctrl-C to stop all watchers."
  exit 1
}

CONTAINER=""
[[ "$1" == "--container" || "$1" == "-c" ]] && CONTAINER="./run.sh"


if [[ "$LANGUAGE" == "en" ]]; then
  BASE_PATH="sections"
  TARGET=".tex"
else
  BASE_PATH="translations"
  TARGET="/$LANGUAGE.po"
fi

for file in "$BASE_PATH"/*"$TARGET"; do
  if [[ "$LANGUAGE" == "en" ]]; then
    name=$(basename "$file" "$TARGET")
  else
    name=$(basename "$(dirname "$file")" .tex)
  fi
  echo "$file" | entr -cps "echo 'Detected changes in \"$file\"'; $CONTAINER tools/build.sh $LANGUAGE -s $name --args \"-silent\"" &
done

echo "Waiting for changes in ${TARGET:1} files"
wait
