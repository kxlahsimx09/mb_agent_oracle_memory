---
title: W1 refine pass 2 — §ADR-4c ratification: thread #55 closed, all 5 sub-questions 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4c, deposit, auto-expire, ratified, decision, pass-2, thread-55-closed, deposit-trio-complete, substrate-convergence, 5-instances]
created: 2026-04-29
source: docs/adr.md@c877e3d + thread #55 closed 2026-04-29 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 2 — §ADR-4c ratification: thread #55 closed, all 5 sub-questions 

W1 refine pass 2 — §ADR-4c ratification: thread #55 closed, all 5 sub-questions resolved → `#decision`. Deposit-lane trio architecturally complete.

## Ratification (thread #55, 2026-04-29 GMT+7)

User answered C1+C2 in 11 words; C3+C4+C5 already confirmed in earlier exchange:

| Q | Outcome | User quote |
|---|---|---|
| C1 | 1-min `pg_cron` sweep + computed `effective_status` view (Decision #10) | *"C1 ok"* |
| C2 | (a) in-RPC outbox row | *"ตามที่แนะนำ"* |
| C3 | (a) split — RPC-reuse contract here only | *"C3 ok แยก"* |
| C4 | (a) rely on §ADR-4b matcher filter; never auto-resurrect | *"C4 a"* |
| C5 | (a) none required — pg_cron + per-row `FOR UPDATE` | *"C5 ok"* |

## Pass-2 delta

- §ADR-4c title: `#provisional [RATIFICATION_PENDING:55]` → ratified `#decision` 2026-04-29 GMT+7
- 9 `[RATIFICATION_PENDING:55]` markers stripped from live body (Decision #4, #6, #9 + 5 in Open ratification questions + title)
- Open ratification questions section → Resolved questions (sibling-format with §ADR-4b/§ADR-4d)
- Implementation note: ratified status; pass-3 extraction recommended
- No body decisions changed; no scope expansion. Pure marker-strip + status-promotion.
- Diff: 57 ins / 11 del

## Deposit-lane trio architecturally complete

- §ADR-4a (withdrawal) — `#decision` 2026-04-22
- §ADR-4b (deposit auto-match) — `#decision` 2026-04-27 + amendment 2026-04-29 (cross-cut Decision #5)
- §ADR-4c (deposit auto-expire) — `#decision` 2026-04-29 (this pass)
- §ADR-4d (deposit slip-integration) — `#decision` 2026-04-27 + amendment 2026-04-29 (cross-cut Decision #3)

ADR-3 atomic-boundary substrate convergence reaches **5 instances** — substrate fully battle-tested across deposit/withdrawal lane.

## C2 self-audit moment recorded

User asked *"ตอนนี้ผมต้อง confirm อะไรอีกไหมนะ"* — I had assumed C2 was implicitly confirmed during pass-1.5 message but caught the gap on review (user had explicitly confirmed only C3+C4+C5 in earlier message; C1 was being re-asked; C2 was actually unconfirmed). Surfaced C2 explicitly to user; user ratified within minutes.

**Pattern:** when user asks "what else do I need to confirm?", treat it as a structural integrity check — re-audit which sub-questions have explicit user confirmation vs. inferred. Self-audit > assumption. **Failure mode caught here:** assumed C2 was implicitly answered when user's earlier message only addressed C1/C3/C4/C5. Lesson preserved as durable: **ratification status of each Cn must be tracked explicitly, never inferred from "context."**

## Process notes

- **Clean ratification cycle (third instance — §ADR-4b/§ADR-4d/§ADR-4c).** Pre-positioned architect-recs + one-line user answers = sustainable ratification velocity. Pattern stable across 3 instances now; established as the default §ADR-4*-class shape.
- **No new threads opened.** Pass-2 is a closure pass; thread #55 was the only open in-territory thread; closed via `arra_thread_update status=closed` + closing message with commit citation.
- **6 user-surfaced clarification instances (pass-1.5 retro)** — pre-Input-5 checkpoint failure mode unchanged. Will file brew-ops thread for tooling externalization if pattern recurs in pass-3 or any subsequent design pass.

## Threads + commits

- Thread #55 — closed via `arra_thread_update(status=closed)` + closing message with full ratification table.
- Commit: `c877e3d` (pass-2 ratification body) + `<this commit>` (revision-log backfill) on branch `architect/w1-refine-adr-4c-deposit-auto-expire-2026-04-29` / PR [#5](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/5).
- Supersedes: pass-1.5 revise learning `learning_2026-04-29_w1-refine-pass-15-adr-4c-pre-ratification-revi` (this learning is the ratified state).
- Trace chain: this pass should chain to pass-1.5 trace `f9568328-9c32-4969-998c-06a202948a12`.

## Next-pass candidates

1. **§ADR-4c body extraction** (pass-3) — 190 lines over 150 threshold; extract to `docs/design/deposit-lane/` per §ADR-4a/§ADR-6/§ADR-8 precedent. Estimated 30 min.
2. **Wallet-table cross-cutting ADR** — used by §ADR-4a/§ADR-4b atomic boundaries; no ADR currently. 90-120 min.
3. **Callback dispatcher ADR** — newly load-bearing after §ADR-4c Decision #4 outbox-row contract; promoted priority. 90-120 min.

---
*Added via Oracle Learn*
