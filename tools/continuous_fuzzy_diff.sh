#!/usr/bin/env bash

FILE=$1

case "$(uname -s)" in
  Darwin*|Linux*)
    echo "$FILE" | entr -c tools/fuzzy_diff.sh "$FILE"
    ;;
  MINGW*|MSYS*|CYGWIN*)

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf -- "$tmp_dir"' EXIT

  while true; do
    if ! cmp -s "$FILE" "$tmp_dir/last_version"; then
      clear
      tools/fuzzy_diff.sh "$FILE"
      cp "$FILE" "$tmp_dir/last_version"
    fi
    sleep 1
  done
esac
