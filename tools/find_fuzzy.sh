#!/usr/bin/env bash

source tools/.language_base.sh

for f in $(find translations -name ${LANGUAGE}.po)
do
  grep --color -nHA3 fuzzy "$f"
done
