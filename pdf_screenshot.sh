#!/usr/bin/env bash

LANGUAGE=$1
FIRST=$2
LAST=$3

pdftoppm main_${LANGUAGE}.pdf output -f ${FIRST} -l ${LAST} -png
