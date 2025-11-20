#!/usr/bin/env bash

po4a po4a.cfg
git add translations
git commit -m "po4a"
git log -1 @
