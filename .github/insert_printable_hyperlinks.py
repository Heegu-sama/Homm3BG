#!/usr/bin/env python3

import fileinput
import pathlib
import re
import sys

HYPERLINKS_TO_REPLACE = [
    "AIrules",
    "Ability",
    "Combat",
    "Defend",
    "Difficulty",
    "End",
    "Endcombat",
    "Level",
    "Movement",
    "Playerdecks",
    "Quick",
    "Random Town",
    "Trading",
    "Walls",
    "War Machine Factory",
]

SECTIONS_PATH = sys.argv[1]
SECTIONS_DIRECTORY = pathlib.Path(__file__).parent.parent / SECTIONS_PATH


def _replace_line(line: str) -> str:
    for pattern in HYPERLINKS_TO_REPLACE:
        if re.search(f"hyperlink{{{pattern}", line):
            line = line.replace(f"hyperlink{{{pattern}", f"pagelink{{{pattern}")
    return line


def _parse_file(file: fileinput.FileInput[str]) -> None:
    for line in file:
        line = _replace_line(line) if "hyperlink" in line else line
        print(line, end="")


def update_files(directory: pathlib.Path) -> None:
    for filename in directory.glob("*.tex"):
        with fileinput.FileInput(filename, inplace=True) as file:
            _parse_file(file)


if __name__ == "__main__":
    update_files(SECTIONS_DIRECTORY)
