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
3. Read and follow the translation rules in
   `.claude/commands/translation-rules.md`.

---

## Translation mode

For each PO file (work through them in alphabetical order by directory name):

1. Read the file.
2. Find every entry that needs work:
   - **Fuzzy entries**: entries with a `#, fuzzy` flag line immediately before `msgid`. Review the existing `msgstr` against the current `msgid` and the translation rules — adjust if needed — then remove the `#, fuzzy` line.
   - **Untranslated entries**: entries where `msgstr` is empty — matching `msgstr ""` where the line immediately following is another `msgid` block, a comment (`#`), or end of file (i.e. no translated content follows).
   Skip the file header entry (the first `msgid ""`/`msgstr ""` block with PO metadata).
3. For each fuzzy entry, write the corrected `msgstr` and remove the `#, fuzzy` line using the Edit tool. For each untranslated entry, produce the translated `msgstr` following the translation rules, then write it back into the file using the Edit tool.
   **Ambiguity — pause and ask the user** before writing when any of these apply:
   - A fuzzy entry has structural changes beyond minor wording (e.g. sentence count changed, new LaTeX commands present, meaning shifted significantly).
   - An untranslated entry has multiple valid glossary-compliant renderings and the best choice is unclear.
   - The translated string is significantly longer than the English source (layout overflow risk) — present the translation and ask whether to proceed, shorten, or skip.
   Use the `AskUserQuestion` tool to ask. Resume processing after the user responds.
4. After finishing a file, tell the user which file was completed and how many strings were translated.

If a file has no untranslated entries, skip it silently and move to the next.

---

## Review mode

For each PO file (work through them in alphabetical order by directory name):

1. Read the file.
2. Find every entry where **both** `msgid` and `msgstr` are non-empty (i.e. already translated).
   Skip the file header entry (the first `msgid ""`/`msgstr ""` block with PO metadata).
3. For each translated entry, check the `msgstr` against the translation rules.
   If the entry looks correct, skip it silently.
   If you find one or more issues, fix the `msgstr` in place using the Edit tool and record what you changed.
4. After finishing a file, report: file name, how many entries were reviewed, and a bullet list of every fix made (old → new, with the issue type). If no fixes were needed, skip the file silently.

### What to check in review mode

**Language and grammar** — the `msgstr` must read as fluent, idiomatic prose in the target language: correct grammar, natural word order, proper inflection and agreement, and no calques or awkward literal renderings of English phrasing.
The register should match professional technical writing appropriate for a board game rulebook: clear, precise, and consistent, avoiding colloquialisms and ambiguity.
Be rutally critical with this one.

**Glossary compliance** — every term in the glossary must be translated exactly as specified: correct form, correct capitalization, no synonyms, no untranslated terms.

**Capitalization** — mirror the capitalization of the English `msgid` unless the glossary says otherwise.

**LaTeX integrity** — all commands preserved exactly; see the translation rules file.

**PO format** — `msgstr` must follow the same multi-line structure as `msgid`; no collapsing or splitting lines.

**Obvious mistranslations** — flag any `msgstr` that still contains English where a translation is expected, or uses a clearly wrong term.

**Layout risk** — if a translation is >20% longer than the English source, flag it as an overflow risk but do **not** change it automatically; leave the decision to the user.

---

## Translation Rules

Read and follow `.claude/commands/translation-rules.md`.
