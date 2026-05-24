---
title: **Orchestrator campaign #220: two reusable lessons from rebasing stale W1/W2 val
tags: [orchestrator, dispatch, subsumption, stale-base, rebase, baseline, drift, P-004, code-is-truth, pull-request, fleet]
created: 2026-05-23
source: orchestrator — thread #220 campaign close-out
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Orchestrator campaign #220: two reusable lessons from rebasing stale W1/W2 val

**Orchestrator campaign #220: two reusable lessons from rebasing stale W1/W2 validation PRs after #458 merged.**

Context: #458 (W9 flows track) merged → main = `8fe83c2`, advancing `docs/.baseline`. The W1 (#456 pg-tester) and W2 (#457 pg-writer) sibling validation PRs went CONFLICTING (§3d-class stale-base). Orchestrator dispatched §9-safe `git merge origin/main` INTO each branch (no rebase/force). Outcome diverged sharply between the two:

**Lesson 1 — A dispatch instruction can carry an inverted factual premise; the worker must verify against code/git evidence (P-004) and resolve to INTENT + flag, not apply literal text that regresses the artifact.**
The orchestrator told pg-writer: "resolve `docs/.baseline` — take the post-#458 advanced value `7e239a5`, don't revert." But `7e239a5` (2026-05-22) is an *ancestor* of #457's own `d181f34` (2026-05-23), 13 commits behind. Taking `7e239a5` literally would have moved `.baseline` BACKWARDS. pg-writer kept `d181f34` (honored the stated intent "don't revert / advanced") and flagged the inversion. Root cause: TWO tracks edit DIFFERENT baselines — #458 is the flows track (authoritative owner of `docs/flows/.baseline`, only *incidentally* bumped `docs/.baseline` to `7e239a5`); #457 is the current-system track and the authoritative owner of `docs/.baseline` (already at `d181f34`). They only collide on `docs/.baseline` because #458 touches it as a side effect. Takeaway for dispatchers: don't assert "the merged sibling advanced X" without checking ancestry; for workers: when an instruction's literal value contradicts the tree, resolve to intent and flag (do NOT silently apply or silently override).

**Lesson 2 — #456 (W1 test-index validation) was fully SUBSUMED by an already-merged fix; CLOSED as subsumed, not merged or reworked.**
#456 marked 42 create-path tests STALE@9aebabb (root cause #392 made `X-Idempotency-Key` mandatory) with proposed fix "add a unique key to each create call." But #473 (`34f3a4c`, merge `2be3489`) had already shipped exactly that — injected `X-Idempotency-Key: $(gen_idem_key)` into all 37 create-path scripts + `gen_idem_key()` in setup-infra.sh; #475 (`d768599`) ratified with KNOWN-WONTFIX fifo rows. At the merged tree (38 scripts carry the key) #456's STALE rows are factually false. No coherent merge resolution preserved value (take-ours ships false rows + clobbers #475; take-theirs self-contradicts the cleanly-merged STALE rows below; reconcile-honestly ≈ main). pg-tester's only non-subsumed output (coverage-gap rows + arra_learn/arra_trace) was already independently filed. Decision: CLOSE #456 as subsumed — do not rework, do not merge. The "rebase stale PR" reflex must include a subsumption check: a sibling PR's tracked range can be overtaken by an intervening merge, making the PR redundant rather than just conflicting.

Process notes: closing/merging are §9 USER actions — orchestrator routed "merge #457 / close #456" to the user, did not act on the PRs itself. #457 stayed mergeable & not-subsumed (22 lines genuine W2 content survived dedup). Tags: #repo:cross #repo:mobiz-payment-gateway #fleet #orchestrator #drift #decision #gotcha #current

---
*Added via Oracle Learn*
