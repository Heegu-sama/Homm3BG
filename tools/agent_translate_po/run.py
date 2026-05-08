#!/usr/bin/env python3
# /// script
# requires-python = ">=3.12"
# ///
"""Translate untranslated entries in a .po file using Claude CLI or Codex CLI.

Usage:
    tools/translate_po/run.py [--agent claude|codex] [--render-prompt] <path/to/lang.po>

The language is inferred from the .po filename (e.g., cn.po -> cn). The system
prompt is rendered from tools/translate_po/prompts.md.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile


INCLUDE_RE = re.compile(r"^INCLUDE=([^\n#]+?)(?:##([^\n]+))?$", re.MULTILINE)


def repo_root_from_script(script_dir: str) -> str:
    return os.path.abspath(os.path.join(script_dir, os.pardir, os.pardir))


def glossary_path(repo_root: str, lang: str) -> str:
    return os.path.join(repo_root, "glossaries", f"{lang}.md")


def language_full_name(repo_root: str, lang: str) -> str:
    path = glossary_path(repo_root, lang)
    if not os.path.exists(path):
        raise FileNotFoundError(f"No glossary file found at {path}")

    with open(path, encoding="utf-8") as f:
        for line in f:
            match = re.match(r"^#\s+(.+?)(?:\s+\([^)]+\))?\s*$", line)
            if match:
                return match.group(1).strip()

    return lang


def replace_prompt_args(text: str, language_short: str, language_full: str) -> str:
    return (
        text.replace("ARG=LANGUAGE_FULL", language_full)
        .replace("ARG=LANGUAGE_SHORT", language_short)
    )


def extract_markdown_section(content: str, section: str, path: str) -> str:
    lines = content.splitlines()
    heading_re = re.compile(r"^(#{1,6})\s+(.+?)\s*$")

    start = None
    level = None
    for i, line in enumerate(lines):
        match = heading_re.match(line)
        if match and match.group(2).strip() == section:
            start = i + 1
            level = len(match.group(1))
            break

    if start is None or level is None:
        raise ValueError(f"Section '{section}' not found in {path}")

    end = len(lines)
    for i in range(start, len(lines)):
        match = heading_re.match(lines[i])
        if match and len(match.group(1)) <= level:
            end = i
            break

    return "\n".join(lines[start:end]).strip()


def resolve_include(
    include_target: str,
    section: str | None,
    repo_root: str,
    script_dir: str,
) -> str:
    path = include_target.strip()
    candidates = [
        os.path.join(repo_root, path),
        os.path.join(script_dir, path),
    ]
    source_path = next((p for p in candidates if os.path.exists(p)), None)
    if source_path is None:
        raise FileNotFoundError(f"Include file not found: {path}")

    with open(source_path, encoding="utf-8") as f:
        content = f.read()

    if section:
        return extract_markdown_section(content, section.strip(), source_path)
    return content.strip()


def render_prompt(
    template: str,
    language_short: str,
    language_full: str,
    repo_root: str,
    script_dir: str,
) -> str:
    rendered = replace_prompt_args(template, language_short, language_full)

    def replacement(match: re.Match[str]) -> str:
        include_target = replace_prompt_args(match.group(1), language_short, language_full)
        section = match.group(2)
        included = resolve_include(include_target, section, repo_root, script_dir)
        return replace_prompt_args(included, language_short, language_full)

    return INCLUDE_RE.sub(replacement, rendered)


def load_system_prompt(lang: str, script_dir: str) -> str:
    repo_root = repo_root_from_script(script_dir)
    language_full = language_full_name(repo_root, lang)
    path = os.path.join(script_dir, "prompts.md")
    if not os.path.exists(path):
        raise FileNotFoundError(f"No prompt file found at {path}")

    with open(path, encoding="utf-8") as f:
        template = f.read()
    return render_prompt(template, lang, language_full, repo_root, script_dir)


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


def translate_via_claude(system_prompt: str, entry_text: str, cwd: str) -> str:
    """Translate using the claude CLI."""
    msgid_block = get_msgid_block(entry_text)
    prompt = (
        system_prompt
        + "\n\nTranslate the following PO entry. Return only the translated msgstr block, "
        + "with no explanation or markdown fence:\n"
        + f"```po\n{msgid_block}\n```"
    )
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


def translate_via_codex(system_prompt: str, entry_text: str, cwd: str) -> str:
    """Translate using the codex CLI."""
    msgid_block = get_msgid_block(entry_text)
    prompt = (
        system_prompt
        + "\n\nTranslate the following PO entry. Return only the translated msgstr block, "
        + "with no explanation or markdown fence:\n"
        + f"```po\n{msgid_block}\n```"
    )
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


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Translate untranslated entries in a .po file."
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

    print(
        f"Translating: {po_file}  "
        f"(lang={lang}, agent={args.agent}, backend={args.agent} CLI)\n"
    )

    while True:
        with open(po_file, encoding="utf-8") as f:
            content = f.read()

        entries = split_entries(content)

        target = next(
            ((s, e, t) for s, e, t in entries if is_untranslated(t)),
            None,
        )

        if target is None:
            fuzzy = sum(1 for _, _, t in entries if is_fuzzy(t))
            print(f"Done. Translated {translated} entries this run.")
            if fuzzy:
                print(f"{fuzzy} fuzzy entries remain - review manually.")
            break

        start, end, entry_text = target
        msgid_val = get_po_value(entry_text, "msgid")
        preview = msgid_val[:80].replace("\n", "->")
        ellipsis = "..." if len(msgid_val) > 80 else ""
        print(f"[{translated + 1}] {preview}{ellipsis}")

        if args.agent == "codex":
            msgstr_block = translate_via_codex(system_prompt, entry_text, repo_root)
        else:
            msgstr_block = translate_via_claude(system_prompt, entry_text, repo_root)

        new_entry = patch_entry(entry_text, msgstr_block)

        if new_entry == entry_text:
            print("  WARNING: patch produced no change - stopping to avoid a loop.")
            print(f"  LLM returned: {msgstr_block[:120]}")
            sys.exit(1)

        new_content = content[:start] + new_entry + content[end:]
        with open(po_file, "w", encoding="utf-8") as f:
            f.write(new_content)

        translated += 1
        result_preview = get_po_value(new_entry, "msgstr")[:80].replace("\n", "->")
        print(f"    -> {result_preview}")


if __name__ == "__main__":
    main()
