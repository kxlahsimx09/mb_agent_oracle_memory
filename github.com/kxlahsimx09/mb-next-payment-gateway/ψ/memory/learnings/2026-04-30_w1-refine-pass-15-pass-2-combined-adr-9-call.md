---
title: W1 refine pass 1.5 + pass 2 combined — §ADR-9 Callback Dispatcher ratified `#dec
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-9, callback-dispatcher, ratified, decision, pass-15, pass-2, combined-pass, outbox, at-least-once, idempotency, hmac, retry-budget, dead-letter, callback-attempts-table, cost-coalescing, user-pushback-as-design-force-instance-2, substrate-convergence-5-instances, thread-56-closed]
created: 2026-04-30
source: docs/adr.md@6dc74bd §ADR-9 + thread #56 closed messages 113-115
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1.5 + pass 2 combined — §ADR-9 Callback Dispatcher ratified `#dec

W1 refine pass 1.5 + pass 2 combined — §ADR-9 Callback Dispatcher ratified `#decision` (thread #56 closed).

User ratified all six sub-questions C1-C6 in single conversation 2026-04-30 GMT+7. Combined within-scope revise (pass 1.5: cost-coalescing tightening on Decision #1 + Decision #6 added) + ratification close (pass 2) into single commit `6dc74bd`. First instance of combined-pass shape — appropriate when user-paced ratification arrives within one session; separate-pass shape (§ADR-4c precedent) is appropriate when ratification spans separate sessions.

Ratification quotes (all from user, 2026-04-30 GMT+7 thread #56):
- C1 substrate hybrid + cost-coalescing — "C1 ผมก็โอเค ถ้าเป็นแบบนี้"
- C2 at-least-once + event_id + no FIFO — "C2 At-least-once + event_id + ไม่มีลำดับ"
- C3 dispatch-time HMAC — "C3 dispatch time"
- C4 fixed-step exponential 6 attempts → dead_letter — "shape = fixed-step exponential + 6 attempts + dead_letter ปลายทาง"
- C5 single-table dead_letter — "C5 ตามแนะนำ"
- C6 append-only callback_attempts table — "C6 ตามแนะนำ"

Pass 1.5 within-scope revise drivers (both user-surfaced):
1. Cost concern on C1 — user asked "ถ้า trigger ถูก insert EF จะถูก call บ่อยไปไหม ทำยังไงให้ cheap". Architect surfaced §ADR-8 X4 NOTIFY-coalescing primitive (pg_try_advisory_lock probe — burst N INSERTs collapses to ~1-5 notifies) + drain-loop pattern (FOR UPDATE SKIP LOCKED batch within EF). Decision #1 paragraph extended with cost-coalescing primitive + cross-ref to design/bot-gateway-dispatch/trigger-coalescing.md.
2. Forensic-log gap on C5 — user asked "เวลา failed หลายๆ ครั้ง จะเก็บ log ยังไง เอาไว้ใน table รึเปล่า". Architect proposed C6 = append-only callback_attempts table + denormalized counter on callback_queue parent row, parallel to §ADR-4d Decision #9 slip_verify_attempts. Pattern shorthand: "second instance of pattern X" lets §ADR-9 reference §ADR-4d for canonical specification (~4 lines vs ~30).

§ADR-9 body 67 → 78 lines after combined pass; still well under 150-line extract threshold. No docs/design/callback-dispatcher/ extraction this pass.

Substrate convergence count → 5 (single ADR contributes 2 instances): Decision #1 hybrid push-pull = 4th port of §ADR-3+§ADR-8 substrate; Decision #6 append-only attempts table = 2nd instance of §ADR-4d D9 forensic-log pattern.

User-pushback-as-design-force pattern — instance #2 in repo. §ADR-4c pass-1.5 logged this for the first time (user "ไม่ clean" pushback drove view-contract design). §ADR-9 pass-1.5 is instance #2: user follow-up questions during ratification surfaced load-bearing architectural decisions architect had silently deferred. Trigger heuristic: when user asks "where does X get stored / how do we recover Y" after seeing decisions #1-#N, that's a signal architect missed a load-bearing data-substrate decision. Pattern qualifies as durable.

Architecture-vs-design discipline tested + held under user pushback. C1 cost concern could have triggered design-content drift (specify lock id, batch size, timeouts); architect resisted by citing §ADR-8 X4 pattern as substrate precedent + drain-loop as architectural shape, leaving exact ids/sizes to impl pass. Same discipline applied to C6 — names table existence + append-only invariant + denormalized-on-parent pattern, defers column shape to design pass.

§ADR-9 lifecycle: pass-1 baseline (`#provisional`) → pass-1.5 within-scope revise (cost-coalescing + Decision #6) → pass-2 ratification (`#decision`) all on single branch architect/w1-refine-adr-callback-dispatcher-2026-04-30 + PR #7. Two-link arra_trace_link chain: f9c519ad (§ADR-4c pass-3 producer side) → 541c6fdd (§ADR-9 pass-1 consumer baseline) → this pass (consumer ratified). Cross-ADR producer/consumer chain now complete.

Thread #56 closed with citation to commit 6dc74bd + revision-log backfill commit + closing message message_id 115. All six sub-questions resolved + quoted in §Resolved questions section.

Outbox consumer side now ratified — §ADR-4a/§ADR-4b/§ADR-4c/§ADR-4d producer side has its consumer-side architectural counterpart. Sibling outbox-row contracts cite §ADR-9 retroactively at impl time; no §ADR-4* text update required.

Next-pass candidate: Wallet-table cross-cutting ADR (strongest standalone candidate per multiple retros; used by §ADR-4a + §ADR-4b atomic boundaries; no ADR currently). 90-120 min. Idempotency ADR (client-facing payment APIs) and Payment Source-Flow ADR are queued behind Wallet-table.

---
*Added via Oracle Learn*
