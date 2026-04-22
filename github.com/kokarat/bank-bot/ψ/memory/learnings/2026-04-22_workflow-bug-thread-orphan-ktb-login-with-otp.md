---
title: workflow-bug — thread-orphan — ktb-login-with-otp.md:5 carries [RATIFICATION_PEN
tags: [technical-writer, repo:bank-bot, workflow-bug, thread-orphan, flow:ktb-login-with-otp, thread:23, ratification-marker-stale, follow-up-w8-revision]
created: 2026-04-22
source: docs/flows/ktb-login-with-otp.md@b71aff4 (stale header marker) + arra_thread_read(23) message #45 (human ratification 2026-04-20)
project: github.com/kokarat/bank-bot
---

# workflow-bug — thread-orphan — ktb-login-with-otp.md:5 carries [RATIFICATION_PEN

workflow-bug — thread-orphan — ktb-login-with-otp.md:5 carries [RATIFICATION_PENDING:23] despite thread #23 being closed with ratification. Thread #23 was answered by human (mobiztool@gmail.com) on 2026-04-20T04:21 GMT+7 with full ratification (Q1 tag-framing REVISE to drop -bot-first suffix; Q2 mermaid KEEP; Q3 scope KEEP; Q4 ensureLoggedIn promote to first-class steps; bonus drifts acknowledged) and moved to status=closed. The flow doc's header should have been updated in a follow-up commit to: (a) strip [RATIFICATION_PENDING:23] and replace with // ratified-via-thread:23; (b) promote claim strength S4 → S2; (c) apply Q1 (drop -bot-first tag suffix throughout) + Q4 (promote ensureLoggedIn/checkSession to numbered steps in mermaid); (d) add a "Thread #23 ratified" entry to the change log. None of these follow-up actions landed. Per workflow-thread-resolve.md discipline this is a Pass 2 safety-net catch: thread closed without corresponding doc update = leaked anchor. Discovered during Step 0 grep of docs/flows/ on 2026-04-22 W8 pass for bot-otp-relay. The bot-otp-relay author made a judgment call to flag and proceed (orphan is in different doc, fixing it is separate W8 revision scope). This learning is the "unfiled orphan filed" action. FOLLOW-UP NEEDED: dedicated W8 revision pass on ktb-login-with-otp.md applying thread #23 Q1+Q4 ratifications and stripping the stale marker. Not queued for W4 because it's a doc-only revision not a code drift. Related: similar orphan-marker issue may exist on other bot-side flow docs — audit recommended on next W9 track pass. Date discovered: 2026-04-22 GMT+7. Discovering pass: W8 bot-otp-relay.

---
*Added via Oracle Learn*
