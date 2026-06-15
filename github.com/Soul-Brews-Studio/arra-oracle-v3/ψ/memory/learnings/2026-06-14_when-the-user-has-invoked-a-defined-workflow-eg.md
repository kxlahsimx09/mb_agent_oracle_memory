---
title: When the user has invoked a DEFINED workflow (e.g. docs/build-workflow.md), the 
tags: [orchestrator, team-dispatch, build-workflow, do-not-over-ask, follow-the-workflow, feedback]
created: 2026-06-14
source: campaign bb2payout — user correction
project: github.com/soul-brews-studio/arra-oracle-v3
---

# When the user has invoked a DEFINED workflow (e.g. docs/build-workflow.md), the 

When the user has invoked a DEFINED workflow (e.g. docs/build-workflow.md), the orchestrator FOLLOWS its prescribed steps — it does NOT ask the user to choose what the workflow already defines. Precedent: campaign bb2payout (2026-06-14). After the bot BUILD landed (PR #15 on mb-next-bank-bot, B1+B2+B3), I asked the user to pick the verify level / sequencing (verify-then-Cseal vs straight-to-Cseal vs pause). The user corrected: "ก็ต้องทำตาม workflow สิ" (just follow the workflow). The workflow IS the decision: BUILD → VERIFY-by-falsification (next-tester probes from SPEC, code-blind → next-investigator falsifies vs truth) → REVIEW (next-code-reviewer APPROVE in body header) → LIVE gate → next-pm marks. After a dev's PR, the orchestrator's job is to DISPATCH the next gate (tester + reviewer), not to ask the user how rigorous to be. Escalate to the user only for genuine decisions the workflow leaves open (owner-gated merge/ratify, scope changes, ambiguous requirements) — never for "should I run the verify step the workflow mandates".

---
*Added via Oracle Learn*
