---
title: ## Reviewer checklist — spec-slice review for an OPS/monitoring epic (PR #402 MO
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, approve, monitoring, adr-15, spec-slice, monitor-002, checklist, gotcha]
created: 2026-06-11
source: PR #402 review 2026-06-11
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Reviewer checklist — spec-slice review for an OPS/monitoring epic (PR #402 MO

## Reviewer checklist — spec-slice review for an OPS/monitoring epic (PR #402 MONITOR-001..005, all-APPROVE first pass): what to verify beyond AC-bijection, and one real deployed-defect catch

The monitoring spec layer reviews differently from auth/payment slices because half the substrate is ENVIRONMENT, not code. What paid off on #402:

1. **Literal-by-literal ADR verification beats trusting paraphrase** — D4's routing literals (@mb_alerts_bot, #mb-alerts-p1/p2, /ack <alert_id>, the 🚨🚨 ESCALATED — UNACKNOWLEDGED 15min prefix, P3 9am-Bangkok digest destination), the D5 5-item checklist, D7's closure map (P2.1→B5, P2.7→B3-Q1, P2.8→B3-Q2, P2.9→B3-Q4), the catalogue arithmetic across 3 amendments (32→33→34 = 7P1+18P2+9P3), and MA1/MA2's Go-cron port constants (200k threshold, 50k bucket, (client_id,bucket) set-hash, 23h floor, hourly, business-day 02:00 BKK, lock:hourly_report). Grep gotcha: searching adr.md for "15-min"-class strings floods with hits from OTHER ADRs before reaching §ADR-15 (~line 4040) — grep the section range (sed) not the whole file.
2. **Deployed-state anchors need an independent record to check against** — the Keep-leg pins (cluster mb-next-keep, keep-api:0.53.0, KEEP_PROVIDERS/investigator_ro, NO_AUTH+SG-boundary, ephemeral residual) verified against the stand-up memory, not the slice's own claims. Dated "at authoring time" env tables + [ENV-PENDING] tri-state tags are the ACCEPTABLE form of time-varying state in specs (unlike PR merge-state strings — the ledger alternative exists for those; env state has no repo ledger).
3. **A good spec review can surface deployed code defects**: monitor-002 flagged that supabase/functions/deposits-qr/index.ts:70 returns the MATCHER request_id (DEP… text) under the X-Request-Id response header that §ADR-15 D3 reserves for the trace UUID — verified real at HEAD. A spec-vs-deployed collision found at spec-review time is far cheaper than at probe-failure time. Routed to next-dev with the D2/D3 build.
4. **⚑ pinned-lean hygiene**: leans must be (a) marked, (b) distinguishable from ADR text (the slice that pinned `cron:` as a 5th actor kind correctly did NOT attribute it to D2), (c) swept by the architect in one confirm-or-redirect pass — listed them in the verdict for that purpose.
5. **Interpretation-tension resolution is a spec's job**: MONITOR-005 AC1's 23h heartbeat vs AC2's no-alert-when-under — the slice resolved (heartbeat applies only to a standing non-empty set) and ⚑-flagged it; the reviewer verifies the resolution is consistent with BOTH AC texts rather than re-litigating.

Source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/402 review 2026-06-11; docs/adr.md §ADR-15 @ HEAD; epic-monitoring.md.

---
*Added via Oracle Learn*
