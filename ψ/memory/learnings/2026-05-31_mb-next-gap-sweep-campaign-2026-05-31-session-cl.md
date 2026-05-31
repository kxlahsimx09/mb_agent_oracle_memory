---
title: mb-next gap-sweep campaign — 2026-05-31 SESSION CLOSE: 9 PRs merged, provisionin
tags: [orchestrator, team-dispatch, mb-next-payment-gateway, campaign-resume, gap-sweep, provisioning, adr-18, session-close, backlog, pr-282-289, repo:arra-oracle-v3, fleet]
created: 2026-05-31
source: orchestrator session 2026-05-31; main HEAD e35a6e1; PRs #282-289 merged
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next gap-sweep campaign — 2026-05-31 SESSION CLOSE: 9 PRs merged, provisionin

mb-next gap-sweep campaign — 2026-05-31 SESSION CLOSE: 9 PRs merged, provisioning + key-lifecycle + fraud-badge all landed. Resume point for remaining backlog.

Long orchestrator session closed at user request ("พอแล้ว/สรุป"). main HEAD e35a6e1, 0 open PRs, fleet clean (3 keeper windows, 0 worktrees, 0 teams, 0 agent procs). A depqrfee (ADR-19 deposit QR/fee) dispatch was started then immediately cancelled when the user said stop — killed mid-draft, nothing committed/pushed/leaked.

ALL MERGED THIS CAMPAIGN (9 PRs, in order):
- #282 quick-wins (CALLBACK-001 30s timeout §ADR-9 WC9; AUTH-007 step-up per-purpose replay §ADR-2 S3; INDEX PAYOUT-011 deferred §ADR-4a RR4)
- #283 4 ADR-backed AC (PAYOUT-001 unroutable-by-band §ADR-8 AF2; MATCH-003 payout-driven trigger §ADR-4a RR1; WALLET-003 is_owner §ADR-10 D1; CLIENT-001 cached-4xx replay §ADR-11 C4)
- #284 3 HIGH ADR amendments (§ADR-12 Settlement Confirm-Review CR1-4; §ADR-12 DT-override DTO1-4 step-up REQUIRED; §ADR-13 admin deposit read-surface DL1-3)
- #285 SETTLE-002 confirm-review story S3→S2 + DTR-001 reconciliation-override story
- #286 §ADR-13 DL3 read-time fraud-preview advisory badge RATIFIED (user kept the badge — DL3 carve-out→ratified)
- #287 §ADR-18 Admin Entity Provisioning (6 entities; 6 policy sub-decisions ratified — user: b1 OFF-until-reviewed, b2 ==fee, b3 soft-delete+block-nonzero-wallet, b4 sub-client admin-only Phase-1, b5 Supabase Vault, b6 method[] SOFT convention)
- #288 epic-entity-provisioning.md (PROV-001..007, 7 stories) reflecting all 6 ratified policies
- #289 PROV-008 client API-key rotation+revocation (writer-only on §ADR-2 GW6 substrate; step-up not required per §ADR-2 S2)

KEY USER DECISIONS (binding): review-not-waiting_to_review; plain DT no wallet/freeze (pure status reconciliation); DT step-up required; keep read-time fraud badge; provisioning b1 OFF / b4 admin-only Phase-1 / b6 soft (b1+b6 overrode architect lean).

REMAINING BACKLOG (NOT dispatched; needs user GO — money/new-ADR escalate per charter §9):
- 2 new-ADR: deposit QR/fee config (ADR-19 — PromptPay QR payload in DEPOSIT-001 response contract + deposit-fee config surface + MDR-base question; PARTLY drafted then cancelled, re-dispatch fresh) ; pullout-task operator CRUD (155 docs prod, source-flows).
- ~6 medium amendments: admin audit-log query surface (ADMIN-005); partner self-service MDR revenue view (WALLET-006); monitoring wallet-high-balance alert (MONITOR-005) + hourly/daily ops-report; topup filter + residual-MDR routing; callback redirect-chain + gateway-identity header; fleet reboot-ack health.
- 3 PROV-008 open-questions flagged by next-writer (not blocking): (a) rotation grace/overlap window (Phase-1 single key pair, in-place replace = brief auth gap); (b) client self-service rotation (admin-only now); (c) key-expiry ↔ KV-cache interaction (GW6 invalidates on column-change only, not time-based expiry).
- dpay-finder MCP: connection healthy (claude mcp list = Connected; teammates can call it) but the dpay-finder SUBAGENT was unreliable twice (fabricated once, looped once) — ground entity facts from Go source + cross-check; a fresh 6-collection dpay re-verification for ADR-18 is a recorded non-blocking follow-up.

Supersedes prior resume learnings 2026-05-30 + 2026-05-31_archamd1 + 2026-05-31_close-all.

---
*Added via Oracle Learn*
