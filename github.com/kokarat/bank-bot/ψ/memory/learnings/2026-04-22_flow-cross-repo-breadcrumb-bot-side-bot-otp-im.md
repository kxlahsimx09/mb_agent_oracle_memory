---
title: flow cross-repo breadcrumb (bot side) — bot-otp-imap-fallback has NO mobiz-payme
tags: [technical-writer, repo:bank-bot, repo:cross, current, flow, flow:bot-otp-imap-fallback, cross-repo-sync, otp, imap, external-actor-only, no-mobiz-counterpart, sibling:bot-otp-relay]
created: 2026-04-22
source: docs/flows/bot-otp-imap-fallback.md@adeac29 — no mobiz code path referenced
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side) — bot-otp-imap-fallback has NO mobiz-payme

flow cross-repo breadcrumb (bot side) — bot-otp-imap-fallback has NO mobiz-payment-gateway crossing. The flow's sole external actor is External:GmailIMAP (or whichever IMAP provider the account uses, Gmail is the default). Unlike the sibling bot-otp-relay flow which crosses into mobiz at step 3 (GET /bot/otp), this flow connects directly from bank-bot to IMAP provider via imapflow library. No // ext: kokarat/mobiz-payment-gateway pointer anywhere in the doc. The cross-repo tag is filed anyway per thread #23 Q1 convention (plain cross-repo-sync, dropped bot-first suffix) because: (a) the flow has a non-internal actor boundary (External:GmailIMAP is outside the bot repo), (b) the sibling bot-otp-relay flow IS cross-repo and the two should be searchable together, (c) the tag signals W8 cross-repo discipline was applied even though the result is null on the mobiz side. Body text explicitly names External:GmailIMAP as sole external actor and discloses "no mobiz counterpart." Future mobiz W8 passes on bot-otp-* slugs will find only bot-otp-relay has a genuine pair; this flow will surface as a sibling via the shared flow:bot-otp-* fuzzy match but will not need its own mobiz counterpart. Bot W8 trace: 3d7ced04-712c-4401-aeee-f3fb2d5dbebe. Sibling W8 trace: ce35d223-bab7-4bab-bc9f-94b3875a002d (bot-otp-relay, ratified S2 via thread #39). No arra_trace_link between siblings — trace linked list slots reserved for revision chains, not sibling chains, per workflow-8-flow-map §Trace-chain discipline.

---
*Added via Oracle Learn*
