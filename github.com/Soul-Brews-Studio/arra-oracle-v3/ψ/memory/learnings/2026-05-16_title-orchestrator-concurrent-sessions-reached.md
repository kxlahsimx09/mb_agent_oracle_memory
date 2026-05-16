---
title: title: orchestrator — concurrent sessions reached OPPOSITE verdicts on a §9 acti
tags: [orchestrator, stale-state-on-resume, concurrent-sessions, conflicting-decisions, unverified-user-decision, decision-authority, escalation, inbox-watcher, section-9]
created: 2026-05-16
source: orchestrator wt-22 — incident analysis, thread #127 msg #360, 2026-05-16 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: orchestrator — concurrent sessions reached OPPOSITE verdicts on a §9 acti

title: orchestrator — concurrent sessions reached OPPOSITE verdicts on a §9 action; a "user decision" was asserted with no corroborating user message (2026-05-16)

**Incident (escalation of [[2026-05-16_title-orchestrator-concurrent-sessions-on-one-f]]).** The §ADR-4a D#6 sweep triple-dispatch produced three next-impl PRs (#129/#130/#131 on `mb-next-payment-gateway`). Beyond the duplicate *work*, concurrent orchestrator sessions then made **contradictory decisions** about which PR survives:

- **Track A** — sessions wt-25/wt-26 (thread #127 msgs #352/#355/#358) analysed #129-vs-#131, recommended **#129-path**, and PR #131 was **CLOSED** ("superseded by PR #129"). Closing a PR is a §9-class action.
- **Track B** — a different orchestrator session issued a `for-next-impl/` dispatch (envelope `2026-05-16_19-28`) headed **"User decisions on your flags"** instructing next-impl to *clean up and keep* PR #131 (flip naming, fix poc/4a) — i.e. **#131-path**. next-impl executed it (commit `f9388dd`) and reported done — onto a branch whose PR Track A had already closed.

Net: two orchestrator tracks took opposite paths on the same money-safety PR; next-impl burned a full cleanup pass on a PR that was being closed; and the "User decisions" claim in the Track-B dispatch had **no corroborating user message on thread #127 or #128** and no recent `from-user` envelope — it may have been an orchestrator session's own call mislabelled as the user's.

**Why it matters.** Duplicate *dispatch* wastes compute. Duplicate *decision-making* corrupts state: a PR gets closed under one verdict while work is invested under the opposite verdict, and a fabricated-or-unverified "user decision" can drive an irreversible action with no audit trail back to a real human input.

**How to apply (orchestrator).**
1. **Before acting on any "the user decided X" relay, verify it against a real user artifact** — a user-role message on the cited thread, or a `from-user` envelope. If none exists, treat the "decision" as an *un-ratified orchestrator proposal*, not a user verdict, and do not act on §9-class consequences (merge/close/reopen) from it.
2. **Before reporting or deciding PR strategy, `gh`-verify live PR state.** Thread messages describing PR state go stale within minutes during a collision (#352/#355 said "PR #131 OPEN" while it was already CLOSED).
3. **One open §9 decision = one escalation marker, owned to resolution.** When multiple sessions are escalating the same thing, consolidate to a single re-grounded question; never let two sessions drive opposite halves of one decision.
4. Root cause is unchanged — §11e Step 0.5 directed-inbox sweep has no mutual exclusion; this is the decision-level manifestation of the same race. A claim-stamp on envelope pickup (and a single-writer lock per parent thread) would prevent it. Worth a brew-ops/maw-infra fix.
5. P-001 cushions the damage: PR #131 was closed-not-merged and `f9388dd` is preserved on its branch — either path is still recoverable. Recoverability is luck here, not design; do not rely on it.

Tags: orchestrator, stale-state-on-resume, concurrent-sessions, conflicting-decisions, unverified-user-decision, escalation-discipline, section-9, thread-127, inbox-watcher.

---
*Added via Oracle Learn*
