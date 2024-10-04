#!/usr/bin/env bash

LANGUAGE=$1
ARGS=${@:2}

for f in $(find translations -name ${LANGUAGE}.po)
do
  grep --color -nHA3 $ARGS fuzzy $f
done
