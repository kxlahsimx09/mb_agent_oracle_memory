---
title: RATIFIED S2 — bot-otp-imap-fallback flow doc ratified via thread #40 on 2026-04-
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-otp-imap-fallback, otp, imap, s2, ratified-via-thread:40, ratification-landed, sibling:bot-otp-relay]
created: 2026-04-22
source: docs/flows/bot-otp-imap-fallback.md@post-ratification (thread #40 closed 2026-04-22 GMT+7) + docs/flows/ktb-login-with-otp.md:104 bidirectional link added
project: github.com/kokarat/bank-bot
---

# RATIFIED S2 — bot-otp-imap-fallback flow doc ratified via thread #40 on 2026-04-

RATIFIED S2 — bot-otp-imap-fallback flow doc ratified via thread #40 on 2026-04-22 GMT+7. All five judgement calls returned KEEP: (Q1) scope = one getOtpFromEmail invocation, 3x API retry wrapper + relay sibling stay in bot-otp-relay; (Q2) nested outer-loop + inner-loop + three-way outer-alt mermaid — filter chain detail preserved for wrong-batch OTP risk visibility; (Q3) five drifts as learnings only (imap-auth-fail-swallowed, regex-staleness-invisible, 20-message-window, env-var-silent-fallback, console-log-untagged); console-log-untagged W4 candidate call-out kept for next W4 pass; env-var-silent-fallback security-smell gated on broader config-injection-audit pass; (Q4) bidirectional link added — forward pointer from ktb-login-with-otp.md:104 → bot-otp-imap-fallback.md §Implementation pointers "Non-callers (by design)" so readers tracking [DRIFT-login-imap-fallback] can jump to the sibling flow that does have IMAP fallback for transfer-time OTP; (Q5) #cross-repo-sync tag reuse despite no mobiz crossing per bot-otp-relay precedent (thread #39 / thread #23 Q1 convention). Doc header promoted S4 → S2, [RATIFICATION_PENDING:40] stripped → // ratified-via-thread:40. Change log entry added. Thread #40 moved straight to closed per project feedback memory. Supersedes prior learning_2026-04-22_flow-intent-at-a-glance-bot-otp-imap-fallback-b which carried ratification-pending + s4 tags. W8 root trace: 3d7ced04-712c-4401-aeee-f3fb2d5dbebe. Sibling flow: bot-otp-relay (ratified S2 via thread #39 on 2026-04-22, trace ce35d223-bab7-4bab-bc9f-94b3875a002d). Portfolio: 11 bot-side flow docs, 10 ratified S2 + 1 S4 pending (queue-claim-to-processing from prior pass).

---
*Added via Oracle Learn*
