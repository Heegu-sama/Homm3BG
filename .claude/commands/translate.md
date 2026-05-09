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
2. Find every entry where `msgstr` is empty — that is, entries matching:
   ```
   msgstr ""
   ```
   where the line immediately following is either another `msgid` block, a comment (`#`), or end of file (i.e. no translated content follows).
   Skip the file header entry (the first `msgid ""`/`msgstr ""` block with PO metadata).
3. For each untranslated entry, produce the translated `msgstr` following the translation rules, then write it back into the file using the Edit tool.
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

**Glossary compliance** — every term in the glossary must be translated exactly as specified: correct form, correct capitalization, no synonyms, no untranslated terms.

**Capitalization** — mirror the capitalization of the English `msgid` unless the glossary says otherwise.

**LaTeX integrity** — all commands preserved exactly; see the translation rules file.

**PO format** — `msgstr` must follow the same multi-line structure as `msgid`; no collapsing or splitting lines.

**Obvious mistranslations** — flag any `msgstr` that still contains English where a translation is expected, or uses a clearly wrong term.

**Layout risk** — if a translation is >20% longer than the English source, flag it as an overflow risk but do **not** change it automatically; leave the decision to the user.

---

## Translation Rules

Read and follow `.claude/commands/translation-rules.md`.
