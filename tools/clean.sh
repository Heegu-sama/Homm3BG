#!/usr/bin/env bash

rm -f ./* 2> /dev/null
rm -rf cache screenshots sections svg-inkscape
git restore \
  LICENSE \
  README.md \
  index_style.ist \
  latexmkrc \
  main_cs.tex \
  main_de.tex \
  main_en.tex \
  main_es.tex \
  main_fr.tex \
  main_he.tex \
  main_pl.tex \
  main_ru.tex \
  main_ua.tex \
  metadata.tex \
  po4a.cfg \
  run.sh \
  sections/ \
  structure.tex
