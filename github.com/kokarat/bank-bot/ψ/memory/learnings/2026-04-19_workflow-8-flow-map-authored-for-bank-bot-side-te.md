---
title: Workflow-8 flow-map authored for bank-bot side (technical-writer role in `github
tags: [["brew-ops", "workflow-edit", "workflow-8", "technical-writer", "bank-bot", "cross-repo-sync", "reciprocal-breadcrumb", "self-test", "pattern", "repo:cross", "2026-04-19"]]
created: 2026-04-19
source: vault commit 47b42ca on main, 2026-04-19 brew-ops session
project: github.com/kokarat/bank-bot
---

# Workflow-8 flow-map authored for bank-bot side (technical-writer role in `github

Workflow-8 flow-map authored for bank-bot side (technical-writer role in `github.com/kokarat/bank-bot`), commit `47b42ca` on vault `main`. Closes the cross-repo-sync asymmetry observed in 2026-04-19 audit: 17 of 18 existing `#cross-repo-sync` learnings were mobiz-only before today, producing one-way links where bot-side queries stayed blind to mobiz flow context.

## What changed in the ecosystem

Before: mobiz-side W8 passes filed `#cross-repo-sync + bank-bot` breadcrumbs expecting bot-writer to eventually reciprocate. Bot-writer had no W8 workflow, so no reciprocation happened. Queries from bot-side for a cross-repo slug surfaced mobiz docs via keyword match (it worked, just not bidirectionally) but there was no trace-chain bridge, no shared index learning, and no guarantee the bot-side doc (when eventually written) would land with the right tag shape to complete the loop.

After: bot-writer has W8 with two steps absent from mobiz's version — §9b mandatory reciprocal breadcrumb (dual-repo tag set `repo:bank-bot + repo:cross + repo:mobiz-payment-gateway`, plus a short index-learning tombstone when a mobiz counterpart exists), and §9c four-query self-test blocking DoD until the reverse-query loop is verifiably closed.

## Why two workflows instead of one shared

Role semantics are identical (`technical-writer` writes flow docs from code) but the surface differs enough to warrant separate specs:

- Language + stack: Go/Fiber/MongoDB (mobiz) vs Node.js/Playwright/Cheerio (bot). Actor lists and error-class vocabularies differ accordingly.
- Cross-repo direction flips: mobiz flows see bot as the `// ext: kokarat/bank-bot` side; bot flows see mobiz as the `// ext: kokarat/mobiz-payment-gateway` side.
- Every bot flow is cross-repo by construction (the bot exists because mobiz invokes or consumes it). Every mobiz flow is single-repo by default with cross-repo the exception. The discipline weight lands differently — bot's W8 makes the cross-repo step mandatory and self-tested; mobiz's W8 keeps it conditional on step analysis.

## Tag-form nuance worth knowing

Step 2c in the bot W8 queries BOTH `flow:<slug>` and bare `<slug>` tag forms because the canonical `flow:<slug>` form was standardised only on 2026-04-19 (see workflow-9 change log). Older mobiz breadcrumbs (authored 2026-04-17/18) tag bare slug; newer ones use prefixed. Per P-001 the old breadcrumbs won't retag — both forms live side by side in the vault and any search script over `#cross-repo-sync` must union both. Step 9c acceptance uses top-10 rather than top-5 to tolerate FTS ranking noise observed on compound queries during the workflow's own drafting self-test (`arra_search query="flow:deposit-qr-request cross-repo-sync"` returned the target breadcrumb at rank 5, buried under unrelated cross-repo breadcrumbs sharing one term).

## Trace-chain linked-list constraint

W8 root traces have a single `prev_trace_id` and a single `next_trace_id` (observed 2026-04-18 via retro 14.29 when pg-writer hit `Error: Trace ... already has a prev link`). The bot W8 spec codifies the 2026-04-18 decision: intra-repo chain wins the trace slots, cross-repo sibling trace id is captured in the reciprocal breadcrumb's body text. The index-learning tombstone (Step 9b second learning) carries both ids in plain text so `arra_read <index-id>` returns the cross-repo pair directly, bypassing trace-chain traversal altogether.

## Self-test as a workflow feature

The four-query self-test in §9c is a generalisable pattern worth flagging in the brew-ops pattern library: any workflow whose output needs to be discoverable across arbitrary query angles should include, as the final step before commit, a set of queries that prove the artefact is in fact findable from each expected angle. Without it, the workflow produces the artefact correctly but can silently ship a doc that reverse-queries miss (exactly the asymmetry that motivated this whole workflow). Failure mode is latent and gets discovered days later via audit — same class as the W9 Step 3 regex bug from yesterday.

## What's scoped OUT of this pass

- **W9 for bank-bot** — not added. Bank-bot flow portfolio is currently zero docs; W9 is track-commit-against-flows and has nothing to do until the portfolio has 2+ docs. Revisit when the first W8 runs.
- **Retroactive retag of existing mobiz breadcrumbs** — not done (P-001). Both tag forms live side by side; dual-form queries are the mitigation.
- **Trace schema migration for DAG siblings** — not proposed. Out of scope for a workflow-authoring pass; would need a separate Oracle-core change.

## How to apply

First bot-side W8 pass should author a flow for a slug already covered by mobiz — `deposit-qr-request` is the natural candidate (mobiz breadcrumb `learning_2026-04-17_flow-cross-repo-breadcrumb-deposit-qr-request-cr` is the anchor; mobiz W8 trace `64ef2dc5-7a6b-45f4-8ab6-3fe49e9202a0` is the senior chain head). Running W8 on this slug first produces the smallest-possible test of the whole cross-repo mechanism end-to-end, with a prior mobiz breadcrumb available to consume in Step 2c and a known counterpart to reference in Step 9b.

Tags: brew-ops, repo:cross, workflow-edit, workflow-8, technical-writer, bank-bot, cross-repo-sync, reciprocal-breadcrumb, self-test, pattern

---
*Added via Oracle Learn*
