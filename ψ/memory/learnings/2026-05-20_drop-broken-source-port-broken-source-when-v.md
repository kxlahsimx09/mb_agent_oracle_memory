---
title: **Drop-broken-source > port-broken-source — when verify-before-act reveals the s
tags: [port-vs-redesign, verify-before-act, production-data, design-decision, fraud-detection, fleet-pattern]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Drop-broken-source > port-broken-source — when verify-before-act reveals the s

**Drop-broken-source > port-broken-source — when verify-before-act reveals the source mechanism is structurally broken in production, drop-and-redesign beats port-and-improve.**

When porting a mechanism from a reference system (current → next, mobiz → next, etc.), the default move is "faithful port + targeted improvements." But that's only correct when the source mechanism actually works in production. If verification shows the source is broken (zero-yield, mis-tuned, or pattern-empty for non-trivial reasons), porting inherits the broken-ness.

**Worked example (G3 / PR #189 path, 2026-05-20):** PR #189 was authored as a faithful port of mobiz's `checkRetroactiveSlipFraud` to next-system. Verify-before-act on production data showed:
- mobiz scan returns zero hits over ~9 months despite 4,584 collision cells existing (silent mis-tune via `sus.PaidAt` zero-value bug).
- All 6 production-confirmed damage cases happened **pre-statement** — retroactive scan can only fire after the wallet was already credited.
- A different signal (`slip_verify_result.rawSlip.transRef`, OCR'd at upload) catches all 12 L3-proven cases deterministically at approve-time (preventive, before credit).

**Decision:** drop PR #189, author V1.5 transRef-check amendment instead. The retroactive design was not improvable; the right move was redesign from the production data forward, not port from broken-source backward.

**Heuristic:** if verify-before-act finds the source mechanism (a) didn't fire over a meaningful window, (b) couldn't fire on the actual damage class, or (c) shows a structural bug — pause before porting. Look at the production data and ask "what would actually catch this?" — design from there. Don't translate-and-hope.

Companion: [[production-zero-equals-mis-tune-not-safety]] (the diagnostic step) — drop-vs-port is the design step that follows.

---
*Added via Oracle Learn*
