---
title: Convention — as-of-date every illustrative production-count citation in docs/adr
tags: [adr, documentation, prevent-recurrence, production-counts, as-of-date, drift]
created: 2026-06-04
source: next-architect (campaign stalecnt)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Convention — as-of-date every illustrative production-count citation in docs/adr

Convention — as-of-date every illustrative production-count citation in docs/adr.md (prevent-recurrence for silent stale-count drift).

CONTEXT: ADRs cite live production figures as *illustrative evidence* for ratified decisions (e.g. §ADR-8 AF3 "5/56 banks set a cap @50000"; §ADR-10 "103 active wallets = 93 client + 10 partner"). These are NOT decisions — but bare, undated they silently go stale as production grows, and a reader can't tell when they were true. The dpay ADR-18 re-verify (campaign ng2dpay, 2026-05-31) caught two such drifted figures; a live re-verify 4 days later (2026-06-04, campaign stalecnt) found one had drifted AGAIN (system_banks 56→58→65) — proving bare counts rot continuously.

CONVENTION (the structural fix): every illustrative production-count citation in an ADR MUST carry an explicit **as-of date** + a "point-in-time snapshot, not a ratified figure" qualifier, e.g. "6 of 65 system banks set a cap, as of the 2026-06-04 dpay re-verify". The as-of label is what stops it silently going stale — a future reader sees the date and knows to re-verify rather than trusting a number of unknown vintage. Refresh = update the number AND the date together.

HOW TO REFRESH (campaign stalecnt precedent, PR #326):
1. Re-confirm live where possible (dpay MCP `count`), use today's number + today's date; only fall back to a prior re-verify's figure (with that earlier as-of date) if the source is unreachable.
2. Preserve ratified logic. If refreshing the count makes an embedded analytical claim false (AF3's "all method=payout @50000" became false once non-payout-capped banks appeared), correct the evidence to current reality — this is still evidence-refresh, NOT a decision change, because the *ruling* ("effectively a payout gate") is untouched.
3. Don't break a self-consistent dated snapshot block. §ADR-10's "Production evidence (dpay MCP audit 2026-05-13)" block has 93+10=103 with "103" referenced ~6× downstream; rewriting 93→113 would break the historical arithmetic. Instead leave the dated block intact and APPEND an as-of-dated current-figure note. A block that already states its audit date is half-compliant — it just needs the current delta surfaced.
4. Scope discipline: refresh only the named sections; do NOT hunt the same figure across all ADRs (e.g. §ADR-18 back-references to §ADR-8/§ADR-10 figures were left untouched + flagged). One revision-log entry; NOT merged by bot (§9 — owner merges).

---
*Added via Oracle Learn*
