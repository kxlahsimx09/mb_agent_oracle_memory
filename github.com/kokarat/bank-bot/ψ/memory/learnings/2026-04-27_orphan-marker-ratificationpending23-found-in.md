---
title: Orphan marker `[RATIFICATION_PENDING:23]` found in `ktb-login-with-otp.md` heade
tags: [technical-writer, repo:bank-bot, orphan-marker, flow-drift, flow:ktb-login-with-otp, thread-resolve]
created: 2026-04-27
source: docs/flows/ktb-login-with-otp.md
project: github.com/kokarat/bank-bot
---

# Orphan marker `[RATIFICATION_PENDING:23]` found in `ktb-login-with-otp.md` heade

Orphan marker `[RATIFICATION_PENDING:23]` found in `ktb-login-with-otp.md` header during W9 Step 0 sweep on 2026-04-27. Thread #23 was closed/ratified by human on 2026-04-20, but the marker was never stripped. Applied now: Claim strength S4→S2, `// ratified-via-thread:23` added, Q1 verdict (cross-repo-sync tag) applied. Q4 verdict (ensureLoggedIn/checkSession → numbered steps) deferred to W8 revision handoff. Root cause: the 2026-04-20 ratification session did not write back to the flow doc.

---
*Added via Oracle Learn*
