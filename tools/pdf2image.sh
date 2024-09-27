#!/usr/bin/env bash

LANGUAGE=$1
FIRST_PAGE=$2

if [ -z $3 ]; then
  LAST_PAGE=$2
else
  LAST_PAGE=$3
fi

pdftoppm main_${LANGUAGE}.pdf screenshots/${LANGUAGE} -f ${FIRST_PAGE} -l ${LAST_PAGE} -png
