#!/usr/bin/env bash
#
case "$(uname -s)" in
    Darwin*)    open=open;;
    Linux*)     open=xdg-open;;
esac

LANGUAGE=$1
if [[ ${LANGUAGE} == en ]]; then
  SECTIONS=sections
else
  SECTIONS="sections/translated/${LANGUAGE}"
fi

case "${LANGUAGE}" in
  ru|ua)
    ENGINE=-pdflua
    ;;
  *)
    ENGINE=-pdf
    ;;
esac

po4a --no-update po4a.cfg

find ${SECTIONS} -type f -execdir sed -i 's@\\hypertarget@\\pagetarget@g' '{}' +
python .github/insert_printable_hyperlinks.py "${SECTIONS}"

sed -i -e "/% QR codes placeholder/{r .github/qr-codes-$LANGUAGE.tex" -e 'd}' metadata.tex

export HOMM3_LANG=${LANGUAGE}
export HOMM3_PRINTABLE=1
latexmk ${ENGINE} -shell-escape main_${LANGUAGE}.tex

${open} main_${LANGUAGE}.pdf &
