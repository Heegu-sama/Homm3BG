#!/usr/bin/env bash

rm -f * 2> /dev/null
git restore \
  README.md \
  build.sh \
  clean.sh \
  components_list.tex \
  index_style.ist \
  main_es.tex \
  main_en.tex \
  main_pl.tex \
  make_printable.sh \
  metadata.tex \
  po4a.cfg
