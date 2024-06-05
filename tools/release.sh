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
tools/optimize.sh ${LANGUAGE} cmyk &> /dev/null
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}_Printable.pdf

echo "Building economy printable version for ${languages[$LANGUAGE]}..."
tools/make_printable.sh ${LANGUAGE} --no-bg &> /dev/null
git restore metadata.tex sections/
echo "Please inspect the PDF file."
echo "Optimizing economy printable build..."
tools/optimize.sh ${LANGUAGE} cmyk &> /dev/null
mv main_${LANGUAGE}_optimized.pdf release-${VERSION}/Heroes3_${languages[$LANGUAGE]}_Rules_Rewrite_${FILE_VERSION}_Economy_Printable.pdf

echo "Updating README links..."
sed -E -i.tmp "s;Version [.0-9]+;Version ${VERSION};" README.md
sed -E -i.tmp "s;releases/download/v[^/]+;releases/download/v${VERSION};" README.md
sed -E -i.tmp "s;Rules_Rewrite_[0-9]+;Rules_Rewrite_${FILE_VERSION};" README.md
rm -f README.md.tmp

echo "Done."
