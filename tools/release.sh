#!/usr/bin/env bash

set -e

LANGUAGE=$1

VERSION=$(cat .version)
FILE_VERSION=$(echo "${VERSION}" | tr . _)

declare -A languages=(
  ["en"]="English"
  ["pl"]="Polski"
  ["es"]="Espanol"
  ["fr"]="Francais"
  ["ua"]="Ukrainska"
  ["cs"]="Cestina"
  ["ru"]="Russkiy"
  ["he"]="Ivrit"
  ["de"]="Deutsch"
)

echo "Building release ${VERSION} for ${languages[$LANGUAGE]}..."

mkdir -p "release-${VERSION}"

echo "Building digital version for ${languages[$LANGUAGE]}..."
tools/build.sh "${LANGUAGE}" &> /dev/null
echo "Please inspect the PDF file."
echo "Optimizing digital build..."
tools/optimize.sh "${LANGUAGE}" &> /dev/null
mv "main_${LANGUAGE}_optimized.pdf" "release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}.pdf"

echo "Building printable version for ${languages[$LANGUAGE]}..."
tools/build.sh "${LANGUAGE}" --printable &> /dev/null
echo "Please inspect the PDF file."
echo "Optimizing printable build..."
tools/optimize.sh "${LANGUAGE}" --cmyk &> /dev/null
mv "main_${LANGUAGE}_optimized.pdf" "release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}_Printable.pdf"

echo "Building economy printable version for ${languages[$LANGUAGE]}..."
tools/build.sh "${LANGUAGE}" --printable --no-bg &> /dev/null
echo "Please inspect the PDF file."
echo "Optimizing economy printable build..."
tools/optimize.sh "${LANGUAGE}" --cmyk &> /dev/null
mv "main_${LANGUAGE}_optimized.pdf" "release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}_Economy_Printable.pdf"

echo "Done."
