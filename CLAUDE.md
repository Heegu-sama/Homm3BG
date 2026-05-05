# Homm3BG Rules Rewrite

This is the source repository for the Heroes of Might & Magic 3 board game rulebook, written in LaTeX and translated via GNU gettext PO files.

## Translation

To translate a section into another language, run:

```
/translate <lang>
```

For example, `/translate de` for German or `/translate pl` for Polish.

The skill loads the glossary for that language from `glossaries/<lang>.md` and then accepts `msgid` blocks one at a time, returning the translated `msgstr`.

### Adding or updating a glossary

Glossaries live in `glossaries/` — one Markdown file per language. `glossaries/pl.md` is the most complete reference. If your language's file is missing terms, add them and open a PR.

### Adding a new language

1. **`po4a.cfg`** — add the language code to the `[po4a_langs]` line
2. **`main_<lang>.tex`** — create the root LaTeX file (copy an existing one as a template)
3. **`.github/workflows/build-and-publish-rule-book.yaml`** — add an entry to the language matrix
4. **`.github/workflows/build-release.yaml`** — add an entry to the language matrix (note: this one also requires `language_name` for artifact filenames)
5. **`.github/CODEOWNERS`** — add three lines for the new language: `**/<lang>.po`, `/translations/assets/<lang>/`, and `main_<lang>.tex`
6. **`glossaries/<lang>.md`** — create the glossary file using `glossaries/pl.md` as a reference
