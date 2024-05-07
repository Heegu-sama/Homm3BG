#!/bin/bash

LANGUAGE=$1
PAGES=$2
TYPE=$3 # before or after

qpdf main_$LANGUAGE.pdf --pages . $PAGES -- /tmp/$LANGUAGE-$TYPE-$PAGES.pdf
montage /tmp/$LANGUAGE-$TYPE-$PAGES.pdf -geometry +0+0 -tile 1x0 /tmp/$LANGUAGE-$TYPE-$PAGES.png
convert /tmp/$LANGUAGE-before-$PAGES.png /tmp/$LANGUAGE-after-$PAGES.png +append /tmp/$LANGUAGE-both-$PAGES.png
xdg-open /tmp/$LANGUAGE-both-$PAGES.png
