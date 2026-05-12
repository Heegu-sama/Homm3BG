#!/usr/bin/env bash

FILE=$1

case "$(uname -s)" in
  Darwin*|Linux*)
    # shellcheck disable=SC2016 # $0/$PPID are expanded by the inner bash, not this one
    echo "$FILE" | entr -c bash -c 'tools/fuzzy_diff.sh "$0"; [[ $? -eq 99 ]] && kill -PIPE $PPID' "$FILE"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf -- "$tmp_dir"' EXIT

    while true; do
      if ! cmp -s "$FILE" "$tmp_dir/last_version"; then
        clear
        tools/fuzzy_diff.sh "$FILE"
        rc=$?
        cp "$FILE" "$tmp_dir/last_version"
        [[ $rc -eq 99 ]] && exit 0
      fi
      sleep 1
    done
    ;;
esac
