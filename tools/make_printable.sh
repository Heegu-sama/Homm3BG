#!/usr/bin/env bash

LANGUAGE=$1
export HOMM3_PRINTABLE=1 HOMM3_LANG=${LANGUAGE}
exec tools/build.sh "$@"
