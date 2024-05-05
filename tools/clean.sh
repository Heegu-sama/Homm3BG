#!/usr/bin/env bash

rm -f * 2> /dev/null
git restore \
  README.md \
  index_style.ist \
  main_en.tex \
  main_es.tex \
  main_fr.tex \
  main_pl.tex \
  main_ru.tex \
  main_ua.tex \
  metadata.tex \
  po4a.cfg
