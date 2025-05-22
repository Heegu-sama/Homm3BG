msgattrib --only-fuzzy $1 > fuzzy.cs.po
awk '/^#, fuzzy/ {print; found=1; next} found {print; if (/^msgstr/) exit}' fuzzy.cs.po > fuzzy.cs.po.first
awk '/^#\|/,/^msgid/ {if ($0 ~ /^#\|/) print substr($0, 4)}' fuzzy.cs.po.first > old_translations.cs.po
awk '/^msgid/,/^msgstr/ {print}' fuzzy.cs.po.first | head -n -1 > new_translations.cs.po
diff -u --color old_translations.cs.po new_translations.cs.po