---
title: epic-auth-rbac 4-lens review + dpay-verify arc — RATIFIED 2026-06-07, staged fix
tags: [epic-auth-rbac, 4-lens-review, authreview, authverify, authfix, dpay-verify, phase1-db-rls, sub-client-taxonomy, lockout-ratify, suspended-login-gate, ui-substrate-split, wui-auth, unified-users-table, next-architect, prod-data-grounded-decision]
created: 2026-06-07
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# epic-auth-rbac 4-lens review + dpay-verify arc — RATIFIED 2026-06-07, staged fix

epic-auth-rbac 4-lens review + dpay-verify arc — RATIFIED 2026-06-07, staged fix IN PROGRESS. Second epic to run the UI/substrate split (next-ui → admin-portal WUI stories).

REVIEW (campaign authreview): architect 2H/2M/5L (mostly doc-faithfulness/within-authority), pg-writer 0H/2M/4L (1 MUST-ADD), next-writer 8H/11M/7L (many missing identity ops + 2 contradictions), next-ui 8H/8M/1L → 17 split-aware WUI stories for admin-portal. 58 raw → 10 themes. Findings ψ/memory/mailbox/. Aggregate /tmp/authreview/authreview_AGGREGATE_report.md.

dpay VERIFY (campaign authverify, brew-ops direct mcp__dpay__*): KEY DISCOVERY — `users` is the UNIFIED identity table (user_type = admin/merchant/client/partner/sub-client); merchants/clients/partners = parallel business-profile tables; super-admin is a ROLE not a tier; standalone `subclients` collection vestigial (4). Numbers as-of 2026-06-07: sub-client 554/765 (72%, dominant); suspended/inactive login-gate LIVE (3 refusals, 8 gated, status==2 never triggered); lockout fired 16× / 5 currently locked / ~11 unlocks / login_logs pending 23,844; 2FA enrolled 582/765 (76%), admin 2FA-reset only 5 events ever.

RATIFIED (user GO 2026-06-07) — full detail /tmp/authreview/RATIFIED-decisions.md:
- A: DB/RLS in Phase-1 (user chose the STRONGER guarantee — overrides §ADR-13 F4's Phase-2 deferral → architect amends F4 to pull RLS forward; resolves AUTH-003↔AUTH-004 contradiction toward DB-enforcement).
- B: sub-client = entity_type=client + parent_client_id (entity_type stays 4); merchant tenant-scope = own clients.
- C: MINIMAL — fix contradictions + doc-faithfulness only; missing identity ops (logout/session, password reset/policy/change, key rotate/revoke, role assign/delete, account disable, 2FA recovery) = documented backlog / route creation to entity-provisioning.
- D: AUTH-007 fail-closed + super-admin-toggle ACs. E: AUTH-006 cite §ADR-2 §Amd 2026-05-28 edge-gateway + signature/replay ACs. F: MUST-ADD suspended/inactive login gate (+ carry-over flags: wired per-token JWT blacklist jwt.go:301, last_login/ip). G: RATIFY two-regime lockout as §ADR-2 #decision (Phase-1 baseline figures; resolves thread #244). H: glossary step-up fix; 2FA recovery LEAVE-AS-IS (backup-codes NOT worth a clause — 5 resets ever). I: HIGH-8 WUI (001/002/003/006/008/009/013/015) → admin-portal epic-auth-ui.md; WUI-013 step-up modal must match AUTH-007 gated set exactly (never on admin payout). J: doc-faithfulness grab-bag.

STAGED FIX: architect adr PR (campaign authfix: A §ADR-13-F4 amendment + G §ADR-2 lockout clause) + writer-spec → orchestration-catch → next-writer epic PR (authfix-epic, Minimal, disjoint files) + next-writer admin-portal epic-auth-ui.md PR (authui, HIGH-8 WUI). Pattern proven on wallet-ledger (PRs #338/#339 + admin-portal#1, pending merge).

NOTE the admin-portal docs-site Nextra renderer was ported this session (PR mb-next-admin-portal#1) — epic-auth-ui.md will render there too; Vercel root=docs-site/, enable 'Include source files outside Root Directory'.

---
*Added via Oracle Learn*
