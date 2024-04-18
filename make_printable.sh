#!/usr/bin/env bash

LANGUAGE=$1
if [[ ${LANGUAGE} == en ]]; then
  SECTIONS=sections
else
  SECTIONS="sections/translated/${LANGUAGE}"
fi

makeindex main_en -s index_style.ist
find sections -type f -execdir sed -i 's@\\hypertarget@\\pagetarget@g' '{}' +
python .github/insert_printable_hyperlinks.py "${SECTIONS}"
sed -i 's@\\include{\\sections/back_cover.tex}@\\include{\\sections/index.tex}\\include{\\sections/back_cover.tex}@g' metadata.tex
sed -i -e "/% QR codes placeholder/{r .github/qr-codes-$LANGUAGE.tex" -e 'd}' metadata.tex
latexmk -pdf -silent -shell-escape "main_${LANGUAGE}"
