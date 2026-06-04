---
title: §ADR-12 §Amendment 2026-05-31 NEW (campaign ng2arch, PR #292, NOT merged — pendi
tags: [adr-12, pullout, pullout-tasks, operator-crud, amendment-vs-new-adr, rbac, soft-delete, step-up, ratification-pending, ng2arch]
created: 2026-05-31
source: next-architect (ng2arch campaign)
---

# §ADR-12 §Amendment 2026-05-31 NEW (campaign ng2arch, PR #292, NOT merged — pendi

§ADR-12 §Amendment 2026-05-31 NEW (campaign ng2arch, PR #292, NOT merged — pending user GO) — Pullout-Task Operator CRUD Surface. Closes the deferred-S4 gap of §ADR-12 D3: D3 consolidated the pullout dispatcher + PULLOUT-001/002 specify dispatcher+guard chain, but the operator-facing CRUD surface for the `pullout_tasks` configs that feed it (~155 in prod) had no decision record.

HOME DECISION (the "new ADR vs amendment" call): §ADR-12 AMENDMENT, NOT a new ADR-20. Rationale: pullout-task config is the config/creator side of the D3 dispatcher §ADR-12 already owns; an amendment keeps it adjacent to D3 + PULLOUT-001/002 (which already cite §ADR-12 D3). §ADR-12 §Out-of-scope explicitly parked it ("admin UI shape … admin-API future"; "exact column shapes (pullout_tasks)"). Parallels the 2026-05-26/27/30 amendments that filled D3/D4-deferred details. Rejected: standalone ADR (orphans from D3); fold into §ADR-18 (pullout_tasks is not one of the 6 core config entities, §ADR-18 closed at 6).

RATIFIED class (a) port-fidelity:
- PT1 — operator CRUD surface exists + composes §ADR-13 (D1/D2/D3 + F1/F2/F3) + §ADR-18 + §ADR-12 D1/D3. Dashboard JWT + RBAC `pull-out-tasks`{view,create,update,delete,approve} + `pull-out-logs`{view} — ALREADY in the ratified §ADR-13 F3 33-resource catalogue (adr.md:3035-3036) → adds NO new RBAC resource. Human caller → no §ADR-11 Idempotency-Key. Converges the SSE-only `PublishEvent` trail onto canonical `audit_log` + adds the missing `created_by` triple (same class-(a) hardening §ADR-18 applied to system-bank's bespoke FieldChange trail). `execute-now` = the admin-manual-trigger source PULLOUT-001 names; feeds the single D3 dispatcher (not a copy).
- PT2 — port-fidelity field inventory: source/dest bank, `min/max` band (the dispatcher-side gate, §ADR-8 AF3b, DISTINCT from the fair-router 9th filter), `time_strategy`{jitter,window,weighted,burst}+`time_config` (only jitter+window live), window, txn_per_day, status, `last_demand_trigger_at` (demand-refill cooldown). Dead/legacy fields dropped on port: `merchant_bank_*`, `minimum_amount`, `pull_out_amount`, `time_interval`.

FLAGGED class (b) [RATIFICATION_PENDING:ng2arch-b] — 2 policy/safety sub-decisions (pullout NEVER touches a client wallet — operator funds bank→bank, lower money-sensitivity):
- (p1) delete/disable policy + in-flight guard — current = unconditional hard-delete (`DeleteOne`, no in-flight check, no audit) + unguarded toggle; lean SOFT-DELETE + BLOCK delete/disable while a drain is enqueued/in-flight in withdrawal_queue (composing RESOLVED §ADR-18 b3, which BLOCKs deleting a system_bank with "pending pullout"). Deliberately NOT porting the unconditional hard-delete.
- (p2) step-up (AUTH-007) on manual `execute-now` — §ADR-2 §Amendment 2026-05-26 S2 step-up scope deliberately OMITTED pullout (S2 set = wallet/client-money-out: refund·admin-DTR·admin-settlement·admin-payout-override). Lean follow S2 = NO step-up; user decides whether to EXTEND S2 to pullout run-now.

Stories: PULLOUT-003 (create/list/edit, class a) + PULLOUT-004 (enable-disable/cancel/execute-now + safety guards, guards pending p1/p2) in epic-source-flows. Grounded in `PullOutTaskController.go` (11 handlers) + `routes/pullout_task.go` + `models/pullout_task.go`. Repo: kxlahsimx09/mb-next-payment-gateway (next-system).

---
*Added via Oracle Learn*
