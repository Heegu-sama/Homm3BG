#!/usr/bin/env bash

set -e

source tools/.language_base.sh

VERSION=$(cat .version)
FILE_VERSION=$(echo "${VERSION}" | tr . _)

declare -A languages=(
  ["cn"]="ZhongWen"
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

if [[ -z "${languages[$LANGUAGE]}" ]]; then
  echo "Error: Missing release filename label for language '$LANGUAGE'." >&2
  exit 1
fi

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
