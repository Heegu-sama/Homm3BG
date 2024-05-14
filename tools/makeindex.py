#!/usr/bin/env python

import argparse
import collections
import re

parser = argparse.ArgumentParser()
parser.add_argument('--i', required=True)
parser.add_argument('--o', required=True)
args = parser.parse_args()

ENTRIES = collections.defaultdict(set)

with open(args.i, 'rt', encoding='utf-8') as f:
  for line in f:
    m = re.match(r'^\\indexentry\{(.+)\}\{(\d+)\}$', line)
    if m:
      ENTRIES[m[1]].add(int(m[2]))

with open(args.o, 'wt', encoding='utf-8') as f:
  print(r'\begin{theindex}', file=f)

  last_letter = ''

  for name in sorted(ENTRIES):
    if last_letter != name[0]:
      if last_letter != '':
        print(r'\indexspace', file=f)
      last_letter = name[0]
      print(r'\hommIndexLetter{' + last_letter + '}', file=f)
    numbers = [str(i) for i in sorted(ENTRIES[name])]
    print(r'\hommIndexEntry{' + name + r'}{' + ', '.join(numbers) + '}', file=f)

  print(r'\end{theindex}', file=f)
