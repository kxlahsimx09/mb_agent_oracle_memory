---
title: Dispatcher tier-table comment aligned with code at `scheduler/withdrawal_dispatc
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, scheduler, drift-resolution]
created: 2026-04-22
source: scheduler/withdrawal_dispatcher.go:218-220@d951641
project: github.com/kokarat/mobiz-payment-gateway
---

# Dispatcher tier-table comment aligned with code at `scheduler/withdrawal_dispatc

Dispatcher tier-table comment aligned with code at `scheduler/withdrawal_dispatcher.go:218-220` (`d951641`, thread #29 bonus ruling, 2026-04-21). Prior comment read `>=20: 3-5 / >=5: 2-4 / else: 1-3 (stealth — idle pattern)` but the code has used `mrand.Intn(2)+4`, `mrand.Intn(3)+3`, `mrand.Intn(5)+1` for weeks — resolving the `2026-04-20_drift-dispatcher-comment-code-mismatch-1-3-vs-1-5` learning. Comment-only, no behaviour change. The earlier "stealth idle" framing was never implemented; aligning comment with code was the right disposition (ratified via thread #29). **Separate drift still open:** DRIFT-12 in `docs/current-system.md` §9 — the per-bank-independent claim at lines 210-211 ("Each bank's cap is picked independently…") is unchanged by this commit; `perBankCap` is still picked once per dispatch tick and applied uniformly to every idle bank. d951641 closed one comment/code mismatch; the other remains.

---
*Added via Oracle Learn*
