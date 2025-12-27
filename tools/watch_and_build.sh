#!/usr/bin/env bash

source tools/.language_base.sh

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
  echo "  --printable, -p    Enable printable mode"
  echo "  --help, -h         Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 -p        # Watch English files in printable mode"
  echo "  $0 fr -c     # Watch French translations, build in container"
  echo ""
  echo "Press Ctrl-C to stop all watchers."
  exit 1
}

CONTAINER=""
PRINTABLE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--printable)
        PRINTABLE="--printable"
        shift
        ;;
    -c|--container)
        CONTAINER="./run.sh"
        shift
        ;;
  esac
done

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
  echo "$file" | entr -cps "echo 'Detected changes in \"$file\"'; $CONTAINER tools/build.sh $LANGUAGE -s $name $PRINTABLE --args \"-silent\"" &
done

echo "Waiting for changes in ${TARGET:1} files"
wait
