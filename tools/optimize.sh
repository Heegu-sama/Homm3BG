#!/usr/bin/env bash

LANGUAGE=$1
CMYK=$2

if [[ ${CMYK} == "cmyk" ]]
then
  ARGS=-sColorConversionStrategy=CMYK
fi


gs -o main_${LANGUAGE}_optimized.pdf \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.5 \
  -dPDFSETTINGS=/prepress \
  -dDetectDuplicateImages=true \
  ${ARGS} main_${LANGUAGE}.pdf
