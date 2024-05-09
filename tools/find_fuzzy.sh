#!/usr/bin/env bash

LANGUAGE=$1

for f in $(find translations -name ${LANGUAGE}.po)
do
  grep --color -nHA3 fuzzy $f
done
