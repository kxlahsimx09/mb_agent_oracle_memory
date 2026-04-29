---
title: Pullout destination in-flight inbound reservation (mobiz 5ce4596 #323, 2026-04-2
tags: [technical-writer, repo:mobiz-payment-gateway, current, pullout, destcap, race-condition, in-flight-reservation]
created: 2026-04-27
source: services/pulloutDemand.go:78-122@5ce4596
project: github.com/kokarat/mobiz-payment-gateway
---

# Pullout destination in-flight inbound reservation (mobiz 5ce4596 #323, 2026-04-2

Pullout destination in-flight inbound reservation (mobiz 5ce4596 #323, 2026-04-27). SumPendingPulloutAmountsToDest(ctx, destBankCode, destAccountNumber) sums withdrawal_queue.amount for all pending/processing pullout items targeting the same destination account. Effective dest balance = destBank.Balance + inboundPending before comparing to DestCap. This sum-based approach replaced the old count-based CountPendingPulloutsToDest. Motivation: incident PO20260427103956 where two pullouts to the same dest each individually passed the headroom check (reading stale balance) and their combined total exceeded the 100k cap after both settled. The new guard prevents this race across all three write paths (scheduler, manual execute-now, balance trigger).

---
*Added via Oracle Learn*
