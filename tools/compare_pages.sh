#!/usr/bin/env bash

FILE_TO_COMPARE=$1
LANGUAGE=$2
FIRST_PAGE=$3

if [ -z $4 ]; then
  LAST_PAGE=$3
else
  LAST_PAGE=$4
fi

echo "Making images of ${FILE_TO_COMPARE} and main_${LANGUAGE}.pdf..."
pdftoppm ${FILE_TO_COMPARE} aa -f ${FIRST_PAGE} -l ${LAST_PAGE} -png -progress &
pdftoppm main_${LANGUAGE}.pdf bb -f ${FIRST_PAGE} -l ${LAST_PAGE} -png -progress &
wait

for page in $(seq ${FIRST_PAGE} ${LAST_PAGE})
do
  echo "Combining pages $(printf %02d $page)..."
  montage *$(printf %02d $page).png -tile 2x1 -geometry +0+0 $(printf %02d $page).png && \
  rm aa-$(printf %02d $page).png bb-$(printf %02d $page).png &
done
wait
echo "Done."
