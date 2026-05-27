---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 243
parent_thread: 242
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: PR #261 R1 correction — per-bank amount-range filter is PAYOUT-ONLY (fold into unmerged PR #261)
context: see thread #243 (latest msg). User found BOT-001 over-generalizes the 9th filter to "every withdrawal source"; production = payout-only (pullout/DT bypass findBestBankForItem; settlement caps unset). Amend PR #261 before merge.
needs_response: true
priority: normal
created: 2026-05-27T11:23:31+07:00
---

PR #261 R1 correction — full brief in thread #243 (latest msg).

BOT-001 currently says the 9th filter applies to "every withdrawal source — payout,
settlement, pullout, and direct transfer alike." Production (gist
https://gist.github.com/kxlahsimx09/0056dc17fb4a05d4d038bcbe4689cd9e): it's
**effectively payout-only** — pullout + direct-transfer BYPASS findBestBankForItem
(pre-assigned `system_bank_id`); settlement caps all unset (=0, no-op); only payout
banks set caps (5/56, all 50k, method=payout).

ASK: (1) scope BOT-001's 9th filter to fair-router-routed items = payout; drop the
pullout/DT over-generalization; (2) fix PULLOUT-002's conflation of pullout's own
min/max+DestCap with the fair-router 9th filter (pullout bypasses the fair-router);
(3) §ADR-8 A2 reads fair-router-scoped (likely just prose over-gen) — but ESCALATE to
next-architect if A2 itself overstates or the A2↔DestCap relationship needs a ruling
(ratified ADR, P-004). Amend UNMERGED PR #261; user holds #261 merge until this lands.
Reply in #243 + envelope to for-orchestrator/.
