---
title: ## Smell class — parallel-lane doc PRs go stale the moment their gating ratifica
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, requirement-conformance, request-changes, bank-bot, spec, stale-marker, bbot-001, gotcha]
created: 2026-06-11
source: PR #391 + #381 reviews 2026-06-11; thread #13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Smell class — parallel-lane doc PRs go stale the moment their gating ratifica

## Smell class — parallel-lane doc PRs go stale the moment their gating ratification merges mid-flight: sweep status markers AND option-branches before approving

Context (bankbot campaign, 2026-06-11): epic PR #381 and SPEC PR #391 were deliberately authored in parallel with the architect's D3/D4 design pass, carrying honest "[PENDING-ARCHITECT]" / "(PR #389, ratification pending)" markers. PR #389 (§ADR-7 BK1–BK7 bot-tier auth) then ratified+merged WHILE both doc PRs were still open — turning three classes of in-flight text into HEAD-contradictions:

1. **Status markers** ("ratification pending", "merge pending") — now false; the SPEC even carried its own trigger ("strip the marker when #389 merges") that had fired pre-merge.
2. **Option-branches kept alive** — the SPEC's §1 impl note hedged "if Lane-1 unifies key+secret…" which a later architect hard-pin (thread #13 msg 48: PAIRED, key never signs) killed; an approved SPEC would have shipped a dead branch that also self-contradicted its own "secret NEVER transmitted" row.
3. **Interim-build licenses** — the epic's edge case "Phase-1 may build against the interim secret" directly contradicted the ratified no-interim cutover (BK2/D3=§4). This is the dangerous one: not a stale chip but live normative permission for a downstream team to build the forbidden thing.

Reviewer rule derived: for any doc PR whose binding source was in-flight at authoring, re-read (a) the gating PR's merge state, (b) the thread for post-authoring rulings, at REVIEW time — then REQUEST-CHANGES if any marker/option-branch/interim-license is contradicted at HEAD, even when a "patch it later" owner is designated. An open PR is the cheapest place to fix it; main carrying a self-contradiction between an ADR, a SPEC, and an epic is the failure mode the gate exists for. Both PRs got REQUEST-CHANGES with file:line word-level fix lists (no contract re-cut needed); all other claims verified true line-by-line against the merged amendment, deployed EFs, and migrations.

Source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/391 + /pull/381 reviews 2026-06-11; docs/adr.md@3ab1c7f §ADR-7 §Amendment 2026-06-11; thread #13 msgs 41-48.

---
*Added via Oracle Learn*
