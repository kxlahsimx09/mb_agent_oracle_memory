---
title: ## Reviewer method — first bankbot CODE wave (gateway #398 + cross-repo bot #1, 
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, approve, bank-bot, bot-auth, cross-repo, hmac, adapter, bbot-002, bbot-001, checklist]
created: 2026-06-11
source: PR #398 + mb-next-bank-bot#1 reviews 2026-06-11; thread #13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Reviewer method — first bankbot CODE wave (gateway #398 + cross-repo bot #1, 

## Reviewer method — first bankbot CODE wave (gateway #398 + cross-repo bot #1, both APPROVE): how to verify "untouched seed code still composes" and what the auth-substrate checklist was

Two patterns worth keeping from the 2026-06-11 build-wave review:

**1. Cross-repo adapter PRs with an "untouched portal code" requirement need SEAM verification, not just diff-absence.** mb-next-bank-bot PR #1 touched only the adapter (core/api.js, app.js, secrets) and left banks/* out of the diff — but "no banks/ files in the diff" alone doesn't prove the new runtime composes with the seed. The checks that mattered (shallow-clone the PR head, grep/read the seed):
- call-signature compatibility: app.js passes {lastInDateBKK, lastOutDateBKK} → the seed's scrapeStatement(page, lastKnown) had to accept the object (it does, via normalizeCursor — the PR-12 direction-aware fix was already in the seed; the @param union doc confirmed it);
- stub-reachability sweep: grep banks/* + base.js for `this.api.`/otp_api usage to find Phase-1-reachable calls into now-stubbed BotAPI methods. Found: SCB login clean; KTB login.js:208 rides otp_api→getOTP (stub throws) → KTB Phase-1 deploy fails loudly = consistent with the SCB-first pin, but it MUST be on record (it was, in the PR's CLAUDE.md).

**2. Bot-tier auth substrate checklist that paid off on gateway #398** (beyond the wire-contract diff-match): (a) cutover completeness = grep the PR HEAD for the old verifier name, not just the diff (zero leftover botAuth call sites); (b) encrypted-not-hashed storage is LOAD-BEARING for HMAC tiers — a hashed secret cannot verify signatures (K1b rationale; #398 got it right with pgp_sym_encrypt + per-call EF-held enc key, never stored in DB); (c) read-raw-body-once before auth so signed bytes == parsed bytes, and auth-precedes-400 must be a PINNED semantic (it was, in the dev's substrate slice §6); (d) every verifier time read through app_now() so replay window + retire_at are virtual-clock probe-drivable; (e) binding-bypass check: trace that any account ref reaching a data RPC was first asserted at auth — null refs may only fall through to post-auth 400s; (f) deploy sequencing is part of the verdict's notes even when the diff is correct (ENC_KEY per stack, mint before any bot runs, Lane-3 bot-config EF before bot boot).

Also: dev-authored "substrate/probe-surface" spec slices (observable surface for testers, subordinated to the writer's wire slices) fit the dev↔tester de-bias pattern — accept with a back-link routing note to next-writer rather than a lane-violation block.

Source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/398 + https://github.com/kxlahsimx09/mb-next-bank-bot/pull/1 reviews 2026-06-11; thread #13.

---
*Added via Oracle Learn*
