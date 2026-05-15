---
title: W1 sub-amendment ratify pass — §ADR-4d Decision #8 call-shape sub-amendment (syn
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, sub-amendment, w1, adr-4d, adr-4d-d8-call-shape-sub-amendment, admin-verify-slip-now, sync-default-phase-1, phase-2-async-realtime-trigger-grounded, thread-92-closed, combined-baseline-ratify-landing-instance-4, production-grounded-sync-default-instance-1-NEW, writer-flagged-unratified-surface-instance-2, decision-preservation-atc2, verify-divergence-via-production-mcp-instance-5, drift-closure-as-decision-instance-6, trace-chain-32-links, pr:75]
created: 2026-05-12
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 sub-amendment ratify pass — §ADR-4d Decision #8 call-shape sub-amendment (syn

W1 sub-amendment ratify pass — §ADR-4d Decision #8 call-shape sub-amendment (sync default Phase-1 + Phase-2 async-via-Realtime triggers; thread #92 closed). Same-day pair with §ADR-4b D6 amendment thread #91 — both surfaced via DEPOSIT epic review session 2026-05-10-to-11.

# Pass shape

Combined baseline + ratify landing — instance #4 (durable threshold reached at #3, this is continuing-confirmation). Same-day double amendment pass demonstrates the pattern at scale: §ADR-4b D6 amendment (thread #91) morning + §ADR-4d D8 sub-amendment (thread #92) afternoon, both closing drifts surfaced by single writer review session.

Sub-amendment scope: narrower than full amendment — just locks the call shape that original Decision #8 left implicit. Preserves Decision #9 ratified stance (rate-limit deferred to impl) — explicit decision-preservation pattern (ATC2).

# 3 verifications + production audit

## Verification table

| Writer claim | Verified | Evidence |
|---|---|---|
| §ADR-4d D8 doesn't specify sync vs async | ✅ TRUE | adr.md:422 — no call-shape lock in original text |
| DEPOSIT-008 ACs imply sync | ✅ TRUE | epic-deposit.md:447-453 |
| Rapid-fire allowed by AC | ✅ TRUE | epic-deposit.md:452 |
| §ADR-5 Realtime substrate available | ✅ TRUE | ratified #decision |
| Thunder SLA 2-30s | ⚠️ PARTIAL | tail-case framing; actual p50 = 600ms |
| Both concerns lack production data | ✅ TRUE | NEW feature, no current-system equivalent |
| Decision #9 rate-limit deferred to impl | ✅ TRUE | adr.md:442 — user said "defer ไว้ก่อน" |

## Production audit (dpay MCP)

mobiz `/api/v1/deposits/:id/upload-slip` (Thunder inline at upload — closest production analog):
- 15,524 success 200 calls; 1,153 error 500 calls (6.9% Thunder error rate)
- avg = 2,065ms; p50 = 600ms; min = 145ms; max = 60,199ms
- < 1s: 77%; < 2s: 88%; < 5s: 94%; < 30s: 99%; > 30s tail: 1.6%
- No rapid-fire pattern observed (282 calls/day distributed across multiple admins)

→ Writer's "2-30s blocking every call" framing reflected worst case; reality is sub-second majority. Sync UX comfortable for 88%+ of calls.

# ATC1-ATC4 (wholesale-ratified)

- **ATC1** — Sync default Phase-1: HTTP 200 + verdict inline. EF 60s timeout. UI loading state during call.
- **ATC2** — Rate-limit / cooldown remains impl-level per Decision #9 (preserved; no architectural override).
- **ATC3** — Phase-2 async-via-Realtime upgrade triggers (grounded):
  - Latency: rolling 30d p99 > 10s sustained (current ~5s)
  - Error-retry: Thunder error rate > 10% sustained (current ~7%)
  - Concrete business driver: workflow scenario unobserved currently
- **ATC4** — NEW sub-pattern: production-grounded sync default with explicit Phase-2 trigger thresholds.

Phase-2 migration shape (when triggered): 200 → 202 + attempt_id + Realtime topic `slip_verify_attempts:{deposit_id}` push; append-only table semantics preserved (Decision #9).

# Patterns surfaced/confirmed

## Production-grounded sync default — instance #1 NEW (ATC4)

When Phase-1 endpoint has open call-shape question + current-system analog with measurable latency, prefer **sync default + Phase-2 async trigger with grounded thresholds**.

Distinct from "premature optimization avoidance":
- POA defers async without measuring; risks shipping unusable sync
- Grounded variant measures first; defines flip threshold upfront
- Trigger thresholds are quantitative + sustained (not point-in-time)

Brew-ops handoff candidate at instance #2.

## Writer-flagged unratified surface during user-story authoring — instance #2

After §ADR-4b D6 thread #91 (instance #1). Pattern: writer's W1 requirement pass surfaces a question that the source ADR didn't lock; story authoring blocks on architect ratification.

Lifecycle:
1. Writer authors story porting ratified ADR
2. Verification pass against code/data surfaces drift OR unratified surface
3. Writer opens arra thread with options + recommendation
4. Architect verifies + may run production MCP audit
5. Architect ratifies via amendment + writer handoff to update story

Candidate-durable at instance #2 (this pass).

## Decision-preservation pattern (ATC2)

When adjacent question is being ratified, explicitly preserve unrelated prior deferrals to prevent decision-creep. Sub-pattern of "minimal ratification scope."

ATC2 example: thread #92 is about call shape; rate-limit was deferred by Decision #9; ATC2 explicitly preserves that decision instead of opportunistically ratifying cooldown.

## Continuing-durable instances
- **Combined baseline + ratify landing** — instance #4
- **Verify-divergence-via-production-MCP at amendment time** — instance #5
- **Drift-closure-as-decision** — instance #6

# User dialogue trajectory

- Architect surveys thread #92 + verifies writer's 4-option framing against §ADR-4d D8 text + DEPOSIT-008 story
- User flags: "production data accessible via dpay MCP for Thunder latency — query it"
- Architect runs latency distribution audit on upload-slip endpoint (closest production analog)
- Audit reveals real distribution dramatically different from writer's framing (p50 600ms vs "2-30s for every call")
- Architect re-recommends (E) Sync default + grounded Phase-2 triggers
- User wholesale ratifies: *"เค ดีมาก เอาตามที่แนะนำเลย"*

User-pushback-as-design-force pattern instance #31 — user redirected architect from speculative option evaluation to production-grounded measurement. Pattern naming: *"query first, decide second."*

Pre-Input-5 instance count: 21 → 22 (Thunder latency distribution from mobiz upload-slip audit).

# Architecture-decision phase status post-pass

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.** Sub-amendment closes one drift class (open call shape) without opening new ones.

Trace chain: extends 31 → 32 links. Previous: `bffd971f` §ADR-13 amendment ratify → `42c30ed4` §ADR-16 ratify → `0eef3209` §ADR-4d D1 amendment ratify → `d5139d8e` §ADR-4b D6 amendment → this pass (chain continuing longest-in-repo).

# Same-day double amendment pass — process insight

Both thread #91 (§ADR-4b D6) and thread #92 (§ADR-4d D8) closed in single architect session 2026-05-12. Both surfaced via DEPOSIT epic review pass 2026-05-10-to-11 (writer-territory). Both ratifications were combined baseline + ratify landings on clean-from-main branches.

Pattern reinforces W1 *"verify writer's framing against production MCP before ratifying"* as architect default discipline. Writer flagged speculative concerns; architect grounded both via dpay MCP audit; decisions ratified with production-evidence backing.

This validates the **writer-architect coordination loop** at requirements-author time — drift surfaces at user-story authoring before stories are implemented = catches architectural debt before it ships.

# Threads

- **Closed:** #92 (with closing message + commit citation `c52cf32` + writer handoff for DEPOSIT-008 minor update)
- **Opened:** none

# Writer handoff — DEPOSIT-008 minor update

Thread #92 reply tags `@next-writer / @next-product-writer` for minor DEPOSIT-008 update:
- Sync ACs preserved verbatim (no rewrite required — they align with ATC1)
- Add traceability note linking to §ADR-4d D8 sub-amendment 2026-05-12
- Optionally add Phase-2 trigger criteria note in edge cases section
- Rate-limit open question (PR #72 restructure pass) stays open — ATC2 explicitly preserves Decision #9 deferral

# Sources

- thread:#92 (writer-flagged open shape; 4-option survey)
- dpay MCP audit 2026-05-12: `audit_trail` filtered upload-slip route; bucketed by duration_ms; grouped by status_code
- §ADR-4d Decision #4 (verify-slip EF body shape — same body powers sweep + verify-slip-now)
- §ADR-4d Decision #8 original text (call-shape unspecified)
- §ADR-4d Decision #9 (rate-limit deferred to impl; preserved by ATC2)
- §ADR-5 (Supabase Realtime substrate — Phase-2 trigger path)
- session-arc memory `project_session_arc_2026-05-10-to-11.md`
- Same-day sibling: §ADR-4b D6 amendment thread #91 / PR #63 / commit `d4ecc14`

# Commit anchor

`878189a` (sub-amendment combined-landing) on branch `architect/w1-adr4d-d8-sub-amendment-sync-default-2026-05-12`. PR #75 merged via `c52cf32`.

---
*Added via Oracle Learn*
