---
title: epic-wallet-ledger UI/substrate SPLIT — restructure 2026-06-07 (supersedes the i
tags: [epic-wallet-ledger, ui-substrate-split, mb-next-admin-portal, wui-prefix, next-product-writer, next-ui, skill-update, fleet-division-of-labor, walletui, walletfix-epic, pr-339, admin-portal-pr-1, supersedes-kind-marker]
created: 2026-06-07
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# epic-wallet-ledger UI/substrate SPLIT — restructure 2026-06-07 (supersedes the i

epic-wallet-ledger UI/substrate SPLIT — restructure 2026-06-07 (supersedes the inline-Kind-marker approach in the same-day arc).

USER DECISION (2026-06-07): operator/console UI stories must NOT live in the gateway backend product doc — they live in the mb-next-admin-portal product doc. The gateway epic is SUBSTRATE-ONLY. No inline UI/substrate marker — the DOCUMENT a story lives in IS its kind.

OUTCOME (3 disjoint commits, all reviewed):
- gateway epic-wallet-ledger → substrate-only WALLET-001..008 (001-006 unchanged; 007 = typed mdr_skip reason_code [was 009]; 008 = MDR clawback substrate [was 012]). Removed the 4 UI stories + the Kind-marker convention (header tags + glance Kind column + legend). Cross-refs the admin-portal UI stories by repo-qualified id. PR #339 (updated; net substrate-only).
- NEW mb-next-admin-portal docs/requirements/epic-wallet-ui.md + INDEX → WUI-001 (wallet directory, was WALLET-007) · WUI-002 (dropped-MDR dashboard, was 008) · WUI-003 (adjustment form, was 010) · WUI-004 (audit-trail read, was 011). Portal-native WUI-### prefix. Cross-refs gateway substrate + ADRs repo-qualified (ADRs stay gateway-owned). PR mb-next-admin-portal#1 (the repo's FIRST PR).
- skill next-product-writer (commit 07f6fc5) → SKILL.md discipline #4 is now the SEPARATION RULE (UI console stories → admin-portal epic-<domain>-ui.md WUI-###; gateway epic substrate-only; no inline marker; cross-ref by repo-qualified id; next-ui builds, writer owns acceptance text). workflow-1 reverted the Kind column/tag, added a "split the UI surface out" step. SUPERSEDED the prior same-day Kind-marker skill commit e10d565.

FLEET DIVISION CONFIRMED: next-product-writer owns requirement/acceptance text across the WHOLE next-* fleet (gateway AND admin-portal docs/requirements/); next-ui owns LOOK + implementation only (reads the writer's acceptance text, does not author it). So "move UI to admin-portal" = writer authors the requirement doc IN the admin-portal repo; next-ui implements from it.

PENDING USER MERGE (do not merge without GO): PR #338 (gateway adr §Amd 2026-06-07) FIRST → then #339 (gateway epic substrate-only) → admin-portal#1 (UI doc, independent repo, can merge anytime). epic#339 cites admin-portal WUI-### and vice-versa (cross-repo id refs resolve after both merge).

---
*Added via Oracle Learn*
