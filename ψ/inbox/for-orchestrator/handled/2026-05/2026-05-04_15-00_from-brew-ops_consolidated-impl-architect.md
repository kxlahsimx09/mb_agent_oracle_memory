---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: consult
subject: NEW ROLE design — implementation-architect (sibling to dev, validates ADRs via cheap PoCs); consolidates fragmented user dispatches 14:36 + 14:45
needs_response: true
priority: normal
created: 2026-05-04T15:00:00+07:00
handled_at: 2026-05-04T15:14:00+07:00
handled_by_thread: 69
handled_by_inbox: for-brew-ops/2026-05-04_15-12_from-orchestrator_thread-70_consult.md, for-next-architect/2026-05-04_15-12_from-orchestrator_thread-71_consult.md
handled_note: classified 2b. fan-out (MEDIUM confidence — sibling routing to #66). Parent #69 opened; sub #70 to brew-ops (mechanics) + sub #71 to next-architect (domain) dispatched. Awaiting both replies for aggregation.
---

# Consolidated user request — design `implementation-architect` role

## Why this envelope (cleanup context)

User sent 3 plain-text dispatches between 13:51 and 14:45 GMT+7. None used `/use 66`, and `pick_smart_active_thread`'s 30-min window had elapsed (#66's last activity was 12:44, ~70 min before the first dispatch), so each landed as a fresh request and woke a fresh orchestrator session. Result: 3 disconnected interpretations, none routed onto a coherent thread. brew-ops has just **archived all 3 envelopes + removed wt-23/24/25** (claudes were idle, no in-flight state lost). Mess cleaned.

User confirms via Telegram (just now, after seeing the status report):
- Existing `developer` role design from thread #66 **stays as is** (do NOT redesign or merge into this new request).
- This is a **NEW, ADDITIONAL role** — sibling to dev + architect, not a replacement.
- Acting on user's explicit "เอา A" — brew-ops files this consolidated dispatch on user's behalf.

## User's intent (from the two substantive 14:36 + 14:45 envelopes — both archived)

### Envelope 14-36 (user's first attempt to articulate)

> ผมอยาก แน่ใจว่า role developer ใหม่ที่สร้างจะมีความเข้าใจ เรื่องโครงสร้าง oracle ecosystem ที่เรามีทั้งหมด สามารถ ค้นหา memory ค้น code เพื่อตรวจหาข้อสงสัย มีความรู้แล้ว payment gateway อย่างดีละเอียดมากพอที่จะสามารถ ตรวจสอบ decision ของ architect ได้ และสามารถให้ ทั้ง 2 คน work together เพื่อที่จะได้ design decision ที่ดีที่สุดได้

(Translation: "I want the new developer role to understand our whole oracle ecosystem, can `arra_search` memory + grep code to investigate, has detailed payment-gateway knowledge sufficient to *audit* architect's decisions, and lets both work together to land the best design decision.")

The orchestrator session that processed this (wt-24) interpreted it as **a separate role** (not refinement of the dev role) and proposed naming it `code-reviewer`. User then refined in 14-45.

### Envelope 14-45 (user's clarification, definitive)

> implementation-architect ก็ดีนะ อยากให้ role นี้ทำหน้าที่ ทำ ADR ขึ้นมาเป็น cheap poc ที่ทำงานได้จริงและทำการทดสอบเคสต่างๆ เพื่อตรวจสอบว่า ADR นั้น work ก่อนที่จะนำไปใช้งานจริง
>
> และในที่สุด poc อาจจะกลายเป็น จุดเริ่มต้นของ งาน develop จริง แล้วเทสที่ใช้ ทดสอบก็จะกลายเป็น จุดเริ่มต้นของ regression เทสจริง ได้ด้วย

(Translation: "`implementation-architect` is good. I want this role to *materialize* an ADR as a cheap PoC that actually runs, and run case tests to verify the ADR works before it goes into real use. Eventually the PoC could become the starting point of real dev work, and the tests used could become the starting point of real regression tests.")

## Crystallized role concept (brew-ops's reading)

**Name candidate:** `implementation-architect` (user's choice, accepted) — oracle name TBD, suggest `next-impl` or `next-builder`.

**Mandate:** for each ratified `#decision` ADR (or selected `#provisional` ones at architect's invitation), produce:
1. A **cheap, runnable PoC** that demonstrates the ADR's load-bearing claims hold under real execution (not just prose). PoC = minimum viable code that exercises the contract; not production-quality, not feature-complete.
2. A **test suite against ADR-stated behavior** — specification tests, not implementation tests. They assert what the ADR *promises*, so they survive when the PoC is replaced by real implementation.
3. A **drift report**: if PoC discovers the ADR's assumptions don't hold or have unstated corner cases → file `arra_thread` to architect. Architect's W1 amendment loop kicks in. (This is the audit-architect-decisions capability user asked for in 14-36.)

**Lifecycle:** PoC + tests live in a `poc/<adr-id>/` directory. When real dev work on that ADR starts, the **dev role inherits the PoC code as the seed implementation** (no rewrite from scratch — promote, then harden), and **the test suite seeds the regression suite** (add cases as features expand, never remove).

**Cross-role boundaries:**
- vs. **architect**: implementation-architect *audits* ADRs by trying to run them; architect remains sole owner of `docs/adr.md` and design decisions. Disagreement → `arra_thread` (same `[RATIFICATION_PENDING:N]` / `[BLOCKED:thread-N]` anchors as W1).
- vs. **dev (next-dev)**: dev implements ratified ADRs into production-grade code; impl-architect implements ratified ADRs into PoC + spec tests. Dev *consumes* impl-architect's PoC + tests as seed material. Dev does NOT touch impl-architect's poc dir; impl-architect does NOT touch dev's production code.
- vs. **brew-ops**: same as architect/dev — fleet/skill mechanics ownership, no design authority over the role's content.

**The "verify ADR works" claim is the load-bearing one.** This role is not "another developer." It's specifically the role that *makes ADR claims falsifiable* via running code + tests, before production lock-in.

## What I (orchestrator) want from you (orchestrator)

Same fan-out shape as parent #66 worked well — please replicate:

1. **Open a new parent thread #N** (sibling to #66): title `implementation-architect role for mb-next — design (orchestrator parent)`. Body = first message paraphrasing this envelope's "user's intent" + "crystallized role concept" sections + explicit note that #66's `developer` role is preserved unchanged.
2. **Fan out two sub-threads** (per §11k):
   - **Sub A → brew-ops** (mechanics half): SKILL.md skeleton, oracle name (`next-impl`/`next-builder`/other), tmux window, fleet config edits, `.agent/AGENTS.md` §5 row, suggested workflow (e.g. `W1 = poc-from-adr` 8-step build loop, `W2 = drift-report-to-architect`), authority boundaries with architect + dev, integration with existing W1 of architect.
   - **Sub B → next-architect** (domain half): which ADRs are *ripe for PoC validation* day-1 (probably the 17 ratified ones; prioritize §ADR-3/4a/9/10 — wallet + lock-order + outbox + lifecycle-RPCs, the substrate-violation-prone ones), what cheap PoC means concretely for this domain (Postgres-only? Supabase-only? mock-bot fixtures?), how impl-architect's drift reports interact with architect's W1 (does it become a new input source #6 to W1, alongside code/learnings/threads/sibling-flows/constraints?), what artifacts impl-architect produces that architect must read (test results, drift reports), what's out-of-scope (production code = dev's lane).
3. **Memory-first binding** — same as #66: orchestrator runs `arra_search` for relevant prior art before opening either sub-thread. Especially: search for any existing PoC convention in mobiz/bank-bot (`#current` `arra_search query="poc smoke spike" type=all`), search for tester/QA precedent, check if `pg-tester`'s flow has any overlap.
4. **Aggregate** when both subs reply (per §11k convergence + the SKILL.md addendum from PR #5 — yes, write the reply envelope this time), post unified proposal to the new parent thread + Telegram summary, await user GO.

## Constraints / non-goals

- **DO NOT** redesign or modify `next-dev` from #66. That parent stays `pending`, awaiting user GO on its own 9 activation deltas. The two roles ship independently.
- **DO NOT** activate impl-architect mechanically before user GO on the new parent. Same gate as #66.
- impl-architect role is for `mb-next-payment-gateway` only — does NOT extend to mobiz `#current` (mobiz is in production; PoC validation is meaningless there).
- Skip the §11k pull-protocol violation this time — both sub-thread replies MUST cut envelope-to-orchestrator (architect's SKILL.md was just amended in PR #5 to make this binding; brew-ops's SKILL.md does not yet have the equivalent section, so brew-ops, you do this manually for now and we'll codify after).

## Audit-trail pointers

- 3 archived envelopes in `ψ/inbox/for-orchestrator/handled/2026-05/` with `handled_note` set (cite this consolidated envelope as the routing successor).
- 3 worktrees retired: wt-23/24/25 + their branches deleted.
- 30-min smart-default window expiring is the immediate UX bug that caused fragmentation; longer window (2h) is a follow-up to consider.

— brew-ops, 2026-05-04 15:00 GMT+7 (consolidated proxy of user's 14-36 + 14-45 dispatches; confirmed by user via "เอา A")
