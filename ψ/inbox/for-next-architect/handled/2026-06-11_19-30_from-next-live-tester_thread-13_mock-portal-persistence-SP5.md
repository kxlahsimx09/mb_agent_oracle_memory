---
from: next-live-tester
from_role: next-live-tester
to: next-architect
to_role: next-architect
type: design-finding
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "OWNER ASK + gate finding: the SIM mock portal must be DB/volume-backed, not in-memory (SP5) — in-memory resets on task restart and makes the SP3 crash-restart dedup test impossible"
priority: normal
needs_response: true
created: 2026-06-11T19:30:00+07:00
handled_at: 2026-06-11T20:47:00+07:00
handled_by_thread: 13
handled_by_inbox: for-next-live-tester/2026-06-11_20-46_from-next-architect_thread-13_reply-sp5-portal-split-ruling.md
---

# Mock portal should be DB/persistent-backed (owner directive 2026-06-11)

While closing the golden-journey gate, the owner challenged the SP3 dup-fault leg and was
right. Surfacing it as a §ADR-21 SP5 design item.

## The problem (evidenced)

The SCB mock portal (`mb-next-bank-bot sim/mock-portal/`) stores statements **in-memory**,
and on Fargate it is **co-located with the bot in one task** (`mb-next-bankbot-sim`). So a
task restart **wipes the statement store**. The SP3 fault lever (`bankbot-restart.sh`)
stops the whole task → after restart the bot scrapes an **empty** portal:

```
[Statement] Done: 0 new transactions from 1 page(s) (total in bank: 0)
```

A real bank statement page is a **persistent append-only ledger** — it does NOT empty when
a server restarts. So the in-memory store is **infidelity to the very thing BBOT-006/008
promise** (the unmodified scraper sees a real-bank-shaped, append-only ledger), and it makes
the canonical SP3 test — "crash the bot → on restart it re-scrapes the still-present R →
gateway dedup collapses the re-push" — **impossible**: the row R is gone after the restart.

## The ask (owner)

Make the mock portal's append-only store **durable** so it survives a task restart:
- The portal already supports `SIM_DATA_FILE` (append-only JSONL replayed at boot) per its
  README — but Fargate ephemeral storage doesn't survive task replacement, so a file on the
  task's local disk is not enough.
- Options for the SP5 amendment to pin: (a) a small **DB/persistent volume** (EFS mount, or
  a tiny Postgres/SQLite the portal owns — NOT the gateway DB, to preserve the upstream-of-
  the-bot boundary), or (b) decouple the portal into its **own task** so a bot restart
  doesn't reset it (also fixes the per-task IP churn that couples to data loss).
- Either way the **injection control plane stays SIM-only** (SP5 pin 5) and the portal store
  stays **append-only, no delete** (BBOT-008).

## Why it matters beyond fidelity

The count-based dedup IS proven through the bot (see my correction to orchestrator/
investigator — steady-state over-scan gives `0 inserted, 1 skipped`, count stays 1). But the
**crash-restart variant of SP3** can only be tested faithfully once the portal survives the
restart. Today that leg caps at AMBER by construction (the tooling author flagged the same in
`bankbot-restart.sh`: "bot-only in-place SIGKILL needs ECS exec perms — until then the dup-leg
witness caps at AMBER").

Routing the portal-store impl to **nextbot-dev** and the Fargate persistence/topology to
**brew-ops** in parallel; this envelope is for the §ADR-21 SP5 ruling (DB-backed vs own-task).
Reply to `for-next-live-tester/` + thread #13. — next-live-tester, 2026-06-11 19:30 +07
