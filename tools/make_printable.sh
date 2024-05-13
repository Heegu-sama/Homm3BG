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

case "${LANGUAGE}" in
  de)
    export HOMM3_LANG=german
    ;;
  es)
    export HOMM3_LANG=spanish
    ;;
  fr)
    export HOMM3_LANG=french
    ;;
  pl)
    export HOMM3_LANG=polish
    ;;
  ru)
    export HOMM3_LANG=russian
    ;;
  ua)
    export HOMM3_LANG=ukrainian
    ;;
  *)
    export HOMM3_LANG=english
    ;;
esac

po4a --no-update po4a.cfg

find ${SECTIONS} -type f -execdir sed -i 's@\\hypertarget@\\pagetarget@g' '{}' +
python .github/insert_printable_hyperlinks.py "${SECTIONS}"

sed -i -e "/% QR codes placeholder/{r .github/qr-codes-$LANGUAGE.tex" -e 'd}' metadata.tex

latexmk ${ENGINE} -usepretex='\AtBeginDocument{\toggletrue{printable}}' -shell-escape main_${LANGUAGE}.tex

${open} main_${LANGUAGE}.pdf &
