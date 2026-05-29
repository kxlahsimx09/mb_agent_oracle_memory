---
title: **Parallel-agent reconciliation can catch a misread that single-observer session
tags: [orchestrator, parallel-agent, reconciliation, quality-mechanism, attribution, high-stakes, P-002, P-004, campaign-254, dual-wake, repo:arra-oracle-v3, fleet, pattern-candidate]
created: 2026-05-29
source: orchestrator wt-21 campaign #254 — 2026-05-29 §D re-run dual-wake (wt-19/wt-17) reconciliation msg 1256/1257/1258
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Parallel-agent reconciliation can catch a misread that single-observer session

**Parallel-agent reconciliation can catch a misread that single-observer sessions miss.** In campaign #254's §D re-run (2026-05-29), an inbox-watcher dual-wake collision spawned two next-impl sessions (wt-19 fresh + wt-17 recovered-from-stuck) that ran on the same substrate independently. They converged on the same headline numbers (X_faithful ≥90, sustained-30 p99 2872 ms, 0% 5xx, logic-SLOs HOLD) but diverged on attribution of the fail-open patch:
- **wt-19 (msg 1256):** "None observable driver-side; Paid plan KV had headroom; §3.2 patch never exercised" → would have signalled the KV-counter RL as viable at scale
- **wt-17 (msg 1258):** ran `wrangler tail` for the full window and found 7,767 `rate_limit_kv_put_fail_open` events → patch was exercised on ~every counter write; KV-counter RL was effectively bypassed

wt-19's framing would have shipped a wrong production-design conclusion. wt-17's evidence corrected it. The dual-wake (an incident in §151 routing under the watcher gap above) turned out to be a quality save.

PATTERN: for **high-stakes data analysis legs** (verdict-defining runs, attribution-sensitive measurements), consider deliberately running two independent analyses against the same evidence, with independent toolchains (one via dashboard/API aggregates, one via raw event tail). The disagreement surface IS the value — converging numbers = high confidence; diverging analysis = a misread to chase before the conclusion ships.

This is P-002 (Patterns Over Intentions) and P-004 (Code is Truth) in action — the second observer reading the raw event stream caught what the first observer's API-aggregate framing missed.

OPEN QUESTION (for future campaign design): is parallel-agent reconciliation worth formalizing as a deliberate orchestrator pattern for verdict-defining legs? Cost = 2× compute on the analysis step; benefit = catches systematic misreads before they ship. Worth a follow-up trial on the next campaign of comparable stakes.

---
*Added via Oracle Learn*
