---
title: RATIFICATION (user GO 2026-05-31) — campaign ng2arch FOLLOW-ON items C/D/E final
tags: [ratification, adr-15, adr-10, adr-9, wallet-high-balance, residual-mdr, is_owner-wallet, callback-ssrf, redirect, ng2arch]
created: 2026-05-31
source: next-architect (ng2arch follow-on — user ratification)
---

# RATIFICATION (user GO 2026-05-31) — campaign ng2arch FOLLOW-ON items C/D/E final

RATIFICATION (user GO 2026-05-31) — campaign ng2arch FOLLOW-ON items C/D/E finalized; all 4 sub-decisions matched the architect lean. PRs #294/#295/#296 ready-for-review, NOT merged (user merges). Updates the three prior ng2arch follow-on learnings (which were "pending user GO").

§ADR-15 §Amendment (PR #294, ITEM C): C-s1 = wallet-high-balance alert severity = P2 channel-severity (change-gated + 23h daily-heartbeat); catalog 32→33 (7 P1 + 17 P2 + 9 P3). C-s2 = ops-report cadence = HOURLY (port the current "Hourly Transaction Summary" grouped by merchant; distinct from the unchanged P3 daily 9am digest). MA1/MA2 (class a) + C-s1/C-s2 (class b) all #decision. MONITOR-005 finalized.

§ADR-10 §Amendment (PR #295, ITEM D, MONEY): RM2 = R1 — an un-routable partner MDR share (inactive partner / missing wallet) is credited to the `is_owner` system-residual wallet; the `mdr_skip` row cross-references the residual credit; ledger balances (gross = client-net + Σpartner-credits + residual). RM1 (ledger-balance + audit invariant, class a) + RM2 (class b) both #decision. Closes the MONEY half of the thread-#6 silent-skip drift that §ADR-10 D4 closed only the audit half of. Applies to finalize_deposit + apply_client_topup; deposit lane (WALLET-003/DEPOSIT-002) same rule. TOPUP-002 finalized.

§ADR-9 §Amendment (PR #296, ITEM E, SECURITY): RF1 = (a) DO-NOT-FOLLOW — the callback dispatcher's HTTP client disables auto-redirect; a 3xx is a non-2xx delivery attempt recorded error_code='callback_redirect_blocked' that rides the normal retry/dead-letter path (§ADR-9 Decision #4); the gateway never fetches the Location target. RF2 (class a) + RF1 (class b) both #decision. Closes the redirect-chain SSRF vector CU1-CU8 left open. CALLBACK-003 finalized. DURABLE: outbound-webhook SSRF has three legs — validate-config (CU3), re-resolve-DNS-at-connect (CU6), and do-not-follow-redirect-at-response (RF1); all three required.

All architect leans held across all 9 ng2arch PRs (#291,#292,#294,#295,#296 + provision1). Repo: kxlahsimx09/mb-next-payment-gateway.

---
*Added via Oracle Learn*
