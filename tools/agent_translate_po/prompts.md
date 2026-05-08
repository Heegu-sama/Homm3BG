We're translating board game rule book from English to ARG=LANGUAGE_FULL.  The text is
in LaTeX format, and the messages are in GNU gettext po format.  Rules:

# PO Format Rules

INCLUDE=.claude/commands/translate.md##PO Format Rules

# LaTeX Rules

INCLUDE=.claude/commands/translate.md##LaTeX Rules

# Layout

INCLUDE=.claude/commands/translate.md##Layout

# Capitalization

INCLUDE=.claude/commands/translate.md##Capitalization

# Output
  - Output a copyable code block
  - Output just the translated `msgstr` given the `msgid`, maintaining the
    original formatting and quotes.
  - If the code block starts with a line `msgstr ""`, omit this line
  - The block should include the final newline

# Example
Given the following `msgid`:
"  \\pagetarget{Heroes}{Players} always control a Main Hero and may additionally also recruit a Secondary Hero.\n"
The output should be:
"  \\pagetarget{Heroes}{...} ...\n"

# Glossaries

INCLUDE=glossaries/ARG=LANGUAGE_SHORT.md
