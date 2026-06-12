---
title: title: next-tester BS-2 rebind — probe fork on int64 wire shape; deposit suite w
tags: [next-tester, repo:mb-next-payment-gateway, next, probe, bankbot, drift, coverage-gap, handoff]
created: 2026-06-11
source: tests/integration/probes/_flow.ts + probes/bbot/bk-auth.ts @ PR #403 8890764
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: next-tester BS-2 rebind — probe fork on int64 wire shape; deposit suite w

title: next-tester BS-2 rebind — probe fork on int64 wire shape; deposit suite will go loud-STALE at cutover (G-9)

Thread #13 routed note (gateway PR #409 / migration 20260611000200, BS-2 drift fix): the gateway now honors the spec'd statement wire shape — statement_date_bkk int64 YYYYMMDDHHMM intake + int64 4-key cursor output; old drifted pushes (transaction_date_bkk ISO) are rejected bad_statement_date_bkk BY DESIGN. next-tester rebind landed on PR #403 @ 8890764: (1) _flow.ts feedStatement pushes the new shape, ISO→int64 conversion internal, ten deposit call sites untouched; (2) bbot lane gains cursor-int64-echo witness + 2 BS-2 rejection negatives (these need 000200 — fail loudly on a 000100-only stack); (3) wire-vs-column pin: bank_statements GROUND-TRUTH column stays transaction_date_bkk (deposit-slice §2.7) — only the WIRE field is statement_date_bkk; never push the column name. NOT patched: frozen PoC bot-sim main-hosted.ts (P-001, next-impl's) — rejected-by-design post-#409, logged G-8. SURFACED RESIDUAL G-9: feedStatement still defaults to legacy x-bot-secret (dead at BK2 cutover #398) — the ENTIRE deposit regression suite goes loud-STALE on any cut-over stack until its runners mint a bot credential and pass the new auth seam ({cred, tMs} → PAIRED HMAC headers). The deposit-suite breakage after the tester-stack deploy wave is EXPECTED; refit rides the lanes-1-3 re-run. Re-run prerequisite list is now 000100+000110+000200 + 5 EFs + BOT_CRED_ENC_KEY.

tags: next-tester, repo:mb-next-payment-gateway, next, probe, bankbot, bs2, drift, coverage-gap, handoff, fixture-source:repo-flow-doc

---
*Added via Oracle Learn*
