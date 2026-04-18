---
title: Decision (2026-04-18, GMT+7) — technical-writer workflow-2 Escalation moved to t
tags: [brew-ops, technical-writer, workflow, escalation, decision, arra_thread, repo:cross, anchor-discipline, p-001, p-003]
created: 2026-04-18
source: 2026-04-18 brew-ops session, triggered by CC request on mobiz PR f44cf44 ConfirmPayoutCompleted wallet deduction invariant
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Decision (2026-04-18, GMT+7) — technical-writer workflow-2 Escalation moved to t

Decision (2026-04-18, GMT+7) — technical-writer workflow-2 Escalation moved to thread-first pattern

Trigger: a CC request landed in a mobiz PR ("Per workflow-2-track-commit.md §Escalation, this PR touches financial behaviour … please confirm the invariant matches your intent in f44cf44"). Human raised: CC-in-PR is hard to see and gets buried on merge — should use arra_thread instead.

Observation: Both mobiz and bank-bot versions of `workflow-2-track-commit.md` Escalation sections used PR-body CC for verification asks (`CC code_reviewer in the PR description`, `include human review as explicit reviewer on the PR`). But the same workflows already have:
- Step 0 that sweeps `[AWAITING_THREAD:<id>]` anchors from docs and resolves them via `arra_thread_update(status="answered")` → cascading doc edits.
- DoD line 269-ish requiring every `arra_thread(...)` in a pass to have a paired `[AWAITING_THREAD:<id>]` marker.

The infrastructure existed; the escalation was asymmetrically using the weaker channel (PR comments) for the stronger class of ask (invariant verification).

Change applied:
- `mobiz .../workflow-2-track-commit.md` §Escalation — rewritten thread-first. Financial-behavior claims now open `arra_thread` + anchor `[AWAITING_THREAD:<id>]` + PR body carries single-line pointer only. Security-sensitive and invariant-level asks follow the same pattern.
- `bank-bot .../workflow-2-track-commit.md` §Escalation — mirror of above. Added bank-bot-specific category for cross-repo contract claims (shared payload / HMAC / MDR / OTP) where both the mobiz writer and the bank-bot writer need to ratify at the same commit — thread is the joint ratification point.

Why this matters beyond this PR:
- PR comments and `reviewers: [...]` die with the merge — `arra_search` cannot index them, future audits (workflow-5 §7 cross-refs) cannot see them, next agent reads the doc without knowing a verification is pending.
- `arra_thread` persists per P-001, carries searchable `title + message`, and the `[AWAITING_THREAD:<id>]` marker is greppable by Step 0 of the next W2 run — resolution is automatic.
- P-003 (External Brain, Not Commander): threads are input to the next agent's decision-making. PR review comments are ephemeral commander-mode messages addressed to a specific human at a specific moment.

How to apply (for writers):
1. When about to escalate a claim (financial / security / invariant / cross-repo contract):
   `arra_thread(title="verify: <claim>", message="<claim> @ <commit>; source: <file:line>; reviewer: <@role>")`
2. Insert `[AWAITING_THREAD:<id>]` in the doc at the exact section.
3. PR body: "Pending verification: `arra_thread_read(<id>)` — see `[AWAITING_THREAD:<id>]` markers."
4. Reviewer responds in the thread + calls `arra_thread_update(status="answered")`.
5. Next W2 pass Step 0 sweeps the anchor, edits the doc to resolve (ratify / correct / document the answer), closes the thread.

Who did this edit: brew-ops (me), with human approval, because the change is a meta-workflow pattern (anchor discipline) not domain content (what the claim asserts). Technical-writer peer roles can ratify or counter-edit on their next pass; if they disagree, they should revert and explain via `arra_thread`.

Ironic/self-consistent note: this very learning is itself a claim that could be verified via thread. I am not opening one because the change is additive (upgrade from weaker to stronger discipline) and reversible (peer writers can revert). If a technical-writer disagrees, they can revert and open a thread citing this learning.

---
*Added via Oracle Learn*
