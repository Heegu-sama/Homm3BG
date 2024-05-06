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
if [ $(grep -c "icu_locale" index_style.ist) -eq 0 ]
then
  echo "icu_locale \"${LANGUAGE}\"" >> index_style.ist
fi
upmendex -s index_style main_${LANGUAGE}
# upmendex sorts non-English characters properly but fails to generate proper ind file
sed -i 's@\(\\noindent\\textbf{\)\(.\)@\\noindent\\textbf{\2}\\par}@g' main_${LANGUAGE}.ind

find ${SECTIONS} -type f -execdir sed -i 's@\\hypertarget@\\pagetarget@g' '{}' +
python .github/insert_printable_hyperlinks.py "${SECTIONS}"
if [ $(grep -c "sections/index.tex" metadata.tex) -eq 0 ]
then
  sed -i 's@\\include{\\sections/back_cover.tex}@\\include{\\sections/index.tex}\\include{\\sections/back_cover.tex}@g' metadata.tex
fi
sed -i -e "/% QR codes placeholder/{r .github/qr-codes-$LANGUAGE.tex" -e 'd}' metadata.tex
latexmk ${ENGINE} -shell-escape "main_${LANGUAGE}"
git restore index_style.ist
${open} main_${LANGUAGE}.pdf &
