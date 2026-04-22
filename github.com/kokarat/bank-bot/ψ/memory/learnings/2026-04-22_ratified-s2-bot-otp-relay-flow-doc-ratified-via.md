---
title: RATIFIED S2 — bot-otp-relay flow doc ratified via thread #39 on 2026-04-22 GMT+7
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-otp-relay, otp, gateway-relay, s2, bot-first, ratified-via-thread:39, ratification-landed]
created: 2026-04-22
source: docs/flows/bot-otp-relay.md@post-ratification (thread #39 closed 2026-04-22 GMT+7)
project: github.com/kokarat/bank-bot
---

# RATIFIED S2 — bot-otp-relay flow doc ratified via thread #39 on 2026-04-22 GMT+7

RATIFIED S2 — bot-otp-relay flow doc ratified via thread #39 on 2026-04-22 GMT+7. All five judgement calls returned KEEP: (Q1) scope = one getOtpFromAPI invocation, IMAP fallback deferred to sibling scb-email-otp-via-imap flow; (Q2) linear + nested loop + three-way alt mermaid (no loop-wrap); (Q3) External:OTPService as named-but-non-sequenced actor in §Actors + §Preconditions, not drawn in diagram; (Q4) two drifts ([DRIFT-gateway-5xx-swallowed] + [DRIFT-expiry-invisible-to-caller]) as learnings only, no W4 queue (masking risk on both fixes); (Q5) 11-call-site inventory in §Implementation pointers is load-bearing for reader comprehension of timeout/retry/fallback divergence between SCB and KTB. Doc header promoted S4 → S2; `[RATIFICATION_PENDING:39]` stripped and replaced with `// ratified-via-thread:39`. Change log entry added recording all five KEEP classifications. Thread #39 moved straight to closed per project feedback memory (skipping intermediate answered). Supersedes prior `learning_2026-04-22_flow-intent-at-a-glance-bot-otp-relay-bank-bot` which carried ratification-pending + s4 tags. Baseline unchanged — docs/flows/.baseline still 338070b (W9 owns baseline refresh). W8 root trace: ce35d223-bab7-4bab-bc9f-94b3875a002d. Primary flow learning now at: docs/flows/bot-otp-relay.md. Cross-repo breadcrumb: bot-first (no mobiz sibling authored at HEAD).

---
*Added via Oracle Learn*
