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
        r'code-block:: ada.*?^\s+package\s+\S+\s*$'
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
    """Split RST text into (kind, name, decl, params, returns) blocks."""
    blocks = []
    lines = text.split("\n")
    i = 0
    while i < len(lines):
        m = re.match(r"^\.\. ada:(type|function|procedure)::\s+(.+)$", lines[i])
        if m:
            kind = m.group(1)
            name = m.group(2).strip()
            decl = ""
            i += 1
            while i < len(lines) and lines[i].strip() and lines[i].startswith(" "):
                stripped = lines[i].strip()
                i += 1
                if re.match(r'^:[\w-]+:', stripped):
                    continue
                if decl:
                    decl += "\n"
                decl += stripped
            params = {}
            returns = ""
            desc = ""
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
                    rm = re.match(r'^\s+:returns:\s*(.*)', lines[i])
                    returns = rm.group(1).strip()
                    i += 1
                    while i < len(lines) and lines[i].strip() and re.match(r'^\s{4,}', lines[i]):
                        if lines[i].strip():
                            returns += " " + lines[i].strip()
                        i += 1
                elif re.match(r'^\s*\.\. code-block:: ada', lines[i]):
                    i += 1
                    base_indent = None
                    while i < len(lines):
                        if not lines[i].strip():
                            i += 1
                            continue
                        indent = len(lines[i]) - len(lines[i].lstrip())
                        if base_indent is None:
                            base_indent = indent
                        if indent < base_indent:
                            break
                        stripped = lines[i].strip()
                        if re.match(r'^--', stripped):
                            i += 1
                            continue
                        if decl:
                            decl += "\n"
                        decl += stripped
                        i += 1
                elif re.match(r'^\s*\.\. ada:', lines[i]):
                    break
                elif re.match(r'^----', lines[i]):
                    break
                elif re.match(r'^\S', lines[i]) and not lines[i].startswith(" "):
                    if not desc and kind == "type":
                        desc = lines[i].strip()
                    i += 1
                else:
                    i += 1
            blocks.append((kind, name, decl, params, returns, desc))
        else:
            i += 1
    return blocks


def parse_ada_pkg_desc(lines):
    """Extract package description from Ada spec file header comments."""
    desc_parts = []
    for line in lines:
        s = line.strip()
        if re.match(r'--\s*@', s):
            continue
        if s.startswith('--'):
            text = re.sub(r'^--\s*', '', s)
            if text:
                desc_parts.append(text)
        elif not s:
            continue
        else:
            break
    if not desc_parts:
        return ""
    desc = " ".join(desc_parts)
    return re.sub(r'\s+', ' ', desc).strip()


def parse_ada_annotations(ads_path):
    """Parse .ads file for package description and per-subprogram annotations.
    Returns (pkg_desc, annotations, has_private_section)."""
    if not os.path.isfile(ads_path):
        return "", {}, False
    with open(ads_path) as f:
        lines = f.readlines()
    pkg_desc = parse_ada_pkg_desc(lines)
    annotations = {}
    cur = {"params": {}, "returns": ""}
    in_private = False
    protected_depth = 0
    for line in lines:
        s = line.strip()
        if re.match(r'\s*protected\s+type\b', s):
            protected_depth += 1
            continue
        if re.match(r'end\s+\w+\s*;', s) and protected_depth > 0:
            protected_depth -= 1
            continue
        if protected_depth > 0:
            continue
        if re.match(r'^private$', s):
            in_private = True
            continue
        if in_private:
            continue
        pm = re.match(r'--\s*@param\s+(\S+)\s*(.*)', s)
        if pm:
            cur["params"][pm.group(1)] = pm.group(2).strip()
            continue
        rm = re.match(r'--\s*@return\s*(.*)', s)
        if rm:
            cur["returns"] = rm.group(1).strip()
            continue
        sm = re.match(
            r'\s*(?:overriding\s+)?(?:procedure\b|function\b)\s+'
            r'("(?:[^"]|"")+"|\w+)',
            s
        )
        if sm:
            name = sm.group(1)
            annotations[name] = cur
            cur = {"params": {}, "returns": ""}
    return pkg_desc, annotations, in_private


def subprog_short_name(block_name):
    m = re.match(r'(?:procedure|function)\s+("(?:[^"]|"")+"|\w+)', block_name)
    return m.group(1) if m else block_name


def package_to_ads_path(pkg_name):
    """Convert CRDT.Lww_Element_Sets -> src/crdt-lww_element_sets.ads.
    For nested packages (e.g. CRDT.Protected.Shared_RGA) walks up the
    hierarchy until it finds an existing file."""
    parts = pkg_name.lower().split(".")
    for i in range(len(parts), 0, -1):
        candidate = "src/" + "-".join(parts[:i]) + ".ads"
        if os.path.isfile(candidate):
            return candidate
    return "src/" + "-".join(parts) + ".ads"


def extract_protected_type_decl(ads_path, type_name):
    """Extract full protected type declaration from Ada spec file.
    Returns Ada source text or empty string if not found."""
    if not os.path.isfile(ads_path):
        return ""
    with open(ads_path) as f:
        lines = f.readlines()
    start = None
    for i, line in enumerate(lines):
        if re.match(rf'\s*protected\s+type\s+{re.escape(type_name)}\b', line):
            start = i
            break
    if start is None:
        return ""
    buf = []
    for i in range(start, len(lines)):
        buf.append(lines[i].rstrip())
        if re.match(rf'^\s*end\s+{re.escape(type_name)}\s*;', lines[i]):
            break
    while buf and not buf[-1]:
        buf.pop()
    return "\n".join(buf)


def parse_subitem_from_comment(kind, name, signature, comment_lines, is_private):
    desc_lines = []
    params = {}
    returns = ""
    for cl in comment_lines:
        pm = re.match(r'--\s*@param\s+(\S+)\s*(.*)', cl)
        if pm:
            params[pm.group(1)] = pm.group(2).strip()
            continue
        rm = re.match(r'--\s*@return\s*(.*)', cl)
        if rm:
            returns = rm.group(1).strip()
            continue
        s = re.sub(r'^--\s*', '', cl)
        if s:
            desc_lines.append(s)
    description = " ".join(desc_lines).strip()
    return (kind, name, signature, description, params, returns, is_private)


def parse_protected_subitems(decl, type_name):
    """Parse protected type Ada declaration into structured sub-items.
    Returns (header_text, items, footer_text) where each item is
    (kind, name, signature, description, params, returns, is_private)."""
    lines = decl.split("\n")
    header_lines = []
    i = 0
    found_is = False
    while i < len(lines):
        header_lines.append(lines[i])
        if re.search(r'\bis\s*$', lines[i]):
            found_is = True
            i += 1
            break
        i += 1
    if not found_is:
        return "\n".join(header_lines), [], f"end {type_name};"
    header = "\n".join(header_lines)

    items = []
    current_comment = []
    in_private = False

    while i < len(lines):
        line = lines[i].rstrip()
        s = line.strip()

        if s == "private":
            in_private = True
            i += 1
            continue
        if re.match(rf'^\s*end\s+{re.escape(type_name)}\s*;', s):
            i += 1
            break
        if not s:
            i += 1
            continue
        if s.startswith("--"):
            current_comment.append(s)
            i += 1
            continue

        sm = re.match(r'\s*(procedure|function|entry)\s+("[^"]+"|\w+)', s)
        if sm:
            kind = sm.group(1)
            name = sm.group(2)
            sig_lines = [line]
            depth = line.count("(") - line.count(")")
            i += 1
            while i < len(lines) and depth > 0:
                nl = lines[i].rstrip()
                ns = nl.strip()
                if ns.startswith("--") or not ns or ns == "private" or re.match(rf'^\s*end\s+{re.escape(type_name)}\s*;', ns):
                    break
                sig_lines.append(nl)
                depth += nl.count("(") - nl.count(")")
                if depth <= 0:
                    i += 1
                    break
                i += 1
            signature = "\n".join(sig_lines)
            items.append(parse_subitem_from_comment(kind, name, signature, current_comment, in_private))
            current_comment = []
        else:
            items.append(parse_subitem_from_comment("field", s.split()[0] if s else "", s, current_comment, in_private))
            current_comment = []
            i += 1

    return header, items, f"end {type_name};"


def parse_record_subitems(decl, type_name):
    """Parse record Ada declaration, extracting common fields and variant cases.
    Returns (header_text, common_fields, variants, footer_text).
    common_fields is list of (field_name, field_type_str, description)
    variants is list of (when_expr, [(field_name, field_type_str)])."""
    lines = decl.split("\n")
    header_lines = []
    i = 0
    while i < len(lines) and "record" not in lines[i]:
        header_lines.append(lines[i])
        i += 1
    if i < len(lines):
        header_lines.append(lines[i])
        i += 1
    header = "\n".join(header_lines)
    common = []
    variants = []
    current_variant = None
    ftype_desc = ""
    in_case = False
    while i < len(lines):
        s = lines[i].strip()
        if not s:
            i += 1
            continue
        if re.match(r'^end\s+record\s*;', s) or re.match(rf'^end\s+{re.escape(type_name)}\s*;', s):
            i += 1
            break
        if re.match(r'^case\s+\w+\s+is', s):
            in_case = True
            i += 1
            continue
        if re.match(r'^end\s+case\s*;', s):
            in_case = False
            current_variant = None
            i += 1
            continue
        if in_case:
            m = re.match(r'^when\s+(.+?)\s*=>\s*$', s)
            if m:
                current_variant = (m.group(1).strip(), [])
                variants.append(current_variant)
                i += 1
                continue
            if current_variant and re.match(r'\w+\s*:', s):
                parts = s.split(":")
                ft = parts[1].strip().rstrip(";")
                current_variant[1].append((parts[0].strip(), ft))
                i += 1
                continue
        else:
            m = re.match(r'(\w+)\s*:\s*(.+?);?\s*$', s)
            if m:
                common.append((m.group(1), m.group(2).strip(), ""))
                i += 1
                continue
        i += 1
    return header, common, variants, "end record;"


def render_record_type(name, header, common, variants, footer, desc):
    lines = []
    lines.append(f"```ada\n{header}\n```\n")
    if desc:
        lines.append(f"> {desc}\n")
    if common:
        lines.append("| Field | Type |")
        lines.append("|-------|------|")
        for fn, ft, _ in common:
            lines.append(f"| `{fn}` | `{ft}` |")
        lines.append("")
    if variants:
        lines.append("**Variants:**\n")
        for when_expr, fields in variants:
            field_str = ", ".join(f"`{fn}` : `{ft}`" for fn, ft in fields)
            lines.append(f"- `when {when_expr} =>` {field_str}")
        lines.append("")
    lines.append(f"```ada\n{footer}\n```\n")
    return lines


def render_index(packages):
    lines = ["# CRDT API Reference", "", "## Packages", ""]
    for title in sorted(packages, key=lambda p: (p.count("."), p.lower())):
        lines.append(f"- [{title}]({packages[title]})")
    lines.append("")
    return "\n".join(lines)


def render_structured_type(name, header, subitems, footer, desc):
    """Render a type with sub-items (e.g. protected type with operations/state)."""
    lines = []
    lines.append(f"```ada\n{header}\n```\n")
    if desc:
        lines.append(f"> {desc}\n")

    public_items = [it for it in subitems if not it[6]]
    private_items = [it for it in subitems if it[6]]

    if public_items:
        lines.append("**Public Operations:**\n")
        for kind, iname, sig, idesc, params, returns, _ in public_items:
            iname_clean = iname.replace('"', '')
            lines.append(f"#### {kind} {iname_clean}\n")
            if sig:
                lines.append(f"```ada\n{sig}\n```\n")
            if idesc:
                lines.append(f"{idesc}\n")
            if params:
                lines.append("| Parameter | Description |")
                lines.append("|-----------|-------------|")
                for pn, pd in sorted(params.items()):
                    lines.append(f"| `{pn}` | {pd} |")
                lines.append("")
            if returns:
                lines.append(f"**Returns:** {returns}\n")

    if private_items:
        lines.append("**Private State:**\n")
        for kind, iname, sig, idesc, params, returns, _ in private_items:
            lines.append(f"- `{sig}`")
            if idesc:
                lines.append(f"  - {idesc}")

    lines.append(f"```ada\n{footer}\n```\n")
    return lines


def render_package(title, desc, blocks, annotations, has_private, ads_path):
    lines = [f"# {title}", ""]
    if desc:
        lines.append(desc)
        lines.append("")
    if has_private:
        lines.append("> **Note:** This package declares items in a `private` section (not shown in full below).")
        lines.append("")

    sections = {}
    for kind, name, decl, params, returns, desc in blocks:
        sec = {"type": "Types", "function": "Functions", "procedure": "Procedures"}.get(kind, "Other")
        sections.setdefault(sec, []).append((name, decl, (params, returns), desc))

    for sec in ["Types", "Functions", "Procedures"]:
        items = sections.get(sec)
        if not items:
            continue
        lines.append(f"## {sec}\n")
        for name, decl, params_returns, desc in items:
            params, returns = params_returns
            sname = subprog_short_name(name)
            anno = annotations.get(sname, {})
            lines.append(f"### {name}\n")
            type_name = re.sub(r'^type\s+', '', name).strip()
            if not decl:
                ads_decl = extract_protected_type_decl(ads_path, type_name)
                if ads_decl:
                    decl = ads_decl
            if decl and re.match(r'\s*protected\s+type\b', decl):
                hdr, subitems, ftr = parse_protected_subitems(decl, type_name)
                lines.extend(render_structured_type(name, hdr, subitems, ftr, desc))
            elif decl and 'case' in decl and 'record' in decl:
                hdr, common, variants, ftr = parse_record_subitems(decl, type_name)
                lines.extend(render_record_type(name, hdr, common, variants, ftr, desc))
            else:
                if decl:
                    lines.append(f"```ada\n{decl}\n```\n")
                if desc:
                    lines.append(f"> {desc}\n")
                merged = {}
                for pname in sorted(params):
                    merged[pname] = params[pname] or anno.get("params", {}).get(pname, "")
                if merged:
                    lines.append("| Parameter | Description |")
                    lines.append("|-----------|-------------|")
                    for pname, pdesc in sorted(merged.items()):
                        lines.append(f"| `{pname}` | {pdesc} |")
                    lines.append("")
                rdesc = returns or anno.get("returns", "")
                if rdesc:
                    lines.append(f"**Returns:** {rdesc}\n")

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
        ads_path = package_to_ads_path(title)
        pkg_desc, annotations, has_private = parse_ada_annotations(ads_path)
        if not desc:
            desc = pkg_desc
        fn = slug(title)
        with open(join(OUT_DIR, fn), "w") as f:
            f.write(render_package(title, desc, blocks, annotations, has_private, ads_path))
        packages[title] = fn

    with open(join(OUT_DIR, "index.md"), "w") as f:
        f.write(render_index(packages))

    print(f"Wrote {len(packages)} package docs + index to {OUT_DIR}/")


if __name__ == "__main__":
    main()
