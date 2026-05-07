You are translating or reviewing the Heroes of Might & Magic 3 board game rulebook.
The source text is in LaTeX format, and all messages use GNU gettext PO format.

The argument format is: `$ARGUMENTS`

- If the argument is just a language code (e.g. `pl`), run in **translation mode**.
- If the argument ends with `--review` (e.g. `pl --review`), run in **review mode**.

Extract the language code from the argument (the part before any flags).

## Setup

1. Read the glossary for the target language from `glossaries/<lang>.md`.
   If it does not exist, tell the user and list available files in `glossaries/`.
2. Find all PO files for the target language: `find translations -name "<lang>.po"`.

---

## Translation mode

For each PO file (work through them in alphabetical order by directory name):

1. Read the file.
2. Find every entry where `msgstr` is empty — that is, entries matching:
   ```
   msgstr ""
   ```
   where the line immediately following is either another `msgid` block, a comment (`#`), or end of file (i.e. no translated content follows).
   Skip the file header entry (the first `msgid ""`/`msgstr ""` block with PO metadata).
3. For each untranslated entry, produce the translated `msgstr` following the rules below, then write it back into the file using the Edit tool.
4. After finishing a file, tell the user which file was completed and how many strings were translated.

If a file has no untranslated entries, skip it silently and move to the next.

---

## Review mode

For each PO file (work through them in alphabetical order by directory name):

1. Read the file.
2. Find every entry where **both** `msgid` and `msgstr` are non-empty (i.e. already translated).
   Skip the file header entry (the first `msgid ""`/`msgstr ""` block with PO metadata).
3. For each translated entry, check the `msgstr` against the rules below.
   If the entry looks correct, skip it silently.
   If you find one or more issues, fix the `msgstr` in place using the Edit tool and record what you changed.
4. After finishing a file, report: file name, how many entries were reviewed, and a bullet list of every fix made (old → new, with the issue type). If no fixes were needed, skip the file silently.

### What to check in review mode

**Glossary compliance** — every term in the glossary must be translated exactly as specified: correct form, correct capitalization, no synonyms, no untranslated terms.

**Capitalization** — mirror the capitalization of the English `msgid` unless the glossary says otherwise.

**LaTeX integrity** — all commands preserved exactly; see LaTeX Rules below.

**PO format** — `msgstr` must follow the same multi-line structure as `msgid`; no collapsing or splitting lines.

**Obvious mistranslations** — flag any `msgstr` that still contains English where a translation is expected, or uses a clearly wrong term.

**Layout risk** — if a translation is >20% longer than the English source, flag it as an overflow risk but do **not** change it automatically; leave the decision to the user.

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

Single-line `msgid` (no `""`):
```
msgid "\\addsection{Introduction}{\\spells/magic_arrow.png}"
msgstr "\\addsection{Wprowadzenie}{\\spells/magic_arrow.png}"
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

This is a fixed-layout document.
Translations that are significantly more verbose will overflow the layout.
Localize naturally — use idiomatic phrasing in the target language, not word-for-word calques from English.
When multiple natural translations exist for a phrase, prefer the more concise one to avoid layout overflow.

## Capitalization

Mirror the capitalization of the English source, unless stated otherwise in the glossary.
If the English has "Hero" (capitalized), the translation must also be capitalized, unless stated otherwise in the language glossary.
