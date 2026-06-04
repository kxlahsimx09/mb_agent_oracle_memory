---
title: mb-next gap-sweep WAVE 2 — 2026-05-31 SESSION CLOSE: orchestrator team-dispatch,
tags: [orchestrator, team-dispatch, 2b, accepted, mb-next-payment-gateway, campaign-resume, gap-sweep, wave-2, pr-290-296, adr-19, adr-12, adr-15, adr-10, adr-9, residual-mdr, step-up-split, dpay-verify, adr-18, finish-script-orphan-pane, session-close, backlog, repo:arra-oracle-v3, fleet]
created: 2026-05-31
source: orchestrator session 2026-05-31 (wave 2); campaigns ng2write/ng2arch/ng2dpay
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next gap-sweep WAVE 2 — 2026-05-31 SESSION CLOSE: orchestrator team-dispatch,

mb-next gap-sweep WAVE 2 — 2026-05-31 SESSION CLOSE: orchestrator team-dispatch, 6 PRs (#290-296) open + awaiting user merge, 9 sub-decisions ratified, dpay ADR-18 all-PASS.

CONTEXT: resumed the wave-1 session-close backlog (prior learning 2026-05-31_mb-next-gap-sweep-campaign-2026-05-31-session-cl; PRs #282-289). User GO'd all 4 backlog buckets. Dispatched via workflow-2 team-dispatch.

6 PRs OPEN on kxlahsimx09/mb-next-payment-gateway (HEAD was e35a6e1; NONE merged — user merges):
- #290 (writer/ng2write, next-writer): ADMIN-005 audit-log query surface + WALLET-006 partner self-service MDR view + callback egress-IP identity (§ADR-9 EG1 — was missing from requirements).
- #291 (arch/ng2arch-a, next-architect): NEW §ADR-19 deposit QR-payload contract + deposit-fee config surface. Ratified: A-m1 fee/MDR base = GROSS, A-m2 per-client (MDR-profile) fee, A-m3 snapshot-at-CREATE.
- #292 (arch/ng2arch-b): §ADR-12 §Amendment pullout-task operator CRUD (PULLOUT-003/004). Ratified: B-p1 soft-delete + BLOCK delete/disable while in-flight drain. B-p2 USER SPLIT (the only non-lean): manual execute-now = NO step-up, BUT pullout-task CONFIG create/update (destination + timing) REQUIRES step-up — EXTENDS §ADR-2 S2 scope. User rationale: money-risk is defining where/when money goes, not pressing go on a vetted config.
- #294 (arch/ng2arch-c): §ADR-15 §Amendment wallet-high-balance alert + ops-report (MONITOR-005). Ratified: C-s1 severity P2 (channel), C-s2 hourly ops-report (port current).
- #295 (arch/ng2arch-d): §ADR-10 §Amendment residual-MDR routing (MONEY; TOPUP-002 + governs deposit lane). Ratified: D-s1 = R1 credit the is_owner system-residual wallet when a partner share is un-routable; ledger balanced; mdr_skip row cross-refs residual credit.
- #296 (arch/ng2arch-e): §ADR-9 §Amendment callback redirect SSRF posture (CALLBACK-003). Ratified: E-s1 = (a) DO-NOT-FOLLOW 3xx; record error_code=callback_redirect_blocked, normal retry/dead-letter, never fetch Location.

8 of 9 sub-decisions = architect lean (= preserve current prod); only B-p2 was a user refinement (split execute-now vs config-write step-up).

dpay ADR-18 re-verify (brew-ops/ng2dpay): ALL 6 entities PASS — merchants 32, clients 113, partners 14, mdr_profiles 33, pools 5, system_banks 58. No ratified §ADR-18 number contradicted (ADR-18 ratified no counts). dpay MCP functional, NO fabrication this time (ground-in-Go-source-first worked). Non-blocking drift BOUNCED to orchestrator (NOT ADR-18 errors): (1) system_bank bson pools→pool_ids field-name + legacy fee fields = schema/impl-pass detail; (2) STALE illustrative counts in OTHER ADRs — §ADR-8 '5/56 banks @50000'→ now 58 banks (6 capped), §ADR-10 '93 clients'→ now 113; (3) undocumented 'tel' field on merchant/client/partner. b3/b6/b2 conventions all confirmed.

next-writer verify-at-HEAD discipline paid off: SKIPPED topup-filter (already shipped TOPUP-004) + fleet-reboot-ack (FLEET-001/003/004 cover it) + PROV-008 3 open-Qs (already in revision-log); BOUNCED 3 that needed ADR amendments (→ became #294/#295/#296). Don't dispatch a writer to author what is really architect/ADR work.

PROCESS WIN: for the 3 bounced items, REUSED the live ng2arch architect via a follow-on maw team send (it offered) instead of spawning a 2nd concurrent next-architect — avoided the §6 mailbox-bleed risk of two same-role instances.

PROCESS BUG (3×): team-dispatch-finish.sh leaves an ORPHANED LIVE PANE every close (ng2write, ng2dpay, ng2arch) — shutdown --merge cleans the manifest but does not reap the alive-idle teammate pane; maw cleanup --zombie-agents misses it (alive≠zombie); the chat-watcher then fires repeated 'teammate idle' nudges. FIX (manual): after finish, tmux kill-window the lingering <role>-<campaign> window directly. Also leaves a husk worktree dir (empty .claude) when git de-registers the worktree but the idle process recreates cwd. Handoff filed to brew-ops (2026-05-31_19-14_brew-ops-team-dispatch-finish-orphan-pane-bug) recommending: kill panes by window-name glob BEFORE manifest removal + tolerate de-registered-dir-lingers.

REMAINING BACKLOG (next session): (a) EG1 source-IP allowlist propagation to DEPOSIT-001/PAYOUT-001 + callback onboarding doc (writer pass — §ADR-9 §Amendment 2026-05-29 EG1 names them but requirements only got the callback side in #290); (b) husk-dir sweep + finish-script fix (brew-ops); (c) optional refresh of stale illustrative counts in §ADR-8/§ADR-10 (56→58 banks, 93→113 clients). All 6 PRs await user review/merge.

Supersedes nothing (wave-1 session-close learning stays as the #282-289 record); this is the #290-296 wave-2 record.

---
*Added via Oracle Learn*
