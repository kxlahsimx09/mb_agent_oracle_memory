---
title: orchestrator dispatch — #234 mb-next #228-loose-ends: refresh cleanup + settleme
tags: [orchestrator, decision-authority, ratify, escalate-money-security, relay-not-answer, nuanced-spec-relay, config-vs-structural, settlement, step-up, conflict-routing-to-owner, next-architect, next-writer, thread-234, two-orchestrator-session-hook-bug, repo:arra-oracle-v3, mb-next-payment-gateway]
created: 2026-05-26
source: parent thread #234 — #228 loose-ends campaign (msgs 1073-1098), 2026-05-26; all 4 PRs merged
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — #234 mb-next #228-loose-ends: refresh cleanup + settleme

orchestrator dispatch — #234 mb-next #228-loose-ends: refresh cleanup + settlement/step-up resolution.

Follow-on to campaign #228. Two sub-tracks: (1) refresh-on-amendment cleanup → next-writer; (2) resolve the pending #233 architect consult → next-architect. Outcome: 4 PRs all merged (#255 AUTH-006 cleanup, #257 §ADR-2 step-up, #259 §ADR-12 settlement money-movement, #260 #233 anchor-resolution). Closes the #225→#228→#234 chain.

DECISION-AUTHORITY PATTERNS (reinforce + extend #228's):
- USER ASKS PRECISE FACTUAL CLARIFICATIONS BEFORE BINDING — relay, don't answer (Principle 2a). On Q2 (settlement fee) the user didn't answer yes/no; they asked "is it config-0 (mechanism exists, disabled) or structurally absent?" I relayed that to next-architect (who made the MDR-free claim) rather than guessing. The answer (CONFIG-0: a dormant rate-driven settlement_fee mechanism, briefly live, reframed as a withdrawal-service fee = payout_fee analog, NOT MDR) materially changed the framing and led the user to ratify PRESERVE-config-gated-default-OFF. Lesson: a sharp user clarification can flip a "looks-resolved" finding; route it to the verifying agent for a code+data answer before binding.
- USER GIVES NUANCED SPECS, NOT MENU PICKS — relay the exact spec. On Q3 (AUTH-007 step-up posture) the user didn't pick plain fail-open OR fail-closed; they specified "fail-closed DEFAULT + super-admin-only runtime toggle to fail-open, effective immediately (OTP-outage escape hatch)." Orchestrator must carry the verbatim spec to the agent (next-architect bound it into §ADR-2), not collapse to one of the offered options.
- ESCALATE money/security, auto-decide parity: Q1 wallet-timing (applies ratified §ADR-10) decided by architect directly; Q2 (revenue) + Q3 (security/§9) escalated to user. Same pattern as #228 A1/A4.
- VERIFY DEFERRED LISTS AGAINST HEAD: next-writer's cleanup found #120/#132 already reconciled on main (only AUTH-006 was genuinely stale) — reported already-done honestly. (Filed separately by next-writer.)

CONFLICT-RESOLUTION ROUTING: PR conflicts go to the PR's OWNING agent — #259 (adr.md) conflict → next-architect; epic-file PRs → next-writer. Orchestrator never edits (orchestrator-guard hook); relays the take-both-hunks instruction; agent resolves §9-safe (--force-with-lease, never plain --force).

RECURRING FLEET BUG (still open, candidate brew-ops): with two concurrent orchestrator sessions (this = wt-20, the load-test campaign #201 = wt-21), the inbox-loop-closure Stop-hook's orchestrator whole-dir exception repeatedly false-blocked wt-20 on wt-21's #216 envelopes. Confirmed TRANSIENT/SELF-HEALING — the watcher §151-routes each #216 to wt-21, wt-21 archives within ~1 min, block clears. No harm, but noise. Fix: scope the orchestrator Stop-hook by §151 owner (worktree match), not whole-dir. Logged in the #228 learning too.

---
*Added via Oracle Learn*
