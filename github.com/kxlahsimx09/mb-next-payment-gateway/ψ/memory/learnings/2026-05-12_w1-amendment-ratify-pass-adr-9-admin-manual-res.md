---
title: W1 amendment ratify pass — §ADR-9 admin manual resend-callback endpoint PROMOTED
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-9, admin-manual-resend-callback, promoted-to-phase-1, thread-93-closed, writer-flagged-unratified-surface-instance-3-DURABLE, production-grounded-promotion-instance-1-NEW, f3-ratify-drift-instance-1-NEW, bundle-fix-in-adjacent-amendment-instance-1-NEW, h3-fix-bundle, combined-baseline-ratify-landing-instance-5, per-action-actor-triple-instance-8, coordination-rule-instance-7, verify-via-production-mcp-instance-6, same-day-triple-amendment-pass, phase-1-architectural-surface-19-decisions-0-provisional, trace-chain-33-links, pr:76, next-writer-handoff-deposit-012]
created: 2026-05-12
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratify pass — §ADR-9 admin manual resend-callback endpoint PROMOTED

W1 amendment ratify pass — §ADR-9 admin manual resend-callback endpoint PROMOTED to Phase-1 from "admin-API ADR future" deferral (combined baseline + pass-2 ratify; thread #93 closed). Same-day triple-amendment pass with §ADR-4b D6 (defer thread #91) + §ADR-4d D8 (sync default thread #92).

Bundles §H3-Fix correcting §ADR-4d D1 amendment H3 RBAC permission strings from prefix format (drift from F3 baseline) to flat mobiz-parity format (per F3 ratify 2026-05-08 pass 1.5 revise).

# Pass shape

Combined baseline + ratify landing — instance #5 (continuing durable). Single-commit landing on clean-from-main branch.

Writer-flagged unratified surface during user-story authoring — instance #3 (DURABLE threshold reached per W1 §Port-from-mobiz protocol rule 2). Pattern brew-ops handoff for W1 workflow doc.

# Production audit grounding

dpay MCP audit `audit_trail` filtered `route_match='/api/v1/deposits/:id/resend-callback'` (27-day window 2026-04-15 → 2026-05-12):
- 17,797 total calls (~659/day)
- 16,605 success (93.3%)
- Actor mix: sub-client 65% / admin 32% / client 3% (validates §ADR-13 amendment F1 3-tier matrix)
- 940 admin sync-mode failures at avg 94s (16% admin error rate)
- 252 permission denials (tenant + tier protection)

→ Defer = forced ~659 daily direct-DB recoveries = contradicts next-system self-service posture. Substrate already ratified; amendment wires endpoint without new substrate.

# AM1-AM8 + §H3-Fix (wholesale-ratified)

- **AM1** — Promote endpoint to Phase-1
- **AM2** — 2-path actor matrix (admin + client tier; sub-client folds via F1; no customer path)
- **AM3** — 202 fire-and-forget all tiers (production-grounded; eliminates sync 16% error class)
- **AM4** — Reset semantic = append (new callback_queue row + companion callback_attempts with triggered_by_actor triple per F2; per-action actor triple instance #8)
- **AM5** — Terminal-only pre-condition + concurrent race-guard (409)
- **AM6** — Layer-1 tenant scope check (coordination-rule instance #7)
- **AM7** — NEW `deposit:resend-callback` + `payout:resend-callback` actions (split-for-granularity per §ADR-13 D3; flat namespace per F3)
- **AM8** — Writer-flagged unratified surface pattern instance #3 DURABLE
- **§H3-Fix** — bundle §ADR-4d D1 amendment H3 prefix → flat format correction

Symmetric scope covers payout-side resend (PayoutController.ResendCallback analog).

# Patterns surfaced/confirmed

## Writer-flagged unratified surface during user-story authoring — instance #3 DURABLE

After §ADR-4b D6 thread #91 (instance #1) + §ADR-4d D8 thread #92 (instance #2) + this §ADR-9 thread #93 (instance #3). **3-instance threshold reached.** Lifecycle:

1. Writer authors W1 user story porting ratified ADR
2. Writer's verification (code/data/MCP) surfaces drift OR unratified surface OR deferred-surface-with-strong-evidence
3. Writer opens arra thread with options + recommendation
4. Architect verifies + production MCP audit
5. Architect ratifies amendment (defer / promote / shape-lock / drift-fix)
6. Writer handoff to update/remove/author user story

Brew-ops handoff for W1 workflow doc as durable lifecycle pattern.

## Production-grounded promotion sub-pattern — instance #1 NEW

Mirror of "production zero-evidence deferral" (§ADR-4b D6, 4 calls / 27d / 0 matches → defer). This pass: 17,797 calls / 27d / 3 actor tiers → promote. Same architectural primitive (production MCP audit) grounds DEFERRAL or PROMOTION symmetrically.

Trigger rule: when ADR text defers a surface AND production data later emerges via MCP, audit drives direction:
- Zero evidence → defer (preserves Phase-1 minimal surface)
- Heavy evidence → promote (preserves operational self-service)
- Mixed evidence → shape-lock (preserves architectural decision space)

Brew-ops handoff candidate at instance #2.

## F3-ratify-drift in cross-section amendments authored pre-F3-revise — instance #1 NEW (via §H3-Fix)

§ADR-4d D1 amendment H3 authored 2026-05-07 (F3 baseline = prefix); ratified 2026-05-09 wholesale (post F3 ratify 2026-05-08 = flat) without drift catch.

Pattern: when cross-cutting decision (F3 namespace format) is revised mid-arc, all in-flight amendments authored pre-revise carry obsolete format unless explicitly re-checked. Open question: should retroactive audit be a process step for cross-cutting decision revises? Candidate-durable.

## Bundle-fix-in-adjacent-amendment sub-pattern — instance #1 NEW

User chose to bundle §H3-Fix into §ADR-9 amendment rather than open separate thread. Trigger conditions:
1. Drift is mechanical not architectural
2. Fix is contained (single text replacement)
3. Explicit traceability preserved (§H3-Fix block with explanatory parenthetical at the fix site)
4. User opts-in (not architect-imposed scope creep)

Bundle saves one ratify cycle. Distinct from scope creep. Brew-ops handoff candidate at instance #2.

## Continuing-durable instances
- **Combined baseline + ratify landing** — instance #5
- **Per-action actor triple** — instance #8 (triggered_by_actor triple in callback_attempts)
- **Coordination-rule pattern (Layer-1 tenant scope)** — instance #7
- **Verify-divergence-via-production-MCP at amendment time** — instance #6

# Same-day triple amendment pass (2026-05-12)

| Time | Thread | Decision | Production evidence | PR |
|---|---|---|---|---|
| Morning | #91 §ADR-4b D6 | DEFER Phase-2 | 4 calls / 27d / 0 matches | #63 (d4ecc14) |
| Afternoon | #92 §ADR-4d D8 | SYNC DEFAULT Phase-1 | upload-slip p50 600ms (proxy) | #75 (c52cf32) |
| Evening | #93 §ADR-9 admin resend | PROMOTE Phase-1 | 17,797 calls / 27d / 3 tiers | #76 (20fc6ce) |

All three decisions production-audit-grounded via dpay MCP. Pattern reinforces writer-architect coordination loop + production-evidence-as-deciding-vote. Trace chain 30 → 33 links over single day.

# User dialogue trajectory

- Writer survey of epic-deposit gap analysis → flags resend-callback as heaviest-used admin endpoint
- Architect verifies §ADR-9 deferral text + dpay MCP audit confirms 17,797 calls + 3-tier mix + 16% admin sync error class
- Architect frames decision matrix vs D6 (defer) and D8 (sync); recommends promote + AM1-AM8 (with prefix RBAC in AM7 ERROR)
- User corrects AM7 RBAC prefix → flat per F3 ratify (*"rbac เราใช้ เป็น flat แล้วนะ"*) + ratifies rest wholesale
- Architect dpay MCP query of roles collection confirms flat namespace structure; surfaces secondary drift in §ADR-4d D1 amendment H3 prefix
- User chooses AM7-β (NEW `deposit:resend-callback` action over verbatim `deposit:update` port) + bundle §H3-Fix
- Wholesale ratify *"deposit:resend-callback ... นอกนั้นข้ออื่นผมโอเคหมด"* + *"Bundle fix"*

User-pushback-as-design-force pattern instance #32 — user-redirect on RBAC format caught architect drift at amendment-time + surfaced cross-section H3 drift via memory of recent decisions. Pattern: user memory of recent ratifications is a forensic check against author drift.

Pre-Input-5 instance count: 22 → 23 (dpay MCP audit + roles collection structure verification within same pass).

# Architecture-decision phase status post-pass

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.** Corrective amendment promotes one deferred surface to Phase-1 + bundles one cross-section drift fix without opening new provisional.

Trace chain: extends 32 → 33 links. Sequence: `bffd971f` §ADR-13 amend → `42c30ed4` §ADR-16 → `0eef3209` §ADR-4d D1 → `d5139d8e` §ADR-4b D6 → `46bc6d02` §ADR-4d D8 → this pass.

# Writer handoff — DEPOSIT-012 fresh authoring

Thread #93 reply tags `@next-writer / @next-product-writer` for DEPOSIT-012 authoring from §ADR-9 amendment text. Similar pattern to DEPOSIT-007/008 authoring from §ADR-4d ratified text.

Recommended story shape: endpoint paths AM2 + 202 response shape AM3 + append semantic AM4 + terminal pre-condition AM5 + Layer-1 tenant scope AM6 + RBAC AM7. Symmetric payout-side coverage if PAYOUT epic is also being authored.

# Sources

- thread:#93 (writer-flagged production-usage signal + 4-question survey + 3-tier audit)
- dpay MCP: `audit_trail` filtered resend-callback route; `roles` collection structure
- mobiz code: `controllers/DepositController.go:2409 ResendCallback` + `PayoutController.ResendCallback` (symmetric)
- §ADR-9 Decision #2 (event_id idempotency-key) + Decision #5 (dead-letter) + Decision #6 (callback_attempts append-only)
- §ADR-13 amendment F1-F4 (actor model + create-time triple + RBAC flat + tenant scope) + D3 (resource-split discipline)
- §ADR-11 (idempotency-exemption)
- §ADR-4d D1 amendment H3 (precedent for split actor-tier; drift target for §H3-Fix)
- §ADR-4d D8 sub-amendment 2026-05-12 ATC4 (production-grounded shape selection sub-pattern parallel)
- Vault learnings: 2026-04-19 + 2026-04-21 callback-resend-idempotency regression class
- session-arc memory `project_session_arc_2026-05-10-to-11.md`
- Same-day siblings: §ADR-4b D6 amendment thread #91 / PR #63 + §ADR-4d D8 sub-amendment thread #92 / PR #75

# Commit anchor

`82aa11b` (amendment combined-landing on clean-from-main branch `architect/w1-adr9-amendment-admin-resend-callback-2026-05-12`). PR #76 merged via `20fc6ce`.

---
*Added via Oracle Learn*
