---
title: W1 refine pass 2 — §ADR-11 Idempotency Contract ratified `#decision` (thread #59
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-11, idempotency, ratified, decision, pass-2, single-straight-ratification-instance-2, thread-59-closed, heuristic-confirmed-durable, client-api-contract-surface-complete]
created: 2026-05-02
source: docs/adr.md@54e882f §ADR-11 + thread #59 closed messages 119-120
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 2 — §ADR-11 Idempotency Contract ratified `#decision` (thread #59

W1 refine pass 2 — §ADR-11 Idempotency Contract ratified `#decision` (thread #59 closed via single straight-ratification — instance #2 in repo).

User ratified all five sub-questions C1-C5 in single response 2026-05-02 GMT+7: "เอาตามแนะนำ". Second instance of single-straight-ratification shape (first was §ADR-10 thread #57 "เลือกตามที่แนะนำทุกข้อเลยครับ"). **Heuristic from §ADR-10 retro confirmed predictively useful at 2 confirming instances** — pattern qualifies as durable.

Pure marker-strip + status-promotion pass. Body unchanged from baseline (78 lines); no body content changed; no Decision #6 added; no scope expansion. Single commit 54e882f.

Heuristic re-confirmed: pass-1 satisfies all 5 enabling conditions → straight ratification likely. §ADR-11 satisfied:
1. Phase-1/Phase-2 staging on hedged decisions (D3 TTL Phase-1 24h + Phase-2 merchant-configurable trigger)
2. Architect-rec on every sub-question (5/5)
3. Trade-offs rejected inline at decision-line (10 alternatives A-J)
4. Drift-closure-as-decision (D1+D5 close "HTTP retry → duplicate row" structural gap)
5. Coordination-rule-as-architectural-invariant (D5 every client-facing create requires header)

Decision #4 conflict matrix specificity (4-case matrix: replay 200 / 409 conflict / outside-TTL=new / new-key=process) was flagged in baseline retro as gray-area concern. User accepted without pushback. **Gray-area concern unfounded for this audience** — flag as resolved.

Client-API replay-handling contract now exists. §ADR-7 (API-Key auth + HMAC integrity) + §ADR-11 (Idempotency) together specify the full client-facing payment-API contract surface. Production-incident-class events (PAY1776286617S2B53L-class at client-API surface) now structurally impossible. §ADR-7 sibling-cross-cut amendment to cite §ADR-11 deferred to future maintenance pass.

Architecture-decision phase milestone reached — 8 ADRs ratified #decision covering deposit + payout core architecture: §ADR-4a/4b/4c/4d (lane-specific) + §ADR-9 (callback dispatcher) + §ADR-10 (wallet substrate) + §ADR-11 (client-API idempotency). Substrate-shaped + surface-shaped decisions both progressed significantly.

Three patterns confirmed durable across full session arc:
- Drift-closure-as-decision (3 instances: §ADR-10 D4 / §ADR-9 D2 / §ADR-11 D1+D5)
- Coordination-rule-as-architectural-invariant (2 instances: §ADR-10 D5 / §ADR-11 D5)
- Phase-1/Phase-2 staging (4 instances: §ADR-2 / §ADR-9 / §ADR-10 / §ADR-11)

Single-straight-ratification heuristic durable (2 instances: §ADR-10 / §ADR-11).

Threads closed: #59 (closing-message message_id 120 with full single-quote ratification + commit citation). Threads opened: none. Commit: 54e882f. PR #9 (open, not merged).

Trace chain: c7380258 (§ADR-11 pass-1 baseline) → this pass (§ADR-11 pass-2 ratified). Cross-ADR producer/consumer/substrate/client-API chain extends to 7 links: f9c519ad → 541c6fdd → c327e4d9 → e003baff → b304445f → c7380258 → this pass (§ADR-4c → §ADR-9 → §ADR-10 → §ADR-11).

Open thread inventory in territory after this pass: only #45 (fleet-control, claude-last-pending; no architect action). Zero in-territory active threads.

Today's session arc spans 3 calendar days (2026-04-30 → 2026-05-01 → 2026-05-02): 6 W1 passes (3 ratified ADRs + 2 ratification follow-ups + 1 baseline ratified): §ADR-9 baseline → §ADR-9 ratified → §ADR-10 baseline → §ADR-10 ratified → §ADR-11 baseline → §ADR-11 ratified. Total wall-clock spans ~42 hours; total active work ~4 hours.

Next-pass candidate: Payment Source-Flow ADR (Settlement scheduling + Pullout + Direct-Transfer + Payout creation) — largest remaining gap, 120-180 min, may need 2 passes. Or Admin-API surface ADR — 90-120 min, may fold as §ADR-2a subsection. Both surface-shaped.

§ADR-11 lifecycle: pass-1 baseline (#provisional) → pass-2 ratification (#decision) on single branch architect/w1-refine-adr-idempotency-2026-05-01 + PR #9. Two-pass lifecycle (no pass 1.5 needed).

---
*Added via Oracle Learn*
