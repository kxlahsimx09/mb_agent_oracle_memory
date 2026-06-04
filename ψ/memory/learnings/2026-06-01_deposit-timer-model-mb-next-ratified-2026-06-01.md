---
title: Deposit timer model (mb-next, ratified 2026-06-01 user GO — "deptimer" revision,
tags: [deposit, timer, slip-escalation, expire-sweep, thunder, mb-next, requirements, epic, adr]
created: 2026-06-01
source: next-writer (deptimer-epic campaign)
project: github.com/kokarat/mobiz-payment-gateway
---

# Deposit timer model (mb-next, ratified 2026-06-01 user GO — "deptimer" revision,

Deposit timer model (mb-next, ratified 2026-06-01 user GO — "deptimer" revision, restores current-mobiz): TWO cleanly-separated background sweeps split by SLIP-PRESENCE, never overlap.
(A) EXPIRE sweep — slip-LESS only: a pending deposit with NO uploaded slip flips to `expired` at its deadline (created + per-client `expired_deposit_time`, per-client config) and fires `deposit.expired`.
(B) SLIP-ESCALATION sweep — slip-BEARING only: a pending deposit WITH an uploaded slip NEVER expires (excluded from the expire sweep by the slip-absent predicate). At `slip_uploaded_at + slip_review_timeout_minutes` (operator server config, DEFAULT 5 MIN, tunable later — NOT 15-min-from-creation, NOT the deadline) it flips `pending → checking` (admin-review lane) AND queues Thunder-verify together in ONE tick. The `pending → checking` flip is the GUARANTEED no-verdict-safe producer: it fires on the timer regardless of Thunder's verdict, so a slip-bearing deposit always reaches `checking` even on a no-verdict event (`thunder_system_error` / `thunder_timeout`). Thunder runs as the deferred verify on the now-`checking` deposit; verdict is informational, admin owns the terminal.

This SUPERSEDES the interim depfix #300 "§ADR-4c expire-sweep escalation arm" framing (which flipped slip-bearing → checking at the DEADLINE). The deadline never touches a slip-bearing deposit. Verdict-only-flip (§ADR-4d §VF1–VF7) now applies ONLY to the on-demand verify-slip-now path (DEPOSIT-008), not the automatic sweep.

Ground truth: `scheduler/deposit_expiry.go` `processSlipEscalation` — `GetAppSettingInt("slip_review_timeout_minutes", 5)`, `slip_uploaded_at` cutoff, atomic update `status → checking` + `slip_verify_status → queued`; filter `status=pending, slip_image != "", slip_uploaded_at <= cutoff`. Epic wording in `docs/requirements/epic-deposit.md` DEPOSIT-003/004/008; ADR in §ADR-4c/§ADR-4d.

Writer/architect split lesson: when a timer/model wording lives in BOTH the epic (requirements) and adr.md, the writer revises the epic and CITES the ADR revision as "pending on <arch branch>" rather than editing adr.md — the architect owns adr.md in parallel. Keeps the two PRs non-conflicting.

---
*Added via Oracle Learn*
