#!/usr/bin/env bash

LANGUAGE=$1

VERSION=$(grep Version main_en.tex | grep -Po "\d.+$")
FILE_VERSION=$(echo "${VERSION}" | tr -d .)

declare -A languages=(
  ["en"]="English"
  ["pl"]="Polski"
  ["es"]="Espanol"
  ["fr"]="Francais"
  ["ua"]="Ukrainska"
)

echo "Building release ${VERSION} for ${languages[$LANGUAGE]}..."

mkdir -p release-${VERSION}

echo "Building digital version for ${languages[$LANGUAGE]}..."
tools/build.sh ${LANGUAGE} &> /dev/null
echo "Please inspect the PDF file."
echo "Optimizing digital build..."
tools/optimize.sh ${LANGUAGE} &> /dev/null
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}.pdf

echo "Building printable version for ${languages[$LANGUAGE]}..."
tools/make_printable.sh ${LANGUAGE} &> /dev/null
git restore metadata.tex sections/
echo "Please inspect the PDF file."
echo "Optimizing printable build..."
tools/optimize.sh ${LANGUAGE} &> /dev/null
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}_Printable.pdf
echo "Done."
