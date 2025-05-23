MYTMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$MYTMPDIR"' EXIT
msgattrib --only-fuzzy $1 > "$MYTMPDIR/fuzzy_only.po"
awk '/^#, fuzzy/ {print; found=1; next} found {print; if (/^msgstr/) exit}' "$MYTMPDIR/fuzzy_only.po" > "$MYTMPDIR/fuzzy_first.po"
awk '/^#\|/,/^msgid/ {if ($0 ~ /^#\|/) print substr($0, 4)}' "$MYTMPDIR/fuzzy_first.po" > "$MYTMPDIR/old.po"
awk '/^msgid/,/^msgstr/ {print}' "$MYTMPDIR/fuzzy_first.po" | head -n -1 > "$MYTMPDIR/new.po"
diff -u --color "$MYTMPDIR/old.po" "$MYTMPDIR/new.po"