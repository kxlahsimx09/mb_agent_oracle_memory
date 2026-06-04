---
title: Deposit timer model (next-system / mobiz-payment-gateway): the deposit lane runs
tags: [deposit-lane, scheduler, slip-escalation, auto-expire, thunder-verify, adr-4c, adr-4d, two-sweep, guaranteed-producer, deptimer]
created: 2026-06-01
source: next-architect / campaign deptimer (user GO 2026-06-01)
project: github.com/kokarat/mobiz-payment-gateway
---

# Deposit timer model (next-system / mobiz-payment-gateway): the deposit lane runs

Deposit timer model (next-system / mobiz-payment-gateway): the deposit lane runs TWO independent scheduler sweeps cleanly separated by slip-presence — do NOT conflate them into one sweep. (A) EXPIRE sweep = slip-LESS only: a pending deposit with no uploaded slip → 'expired' at created_at + per-client expired_deposit_time; fires deposit.expired (current `processExpiredDeposits`, filter $or:[{slip_image:""},{slip_image:{$exists:false}}]). (B) SLIP-ESCALATION sweep = slip-BEARING only: a pending deposit WITH a slip NEVER expires; at slip_uploaded_at + slip_review_timeout_minutes (operator app_settings, DEFAULT 5 MIN, tunable) it flips pending→checking AND queues Thunder-verify in one tick (current `processSlipEscalation` sets status='checking' + slip_verify_status='queued'; `processSlipVerify` runs Thunder afterward). KEY INVARIANT: the flip-to-checking is the GUARANTEED, no-verdict-safe producer of 'checking' — it fires at the escalation tick regardless of any Thunder verdict; Thunder is informational, queued AFTER. Anti-pattern (reverted by campaign deptimer, ADR §ADR-4c/§ADR-4d §Amendment 2026-06-01): putting the slip-bearing→checking escalation INSIDE the expire sweep anchored on expires_at, and framing the threshold as "hard 15 min from creation" / the flip as a Thunder-verdict-driven event (VF1). Correct anchor is slip_uploaded_at (not created_at/expires_at); correct flip is unconditional at the escalation tick (not gated on Thunder genuine/forged). Because slip-bearing deposits are excluded from expiry entirely, the "deadline shorter than threshold" race is moot. D4 invariant (Thunder informational; admin owns paid+failed terminals) is orthogonal and stays unchanged.

---
*Added via Oracle Learn*
