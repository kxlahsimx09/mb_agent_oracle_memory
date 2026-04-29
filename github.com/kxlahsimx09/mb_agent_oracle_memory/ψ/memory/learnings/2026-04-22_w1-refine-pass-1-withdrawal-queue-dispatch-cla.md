---
title: W1 refine pass 1 — withdrawal queue dispatch & claim.
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, adr, refinement, w1, withdrawal-queue, dispatcher, provisional, trade-off, migration-map]
created: 2026-04-22
source: docs/adr.md@a6d1f40 + threads #41, #42; evidence bundle cited in §Revision log
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 refine pass 1 — withdrawal queue dispatch & claim.

W1 refine pass 1 — withdrawal queue dispatch & claim.

Refined ADR-4's single-line "Withdrawal dispatch" sub-bullet into a deep-dive §ADR-4a in `docs/adr.md` at `a6d1f40`. Scope: the withdrawal-queue lane only — the four-way intake/matching decoupling of the parent ADR-4 is unchanged.

The pass ratifies (provisionally, pending threads #41+#42) a Realtime-broadcast + claim-side-enforced-invariants + pg_cron-sweep pull model for the next system. Load-bearing design choices grounded in mobiz-ratified prior art:

- Mobiz's thread #29 "one batch per bank end-to-end, no pipelining" permanent design intent is **carried forward unchanged** into the next system, enforced atomically inside a thin PL/pgSQL RPC `claim_withdrawal_items` — consistent with ADR-3 ("only `FOR UPDATE` logic belongs in PL/pgSQL"). This eliminates the mobiz `WithdrawalDispatcher` goroutine while preserving the invariant it defended.
- Per-bank tier cap (mobiz PR #237, 3 tiers on `unassigned` count) carried forward into the same RPC.
- Atomic `batch_id` mirror onto source docs (payout / settlement / pullout / direct-transfer) preserved — but authored at **claim time** rather than dispatch time. This is a deliberate behavioural divergence (thread #42 confirms reading).
- Bot-side pre-claim browser-session health check is **mandatory**, citing the KTB session-death drift (prod incidents 0170681475 / 0170679675 / 0170689786). The bot must refuse to call the RPC if its browser session is not verifiably live.
- Admin JWT queue-terminal endpoints (`PUT …/success|/failed`) are explicitly **not** carried forward — thread #12 classified them as debug/legacy in the current system.

Key deltas:
- `docs/adr.md` gained §ADR-4a (~85 lines) between ADR-4 and ADR-5.
- `docs/adr.md` gained `### Revision log` section at doc end with first entry per W1 §Outputs format.
- Two new `arra_thread` pending: #41 (ratification) + #42 (disambiguation), both anchored in §ADR-4a §Open questions.
- Claim in §ADR-4a §Decision is tagged `[RATIFICATION_PENDING:41,42]`; section carries `#provisional` until both threads resolve.

Sources cited (10 learnings + 4 flows + 1 pending current-system thread): flow `withdrawal-queue-dispatch-and-claim@252849e`, flow `withdrawal-queue-single-bot-transfer@252849e+bbd1616`, flow `ktb-single-transfer-withdrawal@1cf5e14`, flow `ktb-keepalive-session-rotation`; learnings `2026-04-18_flow-withdrawal-queue-dispatch-and-claim-ratif` (thread #12), `2026-04-21_w8-revision-ratified-flow-withdrawal-queue-dispatch-and-claim-thread-29` (thread #29), `2026-04-19_withdrawal-dispatcher-per-bank-cap-pr-237-12ad0`, `2026-04-17_withdrawaldispatcher-stale-bot-skip-in-findidleb`, `2026-04-17_name-withdrawal-queue-batch-id-end-to-end`, `2026-04-17_withdrawal-queue-gained-waitingtoreview-termin`, `2026-04-18_drift-followup-admin-queue-terminal-endpoints-cl`, `2026-04-16_resolution-drift-scheduler-intervals`, `2026-04-17_name-drift-ktb-session-death-is-a-real-sil`, `2026-04-22_w10-constraint-harvest-first-run-baseline`; current-system thread #14 (pending, `waiting_to_review` admin resolution).

Threads opened: #41 + #42. Threads closed: none. Commit: `a6d1f40`. PR: `kxlahsimx09/mb-next-payment-gateway#1` (open, not merged). Next pass candidate themes (one per line, pick next run):
- When threads #41/#42 resolve: close the markers + promote §ADR-4a §Decision from `#provisional` to `#decision` + supersede this learning with the ratified version.
- Cross-cutting concern §4 "Authentication and authorization": ADR-2 currently conflates Supabase Auth (entity isolation) with RBAC (action authorization) — could benefit from a §4-style deep dive once a Phase 1 RBAC enum is drafted. Security-sensitive — halts and pings the human before writing.
- Subsystem: deposit auto-match (ADR-4 other lane). Rich current-system prior art via `flow:deposit-auto-match-from-statement`.

Meta-observations for workflow-authoring / brew-ops follow-up:
- Baseline `docs/adr.md` (committed d1dc579 — pre-W1) does NOT follow the W1 template: no H1 title, no §§1–7, ADRs written at H4 under an H3 umbrella. W1's refine-vs-baseline branching handled this correctly by refusing to treat it as baseline (file exists) and instead doing surgical single-section refinement. A future W1 change could document this "pre-W1 baseline" edge case explicitly so successor architects don't wonder whether to retrofit the template.
- `KNOWN_PROJECTS` gap still present: filing under `github.com/kxlahsimx09/mb_agent_oracle_memory` as the prior `2026-04-22_w1-refine-adr-workflow-authored-for-system-archite` learning did. Brew-ops should land the one-line PR to `arra-oracle-v3`'s `src/tools/learn.ts:68-77` KNOWN_PROJECTS list to add `github.com/kxlahsimx09/mb-next-payment-gateway`.

---
*Added via Oracle Learn*
