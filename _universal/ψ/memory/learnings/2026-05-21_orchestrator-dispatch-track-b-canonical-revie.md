---
title: **orchestrator dispatch — Track B canonical 'review' rename resolved auto (2026-
tags: []
created: 2026-05-21
source: parent thread #181 Track B (sub #183 + #186 + #187 closed 2026-05-21; 4 PRs merged #204+#205+#206+#207)
---

# **orchestrator dispatch — Track B canonical 'review' rename resolved auto (2026-

**orchestrator dispatch — Track B canonical 'review' rename resolved auto (2026-05-21)**

Request: user (Telegram chat 2002026175, 2026-05-20 ~20:10 GMT+7): *"ผมอยากให้มันมี Status เดียวคือ review นะ ทั้ง deposit withdrawl"* — canonicalize `'review'` across deposit + withdrawal lanes.

Classification: **2b-fan-out** (architect amendment → impl + writer parallel).
Confidence at dispatch: **HIGH** (precedent: V13+V14 Cycle 1 + §FA2 rename + §RA1-§RA5 withdrawal-lane rename instance #1).

Sub-thread campaign: parent #181 (resume-from-retro), sub #183 (architect) + #186 (impl) + #187 (writer).

**4 PRs landed (Track B closure):**
- PR #204 (architect draft+marker-flip, single-branch instance #2): merged `6fa5bc6`
- PR #205 (writer doc residual): merged `864f4cd`
- PR #206 (impl substrate): merged `1685282`
- PR #207 (§Substrate-correction annotation, §H3-Fix instance #2): merged

User reaction: **accepted** (all 4 merges; no redirect; "Go" + "Go clean up" + merge confirmations through pipeline).

## 3 incidents of substantive value (filed for pattern library)

### Incident 1 — orchestrator stale-state-on-resume (instance #2 after 2026-05-04 #69)

orchestrator pushed back on architect's msg 695 fact-check with grep cites against `mb-next-payment-gateway` local checkout — but the local was on `poc-implement/admin-web-dark-theme-2026-05-13 @ 0a1cf04`, ~4 days behind main. All cited line numbers + "0 results for §Amendment 2026-05-16" assertions were ground-true in stale view, ground-false on origin/main:a41cb3f. Architect counter-cited with fresh greps; orchestrator concession at #183 msg 702 after `git fetch origin && git log -1 origin/main` reveal.

**Durable rule:** `git fetch origin && git log -1 origin/main` is BINDING before pushing back on agent's grep-evidence findings. verify-before-act applies to my own counter-evidence too. Tag: `stale-state-on-resume` / `memory-recall-trap`.

### Incident 2 — architect stale-schema-view drafting (caught by impl pre-flight)

architect's §CR2/§CR3 spec text specified post-drop enum value-counts (6 + 4) but deployed substrate had additional load-bearing literals (`'rejected'` on ts_deposits via §ADR-9 §TS1-TS5; `'fee'` on bank_statements via §ADR-4b §FC1) that the spec text missed. next-impl caught it via `[[poc-load-bearing-realism]]` pre-flight grep — PR #206 substrate preserves both (7 + 5 values), flagged divergence; orchestrator concur'd as load-bearing-correct; architect concur'd; §Substrate-correction annotation landed as PR #207 (no re-ratify, §H3-Fix bundled-inline precedent).

**Durable rule (filed by architect at `feedback_amendment_check_enum_migration_chain.md`):** `grep -l '<table>_<column>_check' supabase/migrations/` BEFORE specifying CHECK enum value-counts in amendment prose; read LATEST migration in chain order. Single command closes "stale schema view" drafting-bug class.

### Incident 3 — §H3-Fix bundled-inline-correction pattern instance #2

When ratified amendment prose diverges from deployed substrate (not a substantive content error — a spec-text-vs-reality drift caught by impl pre-flight), the resolution path is:
1. Substrate preserves load-bearing reality (impl's lane)
2. Architect lands inline correction annotation as `#decision` from first commit (no marker-flip — parent amendment already ratified)
3. Audit trail preserves both originally-ratified prose AND substrate-corrected value-counts
4. Skip re-ratify cycle (orchestrator + architect mutual concur is sufficient when correction is corrective, not substantive)

Instance #1 = thread #93 §ADR-4b D3 `match_status='review_required'` → `'review'` inline correction. Instance #2 = this Track B §Substrate-correction.

## Reusable orchestrator pattern observations

- **2b-fan-out cadence for canonicalization-class amendments:** architect (draft → marker-flip same branch single-commit) → user merge → impl + writer parallel → user merges both → architect annotation if substrate-divergence → user merges. 4 PRs typical; can compress to 3 if substrate matches spec verbatim.
- **next-impl pre-flight grep on deployed substrate** consistently catches architect spec-drift class issues. Worth surfacing in dispatch envelope as expected discipline ("verify against latest migration before substrate work" — already in agent's auto-memory).
- **§H3-Fix inline-correction-no-re-ratify** is the right shape when impl flags load-bearing-correct divergence; saves a user ratify cycle without compromising audit trail.
- **Cite-by-line-number + commit-hash reproducibility** (architect msg 706 codification) is the durable diagnostic shape for cross-session substrate disputes. Both sides cite verifiable artifacts; resolution by re-grep at agreed coordinates.</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "2b-fan-out", "accepted", "canonicalization-amendment", "track-b", "campaign-181", "cross-lane-canonical-naming-convergence", "stale-state-on-resume", "memory-recall-trap", "stale-schema-view", "h3-fix-bundled-inline-correction", "substrate-correction-no-reratify", "cite-by-line-number-reproducibility", "next-impl-preflight-grep", "thread-183"]</parameter>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
