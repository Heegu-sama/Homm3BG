#!/usr/bin/env bash

FILE_TO_COMPARE=$1
LANGUAGE=$2
FIRST_PAGE=$3

if [[ -z $4 ]]; then
  LAST_PAGE=$3
else
  LAST_PAGE=$4
fi

RANDOM_DIR=$(cat /dev/random | tr -dc 'a-z' | fold -w 7 | head -n 1)
mkdir /tmp/${RANDOM_DIR}

echo "Making images of ${FILE_TO_COMPARE} and main_${LANGUAGE}.pdf..."
pdftoppm ${FILE_TO_COMPARE} /tmp/${RANDOM_DIR}/aa -f ${FIRST_PAGE} -l ${LAST_PAGE} -png -progress &
pdftoppm main_${LANGUAGE}.pdf /tmp/${RANDOM_DIR}/bb -f ${FIRST_PAGE} -l ${LAST_PAGE} -png -progress &
wait

for page in $(seq ${FIRST_PAGE} ${LAST_PAGE})
do
  echo "Combining pages $(printf %02d $page)..."
  montage /tmp/${RANDOM_DIR}/*$(printf %02d $page).png -tile 2x1 -geometry +0+0 /tmp/${RANDOM_DIR}/${LANGUAGE}-$(printf %02d $page).png && \
  rm /tmp/${RANDOM_DIR}/aa-$(printf %02d $page).png /tmp/${RANDOM_DIR}/bb-$(printf %02d $page).png &
done
wait
mv /tmp/${RANDOM_DIR}/* .
rm -rf /tmp/${RANDOM_DIR}/
echo "Done."
