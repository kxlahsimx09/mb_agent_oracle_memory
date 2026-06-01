# Progress dashboard — data contract (STUB)

> **Status:** scaffold stub authored by `brew-ops` for campaign `nextteam` (C0).
> **Owner going forward:** `next-pm`. **Renders in:** `oracle-studio` (React app proxying Oracle's HTTP API on `:47778`).
> This file is the **seam** between the delivery artifacts (Oracle vault + GitHub + run JSON) and the React progress panel. It is a contract sketch, not a finished schema — `next-pm` ratifies and extends it; the React panel lands in the `oracle-studio` repo as a follow-up PR.

## Purpose

next-pm reports Definition-of-Done **from artifacts, never from a developer's word** (mirrors orchestrator §2a). The dashboard is a *lens* on those artifacts, never a separate database that could drift. Every board cell links back to the artifact it reflects.

## The board

A per-story **4-gate board** + an **investigator-seal** column, with an **epic rollup**:

```
SPEC  →  BUILD  →  REVIEW  →  VERIFY   ( + SEAL at epic level )
```

| Gate | Owner | Green when (artifact) |
|---|---|---|
| **SPEC** | next-product-writer | Story has Given/When/Then AC + trust label `[S2 ratified]` — `docs/requirements/epic-<slug>.md` @ HEAD |
| **BUILD** | next-dev | PR merged, story-id linked — GitHub PR |
| **REVIEW** | next-code-reviewer | `gh pr review --approve` on the 3 dimensions — GitHub review |
| **VERIFY** | next-tester + next-investigator | tester build-probe green (`evidence/integration-run-*.json`, run-sha == merged HEAD) **and** investigator V1 audit pass |
| **SEAL** (epic) | next-investigator | epic seal issued (`#epic-seal` learning) — all member stories green, DEFERRED explicit |

States per gate: `empty` | `in-progress` | `green` | `red/blocked` | `unproven` (claim with no backing artifact — never promoted to green).

## Proposed JSON shape (the panel consumes this)

```jsonc
{
  "generated_at": "<ISO-8601>",          // stamped by next-pm at sweep time
  "source_commit": "<git-sha>",          // HEAD the sweep read
  "epics": [
    {
      "id": "epic-deposit",
      "title": "Deposit",
      "rollup": "in-progress",           // derived: green only if all non-deferred stories green AND seal issued
      "seal": {
        "state": "withheld",             // none | withheld | issued
        "by": "next-investigator",
        "seal_run_sha": null,            // == merged HEAD when issued
        "learning_id": null,             // #epic-seal learning
        "deferred_stories": []
      },
      "stories": [
        {
          "id": "DEPOSIT-001",
          "title": "Merchant requests a deposit ...",
          "trust": "S2",
          "gates": {
            "spec":   { "state": "green",       "artifact": "docs/requirements/epic-deposit.md#DEPOSIT-001" },
            "build":  { "state": "green",       "artifact": "gh:pr/123" },
            "review": { "state": "green",       "artifact": "gh:pr/123#review", "verdict": "approve" },
            "verify": {
              "state": "in-progress",
              "tester":       { "state": "green", "artifact": "evidence/integration-run-2026-06-01.json", "run_sha": "<sha>" },
              "investigator": { "state": "empty", "artifact": null, "v1": null }
            }
          }
        }
      ]
    }
  ]
}
```

## API surface (sketch — to be confirmed with brew-ops)

The panel reads via oracle-studio's proxy to Oracle's HTTP API (`:47778`). Candidate sources, in priority order:
1. **GitHub** — PR merge state + review verdicts (BUILD, REVIEW).
2. **Run artifacts** — `evidence/*.json` committed to the repo (VERIFY).
3. **Oracle vault** — `#epic-seal` / `#verify` / `#evidence` / `#review` learnings via `arra_search` (SEAL + cross-checks).
4. **Story surface** — `docs/requirements/INDEX.md` + epic files @ HEAD (SPEC; the story universe).

A new Oracle HTTP route (e.g. `GET /api/progress/<repo>`) MAY be added in `arra-oracle-v3` to assemble this contract server-side; alternatively next-pm assembles it from the above and posts a snapshot. **Decision deferred to next-pm + brew-ops.**

## Open items for next-pm (do not treat as done)

- [ ] Ratify / extend this JSON shape; pin the gate-state enum.
- [ ] Decide assembly: server-side Oracle route vs next-pm client-side snapshot.
- [ ] Wire the React panel in the `oracle-studio` repo (follow-up PR) — see `ProgressPanel.placeholder.tsx`.
- [ ] Confirm `evidence/*.json` schema with next-tester / next-investigator (run-sha field is load-bearing for V4).
