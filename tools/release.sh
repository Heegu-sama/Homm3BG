#!/usr/bin/env bash

LANGUAGE=$1

VERSION=$(grep Version main_en.tex | grep -Po "\d.+$" | tr -d .)

declare -A languages=(
  ["en"]="English"
  ["pl"]="Polski"
  ["es"]="Español"
  ["fr"]="Français"
  ["ua"]="Українська"
)

echo "Building release ${VERSOPN} for ${languages[$LANGUAGE]}..."

mkdir -p release-${VERSION}

tools/build.sh ${LANGUAGE}
tools/optimize.sh ${LANGUAGE}
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_12.pdf

tools/make_printable.sh ${LANGUAGE}
git restore metadata.tex sections/
tools/optimize.sh ${LANGUAGE}
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_12_Printable.pdf
echo "Done."
