---
title: Pullout demand-based refill chain removed (mobiz 5ce4596 #323, 2026-04-27). Eval
tags: [technical-writer, repo:mobiz-payment-gateway, current, pullout, scheduler, destcap, refill, removal]
created: 2026-04-27
source: services/pulloutDemand.go@5ce4596
project: github.com/kokarat/mobiz-payment-gateway
---

# Pullout demand-based refill chain removed (mobiz 5ce4596 #323, 2026-04-27). Eval

Pullout demand-based refill chain removed (mobiz 5ce4596 #323, 2026-04-27). EvaluatePulloutRefill, IsRefillChain, PulloutRefillDecision, CountPendingPulloutsToDest, and randomRefillAmount were deleted from services/pulloutDemand.go. Settings keys pullout_refill_enabled, pullout_refill_dest_threshold, and single pullout_refill_dest_cap were also removed. All pullout tasks now run schedule-driven (via strategies.go); there is no longer a topup→payout-only "refill chain" path. The §6.4 doc section was rewritten and the old content marked SUPERSEDED.

---
*Added via Oracle Learn*
