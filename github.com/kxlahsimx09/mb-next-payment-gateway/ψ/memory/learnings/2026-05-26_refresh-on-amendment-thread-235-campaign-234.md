---
title: refresh-on-amendment — thread #235 (campaign #234) — AUTH-006 rate-limit line; #
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, refresh-on-amendment, auth-rbac, client-api, rate-limit, auth-006, client-002, thread-235, campaign-234, s2-ratified, decision, p-004, deferred-list-stale-verify-against-head]
created: 2026-05-26
source: docs/requirements/epic-auth-rbac.md @writer/auth-006-rate-limit-client-002-xref (PR #255)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# refresh-on-amendment — thread #235 (campaign #234) — AUTH-006 rate-limit line; #

refresh-on-amendment — thread #235 (campaign #234) — AUTH-006 rate-limit line; #120/#132 verified already-done.

Deferred cleanup pass flagged at campaign #228 close. Three named touches; per P-004 (file = truth, dispatch list = claim) only ONE was genuinely open.

PR #255 (writer/auth-006-rate-limit-client-002-xref, off main aec4a39) — single edit, AUTH-006 in epic-auth-rbac.md:
- Edge case still said per-client rate-limit was "current-system config, not a ratified contract yet" + inline `[open question … flagged to architect sub-thread #229]`. A3 is ratified (§ADR-11 §Amendment 2026-05-26 RL1–RL4) + homed as CLIENT-002; thread #229 closed. Flipped to ratified state: limit IS a client-API contract (per-client/per-scope/dual-window, fail-open); cap numbers stay impl/baseline (RL4); DB-counter-no-external-cache preserved (§ADR-7). AUTH-006 keeps the machine-auth view, points to CLIENT-002 as home.
- Replaced closed-#229 open-question anchor with a new:req CLIENT-002 cross-ref; added §ADR-11 §Amendment 2026-05-26 (A3) Sources line. W3 meaning-change (open→ratified) is expected; governing amendment + closed thread cited.

ALREADY-DONE (verified against HEAD, no edit):
- #120 PAYOUT-003 `rejected` — resolved at epic-payout.md Open-questions in commit c00a745 ("no separate `rejected` payout terminal; `failed` is sole unsuccessful terminal; §ADR-9 §Amendment 2026-05-16 thread #120 verdict").
- #132 PAYOUT-004/009 review-callback — swept in commit e4ee2d8; `review` callback-silent across PAYOUT-004 (CS1/CS3 §ADR-9 §Reconciliation 2026-05-16 thread #132), PAYOUT-009, PAYOUT-006 resend edge case, and epic-callback-delivery.md (`payout.rejected` withdrawn). Full requirements-dir sweep clean. (epic-payout.md:94 `waiting_to_review` is verbatim #current production data — correct, not stale.)

Durable: a dispatch/campaign "deferred" list can go stale between flagging and execution — earlier merged commits may have already closed items. Verify each named touch against HEAD (git log -S + read the section) before authoring; report already-done items honestly rather than fabricating an edit to match the brief. Companion to [[feedback_adr_amendment_supersession]] (PAYOUT-003 `rejected` withdrawal) + [[feedback_writer_stale_base_main_drift]].

---
*Added via Oracle Learn*
