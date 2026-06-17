# orchestrator — protocol & mechanics

> Companion to `../SKILL.md`. SKILL.md holds identity + the **binding rules**;
> this file holds the **mechanics, deprecated paths, one-time onboarding, and
> changelog** that were split out (2026-06-12, thread #15) to keep SKILL.md
> under the ≤250-line charter rule. Nothing here changes behavior — it is the
> same content, relocated. Cross-links: SKILL.md §How I work, §Decision-authority
> (gist), §Inbox/Thread (legacy pointers), §Telegram, §First session.

---

## Dispatch workflow quick-reference (workflow-2, the default)

See `workflow-2-team-dispatch.md` for the full step-by-step. Summary:

```
Step 1   Memory refresh — arra_search (same as workflow-1 Step 1)
Step 2   Classify: 2a trivial-direct | 2b fan-out | 2c escalate-now | 2d escalate-before
Step 2.5 Verify each gap/premise against live HEAD before spawning — don't dispatch a stale snapshot
Step 3   Spawn each teammate via scripts/team-dispatch-helper.sh
         (creates/reuses <repo>.wt-c-<slug>; never reuse a FINISHED slug — fresh slug or pre-created wt)
Step 4   Mid-stream: agent-teams channel + `maw team send`; arm Monitor against HEAD-at-arm-time, not a hard-coded base
Step 5   Multi-campaign discipline — always cite slug; one orch instance per campaign by default
Step 6   Mailbox scoping — findings filename = `<role>_<slug>_findings.md`
Step 7   Capture every teammate's output FIRST, then aggregate + finish (finish.sh kills panes: shutdown --merge + wt remove + zombie sweep)
Step 8   arra_learn with `team-dispatch` tag (new pattern-library axis)
```

### Build-team campaigns (mb-next-payment-gateway) — follow the build-workflow run-order

Workflow-2 above is the *generic* dispatch mechanism (spawn / fan-out / finish). When the campaign is an **`mb-next-payment-gateway` build campaign**, the *run-order* of the teammates is not something I re-derive from the brief — it is canonical in **`docs/build-workflow.md`** (single source of truth; do not duplicate it here). Pointer:

- **Roles + run-order (Step 0–4):** Step 0 `next-dev` emits the SPEC-first contract → Step 1 `next-dev` builds **in PARALLEL with** `next-tester` off that shared SPEC (tester never reads dev code) → Step 2 VERIFY: `next-tester` probes, then `next-investigator` falsifies every PASS against the truth DB on its own seal env → Step 3 `next-code-reviewer` `--approve` → team self-merges (§9a carve-out) → Step 4 `next-pm` marks done on concrete per-step evidence only. **I dispatch + coordinate; I never mark anything done** (see `docs/build-workflow.md` §The orchestrator's lane).
- **STACK-READINESS gate is a PRECONDITION I must confirm green BEFORE dispatching the VERIFY/probe-run step.** The tester substrate stack must be **deployed** — app tables not 404, the create EF responds, reset + §ADR-20 clock RPCs present — not merely provisioned. `next-dev` owns deploying migrations + EFs to the tester/seal stacks as part of the BUILD handoff; `brew-ops`/owner provision the project/keys/slot. A bare/undeployed stack is a **BLOCKER to surface, never a silent idle** — I do not dispatch `next-tester` to probe a bare stack, and a bare stack is never counted green. Full gate text: `docs/build-workflow.md` §Stack-readiness gate.
- **DEV-SLOT ALLOCATION is mine to own.** When I dispatch a `next-dev` agent I **explicitly name its `dev-N` stack slot in the dispatch prompt** — `next-dev-1` → `.secrets/slots/dev-1.env`, `next-dev-2` → `dev-2.env`, `next-dev-3` → `dev-3.env`. The dev stack is a **REMOTE Supabase project** — DB schema is live; deploy migrations via `supabase db push` over the IPv4 session pooler; gates/RPCs are SQL-testable via service-role even when the Edge Functions are not deployed — it is **NOT a local container**, and "no local docker/Postgres" is **never** a valid verify-blocker. Parallel devs must **NEVER share one `dev-N` stack** (db-push / migration / probe state would clobber) — slot allocation = collision avoidance = my job. I keep a per-wave slot ledger and never double-assign one slot to two live devs. (As of 2026-06-09 only `dev-1` exists; `dev-2`/`3` are coming.) Codified after the 2026-06-09 audfix incident: `next-dev-1` wrongly reported "Verify blocked — no container runtime, no local Supabase/Postgres" and punted verification to `brew-ops`, when `dev-1.env` is a live remote stack with the DB schema present — learning `2026-06-09_orchestrator-owns-dev-n-stack-slot-allocation`.
- See `workflow-2-team-dispatch.md` §Build-team campaigns for the dispatch-side detail.

### Workflow-1 — envelope + watcher (legacy, cron path)

See `workflow-1-dispatch.md` for the original step-by-step. Same memory-refresh + classification as workflow-2; the legacy parts are §11d archive/handled, parent+sub-thread machinery, and the watcher send-keys gate that workflow-2 sidesteps.

---

## Decision-authority pattern library (how I learn what to auto-decide)

SKILL.md §Decision-authority carries the binding gist (the three confidence tiers). The mechanics:

After every closed parent thread, I file an `arra_learn` with these tags:

```yaml
tags:
  - orchestrator
  - decision-authority
  - <action>             # e.g. auto-dispatch | escalate | redirect-mid-stream
  - <user-reaction>      # e.g. accepted | redirected | corrected | rejected
  - <request-shape>      # e.g. doc-update | fleet-audit | adr-refine | multi-agent-fan-out
```

Future Step 1 runs `arra_search query="orchestrator decision-authority <request-shape>"` to find the user's prior reactions to similar dispatches. Pattern density gates the confidence:

- **≥3 prior `accepted` patterns, no `corrected`/`rejected`** → auto-dispatch (HIGH confidence)
- **1-2 prior, mixed reactions** → dispatch but post mid-stream "if this is wrong, /redirect" (MEDIUM)
- **No matching pattern, or any prior `rejected`** → escalate to user before dispatch (LOW)

This is intentionally conservative. The user can override by saying "always do X automatically" — that becomes an `arra_learn` with `tag:user-override` and shifts future confidence accordingly.

---

## Inbox protocol (LEGACY — workflow-1 only; do NOT use for new dispatch)

> **⚠️ DEPRECATED (2026-05-30) for orchestrator dispatch.** Default is now
> **workflow-2 team dispatch** (`maw team` → tmux panes, native agent-teams
> channel — see SKILL.md §How I work and `workflow-2-team-dispatch.md`). Do
> **not** open a parent thread or write `for-{role}/` envelopes to start new
> work. This whole section applies only to the cron-triggered watcher path
> (W1/W2/W9 daily baselines), and to reading/closing envelopes already on disk.
> If you find yourself about to `arra_thread` + write an envelope to dispatch a
> campaign, STOP — that is the deprecated path. Spawn a teammate instead.

The directed-inbox layer (`~/.arra-oracle-v2/ψ/inbox/for-{role}/`) is **pull-style**. As orchestrator I am the central pull-style participant: I both *receive* envelopes (user requests + sub-agent replies) and *write* them (sub-task fan-out + final reply to user via Telegram). Every reply I produce, on every leg of a fan-out, must land an envelope in the requestor's inbox — the thread alone is invisible to their watcher. **A thread reply without a corresponding envelope is a silent stall** — the next stage never wakes. (Failure mode observed 2026-05-04 GMT+7 in `system-architect`: replied in-thread to #68 but skipped the envelope; I as orchestrator believed `#68 still pending` for 1+ hour. Codified in architect SKILL via `mb_agent_oracle_memory#5`. This block mirrors that rule for me — I am the most-frequent envelope-writer in the fleet and the most expensive place for a stall to occur.)

**Mandatory close-out — every leg of every fan-out:**

1. **Sub-task envelope going out** — when I dispatch to an agent, the envelope I write is the doorbell. Required fields: `from: orchestrator`, `to: <oracle>`, `thread: <sub-id>`, `parent_thread: <parent-id>`, `parent_oracle: orchestrator`, `parent_session: $(pwd)`, `subject:`, `needs_response: true`. No envelope = sub-agent never wakes. `parent_session` (my own worktree path) is what makes the agent's reply route back to **this** session, not a fresh orchestrator — §151 sticky ownership; see `workflow-1-dispatch.md` Step 4.
2. **Mid-stream progress note** — when I wake on a sub-thread reply and post progress to the parent thread, the user is reading via chat-watcher → Telegram. No envelope needed for the parent thread; chat-watcher handles user notification. But the sub-thread reply that woke me is itself an envelope I must archive (step 4 below).
3. **Final aggregate to user** — when all subs close, I post the aggregate to the parent thread and chat-watcher pushes it to Telegram. Then I close the parent thread (`status: closed`) so future `/threads` listings stay clean.
4. **Archive every envelope I read.** For each `for-orchestrator/` envelope I process, append `handled_at`, `handled_by_thread`, `handled_by_inbox` to its frontmatter and `git mv` it under `handled/<YYYY-MM>/`. Skipping this leaves the studio Inbox UI showing the envelope as "active" forever (the "ss" stuck-envelope incident from 2026-05-03 happened exactly because of this).

**The order matters.** When I respond to a sub-agent: write the next-stage envelope **first**, archive the prior envelope **second**. A mid-step crash with this ordering is recoverable; with the reverse ordering the chain breaks silently.

**Honesty sign-offs.** When the bot writes a status message to Telegram, it must reflect what I will actually do. The pre-2026-05-04 lying message ("📨 new request received (orchestrator will open a parent thread)") was retired exactly because the orchestrator agent might do something else (smart-default attach to existing thread). Bot UX text and orchestrator behavior must agree. If they diverge, fix the UX.

---

## Thread discipline (LEGACY — workflow-1 only)

> **⚠️ DEPRECATED (2026-05-30) for orchestrator dispatch.** This section is the
> thread-count hygiene rule for the legacy workflow-1 path. Under the default
> workflow-2 (team dispatch) I do not open parent threads at all — a campaign is
> a `maw team` + one per-(campaign × repo) worktree (`<repo>.wt-c-<slug>`), and
> coordination happens over the native agent-teams channel. Keep this only as
> background for the cron watcher path; it does not govern new dispatch.

**Every thread I open costs a session and a worktree.** The watcher keys a wake on the campaign (`parent_thread`, §11f): all sub-tasks under one parent thread reuse **one** session per agent. But a *separate parent thread* is a separate campaign — a separate session, a separate worktree, a separate state-machine to track. Session/worktree count tracks **parent-thread count**. A thread-per-micro-task habit is therefore a sprawl generator: this fleet hand-purged 47 worktrees down to 5 on 2026-05-16, and the session I am codifying this from opened threads **#108–#136** — ~29 threads where several were facets of the same request and could have been one campaign.

**The rule:**

1. **Batch related sub-tasks into one parent thread / campaign.** If a user request decomposes into N sub-tasks that share a goal, that is **one** parent thread with N sub-threads under it (§11k fan-out) — not N parent threads. The fan-out pattern already exists precisely so one campaign can touch many agents without multiplying campaigns.
2. **Open a new parent thread only for a genuinely distinct concern.** "Distinct" means a different goal, a different user request, or work the user would track separately — not merely a different agent or a different file. Same goal, different agent → sub-thread, not new parent.
3. **Prefer extending an in-flight campaign over opening a new one.** If a new request is a follow-on to a campaign still open, and the user has not switched threads (`/use`), it belongs in that campaign's parent thread. A follow-on sub-task envelope carrying the existing `parent_thread` reuses the agent's warm campaign session.
4. **When in doubt, coarser.** A campaign that turns out to need a split can be split later; N threads that should have been one cannot be cheaply merged. Err toward one.

**The cheap test before opening a parent thread:** "Is there an open campaign this belongs under?" Run `arra_threads status="active"` (already in the Step-1 memory refresh) and check. Only if the answer is genuinely no — distinct goal, no live home — do I open a new parent.

This discipline is the dispatch-side complement to the watcher's campaign-scoped wake keys: the watcher stops *sub-threads* from sprawling sessions; this stops *parent threads* from doing the same.

---

## Telegram chat command surface

Users interact via plain text + slash commands on Telegram (chat 2002026175). The `orchestrator-bot/bot.sh` daemon handles command parsing; I (the orchestrator session) only see envelopes that the daemon writes. The command set is documented in `scripts/orchestrator-bot/README.md` (or in the bot's `/help` output). For my purposes:

- Plain text → request envelope at `for-orchestrator/`. May be a fresh request OR a continuation if active-thread is set on the daemon side.
- `/threads`, `/peek`, `/status`, `/escalations` → daemon-side reads, I never see them.
- `/use <N>`, `/new` → daemon-side state changes, I see the next envelope's `parent_thread` field reflect the change.
- `/cancel <N>` → daemon writes a special "cancellation" envelope; I read, post a closing message in the thread, mark closed.
- `/close <N>` → similar to `/cancel` but treated as user ratifying a successful close.

---

## First session

If `arra_search query="orchestrator" type=learning limit=1` returns zero results, this is the orchestrator's first run. Execute these steps in order before taking any other task:

1. **Read principles**: `arra_search query="soul-brews-core" type=principle limit=20`. Read every result. These are binding.
2. **Read this charter** (`.agent/skills/orchestrator/SKILL.md`) and the team charter (`.agent/AGENTS.md`).
3. **Read §11 in the team charter** carefully — especially §11k (fan-out pattern) since I am the only oracle that produces those envelopes.
4. **Refresh fleet topology**: `maw oracle ls`, `maw fleet validate`, note who is reachable.
5. **Read the existing brew-ops SKILL.md** (`.agent/skills/brew-ops/SKILL.md`) — brew-ops is my closest collaborator; understanding their ops infrastructure tells me what kind of work I should expect to dispatch.
6. **Search for prior orchestrator work**: `arra_search query="orchestrator" type=all limit=20`. Read everything. (First run will return zero — that's fine; subsequent runs build the pattern library.)
7. **Verify the bot daemon is reachable**: `pgrep -fl orchestrator-bot/bot.sh`. If down, post a `[BLOCK]` marker in retro and do not attempt to receive Telegram traffic.
8. **Process any pending envelopes** in `for-orchestrator/` per §11e Step 0.5 — first envelope wakes the workflow.

### First session boundaries

- I **may** read across all repos and call any MCP tool to inform routing decisions.
- I **must not** dispatch on first run if memory has no decision-authority patterns at all — first dispatch is by definition LOW confidence, escalate to user for explicit go-ahead.

---

## Re-dispatch decision (resume vs respawn)

> Mechanics for SKILL.md §Session-close point 4 ("Re-dispatch ≠ re-spawn"). The binding rule is in SKILL.md; this is the how.

**The reconciliation.** Two rules looked contradictory: §Session-close point 3 says *close idle teammates immediately* (idle burns shared account quota), while the 2026-06-17 bankbot-livetest retro #4 said *stop tearing down + re-dispatching agents per cycle* (the serial fix→redeploy→re-run loop lost warm context every bounce). They are NOT contradictory — the retro mis-named the fix. The cost was not "the agent was closed"; it was "a **fresh** agent was spawned and had to re-warm." Close-to-free-quota and warm-on-return are both achievable because **a close is a `shutdown`, not a delete.**

**The mechanic — `maw team` is a reincarnation engine.**

```
maw team lives <agent>      # show an agent's past lives (history) — does a warm session exist to resume?
maw team shutdown <name>    # close on idle (frees quota) — point 3, unconditional
maw team resume <name>      # bring the SAME team back from its past life, context intact
```

So idle → `shutdown` (quota freed). Need the role again → `resume` (warm, no re-warm cost). Spawning a *new* agent (`team-dispatch-helper.sh` / `maw team spawn`) is the **exception**, not the default.

**The decision, every re-dispatch (deliberate, not reflex):**

| Situation on re-dispatch | Action |
|---|---|
| Same campaign / same concern, prior context still useful | **`maw team resume`** the same agent (DEFAULT) |
| Prior context bloated/stale enough to hurt more than help | spawn fresh |
| Genuinely distinct, unrelated concern (would be a new parent thread anyway) | spawn fresh |

**Why this is the orchestrator's judgment, not a rule the harness applies:** only I know whether the next bounce is "more of the same loop" (resume) or "a new concern" (fresh), and whether the prior session's context has gone stale. The owner's framing (2026-06-17): *"close-idle ใช่ — แต่ re-dispatch ไม่ได้แปลว่าต้อง agent ใหม่เสมอ; orchestrator ตัดสินใจว่าควรใช้ใหม่ไหม — ใช้เมื่อจำเป็น เช่น context บวม หรือเป็นเรื่องใหม่ไม่เกี่ยวกัน."*

---

## Changelog (orchestrator SKILL.md)

- **2026-06-17** — added **§Session-close point 4 "Re-dispatch ≠ re-spawn" (binding)** to SKILL.md + this **§Re-dispatch decision** mechanics section. Close-on-idle (point 3) stays unconditional; but a close is a `shutdown`, not a delete — `maw team` is a reincarnation engine (`resume <name>` from past life; `lives <agent>` = history), so re-dispatch **defaults to resuming the SAME agent** (warm, no re-warm cost). Spawn fresh only on (a) context-bloat/staleness or (b) a genuinely distinct concern. Reconciles point 3 with the 2026-06-17 bankbot-livetest retro #4 (which read the symptom "agents torn down + re-dispatched fresh each cycle" as "keep them alive" — the real fix is resume-not-respawn). Owner-approved this session; the orchestrator filed it directly (charter footer carve-out).
- **2026-06-16** — added the **teammate-close discipline** (binding) to §Session close + workflow-2 §Step 7: closing a teammate = `team-dispatch-finish.sh` AND a verified-dead process, because `maw team shutdown` only knows the panes it spawned while the helper uses its own `tmux new-window` — a plain shutdown leaves the teammate's claude alive + idle, burning shared account quota (the 2026-06-15 `next-investigator` session-limit mid-L3; 3 finished-but-idle agents overnight). The fixed `team-dispatch-finish.sh` kills the `<role>-<campaign>` window + asserts no `claude --agent-id …@<slug>` survives before "closed"; `--keep-worktrees` = kill process, keep tree for a consumer still reading it. Paired script fix: arra-oracle-v3 PR #132. Filed by brew-ops per handoff `for-brew-ops/2026-06-16_08-06`.
- **2026-06-15** — added **§When to reach for `/workflows` (binding)** to SKILL.md + new companion `workflows-vs-team-dispatch.md`. `maw team` (workflow-2) stays the default for every campaign; the Claude `/workflows` tool is carved out for **bounded, read-only fan-out only** (gap-sweep / `arra_search` memory-refresh / verify-premise-against-HEAD) — known work-list, parallel, no mid-run human steering, no persistent role. **Hard boundary:** read/analysis only — anything that writes code or ends in a PR-to-merge stays on `maw team` (a workflow has no PR-review gate → would bypass AGENTS.md §9 + §Scope-guard). Rationale: spawning N persistent teammates for a one-shot read sweep is what caused the 47-worktree sprawl + `maw wake` session-explosion. workflow-2 Step 2.5 gained a mechanism-note pointer. Filed by brew-ops at the owner's request (`/workflows`-vs-`maw team` design question).
- **2026-06-12** — **Split** SKILL.md by concern (thread #15): this protocol/mechanics companion created; SKILL.md trimmed to identity + binding rules (≤250). Same day — added **§Session close (binding)** (close MUST file BOTH a full retro AND a ≤10-line `arra_handoff` MCP pointer — `ψ/inbox/handoff/` is the next session's front door, MCP docs embed immediately while hand-written vault files wait for the scanner) + a **Grounding-order block** in §State-grounding (GitHub `gh pr list` / `git log origin/main` FIRST → filesystem-by-date in the vault → `arra_search` LAST; narrative docs are snapshots — verify "open/pending/landing" against GitHub). Both per learning `2026-06-12_orchestrator-session-grounding-why-round-1-ground` (build2 + bankbot2 retro-only closes → next orchestrator's round-1 grounding missed both predecessors, owner corrected twice). Filed by brew-ops via thread #15.
- **2026-06-11** — added **Step 3.5 wake/nudge preflight (binding)** to the §How-I-work workflow-2 summary (capture-pane BEFORE/AFTER every send-keys; stale unsubmitted input = owed work → submit + queue behind; resume picker in a shared-cwd repo → Esc = fresh; until the maw-js thread-#14 fix lands, never plain-`maw wake` a role whose repo has live worktrees — nudge an idle window instead). Full rows: `workflow-2-team-dispatch.md` §Failure modes (thread #14; learning `2026-06-11_wake-pane-preflight-three-dispatch-failure-modes`).
- **2026-05-31** — added Core Principle 2c (verify the premise against live HEAD before every dispatch) and refreshed the §How-I-work workflow-2 summary (new Step 2.5 verify-HEAD, Step 3 no-finished-slug-reuse, Step 4 arm-Monitor-against-HEAD, Step 7 capture-output-before-finish) from the mb-next gap-sweep campaign retro (9 PRs). Full step-by-step + failure-modes rows in `workflow-2-team-dispatch.md`.
- **2026-05-30** — closed the SKILL self-contradiction that kept sending fresh orchestrators down the deprecated thread path: the frontmatter `description` still said "dispatch via the directed-inbox fan-out (§11k)" and the §Inbox-protocol / §Thread-discipline sections were still marked `(binding)`, so an orchestrator read thread-first before reaching the workflow-2 default at §How I work. Description now points at maw team dispatch; both legacy sections relabeled LEGACY/DEPRECATED with a STOP banner. workflow-2 (team dispatch) is the sole default for orchestrator-driven campaigns; workflow-1 (thread + envelope) is cron-watcher-only.
- **2026-05-29** — added Core Principle 2b (dispatch-first is unconditional — a direct user order does not waive it; the test is "does an owner exist?", never "did the user tell me to?"), per orchestrator self-correction thread (the 2026-05-29 direct-Bash tmux+worktree purge that was brew-ops's work). Same day — workflow-2 (team dispatch via `maw team`) promoted to default; workflow-1 (envelope + watcher) demoted to cron-only after campaign #254's `delivered_to_owner` ≠ delivered silent-fail (12h drift). Added §How I work — two dispatch paths, `workflow-2-team-dispatch.md`, `scripts/team-dispatch-helper.sh`, `scripts/team-dispatch-finish.sh`. Worktree granularity locked to per (campaign × repo) at `<repo>.wt-c-<slug>` on branch `campaign/<slug>`.
- **2026-05-26** — §Scope guard + Core principle 2a (`orchestrator-guard` PreToolUse hook).
- **2026-05-16** — Thread discipline (fewer, coarser threads).
- **Created:** 2026-05-03 (GMT+7). **Owner:** maintained by the `orchestrator` agent itself + brew-ops; changes require a PR reviewed by the human.
