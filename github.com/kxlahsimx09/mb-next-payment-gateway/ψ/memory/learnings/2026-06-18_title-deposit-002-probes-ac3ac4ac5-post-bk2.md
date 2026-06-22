---
title: title: deposit-002 probes (ac3/ac4/ac5) — post-BK2 paired-key auth wired (mintDe
tags: [next-tester, deposit-002, bbot, paired-key-auth, adr-20-clock, shared-helper-lift]
created: 2026-06-18
source: tests/integration/probes/_flow.ts @ 43d9eb0 ; PR #587
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: deposit-002 probes (ac3/ac4/ac5) — post-BK2 paired-key auth wired (mintDe

title: deposit-002 probes (ac3/ac4/ac5) — post-BK2 paired-key auth wired (mintDestCred lifted to shared _flow.ts; feedStatement tMs now optional → app_now)

tags: [next-tester, repo:mb-next-payment-gateway, next, probe, deposit-002, bbot, evidence, handoff, fixture-source:integration-test]
project: github.com/kxlahsimx09/mb-next-payment-gateway
source: tests/integration/probes/_flow.ts @ 43d9eb0 ; evidence/integration-deposit-slice-*-43d9eb02.json ; PR #587

RESOLVES the follow-up flagged on the d5 learning. Same post-BK2 (#398) gap: deposit-002-ac3/ac4/ac5 fed statements via feedStatement with NO auth → legacy x-bot-secret default → 401 bot_key_missing → no cascade/credit/callback.

FIX (test-only, folded into PR #587 alongside d5):
- LIFTED `mintDestCred(ctx, dest, reason)` from d5/_flow5.ts to the SHARED probes/_flow.ts (d5 now re-exports it: `export { mintDestCred } from "../_flow.ts"`, so d5 probe import sites unchanged). It accepts any object with `systemBankId` — for the deposit flows that IS the bank_account.id makeQrDeposit resolved.
- Made `feedStatement`'s `auth.tMs` OPTIONAL: when omitted it stamps from the stack's `app_now()` at send time. This is the clean fix for the §ADR-20 frozen-clock issue (deposit-002 also clock_sets T0=now+5min) — callers just pass `auth:{cred}` and never have to thread a timestamp; a WC3-window probe can still pin tMs. d5's feedAndCascade still passes explicit tMs and stays 17/17 GREEN (verified no regression).
- Wired: ac3 mints inside finalizeViaStatement (per deposit); ac4 mints ONE cred for the deposit d and threads it across all 5 feeds (the 3-retry dedup + the distinct-pair legs all hit the same account); ac5 mints inside the finalize helper.

RESULT on tester yupsevcrubgprsbujbpu: run-deposit-slice.ts → deposit-002 7/7 PASS (ac3×3, ac4×2, ac5×2). run-deposit-5.ts → 17/17 PASS (no regression from the shared refactor).

PRE-EXISTING, UNRELATED FAIL (not the auth gap): deposit-001-ac1 `row_snapshot_pending_net_callback` FAILs on a callback-endpoint seed mismatch (ts_deposits.callback_url snapshot = example.com/cb-ok vs the probe's expected preconfigured httpbin.org/status/500) — a client_callback_endpoints seed/config drift on the tester stack. deposit-001-ac1 feeds no statement and was untouched; needs a seed reset / fixture refresh (route to seed/config owner), independent of the bbot paired-key work.

---
*Added via Oracle Learn*
