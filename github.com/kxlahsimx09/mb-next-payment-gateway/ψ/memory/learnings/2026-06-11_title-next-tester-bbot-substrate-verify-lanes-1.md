---
title: title: next-tester bbot substrate VERIFY — lanes 1-3 BLOCKED-ON-DEPLOY: tester s
tags: [next-tester, repo:mb-next-payment-gateway, next, probe, coverage-gap, bankbot, evidence, handoff, blocked-on-deploy]
created: 2026-06-11
source: tests/integration/run-bbot-substrate.ts @ PR #403; evidence/integration-run-bbot-1781163649970-fddfe836.json
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: next-tester bbot substrate VERIFY — lanes 1-3 BLOCKED-ON-DEPLOY: tester s

title: next-tester bbot substrate VERIFY — lanes 1-3 BLOCKED-ON-DEPLOY: tester stack never received the #398/#399/#400 deploy

Independent probe wave for the merged bot-tier substrate (thread #13 dispatch) found the tester test/perf stack (yupsevcrubgprsbujbpu) still on the PRE-cutover substrate at gateway main fddfe83: migrations 20260611000100/20260611000110 NOT applied (bot_credentials PGRST205; mint/verify/rotate/revoke RPCs PGRST202 with named params), all 4 bot EFs answer 401 invalid_bot_secret (legacy x-bot-secret verifier = pre-BK2 code), bot-config 404 NOT_FOUND, EF secret BOT_CRED_ENC_KEY absent (legacy BOT_SECRET still set), tester slot also lacks BOT_CRED_ENC_KEY. Verdict: lane 4 RED (deploy gap), lanes 1-3 BLOCKED-ON-DEPLOY per the stack-readiness gate — a bare stack is never run, never green. Owner: next-dev (tester-stack deploy ownership, build-workflow.md); slot mirror of the enc key may be brew-ops. Probe suite is authored push-button on PR #403 (tests/integration/run-bbot-substrate.ts gates lanes behind readiness R1-R7; readiness includes a pgcrypto-search_path detector for the known extensions-schema gotcha). PGRST202-with-{} is a false missing-function signal — always probe RPC existence with correctly NAMED params.

evidence: evidence/integration-run-bbot-1781163649970-fddfe836.json (git-sha fddfe83)

tags: next-tester, repo:mb-next-payment-gateway, next, probe, coverage-gap, bankbot, bbot-002, bbot-003, bbot-004, evidence, handoff, blocked-on-deploy, fixture-source:repo-flow-doc

---
*Added via Oracle Learn*
