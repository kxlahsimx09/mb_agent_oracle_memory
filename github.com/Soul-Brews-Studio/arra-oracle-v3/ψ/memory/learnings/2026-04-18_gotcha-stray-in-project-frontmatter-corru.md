---
title: Gotcha — stray `<` in `project:` frontmatter corrupts the on-disk directory name
tags: [brew-ops, gotcha, memory, arra-learn, validation, path-corruption, repo:arra-oracle-v3, frontmatter]
created: 2026-04-18
source: 2026-04-18 brew-ops audit, discovered via `SELECT * FROM oracle_documents WHERE source_file LIKE '%<%'`
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Gotcha — stray `<` in `project:` frontmatter corrupts the on-disk directory name

Gotcha — stray `<` in `project:` frontmatter corrupts the on-disk directory name

Symptom: vault had a literal directory `github.com/kokarat/bank-bot</` (with trailing `<`) containing exactly one learning file. 6 DB rows referenced the corrupted path. Ghost was stable for >24h before this audit caught it.

Root cause: `arra_learn` derives the vault destination path from the `project:` frontmatter field. When the frontmatter was written as `project: github.com/kokarat/bank-bot<` (stray `<` character — likely a paste artefact from HTML-encoded input or an incomplete comparison operator), the writer created `github.com/kokarat/bank-bot</` verbatim on disk. No validation layer rejected the bad character.

How it manifests in Oracle:
- `SELECT DISTINCT source_file FROM oracle_documents WHERE source_file LIKE '%<%'` returns the corrupted rows
- Search results for that topic appear with broken-looking paths
- soul-sync would replicate the corrupt directory to Linux peers where `<` is a valid filename character

Fix pattern (tested 2026-04-18):
1. `git mv` the file from `bank-bot</ψ/...` to `bank-bot/ψ/...`
2. `Edit` the frontmatter: `project: github.com/kokarat/bank-bot<` → `github.com/kokarat/bank-bot`
3. `rmdir` the (now-empty) `bank-bot<` directory tree (safe — no `-rf`)
4. `bun run index` to register the new path as canonical
5. `arra_supersede` the old short-ID row (content frozen at old path) → new path-ID chunks

Preventative hardening (proposed, not yet implemented):
- `arra_learn` should reject `project:` values failing a regex `^github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$`
- Indexer `collectors.ts` could warn when it encounters source_file characters outside a safe allowlist

Open question: did the bot-writer-oracle session that wrote this entry also pass a bad `project` via CLI arg, or did the raw LLM output include the `<`? Worth checking bot-writer retros for Apr 17.

---
*Added via Oracle Learn*
