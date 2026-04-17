---
title: Audit + fix (2026-04-16, GMT+7) — Charter `.agent/AGENTS.md` audited for symmetr
tags: [tester, technical-writer, repo:mobiz-payment-gateway, current, decision, charter, agent-design, audit, drift]
created: 2026-04-16
source: Conversation with Mobiz, 2026-04-16 GMT+7, brew-ops-oracle session; AGENTS.md + fleet config fully read before audit
project: github.com/kokarat/mobiz-payment-gateway
---

# Audit + fix (2026-04-16, GMT+7) — Charter `.agent/AGENTS.md` audited for symmetr

Audit + fix (2026-04-16, GMT+7) — Charter `.agent/AGENTS.md` audited for symmetry across the two active agents (`pg-writer-oracle`, `pg-tester-oracle`). Six gaps/drifts found; all six fixed in the same pass.

## Audit findings (before fix)

1. **Fleet ↔ §5 drift**: `.agent/fleet/20-payment-gateway.json` had `pg-writer-oracle` (suffixed) but `pg-tester` (unsuffixed). §3 line 82 and §5 both require the `-oracle` suffix. Risk: maw's discovery predicate (`window.endsWith('-oracle')`) would have silently excluded the tester pane.
2. **§5a writer-only**: "Two-instance pattern" section was specific to `technical_writer`. No equivalent for `tester` stating single-instance semantics.
3. **§6 step 2 example**: `arra_search` example hard-coded to `technical_writer`. A tester reading the charter had no prompt-template.
4. **§6 step 5 ownership examples**: listed `code_reviewer`, `technical_writer`, `security_auditor` — no tester row.
5. **§8 Reality-first**: framed doc↔code drift only; no coverage of test↔code drift (tester's primary concern) or mock-bank↔backend/bot drift.
6. **§12 Maintainers**: only named `technical_writer` as editor.

## Fixes applied (file: .agent/AGENTS.md + .agent/fleet/20-payment-gateway.json)

1. Fleet entry renamed `pg-tester` → `pg-tester-oracle` to match the `-oracle` suffix convention.
2. Added §5b "Single-instance pattern for `tester`": explicit no-sibling-in-target-repo rule; no cross-repo SKILL.md sync obligation; no `#migration-map` usage from this role.
3. §6 step 2: example query shown twice — one per active role (writer / tester) — with a "substitute your role" instruction.
4. §6 step 5: added explicit tester line — "surfaces regression candidates via `arra_learn` tagged `#regression-candidate` … does not patch production code, does not rewrite tests without user sign-off."
5. §8: restructured from two artifact classes (code, docs) to three (code, docs, tests). Added an ownership table covering four drift pairs: doc↔code (writer), test↔code (tester), mock-bank↔contract (tester), doc↔test (either → routes to doc owner). Each row names the `arra_learn` tag to use.
6. §12: generalized maintainer line to "any active agent in §5 may propose edits via PR; human approves". Added a "Revision history" block with two entries — charter creation 2026-04-14, tester activation 2026-04-16 (this PR).

## What stays writer-only (intentionally)

- §5a two-instance pattern — only `technical_writer` actually has a sibling; §5b documents the asymmetry explicitly so no future reader thinks it's an oversight.

## Verification

After fixes, both `pg-writer-oracle` and `pg-tester-oracle` can read this single file and find:
- Their own role name in §5 roster with tmux window + ownership.
- Their own arra_search template in §6 step 2.
- Their own "do / do not" discipline examples in §6 step 5.
- Their own drift class and resolution path in §8.
- Their own section in §5a or §5b for single/multi-instance deployment.

## Not fixed (deliberate, out of audit scope)

- `maw.config.json` reference in §2 — not present in `.agent/`; that's a maw-ecosystem concern, not this repo's charter.
- Vault path mention in §2 ("mounted into this VM at /sessions/…") — environment-specific, left alone.
- `~/.arra-oracle` vs `~/.arra-oracle-v2` naming (vault used to live at the former; the running Oracle is v2) — historical; out of scope for a symmetry audit.

## Files touched
- .agent/AGENTS.md (§5b added, §6.2+§6.5 + §8 + §12 edited)
- .agent/fleet/20-payment-gateway.json (pg-tester → pg-tester-oracle)

---
*Added via Oracle Learn*
