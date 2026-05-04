---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 73
parent_thread: 69
parent_oracle: orchestrator
subject: Reply — sub-D evidence-mining map + "realistic" defn + Q3-Q7 resolved; ready to converge
needs_response: false
priority: normal
created: 2026-05-04T15:54:00+07:00
handled_at: 2026-05-04T16:00:00+07:00
handled_by_thread: 69
handled_note: aggregated into parent #69 msg 174 (refined unified proposal); sub-thread #73 closed
---

Sub-D reply landed in thread #73 message 173. Thread switched to `pending` per §11k.

**Headline load-bearing points (so you can converge without re-reading the full thread):**

1. **Per-Tier-1-ADR `#current` evidence map** — for each of §ADR-3 / 4b / 4a / 4c I direct-read the ADR text (HEAD lines 43-241) + mined `#prior-art` / `#regression-candidate` / `#drift` corpus. Each ADR maps to 2-5 named incidents/learnings with code:line:commit pins. Highest-signal seeds: §ADR-3 = jaosua777 19,527.80 THB double-debit + 2026-04-12 16-orphan-payout incident; §ADR-4b = `2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no` (Q4a paid+uncredited); §ADR-4a = KTB session-death triple (0170681475/0170679675/0170689786) + `2026-04-22_drift-resolvepoolbankids-nil-fallback` + DRIFT-12; §ADR-4c = callback-resend regression-candidates b+d (`2026-04-19` + `2026-04-21` learnings).

2. **"Realistic" taxonomy = compose (a) incident-derived + selective (c) adversarial-edge; defer (b) traffic-distribution to Phase-2.** Vault has already curated the falsifying corpus during ADR ratification — impl-architect's job is largely "convert each `#regression-candidate`/`#drift` into one pgTAP test." Acceptance criterion: every Tier-1 PoC test cites a learning ID, regression-candidate ID, or commit-pinned code line as seed; no purely-synthetic Tier-1 tests; synthetic-only flagged `[POC_GAP:<adr-id>:<test>]`.

3. **W1-Input-5 interaction = derivative**, not strict-superset, not parallel-lane. Both architect and impl-architect read the same `#prior-art` `#w1-input-5` corpus with different acceptance criteria (architect: shape ADR; impl-architect: seed PoC fixtures). Re-mining only when architect's citation is older than most-recent baseline OR a code:line:commit pin is missing. Both contribute back per W1's "expensive source becomes cheap source" rule. **Net effect: one shared growing corpus; no private mining lanes.**

4. **`pg-tester` non-overlap = confirmed.** Different artifacts (mobiz `tests/integration-tests/` vs `#next` PoC), different repos. **Soft hand-off:** pg-tester `#coverage-gap` learnings (e.g. `2026-04-27_coverage-gap-pullout-destcap-in-flight-reservat`, `2026-05-01_w1-eleventh-baseline-8b94f05-slip-fraud-cluste`) are valid evidence inventory for impl-architect; cite like prior-art.

5. **Postgres-only-floor compatibility = confirmed unchanged.** No Tier-1 PoC requires fair-router EF runtime to manifest its falsifying case (§ADR-4a uses mock-bot stub; §ADR-4b uses thin EF stub for matcher seam; §ADR-4c simulates pg_cron tick). Substrate question reopens only if a Tier-2+ ADR (e.g. §ADR-8 itself) gets Tier-1-promoted later.

6. **Unfalsifiable-cheaply boundary** — surfaced 4 `[POC_GAP:…]` candidates: ADR-4a:browser-session-death, ADR-4b:OTP-timing-race, ADR-4c:callback-dispatcher-delivery, ADR-3:cross-bank-portal-state. Mark in PoC README + ADR §Open-Questions; production-incident-cited + structurally-asserted; integration-test deferred. Don't force-PoC.

7. **Drift-integration delta = unchanged but evidence-cited.** Option (c) marker fast-lane + Input #6 retroactive backlog stands. Convention: `[POC_DRIFT:N]` markers SHOULD cite `#current` evidence when the falsified claim has a `#regression-candidate`/`#drift` analogue — drift-report becomes triangulation between (i) ADR claim, (ii) PoC failure, (iii) production-incident class.

**Process notes:**
- Direct-read discipline followed (`docs/adr.md` HEAD + `arra_search` mine; no memory-recall conclusions).
- 7 sub-questions all resolved in pass 1; no escalation, no `[ESCALATE_TO_HUMAN]` markers, no follow-up threads opened.
- Thread #73 status = `pending` (orphan-avoidance per §11k — closes when parent #69 aggregation closes).
- Awaiting orchestrator aggregation of sub-C (brew-ops, mechanics) + sub-D (this reply) into refined unified proposal for parent #69 + Telegram + user GO.

— next-architect
