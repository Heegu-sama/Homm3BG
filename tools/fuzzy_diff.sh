#!/usr/bin/env bash

# Function to print usage information
usage() {
  echo "Usage: $0 [PO file]"
  echo "Example: $0 translations/ai_rules.tex/cs.po"
  echo
  echo "Shows difference in the first fuzzy entry of the supplied PO file."
  exit 1
}

if [[ $# -eq 1 ]]
then
  case $1 in
    -h|--help)
        usage
    ;;
  esac
else
    usage
fi

MYTMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$MYTMPDIR"' EXIT
msgattrib --only-fuzzy "$1" > "$MYTMPDIR/fuzzy_only.po"
awk '/^#, fuzzy/ {print; found=1; next} found {print; if (/^msgstr/) exit}' "$MYTMPDIR/fuzzy_only.po" > "$MYTMPDIR/fuzzy_first.po"
awk '/^#\|/,/^msgid/ {if ($0 ~ /^#\|/) print substr($0, 4)}' "$MYTMPDIR/fuzzy_first.po" > "$MYTMPDIR/old.po"
awk '/^msgid/,/^msgstr/ {print}' "$MYTMPDIR/fuzzy_first.po" | head -n -1 > "$MYTMPDIR/new.po"
diff -u "$MYTMPDIR/old.po" "$MYTMPDIR/new.po" | delta \
  --no-gitconfig \
  --dark \
  --width=variable \
  --file-style="omit" \
  --hunk-header-style="omit" \
  --minus-style="white bold #86605F" \
  --minus-emph-style="black bold #C98789" \
  --plus-style="white bold #5F885F" \
  --plus-emph-style="black bold #50AF85"
