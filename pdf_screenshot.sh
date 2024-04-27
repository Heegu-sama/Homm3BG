#!/usr/bin/env bash

LANGUAGE=$1
FIRST_PAGE=$2
LAST_PAGE=$3

pdftoppm main_${LANGUAGE}.pdf output -f ${FIRST} -l ${LAST} -png
