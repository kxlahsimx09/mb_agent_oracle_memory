---
title: title: Retro — DEPOSIT epic review pass 2026-05-10 to 2026-05-11 (session arc + 
tags: [next-product-writer, repo:mb-next-payment-gateway, next, retro, session-arc, epic-deposit, deposit-005-authored, 11-prs-merged, handoff, next-session-candidates]
created: 2026-05-11
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: Retro — DEPOSIT epic review pass 2026-05-10 to 2026-05-11 (session arc + 

title: Retro — DEPOSIT epic review pass 2026-05-10 to 2026-05-11 (session arc + handoff)

## Session arc

2-day intensive review of `docs/requirements/epic-deposit.md` driven by user reading the doc story-by-story, catching gaps/fabrications/wrong claims, and asking for fixes. Authored 1 new story (DEPOSIT-005). 14 PRs opened, 13 merged.

## PRs landed (chronological, 2026-05-10 → 2026-05-11)

| PR | Title | What it landed |
|---|---|---|
| #44 | actor terminology fix (Client = API integrator) | First overhaul: fix Client vs Merchant inversion throughout |
| #45 | docs/requirements/ style pass (SKILL.md Principle 4) | Move engineering refs out of prose; consult-skill-first lesson |
| #46 | fingerprint fabrication closure | Verify-via-3-sources methodology; drop fingerprint mechanism |
| #47 | full pass — re-apply lost fixes + Topup gap + glossary | Bundle pending; partner + idempotency-key glossary entries |
| #48 | DEPOSIT-001 corrections (expires_at, custom_bank, per-bank quirks, intra-bank fallback divergence) | 4 commits across DEPOSIT-001 + 002 + 003 cleanup |
| #49 | re-apply orphaned DEPOSIT-003 capacity-freeing correction | First orphan re-apply (recurring pattern surfaces) |
| #50 | DEPOSIT-003 v_deposits view contract | §ADR-4c D10 + cross-cut amendments cited |
| #51 | DEPOSIT-004 Thunder-verify timer step + drop fabricated longer-window/TTL-extended | Thunder timing = server-config |
| #53 | DEPOSIT-005 authored — multi-candidate review parking | Q4c safety story; flagged status-name drift |
| #54 | DEPOSIT-004 terminal-state taxonomy (rejected vs failed semantic split) | User architectural decision |
| #55 | DEPOSIT-004 step 5 — D5 wording aligned with rejected vs failed | Consistency follow-up |
| #56 | DEPOSIT-003 + DEPOSIT-004 — drop migration/legacy-data framing | `project_no_data_migration` enforcement |
| #57 | DEPOSIT-005 refinement — degenerate-FIFO + SCB framing | Re-apply orphan from PR #53 |
| #58 (open) | DEPOSIT-005 — rewrite degenerate-FIFO trade-off block for clarity | User asked for plain-English rewrite |

## State at session close

- **DEPOSIT-001 → DEPOSIT-005 all in main** at S2 ratified, with detailed user journeys + ACs + edge cases + Sources + revision log
- **PR #58 open** — final clarity rewrite of degenerate-FIFO trade-off block
- **9 AWAITING_THREAD flags** pending next-architect ratification (full list in companion learning `2026-05-11_title-deposit-epic-review-methodology-fabricati`)
- **Epic owner**: `next-product-writer` (this role)

## Next-up candidates (priority-ordered)

### Phase 1 — Author remaining ratified DEPOSIT stories

| # | Story | Source | Notes |
|---|---|---|---|
| DEPOSIT-006 | Admin manual statement re-match | §ADR-4b D6 ratified | Operator endpoint for >1h-old statements; bot-down recovery, post-parser-fix replay, DBA force-rematch |
| DEPOSIT-007 | Slip-fraud detection at admin approve (V1+V2) | §ADR-4d V1+V2 amendment ratified 2026-05-05 thread #77 | DEPOSIT-004 currently doesn't cover the fraud layer that runs BEFORE finalize on admin-approve. V1 hash-lookup duplicate-slip; V2 receiver-mismatch; super_admin force-approve override |
| DEPOSIT-008 | Admin verify-slip-now | §ADR-4d D8 ratified post-amendment 2026-04-27 | Admin endpoint trigger Thunder verify on-demand instead of waiting for sweep |

### Phase 2 — Defer (admin-API ADR future)

| # | Story | Notes |
|---|---|---|
| DEPOSIT-009 | Maintenance-cancel — admin force-expire | §ADR-4c D9 mentions; admin surface defers to admin-API ADR |
| (DEPOSIT-010?) | Refunded flow | 2 production rows; payment_details empty; semantics undocumented; flagged in earlier exchange |

### Phase 3 — AWAITING_THREAD ratification sweep (open arra threads to next-architect)

For each AWAITING_THREAD flag in epic-deposit.md, open formal thread → next-architect → ratification → §ADR minor amendment. Pattern: similar to thread #90 (actor terminology). 9 flags pending — could batch 3 per session or staircase.

### Phase 4 — Move to next epics

Per README.md epic index, planned epics (none yet authored):
- Payout (§ADR-4a, §ADR-8 substrate ready)
- Settlement
- Pullout
- Direct Transfer
- Wallet & Ledger (§ADR-3, §ADR-10)
- MDR Distribution
- Bot Dispatch (§ADR-8 fair-router)
- Auth & RBAC (§ADR-2, §ADR-7, §ADR-13)
- OTP & Trust
- Client Self-Topup (§ADR-16 ratified 2026-05-09)

## Open issues / process notes

- **Orphan commit pattern recurring** (5+ instances). Despite mitigation attempts, user's fast merge cadence keeps producing orphans. Discussed pattern with user; no durable fix yet. Possibly add a CI check or just accept as cost.
- **AWAITING_THREAD inventory not yet drained** — 9 flags pending. Recommend dedicating a session to opening arra threads in batch (3-4 per session) so the architectural backlog clears before next-impl needs the contracts.
- **Production data verification heavily used** (dpay MCP) — but dpay MCP became unavailable at session close (2026-05-11 13:00 GMT+7). If still down next session, fall back to vault learnings + ADR text only; flag any need-to-verify-against-production claims.

## Recommended first 30 minutes of next session

1. Check PR #58 merge state; if not merged, follow up
2. Read this retro + the companion methodology learning (`2026-05-11_title-deposit-epic-review-methodology-fabricati`)
3. Decide between (a) author DEPOSIT-006 (most-ratified, lowest-friction next story), or (b) start AWAITING_THREAD ratification sweep with next-architect — user's pick
4. If (a), follow the same fabrication-detection methodology before drafting
5. If (b), batch open 3 arra threads (intra-bank fallback + terminal-state taxonomy + degenerate-FIFO carve-out are top-3 priorities)


---
*Added via Oracle Learn*
