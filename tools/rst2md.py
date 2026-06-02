#!/usr/bin/env python3
"""
Convert gnatdoc RST output to Markdown.
Usage: python3 tools/rst2md.py [rst_dir] [output_dir]
"""

import re
import sys
import os
from os.path import join

RST_DIR = sys.argv[1] if len(sys.argv) > 1 else "obj/gnatdoc-rst"
OUT_DIR  = sys.argv[2] if len(sys.argv) > 2 else "docs/api-docs"


MOJIBAKE_EMDASH = "\u00e2\u0080\u0094"


def fix_text(text):
    return text.replace(MOJIBAKE_EMDASH, ":")


def slug(name):
    return name.lower().replace(".", "-") + ".md"


def parse_title(text):
    m = re.search(r"^(.+?)\n[*]{2,}", text, re.MULTILINE)
    return m.group(1).strip() if m else ""


def parse_description(text):
    """Extract text between the set_package code block and first section heading."""
    m = re.search(
        r'code-block:: ada\s*\n\s+package\s+\S+\s*$'
        r'(.*?)'
        r'(?:^-----.+$|\Z)',
        text,
        re.MULTILINE | re.DOTALL
    )
    if m:
        desc = m.group(1).strip()
        desc = re.sub(r'^\s*\*\s*', '- ', desc, flags=re.MULTILINE)
        desc = re.sub(r'\n{3,}', '\n\n', desc)
        return desc
    return ""


def parse_blocks(text):
    """Parse RST directives into (kind, name, decl, params) tuples."""
    lines = text.split("\n")
    blocks = []
    i = 0
    while i < len(lines):
        m = re.match(
            r'^\s*\.\. ada:(type|function|procedure)::\s+(.+)',
            lines[i]
        )
        if m:
            kind = m.group(1)
            rest = m.group(2).strip()

            if kind == "type":
                m2 = re.match(r'\S+\s+(\S+)', rest)
                if not m2:
                    i += 1
                    continue
                name = m2.group(1)
                i += 1
                while i < len(lines) and "code-block:: ada" not in lines[i]:
                    i += 1
                if i < len(lines):
                    indent = len(lines[i]) - len(lines[i].lstrip())
                    content_indent = indent + 3
                    i += 1
                    decl_lines = []
                    while i < len(lines) and (
                        (len(lines[i]) - len(lines[i].lstrip()) >= content_indent)
                        if lines[i].strip() else True
                    ):
                        if lines[i].strip():
                            decl_lines.append(lines[i][content_indent:])
                        i += 1
                    if decl_lines:
                        blocks.append((kind, name, " ".join(decl_lines).strip(), ""))
            else:
                m2 = re.match(r'\S+\s+(\S+)', rest)
                name = m2.group(1) if m2 else rest.split()[0] if rest else "?"
                decl = rest
                # Collect parameter descriptions
                i += 1
                params = {}
                while i < len(lines):
                    pm = re.match(r'^\s+:parameter\s+(\S+):\s*(.*)', lines[i])
                    if pm:
                        pname = pm.group(1)
                        pdesc = pm.group(2).strip()
                        i += 1
                        while i < len(lines) and lines[i].strip() and re.match(r'^\s{4,}', lines[i]):
                            if lines[i].strip():
                                pdesc += " " + lines[i].strip()
                            i += 1
                        params[pname] = pdesc
                    elif re.match(r'^\s+:returns:\s*(.*)', lines[i]):
                        i += 1
                        while i < len(lines) and lines[i].strip() and re.match(r'^\s{4,}', lines[i]):
                            i += 1
                    elif re.match(r'^\s*\.\. ada:', lines[i]):
                        break
                    elif re.match(r'^----', lines[i]):
                        break
                    elif re.match(r'^\S', lines[i]) and not lines[i].startswith(" "):
                        break
                    else:
                        i += 1
                blocks.append((kind, name, decl, params))
        else:
            i += 1
    return blocks


def render_index(packages):
    lines = ["# Ada_CRDT API Reference", "", "## Packages", ""]
    for title in sorted(packages, key=lambda p: (p.count("."), p.lower())):
        lines.append(f"- [{title}]({packages[title]})")
    lines.append("")
    return "\n".join(lines)


def render_package(title, desc, blocks):
    lines = [f"# {title}", ""]
    if desc:
        lines.append(desc)
        lines.append("")

    sections = {}
    for kind, name, decl, params in blocks:
        sec = {"type": "Types", "function": "Functions", "procedure": "Procedures"}.get(kind, "Other")
        sections.setdefault(sec, []).append((name, decl, params))

    for sec in ["Types", "Functions", "Procedures"]:
        items = sections.get(sec)
        if not items:
            continue
        lines.append(f"## {sec}\n")
        for name, decl, params in items:
            lines.append(f"### {name}\n")
            lines.append(f"```ada\n{decl}\n```\n")
            if params:
                lines.append("| Parameter | Description |")
                lines.append("|-----------|-------------|")
                for pname, pdesc in params.items():
                    lines.append(f"| `{pname}` | {pdesc} |")
                lines.append("")

    return "\n".join(lines)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    files = sorted(f for f in os.listdir(RST_DIR) if f.endswith(".rst"))
    packages = {}

    for fname in files:
        with open(join(RST_DIR, fname)) as f:
            text = fix_text(f.read())

        title = parse_title(text)
        if not title:
            continue

        desc = parse_description(text)
        blocks = parse_blocks(text)
        fn = slug(title)
        with open(join(OUT_DIR, fn), "w") as f:
            f.write(render_package(title, desc, blocks))
        packages[title] = fn

    with open(join(OUT_DIR, "index.md"), "w") as f:
        f.write(render_index(packages))

    print(f"Wrote {len(packages)} package docs + index to {OUT_DIR}/")


if __name__ == "__main__":
    main()
