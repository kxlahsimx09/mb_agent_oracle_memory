---
title: W1 amendment ratify pass — §ADR-4a payout auto-cancel pending timeout (PA1-PA5; 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-4a, payout-auto-cancel-pending-timeout, v-payouts-view-contract, thread-105-closed, cross-repo-code-verification-handoff-instance-1-NEW, symmetric-lane-pattern-port-instance-1-NEW, framing-correction-via-user-domain-knowledge-instance-1-NEW, feature-flag-default-off, deliberate-non-symmetry-global-vs-per-client, port-from-working-flow, trace-chain-38-links, pr:113]
created: 2026-05-16
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratify pass — §ADR-4a payout auto-cancel pending timeout (PA1-PA5; 

W1 amendment ratify pass — §ADR-4a payout auto-cancel pending timeout (PA1-PA5; thread #105 closed). Payout-lane mirror of §ADR-4c deposit auto-expire.

# Pass shape

Combined baseline + ratify landing — instance #9 (continuing durable). Single-commit landing on clean-from-main branch.

# Decision

PROMOTE payout auto-cancel. §ADR-4a §Amendment 2026-05-15 — PA1-PA5:
- PA1: feature flag `payout_auto_cancel_enabled` default OFF, fail-closed
- PA2: `v_payouts` view, flag-aware `effective_status` CASE — 0-lag cancelled visibility (mirror §ADR-4c D10 `v_deposits`; flag-aware divergence)
- PA3: pg_cron 1-min sweep + `cancel_stale_payout` atomic RPC (CAS-flip + wallet unfreeze + queue cancel + callback); lag profile status 0-lag / wallet-unfreeze ≤60s conservative-safe / callback ≤60s
- PA4: write-path race-guard (refuse effectively-cancelled payouts)
- PA5: timeout global config default 15 min (deliberate non-symmetry with deposit per-client TTL)
- PA6: considered + dropped (maintenance-window backstop)

# Framing correction (load-bearing)

Writer thread #105 framed gap as "money-safety, frozen-funds indefinitely." User domain knowledge corrected: mobiz `maintenance_cancel.go` per-window bulk-cancel runs every evening → frozen funds bounded ~daily, never indefinite. Reframed: per-age auto-cancel = refund-latency optimization (~15 min vs ~daily) + deposit-lane symmetry, NOT money-safety-critical.

→ This correction justified dropping PA6 (§ADR-15 alert) — no indefinite-lockup case to alert on.

# NEW patterns

## Cross-repo code-verification handoff — instance #1 NEW

next-architect cannot read mobiz Go source (not in next-system repo). When an architecture decision depends on current-system CODE LOGIC (not just current-system data), open an arra thread to the current-system code authority (pg-writer) for code-level verification.

Thread #106: next-architect → pg-writer, verify whether per-age payout auto-cancel is dead-by-bug or dormant-by-flag. pg-writer answered against mobiz HEAD cf3e02f: dormant-by-flag, mechanism sound.

Distinct from production-MCP verification (reads data, not code). Brew-ops handoff candidate at instance #2.

## Symmetric-lane-pattern-port — instance #1 NEW

PA2 ports §ADR-4c `v_deposits` view-contract to payout lane as `v_payouts`. When two lanes (deposit/payout) have structurally-mirrored flows, porting a ratified pattern is low-risk + high-coherence. Deliberate divergence (flag-aware CASE vs §ADR-4c unconditional CASE) is principled — forced by a real difference (payout has feature flag; deposit-expiry core always-on).

## Framing-correction-via-user-domain-knowledge — instance #1 NEW

Writer framing over-stated severity ("money-safety indefinitely") because writer lacked operational context (maintenance-window runs every evening). User domain knowledge corrected it. Architect should hold writer framing loosely until user-domain-knowledge confirms/corrects.

Related to "production-audit-corrects-writer-framing" (thread #100) but correcting input is user operational knowledge, not production data.

# Coherence resolution — flag-aware view CASE

The one genuine tension: user wanted (a) view-based 0-lag visibility (§ADR-4c symmetry) AND (b) feature flag default-OFF. These compose awkwardly — if view CASE is unconditional (like §ADR-4c), it would show `cancelled` even when feature disabled (incoherent).

Resolution: view CASE is flag-aware. `CASE WHEN cfg.auto_cancel_enabled AND status='pending' AND past_timeout THEN 'cancelled' ELSE status END`. Config via cheap 1-row CROSS JOIN. Flag OFF → raw pending; flag ON → effective cancelled 0-lag. Coherent both states.

# Lag-profile explicitness

PA3 documents 3 lag surfaces with safety direction each:
- payout status visibility: 0-lag (view)
- wallet.frozen unfreeze: ≤60s sweep-bound — conservative-safe (available shows lower not higher → no over-spend)
- callback emission: ≤60s sweep-bound

Architect-discipline: when sweep-based mechanism has multiple effects with different lag bounds, enumerate each + state safety direction.

# Deliberate non-symmetry PA5

Payout timeout = global; deposit TTL = per-client. Semantically grounded (thread #104 reasoning): deposit TTL = end-user-behavior (per-client); payout timeout = pool-routing-capacity (shared system → global). `clients` schema has no per-client payout-timeout field — confirms mobiz's global choice deliberate.

# User dialogue trajectory (2026-05-15 → 2026-05-16)

- Writer thread #105 surfaces gap; architect verifies dpay MCP (per-age scheduler dormant; flag false)
- User asks per-client-vs-global → architect verifies clients schema → SQ1 global
- User doubts flag=false reflects reality → architect opens thread #106 to pg-writer
- pg-writer confirms dormant-by-flag not dead-by-bug
- User recognizes observed auto-cancel = maintenance windows
- User directs symmetric §ADR-4c view-column + callback only delayed + flag default-OFF
- Architect surfaces flag-OFF-vs-view tension → resolves flag-aware CASE
- User drops PA6 (maintenance-window backstop) → "จัดไปครับ"

User-pushback-as-design-force pattern instance #37 — user drove 3 corrections (per-client scope / flag-state skepticism → pg-writer verification / reframe money-safety→latency-optimization). Pre-Input-5 instance count: 26 → 27.

# Architecture-decision phase status

19 ADRs/amendments `#decision`; 0 live `#provisional`. Trace chain extends 37 → 38 links (longest in repo).

# Handoffs

next-writer: author PAYOUT-008 (mirror DEPOSIT-003); finalize PAYOUT-001 pool-scoping edge case.
poc-implement: v_payouts view + flag-aware CASE + payout_cancel_config materialization + cancel_stale_payout RPC + pg_cron sweep + write-path race-guard.

# Sources

- thread:#105 (writer-flagged epic-payout gap) + thread:#106 (pg-writer code verification mobiz HEAD cf3e02f)
- dpay MCP 2026-05-15: app_settings payout keys; clients schema (no per-client payout timeout); wallets_change_logs payout_refund by changed_by
- §ADR-4c D10 v_deposits view-contract (PA2 mirror) + D2 sweep cadence
- §ADR-9 §Bundle TS2 (payout.cancelled + auto_cancelled — pre-ratified thread #95)
- §ADR-10 AM2 (freeze-settle unfreeze) + AM4 (payout_unfreeze op — pre-ratified thread #96)
- thread #104 (per-client-vs-global scope reasoning)
- mobiz flow payout-auto-cancel-pending-timeout (mobiz thread #31); mobiz code scheduler/payout_expiry.go (pg-writer verified)

# Commit anchor

`ff85784` (amendment combined-landing on branch architect/w1-adr4a-amendment-payout-auto-cancel-2026-05-15). PR #113 merged via `d71b847`.

---
*Added via Oracle Learn*
