---
title: OWNER DECISION (2026-06-15): the bank-bot evidence images go in TWO SEPARATE pri
tags: [payout, supabase-storage, bucket, owner-decision, brew-ops, credential, bank-bot, project]
created: 2026-06-15
source: owner decision — bb2infra
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# OWNER DECISION (2026-06-15): the bank-bot evidence images go in TWO SEPARATE pri

OWNER DECISION (2026-06-15): the bank-bot evidence images go in TWO SEPARATE private Supabase Storage buckets — one for deposit SLIPS, one for bot PROOF (payout proof + bankbot-activity-log proof) — NOT one unified bucket. This OVERRIDES the bb2proof/bb2botlog architect design (PR #505/#506) which proposed a single `bank-evidence` private bucket. brew-ops (the all-slots infra/ops actor) creates the buckets + enables Supabase Storage (the gateway project has zero buckets today). Scoped Supabase JWTs (bot_uploader for Storage upload + bankbot_logger for direct log INSERT, each with a bank_account_id claim) are provisioned PER FLEET SLOT (one token per bot). The RLS policies + the NOLOGIN roles + the token-mint EF remain next-dev build work (per docs/spec/bbot-proof-storage-slice.md); brew-ops provisions the buckets + the per-slot tokens. Sequence: brew-ops infra (buckets + tokens) can be created now to unblock, but per-slot tokens are inert until next-dev lands the roles+RLS.

---
*Added via Oracle Learn*
