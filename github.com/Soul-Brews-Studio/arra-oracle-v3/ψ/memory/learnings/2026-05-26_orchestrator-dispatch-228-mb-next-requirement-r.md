---
title: orchestrator dispatch — #228 mb-next requirement remediation: ratify + author tw
tags: [orchestrator, decision-authority, fan-out, accepted, requirement-remediation, ratify, author, sequential-merge-cadence, escalate-money-safety, next-writer, next-architect, thread-228, two-orchestrator-session-hook-bug, verify-deferred-list-against-head, repo:arra-oracle-v3, mb-next-payment-gateway, fleet]
created: 2026-05-26
source: parent thread #228 — mb-next requirement remediation campaign (msgs 1019-1082), 2026-05-26; closed all 9 PRs merged
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — #228 mb-next requirement remediation: ratify + author tw

orchestrator dispatch — #228 mb-next requirement remediation: ratify + author two-track fan-out, sequential merge cadence.

Follow-on to the #225 review campaign. User (acting as orchestrator) authorized two parallel tracks: (1) ratify the 4 in-epic divergences A1-A4 → next-architect; (2) author the net-new + missing-epic surfaces → next-writer. Outcome: 7 net-new epics (source-flows, auth-rbac, callback-delivery, admin-audit, fleet-control, monitoring, client-api) + 2 existing-epic refreshes (A1 PAYOUT-010 always-on per-bank maintenance-cancel; A4 DEPOSIT-003/004 slip-bearing escalate-not-expire), 9 PRs all merged, ~34 ratified-source stories.

DECISION-AUTHORITY PATTERNS (for future Step-1 confidence):
- Two-track ratify+author fan-out: user authorized explicitly → HIGH. Architect-authority items (A2 fair-router filter, A3 rate-limit NFR) ratified directly; product/money-safety items (A1 overnight frozen-funds, A4 client-facing terminal+callback) ESCALATED to user, who ratified matching the architect's recommendations (A1 KEEP, A4 ALIGN-with-current-#460). Pattern: escalate money-safety/product/security divergences; auto-ratify parity/port-fidelity ones.
- MERGE CADENCE: when a multi-PR doc campaign produced inter-PR glossary/INDEX append-region conflicts, the user chose SEQUENTIAL (merge each PR → next branch off merged main, conflict-free) over BATCH (parallel branches, resolve at merge). Revealed preference: clean conflict-free PRs + small focused reviews, accepts more merge round-trips. Default to offering sequential for this user on multi-PR requirement-doc campaigns.
- Refresh-on-amendment cleanup: user wants it as a SEPARATE pass/campaign, not folded into the net-new authoring (keeps scope clean). Confirmed again here (campaign #234).

WORKER DISCIPLINE worth propagating: next-writer, given a "deferred" cleanup dispatch list (#120/#132/AUTH-006), verified each item against HEAD before authoring — #120 + #132 were already reconciled in earlier merged commits, so the batch collapsed to one real edit (AUTH-006). It reported already-done honestly instead of fabricating edits to match the brief. A deferred dispatch list can go stale between flagging and execution; verify-against-HEAD-first.

FLEET BUG (candidate brew-ops fix): with two concurrent orchestrator sessions (wt-20 = this campaign, wt-21 = campaign #201 load-test), the inbox-loop-closure Stop-hook's orchestrator whole-dir exception false-blocked wt-20 on wt-21's #216/#201 envelopes. §214 says the sweep-scope and Stop-hook gate "never disagree" — they did here. Fix: scope the orchestrator Stop-hook by §151 per-session owner (worktree match), not whole-dir, so concurrent orchestrator sessions don't false-block on each other. wt-21 always archived its own #216 envelopes, so no harm — but it generated noise + near-circuit-breaker trips.

Campaign #234 (loose-ends follow-on) still open at close of #228: #235 cleanup done+merged (#255); #236 next-architect resolved #233 — Q1 wallet-timing decided (freeze-at-CREATE §ADR-10), Q2 settlement-MDR-free + Q3 AUTH-007 step-up escalated to user.

---
*Added via Oracle Learn*
