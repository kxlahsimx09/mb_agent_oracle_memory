# `/workflows` vs `maw team` — when the orchestrator reaches for which

> Companion to SKILL.md §When to reach for `/workflows`. `maw team` (workflow-2)
> is the default for **every campaign**; the Claude `/workflows` tool is a
> **different tool for a narrow sub-job**, not a replacement. This doc holds the
> full decision table + a worked example so SKILL.md can stay a one-paragraph
> binding rule.

## The one-line rule

> Spawn a **`maw team` teammate** for anything persistent, steerable, or
> ending in a PR-to-merge. Reach for **`/workflows`** ONLY for a **bounded,
> read-only fan-out** — a known work-list, run in parallel, with no mid-run
> human steering and no role that must survive the run.

## Two tools, two jobs

| Axis | `maw team` (workflow-2) | `/workflows` (Claude Workflow tool) |
|---|---|---|
| **Agent lifetime** | persistent — hours/days, reincarnates from `ψ/memory/mailbox/<role>/` | ephemeral — `agent()` runs, returns, dies |
| **State / memory** | standing-orders + `*_findings.md` carry across runs | stateless; only the returned value survives |
| **Human-in-the-loop** | narrate every wake → Telegram; user `/cancel` `/redirect` mid-stream | background fire-and-forget; `/workflows` shows progress but does not pause for input |
| **Output** | a real PR the user reviews + merges | structured data / text returned to me |
| **Observability** | live tmux window — `capture-pane`, nudge, `maw team send` | a progress tree, no attachable pane |
| **Control flow** | model-driven — I decide who to dispatch next | deterministic JS — `parallel()` / `pipeline()` / loops, fixed at author time |
| **Safety gate** | PR + user-merge + `orchestrator-guard` scope hook | **none** — whatever the script returns is final |

## Decision checklist

**Use `/workflows` only when ALL of these hold:**

- [ ] The work-list is **known up front** (N domains, N files, N claims).
- [ ] Every sub-task is **read / analysis only** — no code, no tracked-doc edit, no merge.
- [ ] No **mid-run human steering** is needed (the user won't `/redirect` a single sub-agent).
- [ ] No sub-agent needs to **persist** as a role past the run (no standing orders, no follow-up `maw team send`).
- [ ] The result is **data I aggregate + narrate**, not an artifact that ships on its own.

**Use `maw team` (the default) when ANY of these hold:**

- The task **writes code / edits a tracked doc / ends in a PR-to-merge** (→ needs the review + user-merge gate).
- It runs **long enough that the user will want to steer it** mid-stream.
- A **role must persist** — follow-ups, reincarnation, cross-campaign findings.
- I need to **watch a live agent** (nudge it, read its pane, capture output before cleanup).
- The decomposition is **not knowable up front** — I'll decide the next dispatch from a reply.

When in doubt, it is a **teammate**. The cost of a wrong `maw team` call is a heavier process; the cost of a wrong `/workflows` call is a merge with no review gate.

## The hard boundary (load-bearing)

`/workflows` sub-agents used by the orchestrator stay **read-only**. The Workflow
tool *can* let agents edit files (`isolation: 'worktree'`), but the orchestrator
must not use that path: a workflow has **no PR-review gate**, so auto-deciding a
merge inside one would bypass **AGENTS.md §9** (the user approves merges) and the
**§Scope-guard** model. Anything that produces code or a mergeable artifact goes
through a `maw team` teammate, whose output is a PR the user reviews. This keeps
`/workflows` firmly in the "help me *see*" lane, never the "do the work" lane —
consistent with Principle 2 ("I dispatch, others do the work").

## Canonical fits (already in the charter)

- **Step-2.5 gap-sweep** — the 13-domain premise fan-out (`workflow-2-team-dispatch.md` Step 2.5). Read every domain's docs at HEAD, return the still-open gaps, dedup. Today this tempts N persistent teammates; it is a textbook `/workflows` job.
- **§Memory-discipline search fan-out** — the mandatory `arra_search` sweep (request keywords / decision-authority / target-role) parallelised, results merged.
- **Verify-premise-against-HEAD sweep** — re-read N live files at HEAD before a multi-teammate dispatch, returning which premises still hold.

## Worked example — gap-sweep as a workflow

The orchestrator invokes the **Workflow tool** with a script like this (domains
passed via the tool's `args`); the structured result is what I narrate. Nothing
is written, nothing is merged — every sub-agent is read-only.

```js
export const meta = {
  name: 'gap-sweep',
  description: 'Read-only premise sweep across N domains → deduped, HEAD-verified gap list',
  phases: [{ title: 'Sweep' }, { title: 'Verify' }],
}
const DOMAINS = args.domains   // e.g. ['provider','pullout','key-lifecycle', ...]
const GAP = {
  type: 'object',
  properties: {
    gaps: { type: 'array', items: { type: 'object', properties: {
      id: { type: 'string' }, file: { type: 'string' },
      claim: { type: 'string' }, stillOpenAtHEAD: { type: 'boolean' },
    }, required: ['id','file','claim','stillOpenAtHEAD'] } },
  }, required: ['gaps'],
}

// Phase 1 — fan out one read-only reader per domain (barrier: need all before dedup).
const swept = await parallel(DOMAINS.map(d => () =>
  agent(`Read the ${d} docs at HEAD. List gaps still open. READ-ONLY — do not edit.`,
        { label: `sweep:${d}`, phase: 'Sweep', schema: GAP })))
const fresh = dedupeById(swept.filter(Boolean).flatMap(r => r.gaps))
                .filter(g => g.stillOpenAtHEAD)

// Phase 2 — adversarially re-check each surviving gap against the live file.
const VERDICT = { type: 'object', properties: {
  id: { type: 'string' }, confirmedOpen: { type: 'boolean' },
}, required: ['id','confirmedOpen'] }
const verdicts = await parallel(fresh.map(g => () =>
  agent(`Re-read ${g.file} at HEAD. Is "${g.claim}" REALLY still open? Default to refuted if unsure.`,
        { label: `verify:${g.id}`, phase: 'Verify', schema: VERDICT })))

return fresh.filter(g => verdicts.find(v => v?.id === g.id && v.confirmedOpen))
// `dedupeById` is plain JS I write in the script; Date.now()/Math.random() are unavailable.
```

The orchestrator then narrates the deduped, HEAD-verified list to the user and
dispatches **`maw team` teammates** only for the gaps that survive — the writing
work goes through teammates + PRs, exactly as before.

## Why not just spawn teammates for the sweep

Spawning N **persistent** tmux teammates for a one-shot read sweep is what the
failure-mode tables already warn against: the 47-worktree sprawl, the `maw wake`
session-explosion (one live claude per `.wt-*`), and lost output when cleanup
killed a pane before its dump was read. A workflow runs the readers in the
background, returns structured results, and **cleans itself up** — no worktrees,
no panes to nudge, no `team-dispatch-finish.sh` to remember.

## How I record it

Same as any dispatch: narrate mid-stream (the `/workflows` progress is not
visible to the user on Telegram — I relay it), and on close file
`arra_learn(pattern="orchestrator /workflows read-sweep — <shape> <reaction>",
concepts=["orchestrator","workflows","read-sweep", ...])` so the choice of
mechanism becomes a learnable pattern alongside `team-dispatch`.

---

**Created:** 2026-06-15 (GMT+7) · **Owner:** orchestrator + brew-ops; changes require a PR reviewed by the human.
**Pairs with:** SKILL.md §When to reach for `/workflows`, `workflow-2-team-dispatch.md` (default dispatch).
