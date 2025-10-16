#!/usr/bin/env bash

po4a --no-translations po4a.cfg 2> >(grep -v "unmatched end of environment .expansion\|unmatched end of environment\| (po4a::tex)$" >&2)
