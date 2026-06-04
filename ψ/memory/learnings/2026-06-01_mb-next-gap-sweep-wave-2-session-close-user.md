---
title: mb-next gap-sweep WAVE 2 — SESSION CLOSE (user "พอแล้ว"): 6 PRs (#290-296) ratif
tags: [orchestrator, team-dispatch, session-close, mb-next-payment-gateway, campaign-resume, gap-sweep, wave-2, pr-290-296, readability-pass, writer-vs-architect, ac-prose, adr-19, adr-12, adr-15, adr-10, adr-9, residual-mdr, step-up-split, dpay-verify-adr-18, finish-script-orphan-pane, backlog, repo:arra-oracle-v3, fleet]
created: 2026-06-01
source: orchestrator session 2026-05-31 wave 2 close; campaigns ng2write/ng2arch/ng2dpay/ng2fix/ng2fix2
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next gap-sweep WAVE 2 — SESSION CLOSE (user "พอแล้ว"): 6 PRs (#290-296) ratif

mb-next gap-sweep WAVE 2 — SESSION CLOSE (user "พอแล้ว"): 6 PRs (#290-296) ratified + readability-passed, ALL await user review/merge. Resume point for remaining backlog.

Supersedes the earlier same-day wave-2 learning (2026-05-31_mb-next-gap-sweep-wave-2-2026-05-31-session-clos) — that one predated the readability work below.

ALL 6 PRs OPEN on kxlahsimx09/mb-next-payment-gateway, NONE merged (user merges; base main @ e35a6e1):
- #290 (writer/ng2write): ADMIN-005 audit-log query + WALLET-006 partner self-service MDR view + callback egress-IP identity (§ADR-9 EG1).
- #291 (arch/ng2arch-a): NEW §ADR-19 deposit QR-payload + deposit-fee config. Ratified: GROSS base · per-client (MDR-profile) · snapshot-at-create. READABILITY-FIXED (commit 60cf6ba — DEPOSIT-002 AC#1 + DEPOSIT-001 QR ACs).
- #292 (arch/ng2arch-b): §ADR-12 §Amendment pullout-task operator CRUD (PULLOUT-003/004). Ratified: soft-delete + BLOCK-on-in-flight-drain; B-p2 USER SPLIT = execute-now NO step-up, but pullout CONFIG create/update (dest+timing) REQUIRES step-up (EXTENDS §ADR-2 S2). READABILITY-FIXED (f5f412b).
- #294 (arch/ng2arch-c): §ADR-15 §Amendment wallet-high-balance alert + ops-report (MONITOR-005). Ratified: severity P2 (channel) · hourly ops-report. READABILITY-FIXED (9c0b7aa).
- #295 (arch/ng2arch-d): §ADR-10 §Amendment residual-MDR routing (MONEY; TOPUP-002, governs deposit lane). Ratified: R1 = credit the is_owner system-residual wallet when a partner share is un-routable; ledger gross = client-net + Σpartner + residual; mdr_skip row cross-refs residual credit. READABILITY-FIXED (2180fca; ledger eq byte-identical).
- #296 (arch/ng2arch-e): §ADR-9 §Amendment callback redirect SSRF posture (CALLBACK-003). Ratified: do-not-follow 3xx; recorded error_code='callback_redirect_blocked', normal retry/dead-letter, never fetch Location. READABILITY-FIXED (363b423).

9 sub-decisions ratified (8 = architect lean; the ONE user refinement = B-p2 step-up split). dpay ADR-18 re-verify: ALL 6 entities PASS (merchants 32, clients 113, partners 14, mdr_profiles 33, pools 5, system_banks 58); dpay MCP functional, no fabrication.

KEY PROCESS LEARNING (user correction): requirement-story/AC prose is the WRITER's job, not the architect's — even when the architect authors the ADR. The architect wrote dense run-on ACs across all 5 PRs it touched; a next-writer readability pass (campaigns ng2fix + ng2fix2, prose-only, meaning-locked) fixed all of them. Going forward: scope architect to decision + skeletal pointers, dispatch writer for AC prose (or a writer readability pass before PR review). See learning 2026-05-31_orchestrator-dispatch-requirement-storyac-prose.

REMAINING BACKLOG (next session — NOT done):
1. EG1 source-IP propagation: §ADR-9 §Amendment 2026-05-29 EG1 egress-IP allowlist must also land in DEPOSIT-001 / PAYOUT-001 + the callback onboarding doc (wave 2 only got the callback side in #290). Writer pass.
2. husk-dir sweep + team-dispatch-finish.sh orphan-pane fix — handoff filed to brew-ops (2026-05-31_19-14_brew-ops-team-dispatch-finish-orphan-pane-bug). The finish script left an orphaned LIVE pane on EVERY close this session (ng2write/ng2dpay/ng2arch/ng2fix/ng2fix2 — 5×); orchestrator killed each window manually. Real fix: kill panes by window-name glob BEFORE manifest removal.
3. Optional: refresh stale illustrative counts — §ADR-8 '56 banks'→58 (6 capped), §ADR-10 '93 clients'→113 (from dpay re-verify).

FLEET STATE AT CLOSE: all ng2* campaign windows/worktrees closed. One unrelated window 'next-architect-nextteam' remains (NOT this session's — left untouched). 6 PRs await user merge.

---
*Added via Oracle Learn*
