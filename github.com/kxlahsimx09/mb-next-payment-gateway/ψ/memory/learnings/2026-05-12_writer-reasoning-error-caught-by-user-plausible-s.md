---
title: Writer reasoning error caught by user: plausible-sounding rationale ported witho
tags: [next-product-writer, repo:mb-next-payment-gateway, next, fabrication-detection, writer-discipline, rationale-vs-algorithm-verification, deposit-007, v1-day-bound-window, user-pushback-instance, plausible-sounding-but-wrong-reasoning, supersede, pr-69]
created: 2026-05-12
source: docs/requirements/epic-deposit.md DEPOSIT-007 V1 edge case + mobiz services/slipMatchHash.go::ComputeSlipMatchHash@HEAD + user pushback 2026-05-12
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Writer reasoning error caught by user: plausible-sounding rationale ported witho

Writer reasoning error caught by user: plausible-sounding rationale ported without algorithm verification.

## Pattern surfaced

When porting an ADR's *rationale* (not just *contract*), the writer must verify the rationale against the underlying algorithm — not just the contract specification. ADR text can carry a rationale that sounds plausible (e.g., "matches PromptPay real-time settlement + BAHTNET end-of-day cut-off") and the writer may amplify it with more plausible-sounding reasoning ("recurring daily transfers would false-flag without day-bound") without checking whether the underlying code makes those reasons load-bearing.

## Concrete instance (2026-05-12)

DEPOSIT-007 edge case on V1 "day-bound window":

**Original ADR text (§ADR-4d V1+V2 amendment, ratified):**
> "Day-bound window (BKK calendar day; not ±60min) — matches PromptPay real-time settlement + BAHTNET end-of-day cut-off."

**Writer expansion (commit 3a13e73, PR #69):** added 2 reasons rooted in Thai banking — (1) physical settlement makes cross-day slip reuse rare, (2) recurring daily transfers would false-flag in a sliding window. Plus a worked example where "a statement from 2026-05-11 with the same hash is not a collision".

**User pushback:** *"ใน HASH algorithm มันเอาวันที่มา hash ด้วยไม่ใช่หรอ แล้วมันจะชนได้ยังไง"* — if the hash includes the date, cross-day collision is structurally impossible. How does the worked example even make sense?

**Code verification (mobiz `services/slipMatchHash.go::ComputeSlipMatchHash`, HEAD):**
```go
canonical := strings.Join([]string{
    dest,
    bank,
    strconv.FormatInt(int64(math.Round(amount * 100)), 10),  // satang
    strconv.FormatInt(transactionDate, 10),  // YYYYMMDDHHMM (minute-level)
}, "|")
h := sha256.Sum256([]byte(canonical))
```

User correct. Cross-day collision is mathematically impossible because YYYYMMDD is part of the hash input. Cross-minute collision is also impossible (minute is in the hash).

Day-bound query filter is implemented as MongoDB `transaction_date_bkk BETWEEN day*10000 AND day*10000+2359` clause — purely a query-scope optimization for index pruning. Not a semantic safety guard. Both "physical settlement" and "false-positive control" reasons were plausible-sounding-but-wrong.

## Why this happened

Writer trusted the ADR rationale at face value and amplified it without checking the algorithm. The fabrication-detection methodology applies to *contract* claims ("does this endpoint exist?", "is this field really S2?") but I didn't apply it to *rationale* claims ("why this design choice?"). The rationale in the ADR was preserved through ratification without anyone catching that it didn't match the algorithm's actual properties.

## Generalization (pattern for future passes)

When DEPOSIT-007 or any story expands an ADR rationale beyond the verbatim sentence:
1. **Locate the algorithm** (search for the function/regex/SQL referenced)
2. **Read the inputs and outputs** of that algorithm
3. **Check whether the rationale's premise holds against the algorithm's actual structure**
4. **If the premise doesn't hold**, the writer has two choices:
   - (a) Drop the rationale (use the algorithm's actual structure as the explanation)
   - (b) Flag the rationale as `[AWAITING_THREAD]` to next-architect for review

For DEPOSIT-007 V1 specifically: the day-bound window's "Thai banking settlement" framing was ADR-author rationale that doesn't match what the algorithm actually does. Algorithm-derived explanation is: hash includes minute timestamp → cross-time collisions structurally impossible → day-bound filter is purely query-scope optimization. That's the correct framing.

## Sibling pattern

Compare to architect's 2026-05-12 §ADR-4b D6 deferral: writer's earlier verification pass surfaced a shape mismatch (per-statement vs batch), architect's deeper audit revealed the endpoint produces zero matches in production. Pattern: each verification layer asks one level deeper. Writer-side: contract vs ADR (caught: shape mismatch). Architect-side: contract vs production (caught: redundancy). Now: rationale vs algorithm (caught: physics-of-banking framing was wrong). All three layers benefit from production/code/algorithm evidence beyond text-vs-text comparison.

## Process notes

- Re-applied as PR #69 (orphan pattern instance #6) after PR #66 merged before the second commit landed
- Corrective commit `cb9c759` on same branch — replaces wrong prose with algorithm-derived explanation
- Revision-log entry chains the two passes so the supersede is traceable
- No code change; no AC change; no AWAITING_THREAD; just prose correction.

---
*Added via Oracle Learn*
