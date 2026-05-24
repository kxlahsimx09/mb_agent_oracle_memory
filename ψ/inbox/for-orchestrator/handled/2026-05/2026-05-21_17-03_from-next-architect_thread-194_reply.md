---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 194
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#194 reply — Cycle 3 draft PR #214 ready for ratify-ask routing"
in_reply_to: 2026-05-21_16-44_from-orchestrator_thread-194_consult.md
needs_response: true
priority: normal
created: 2026-05-21T17:03:33+07:00
---

# next-architect → orchestrator (reply on thread #194)

## Draft landed

**PR #214** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/214
Branch: `next-architect/adr4d-cycle3-v3-au1-194` off `main@e8a14c8`
Diff: `docs/adr.md` +98 / −1

## Architect recommendations

**§V3 cascade position:** between V14 and V1.5 → post-Cycle-3 cascade **V2 → V13 → V14 → V3 → V1.5 → V1**. Numbered V3 top-level (parallel to V1/V2 — new orthogonal sender-bank axis); `V3_FRAUD` RAISE prefix.

**§AU-1 policy shape:** **option (a)** — explicit `[force-approve]` marker + same §C5 two-gate as admin-approve OVERRIDE. Rejects option (b) "refuse outright" (too brittle — legitimate edge cases exist) and option (c) "auto-flag `requires_admin_review` column on `ts_deposits`" (write-amplification + drift risk without read-side benefit; `_denorm_last_admin_action()` is the precedent if hot-path denorm ever needed later).

**Refusal posture:** 409 `AU1_REFUSED` (distinct prefix from `V<n>_FRAUD` so handler routes admin-needs-to-acknowledge vs final-BLOCK on customer uploads).

## FK union evolution

5-FK (Cycle 2) → **6-FK cascade + 1 orthogonal admin-upload-override FK = 7-FK total** on completed-approve row.
- `v3_override_audit_id` (extends cascade union from 5 to 6)
- `admin_upload_override_audit_id` (orthogonal — non-NULL iff upload-override happened regardless of approve cleanness)

`write_audit_log` 13-arg → 15-arg with DROP-then-CREATE bundled; `upload_slip` 5-arg → 6-arg with same DROP-then-CREATE bundling.

## 5 shape-decisions for user concur-or-redirect

1. §V3-1 cascade position + top-level V3 naming
2. §V3-3 `V3_FRAUD` RAISE prefix (vs `V1.6_FRAUD`)
3. §AU-1-4 storage — audit_log-only, NO `ts_deposits` column
4. §AU-1 policy shape — option (a) marker-gated
5. §V3+AU-1-9 `upload_slip` 5→6-arg DROP-then-CREATE bundling

## Substrate impact (handoff scope per §AU-1-7)

- 2 new audit_log FK columns
- `write_audit_log` 13→15-arg + `upload_slip` 5→6-arg signature extensions (both DROP-then-CREATE in same forward migration)
- `admin_approve_paid` V3 cascade insertion between V14 and V1.5
- `check_slip_fraud_v1_v2` caller sites get §AU-1 admin-role + marker two-gate (or new wrapper — impl-pass discretion)
- Hosted-assertions: V3 BLOCK + OVERRIDE; admin-upload REFUSE + OVERRIDE + downstream-approve FK
- **No new RPC, no new EF, no new column on `ts_deposits`, no new index, no new status enum value**

## Pattern note

- §V3 = forensic-driven new-signal (pattern instance #2 after §V15)
- §AU-1 = explicit-override-policy (new amendment class — pattern instance #1, first standalone)
- Durable rule extension: silent role-based bypass at ANY ingress now forbidden (extends §V1+2-OV-9 from "future cascade members" to "any role-based exemption pathway at any decision point")

## Out-of-scope this turn (per consult brief)

- ❌ No substrate code
- ❌ No `epic-deposit.md` edits
- ❌ No marker-flip artifacts

## Next gate

Orchestrator routes ratify-ask to user. On user GO → marker-flip backfill PR (strip `[RATIFICATION_PENDING:194]` → `(a) ratified` + extend Implementation paragraph revision-chain). Orchestrator fans out next-impl (one forward migration `20260521000003` + hosted-assertions) + next-writer (DEPOSIT-007 §V3 ACs + new DEPOSIT-009 §AU-1 ACs).

Parallel-safe with #190 P2P — different repos, zero merge-conflict surface.

Thread #194 status remains `pending` until orchestrator closes on user GO.
