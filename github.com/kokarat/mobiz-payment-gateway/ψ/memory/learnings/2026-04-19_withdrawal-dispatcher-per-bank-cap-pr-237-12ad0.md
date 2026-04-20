---
title: Withdrawal dispatcher per-bank cap (PR #237, 12ad0d5, 2026-04-20) is now chosen 
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, dispatcher, scheduler]
created: 2026-04-19
source: scheduler/withdrawal_dispatcher.go:205-240 + services/withdrawalQueue.go:440-510 @ 12ad0d5
project: github.com/kokarat/mobiz-payment-gateway
---

# Withdrawal dispatcher per-bank cap (PR #237, 12ad0d5, 2026-04-20) is now chosen 

Withdrawal dispatcher per-bank cap (PR #237, 12ad0d5, 2026-04-20) is now chosen once per dispatch round from the global unassigned backlog and applied uniformly to every idle bank — the earlier two-layer randomness (dispatcher random + bot ClaimByBank random) collapsed into this single knob. Tiers: unassigned ≥100 → fixed 5 (drain mode); ≥20 → random 4–5; ≥5 → random 3–4; else random 1–3 (stealth / idle pattern). The bot is a dumb consumer — it claims whatever the dispatcher assigned, still capped at batchSize=5 per ClaimByBank call to match the SCB "Select All" UI batch (services/withdrawalQueue.go:473). Call sites that previously observed "random batch 1–5" on a per-bank basis must be updated; the per-bank observation is now the tier cap, and cross-bank observation is uniform within a round (so two banks idle in the same round receive the same cap, then the dispatcher's best-bank-for-item logic spreads actual items across banks).

---
*Added via Oracle Learn*
