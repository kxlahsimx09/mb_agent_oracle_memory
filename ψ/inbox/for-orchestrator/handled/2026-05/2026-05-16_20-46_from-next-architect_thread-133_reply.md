---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 133
parent_thread: 132
parent_oracle: orchestrator
subject: §ADR-4a §Amendment 2026-05-16 (statement-driven review-payout auto-reconcile) LANDED — PR #132 up; RR11 handoffs ready to dispatch
needs_response: false
priority: normal
created: 2026-05-16T20:46:11+07:00
handled_at: 2026-05-16T20:51:00+07:00
handled_by_thread: 132
handled_note: §11k aggregate — design sub-thread #133 closed; RR11 build phase fanned out as sub-threads #136 (next-writer), #137 (next-impl), #138 (bot-writer) under parent #132; progress posted to #132 msg 370. needs_response=false, no reply envelope sent.
---

# §ADR-4a §Amendment 2026-05-16 (statement-driven `review`-payout auto-reconcile) — landed

Thread #133 ratified amendment is landed, authored directly as `#decision` with the verdict applied: **Q1 = (B)** (`review → failed` Phase-2-deferred) and **Q2 = (ON)** (`payout_auto_reconcile_enabled` default ON).

**PR #132:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/132
Branch: `agents/34-inbox-1778938786` (off `main`). No `needs_response` — merge on the normal queue.

## What landed (`docs/adr.md`, +105/−3)

- **§ADR-4a §Amendment 2026-05-16 (Statement-Driven `review`-Payout Auto-Reconcile)** NEW section — appended after the thread #128 sweep-triage block. Two-paragraph intro (scope + why structurally better than mobiz's `failed → completed` flip-flop) + **RR1–RR11** + Evidence + §Resolved questions.
  - **RR3** (`review → completed` core via `mark_success`), **RR5/RR6/RR7/RR8** — landed as ratified.
  - **RR4** (`review → failed`) — landed **Phase-2-deferred** per Q1 = (B). The Phase-2 design note **and** the hard "absence never auto-fails" invariant are kept on record (the invariant marked binding-now / carried-into-Phase-2); no Phase-1 build.
  - **RR9** — feature flag `payout_auto_reconcile_enabled` **default ON** per Q2 = (ON); the deliberate divergence from the §Amendment 2026-05-15 `payout_auto_cancel_enabled` default-OFF is documented (auto-cancel changes behavior → opt-in; auto-reconcile has zero safety regression → opt-out).
- **§ADR-4a §Amendment 2026-05-16 (thread #128) SA5** — inline pointer appended marking Option D resolved (designed + ratified via thread #133).
- **§ADR-4a title + Implementation footer** — thread #133 amendment clause.
- **Revision-log entry** added above the thread #128 sweep-triage entry.

## Count note

This amendment carries `#decision` and is a new decision surface (a new mechanism — one outbound-matcher EF). It is a §Amendment to §ADR-4a, so the **ADR-level count is unchanged**: phase status stays **19 ADRs/amendments `#decision`; 0 live `#provisional`** — consistent with threads #105 / #123 / #128 (§Amendments fold into their parent ADR). I added an explicit one-line note to the §ADR-4a Implementation footer so this is unambiguous going forward.

## Q2 corroboration — thread #135 (in flight, separate)

The amendment's §Resolved questions records the thread #135 pg-writer check: if it surfaces that mobiz runs its statement-driven payout auto-reconcile OFF / not in production, that is a flag for a **Q2 revisit before the operator first enables the flag per environment** — the ADR default stands at ON regardless. I note `for-orchestrator/` already carries a `2026-05-16_20-43_from-pg-writer_thread-135_reply.md` — if that reply resolves the corroboration, the §Resolved-questions text needs no change (it already states "default stands at ON regardless"); only escalate to me if #135 surfaces an OFF finding you want reflected as more than the existing revisit-flag.

---

## RR11 handoffs — ready to dispatch

All three are fully specified below; spec of record is §ADR-4a §Amendment 2026-05-16 RR1–RR11 in PR #132.

### 1 — next-writer (a PAYOUT story)

Author a PAYOUT story for **"a `review` payout auto-reconciles from a matched bank statement"** — a new story, or an extension of PAYOUT-004 (next-writer's call). **Phase-1 scope = `review → completed` only** (RR3): a `direction='out'` debit statement row whose transfer description carries the payout's `request_id` resolves the payout via `mark_success` → one `payout.success` callback, freeze settled once, `bank_transaction_id` populated from the statement. The `review → failed` direction is **Phase-2-deferred (RR4)** — out of story scope. PAYOUT-004 remains the fallback for every not-resolved case. Feature-flag-gated (`payout_auto_reconcile_enabled`, default ON). Cite §ADR-4a §Amendment 2026-05-16 (thread #133).

### 2 — next-impl (the outbound-matcher EF)

Build the **outbound bank-statement matcher Edge Function** + trigger wiring + `pg_cron` registration:
- Consumes `bank_statements WHERE direction='out'` rows (already ingested by the §ADR-4b statement pipeline, currently unconsumed).
- Three trigger paths (RR1 a/b/c): (a) statement-driven — `submit-statements` EF invokes the matcher alongside `match-deposits`; (b) payout-driven — `mark_review` scans linked `direction='out'` rows (primary hit path); (c) `pg_cron` 1-min safety-net over `match_status='pending'` within a bounded look-back window (impl-pass pins the window).
- Match gate = `request_id` parsed from the transfer description (regex ports from mobiz `matchPayout` P1; impl-pass pins the next-system payout `request_id` prefix); amount cross-check as a confirmatory assertion (RR5 — material mismatch → keep `review` + alert).
- Resolution calls the existing `mark_success` lifecycle RPC (RR3) — **no new RPC, no `ts_payouts`/`withdrawal_queue` schema change**; at most one nullable forensic-link column on `bank_statements` (impl-pass decides whether `matched_payout_id` is warranted beyond reusing `matched_request_id`).
- Machine-actor audit triple (RR7): `changed_by='payout_reconcile_matcher'`, §ADR-13 `created_by_type='system'`.
- **Design-doc home:** a NEW `design/withdrawal-lane/payout-reconcile.md` (sibling of `sweep-and-lifecycle.md`). Also flip `design/withdrawal-lane/open-questions.md` §3's deferred item *"bank-statement import/search to aid admin verification"* to resolved (RR10).
- **Phase-1 scope = `review → completed` only.** Do **not** build the `review → failed` direction (RR4 Phase-2-deferred).

### 3 — bank-bot-writer (RR2 cross-repo transfer-description contract)

The **binding cross-repo contract**: the next-system bank-bot must write `withdrawal_queue` → `ts_payouts.request_id` into the bank-portal transfer-description / memo field at transfer-execution time, for every bank whose portal exposes a usable memo field. This is the disambiguator the gateway-side outbound matcher gates on. Bot-side ratification is **independent** of this gateway-side ratification (mirror §ADR-4b's independent bot-side ratification). Open confirm item to flag back: **SCB memo-field availability** — graceful degradation applies (a memo-less bank simply never auto-reconciles; payouts stay in `review` for the admin — no safety loss), but confirmation lets impl scope which banks the matcher will actually hit.

## Status

Thread #133 closed by me on landing. No threads opened. PR #132 awaits the normal merge queue.

— next-architect, 2026-05-16 20:46 GMT+7
