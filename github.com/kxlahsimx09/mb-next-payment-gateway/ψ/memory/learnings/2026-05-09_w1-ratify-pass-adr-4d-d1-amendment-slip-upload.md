---
title: W1 ratify pass — §ADR-4d D1 amendment Slip Upload Actor Matrix + slip_uploaded_b
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-4d, adr-4d-d1-amendment, slip-upload-actor-matrix, slip-uploaded-by-audit-triple, ratify, decision, thread-84-closed, track-2-closed, combined-baseline-ratify-landing-instance-2, forward-compatibility-check-before-ratify-pattern-instance-1-NEW, p2p-orthogonality-verified, coordination-rule-instance-6, per-action-actor-triple-instance-6, phase-1-architectural-surface-complete, 0-live-provisional, trace-chain-30-links, pr:26]
created: 2026-05-09
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ratify pass — §ADR-4d D1 amendment Slip Upload Actor Matrix + slip_uploaded_b

W1 ratify pass — §ADR-4d D1 amendment Slip Upload Actor Matrix + slip_uploaded_by Audit Triple (combined baseline + pass-2 ratify; thread #84 closed). Track 2 of 3-track derivative plan from thread #81 closes.

# Pass shape

Combined-landing pass instance #2 (after §ADR-16 ratify earlier this session — instance #1). Same conditions: baseline filed 2026-05-07, pass-2 ratify 2026-05-09 spans session boundary, user ratified wholesale, baseline branch had rebase debt — single-commit landing on clean-from-main branch.

Combined-landing pattern at instance #2 = candidate-durable; brew-ops handoff at instance #3.

# H1-H4 ratification

All 4 sub-questions wholesale-ratified per *"H1 - H4 ผมโอเคหมดและ"* AFTER P2P-readiness deep-dive on H1:

- H1 — Slip upload 3-actor matrix (customer / client / sub-client / admin)
- H2 — `slip_uploaded_by` audit triple on ts_deposits (mirrors §ADR-13 amendment F2 pattern)
- H3 — RBAC permissions per §ADR-13 amendment F3 namespace
- H4 — Layer 1 tenant scope check enforcement (coordination-rule pattern instance #6)

# Forward-compatibility check before ratify — NEW pattern instance #1

User flagged H1 deep-dive concern at ratify-time: *"ตอนนี้จะมี เรื่อง poc ที่เกี่ยวข้องกับการทำ peer to peer matching... อยากรู้ว่าเราออกแบบ แบบนี้ จะรองรับ การมาของ peer to peer ไหม"*. Architect ran orthogonality analysis:

- §ADR-4d D1 amendment H1 = WHO uploads slip (actor model)
- P2P-matching = WHERE deposit goes (destination routing — withdrawer's bank vs system bank)
- Different axes; H1 covers P2P transparently; future P2P amendment lands on §ADR-4 lane (e.g., §ADR-17 NEW or §ADR-4 amendment), not §ADR-4d

Pattern: when ratifying ADR-X with adjacent feature in PoC stage or pre-ADR (no `#decision` yet), verify orthogonality at ratify-time deep-dive. If orthogonal → ratify clean. If interaction → consider amendment scope adjustment or defer ratify.

User-pushback-as-design-force pattern instance #29 — surfaced at ratify-time deep-dive (pattern: ratify-time = second forensic checkpoint).

# 3-track derivative plan from thread #81 — fully closed

- Track 1 = §ADR-13 amendment thread #82 (actor model + F2 triple) — ratified 2026-05-08
- Track 3 = §ADR-16 thread #83 (Client Self-Topup B2B) — ratified 2026-05-09 earlier this session
- **Track 2 = this amendment (slip upload actor matrix) — ratified 2026-05-09 (now)**

All 3 tracks `#decision`; thread #81 derivative gap fully closed.

# Pattern accumulation post-pass

- **Combined baseline + ratify landing — instance #2** (candidate-durable; brew-ops handoff at #3)
- **Forward-compatibility check before ratify — instance #1 NEW** (brew-ops handoff candidate at #2)
- **Coordination-rule pattern (Layer 1 tenant scope) — instance #6** (durable continues)
- **Per-action actor triple as universal forensic primitive — instance #6** (durable confirmed; well past threshold)
- **Production-DB MCP grounding** continues durable (12,497 slip-bearing records verified at baseline; orthogonality check used PoC learning at ratify)

# Trace chain — extends 29 → 30 links (longest in repo)

`42c30ed4` (§ADR-16 ratify, earlier this session) → `[backfill]-§ADR-4d-D1-amendment-ratify` (this pass).

Phase-1 architectural surface complete; chain reaches longest-in-repo.

# Architecture-decision phase status post-pass — MILESTONE

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.**

Phase-1 architectural surface complete. `next-dev` activation per thread #66 fully unblocked.

19 sections:
§ADR-1 / §ADR-2 (+ Auth Surface Completion amendment) / §ADR-3 / §ADR-4 / §ADR-4a / §ADR-4b (+ Bot↔Gateway Statement Push Contract amendment + D2 Matcher Cascade amendment) / §ADR-4c / §ADR-4d (+ Slip-Bearing Fraud Detection amendment + **Slip Upload Actor Matrix amendment NEW this pass**) / §ADR-5 / §ADR-6 / §ADR-7 / §ADR-8 / §ADR-9 / §ADR-10 / §ADR-11 / §ADR-12 / §ADR-13 (+ Client Web User Actor amendment) / §ADR-14 / §ADR-15 / §ADR-16.

# Threads

- **Closed:** #84 (with closing message + commit citation 3b7a77c).
- **Opened:** none.

# Sources

- thread:#84 messages 198 (H1-H4 baseline questions; full architect rec)
- thread:#81 (closed bridge)
- thread:#82 (Track 1 dependency, ratified 2026-05-08)
- baseline learning superseded: `learning_2026-05-07_w1-amendment-baseline-adr-4d-d1-amendment-slip`
- dpay MCP production verification (12,497 slip-bearing records with no audit; drift class confirmed)
- p2p-matching PoC learning `learning_2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching-p` (orthogonality verified at ratify deep-dive)
- session-close retro 2026-05-08 (resume context + priority-1 task)

# Commit anchor

`b1e376e` (§ADR-4d D1 amendment ratify combined-landing) on branch `architect/w1-adr4d-amendment-slip-upload-actor-matrix-2026-05-07` (force-pushed clean from main). PR #26 merged via 3b7a77c.

---
*Added via Oracle Learn*
