#!/usr/bin/env bash

makeindex main -s index_style.ist
find sections -type f | xargs -n 1 sed -i "s@\\\hypertarget@\\\pagetarget@g"
python .github/insert_printable_hyperlinks.py
sed -i "s@\\\include{sections/back_cover.tex}@\\\include{sections/index.tex}\\\include{sections/back_cover.tex}@g" main.tex
sed -i -e '/% QR codes placeholder/{r .github/qr-codes.tex' -e 'd}' main.tex
latexmk -pdf -silent "main"
