#!/usr/bin/env bash

FILE_TO_COMPARE=$1
LANGUAGE=$2
FIRST_PAGE=$3

if [[ -z $4 ]]; then
  LAST_PAGE=$3
else
  LAST_PAGE=$4
fi

RANDOM_DIR=$(mktemp -d)

echo "Making images of ${FILE_TO_COMPARE} and main_${LANGUAGE}.pdf..."
pdftoppm ${FILE_TO_COMPARE} ${RANDOM_DIR}/aa -f ${FIRST_PAGE} -l ${LAST_PAGE} -png -progress &
pdftoppm main_${LANGUAGE}.pdf ${RANDOM_DIR}/bb -f ${FIRST_PAGE} -l ${LAST_PAGE} -png -progress &
wait

for page in $(seq ${FIRST_PAGE} ${LAST_PAGE})
do
  echo "Combining pages $(printf %02d $page)..."
  montage ${RANDOM_DIR}/*$(printf %02d $page).png -tile 2x1 -geometry +0+0 ${RANDOM_DIR}/${LANGUAGE}-$(printf %02d $page).png && \
  rm ${RANDOM_DIR}/aa-$(printf %02d $page).png ${RANDOM_DIR}/bb-$(printf %02d $page).png &
done
wait
mv ${RANDOM_DIR}/* .
rm -rf ${RANDOM_DIR}/
echo "Done."
