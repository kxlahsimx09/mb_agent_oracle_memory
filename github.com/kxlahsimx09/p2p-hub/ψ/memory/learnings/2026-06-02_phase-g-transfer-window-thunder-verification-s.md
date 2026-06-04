---
title: Phase G (transfer-window + thunder verification) SHIPPED + HOSTED-VERIFIED (p2p-
tags: [phase-g, transfer-window, thunder-verification, supabase, hosted-provisioning, pooler, aws-1, repo:p2p-hub, next-impl, settle-gate, fee_refund_charged, seam]
created: 2026-06-02
source: thread #5/#7 ratify — Phase G impl + hosted verify (next-impl, PR #22, 2026-06-02)
project: github.com/kxlahsimx09/p2p-hub
---

# Phase G (transfer-window + thunder verification) SHIPPED + HOSTED-VERIFIED (p2p-

Phase G (transfer-window + thunder verification) SHIPPED + HOSTED-VERIFIED (p2p-hub, 2026-06-02, PR #22, ref §G/§E/threads #5/#7). One PR, DB migrations 010–013 + Bun/TS app layer.

**What landed.** 010: match_status ADD VALUE 'INSTRUCTED' then 'SENT' (each its OWN statement BEFORE 'VERIFYING' — §E4/§G5 same-tx caution) + matches transfer-window columns (destination_account=PI-6 reveal NULL-before-INSTRUCTED, transfer_ref, slip_ref, *_at, transfer/verification_deadline clamped within match_deadline, receipt_confirmed_at). 011: match_verifications ⟦S4⟧ table + UNIQUE PARTIAL index on non-null trans_ref (dedupe, thunder has no idempotency key) + new wallet op fee_refund_charged (balance += F) — DISTINCT from fee_refund (reserved -= F), never overloaded (§G7b). 012: transfer_instruction/transfer_sent/receipt_confirm. 013: record_verification — appends ⟦S4⟧ + drives transition: settle-gate (genuine AND actual>=M AND delivered) PASS → SETTLED via settle_p2p_match at M (over-pay settles at M, excess UNTOUCHED = matched_overpaid DSP-fault); under-pay → matched_incomplete release+EXPIRED; ambiguous+cap → oracle-error EXPIRED. FAIL(fake_slip)/NOT_DELIVERED(customer_non_receipt) are RECORD-ONLY (deferred §F overlay drives those). §E7 advance_to_verifying DROPPED; both §E8 seams closed (EXPIRED-from-VERIFYING + post-charge fee_refund_charged refund-to-balance). Canonical provider_id ASC lock order throughout.

**App layer (mirrors admin-approve-topup).** ThunderClient seam + normalized ThunderVerdict (OMITS delivered/amountMatched — derived ABOVE the seam in src/thunder/derive.ts in ONE place, the ~905-case fraud defence). Shared envelopeToVerdict maps mobiz wire shape; Gap-#3 ambiguous split = success:false WITH data ⇒ definitive bad slip, WITHOUT data ⇒ ambiguous. MockThunderClient per-scenario (every §F class) + RealThunderClient (contract-only, branches on success not HTTP status, never throws→ambiguous, NO live wiring). verify service: exp-backoff + increasing timeout to cap → fail-safe EXPIRED, idempotent on match_id+attempt. THUNDER_CLIENT=mock|real (defaults mock).

**Impl-params pinned.** transfer_window=30min, verification_window=15min; re-attest cap=3 (mobiz parity), backoff base=1s exponential, per-attempt timeout 30s→90s ceiling; mask-compare = strip non-digits + compare unmasked last-4, FAIL-SAFE (not delivered) if either side exposes <4 unmasked trailing digits.

**HOSTED-PROVISIONING GOTCHA (extends the mb-next 'VERIFIED hosted-provisioning recipe' learning).** Fresh project gkgacoskpocntboxzkyy in ap-southeast-1: the session pooler host is **aws-1-ap-southeast-1.pooler.supabase.com:5432**, NOT aws-0. aws-0 returned `FATAL: tenant/user postgres.<ref> not found (SQLSTATE XX000)`; aws-1 worked first try. Newer ap-southeast-1 projects are provisioned on the aws-1 pool. Direct host db.<ref>.supabase.co does NOT resolve (IPv6-only). `supabase db push --db-url <aws-1 session pooler :5432> --include-all` (no `supabase link`, no PAT needed) pushed 001–013 CLEAN to the empty project. supabase CLI installed via `brew install supabase/tap/supabase` (no psql needed). Creds loaded BY PATH ONLY from the fleet secret store at ~/.arra-oracle-v2/fleet-secrets/p2p-hub/supabase.env (SUPABASE_URL/ANON/SERVICE_ROLE/DB_PASSWORD; no PROJECT_REF — derive from URL; no pooler URL — construct it).

**Verify result.** 28/28 hosted-assertions PASS on gkgacoskpocntboxzkyy (A1–A12 + E1–E9 + G1–G7; E1 now drives the real transfer-window path) + 25/25 bun unit tests + tsc clean.

**Deferred (stated):** live thunder switch-to-real (egress-gated, §G3/§G9); the §F dispute-overlay ⟦S5⟧ engine for fake_slip/customer_non_receipt dispositions (record_verification records the verdict; the autonomous under/over/oracle-error outcomes ARE driven now).

---
*Added via Oracle Learn*
