#!/usr/bin/env bash

LANGUAGE=$1


gs -o main_${LANGUAGE}_optimized.pdf \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.5 \
  -dPDFSETTINGS=/printer \
  -dDetectDuplicateImages=true \
  main_${LANGUAGE}.pdf
