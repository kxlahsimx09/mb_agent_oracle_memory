---
title: Workflow-5 §13c orphan-detector overcounts narration — corrected detector + flee
tags: [brew-ops, memory, audit, workflow-5, workflow-9, orphan-markers, 2026-05-16, campaign-108]
created: 2026-05-16
source: brew-ops — workflow-5 §13c detector fix, thread #112
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Workflow-5 §13c orphan-detector overcounts narration — corrected detector + flee

Workflow-5 §13c orphan-detector overcounts narration — corrected detector + fleet re-count (campaign #108 / thread #112)

## The bug
Workflow-5 §13c's orphan-marker audit grepped `\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED-STEP):N\]` and counted every literal occurrence. That counts P-001 historical narration as live drift: marker tokens quoted inside `## Change log` / `### Revision log` bullets, inside `revision-log-archive-*.md` files, inside `[RESOLVED:…]` drift entries, and inside backtick-wrapped past-tense strip prose. Because every successful strip writes a change-log bullet naming the marker it removed, the metric grew monotonically and could never reach zero. The 2026-05-16 audit's "156 cross-repo orphan markers" P0 (learning `2026-05-16_oracle-memory-audit-run-2026-05-16-workflow-5`) was ~97% recounted narration.

## The fix
New detector `.agent/skills/brew-ops/references/w5-orphan-marker-detect.mjs` (shipped next to the workflow-5 spec) keeps only LIVE anchors via four filters: (1) doc scope = `docs/flows/*.md` + live `docs/adr.md` only; (2) drop lines inside a Change/Revision-log heading section; (3) drop `[RESOLVED:…]` / `DRIFT-N RESOLVED` lines; (4) drop past-tense strip-narration lines. A live anchor whose thread is closed/answered = a genuine orphan. workflow-5 §13c.2 rewritten; workflow-9 §4b grep (both mobiz + bank-bot copies) replaced with an awk filter applying the same narration exclusions.

## Corrected fleet re-count 2026-05-16
- mobiz-payment-gateway: 36 raw grep hits → 0 genuine orphans
- bank-bot: 13 raw hits → 0 genuine orphans
- mb-next-payment-gateway: 87 raw hits → 3 genuine orphans
- FLEET: 136 raw hits → **3 genuine orphans** (vs the "156" headline)

The 3 genuine orphans are all `[AWAITING_THREAD:45]` in `mb-next-payment-gateway/docs/adr.md` lines 936/942/958 (thread #45 closed 2026-05-06; deferral to a future fleet-control ADR). next-impl PR #116 is the in-flight fix. mobiz/bank-bot are clean — their surviving live markers (`[AWAITING_THREAD:14]`, `[UNDOCUMENTED-STEP:50]`) reference still-pending threads, the intended state.

## Standing findings from the superseded audit
This learning supersedes `2026-05-16_oracle-memory-audit-run-2026-05-16-workflow-5` because its §13c P0 count was a detector artifact. The audit's other findings still stand and are NOT re-audited here: P0-2 vector search degraded (LanceDB data fragment missing); P1 9 stale handoffs >14d.

Tags: #brew-ops #repo:cross #repo:arra-oracle-v3 #memory #audit #workflow-5 #workflow-9 #orphan-markers #2026-05-16 #campaign-108 #gotcha #drift

---
*Added via Oracle Learn*
