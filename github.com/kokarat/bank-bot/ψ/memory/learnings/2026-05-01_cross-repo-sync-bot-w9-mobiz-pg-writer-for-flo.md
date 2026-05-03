---
title: Cross-repo sync (bot W9 → mobiz pg-writer) for flow-drift surfaced by bank-bot P
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, cross-repo-sync, flow-drift, flow-track, flow:scb-dual-control-withdrawal, scb, balance-mapping, pg-writer-handoff]
created: 2026-05-01
source: docs/flows/scb-dual-control-withdrawal.md@HEAD + sibling mobiz docs/flows/payout-request.md
project: github.com/kokarat/bank-bot
---

# Cross-repo sync (bot W9 → mobiz pg-writer) for flow-drift surfaced by bank-bot P

Cross-repo sync (bot W9 → mobiz pg-writer) for flow-drift surfaced by bank-bot PR #110 (commit 20289a3, 2026-04-30). The SCB→backend balance mapping swap (backend `balance` ← SCB cash-available, `available_balance` ← SCB account-total) does not change the wire format but inverts the field semantics for SCB banks only (KTB unchanged). Mobiz flow doc that explicitly cites these field semantics: `mobiz/docs/flows/payout-request.md` lines 26 (preconditions: `non-zero available_balance` + headroom check), 62 (postconditions: `system_banks.balance` and `available_balance` both decremented by amount), 91 (success postcondition: same fields). The flow's claims about "decrement both fields by amount" remain correct (the wire format absorbs the same value either way) but the **operator-facing meaning** of which physical SCB number sits in which slot has flipped, and the dispatcher's `bank.AvailableBalance` headroom comparison now reads SCB's account total (less conservative). Mobiz W9 cannot detect this drift directly — bot's `// ext: kokarat/bank-bot` markers in mobiz flows are opaque. This learning is the channel. Bot W9 trace: 01a64ce4-239a-4591-bfb8-22aa05101d99. Mobiz sibling already filed the reciprocal `#cross-repo-sync` learning today (`2026-05-01_cross-repo-sync-mobiz-e1496a2-345-destcap-effe`) describing how mobiz `services/pulloutDemand.go EffectiveDestBalance` defensively reads `max(Balance, AvailableBalance)` to absorb the swap on the DestCap guard side. Action item for pg-writer's next pass: confirm whether `payout-request.md` §Preconditions / §Postconditions / §Implementation pointers should add a side-note ("for SCB banks post-2026-04-30, `available_balance` reflects ยอดเงินในบัญชี (account total) and `balance` reflects ยอดเงินสดที่ใช้ได้ (cash available); for KTB banks both reflect KTB's own labels — see bank-bot `banks/scb/dashboard.js@20289a3` and `banks/ktb/dashboard.js§unchanged`"). Sibling mobiz W2 trace: 5900d287-20a2-4883-bef1-55e52e74c857.

---
*Added via Oracle Learn*
