#!/usr/bin/env bash

FILE_TO_COMPARE=$1
LANGUAGE=$2
FIRST_PAGE=$3

if [ -z $4 ]; then
  LAST_PAGE=$3
else
  LAST_PAGE=$4
fi

echo "Making images of ${FILE_TO_COMPARE}..."
pdftoppm ${FILE_TO_COMPARE} aa -f ${FIRST_PAGE} -l ${LAST_PAGE} -png
echo "Making images of main_${LANGUAGE}.pdf..."
pdftoppm main_${LANGUAGE}.pdf bb -f ${FIRST_PAGE} -l ${LAST_PAGE} -png

for page in $(seq ${FIRST_PAGE} ${LAST_PAGE})
do
  echo "Combining pages ${page}..."
  montage *${page}.png -tile 2x1 -geometry +0+0 ${page}.png
  rm aa-${page}.png bb-${page}.png
done
echo "Done."
