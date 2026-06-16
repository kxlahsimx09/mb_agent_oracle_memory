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

### Step 2.5 — Verify the premise against live HEAD (mandatory before spawn)

Gap-finders, deferred-task backlogs, and my own campaign brief are all **snapshots**. Between when a gap was recorded and when I dispatch, the owning agent may already have shipped it, or it may turn out to be a smaller class of work than the brief claims (a writer-only edit on existing substrate, not a new ADR). Spawning a teammate against a stale premise burns a whole teammate cycle and risks a wrong artifact landing.

**Before I write each dispatch contract, I re-read the live file at HEAD** — `git -C <repo> show HEAD:<path>` (or read it in the campaign worktree once it tracks the right branch) — and confirm the gap still exists, the premise still holds, and the work is the class I think it is.

Precedent (campaign mb-next gap-sweep, 2026-05-31): the 13-domain fan-out that opened the campaign found 31 gaps from `#current` snapshots and several were already closed at HEAD — BOT-001 and PULLOUT-002 were shipped; the key-lifecycle item was a writer-only edit on existing §ADR-2 substrate, not a new ADR; and my own PROV-001 brief-premise was factually wrong. All three were caught only by re-reading the live file before dispatch. **Verify each against HEAD; don't dispatch the snapshot.**

> **Mechanism note.** A bounded, read-only premise-sweep like this 13-domain fan-out is the **canonical `/workflows` fit** — ephemeral parallel readers, structured output + dedup, no mid-run steering — *not* N persistent teammates (which is what produced the 47-worktree sprawl + `maw wake` explosion). Run the sweep as a workflow, then dispatch teammates only for the gaps that survive. Boundary + worked example: SKILL.md §When to reach for `/workflows` + `references/workflows-vs-team-dispatch.md`.

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

**Never reuse a slug from a finished campaign.** The helper "creates **or reuses**" `<repo>.wt-c-<slug>` — reuse is intended only for a *second role joining the same live campaign*, sharing that worktree. Re-dispatching under a slug whose campaign already ran `team-dispatch-finish.sh` re-creates a worktree against a half-removed branch and tangles git state. For a follow-on or a re-run, pick a fresh slug (e.g. `<slug>-2`) or pre-create the worktree on the intended branch first. Precedent (gap-sweep 2026-05-31): re-dispatched to a finished campaign slug and tangled worktrees.

### Step 4 — Mid-stream

Two ways teammates reach me:

- **Native agent-teams channel** (because the spawn used `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` + `--parent-session-id <my-session>`): teammate's messages tagged with `team-name` + `agent-id` (`role@campaign`) arrive in my session.
- **`maw team send`**: I can poll or initiate. To send a teammate a follow-up: `maw team send <slug> <role> "<text>"`.

For every teammate reply I narrate to the user, **prefix with the teammate id** (`↪ next-impl@perfcf:`). This is the Principle 2a "attribute the answer to the agent who gave it" rule made concrete for the multi-teammate case.

**Watching for a teammate's PR push — arm Monitor against HEAD-at-arm-time, never a hard-coded base commit.** When I poll for a teammate's branch to push or open a PR, I read the current head at the moment I arm the watch (`git -C <wt> rev-parse HEAD`) and compare against *that* — not a commit hash I typed earlier. A hard-coded base goes stale the instant any commit lands, firing false "PUSHED" signals. Arm one watch per teammate; don't double-arm. Precedent (gap-sweep 2026-05-31): a hard-coded base caused ≥3 false PUSHED signals and one double-armed Monitor; reading head at arm-time removes the whole class.

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

The finish script: `maw team shutdown --merge --force` (preserves findings + standing orders to `ψ/memory/mailbox/<role>/`), **kills each teammate's helper-launched window `<role>-<campaign>` and asserts no `claude --agent-id …@<slug>` process survives**, removes every `<repo>.wt-c-<slug>` worktree, runs `maw cleanup --zombie-agents --yes`.

**Closing a teammate = finish-script AND a dead process — verify both (binding).** `maw team shutdown` alone only knows the panes IT spawned; the helper spawns each teammate in its OWN `tmux new-window` (to set cwd), so a plain shutdown leaves the teammate's claude **alive and idle**, answering keepalive pings and **burning shared account quota**. On 2026-06-15 three finished-but-idle agents left overnight are the suspected cause of `next-investigator` hitting its **session limit mid-L3**. The fixed `team-dispatch-finish.sh` now kills the window + asserts the process is gone before printing "closed" — if it warns one is still alive, free it (`tmux kill-pane` / `kill <pid>`) before treating the campaign as closed.

**Keep-the-worktree nuance.** Killing the idle PROCESS is independent of removing the worktree FILES. When another live agent still needs a teammate's tree (e.g. `next-investigator` reading `<repo>.wt-c-<slug>/poc/integration/evidence/live/…`), close with `team-dispatch-finish.sh --campaign <slug> --keep-worktrees` — kills the process (frees quota) but keeps the tree; run the worktree-removing finish only **after** the consumer is done.

**Capture every teammate's output BEFORE running the finish script.** `shutdown --merge --force` kills the teammates' panes; any report still living only in a pane (not yet written to `*_findings.md`) dies with it. `--merge` preserves `*_findings.md` — it does **not** preserve un-persisted pane scrollback. So before I run finish I (a) read each teammate's final reply / `<role>_<slug>_findings.md`, and (b) for any teammate whose output exists only in its pane (e.g. a dpay-finder dump), `tmux capture-pane` it into the worktree first. Precedent (gap-sweep 2026-05-31): cleaned up before reading the teammate report and lost the dpay-finder output to a dead pane — twice.

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

## Build-team campaigns (mb-next-payment-gateway)

The step-by-step above is the **generic** dispatch mechanism. When the campaign is an `mb-next-payment-gateway` **build campaign**, the *run-order of the teammates* is canonical in the product repo's **`docs/build-workflow.md`** — I follow that, I do not re-derive the sequence from the campaign brief each time. This section is a **pointer**, not a copy; the single source of truth is `docs/build-workflow.md`.

**Run-order (Step 0–4) and the teammates each step dispatches:**

| Step | Who | What I dispatch / coordinate |
|---|---|---|
| 0 SPEC-first | `next-dev` | emits the test-facing SPEC (`docs/spec/<file>`; the contract that decouples the tester from the code). Dev pushes it to its PR branch early + broadcasts `branch`+`path`; **I relay that `branch`+`path` to `next-tester` on dispatch** (`origin/<dev-branch>` : `docs/spec/<file>`) so the tester binds off the contract via `git show` — never the code |
| 1 PARALLEL build | `next-dev` ∥ `next-tester` | dev builds code + **deploys to its OWN `dev-N` stack** (the only slot it holds) and **hands off the migration set + EF list to `brew-ops`/owner for the CROSS-STACK deploy to the tester/seal stacks**; tester builds probes from the SPEC only (reads it off dev's PR branch via `git show`; never reads dev code) — spawn both off the shared SPEC, not sequentially |
| — STACK-READINESS gate | (precondition) | **confirm green BEFORE dispatching Step 2** — see below |
| 2 VERIFY | `next-tester` → `next-investigator` | tester probes; then investigator falsifies every PASS against the truth DB on its own seal env |
| 3 review/merge | `next-code-reviewer` | **APPROVE verdict (read from the review BODY header, NOT the `gh` state** — self-approve is refused → COMMENTED; see `docs/build-workflow.md` Step 3) → team self-merges (§9a carve-out; build CODE only) |
| 4 mark done | `next-pm` | marks step/story/epic `done` on concrete per-step evidence only |

**I dispatch + coordinate; I NEVER mark anything done** (`docs/build-workflow.md` §The orchestrator's lane). Only `next-pm` marks.

**STACK-READINESS gate — a precondition I confirm green before dispatching VERIFY (Step 2).** Before I send `next-tester` to run probes, the tester substrate stack must be **deployed**, not merely provisioned: app/deposit tables exist (not `404`), the create EF (`deposits-create`) responds (not `404`, GW4 gate live), and the reset RPCs + §ADR-20 clock RPCs respond. A *bare* stack (REST root `200` but app tables `404` and create EF `404`) leaves the tester blocked/idle. **Deploy ownership (role-isolation):** `next-dev` deploys only to its **OWN `dev-N` stack** (it holds only `dev-1/2.env`, not `tester.env`/`investigator.env`, so it *cannot* deploy to tester/seal); the **CROSS-STACK deploy to the tester/seal stacks is `brew-ops`/owner** (they hold those slots), driven by the migration set + EF list `next-dev` hands off. Merging the PR ≠ a deployed stack. **A bare/undeployed stack is a BLOCKER to surface — never a silent idle, never counted green.** I do not dispatch the probe-run against a bare stack; I route the cross-stack deploy to `brew-ops`/owner (with `next-dev`'s hand-off ref) first. Full gate text + checklist: `docs/build-workflow.md` §Stack-readiness gate. (Precedent: DEPOSIT slice 2026-06-03 — the orchestrator had to manually have brew-ops verify the tester stack `yupsevcrubgprsbujbpu` was deployed before dispatching next-tester; this gate replaces that manual pre-check.)

## Failure modes

| Symptom | Likely cause | Recovery |
|---|---|---|
| Teammate pane exits immediately after spawn | claude CLI couldn't reach API, or `--system-prompt-file` path missing | re-run team-dispatch-helper; the team manifest already has the member, so spawn is idempotent |
| Teammate pane alive but no reply for >10 min | claude is thinking, OR genuinely stuck | check the pane visually; `maw team send` a "are you stuck?" prompt; if still stuck, `tmux kill-pane` + re-spawn (no §151 record to clear) |
| Two teammates in same repo+campaign want to git-commit on the same branch | shared-worktree contention | serialise via the prompt ("teammate-B: wait for teammate-A's commit notification before starting your edit phase") or override granularity (split into two campaigns) |
| `team-dispatch-finish.sh` reports "failed to remove worktree" | uncommitted changes in the wt | inspect manually (`git -C <wt> status`); decide whether to commit/discard, then `git worktree remove --force` by hand |
| User says "you used the old fan-out instead of team dispatch" | I followed workflow-1 by reflex | apologise, file `arra_learn` `tag:procedure-violation`, re-do via this workflow |
| Dispatched a teammate against a gap that was already closed | premise was a stale snapshot, not re-checked | Step 2.5 — re-read the live file at HEAD before writing each dispatch contract |
| Lost a teammate's output after cleanup | ran `team-dispatch-finish.sh` before reading the pane | Step 7 — read `*_findings.md` + `tmux capture-pane` BEFORE finish; if already lost, re-spawn the teammate to regenerate |
| Repeated false "PUSHED" signals / double-armed watch | Monitor armed against a hard-coded base commit | Step 4 — re-arm reading `git rev-parse HEAD` at arm-time; one watch per teammate, never type the base hash |
| Re-dispatch tangles worktree/branch | reused a slug from a finished campaign | Step 3 — use a fresh slug (`<slug>-2`) or pre-create the worktree on the right branch |
| One `maw wake <role>` explodes the session with `<role>-<wt-suffix>` windows (one per worktree on disk), each a live claude | `wake-cmd.ts:215-235` existing-session branch respawns every `.wt-*` unconditionally (thread #14; until the maw-js opt-in fix lands) | never plain-`maw wake` a role whose repo has live worktrees — nudge an existing idle window of that role instead; if it fired, confirm each duplicate idle (`esc to interrupt` ABSENT) then `tmux kill-window` each, keep only `<role>-oracle`; zsh aside: `for w in $VAR` does not word-split — use a literal list |
| Woken/respawned pane shows ANOTHER role's transcript or a resume picker | `claude --continue` resumes the most-recent session in that cwd — cross-role contamination in shared-cwd/multi-role repos (03 has 11 roles, one cwd) | Esc cancels the picker → falls through to fresh `claude`; never blind-confirm a resume dialog in a multi-role repo |
| Nudge sent but the agent never starts; prompt text sits at `❯` | send-keys Enter didn't take (bracketed-paste/timing) — silent dispatch failure, looks identical to a slow agent | capture-pane AFTER every nudge: `esc to interrupt` = running; text still at `❯` = NOT submitted → one bare `send-keys Enter`, re-verify |
| Woken pane's input box already holds typed-but-unsubmitted text | a previous nudge/order was never submitted — OWED WORK, not junk (3 instances on 2026-06-11 alone) | don't clobber (C-u/C-c/Esc may not clear it): press Enter to SUBMIT the owed work, then queue your dispatch behind it (input typed mid-turn queues) |

---

**Created:** 2026-05-29 (GMT+7)
**Updated:** 2026-05-31 — added four disciplines from the mb-next gap-sweep campaign retro (9 PRs, orchestrator session): Step 2.5 verify-each-premise-against-live-HEAD before spawn (stale gap snapshots dispatched 3 already-shipped/mis-classed items); Step 3 never-reuse-a-finished-slug (worktree tangle); Step 4 arm-Monitor-against-HEAD-at-arm-time (≥3 false PUSHED from a hard-coded base); Step 7 capture-teammate-output-before-finish (`shutdown --merge` kills panes — lost dpay-finder output twice). Failure-modes table gained the matching four rows.
**Updated:** 2026-06-11 — failure-modes table gained four wake/nudge rows (maw-wake worktree respawn explosion, cross-role --continue, Enter-not-taken, stale-unsubmitted-input = owed work) from the bank-bot campaign dispatch round (thread #13/#14; learning 2026-06-11_wake-pane-preflight…).
**Owner:** brew-ops + orchestrator. Changes require a PR (per SKILL footer).
