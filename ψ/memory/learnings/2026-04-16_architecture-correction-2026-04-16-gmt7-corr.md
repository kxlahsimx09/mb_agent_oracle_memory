---
title: Architecture correction (2026-04-16, GMT+7) — Corrected a false premise in `work
tags: [tester, repo:mobiz-payment-gateway, current, decision, mock-bank, bank-bot, architecture, correction, workflow]
created: 2026-04-16
source: Conversation with Mobiz, 2026-04-16 GMT+7, brew-ops-oracle session. User correction of workflow-3 false premise.
project: github.com/kokarat/mobiz-payment-gateway
---

# Architecture correction (2026-04-16, GMT+7) — Corrected a false premise in `work

Architecture correction (2026-04-16, GMT+7) — Corrected a false premise in `workflow-3-mock-bank-sync-check.md` and its refs across the tester SKILL and AGENTS.md.

## The wrong premise (now removed)
Earlier drafts of workflow-3 framed mock-bank drift as a three-way cross-read between mock-bank, **backend**, and bank-bot. The workflow had a Step 2 "Inventory what the backend expects from mock-bank" that assumed the backend was a live consumer of mock-bank's surface.

## The reality (user-authoritative, confirmed 2026-04-16)
```
backend ←──(bot reports results)── bank-bot ──(drives portal)──→ mock-bank
```

- **Backend never talks to mock-bank directly.** The live contract is strictly mock ↔ bot.
- **bank-bot is the sole production-shaped consumer** of mock-bank's portal surface (login pages, statement pages, transfer forms, OTP entry).
- **Tests** use a secondary `/admin/**` surface on mock-bank to seed fixtures (balances, inbound transfers). That is a fixture contract, not the bot contract.
- **If mock-bank has outbound `fetch`/`axios` calls to the backend** (e.g., auto-posting a generated OTP to `/api/v1/bot/otp-log`), those are **test-convenience glue**, not part of the live contract. Their drift is test-infra noise, not production-impact drift.

## Fix applied
- `workflow-3-mock-bank-sync-check.md` rewritten end-to-end: intro now carries the correct 3-node diagram; Step 2 is the bot-expectation walk (primary contract); Step 3 demoted the backend-calls inventory to "informational only"; Step 4 is admin/fixture (secondary); Step 5 matrix columns updated (dropped "Called by backend", added SELECTOR-DRIFT + TIMING-DRIFT status values); Step 6 contract doc template rewritten with per-bank subsections.
- `skills/tester/SKILL.md` lines updated in three places: principle #5 (mock-bank edits are against the bot contract, not the backend contract), ownership row for `docs/mock-bank-contract.md` (portal surface + selector/response inventory vs. "endpoint inventory + what backend callers expect"), workflow 3 trigger condition (drops the backend bot-facing surface as a trigger; uses mock + bot only).
- `AGENTS.md` §8 ownership table: the row "mock-bank ↔ backend/bot contract" relabelled "mock-bank ↔ bank-bot contract" with an explicit note that backend never talks to mock-bank directly.

## Why this matters beyond the doc
A workflow that told tester to cross-read backend↔mock would produce false drift reports (every backend route that doesn't call mock-bank would be "MISSING-IN-MOCK" under the wrong mental model) — or worse, no findings at all, because the real drift (bot↔mock) was never searched. The corrected workflow makes the silent failure mode (SELECTOR-DRIFT: Puppeteer timeout that looks like slow mock) a first-class status value.

## Tagging
- tester + repo:mobiz-payment-gateway + current (3-layer)
- mock-bank + bank-bot + architecture + correction (feature)
- decision + handoff (special — this is a design call that supersedes earlier workflow text)

## Lesson for the tester agent
When a workflow names more than two endpoints for a cross-read, confirm the topology with the user before building the matrix. "A talks to B talks to C" is often mis-generalized from a diagram where only A↔B is live. The right opening question is "who calls whom?" — not "list all the nodes."

---
*Added via Oracle Learn*
