#!/usr/bin/env bash

LANGUAGE=$1
if [[ ${LANGUAGE} == en ]]; then
  SECTIONS=sections
else
  SECTIONS="sections/translated/${LANGUAGE}"
fi

po4a --no-update po4a.cfg
upmendex -s index_style main_${LANGUAGE}
# upmendex sorts non-English characters properly but fails to generate proper ind file
sed -i 's@\(\\noindent\\textbf{\)\(.\)@\\noindent\\textbf{\2}@g' main_${LANGUAGE}.ind

find sections -type f -execdir sed -i 's@\\hypertarget@\\pagetarget@g' '{}' +
python .github/insert_printable_hyperlinks.py "${SECTIONS}"
if [ $(grep -c "sections/notes.tex" metadata.tex) -eq 1 ]
then
  sed -i 's@\\include{\\sections/notes.tex}@@g' metadata.tex
fi
if [ $(grep -c "sections/index.tex" metadata.tex) -eq 0 ]
then
  sed -i 's@\\include{\\sections/back_cover.tex}@\\include{\\sections/index.tex}\\include{\\sections/back_cover.tex}@g' metadata.tex
fi
sed -i -e "/% QR codes placeholder/{r .github/qr-codes-$LANGUAGE.tex" -e 'd}' metadata.tex
latexmk -pdf -shell-escape "main_${LANGUAGE}"
