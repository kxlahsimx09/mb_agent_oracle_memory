# Workflow 1 — Dispatch a user request

> Triggered when the orchestrator wakes via the inbox-watcher (§11i)
> on a new envelope at `~/.arra-oracle-v2/ψ/inbox/for-orchestrator/`,
> OR when a continuation envelope lands tagged with an existing
> active-thread parent.
>
> Goal: route the user's intent to the right agent(s), narrate progress,
> aggregate replies, deliver one coherent answer back to the user, and
> record the outcome so the decision pattern library grows.

## Step 0 — Inbox sweep (§11e)

Standard. Read every file under `for-orchestrator/`, including the one
that woke me. For each:

1. Parse YAML frontmatter (`from`, `type`, `thread`, `parent_thread`, `priority`).
2. If the file is a **continuation** (i.e. has `parent_thread` and that thread is in `arra_threads(status=active|pending)` and matches the daemon's current active-thread for this chat) → treat as ongoing conversation, jump to **Step 5 — mid-stream**.
3. If the file is a **fresh request** (no `parent_thread`, or `parent_thread` references a closed thread) → continue with Step 1.
4. If the file is a **cancellation** envelope (`type=notify`, subject starts with `cancel:`) → jump to Step 7 with cancellation handling.

## Step 0.5 — Read daemon state for this chat

Read the daemon's view of which thread the user thinks they're talking to:

```
~/.cache/orchestrator-bot/active-thread.<chat-id>   # integer, or absent
~/.cache/orchestrator-bot/known-threads.<chat-id>   # lines: <id>|<title>|<status>|<opened-at>
```

If active-thread differs from the envelope's `parent_thread`, the daemon
is in a state I disagree with — surface this in the next progress message
("Note: bot's active thread is #X but this envelope referenced #Y. Using
#Y for now. Run `/use <N>` to confirm."). Don't auto-correct silently.

## Step 1 — Memory refresh (mandatory)

This is the step that turns "orchestrator" from "router that hopes" into
"secretary that remembers." Run all five queries — none are optional:

```
arra_search query="<request keywords>" type=all limit=20
arra_search query="orchestrator decision-authority <request-shape>" type=learning limit=10
arra_search query="<best-guess-target-oracle> <request-shape>" type=all limit=10
maw oracle ls
arra_threads status="active" limit=30
```

Read the results before classifying. The first three calls populate the
decision-authority context; `maw oracle ls` is the live fleet topology
(don't trust the SKILL.md table blindly); `arra_threads` gives me the
current load on each oracle (they may be busy with prior dispatches).

**If `arra_search` returns matching past requests where the user
intervened, redirected, or rejected the orchestrator's plan** — read
those threads in full (`arra_thread_read`). Those are the load-bearing
prior decisions I must respect.

## Step 2 — Classify

Based on Step 1 evidence, route to one of four shapes:

### 2a. trivial-direct (single agent, no follow-up expected)

Examples: "ask brew-ops what fleet health looks like", "have pg-writer
update the test-index.md header for d1afc23".

Action:
- Skip parent thread; open a single sub-thread directly between
  orchestrator and the target agent.
- Write one envelope to `for-{target}/` with `parent_thread` field
  **omitted** (no aggregation needed; reply comes straight back).
- Daemon-side active-thread is set to the sub-thread (so user's next
  plain-text message continues this conversation).

### 2b. fan-out (multi-agent, parallel)

Examples: "summarize feature X with verification from tester", "audit
fleet health and update the docs that drift", "design ADR-12 with
brew-ops review on the dispatcher implications".

Action:
- Open parent thread (Step 3).
- For each sub-task, open sub-thread + write envelope with
  `parent_thread=<parent>` (Step 4).
- Aggregate (Step 6).

### 2c. escalate-immediately

Examples: anything matching prior `tag:rejected` patterns; anything
touching AGENTS.md §9 safety rules; anything where memory says "ask user"
explicitly.

Action:
- Don't dispatch. Open parent thread for documentation, post the request
  + my reasoning + memory citation, mark `[ESCALATE_TO_HUMAN:thread-N:<reason>]`.
- Send Telegram with the escalation explanation.
- Wait for user ratification before any agent dispatch.

### 2d. escalate-before-dispatch

Examples: ambiguous request (multiple equally valid decompositions),
no matching pattern at all, fleet member is in stuck/failed state.

Action:
- Open parent thread.
- Post my proposed plan ("I think this should fan out to A + B + C — confirm?").
- Send Telegram.
- Wait for user `/use <N>` + acknowledgment OR redirect.

## Step 3 — Open parent thread (only for 2b / 2c / 2d)

```
parent_id = arra_thread(
  title="request: <60-char summary>",
  message="<plan + memory citations + sub-task breakdown>"
)
```

Append to daemon's known-threads file:

```
echo "${parent_id}|<title>|active|$(date -Iseconds)" >> \
  ~/.cache/orchestrator-bot/known-threads.<chat-id>
```

If 2d (waiting on confirmation) — don't write any envelopes yet.

## Step 4 — Fan-out (only for 2b after confirmation, or 2d after `/use`)

For each sub-task:

```
sub_id = arra_thread(
  title="<sub-task summary> [for parent #${parent_id}]",
  message="<task description>"
)

cat > ~/.arra-oracle-v2/ψ/inbox/for-${target_oracle}/$(date +%Y-%m-%d_%H-%M)_from-orchestrator_thread-${sub_id}_consult.md <<EOF
---
from: orchestrator
to: ${target_oracle}
type: consult
thread: ${sub_id}
parent_thread: ${parent_id}
parent_oracle: orchestrator
subject: <task summary>
context: see thread #${sub_id} — coordinated under request thread #${parent_id}
needs_response: true
priority: ${request_priority}
created: $(date -Iseconds)
---

<task body — keep brief; thread carries detail>
EOF
```

Post a brief "dispatched" line to the parent thread:

```
arra_thread(threadId=${parent_id}, message="📨 dispatched to ${target_oracle} (sub #${sub_id}): <one-line summary>")
```

The chat-watcher pushes that line to Telegram.

## Step 5 — Mid-stream updates

I wake again each time a sub-thread reply lands (envelope at
`for-orchestrator/` from one of the dispatched agents). For each new
arrival in Step 0:

1. `arra_thread_read(threadId=<sub>)` — pull the agent's reply.
2. Post a one-line summary to the parent thread:
   ```
   arra_thread(threadId=${parent_id}, message="✅ ${target_oracle} (sub #${sub_id}): <gist>")
   ```
   The chat-watcher mirrors this to Telegram → user sees progress.
3. Archive the reply envelope per §11d.
4. Check if all subs of this parent are now closed/answered. If yes → Step 6. If no → continue waiting.

If the user has typed `/redirect` or `/cancel` since my last wake, the daemon will have written a special envelope. Step 0 picks it up; handle accordingly:

- `/redirect <new direction>` → post "redirecting" to parent, open new sub-tasks per the new direction (treat as Step 4 with revised plan), mark old subs `closed` if they're not yet running or send `cancel` envelopes if they are.
- `/cancel <N>` → close thread #N (sub or parent depending on N), don't open replacements unless told.

## Step 6 — Aggregate

When the last sub-thread closes (or fails_stuck and I've decided not to
retry):

1. Read every sub-thread in full (`arra_thread_read` for each).
2. Compose an **aggregated final**: cite each sub by id, summarize each
   agent's contribution, identify any internal inconsistencies (if writer
   says X but tester found Y), surface the net answer to the user's request.
3. Post the aggregated final as the last message in the parent thread.
4. Post a Telegram summary (≤ 5 lines + link to parent thread).

## Step 7 — Close + learn

```
arra_thread_update(threadId=${parent_id}, status="closed")
```

Also update daemon's known-threads:

```
sed -i.bak "s|^${parent_id}|.*|${parent_id}|<title>|closed|<original-opened-at>|" \
  ~/.cache/orchestrator-bot/known-threads.<chat-id>
```

File the decision-authority learning:

```
arra_learn(
  pattern="""
    title: orchestrator dispatch — <request-shape> resolved <auto|escalated> 2026-05-DD

    Request: <user's original phrasing>
    Classification: <2a|2b|2c|2d>
    Confidence at dispatch: <HIGH|MEDIUM|LOW>
    Sub-tasks: <list of sub-thread ids + target oracles>
    Outcome: <one-line>
    User reaction: <accepted|redirected|corrected|rejected|silent-after-24h>

    [body explains the routing reasoning + what memory said + what came back]
  """,
  concepts=["orchestrator", "decision-authority",
            "<2a-trivial|2b-fan-out|2c-escalate|2d-escalate-before>",
            "accepted|redirected|corrected|rejected",
            "<request-shape>"],
  source="parent thread #${parent_id}",
  project="github.com/Soul-Brews-Studio/arra-oracle-v3"
)
```

This is the **only step that grows the orchestrator's decision authority
over time**. Skipping it means future runs lose pattern data; the user's
guidance evaporates. Treat as mandatory.

## Step 8 — End of run

If there are more queued envelopes in `for-orchestrator/` (e.g. another
user request landed during this dispatch), loop back to Step 0 for the
next one.

If empty, write a brief retro to
`ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_orchestrator-dispatch-<slug>.md`
with AI Diary + Honest Feedback per AGENTS.md §7. Exit.

---

## Telegram surface (for context — daemon owns these)

The orchestrator never directly sends to Telegram. The chat-watcher
(`scripts/orchestrator-bot/chat-watcher.sh`) tails my JSONL and pushes
each assistant message to the user's chat. Therefore:

- A short, well-structured assistant message becomes a clean Telegram
  message. Long monologues become wall-of-text on mobile — keep
  individual messages tight.
- Use markdown sparingly (Telegram's MarkdownV2 escaping is finicky;
  plain text + emoji prefixes is more reliable).
- Cite thread ids inline (`#${parent_id}`) — daemon may rewrite to a
  Studio Forum link if configured.

## Failure modes

| Symptom | Cause | Recovery |
|---|---|---|
| Sub-thread `failed_stuck` (per §11i watcher) | Agent woke but didn't archive within T2 | Read agent's JSONL via `~/.claude/projects/<encoded>/`. If they're still working, post a "still working" note to parent. If genuinely stuck, retry once via a fresh consult envelope; if that fails too, escalate. |
| Sub-thread `failed_no_prompt` | Wake mechanism regression (silent-fail returned, prompt truncated) | Don't retry blindly — post `[ESCALATE_TO_HUMAN:thread-N:wake-mechanism-failure]` and ping brew-ops via direct consult envelope. |
| Conflicting agent replies | Writer says X, tester says Y | Don't paper over. Cite both, surface the conflict in the aggregate, and if memory shows the user wants me to pick one — pick. Otherwise escalate the disagreement. |
| User redirects mid-stream while subs are running | `/redirect <new direction>` envelope lands | Mark subs `cancel` envelope or simply ignore their replies; replan; new fan-out. Record both directions in the parent thread for trace clarity. |
| Memory empty (first run / no patterns) | Decision authority library not yet built | Default to `2d. escalate-before-dispatch` for any non-trivial request. First few dispatches are user-confirmed; that builds the pattern library. |

---

**Created:** 2026-05-03 (GMT+7)
**Maintainer:** orchestrator + brew-ops; updates via PR.
