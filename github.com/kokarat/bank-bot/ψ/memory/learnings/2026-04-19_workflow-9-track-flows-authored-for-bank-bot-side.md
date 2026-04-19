---
title: Workflow-9 track-flows authored for bank-bot side (technical-writer role in `git
tags: [["brew-ops", "workflow-edit", "workflow-9", "technical-writer", "bank-bot", "cross-repo-sync", "drift-propagation", "pattern", "repo:bank-bot", "2026-04-19"]]
created: 2026-04-19
source: vault workflow-9-track-flows.md (bank-bot side), 2026-04-19 brew-ops session
project: github.com/kokarat/bank-bot
---

# Workflow-9 track-flows authored for bank-bot side (technical-writer role in `git

Workflow-9 track-flows authored for bank-bot side (technical-writer role in `github.com/kokarat/bank-bot`). Mirrors the mobiz-side W9 structure established 2026-04-17 but with three bot-specific adaptations that flow from observations in today's W8 first-pass work.

## What bot-side W9 inherits verbatim from mobiz-side

- Daily cron cadence alongside W2.
- Pointer-level verification unit (not doc-section).
- Six outcome classes A/B/C/D/E/F with clear action mapping.
- Fast-fix thresholds (≤5 flows, ≤50% per-flow step drift; exceeding escalates to W8 revision).
- Global `docs/flows/.baseline` (not per-flow).
- Bootstrap via oldest `// impl:` commit hash across the portfolio (already covered by W8 Step 9a seed at `466d56e` on 2026-04-19 — bootstrap unlikely to fire here).
- Step 3 fixed extractor regex (anchors on backtick-wrapped `<path>@<hash>` tokens scoped to `## Implementation pointers` sections, with mandatory regex self-test). Inherits the brew-ops audit fix from 2026-04-19 that landed on the mobiz side yesterday.
- Step 7b verify.sh hard gate. Inherits today's post-W8-calibration addition.

## What differs from the mobiz-side sibling

**1. Step 2c cross-repo direction flips.** Mobiz W9 Step 2c looks for a recent bank-bot W2 trace within 24h. Bot W9 Step 2c looks for a recent mobiz W2 trace instead. The mirror is exact — whichever side is running W9 looks for the *other* repo's most recent W2 chain head to link.

**2. Step 5e cross-repo-sync is mandatory on most bot passes.** Bot flows are cross-repo by construction (per bot W8 Design notes on decomposition asymmetry — one mobiz `// ext: kokarat/bank-bot` marker typically expands to 5-10 bot steps). A drift inside those bot steps is invisible to mobiz W9 because mobiz's code did not change; the mobiz-side `// ext:` marker is a black box to mobiz's own tooling. The `#cross-repo-sync + #flow-drift + repo:cross` learning is the *only* channel by which bot-side drift reaches mobiz's W4 queue. Without it, mobiz's sibling flow doc silently drifts out of alignment with reality.

The mobiz-side mirror of this (mobiz W9 Step 5e) is weaker because mobiz flows are mostly single-repo — only a fraction cross into bank-bot territory. Bot W9's prominence on Step 5e reflects that asymmetry.

**3. Examples + actors are bot-flavored.** Instead of Go/Fiber/MongoDB examples (handlers changed, schedulers ticked), the Class C/D/E examples name: bank portal selector changes (bank updated their UI), OTP phase reordering, scraper cursor resets, Playwright session refresh, CAPTCHA-class additions, new bank integrations appearing in `banks/<new>/`.

## What's out of scope for this workflow

- **§Design notes from W8** (decomposition asymmetry + loop representation framework) — not mirrored. W9 doesn't author flows or draw diagrams, so neither observation applies. Captured only in W8 spec.
- **Self-test block (analogous to W8 Step 9c)** — not needed. W9's outputs are drift learnings and pointer refreshes, not a new flow doc whose cross-repo link needs post-hoc verification. The `#cross-repo-sync` learning in Step 5e is findable by search on the slug; no dedicated self-test block.

## Expected early-portfolio behavior

As of 2026-04-19, bank-bot has exactly 1 flow doc (`scb-dual-control-withdrawal.md@466d56e`). The W9 pass's effect depends on whether post-`466d56e` commits have touched any file referenced in that flow's `## Implementation pointers` section. Most likely outcome for the first few bot W9 passes: `#no-drift-found + #flow-track` + baseline bump, same shape as the mobiz-side 2026-04-18 14:37 zero-drift pass. The bot's first real pointer drift will probably arrive when an SCB portal update breaks a selector or when a new bank integration lands.

## Trace-chain discipline reminder

`arra_trace`'s `prev_trace_id` / `next_trace_id` are a linked list, not a DAG (2026-04-18 retro 14.29 confirmed the single-slot constraint). Step 2b chains to the intra-bank-bot prior trace; Step 2c captures the mobiz sibling in the `#cross-repo-sync` learning's body, not in the trace's slot. Same convention as bot W8 and mobiz W9.

Tags: brew-ops, repo:bank-bot, memory, workflow-edit, workflow-9, technical-writer, cross-repo-sync, drift-propagation, pattern

---
*Added via Oracle Learn*
