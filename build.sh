#!/usr/bin/env bash

LANGUAGE=$1

rm -f main_${LANGUAGE}.aux && \
  po4a --no-update po4a.cfg && \
  latexmk -pdf -shell-escape main_${LANGUAGE}.tex && \
  xdg-open main_${LANGUAGE}.pdf &
