#!/usr/bin/env python3
"""
Pre-push / pre-commit memory hygiene check.

Scans uncommitted (untracked + modified + staged) memory files under
**/ψ/memory/{learnings,retrospectives}/*.md and runs 8 checks defined in
workflow-6-pre-push-memory-check.md.

Exit codes:
  0 — all pass (or WARN-only in default mode)
  1 — one or more FAIL (or WARN in --strict mode)
  2 — invocation error (not in a git repo, no candidate files, etc.)

Flags:
  --strict       WARNs are upgraded to FAIL-level blocking
  --allow-warn   Explicit opt-in that WARNs do not block (currently the default;
                 kept for forward-compat if defaults ever change)
  --help         Show usage
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


# ---------- Frontmatter parsing (regex-based; no PyYAML dependency) ----------

FM_OPEN = re.compile(r'\A---\s*\n')
FM_CLOSE = re.compile(r'\n---\s*(\n|$)')


def split_frontmatter(text: str):
    """Return (frontmatter_text, body) or (None, text) if missing."""
    if not FM_OPEN.match(text):
        return None, text
    close = FM_CLOSE.search(text, 4)
    if not close:
        return None, text
    return text[4:close.start()], text[close.end():]


def parse_fm_fields(fm: str) -> dict:
    """Lightweight frontmatter parser: top-level scalars + list/block literals."""
    fields: dict = {}
    lines = fm.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i]
        if not line.strip() or line.strip().startswith('#'):
            i += 1
            continue
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*)$', line)
        if not m:
            i += 1
            continue
        key, rest = m.group(1), m.group(2)
        if rest == '' or rest.strip() == '|' or rest.strip() == '>':
            # Block scalar OR list (collect indented lines)
            collected = []
            j = i + 1
            while j < len(lines):
                nxt = lines[j]
                if nxt and not nxt.startswith((' ', '\t')) and not nxt.startswith('-'):
                    break
                collected.append(nxt)
                j += 1
            val = '\n'.join(collected).strip()
            if any(l.strip().startswith('-') for l in collected):
                items = [l.strip().lstrip('- ').strip().strip('"\'')
                         for l in collected if l.strip().startswith('-')]
                fields[key] = items
            else:
                fields[key] = val
            i = j
        elif rest.startswith('['):
            # Inline list: [a, b, c]
            inner = rest.strip().strip('[]')
            items = [x.strip().strip('"\'') for x in inner.split(',') if x.strip()]
            fields[key] = items
            i += 1
        else:
            fields[key] = rest.strip().strip('"\'')
            i += 1
    return fields


# ---------- Git integration ----------

def git_toplevel() -> Path:
    try:
        out = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            capture_output=True, text=True, check=True,
        )
        return Path(out.stdout.strip())
    except subprocess.CalledProcessError:
        sys.stderr.write('Error: not in a git repository.\n')
        sys.exit(2)


# Git escapes non-ASCII paths (e.g. ψ → "\317\210") unless core.quotepath is off.
# We pass -c core.quotepath=off on every invocation so Unicode paths come through
# verbatim as UTF-8. This matters for this vault because ψ/ is everywhere.
GIT_UNICODE = ['git', '-c', 'core.quotepath=off']


def candidate_files(root: Path) -> list[Path]:
    """Files that are untracked OR modified OR staged, filtered to memory scope."""
    def run(cmd):
        out = subprocess.run(cmd, cwd=root, capture_output=True, text=True, check=True)
        return [l for l in out.stdout.split('\n') if l.strip()]

    untracked = run(GIT_UNICODE + ['ls-files', '--others', '--exclude-standard'])
    modified = run(GIT_UNICODE + ['diff', '--name-only'])
    staged = run(GIT_UNICODE + ['diff', '--cached', '--name-only'])

    seen = set()
    result = []
    for rel in untracked + modified + staged:
        if rel in seen:
            continue
        seen.add(rel)
        # Filter: only memory files
        if not rel.endswith('.md'):
            continue
        # Use a Unicode-safe check; ψ is U+03C8
        if '/\u03c8/memory/learnings/' not in '/' + rel and \
           '/\u03c8/memory/retrospectives/' not in '/' + rel:
            continue
        p = root / rel
        if p.exists():
            result.append(p)
    return result


# ---------- Checks ----------

class Finding:
    def __init__(self, severity: str, check_id: int, message: str):
        self.severity = severity  # 'FAIL' or 'WARN'
        self.check_id = check_id
        self.message = message

    def __str__(self):
        return f'{self.severity} #{self.check_id}: {self.message}'


PROJECT_BAD_CHARS = re.compile(r'[<>\s"\']')
TRUNCATION_HINT = re.compile(r'\b[a-z]\s*$', re.IGNORECASE)  # ends with single letter + trailing whitespace


def check_file(path: Path, root: Path) -> list[Finding]:
    findings: list[Finding] = []
    text = path.read_text(encoding='utf-8', errors='replace')
    fm_text, body = split_frontmatter(text)

    # #1 Frontmatter parseable
    if fm_text is None:
        findings.append(Finding('FAIL', 1, 'missing or unterminated frontmatter (--- delimiters)'))
        return findings  # no point continuing without frontmatter
    try:
        fm = parse_fm_fields(fm_text)
    except Exception as e:
        findings.append(Finding('FAIL', 1, f'frontmatter parse error: {e}'))
        return findings

    # #2 Required fields
    required = ['title', 'tags', 'created']
    # project is required for non-universal files (under github.com/…)
    rel_from_vault = str(path.relative_to(root))
    if rel_from_vault.startswith('github.com/') or rel_from_vault.startswith('github.com\\'):
        required.append('project')
    missing = [k for k in required if k not in fm or not fm[k]]
    if missing:
        findings.append(Finding('FAIL', 2, f'missing required frontmatter field(s): {missing}'))

    # #3 project: path safety
    project = fm.get('project', '')
    if isinstance(project, str) and project and PROJECT_BAD_CHARS.search(project):
        findings.append(Finding('FAIL', 3,
            f'project: contains disallowed char(s) — {project!r}'))

    # #4 Retro structure
    is_retro = '/\u03c8/memory/retrospectives/' in '/' + rel_from_vault
    if is_retro:
        body_lc = body.lower()
        if 'diary' not in body_lc:
            findings.append(Finding('FAIL', 4, "retro missing 'AI Diary' section (case-insensitive)"))
        if 'feedback' not in body_lc:
            findings.append(Finding('FAIL', 4, "retro missing 'Honest Feedback' section (case-insensitive)"))

    # #5 Title truncation heuristic (WARN)
    title = fm.get('title', '')
    if isinstance(title, str) and title:
        # Heuristic: title ends with " n" or " a" etc — single short word fragment
        if re.search(r'\s[a-z]$', title) or re.search(r'[a-z]\s+$', title):
            findings.append(Finding('WARN', 5,
                f"title may be truncated mid-word: '...{title[-30:]}'"))

    # #6 3-layer tag presence (WARN)
    tags = fm.get('tags', [])
    if isinstance(tags, list):
        tag_str = ' '.join(str(t) for t in tags).lower()
    else:
        tag_str = str(tags).lower()
    has_repo = bool(re.search(r'\brepo:[a-z0-9_.-]+', tag_str))
    DOMAINS = ['memory', 'indexer', 'search', 'federation', 'fleet', 'studio',
               'mcp-tools', 'vault', 'workflow', 'flow', 'drift', 'handoff',
               'audit', 'trace', 'backup']
    has_domain = any(d in tag_str for d in DOMAINS)
    ROLES = ['brew-ops', 'pg-writer', 'pg-tester', 'bot-writer',
             'technical-writer', 'tester', 'writer']
    has_role = any(r in tag_str for r in ROLES)
    missing_layers = []
    if not has_repo: missing_layers.append('repo:*')
    if not has_domain: missing_layers.append('system-domain')
    if not has_role: missing_layers.append('role')
    if missing_layers:
        findings.append(Finding('WARN', 6,
            f'3-layer tags incomplete — missing: {missing_layers} (tags: {tags})'))

    # #7 Source citation quality (WARN)
    source = fm.get('source', '')
    if not source:
        findings.append(Finding('WARN', 7, 'source: field missing or empty'))
    else:
        s = str(source)
        has_hash = bool(re.search(r'\b[0-9a-f]{7,40}\b', s))
        has_fileref = bool(re.search(r'\S+\.[a-z]+:\d+', s))
        has_pr = bool(re.search(r'#\d+|PR\s*#?\d+', s))
        has_date = bool(re.search(r'\d{4}-\d{2}-\d{2}', s))
        has_url = 'http' in s
        if not any([has_hash, has_fileref, has_pr, has_date, has_url]):
            findings.append(Finding('WARN', 7,
                'source: citation has no commit hash / file ref / PR# / date / URL'))

    # #8 related: refs resolve (WARN)
    related = fm.get('related', [])
    if isinstance(related, list):
        for ref in related:
            ref = str(ref).strip()
            if not ref or ref.startswith('<') or ref.startswith('http'):
                continue
            key = ref[:-3] if ref.endswith('.md') else ref
            basename = os.path.basename(key)
            # Search the vault for this basename
            found = False
            try:
                out = subprocess.run(
                    ['find', str(root), '-name', f'{basename}.md'],
                    capture_output=True, text=True, timeout=10,
                )
                found = bool(out.stdout.strip())
            except Exception:
                pass
            if not found:
                findings.append(Finding('WARN', 8,
                    f"related: ref not found on disk — '{ref}'"))

    return findings


# ---------- Main ----------

def main():
    ap = argparse.ArgumentParser(description='Pre-push memory hygiene check')
    ap.add_argument('--strict', action='store_true',
                    help='Upgrade WARNs to blocking FAILs')
    ap.add_argument('--allow-warn', action='store_true',
                    help='Explicit opt-in that WARNs do not block (default behavior)')
    ap.add_argument('--quiet', action='store_true',
                    help='Only print on issues; silent on clean pass')
    args = ap.parse_args()

    root = git_toplevel()
    files = candidate_files(root)

    mode = 'strict (WARN blocks)' if args.strict else 'default (FAIL blocks, WARN informational)'
    now = datetime.now().strftime('%Y-%m-%d %H:%M %Z')

    if not files:
        if not args.quiet:
            print(f'=== Pre-push memory check — {now} ===')
            print(f'Mode: {mode}')
            print(f'Scope: 0 uncommitted memory files in {root}')
            print('\n✅ Nothing to check. Exit 0.')
        sys.exit(0)

    if not args.quiet:
        print(f'=== Pre-push memory check — {now} ===')
        print(f'Mode: {mode}')
        print(f'Scope: {len(files)} uncommitted memory files in {root}\n')

    n_pass = n_warn_only = n_fail = 0
    all_findings: list[tuple[Path, list[Finding]]] = []

    for path in files:
        findings = check_file(path, root)
        all_findings.append((path, findings))
        has_fail = any(f.severity == 'FAIL' for f in findings)
        has_warn = any(f.severity == 'WARN' for f in findings)
        if has_fail:
            n_fail += 1
            icon = '🔴'
        elif has_warn:
            n_warn_only += 1
            icon = '⚠️ '
        else:
            n_pass += 1
            icon = '✅'
        rel = path.relative_to(root)
        print(f'  {icon} {rel}')
        for f in findings:
            print(f'       {f}')

    total = len(files)
    print(f'\nSummary: {n_pass} PASS | {n_warn_only} WARN | {n_fail} FAIL  '
          f'(total {total})')

    # Exit code logic
    block = n_fail > 0 or (args.strict and n_warn_only > 0)
    if block:
        print('Exit: 1 (blocking — fix issues before commit/push)')
        sys.exit(1)
    else:
        if n_warn_only > 0:
            print('Exit: 0 (WARNs informational; use --strict to block on warnings)')
        else:
            print('Exit: 0 (all clean)')
        sys.exit(0)


if __name__ == '__main__':
    main()
