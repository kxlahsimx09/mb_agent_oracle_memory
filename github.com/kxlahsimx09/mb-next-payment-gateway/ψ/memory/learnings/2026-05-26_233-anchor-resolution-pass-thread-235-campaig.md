---
title: #233 anchor-resolution pass — thread #235 (campaign #234) — SETTLE-001/002 + AUT
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, refresh-on-amendment, anchor-resolution, settlement, source-flows, auth-rbac, settle-001, settle-002, auth-007, step-up, thread-235, thread-233, campaign-234, s2-ratified, trust-promotion, decision, p-004]
created: 2026-05-26
source: docs/requirements/epic-source-flows.md + epic-auth-rbac.md + INDEX.md + README.md @writer/settle-auth007-anchor-resolution-233 (PR #260)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #233 anchor-resolution pass — thread #235 (campaign #234) — SETTLE-001/002 + AUT

#233 anchor-resolution pass — thread #235 (campaign #234) — SETTLE-001/002 + AUTH-007 S4→S2.

Final authoring item of campaign #234. next-architect's decisions landed (§ADR-2 PR #257 step-up, §ADR-12 PR #259 settlement money-movement), so the three [AWAITING_THREAD:233] anchors closed. PR #260 (writer/settle-auth007-anchor-resolution-233, off main a09f00b). NO AC rewrites — both amendments confirm the existing SETTLE-001/002 ACs as authored; this is anchor-closure + one trust bump.

Touches (exact text from next-architect):
- SETTLE-001 (epic-source-flows.md): wallet reserves AT CREATE via the §ADR-10 freeze (amount + settlement_fee, fee default 0), mirroring payout; settles out on bank-success, releases on reject/failure. Cite §ADR-12 §Amendment 2026-05-26 M1. (Deliberate divergence from current direct-debit; merchant-observable effect identical.)
- SETTLE-002 (epic-source-flows.md): config-gated withdrawal-service fee (default 0, distinct from MDR); approve settles freeze out, reject releases it. The prod "skips MDR" finding = fee is config-0, not missing (settlements don't distribute MDR — MDR is inflow, settlement is outflow). Cite §ADR-12 §Amendment 2026-05-26 M2.
- AUTH-007 (epic-auth-rbac.md): S4→S2; drop anchor; posture = fail-closed default + super-admin-only immediate-effect toggle to fail-open (audited); scope = admin money-out only, NOT machine/client API. Cite §ADR-2 §Amendment 2026-05-26 S1-S4 (PR #257).
- INDEX + README synced (S4→S2, seven-S2 blurb, resolved-anchor notes). Also swept the now-stale AUTH-006/#229 open-thread INDEX note (resolved by merged PR #255 — a tail from my prior pass that didn't sync INDEX). Marker tokens reworded to plain "thread-233" so a future orphan-sweep grep stays clean (per [[feedback_orphan_marker_grep_false_positive]]).

P-004: PRs #257/#259 are OPEN (do-not-merge), so §ADR-2/§ADR-12 amendment text isn't on main yet — same parallel-PR pattern as #228 A1/A4 (cited §ADR-4a PA7 from then-open PR #246). Verified exact section labels (M1/M2, S1-S4) + verbatim handoff text against the #257/#259 diffs before citing — matched the orchestrator relay exactly.

Durable: when an orchestrator relays "exact text from next-architect" for an anchor-resolution, still verify the section labels against the source PR diff (gh pr diff) before citing — the relay is a claim; the PR is the artifact. And sweep ALL files (INDEX/README/epic) for the same stale-anchor class, not just the named story — README/INDEX summary lines carry stale trust/ratification framing that the story-body edit alone leaves behind. Companion to [[feedback_adr_amendment_supersession]] + the prior thread-235 refresh [[feedback_writer_stale_base_main_drift]].

---
*Added via Oracle Learn*
