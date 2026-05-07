---
title: W1 amendment baseline — §ADR-4d D1 amendment (Slip Upload Actor Matrix + `slip_u
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-4d, adr-4d-d1-amendment, slip-upload-actor-matrix, slip-uploaded-by-audit-triple, coordination-rule-instance-6, per-action-actor-triple-emerging-pattern, thread-84-opened, track-2-of-3-derivative-plan, depends-on-adr-13-amendment-thread-82, baseline, pass-1, provisional, ratification-pending, production-db-mcp-grounding-confirmed-12497-slips-no-audit]
created: 2026-05-07
source: docs/adr.md@a42ea8e §ADR-4d amendment block; thread:#84 + thread:#81 (closed bridge); §ADR-13 amendment F1/F2/F3/F4 (depends-on); dpay MCP verification 2026-05-07 (12,497 slips with no slip_uploaded_by audit)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment baseline — §ADR-4d D1 amendment (Slip Upload Actor Matrix + `slip_u

W1 amendment baseline — §ADR-4d D1 amendment (Slip Upload Actor Matrix + `slip_uploaded_by` Audit Triple) (`#provisional`, thread #84 opened).

Track 2 of 3-track derivative plan from thread #81 correction. Depends on §ADR-13 amendment thread #82 ratifying (F1 actor tier + F2 create-time triple pattern that this amendment mirrors).

Closes 2 architectural gaps surfaced 2026-05-07:
1. §ADR-4d D1 today specifies 2 actor paths (customer API-Key + admin JWT) — production reality requires 3 (customer / client web user / admin per user clarification of slip-upload actor matrix)
2. Current schema has 12,497 ts_deposits records with `slip_uploaded_at` but NO `slip_uploaded_by_*` audit fields (verified via dpay MCP) — drift in current; next-system fixes structurally

4 decisions in amendment (H1-H4):
- H1 Slip upload 3-actor matrix: customer (API-Key client tier) / client+sub-client (JWT NEW path) / admin (JWT existing). All 3 paths share `save-slip-metadata` helper per §ADR-4d D1 side-benefit. Endpoints: `POST /deposit/:txnId/upload-slip` (a) / `POST /clients/:id/deposits/:txnId/upload-slip` (b NEW) / `POST /admin/deposits/:id/upload-slip` (c).
- H2 `slip_uploaded_by` audit triple on ts_deposits: `(slip_uploaded_by_id, slip_uploaded_by_username, slip_uploaded_by_type)`. Application-time write (NOT trigger-populated; mirrors §ADR-13 amendment F2 create-time pattern). Enum: 'customer' (path a; id+username NULL) / 'client' / 'sub-client' / 'admin'.
- H3 RBAC permissions per §ADR-13 amendment F3 namespace: `client:deposit:upload-slip` (NEW; client web user + sub-client per F1 tenant scoping) + `admin:deposit:upload-slip` (codify existing). No `customer:*` namespace (different auth mechanism per §ADR-7).
- H4 Layer 1 tenant scope check: every non-admin slip-upload request MUST verify `deposit.client_id = jwt.effective_client_id` at Layer 1 (sync-validate before slip metadata UPDATE). Coordination-rule pattern instance #6 (after §ADR-13 amendment F4 instance #5).

Migration map (additive):
- ts_deposits ~421k records: add 3 columns (NULL-default for legacy)
- 12,497 slip-bearing records: `slip_uploaded_by_type='unknown'` backfill OR NULL (impl decides)
- New uploads mandatory triple per H2

3-track derivative plan now has all 3 baselines opened today (2026-05-07):
- Track 1 thread #82 (§ADR-13 amendment) — actor model + create-time triple + RBAC namespace + tenant scope Layer-1
- Track 2 thread #84 (this amendment) — slip upload actor matrix + slip_uploaded_by audit
- Track 3 thread #83 (§ADR-16) — Client Self-Topup B2B

PR stack: PR #19 (§ADR-14) → PR #20 (§ADR-13 amendment) → PR #21 (§ADR-16) → PR #22 (this).

Patterns surfaced this pass:
- Coordination-rule pattern instance #6 (H4 Layer 1 tenant scope) — already-durable rule continues; instance count tally only. Sequence: Decision #1 instance #1 + §ADR-4c D10 instance #2 + §ADR-13 D2 instance #3 + §ADR-9 D6 instance #4 + §ADR-4b amendment B2 instance #5 + §ADR-13 amendment F4 instance #5 (re-application) + this H4 instance #6.
- Pattern emerging: "per-action actor triple as universal forensic primitive". Settlements PR #374 introduced create-time triple (`created_by_*`); §ADR-13 amendment F2 ratified create-time triple as architectural rule; this amendment introduces upload-time triple (`slip_uploaded_by_*`); future amendments may introduce approve-time / reject-time / etc. as needed. Worth tracking as candidate-pattern when 3rd action-time triple emerges (would reach durable threshold per W1 §Port-from-mobiz protocol rule 2). Brew-ops handoff candidate when 3rd instance.

Architecture-decision phase status post-this-baseline: 12 ADRs ratified `#decision` + **4 live `#provisional`** (§ADR-14 thread #80, §ADR-13 amendment thread #82, §ADR-16 thread #83, §ADR-4d D1 amendment thread #84). After all 4 ratify: 0 live `#provisional`; full Phase-1 architectural surface ready for implementation kickoff per §11k orchestrator + thread #66 next-dev developer agent.

Threads opened: #84. Threads closed: none. Commit: `a42ea8e`. PR: #26 (stacked on PR #25 → PR #24 → PR #19 → main).

Next pass candidate: ratify all 4 open threads (#80 / #82 / #83 / #84) — combined or sequential. Track 2 thread #84 ratification depends on Track 1 thread #82 ratifying first (F1+F2 patterns must ratify before this amendment's H2+H3+H4 can ratify cleanly).

---
*Added via Oracle Learn*
