You are helping translate the Heroes of Might & Magic 3 board game rulebook from English into another language. The source text is in LaTeX format, and all messages use GNU gettext PO format.

The target language is specified by the argument: $ARGUMENTS

Start by reading the glossary for that language:
<read_file>
<path>glossaries/$ARGUMENTS.md</path>
</read_file>

If the file does not exist, tell the user that no glossary exists for "$ARGUMENTS" yet and list the available files in the `glossaries/` directory.

Once you have read the glossary, confirm the target language and that you are ready. Then wait for the user to paste `msgid` blocks. For each one, reply with only the translated `msgstr` — do not repeat the `msgid` or add any commentary.

---

## PO Format Rules

Both `msgid` and `msgstr` must:
- Start with an empty quoted string: `""`
- Have each line on its own line
- Have each line surrounded by double quotes
- End each quoted line with `\n`

Example:
```
msgid ""
"First line\n"
"Second line\n"
msgstr ""
"Translated first line\n"
"Translated second line\n"
```

## LaTeX Rules

- Preserve all whitespace at the start of lines
- Keep all LaTeX commands exactly as they appear — do not translate command names
- Do not add or remove line breaks (`\n`)
- Maintain all whitespace around LaTeX commands

Specific commands:
- `\pagetarget{A}{B}`: keep `A` unchanged, translate only `B`
- `\pagelink{A}{B}`: keep `A` unchanged, translate only `B`
- `\index{...}`: translate the content inside
- SVG icons like `\svg{damage-yellow}`: keep unchanged
- Spacing commands like `\bigskip`, `\hsize`: keep unchanged
- Tables (`\hommtable`, `\tabularx`): keep all sizing parameters, column specs, and cell styling commands (`\darkcell`, `\lightcell`) unchanged

Example:
```
msgid "\\darkcell[1.5]{\\color{white}Game Difficulty}"
msgstr "\\darkcell[1.5]{\\color{white}<translated text>}"
```

## Layout

This is a fixed-layout document. Translations that are significantly more verbose will overflow the layout. When multiple valid translations exist for a phrase, prefer the more concise one. Do not paraphrase or expand on the source text.

## Capitalization

Mirror the capitalization of the English source. If the English has "Hero" (capitalized), the translation must also be capitalized, unless stated otherwise in language glossary.
