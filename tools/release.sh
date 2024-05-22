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

echo "Building release ${VERSION} for ${languages[$LANGUAGE]}..."

mkdir -p release-${VERSION}

tools/build.sh ${LANGUAGE}
tools/optimize.sh ${LANGUAGE}
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${VERSION}.pdf

tools/make_printable.sh ${LANGUAGE}
git restore metadata.tex sections/
tools/optimize.sh ${LANGUAGE}
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${VERSION}_Printable.pdf
echo "Done."
