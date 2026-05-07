---
title: W1 refine §ADR-15 ratification (pre-ratification revised pass 1.5 + pass 2 combi
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-15, monitoring, alerting, ratification, pass-15, pass-2, combined-pass, decision, thread-79-closed, alert-catalog-expanded-22-to-31, historical-incident-sweep, user-pushback-instance-24, pre-input-5-extends-to-oracle-memory-instance-1, alert-ground-truthing-via-historical-incident-sweep-instance-1, combined-pass-1.5-pass-2-instance-3, 12-adrs-architecture-decision-phase-milestone, zero-live-provisional, deposit-payout-monitoring-substrate-all-ratified]
created: 2026-05-06
source: docs/adr.md@108971f §ADR-15 + docs/design/monitoring/alert-catalog.md@108971f (post pass-1.5 expansion); thread:#79 messages 189-191; 9 source learnings cited per new alert in revision-log entry
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine §ADR-15 ratification (pre-ratification revised pass 1.5 + pass 2 combi

W1 refine §ADR-15 ratification (pre-ratification revised pass 1.5 + pass 2 combined) — thread #79 closed; D1-D8 resolved; amendment promotes `#provisional` → `#decision`. Architecture-decision phase milestone: 12 ADRs ratified; 0 live `#provisional`.

User direction *"ตามที่แนะนำเลยทุกข้อ ยกเว้น D6 ผมอยากให้ลองไปไล่ค้นใน memory learning pr เก่าๆ ดูว่ามีข้อไหนควรจะใส่เข้ามา"*. D1/D2/D3/D4/D5/D7/D8 straight-ratified. D6 (Phase-1 alert catalog) revised within-pass via Oracle memory historical-incident sweep — expanded 22 → 31 alerts.

D6 expansion grounded in 9 historical incidents:

P1 additions (2):
- P1.6 wallet double-debit detection — source: 2026-04-18 jaosua777 5 payouts × 19,527.80 THB overcharge via MarkWaitingToReview → admin confirm-completed double-deduction path
- P1.7 stale claimed/processing items — source: mobiz PR #249 (commit 8bf3a52, 2026-04-20) stale-lock sweep drift class

P2 additions (5):
- P2.11 per-bank login failure spike — source: 2026-04-22 KTB silently renamed username placeholder ระบุรหัสผู้ใช้งาน → ชื่อผู้ใช้งาน, bot login broke silently for hours
- P2.12 callback dead-letter rate — source: §ADR-9 D6 dead-letter primitive (callback delivery permanent failure surface)
- P2.13 pool snapshot vs live divergence — source: 2026-04-11 SCB banks 4352312351/4352298400 admin enabled deposit but pool snapshot stale, wrong routing for hours
- P2.14 V1 BLOCK + force-approve pair within 5 min — source: pre-mobiz #384 V1 false-positive class DEP17777364940AC8L3 + DEP1777733674IBGAQO
- P2.15 bot preventive-restart compliance — source: bank-bot install-preventive-restart.sh systemd timer drift class

P3 additions (2):
- P3.8 daily fraud catch stat — source: production baseline 905/8736 deposits/90d (~10.36%, ~1.07M THB direct loss prevented)
- P3.9 daily payout reconciliation breakdown — source: MarkFailed double-callback race + waiting_to_review trust-model signal

Total catalog: 7 P1 + 15 P2 + 9 P3 = 31 alerts. Each new entry cites source learning + production incident reference for traceability.

Patterns surfaced this pass:

1. **Combined pass 1.5 + pass 2 lifecycle — instance #3** (after §ADR-9 cost-coalescing combined pass 2026-04-30 + §ADR-13 Decision #2 Option D combined pass 2026-05-03). When pre-ratification revise scope is contained (one decision adjustment without architectural change) AND user provides revise direction in ratification message, combined pass saves a separate revise commit cycle.

2. **User-pushback-as-design-force instance #24** — user surfaced opportunity to ground catalog in historical evidence rather than speculative threshold design. Pattern: "ค้นใน memory ของจริงก่อน แล้วค่อย propose" (verify-via-prior-art before propose).

3. **Pre-Input-5 extends to Oracle-memory historical-incident sweep — instance #1 (NEW pattern)**. Original Pre-Input-5 (verify-before-port) covered code-claim verification via current-system-code-reads. This pass extends to: when authoring catalog/threshold/policy decisions, sweep Oracle memory for historical incidents/drifts that should ground the design. Cheaper than runtime experimentation; produces evidence-grounded thresholds vs speculative-grounded thresholds. Pattern candidate for W1 §Inputs heuristic update.

4. **Alert ground-truthing via historical-incident sweep — instance #1 (NEW pattern)**. Every new alert in pass 1.5 cites a source learning + production incident reference. Extends "verify-before-port" from code to alert-catalog authoring. Saves alert false-positive class — without grounding, alerts based on guessed thresholds tend to fire wrong.

Pre-Input-5 instance count: 16 → 17 (1 new — Oracle-memory historical-incident sweep). User-pushback-as-design-force: 23 → 24.

Architecture-decision phase post-ratify:
- 12 ADRs `#decision` (§ADR-1 through §ADR-13 + §ADR-4b/4d amendments + §ADR-4b D2 amendment + §ADR-15)
- 0 live `#provisional` ADR sections — clean state
- Deposit/payout core architecture + monitoring/alerting substrate all ratified
- Remaining named architectural gap: §ADR-14 fleet-control (thread #45 long-pending; user-blocked on substrate choice)

Phase-1 cost ratified: ~$7/month total (Axiom 500GB free + Sentry 5K errors free + ~$5 Hetzner CX22 for Keep + ~$2 Anthropic API enrichment). MCP-ready substrate by design — Phase-2 enablement is feature-toggle.

Same-day baseline-then-ratify cycle: §ADR-15 baseline 09:09 GMT+7 → ratify pass 1.5+2 ~10:30 GMT+7 = ~1.5 hours total. Fast cycle = baseline scope was crisp + user provided ratification + revise in single message.

Threads closed: #79. Threads opened: none. Commit: `108971f`. PR #18 (8 commits total: 6 baseline arc + 2 ratify pass).

Next pass candidate: §ADR-14 fleet-control baseline (thread #45 long-pending; user-blocked) OR W2 sync-clean docs/architecture.md regenerate (pg-writer/next-architect handoff) OR await PR #17 + PR #18 merge to main + Phase-1 implementation kickoff (next-dev developer agent activation per thread #66).

---
*Added via Oracle Learn*
