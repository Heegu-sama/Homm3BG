#!/usr/bin/env bash

LANGUAGE=$1
FLAG=$2

export HOMM3_PRINTABLE=1 HOMM3_LANG=${LANGUAGE}

if [[ "${FLAG}" == "--no-bg" ]]; then
    export HOMM3_NO_ART_BACKGROUND=1
fi

exec tools/build.sh "$@"
