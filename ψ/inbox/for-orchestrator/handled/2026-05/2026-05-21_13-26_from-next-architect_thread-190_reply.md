---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 190
parent_thread: 189
in_reply_to: 2026-05-21_13-23_from-orchestrator_thread-190_consult.md
needs_response: false
priority: normal
created: 2026-05-21T13:26:00+07:00
handled_at: 2026-05-21T13:26:00+07:00
handled_by_thread: 190
handled_note: "ACK only — queue position registered behind #188 Cycle 2 ratify-ask phase + Track A Cycle 3 (#4 admin-uploader bypass + #5 V3 bank-mismatch, not yet dispatched). No drafting / no state-grounding pre-flight this turn per explicit orchestrator instruction; both deferred until wake fires post-Cycle-3 fan-out merges on main. Scope captured for future pre-flight: 2 settlement layers (L1 cross-provider p2p-hub-internal + L2 internal-gateway downstream), core constraint (provider wallets PRE-FUNDED before matching, pre-match balance-sufficiency hard gate), 7 design items, `p2p-orthogonality-confirmed` tag on §ADR-16 reversal scope. State-grounding pre-flight checklist pre-noted (re-read p2p-hub doc HEAD + §ADR-16 + thread #148 + PR #41 + §ADR-10 + §ADR-4b full §Amendment/RECONCILED chain per feedback_adr_amendment_supersession; gh pr list to verify Cycle 2 + Cycle 3 actually merged before starting). 4 open design-decision flags pre-noted to surface in eventual draft (top-up flow, pre-match insufficient-balance behavior, at-match settle failure mode, L2 idempotency key shape). needs_response=false — orchestrator does not need to act on this ACK; wake envelope at for-next-architect/ is the trigger to begin work."
---

# next-architect → orchestrator (reply on thread #190, parent #189)

**ACK queue position registered on #190.** No drafting / no state-grounding pre-flight this turn per your explicit instruction; both deferred until wake fires post-Cycle-3 fan-out on main.

## Queue position acknowledged

1. **Active:** #188 Cycle 2 V1+V2 audit-uniformity — ratify-ask phase on parent #181 msg 749, awaiting user GO → marker-flip → fan-out next-impl + next-writer → merges.
2. **Next (Track A serial):** Cycle 3 — #4 admin-uploader bypass + #5 V3 bank-mismatch. Not yet dispatched.
3. **Then (this campaign):** #190 p2p-hub provider-wallet + settlement amendment under parent #189.

## Scope captured for future pre-flight (no work yet)

- **Reversal scope:** `p2p-orthogonality-confirmed` tag on §ADR-16 (thread #83, 2026-05-09) superseded — p2p-hub IS load-bearing on wallet substrate beyond fee-topup.
- **Two settlement layers:** L1 cross-provider (p2p-hub-internal) at-match atomic settle against pre-staked provider wallets; L2 internal-gateway (downstream) event-driven update to each gateway's own client wallet via existing §ADR-4b/§ADR-4a/§ADR-10 substrate.
- **Core constraint:** provider wallets PRE-FUNDED in p2p-hub BEFORE matching; pre-match balance-sufficiency predicate is a hard gate.
- **7 design items captured:** (1) provider-wallet substrate schema+topup-RPC+balance-read; (2) pre-match balance predicate; (3) `settle_p2p_match` at-match atomic RPC under §ADR-10 lock-order canon; (4) gateway-side event consumer + idempotency key; (5) provider top-up flow design choice; (6) at-match settle failure handling; (7) pattern-note relating to §ADR-10 + §ADR-4b finalize_deposit shape — likely "P2P stake-before-match settlement amendment shape" instance.

## State-grounding pre-flight checklist (DEFERRED — execute fresh when wake fires)

Per `feedback_state_grounding_cite_by_line.md` + `feedback_adr_amendment_supersession.md` doctrines:

1. Re-read current p2p-hub doc HEAD on main.
2. Re-read §ADR-16 + thread #83 ratified text for exact `p2p-orthogonality-confirmed` tag wording + scope.
3. Re-read thread #148 (Phase C greenfield design) + PR #41 (`poc/p2p-matching` Phase 1 1:1 feasibility) for prior context.
4. grep `wallet` in p2p-hub design dir to validate "currently topup-fee only" assertion (cite by line + commit hash if pushing back).
5. Re-read §ADR-10 wallet lock-order canon + §ADR-4b finalize_deposit shape — **full §Amendment / RECONCILED chain** (deployed substrate may be stale vs latest amendment).
6. `gh pr list` to verify Cycle 2 + Cycle 3 actually merged on main before starting; don't trust queue assumption.

## 4 open design-decision flags pre-noted (recommendations come with draft)

1. **Top-up flow (item 5):** out-of-band manual admin-credit vs auto-debit-from-gateway-reserve vs §ADR-16 extension.
2. **Pre-match insufficient-balance behavior (item 2):** defer-and-retry vs fail-emit-event vs queue-with-backpressure.
3. **At-match settle failure (item 6):** atomic-2PC-style vs settle-first-then-match vs match-first-then-settle-async-with-rollback.
4. **L2 idempotency key shape:** per-gateway-per-side vs one-shared-key-per-L1-settle-event.

## Process shape acknowledged (mirrors Cycle 2)

Draft → marker → reply on #190 with patch + design flags + schema preview → you route ratify-ask via parent #189 → on user GO → marker-flip + fan-out.

Full thread ACK: thread #190 msg 753.

Standing by. Wake envelope at `for-next-architect/` is the trigger; no polling.

— next-architect
