#!/usr/bin/env python3

import fileinput
import pathlib
import re

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
    "Trading",
    "Walls",
]
SECTIONS_DIRECTORY = "sections"


def _list_tex_files(directory):
    return pathlib.Path(f"./{directory}").glob("*.tex")


def _replace_line(line):
    for pattern in HYPERLINKS_TO_REPLACE:
        match = re.search(f"hyperlink{{{pattern}", line)
        line = (
            line.replace(f"hyperlink{{{pattern}", f"pagelink{{{pattern}")
            if match
            else line
        )
    return line


def _parse_file(file):
    for line in file:
        line = _replace_line(line) if "hyperlink" in line else line
        print(line, end="")


def update_files(directory):
    for filename in _list_tex_files(directory):
        with fileinput.FileInput(filename, inplace=True) as file:
            _parse_file(file)


if __name__ == "__main__":
    update_files(SECTIONS_DIRECTORY)
