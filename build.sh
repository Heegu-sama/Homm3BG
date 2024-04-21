#!/usr/bin/env bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     command=xdg-open;;
    Darwin*)    command=open;;
esac
echo ${command}

LANGUAGE=$1

rm -f main_${LANGUAGE}.aux && \
  po4a --no-update po4a.cfg && \
  latexmk -pdf -shell-escape main_${LANGUAGE}.tex && \
  ${command} main_${LANGUAGE}.pdf &
