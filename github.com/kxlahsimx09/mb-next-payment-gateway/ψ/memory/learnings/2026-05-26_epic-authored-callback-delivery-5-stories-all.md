---
title: epic authored — callback-delivery — 5 stories, all S2.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, callback-delivery, callback, webhook, s2-ratified, campaign-228, thread-230]
created: 2026-05-26
source: docs/requirements/epic-callback-delivery.md@writer/callback-delivery-adr9
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — callback-delivery — 5 stories, all S2.

epic authored — callback-delivery — 5 stories, all S2.

Subsystem: callback-delivery (the automatic webhook delivery engine)
Net-new epic from campaign #228 / sub-thread #230 (Pass 3, P1 core — the item the orchestrator listed first under P1). Translates §ADR-9 (Callback Dispatcher, #decision thread #56 + amendments #93/#95/#120/#132/#223) into human-readable stories. Grounded vs current production (dpay MCP 2026-05-26).

Stories (all S2):
- CALLBACK-001 at-least-once delivery, hybrid fast-path + safety-net sweep, ~6-attempt backoff → dead-letter, no silent drop, burst-coalesced; review is callback-silent (exactly-one-terminal). §ADR-9 D1/D2/D4/D5 + §Reconciliation 2026-05-16.
- CALLBACK-002 dispatch-time HMAC, Stripe-style X-Maxpay-Signature header (t+v1), HMAC-SHA256 over timestamp.body, 5-min replay window, X-Maxpay-Event-Id dedup, per-attempt re-signature. §ADR-9 D3 + WC1/2/3/8/10.
- CALLBACK-003 preconfigured-endpoint safety (CU1-8): no raw callback_url on create (reject CALLBACK_URL_NOT_ALLOWED), per-client/per-flow HTTPS-only config, create-time snapshot, dispatch-time DNS-rebind re-check, dynamic context → signed payload. §ADR-9 §Amendment 2026-05-25.
- CALLBACK-004 terminal-state taxonomy + payload: deposit paid/expired/rejected/failed; payout success/failed/cancelled (NO payout.rejected — deliberate asymmetry per RC1/RC2); WC4-7 universal fields + camelCase + ISO8601-Z + failureCode/Message + clientReferenceId/metadata echo.
- CALLBACK-005 append-only callback_attempts + denormalized parent counter; dead-letter operator-recoverable; resend=append-not-destructive (AM4); cross-ref DEPOSIT-012/PAYOUT-007 manual resend (NOT re-authored).

Production grounding (dpay 2026-05-26): callback_logs=1,513,205 append-per-attempt rows; event dist deposit.paid 1.08M/payout.success 279k/deposit.expired 140k/payout.failed 9.4k/payout.cancelled 4.6k/deposit.failed 1.7k validates taxonomy. NO signature stored today (body had it; next-system header is the gap-fix). clients have NO callback_url field (0/109) → 100% per-request URL today; next-system diverges to preconfigured. callback_sent + callback_attempts on transactions (deposit max observed 47 attempts); NO dead-letter field. paidAt=Z vs completedAt=+07:00 drift WC6 fixes.

Scoping: manual resend NOT re-authored (already DEPOSIT-012/PAYOUT-007); cross-referenced. Delivery is gateway→client only (no bank-bot).

Downstream-handoff flags surfaced by §ADR-9 amendments (existing-epic REFRESH work, workflow-3, NOT this net-new pass — flag to orchestrator): (a) thread #223 CU* → DEPOSIT-001 + PAYOUT-001 must drop callback_url from create ACs + require preconfigured snapshot; (b) thread #95 → DEPOSIT-004 strip terminal-state-taxonomy AWAITING_THREAD; (c) thread #120 → PAYOUT-003 resolve rejected open-question to "decided against"; (d) thread #132 → sweep PAYOUT-004/009 for review-callback mentions.

Files: docs/requirements/epic-callback-delivery.md (new) + glossary.md (+callback/dead-letter/preconfigured-endpoint) + INDEX.md (+Callback Delivery section) + README.md (+Callback Delivery row after Statement Matching). Mermaid 2/2 PASS; MDX clean.

Stacked-file note: 3rd writer PR off origin/main this session (after #245 source-flows, #247 auth-rbac); glossary.md + INDEX.md append-region overlaps both; README row inserted after Statement-Matching (a row neither #245 nor #247 touched → README clean). Recommend orchestrator pick merge order; one rebase/consolidation pass resolves the trivial glossary/INDEX trailing-anchor conflicts.

---
*Added via Oracle Learn*
