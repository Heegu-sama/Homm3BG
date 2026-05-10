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
