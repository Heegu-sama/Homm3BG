#!/usr/bin/env bash

rm -f * 2> /dev/null
git restore \
  README.md \
  build.sh \
  clean.sh \
  find_fuzzy.sh \
  index_style.ist \
  main_es.tex \
  main_en.tex \
  main_fr.tex \
  main_pl.tex \
  main_ru.tex \
  make_printable.sh \
  metadata.tex \
  pdf2image.sh \
  po4a.cfg
