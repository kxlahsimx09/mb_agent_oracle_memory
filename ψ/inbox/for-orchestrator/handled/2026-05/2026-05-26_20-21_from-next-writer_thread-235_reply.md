---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: progress
thread: 235
parent_thread: 234
parent_oracle: orchestrator
subject: Cleanup DONE — PR #255 (AUTH-006 only); #120 + #132 already reconciled on main (verified)
needs_response: false
priority: normal
created: 2026-05-26T20:21:00+07:00
handled_at: 2026-05-26T20:25:00+07:00
handled_by_thread: 234
handled_note: Cleanup sub #235 done — PR #255 (AUTH-006 only; #120/#132 already on main, verified). Relayed to #234 (msg 1078). type=progress, needs_response=false — no reply envelope. Aggregate held for sub #236 (next-architect #233).
---

Refresh-on-amendment cleanup (thread #235 / campaign #234) DONE — **PR #255** (`writer/auth-006-rate-limit-client-002-xref` → main, off aec4a39). Do-not-merge-without-user.

Per P-004 I verified each of the three named touches against HEAD before editing. **Only one was genuinely open** — the deferred batch collapses to a single real edit.

**AUTH-006 — EDITED.** The edge case still read *"current-system config, not a ratified contract yet"* + `[open question … flagged to architect sub-thread #229]`. A3 is ratified (§ADR-11 §Amendment 2026-05-26 RL1–RL4), homed as CLIENT-002; thread #229 `closed`. Flipped to the ratified state — limit *is* a client-API contract (per-client/per-scope/dual-window, fail-open), cap numbers stay impl/baseline (RL4), DB-counter-no-external-cache preserved (§ADR-7) — and cross-referenced CLIENT-002 as the home. Replaced the closed-#229 anchor with a `new:req` CLIENT-002 Sources line + the §ADR-11 §Amendment 2026-05-26 (A3) line. (This closes the flag you logged in the #230 pass-2 envelope, line 29.)

**#120 → PAYOUT-003 `rejected` — ALREADY DONE (no edit).** Resolved on main in commit `c00a745`: epic-payout.md Open-questions — *"no separate `rejected` payout terminal; `failed` is the sole unsuccessful-payout terminal … §ADR-9 §Amendment 2026-05-16 (thread #120 verdict)."*

**#132 → PAYOUT-004/009 review-callback — ALREADY DONE (no edit).** Swept on main in commit `e4ee2d8`: `review` callback-silent across PAYOUT-004 (CS1/CS3 §ADR-9 §Reconciliation 2026-05-16, thread #132), PAYOUT-009, the PAYOUT-006 resend edge case, and epic-callback-delivery.md (`payout.rejected` withdrawn). Full requirements-dir sweep clean. (`epic-payout.md:94`'s `waiting_to_review` is verbatim `#current` production data — correct, not stale.)

Honored the separation from #233 (settlement / AUTH-007, next-architect) — not touched.

Detail in thread #235 (msg 1076). Learning: `2026-05-26_refresh-on-amendment-thread-235-campaign-234` (durable: a "deferred" dispatch list can go stale between flagging and execution — verify each touch against HEAD before authoring; report already-done items honestly rather than fabricate an edit to match the brief).
