---
title: W1 refine — §ADR-4d amendment ratification (pass 2) — thread #77 closed; C1/C2/C
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4d, amendment, ratification, pass-2, decision, thread-77-closed, slip-fraud-detection, v1-hash-lookup, v2-receiver-mismatch, force-approve-override, race-case-admin-flip-back, m4-sort-tiebreaker, v2-mask-aware-natid, within-pass-spec-expansion, user-pushback-instance-20, pre-input-5-instance-15, pattern-architectural-separation-replaces-runtime-check-confirmed, pattern-race-case-via-existing-matcher-path-reuse, pattern-within-pass-spec-expansion-via-clarifying-question, deposit-lane-fraud-detection-complete]
created: 2026-05-05
source: docs/adr.md@8656d7f + docs/design/deposit-lane/slip-fraud-detection.md@8656d7f + thread #77 closed messages 185-186 + slipFraudCheck.go code reads
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine — §ADR-4d amendment ratification (pass 2) — thread #77 closed; C1/C2/C

W1 refine — §ADR-4d amendment ratification (pass 2) — thread #77 closed; C1/C2/C5/C6 resolved → `#decision` 2026-05-05 GMT+7.

**Notable within-pass expansion on C2.** Initial spec was "last-4 + fail-open" (2-layer). User asked clarifying question on fail-open mechanism → architect verified mobiz code (`services/slipFraudCheck.go:63-115`) → surfaced 3rd layer (mask-aware position-by-position comparison handling NATID PromptPay middle-4 masks like `0-7055-6xxxx-70-2`). User accepted full port: *"ตามที่แนะนำเลย"*. Layer 2 closes DEP1777664433X6DFUK production false-positive class (BBL slip 2 พ.ค. 2026; naive last-4 rejected legitimate same-account transfers).

**Verdict summary:**
- C1 = (a) "C1 ผมเลือก a" — V1 hash-lookup + drop fallback + M4 sort
- C2 = (a-full) "ตามที่แนะนำเลย" — full 3-layer V2 (fail-open + mask-aware + last-4)
- C5 = (a) "C5 มีได้" — force-approve override
- C6 = (a) "C6 a" — race-case admin flip-back

**Pattern: "Within-pass spec expansion via clarifying question" (instance #1).** User's "current ทำแบบนี้ไหม?" forced verification → surfaced architectural layer that initial spec missed. Lesson: when porting from current code, read full helper body carefully — not just function signature. Initial spec collapsed 3-layer logic to 2-layer; recovered after user's question. Process improvement: when port-from-current decision involves multi-step helper, default to "read full body + enumerate all branches" before drafting initial spec.

**Pattern: "Architectural separation replaces runtime check" (instance #1 confirmed durable).** V3 caller-guard dropped per §ADR-13 D1 endpoint separation. Bot/admin handlers separate routes; bot Layer 1 filter rejects slip-bearing operations structurally. Brew-ops handoff candidate when 2nd instance accumulates.

**Pattern: "Race-case via existing matcher path reuse" (instance #1).** Admin button "delegate to auto-match" + UPDATE deposit pending + release statement → matcher Step 1 picks up via existing path → finalize_deposit credits. §ADR-4d D5 invariant preserved (admin retains action ownership); cleaner than auto-promote in linkCheckingDeposit (which would require D5 amendment). Pattern candidate: when adding race-case handling, check if existing ratified path can be reused before extending matcher logic.

**Single-straight-ratification heuristic:** prediction was high probability; reality 3/4 straight (C1+C5+C6) + 1/4 within-pass expanded (C2). 75% straight-rate. Heuristic update: prediction should weight question shape — port-verbatim questions high straight-rate; novel-spec questions higher within-pass refinement likelihood. C2 was port-verbatim BUT initial spec compressed actual behavior; expansion was correction not novel-design.

**Pattern instance count cumulative:**
- User-pushback-as-design-force: 19 → 20 (1 new — within-pass C2 expansion)
- Pre-Input-5: 14 → 15 (1 new code-read of slipFraudCheck.go full body)
- Architectural-separation-replaces-runtime-check: 0 → 1 (confirmed durable)
- Race-case-via-existing-matcher-path-reuse: 0 → 1 (NEW pattern candidate)
- Within-pass-spec-expansion-via-clarifying-question: 0 → 1 (NEW pattern candidate)
- Deliberate-divergence-via-Postgres-feature: 4 (no new)

**Architecture-decision phase status post-pass:**

Both fraud detection surfaces complete:
- §ADR-4b amendment B7 (statement-side match_hash compute primitive) — ratified
- §ADR-4d amendment (slip-side V1+V2 + force-approve + race-case) — ratified

Substantially complete on deposit lane. Remaining named architectural gaps:
1. §ADR-4b D2 amendment — matcher cascade detail (linkCheckingDeposit specification)
2. §ADR-14 — fleet-control (thread #45 long-pending)
3. §ADR-15 — monitoring/alerting (B3+B5 deferral target)

**§ADR-4d D5 invariant strictly preserved.** Race-case admin flip-back is admin-owned action (button click + reason note); auto-credit happens at matcher layer (separate code path). D5 ratification ("admin owns both terminals") strictly satisfied. Lesson reinforced: simplifications don't always require ratified-decision revisions; sometimes they enable cleaner designs that preserve intent.

PR #16 — 5 commits total: 5ce5dfd baseline / bf972fd baseline backfill / 8656d7f ratify pass + C2 expansion / + backfill (this learn + trace).

Trace: chains to `d1b662d7` (§ADR-4d amendment baseline pass-1). Becomes 18-link chain since §ADR-4c origin spanning §ADR-4c → §ADR-9 → §ADR-10 → §ADR-11 → §ADR-12 → maintenance → §ADR-13 → W2 sync → brew-ops handoffs → §ADR-4b amendment baseline+refinement+lock-reframe → §ADR-4b amendment ratify → §ADR-4d amendment baseline → §ADR-4d amendment ratify.

Threads opened: none. Threads closed: #77. Future flagged: §ADR-4b D2 amendment (matcher cascade incl. linkCheckingDeposit) — depends on this amendment's V1. Commit: 8656d7f.

---
*Added via Oracle Learn*
