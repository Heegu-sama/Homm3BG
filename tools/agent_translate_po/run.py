#!/usr/bin/env python3
# /// script
# requires-python = ">=3.12"
# ///
"""Translate untranslated and fuzzy entries in a .po file using Claude CLI or Codex CLI.

Usage:
    tools/agent_translate_po/run.py [--agent claude|codex] [--render-prompt] <path/to/lang.po>

The language is inferred from the .po filename (e.g., cn.po -> cn). The system
prompt is rendered by concatenating tools/agent_translate_po/prompts.md, the
translation rules, and glossaries/<lang>.md.

Untranslated entries are processed first; fuzzy entries follow. For fuzzy entries
the agent receives the old source, the existing translation, and the new source,
and is asked to update only the changed part.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile


def repo_root_from_script(script_dir: str) -> str:
    return os.path.abspath(os.path.join(script_dir, os.pardir, os.pardir))


def read_prompt_part(path: str) -> str:
    if not os.path.exists(path):
        raise FileNotFoundError(f"No prompt file found at {path}")

    with open(path, encoding="utf-8") as f:
        return f.read().strip()


def glossary_path(repo_root: str, lang: str) -> str:
    return os.path.join(repo_root, "glossaries", f"{lang}.md")


def language_full_name(repo_root: str, lang: str) -> str:
    """Extract the full language name from the glossary header (e.g. 'German' from '# German (de)')."""
    path = glossary_path(repo_root, lang)
    if not os.path.exists(path):
        return lang
    with open(path, encoding="utf-8") as f:
        first_line = f.readline().strip()
    m = re.match(r"^#\s+(.+?)\s+\(\w+\)\s*$", first_line)
    return m.group(1) if m else lang


def load_system_prompt(lang: str, script_dir: str) -> str:
    repo_root = repo_root_from_script(script_dir)
    paths = [
        os.path.join(script_dir, "prompts.md"),
        os.path.join(repo_root, ".claude", "commands", "translation-rules.md"),
        glossary_path(repo_root, lang),
    ]
    return "\n\n".join(read_prompt_part(path) for path in paths)


def split_entries(content: str) -> list[tuple[int, int, str]]:
    """Return (start, end, text) for each PO entry block separated by blank lines."""
    lines = content.split("\n")

    line_starts: list[int] = []
    p = 0
    for line in lines:
        line_starts.append(p)
        p += len(line) + 1
    line_starts.append(p)

    entries: list[tuple[int, int, str]] = []
    i = 0
    while i < len(lines):
        while i < len(lines) and not lines[i].strip():
            i += 1
        if i >= len(lines):
            break

        entry_start = line_starts[i]
        while i < len(lines) and lines[i].strip():
            i += 1
        entry_end = line_starts[i] if i < len(lines) else len(content)

        entries.append((entry_start, entry_end, content[entry_start:entry_end]))
    return entries


def get_po_value(entry_text: str, key: str) -> str:
    """Decode the string value of msgid or msgstr."""
    m = re.search(rf"^{key} ((?:\"[^\"]*\"\n?)+)", entry_text, re.MULTILINE)
    if not m:
        return ""
    return "".join(re.findall(r'"([^"]*)"', m.group(1)))


def is_header(entry_text: str) -> bool:
    """True for the PO file header (empty msgid with no continuation lines)."""
    m = re.search(r'^msgid ""$', entry_text, re.MULTILINE)
    if not m:
        return False
    after = entry_text[m.end():].lstrip("\n")
    return not after.startswith('"')


def is_untranslated(entry_text: str) -> bool:
    """True if msgstr is empty and this is not the header."""
    if is_header(entry_text):
        return False
    m = re.search(r'^msgstr ""$', entry_text, re.MULTILINE)
    if not m:
        return False
    after = entry_text[m.end():].lstrip("\n")
    return not after.startswith('"')


def is_fuzzy(entry_text: str) -> bool:
    return bool(re.search(r"^#, .*fuzzy", entry_text, re.MULTILINE))


def get_msgid_block(entry_text: str) -> str:
    """Return the raw msgid lines without trailing newline."""
    m = re.search(r'^(msgid (?:"[^"]*"\n?)+)', entry_text, re.MULTILINE)
    return m.group(1).rstrip("\n") if m else ""


def get_msgstr_block(entry_text: str) -> str:
    """Return the raw msgstr lines without trailing newline."""
    m = re.search(r'^(msgstr (?:"[^"]*"\n?)+)', entry_text, re.MULTILINE)
    return m.group(1).rstrip("\n") if m else ""


def get_prev_msgid_block(entry_text: str) -> str:
    """Return the previous-source block from #| comment lines as a plain msgid block."""
    lines = [line[3:] for line in entry_text.split("\n") if line.startswith("#| ")]
    return "\n".join(lines).rstrip("\n") if lines else ""


def build_msgstr(llm_text: str) -> str:
    """Convert LLM response to a properly formatted msgstr block."""
    m = re.search(r"```(?:po)?\n(.*?)\n?```", llm_text, re.DOTALL)
    raw = m.group(1).strip() if m else llm_text.strip()

    if raw.startswith("msgstr "):
        if raw.startswith('msgstr ""\n') or raw == 'msgstr ""':
            raw = raw[len('msgstr ""\n') :].strip() if "\n" in raw else ""
        else:
            return raw

    if not raw:
        return 'msgstr ""'

    if not raw.startswith('"'):
        return f'msgstr "{raw}\\n"'

    lines = [line for line in raw.split("\n") if line.strip()]

    if len(lines) == 1 and lines[0] != '""':
        return f"msgstr {lines[0]}"

    content = "\n".join(lines)
    if not content.startswith('""'):
        content = '""\n' + content
    return f"msgstr {content}"


def build_new_prompt(system_prompt: str, entry_text: str, lang: str) -> str:
    """Build the agent prompt for a fresh untranslated entry."""
    msgid_block = get_msgid_block(entry_text)
    lang_clause = f" into {lang}" if lang else ""
    return (
        system_prompt
        + f"\n\nTranslate the following PO entry{lang_clause}. Return only the translated msgstr block, "
        + "with no explanation or markdown fence:\n"
        + f"```po\n{msgid_block}\n```"
    )


def build_fuzzy_prompt(system_prompt: str, entry_text: str, lang: str) -> str:
    """Build the agent prompt for a fuzzy (source-changed) entry."""
    prev_msgid_block = get_prev_msgid_block(entry_text)
    current_msgstr_block = get_msgstr_block(entry_text)
    msgid_block = get_msgid_block(entry_text)
    lang_clause = f" {lang}" if lang else ""
    return (
        system_prompt
        + f"\n\nThe English source text has changed. Update the existing {lang_clause} translation "
        + "to match the new source, changing only the outdated part and keeping the rest "
        + "(especially specific formatting for the target language) as close "
        + "to the original translation entry as possible. "
        + "Return only the updated msgstr block, with no explanation or markdown fence.\n\n"
        + f"Old source:\n```po\n{prev_msgid_block}\n```\n\n"
        + f"Existing translation:\n```po\n{current_msgstr_block}\n```\n\n"
        + f"New source:\n```po\n{msgid_block}\n```"
    )


def call_claude(prompt: str, cwd: str) -> str:
    """Call the claude CLI and return the translated msgstr block."""
    result = subprocess.run(
        ["claude", "-p", prompt],
        capture_output=True,
        text=True,
        timeout=300,
        cwd=cwd,
    )
    if result.returncode != 0:
        raise RuntimeError(f"claude CLI failed:\n{result.stderr.strip()}")
    return build_msgstr(result.stdout)


def call_codex(prompt: str, cwd: str) -> str:
    """Call the codex CLI and return the translated msgstr block."""
    with tempfile.NamedTemporaryFile(mode="r", encoding="utf-8") as output:
        result = subprocess.run(
            [
                "codex",
                "exec",
                "--ephemeral",
                "--sandbox",
                "read-only",
                "--cd",
                cwd,
                "--output-last-message",
                output.name,
                prompt,
            ],
            capture_output=True,
            text=True,
            timeout=300,
        )
        if result.returncode != 0:
            raise RuntimeError(f"codex CLI failed:\n{result.stderr.strip()}")
        output.seek(0)
        return build_msgstr(output.read())


def patch_entry(entry_text: str, msgstr_block: str) -> str:
    """Replace the empty msgstr line with the translated block."""
    replacement = msgstr_block.rstrip("\n")
    return re.sub(
        r'^msgstr ""$', lambda _: replacement, entry_text, count=1, flags=re.MULTILINE
    )


def patch_fuzzy_entry(entry_text: str, msgstr_block: str) -> str:
    """Replace msgstr with the updated translation, strip the fuzzy flag and #| lines."""
    # Remove all #| previous-source comment lines
    result = re.sub(r"^#\|[^\n]*\n", "", entry_text, flags=re.MULTILINE)

    # Remove "fuzzy" from the #, flags line; drop the line entirely if no flags remain
    def remove_fuzzy_flag(m: re.Match) -> str:
        flags = [f.strip() for f in m.group(1).split(",") if f.strip() != "fuzzy"]
        return f'#, {", ".join(flags)}\n' if flags else ""

    result = re.sub(r"^#, (.+)\n", remove_fuzzy_flag, result, flags=re.MULTILINE)

    # Replace the existing (non-empty) msgstr block with the updated translation
    replacement = msgstr_block.rstrip("\n")
    result = re.sub(
        r'^msgstr (?:"[^"]*"\n?)+',
        lambda _: replacement + "\n",
        result,
        count=1,
        flags=re.MULTILINE,
    )
    return result


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Translate untranslated and fuzzy entries in a .po file."
    )
    parser.add_argument(
        "--agent",
        choices=("claude", "codex"),
        default="claude",
        help="translation agent to use (default: claude)",
    )
    parser.add_argument(
        "--render-prompt",
        action="store_true",
        help="render the system prompt for the inferred language and exit",
    )
    parser.add_argument("po_file", help="path to the .po file to translate")
    args = parser.parse_args()

    po_file = os.path.abspath(args.po_file)
    if not os.path.exists(po_file):
        print(f"File not found: {po_file}", file=sys.stderr)
        sys.exit(1)

    lang = os.path.splitext(os.path.basename(po_file))[0]
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = repo_root_from_script(script_dir)

    try:
        system_prompt = load_system_prompt(lang, script_dir)
    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    lang_name = language_full_name(repo_root, lang)

    if args.render_prompt:
        print(system_prompt)
        return

    if not shutil.which(args.agent):
        print(
            f"Error: '{args.agent}' CLI not found in PATH.",
            file=sys.stderr,
        )
        sys.exit(1)

    translated = 0
    defuzzied = 0

    print(
        f"Translating: {po_file}  "
        f"(lang={lang_name}, agent={args.agent}, backend={args.agent} CLI)\n"
    )

    while True:
        with open(po_file, encoding="utf-8") as f:
            content = f.read()

        entries = split_entries(content)

        # Prefer untranslated entries; fall back to fuzzy
        target = next(((s, e, t) for s, e, t in entries if is_untranslated(t)), None)
        fuzzy_mode = False
        if target is None:
            target = next(((s, e, t) for s, e, t in entries if is_fuzzy(t)), None)
            fuzzy_mode = target is not None

        if target is None:
            print(f"Done. Translated {translated} new, updated {defuzzied} fuzzy entries.")
            break

        start, end, entry_text = target
        msgid_val = get_po_value(entry_text, "msgid")
        preview = msgid_val[:80].replace("\n", "->")
        ellipsis = "..." if len(msgid_val) > 80 else ""
        label = f"[fuzzy {defuzzied + 1}]" if fuzzy_mode else f"[{translated + 1}]"
        print(f"{label} {preview}{ellipsis}")

        if fuzzy_mode:
            prompt = build_fuzzy_prompt(system_prompt, entry_text, lang_name)
        else:
            prompt = build_new_prompt(system_prompt, entry_text, lang_name)

        if args.agent == "codex":
            msgstr_block = call_codex(prompt, repo_root)
        else:
            msgstr_block = call_claude(prompt, repo_root)

        if fuzzy_mode:
            new_entry = patch_fuzzy_entry(entry_text, msgstr_block)
        else:
            new_entry = patch_entry(entry_text, msgstr_block)

        if new_entry == entry_text:
            print("  WARNING: patch produced no change - stopping to avoid a loop.")
            print(f"  LLM returned: {msgstr_block[:120]}")
            sys.exit(1)

        new_content = content[:start] + new_entry + content[end:]
        with open(po_file, "w", encoding="utf-8") as f:
            f.write(new_content)

        if fuzzy_mode:
            defuzzied += 1
        else:
            translated += 1

        result_preview = get_po_value(new_entry, "msgstr")[:80].replace("\n", "->")
        print(f"    -> {result_preview}")


if __name__ == "__main__":
    main()
