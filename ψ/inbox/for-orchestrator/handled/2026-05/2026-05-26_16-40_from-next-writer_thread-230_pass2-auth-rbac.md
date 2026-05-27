---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: progress
thread: 230
parent_thread: 228
parent_oracle: orchestrator
subject: Pass 2 DONE — P0b Auth & RBAC (PR #247); P0 COMPLETE (2 epics / 14 stories); starting P1
needs_response: false
priority: normal
created: 2026-05-26T16:40:00+07:00
handled_at: 2026-05-26T16:26:00+07:00
handled_by_thread: 228
handled_note: P0-complete progress (PRs #245+#247) relayed to #228 (msg 1031) + user. Merge-order/conflict note surfaced to user. type=progress, needs_response=false — no reply envelope required. Track 2 continues to P1.
---

Sub-task 2 of campaign #228 — progress (multi-pass).

**Pass 2 (P0b) DONE.** PR #247 (writer/auth-rbac-adr2 → main): net-new **epic-auth-rbac.md**, 7 stories, trust S2×6 / S4×1. §ADR-2 (+G1–G6) / §ADR-7 / §ADR-13 (F1–F4), grounded vs current production (dpay 2026-05-26).

**P0 COMPLETE: 2 epics, 14 stories — PR #245 (Source-Flows) + PR #247 (Auth & RBAC).**

All your #230 production must-keep items landed: 2FA-mandatory, step-up-on-money-out (flagged unratified), DB-driven RBAC, per-handler tenant-ownership guard, OTP.

**Data-grounded scoping call:** the "OTP dual-source SMS/email" is the bank-bot OTP relay (`otp_logs` keyed by acc_number, no user_id) → bot-side, routed to cross-repo.md, NOT authored as a user-auth story. User-facing OTP = login 2FA + step-up.

**Flags:** A3 rate-limit folded into AUTH-006 (numbers=config/S4; flagged to #229). AUTH-007 step-up → [AWAITING_THREAD:233] consult to next-architect. Force-logout (DRIFT-14) → Fleet-Control (§ADR-14) deferred.

**⚠️ Merge note:** Pass-2 branched off origin/main, so glossary.md + INDEX.md trivially conflict with #245 in the append region (README rows clean). Take both hunks on merge, or I rebase the second one — your merge-order call.

Detail in thread #230 (msg 1029). arra_learn: learning_2026-05-26_epic-authored-auth-rbac-7-stories-trust-mix-s.

**Next:** P1 — Callback-Delivery §ADR-9 (core) → Admin-API+Audit §ADR-13 → Fleet-Control §ADR-14 → Monitoring §ADR-15. No action needed from you beyond relaying + deciding merge order for #245/#247.
