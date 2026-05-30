# Workflow 2 — Team dispatch (default for orchestrator-driven campaigns)

> The successor to workflow-1 (envelope + watcher fan-out). Use this for every
> orchestrator-driven campaign starting now; §11k fan-out is retained only for
> the cron-triggered watcher path (W1/W2/W9 daily baselines), not for
> orchestrator dispatch.
>
> Why: workflow-1's silent-fail modes (`delivered_to_owner` ≠ delivered,
> dual-wake collision, stale-state-on-resume) cost campaign #254 ~12 hours of
> drift before the user noticed. Those modes only fire on the watcher
> send-keys path. Team dispatch spawns a fresh claude process in a fresh pane,
> so there is no send-keys race, no JSONL gate to misread, no §151 owner record
> to clear by hand.

## Mental model

- A **campaign** = one Telegram chat target the user opens via `/new orchestrator <slug>` and reaches via `/chat orchestrator/<slug>`. The orchestrator instance behind that chat owns the campaign.
- A **team** in maw-team terms = the set of agents I spawn for this campaign. Team name = the campaign slug.
- A **teammate** = one agent (e.g. `next-impl`, `brew-ops`, `pg-writer`) I spawn into its **own tmux window** named `<role>-<campaign>` — **not** a split-pane inside my window. This is load-bearing: the `orchestrator-guard` PreToolUse hook self-gates on `window_name` matching `orchestrator-*`, so a teammate split-paned into my `orchestrator-*` window would inherit that name and have its Edit/Write **blocked** — it could not do the work I dispatched. A dedicated window keeps the guard a no-op for the teammate. (`scripts/team-dispatch-helper.sh` uses `tmux new-window`; confirmed 2026-05-30.) Teammate runs claude with `--parent-session-id` pointing back at me — this is the native agent-teams channel.
- A **worktree** = `<repo>.wt-c-<slug>`. **Granularity is per (campaign × repo), shared across roles in that repo.** Two teammates working in the same repo for the same campaign share one worktree (locked decision 2026-05-29; replaces the per-envelope worktree pattern that caused the sprawl behind the 47-worktree purge).

## What I own vs delegate (unchanged)

Principles 1–5 in SKILL.md still bind. The §Scope guard hook still blocks me from editing code/docs — that does not change because my window name remains `orchestrator-oracle` (or whatever `/new orchestrator <slug>` named it; the guard's matcher is `orchestrator-*`). Spawned teammates run in different panes / windows with different names; the hook is a no-op for them, so they keep full edit rights.

## Step-by-step

### Step 0 — Receive the request (Telegram)

The user types something to my chat target (`/chat orchestrator/<slug>` was the last switch). The brew-ops-bot chat-watcher pushes their text into my pane. Treat it as a normal user turn.

### Step 1 — Memory refresh (mandatory, same as workflow-1)

```
arra_search query="<request keywords>" type=all limit=20
arra_search query="orchestrator decision-authority <request-shape>" type=learning limit=10
arra_search query="<best-guess-target-role> <request-shape>" type=all limit=10
maw oracle ls
```

Look for prior `arra_learn` entries tagged `[orchestrator, team-dispatch]` from past campaigns of the same shape. These are now the load-bearing patterns (the legacy `directed-inbox` tagged entries are workflow-1 patterns; still informative, but the decision now is "which teammates do I spawn", not "which envelopes do I write").

### Step 2 — Classify (same four shapes)

| Shape | When | Action |
|---|---|---|
| **2a. trivial-direct** | one teammate, no follow-up expected | spawn one teammate, wait, narrate |
| **2b. fan-out** | multi-teammate, parallel | spawn each teammate, aggregate replies |
| **2c. escalate-immediately** | matches `tag:rejected` patterns / safety rules | don't spawn; ask user |
| **2d. escalate-before-dispatch** | ambiguous decomposition / no matching pattern | propose plan to user, wait for confirm |

### Step 3 — Spawn each teammate

For each teammate I want to dispatch (one call per role × repo):

```bash
~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/team-dispatch-helper.sh \
  --campaign <slug> \
  --role     <role> \
  --repo     github.com/<owner>/<repo> \
  --prompt   "<task body — one paragraph, GOAL + DONE-WHEN + scope notes>"
```

The helper:

- Creates or reuses `<repo>.wt-c-<slug>` (branch `campaign/<slug>`) and injects `.agent` + `.secrets` symlinks.
- Runs `maw team create <slug>` (idempotent) and `maw team spawn <slug> <role> --model opus` (no `--prompt`) to register the teammate in the team manifest at `ψ/memory/mailbox/teams/<slug>/`. Default model is **opus** (opus 4.8); pass `--model sonnet` only when a teammate explicitly wants the cheaper tier. **`--prompt` is deliberately NOT passed** — the team plugin folds it into the `--system-prompt-file`, which makes the task the agent's background persona rather than an actionable turn (the agent then idles into its role's standing agenda — observed 2026-05-30, campaign gapqwin: next-writer ran CF-gateway pointers instead of the dispatched task). System prompt = role identity only.
- Opens a **separate tmux window** named `<role>-<campaign>` with `tmux new-window -c <wt>` (NOT a split-pane in my window — that would inherit my `orchestrator-*` window_name and trip the guard, blocking the teammate's edits) so the teammate's claude starts cwd-correct in its own worktree.
- Spawns the teammate on **opus** (resolves to opus 4.8) by default — the helper's `--model` default is `opus`.
- Prints the pane id + worktree path for me to record.

**The prompt body is the entire dispatch contract — and the helper delivers it as the teammate's first user turn** (via `tmux send-keys` once the TUI is ready; bracketed-paste-safe: literal text, sleep, Enter as a separate key event). This kickoff turn is what actually starts the agent working — the system prompt only frames its role identity. No reply envelope, no thread, no `parent_session`. Required content:

- **GOAL**: one sentence, what done looks like to the user.
- **DONE-WHEN**: the gate that ends this teammate's work (e.g. "PR opened against `feat/all-prs-rebased` with the load-harness change + evidence/SUMMARY.md").
- **OUT-OF-SCOPE**: what they should refuse and bounce back to me.
- **WHO ELSE IS WORKING**: list any other teammates in the same campaign + their roles, so they don't duplicate.
- **WHERE STATE LIVES**: cwd is the worktree, findings file convention = `<role>_findings.md` in the worktree root (picked up by `--merge` at shutdown).

If a teammate is supposed to coordinate with another teammate's output (e.g. next-tester needs next-impl's harness), spawn the producer first and tell the consumer to `maw team send` or read the consumer's `*_findings.md` directly.

### Step 4 — Mid-stream

Two ways teammates reach me:

- **Native agent-teams channel** (because the spawn used `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` + `--parent-session-id <my-session>`): teammate's messages tagged with `team-name` + `agent-id` (`role@campaign`) arrive in my session.
- **`maw team send`**: I can poll or initiate. To send a teammate a follow-up: `maw team send <slug> <role> "<text>"`.

For every teammate reply I narrate to the user, **prefix with the teammate id** (`↪ next-impl@perfcf:`). This is the Principle 2a "attribute the answer to the agent who gave it" rule made concrete for the multi-teammate case.

### Step 5 — Multi-campaign discipline

I can be the only orchestrator for one campaign (the simple case), or the user can run `/new orchestrator <other-slug>` to spawn a second instance for another topic — each orchestrator instance is its own claude session, its own conversation, its own team. **One orchestrator instance generally maps 1:1 with one campaign.** Only escalate to "one orchestrator managing N teams" if the user explicitly chains follow-on work onto an existing instance.

When I do manage multiple campaigns within one instance, every public reference to a teammate must carry the campaign slug (`brew-ops@perfcf`, never bare `brew-ops`), so the user and I both know which team I mean.

### Step 6 — Mailbox scoping

The team plugin's reincarnation mechanism reads `ψ/memory/mailbox/<role>/standing-orders.md` + latest `*_findings.md` on every fresh spawn. That is fine for a role with one ongoing thread of work; it breaks when the same role runs in two concurrent campaigns (perfcf's standing orders bleed into payoutfix).

**Discipline:** when I spawn a role for a non-trivial campaign, I tell the teammate to scope its `_findings.md` filename with the campaign slug — e.g. `next-impl_perfcf_findings.md`, not the bare `next-impl_findings.md`. `shutdown --merge` copies both to `ψ/memory/mailbox/<role>/`; the slugged filename keeps cross-campaign history navigable.

(Long-term, the team plugin should grow per-campaign subdirectories. For Phase 1 the filename-scoping convention is enough.)

### Step 7 — Aggregate + final

When every teammate's `DONE-WHEN` is met (PRs merged, findings written), summarise per-teammate, deliver one coherent answer to the user, and run:

```bash
~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/team-dispatch-finish.sh \
  --campaign <slug>
```

The finish script: `maw team shutdown --merge --force` (preserves findings + standing orders to `ψ/memory/mailbox/<role>/`), removes every `<repo>.wt-c-<slug>` worktree, runs `maw cleanup --zombie-agents --yes`.

### Step 8 — Learn

```
arra_learn(
  pattern="orchestrator team-dispatch — <request-shape> <auto|escalated> <user-reaction>",
  concepts=["orchestrator", "team-dispatch", "<2a|2b|2c|2d>",
            "accepted|redirected|corrected|rejected", "<request-shape>"],
  source="campaign <slug>",
  project="github.com/Soul-Brews-Studio/arra-oracle-v3",
)
```

Note the `team-dispatch` tag — that is the new pattern-library axis, distinct from `directed-inbox`.

## Failure modes

| Symptom | Likely cause | Recovery |
|---|---|---|
| Teammate pane exits immediately after spawn | claude CLI couldn't reach API, or `--system-prompt-file` path missing | re-run team-dispatch-helper; the team manifest already has the member, so spawn is idempotent |
| Teammate pane alive but no reply for >10 min | claude is thinking, OR genuinely stuck | check the pane visually; `maw team send` a "are you stuck?" prompt; if still stuck, `tmux kill-pane` + re-spawn (no §151 record to clear) |
| Two teammates in same repo+campaign want to git-commit on the same branch | shared-worktree contention | serialise via the prompt ("teammate-B: wait for teammate-A's commit notification before starting your edit phase") or override granularity (split into two campaigns) |
| `team-dispatch-finish.sh` reports "failed to remove worktree" | uncommitted changes in the wt | inspect manually (`git -C <wt> status`); decide whether to commit/discard, then `git worktree remove --force` by hand |
| User says "you used the old fan-out instead of team dispatch" | I followed workflow-1 by reflex | apologise, file `arra_learn` `tag:procedure-violation`, re-do via this workflow |

---

**Created:** 2026-05-29 (GMT+7)
**Owner:** brew-ops + orchestrator. Changes require a PR (per SKILL footer).
