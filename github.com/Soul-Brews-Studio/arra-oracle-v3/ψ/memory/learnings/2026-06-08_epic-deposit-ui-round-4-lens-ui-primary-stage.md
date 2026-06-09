---
title: epic-deposit UI round (4-lens, UI-primary) + staged fix — RATIFIED 2026-06-08, f
tags: [epic-deposit, 4-lens-review, depui, depfix, next-ui-primary, deposit-read-api, substrate-blocker, ui-substrate-split, wui-deposit, live-test-enablement, DEPOSIT-013, ef-wire-shape, sweep-clean, no-dpay-needed]
created: 2026-06-08
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# epic-deposit UI round (4-lens, UI-primary) + staged fix — RATIFIED 2026-06-08, f

epic-deposit UI round (4-lens, UI-primary) + staged fix — RATIFIED 2026-06-08, fix IN PROGRESS. Third epic on the UI/substrate split; first one where the UI round exposed a gateway SUBSTRATE BLOCKER.

CONTEXT: epic-deposit was already deep-reviewed + dev-ready, but could NOT be live-tested because no operator UI. User asked for a 4-lens round: next-ui = PRIMARY deliverable (deposit console UI), other 3 lenses = completeness sweep.

REVIEW (campaign depui): next-ui 6H/8M → 14 WUI (WUI-101..114, used a 1xx deposit band to avoid colliding with wallet/auth WUI-001..). architect 0H/3M/3L, pg-writer 0H/3M/3L, next-writer 2H/7M/8L — all SWEEP. Findings ψ/memory/mailbox/. Aggregate /tmp/depui/depui_AGGREGATE_report.md.

KEY FINDING — the epic is behaviorally CLEAN + dev-ready (sweep found 0 behavioral contradictions, 0 MUST-ADD parity drops), BUT next-ui surfaced THE BLOCKER: there is NO ratified next-system deposit READ/LIST/DETAIL API. DEPOSIT-001..012 ratify per-deposit MUTATION RPCs/EFs + the v_deposits effective-status view, but not the QUERY surface every console screen + live-test needs (legacy GET /api/v1/deposits is mobiz). Plus deferred EF wire shapes (multi-candidate resolve, approve/reject) + fraud-preview projection. → LESSON: a 'dev-ready' backend epic can still be un-live-testable for lack of a read/query surface + operator UI; the next-ui lens catches this.

RATIFIED (user GO 2026-06-08) — detail /tmp/depui/RATIFIED-decisions.md:
- READ-API: author gateway deposit read/query ADR amendment (mirror §ADR-13 DL1 + wallet WR precedent) — list/detail, filters, pagination, realtime, tenant-scope, checking-count, v_deposits effective-status projection, fraud-preview projection; new gateway story DEPOSIT-013.
- EF WIRE SHAPES: pin multi-candidate resolve EF + approve/reject EF + fraud-preview projection now.
- WUI: ALL 14 → admin-portal docs/requirements/epic-deposit-ui.md, bound to gateway DEPOSIT-### (incl. DEPOSIT-013); bind to next-system taxonomy not legacy maxpay-ui-reference.
- SWEEP FIXES (apply all to gateway epic): provenance (deptimer §ADR-4c/4d §Amд 2026-06-01 + DEPOSIT-012 AM5 cited 'pending arch/*' but ratified+merged; INDEX 15→5-min slip-escalation); pg-writer 3 MUST-DOCUMENT parity notes (timeout-override dropped, UploadSlip immediate→checking replaced, DEPOSIT-009/V1.5 stale ingress-bypass refs); next-writer H1 (terminal-set contradiction — architect rules canonical Step-2b/§FA3 link set) + H2 (amount-mismatch no AC → no partial/over credit, stays pending) + M1-M6 testability ACs + L1-L8.
NO dpay-verify this round (doc/substrate-design, not prod-usage).

PROCESS: architect adr PR (depfix: read-API amendment + EF pins + H1 ruling) + writer-spec → orchestration-catch → writer gateway epic PR (depfix-epic: DEPOSIT-013 + all sweep fixes, disjoint) + writer admin-portal deposit-ui PR (depositui: 14 WUI, stacked on walletui base). Same proven pattern as wallet (#338/#339/admin#1) + auth (#344/#345/admin#2).

---
*Added via Oracle Learn*
