#!/bin/bash

LANGUAGE=$1
PAGES=$2
TYPE=$3 # 'a' or 'b'

mkdir -p /tmp/homm3bgre

qpdf main_$LANGUAGE.pdf --pages . $PAGES -- /tmp/homm3bgre/$LANGUAGE-$TYPE-$PAGES.pdf
montage -density 150 /tmp/homm3bgre/$LANGUAGE-$TYPE-$PAGES.pdf -geometry +0+0 -tile 1x0 /tmp/homm3bgre/$LANGUAGE-$TYPE-$PAGES.png
convert /tmp/homm3bgre/$LANGUAGE-a-$PAGES.png /tmp/homm3bgre/$LANGUAGE-b-$PAGES.png +append /tmp/homm3bgre/$LANGUAGE-both-$PAGES.png
xdg-open /tmp/homm3bgre/$LANGUAGE-both-$PAGES.png
