---
title: Pullout DestCap changed from single value to random band (mobiz 5ce4596 #323, 20
tags: [technical-writer, repo:mobiz-payment-gateway, current, pullout, destcap, scheduler, random-cap]
created: 2026-04-27
source: services/pulloutDemand.go:157-182@5ce4596
project: github.com/kokarat/mobiz-payment-gateway
---

# Pullout DestCap changed from single value to random band (mobiz 5ce4596 #323, 20

Pullout DestCap changed from single value to random band (mobiz 5ce4596 #323, 2026-04-27). Settings: pullout_refill_dest_cap_min (default 100,000) and pullout_refill_dest_cap_max (default 120,000). PickRandomDestCap(min, max) draws a cap rounded to nearest 100 THB on every pullout decision. When min==max the function returns min exactly (backward-compatible for operators with only the legacy single setting). Cap applies only to IsPayoutDest() destinations. Operator motivation: prevent perfectly round balance totals (e.g. always 100,000) from appearing suspicious on bank statements.

---
*Added via Oracle Learn*
