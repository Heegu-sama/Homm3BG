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

Single-line `msgid` (no `""`):
```
msgid "\\addsection{Introduction}{\\spells/magic_arrow.png}"
msgstr "\\addsection{Wprowadzenie}{\\spells/magic_arrow.png}"
```

## LaTeX Rules

- Preserve all whitespace at the start of lines
- Keep all LaTeX commands exactly as they appear - do not translate command names
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

This is a fixed-layout document.
Translations that are significantly more verbose will overflow the layout.
Localize naturally - use idiomatic phrasing in the target language, not word-for-word calques from English.
When multiple natural translations exist for a phrase, prefer the more concise one to avoid layout overflow.

## Capitalization

Mirror the capitalization of the English source, unless stated otherwise in the glossary.
If the English has "Hero" (capitalized), the translation must also be capitalized, unless stated otherwise in the language glossary.
