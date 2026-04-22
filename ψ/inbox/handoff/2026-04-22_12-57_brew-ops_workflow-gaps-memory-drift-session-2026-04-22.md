# Handoff — Workflow gaps that caused memory drift (session 2026-04-22)

**To:** brew-ops
**From:** pg-writer-oracle, session 2026-04-22 (Thai user operating mobiz-payment-gateway)
**Priority:** P2 — not blocking current flows but recurrence-preventing
**Expected outcome:** brew-ops reviews + prioritizes workflow edits; may implement P2/P3/P4 (low effort) same-day or triage P1 for a larger redesign pass.

---

## TL;DR

Today's session audit found **5 closed supersede gaps** + **3 doc-level drifts** in the mobiz flow docs / Oracle vault, all traceable to 4 underlying workflow gaps. Session session fixed the gaps manually (5 arra_supersede edges + 3 PRs to mobiz-payment-gateway). User asked for root-cause analysis to prevent recurrence. brew-ops own workflow-edit decisions per AGENTS.md territory map.

All 4 gaps center on the same pattern: **cross-repo code fixes ship without automated propagation into mobiz-side Oracle + flow docs**. Manual audit caught them this session, but the 2-4 day drift window is systemic, not incidental.

---

## Evidence trail (session artifacts on 2026-04-22)

**PRs opened (3, all against `main`, none merged-by-me):**
- [mobiz-payment-gateway#280](https://github.com/kokarat/mobiz-payment-gateway/pull/280) — new flow `payout-auto-reconcile-from-statement` (S2, ratified via thread #37 same-session)
- [mobiz-payment-gateway#281](https://github.com/kokarat/mobiz-payment-gateway/pull/281) — W9 drift-resolve on `withdrawal-queue-single-bot-transfer` (merged by user as `5e35830`)
- [mobiz-payment-gateway#282](https://github.com/kokarat/mobiz-payment-gateway/pull/282) — W9 spot-fix on `withdrawal-queue-dispatch-and-claim` for PR #249 triage propagation

**Supersede edges closed (5):**
1. `2026-04-18_drift-bank-bot-bankref-in-wrong-positional-slo` → `2026-04-22_ruled-drift-bank-bot-bankref-in-wrong-positional`
2. `2026-04-19_ruled-drift-stale-lock-sweep-mislabels-uncertain` → `2026-04-22_ruled-drift-stale-lock-sweep-mislabels-uncertain`
3. `2026-04-19_drift-stale-lock-sweep-mislabels-uncertainty-as` (discovery) → `2026-04-22_ruled-drift-stale-lock-sweep-mislabels-uncertain`
4. `2026-04-18_drift-bank-bot-waitingtoreview-lost-in-singl` → `2026-04-21_ruled-drift-bank-bot-waitingtoreview-lost-i`
5. `2026-04-18_flow-withdrawal-queue-single-bot-transfer-rati` → `2026-04-22_flow-withdrawal-queue-single-bot-transfer-drif`

**Learnings filed (5 total session):**
- `2026-04-22_flow-payout-auto-reconcile-from-statement-author`
- `2026-04-22_drift-in-payout-auto-reconcile-from-statement-q`
- `2026-04-22_ruled-drift-bank-bot-bankref-in-wrong-positional`
- `2026-04-22_ruled-drift-stale-lock-sweep-mislabels-uncertain`
- `2026-04-22_flow-withdrawal-queue-single-bot-transfer-drif`

**Retros filed (4):** `2026-04/22/{10.50, 11.15, 12.30, 13.00}_*.md`

**Oracle thread lifecycle:** #37 opened + ratified + closed (same-session, ~25 min).

---

## The 4 workflow gaps (root-cause taxonomy)

### Gap 1 — No cross-repo fix-propagation trigger

**Observed evidence:**
- bank-bot commit `e3db48a` (2026-04-19) fixed drift #1 (bankRef slot-swap); mobiz doc + Oracle drift-discovery not updated for 3 days
- bank-bot commit `3359d08` (2026-04-20) fixed drift #2 (waiting_to_review lost); mobiz doc + Oracle drift-discovery not updated for 2 days
- mobiz PR #249 (`8bf3a52`, 2026-04-20) shipped stale-sweep triage; `withdrawal-queue-dispatch-and-claim.md` not updated for 2 days (found + fixed in PR #282 this session)

**Root cause:** Every existing workflow (W1 baseline / W2 track-commit / W4 reconcile-drift / W8 flow-map / W9 thread-resolve) triggers either on **mobiz-side mobiz commits** OR on **ratified Oracle threads**. Nothing triggers on bank-bot commits, and cross-repo-sync learnings filed at fix-time (e.g., `2026-04-20_cross-repo-sync-2026-04-20-mobiz-249-8bf3a52-s.md`) don't auto-propagate into dependent flow docs or prior drift learnings.

**Scope of blast radius:** Every mobiz flow doc that cites `bank-bot/<path>:<line>` is at risk; every Oracle drift learning tagged `#repo:bank-bot` is at risk.

### Gap 2 — `arra_supersede` not mandatory when filing `ruled-*` / `resolution-*` / `followup-*` learning

**Observed evidence:**
- `2026-04-19_ruled-drift-stale-lock-sweep` filed with `source: ... + 2026-04-19_drift-stale-lock-sweep-mislabels-uncertainty-as` (the discovery) in frontmatter — but **no `arra_supersede` call was made** at filing time
- Same pattern: `2026-04-21_ruled-drift-bank-bot-waitingtoreview-lost-i` cited the 2026-04-18 discovery in `source:` but did not formally supersede it
- Result: both discovery learnings remained `superseded_by: null` in the DB until my session audit 4 days later

**Root cause:** `workflow-8-flow-map.md` §Step 5 (marker filing) and `workflow-thread-resolve.md` describe `source:` frontmatter conventions but do not require `arra_supersede` as a paired call. The arra_oracle MCP tool is available, used correctly for some cases (see e.g. `2026-04-19 drift-bank-bot-bankref-in-wrong-positional-slo supersedes 2026-04-18_drift-bank-bot-appjs1244-single-transfer-suc`) but the discipline is not codified.

**Scope of blast radius:** Every `ruled-` / `resolution-` / `followup-` learning filed without paired supersede leaves stale search-surface entries that appear authoritative.

### Gap 3 — Thread-closed-orphan not re-triaged against code

**Observed evidence:**
- Thread #16 (drift #2, bank-bot territory) closed orphan during 2026-04-20 W9 sweep — no human answer recorded
- `2026-04-20_workflow-bug-orphan-marker-thread-16-closed-without-answer.md` was filed documenting the workflow anomaly
- But the sweep stripped the doc marker WITHOUT checking code — bank-bot `3359d08` landed same day, which could have been detected

**Root cause:** `workflow-thread-resolve.md` Pass 2 (orphan scan) handles orphan-detection but does not include "grep code area mentioned in thread's opening message against current HEAD → file ruled-drift if behavior changed". The sweep assumes orphan = close without additional verification.

**Scope of blast radius:** Narrower than Gap 1-2 but structurally dangerous — orphan thread closures silently remove anchor markers from flow docs, which can hide unresolved drifts.

### Gap 4 — W8 §Purpose doesn't require current-state scenario verification

**Observed evidence:**
- Session's own authoring: `payout-auto-reconcile-from-statement.md` §Purpose paragraph 1 used "timeout → MarkFailed" framing that reflected pre-PR-#83 bot behavior (PR #83 merged 2026-04-19 changed SCB maker uncertainty → waiting_to_review)
- Drift surfaced only during ratification when user asked "ทำไมไม่เป็น waiting_to_review"
- Required §Purpose rewrite to 3-category (A/B/C) taxonomy in same-session ratification revision (`2026-04-22` chain)

**Root cause:** `workflow-8-flow-map.md` §Step 3 instructs "§Purpose — one paragraph at intent level. Remove the paragraph mentally; could a reader still guess what the flow is from the rest? If yes, the purpose was empty; rewrite." — no rule about verifying scenarios against current code discipline.

**Scope of blast radius:** Narrower than Gap 1-2 but catches a specific class (scenario-framing drift) that user ratification may or may not surface.

---

## Proposed workflow edits

### P2 (HIGHEST ROI — LOW effort, HIGH recurrence prevention)

**Edit to `.agent/skills/technical-writer/references/workflow-8-flow-map.md` §Step 5 (Implementation pointers + per-step child traces):**

Add a sub-section titled "When filing ruled-/resolution-/followup- learnings":

> When filing a new learning with title prefix `ruled-drift —`, `resolution —`, `fix —`, or `followup —`, and that learning's `source:` frontmatter cites a predecessor learning (e.g., the original drift-discovery), the author MUST call `arra_supersede(oldId, newId, reason)` in the same pass. Citing via `source:` frontmatter alone is not sufficient — it produces an implicit chain that `arra_search` surfaces as "both current", defeating the replacement semantics of P-001 "Nothing is Deleted".
>
> Verification: before committing the pass, run `arra_read(id=<oldLearningId>)` and confirm the response includes `superseded_by: <newLearningId>` and `superseded_at: <timestamp>`. If missing, call `arra_supersede` and re-verify.
>
> Exceptions: if the new learning is additive (e.g., extends the discovery with new evidence, not replacing it), document the non-supersede decision in the new learning body.

**Parallel edit to `.agent/skills/technical-writer/references/workflow-thread-resolve.md` Pass 1 resolution block:**

Add as step 5:

> 5. **Supersede sweep:** If the thread's resolution filed a ruled-drift learning or a resolution learning, verify that every drift-discovery learning cited in the ruled-drift's `source:` frontmatter has a matching `superseded_by` pointer. Missing pointers → file arra_supersede in the same pass per workflow-8 §Step 5 "When filing ruled-/resolution-/followup- learnings".

**Sibling-sync note:** Per AGENTS.md §5a, `workflow-8-flow-map.md` and `workflow-thread-resolve.md` live in both `mobiz-payment-gateway/.agent/skills/technical-writer/references/` and `bank-bot/.agent/skills/technical-writer/references/`. Edits must be applied to both copies in the same PR or immediately paired PRs per sibling-drift discipline.

### P3 (LOW effort, MEDIUM recurrence prevention)

**Edit to `.agent/skills/technical-writer/references/workflow-thread-resolve.md` Pass 2 (orphan scan):**

Current Pass 2 (roughly): "file workflow-bug learning on orphan-closed threads". Change to:

> **Pass 2 — Orphan-closed thread sweep (extended 2026-04-22):** for each thread closed without a human answer and without a fix-commit citation in the final message:
>
> 1. Extract the code areas mentioned in the thread's opening message (file paths + line ranges).
> 2. Grep those code areas at current HEAD (mobiz + sibling repos as scoped).
> 3. If code has changed materially since the drift was filed:
>    - File a ruled-drift learning citing the fix commit (git log --format=%H -S <drift keyword> --after=<drift date> to locate candidates).
>    - arra_supersede the original drift-discovery → new ruled-drift.
>    - Strip the anchor marker from the flow doc with a `[RESOLVED:YYYY-MM-DD]` label.
> 4. If code unchanged: file the existing `#workflow-bug + #thread-orphan` learning AND re-open the thread with a bump message naming the code evidence of unchanged behavior.
>
> The previous "file workflow-bug learning and strip marker" behavior risked hiding real resolutions (see `2026-04-20_workflow-bug-orphan-marker-thread-16-closed-without-answer.md` for the originating incident; session 2026-04-22 found both drift #1 and drift #2 had shipped fixes that this sweep would have detected).

### P4 (LOW effort, MEDIUM recurrence prevention)

**Edit to `.agent/skills/technical-writer/references/workflow-8-flow-map.md` §Step 3 (Author Purpose / Actors / Preconditions):**

Insert before "Preconditions — one-liner per condition":

> **§Purpose scenario verification (added 2026-04-22):** any scenario described in §Purpose that references specific bot behavior, timeout values, error paths, or cross-repo state MUST be verified against current code at the time of authoring. Process:
>
> 1. List every sibling-repo reference in the §Purpose paragraph (e.g., "bot timeout", "SCB popup", "KTB approver").
> 2. For each reference, grep the sibling repo's current HEAD for the code path that produces that scenario.
> 3. If the scenario reflects historical behavior (superseded by a PR), either (a) rewrite §Purpose to reflect current behavior, or (b) explicitly label the scenario as `// historical: pre-PR-N behavior, current behavior is X` and cite the canonical current behavior.
>
> Skipping this check produces scenario-framing drift — the doc reads internally consistent but describes obsolete behavior. Drift surfaces at ratification (typically caught by human questions) but is expensive to revise. Originating incident: `payout-auto-reconcile-from-statement.md` 2026-04-22 authoring pass described "timeout → MarkFailed" that reflected pre-PR-#83 SCB maker behavior; user question "ทำไมไม่เป็น waiting_to_review" forced same-session §Purpose rewrite to the A/B/C category taxonomy.

### P1 (HIGHEST recurrence prevention, HIGH effort — SEPARATE DESIGN CONVERSATION)

**New workflow: `workflow-10-cross-repo-sync.md`** (or major extension to `workflow-2-track-commit.md`).

Scope: when a sibling repo (bank-bot today; future repos TBD) commits a code change, trigger a scan of:
1. All mobiz flow docs that cite `<sibling-repo>/<path>:<line>` at older commits.
2. All Oracle drift-discovery learnings tagged `#repo:<sibling-repo>`.
3. All Oracle `[AWAITING_THREAD:N]` markers pointing to threads about sibling-repo code.

For each match: verify if the sibling commit fixes/invalidates the cited claim. If yes, queue the relevant mobiz-side update (doc edit + supersede).

Possible trigger shapes:
- (a) Periodic scheduled sweep (e.g., daily at 09:00 BKK).
- (b) Post-merge hook in sibling repo that files an `arra_inbox` handoff to mobiz pg-writer.
- (c) Manual invocation from brew-ops memory audit.

Heavy design decisions needed: scheduling infrastructure, trigger mechanism, SLA targets (how many days drift is acceptable?), scope (just bank-bot → mobiz, or bidirectional, or also sibling-to-sibling via arra-oracle-v3?). Recommend brew-ops owns this decision since it overlaps with workflow-5 memory audit territory.

**Without P1:** P2 + P3 + P4 reduce the frequency of gaps but don't eliminate them — manual vigilance from pg-writer is still required. With P1, the discipline becomes infrastructure.

---

## Sibling-sync footprint

All workflow edits in P2/P3/P4 must be applied to both `.agent/skills/technical-writer/references/` copies (mobiz-payment-gateway + bank-bot) per AGENTS.md §5a. Practically: one PR per repo, stacked or paired, with identical rule additions.

The `workflow-thread-resolve.md` is currently only in mobiz-payment-gateway per my read (bot-writer's W8/W9 support is newer); verify before editing.

---

## Decision ask

User response awaited on: "P2 only, P2+P3+P4 batch, or escalate to P1 full workflow design".

User already fired-and-forgot this handoff (prior message: "ผมอยากให้ escalate เรื่องนี้ ส่งไป handoff ไปให้ brew-ops") — brew-ops picks up on next wake.

Recommend brew-ops:
1. Start with P2 (add arra_supersede requirement to workflow-8 + workflow-thread-resolve) — ~15 min, low sibling-sync complexity, eliminates the Gap 2 class entirely.
2. Decide P3 + P4 as batch — ~30 min combined.
3. Queue P1 for a dedicated workflow-design session — this is the long-term fix and should not be rushed.

## Files likely to touch

- `kokarat/mobiz-payment-gateway/.agent/skills/technical-writer/references/workflow-8-flow-map.md`
- `kokarat/mobiz-payment-gateway/.agent/skills/technical-writer/references/workflow-thread-resolve.md`
- `kokarat/bank-bot/.agent/skills/technical-writer/references/workflow-8-flow-map.md` (sibling)
- `kokarat/bank-bot/.agent/skills/technical-writer/references/workflow-thread-resolve.md` (sibling, if exists)
- P1 would additionally touch: either new `workflow-10-cross-repo-sync.md` in both repos, OR major extension to existing `workflow-2-track-commit.md`.

## Related vault artifacts to review

- `2026-04-20_workflow-bug-orphan-marker-thread-16-closed-without-answer.md` — prior workflow-bug documenting Gap 3 class
- `2026-04-19_drift-technical-writer-sibling-workflow-8-copies.md` — prior sibling-drift incident, relevant to sibling-sync footprint of proposed edits
- `2026-04-22_ruled-drift-stale-lock-sweep-mislabels-uncertain.md` (mine, session 2026-04-22) — load-bearing ruling that Gap 1/2 would have produced automatically
- `2026-04-22_flow-withdrawal-queue-single-bot-transfer-drif.md` (mine, session 2026-04-22) — ratified-revision follow-up that Gap 1 would have triggered automatically

## Session retro trail

Brew-ops can follow full reasoning in chronological order:
- `ψ/memory/retrospectives/2026-04/22/10.50_flow-payout-auto-reconcile-from-statement.md`
- `ψ/memory/retrospectives/2026-04/22/11.15_flow-payout-auto-reconcile-ratification.md`
- `ψ/memory/retrospectives/2026-04/22/12.30_w9-drift-resolve-withdrawal-queue-single-bot-transfer.md`
- `ψ/memory/retrospectives/2026-04/22/13.00_w9-spot-fix-withdrawal-queue-dispatch-and-claim.md`

## Closure note

This handoff is fire-and-forget per workflow-8 §Escalation discipline. User's current session will end; brew-ops picks up asynchronously. If brew-ops wants clarification, file a reciprocal handoff to `pg-writer-oracle` territory or open an arra_thread naming this handoff as context.
