# Workflow 2 — Document a New/Changed Feature (Track Commit)

> Reference document for the `technical_writer` agent.
> Read this file before running the workflow. Do not skim.

This workflow is the **fast follow-up** to Workflow 1 (baseline). Where Workflow 1 is a slow, grounding pass over the whole system, Workflow 2 is a surgical update triggered by a specific commit range or PR that has touched a surface the writer owns. It keeps `docs/current-system.md` (and sibling docs) in step with `main` without re-reading the entire system.

Output of a successful Workflow 2 pass: updated doc sections with fresh `// verified:` citations, a bumped `docs/.baseline`, any new `arra_learn` entries required, and — if any commit was too large to cover in a fast fix — one or more `#drift` learnings queued for Workflow 4.

---

## When to run this workflow

Run when **all** of the following are true:

- `docs/.baseline` exists (Workflow 1 has been executed at least once).
- `git log <baseline>..HEAD --stat` shows commits that touch files the writer owns (see §Territory map below).
- The commits to cover do **not** together exceed ~10 files or ~500 LOC of behavior change. If they do, run Workflow 1 (full re-baseline) instead.

Do **not** run this workflow:

- When `docs/.baseline` is missing — run Workflow 1 first.
- For a refactor that touches > 10 files or renames a top-level concept — run Workflow 1.
- For a new top-level feature area (new collection, new scheduler, new bot adapter) — run Workflow 1 so the baseline anchors re-set cleanly.
- To describe target-system changes — that is Workflow 3.

---

## Preconditions

- [ ] `git status --porcelain` is empty (clean tree). If not, stash or abort. A Workflow 2 pass against a dirty tree cannot be cited honestly.
- [ ] `git fetch origin && git status -sb` shows no `behind` on the branch being documented.
- [ ] `docs/.baseline` exists and is parsable (two lines: `current-system-baseline:` + `last-verified-at:`).
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). If unreachable, you can still run this workflow — note the gap in the retro and skip `arra_search` grounding in Step 1.
- [ ] You have at least **30 minutes** of focused time. A rushed Workflow 2 produces a stale `.baseline` pointer and silent drift.

---

## Inputs you will read

In approximate order:

1. `docs/.baseline` — the anchor commit.
2. `git log <baseline>..HEAD --stat` — the commit range this run covers.
3. For each commit, `git show --stat <sha>` and `git show <sha> -- <file>` for each touched file in territory.
4. The current versions of files touched in the commit range (not just the diff — the post-change state is what the doc describes).
5. The existing doc sections that describe each touched file (see §Territory map).
6. Oracle vault — `arra_search` for any prior `#drift` learning on the same area; these may already describe what changed.
7. The PR description (if any) — via `gh pr view <number>`. Useful for intent, but P-004 applies: the PR body is a claim; the code is truth.

---

## Outputs you will produce

Required:

- Updated doc section(s) with new `// verified: <path>@<short-hash>` citations against the new HEAD.
- `docs/.baseline` bumped to the new HEAD (same two-line format Workflow 1 specifies).
- At least one `arra_learn` entry per durable fact uncovered. If the only change was a cosmetic rename, no learning is needed — but document that in the retro.

Conditionally produced:

- One or more `#drift` learnings — when a commit revealed that the *prior* doc text contradicted the code that was already there (not the commit's own change). These go into Workflow 4's queue.
- A **scope-overrun note** in the retro — if you discover mid-workflow that the commit range is larger than expected. Stop the fast-fix pass and escalate to Workflow 1.

Never produced in this workflow:

- A full re-read of the system (that is Workflow 1).
- A new top-level doc file (new files belong in Workflow 1 or a dedicated PR).
- ADRs (Workflow 5).
- Runbooks (Workflow 6).

---

## Territory map (which doc owns which source)

Used by Step 3 to decide whether a touched file is in-territory for this workflow:

| Source pattern | Owning doc section | Fast-fix threshold |
|---|---|---|
| `controllers/*.go` | `docs/current-system.md` §3 API surface | 1–3 endpoints changed |
| `routes/*.go` | `docs/current-system.md` §3 API surface | 1–5 routes changed |
| `models/*.go` | `docs/data-model.md` (or §4 if inline) | 1–2 fields added/renamed |
| `middlewares/*.go` | `docs/current-system.md` §3, §7 Security | 1 middleware touched |
| `scheduler/*.go` | `docs/schedulers.md` (or §5 if inline) | 1 scheduler, no cadence change |
| `services/*.go` | `docs/current-system.md` §6 | 1 service, narrow surface |
| `helpers/*.go` | `docs/current-system.md` §7 Security | 1 helper, no signature change |
| `bank-bot/**` | `docs/bank-bot.md` | 1 adapter file |
| `swagger_simple.json` | `docs/current-system.md` §3 | re-check endpoints referenced |
| `db/mongo.go`, `db/redis.go` | `docs/current-system.md` §1 Stack, §4 Data model | connection config change |

Files **outside** this table are out-of-territory for Workflow 2. Either they belong to another role (e.g. `integration-tests/` → `qa_engineer`, `.github/workflows/` → `devops_engineer`) or they are infrastructure the writer does not document (vendored code, build artifacts).

---

## Steps

### Step 0 — Resolve answered threads in territory (blocking, 3–10 min)

Before opening any new work, run `references/workflow-thread-resolve.md` (Pass 1 + Pass 2) to completion.

- **Pass 1 (primary)**: `grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\]'` across pg-writer territory (see territory map in `workflow-thread-resolve.md`). For each id: `arra_thread_read` → if `status="answered"` run the 4-step resolution block (read → classify → update doc + strip/transform marker → `arra_thread_update(status="closed")` + child trace). Prior W2 passes that left behind `[AWAITING_THREAD]` markers are the most common source here (the daily cron hits these first).
- **Pass 2 (safety-net)**: `arra_threads(status="answered", limit=50)` → any id **not** seen in Pass 1 but clearly pg-writer territory = an earlier pass leaked an anchor → file `#workflow-bug + #thread-orphan` learning + `arra_inbox` for human.

**Gate:** Step 1 does not start until Pass 1 = zero remaining answered markers and Pass 2 = zero unfiled orphans. A daily W2 cron pass that skips Step 0 ages zombie threads by 24h every run.

### Step 1 — Grounding (3 min)

```
arra_search query="<feature-keyword> technical-writer current" type=all limit=5
arra_search query="drift technical-writer" type=learning limit=5
```

Look for: prior `#drift` on the same area (your change may already be flagged); the latest handoff from the sibling `next-writer` instance (cross-repo implications); open unanswered questions from previous retros.

If Oracle is unreachable, note `[GROUNDING SKIPPED — Oracle unreachable at <timestamp>]` and continue. Do not block.

### Step 2 — Define the commit range (2 min)

```
baseline=$(awk -F': *' '/^current-system-baseline/{print $2}' docs/.baseline)
git log ${baseline}..HEAD --oneline --stat
```

Record:

- Prior baseline commit (short hash).
- New HEAD commit (short hash).
- Count of commits in range.
- Files touched (broken down by territory column from §Territory map).

If the range is empty, Workflow 2 is a no-op — update `last-verified-at` in `docs/.baseline` and exit. Note this in the retro.

### Step 2b — Open the W2 trace + chain to prior (1 min)

Each W2 pass is a follow-up on the most recent baseline (W1) or the most recent W2. It belongs in a **horizontal chain** (prev → next) so a future agent running `arra_trace_chain(<any-node>)` sees the evolution over time: W1 baseline → W2₁ → W2₂ → W2₃ …

```
arra_trace(
  query="track-commit — <prior-short>..<new-short> (<N> commits)",
  queryType="evolution",                    # this is change-over-time, not structural
  scope="project",
  project="github.com/kokarat/mobiz-payment-gateway",
  foundCommits=[ ...each commit in the range as { hash, shortHash, date, message } ]
)
# store returned trace_id as W2_TRACE
```

Find the chain head (most recent baseline root or last W2 trace) and link:

```
arra_trace_list(project="github.com/kokarat/mobiz-payment-gateway",
                queryType=["project","evolution"], depth=0, limit=5)
# pick the most recent entry — that's the chain head to extend
arra_trace_link(prevTraceId="<head>", nextTraceId=W2_TRACE)
```

### Step 2c — Cross-repo sibling link (1–2 min, conditional)

Daily W2 cron runs across mobiz + bank-bot frequently touch **related** code (shared contract, callback URL shape, signature format, OTP flow). When both repos changed in the same 24h window for the same reason, chain the two W2 traces together so `arra_trace_chain(<either-W2>)` surfaces the sibling.

**Detect the cross-repo signal.** Any one of these is enough:

- A commit message in the range references the other repo by name (`bank-bot`, `mobiz-payment-gateway`) or by a ticket id known to span both.
- A file in the range is part of the shared contract: OpenAPI spec, proto, shared DTO, callback payload struct, signature/verify helper, MDR schema.
- The PR description links the other repo's PR.
- A commit message mentions a shared concept (webhook version bump, callback header change, OTP endpoint rename, MDR code rename).
- **A file in the range is cited in a sibling repo's flow-doc Implementation pointers** (detection one-liner: `for f in <sibling>/docs/flows/*.md; do grep -l "<your-changed-file>" "$f"; done`). Added 2026-04-22 (Gap 1 root-cause fix). This trigger overrides the "defer" branch below — see **§Sibling-flow-doc citation case (no defer)**.

If **no signal**, skip the rest of this step. Do not speculate.

**Look up the other repo's recent W2 trace.**

```
arra_trace_list(
  project="github.com/kokarat/bank-bot",
  queryType=["project","evolution"], depth=0, limit=5
)
# keep only traces whose created_at is within the last 24h
# pick the most recent one that covers commits landing on the same day or the day before
```

**Decide and link:**

- If a matching other-repo trace exists → `arra_trace_link(prevTraceId=<other-W2>, nextTraceId=W2_TRACE)` (the older of the two is always prev).
- If no trace yet (you ran before bank-bot's W2 today) → **defer**. Do not force a parent trace. Bank-bot's W2 will list mobiz traces on its pass and link backward to you. Note the defer in the retro so the human can spot-check that the back-link landed.
- If more than one plausible other-repo trace exists → pick the most recent and file a one-line note in the retro explaining why. Ambiguity here is a signal to talk to the human via `arra_thread`.

**Always, when you link:** file an `arra_learn` tagged `#cross-repo-sync` that names both traces + the shared concept (e.g., "mobiz callback v2 ↔ bank-bot adapter selectors update"). This is the semantic record; the `arra_trace_link` is the navigation record.

**Caveat to keep in mind.** `arra_trace_link` is directional (prev → next) and was designed for temporal evolution. Here we're using it for a sibling-in-time relationship. Readers of `arra_trace_chain` will see the siblings in chronological order but should not over-read "prev → next" as a causal arrow across repos. The `#cross-repo-sync` learning is the authoritative description of *what the two W2 passes have in common*; the link is just the thread that keeps them findable.

If no prior trace exists → skip the link (agents before this one didn't record traces; accept the gap, don't invent a phantom predecessor).

#### Sibling-flow-doc citation case (no defer) — added 2026-04-22, brew-ops (Gap 1 root-cause fix)

When the cross-repo signal fired **because your file is cited in a sibling repo's flow doc** — rather than (or in addition to) a matching sibling W2 trace — the "defer and wait for back-link" branch does NOT apply. The sibling's W2 won't fire unless their own code changes; your fix would then sit for days before any downstream doc catches up.

Originating incident: bank-bot `e3db48a` (bankRef positional slot fix, 2026-04-19) was cited across `mobiz/docs/flows/ktb-single-transfer-withdrawal.md` and `mobiz/docs/flows/withdrawal-queue-single-bot-transfer.md` — but mobiz had no code change that day, so bot-writer's W2 Step 2c deferred "waiting for sibling back-link". Back-link never came (mobiz had no W2 to back-link from). Drift persisted 3 days until 2026-04-22 session audit caught it.

**No defer. Do both:**

1. **File `#cross-repo-sync` learning** naming the affected sibling flow doc path(s) + your fix commit + the contract surface that changed. Phrase the body so a sibling writer reading it cold can locate the doc section to update.
2. **File an `arra_handoff`** addressed to the sibling writer's territory (pg-writer for bot-writer's commits; bot-writer for pg-writer's commits). Include: sibling flow doc path, the section that needs revision, your fix commit short-sha, and expected semantic change.

The sibling writer picks up via `arra_inbox` on next pass — the handoff is the forcing function. "I don't think the sibling will notice" is not a judgment call; the grep told you they cite this file.

### Step 3 — Classify each touched file (5 min)

For each file in the range, assign one of:

- **In territory, fast-fix-eligible**: within the threshold in §Territory map → proceed to Step 4.
- **In territory, over threshold**: too large for a fast fix → file `#drift` with `decision_required` tag and add to Workflow 4 queue. Skip in this run.
- **Out of territory**: record in the retro that it was observed but not updated; mention which role owns it.

If > 50% of in-territory files fall into "over threshold", **stop** — the delta is big enough that a full Workflow 1 re-baseline is cheaper than many Workflow-2 fast fixes. Escalate.

### Step 4 — Read the post-change file (10–20 min, scales with file count)

For each fast-fix file:

1. Read the **current** file (post-change state), not just the diff. The doc describes what the system does now, not what a patch added.
2. Open the controller/service/model being updated.
3. Re-verify every claim in the owning doc section against the new file. For each:
   - **Claim still correct** — update the citation hash: `// verified: <path>@<new-short>`.
   - **Claim is now wrong** — rewrite the claim. Mark the old one `SUPERSEDED (<new-short>, see <new section>)` per SKILL §5. Do not silently delete.
   - **New claim needed** — add it with citation.
4. If a change touches the API surface (new/removed endpoint, changed middleware, changed response shape), update the matching `swagger_simple.json` reference column and note in §9 Known drift if the swagger file lags.

### Step 5 — Ask before inventing (continuous)

If the commit introduces behavior that cannot be unambiguously read from the code (e.g. two plausible status transitions, a feature-flag check with no flag found), stop and:

1. Mark the claim `[UNVERIFIED — ambiguous; see commit <short>]` inline.
2. Open an `arra_inbox` item to the role most likely to know — usually `requirement-writer` or the human.
3. Continue with other files. Do not block the whole pass on one ambiguity.

### Step 6 — Log learnings (5 min)

For each **durable fact** uncovered (not cosmetic changes), write an `arra_learn` with the 3-layer tag set from `.agent/AGENTS.md` §7a:

```yaml
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - <feature>                 # e.g. bank-bot, deposit, scheduler
  - <special>                 # drift / decision / handoff — only if applicable
source: <path>@<new-short-hash>
related:
  - <prior-learning-id-if-any>
project: github.com/kokarat/mobiz-payment-gateway
```

Typical Workflow 2 learnings:

- A new enum value added to an existing status convention.
- A new callback target or signature format.
- A scheduler cadence change.
- A permission gate that moved from per-route to middleware (or vice versa).

Do **not** file an `arra_learn` for:

- Typo fixes in comments.
- Reformatting / linting commits.
- Dependency bumps with no behavior change.

Aim for **1–5 learnings** per Workflow 2 pass. Zero learnings on a non-cosmetic commit range is a yellow flag — you may have skimmed.

### Step 7 — Bump `docs/.baseline` (1 min)

Overwrite, exact format:

```
current-system-baseline: <40-char commit hash of new HEAD>
last-verified-at:        <ISO 8601, GMT+7>
```

Rule: bump **only** when Steps 3–6 are complete. A partial Workflow 2 (e.g. 3 of 5 files updated, 2 deferred to Workflow 4) does **not** bump `.baseline` — the anchor must cite a commit where every in-territory file has been reconciled. Instead, leave `.baseline` at the old hash and note the deferrals in the retro + drift learnings.

### Step 8 — Commit + PR (3 min new / 4 min amend)

The watcher fires daily; if yesterday's W2 PR is still open, today's pass **extends** it instead of stacking a new PR. One open W2 PR per repo at a time. `.baseline` only bumps on Step 7 success, so amending preserves the chain integrity. Empirical precedent for the amend procedure below: retro `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/20/10.25_w2-extend-pr242-bank-rotation-f694dcd.md` (pg-writer manually applied this pattern to PR #242 before the spec was updated; the procedure here mirrors what they did).

#### 8.0 — Detect open W2 PR (run first)

```bash
existing_pr=$(gh pr list --search "head:docs/track- state:open" --author "@me" \
  --json number,headRefName,title --jq '.[0]')
```

- empty → continue with **8.B** (new PR path).
- non-empty → switch to **8.A** (amend path).

#### 8.A — Amend path (existing W2 PR open)

```bash
branch=$(jq -r .headRefName <<< "$existing_pr")
pr_num=$(jq -r .number <<< "$existing_pr")

git fetch origin
git checkout "$branch"
git merge --no-edit origin/main    # absorb new main commits
# Conflicts in docs/* → resolve manually (rare, single-author docs).
# Conflicts in code/* → out-of-territory; abort + retro note.
```

Layer the new doc updates on top with an "extend" subject so the audit trail is readable:

```
docs: extend track to <new-short> (W2 amend; cumulative <orig-baseline>..<new-short>)

Adds <N> commits to PR #<pr_num>. Updated sections:
- <doc path> §<anchor>

Filed <N> new arra_learn entries (PR cumulative now: N+M).
```

Push + rewrite PR metadata to reflect the **cumulative** range:

```bash
git push origin "$branch"
gh pr edit "$pr_num" \
  --title "docs: track commits <orig-baseline-short>..<new-short> (W2, amended)" \
  --body "<regenerated body — list ALL commits cumulatively, ALL doc sections, ALL arra_learn ids; link the prior W2 trace and the new one (chain continuation per Step 2b); end with 'I will not merge this PR. Awaiting human review.'>"
```

Skip to Step 8b. Do **not** open a second PR.

#### 8.B — New PR path (no existing W2 PR)

Branch: `docs/track-<short-hash>` (e.g. `docs/track-c8a91f2`).

Commit message:

```
docs: track commits <old-short>..<new-short>

Updated sections:
- <doc path> §<anchor>
- <doc path> §<anchor>

Filed <N> arra_learn entries.
Filed <M> #drift learnings (see Workflow 4 queue).

No code behavior changes.

Closes #<issue if one exists>
```

PR body:

- List the commits covered (link each).
- List the doc sections updated.
- Link any `#drift` learnings filed.
- Include the standard line: **"I will not merge this PR. Awaiting human review."**

Per `.agent/AGENTS.md` §9, **never** `gh pr merge`.

### Step 8b — Telegram narrative summary (2–3 min)

After the PR is open and all `arra_learn` entries are filed, publish a **Thai-language narrative summary** to the team's Telegram group via the `telegram_send` MCP tool (see `github.com/Soul-Brews-Studio/mcp-telegram`). The goal is a story, not a status report — readers should understand *what landed and why* after a 30-second glance.

**Audience:** mixed. Both a developer scanning between PRs **and** a non-developer operator who wants to know whether today's change affects their workflow. Avoid jargon unless the message makes it self-explanatory on first read.

**Length target:** ~700 chars. Hard cap 800 (one Telegram screen on mobile). Prefer denser prose over more bullets.

**Composition — pull the story from memory, not just this pass's artifacts**

1. **Extract the core (this pass's own outputs):**
   - Commit range, PR link, affected doc sections.
   - Count of `arra_learn` entries filed + classification split (refresh / drift / undocumented).
2. **Weave in the backstory (why this PR exists):**
   - `arra_search query="<affected area> -technical-writer" type=all limit=10` — find earlier learnings or retros that led to this commit range. Often the story started days ago with a thread, a W8 ratification, or a #drift escalation.
   - If this pass *resolves* a thread, name the thread id and summarise the ratified decision. Do not just cite the thread — paraphrase the outcome so the reader understands without opening it.
   - If this pass *discovers* drift, link to the upstream cause (the commit or PR that introduced it) if findable in the memory chain.
3. **Rule of thumb:** reader should finish and feel "I know what changed and the reason — I do not need to open Oracle."

**Structure (HTML, works inside Telegram's `parse_mode: "HTML"`)**

Placeholders are in `{curly braces}` — substitute with real content before sending. Everything else (tags, bullets, labels) is literal.

```html
<b>📝 W2 mobiz-payment-gateway — {หัวข้อหนึ่งบรรทัด}</b>

{เล่าเรื่อง 2–3 ประโยค เริ่มจาก "ทำไมงานนี้เกิดขึ้น" (trace จาก memory),
 ตามด้วย "แก้อะไร" (outputs ของ pass นี้),
 ปิดด้วย "ส่งผลยังไงกับ stakeholder" หรือ "ต้องระวังอะไรต่อ"}

<b>รายละเอียด</b>
• Commits: <code>{old-short}..{new-short}</code> ({N} commits)
• PR: <a href="{pr-url}">#{pr-number}</a>
• Learnings: {N} refresh · {M} drift · {K} new
• Flow affected: {slug} (ถ้ามี, ไม่งั้นข้ามบรรทัดนี้)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

Use `<code>`, `<b>`, `<i>`, `<a href="url">link</a>` — no `<br>`, no `<hr>`, no custom CSS (Telegram strips them).

**HTML escaping:** when interpolating, escape `<`, `>`, `&` in **text content** before substitution. Commit hashes, file paths, slugs are safe; user-authored prose occasionally isn't.

**Tool call**

```
telegram_send(
  text: "<composed HTML from template above>",
  parse_mode: "HTML",
  disable_web_page_preview: true   # keep the card compact
)
```

`chat_id` is omitted — the MCP server uses `TELEGRAM_DEFAULT_CHAT_ID` env (set at `claude mcp add` time).

**Acceptance**

- `telegram_send` returned `{ ok: true, message_id: <N>, chat_id: <ID> }`.
- Captured `message_id` in the Step 9 retro body so the message is traceable if edits are ever needed.
- If the pass produced zero doc changes (empty commit range or all fast-path), still send a short note — "วันนี้ไม่มี drift ใน commit range, baseline bumped" — so the channel reflects activity cadence.

**Fallback (Telegram unreachable)**

If `telegram_send` returns `{ ok: false, error: ... }` or MCP itself is unreachable:

1. Do **not** block the W2 pass; the commit + PR are already real and useful.
2. File one `arra_learn` tagged `#telegram-failed + #workflow-bug + repo:cross` with the intended HTML body (full, unescaped) + the error string. Next session can re-send from there.
3. Note the failure in the Step 9 retro.

**Never** send Oracle-internal vocabulary (UUIDs, trace ids longer than 8 chars, file paths with stray quoting) unless wrapped in `<code>`. The Telegram reader wants story; Oracle reference ids are for the agent's own audit trail, which already lives in the `arra_learn` entries.

### Step 9 — Retrospective (3 min)

**Path discipline (load-bearing — see §The ψ/ trap).** Before writing, verify the vault symlink resolves:

```bash
readlink ~/.arra-oracle-v2/ψ | grep -q "mb_agent_oracle_memory/ψ$" \
  || { echo "FAIL: ~/.arra-oracle-v2/ψ does not resolve to the canonical vault — halt"; exit 1; }
```

**Write to:**
```
~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_<slug>.md
```

**Never to any of these traps:**
- ❌ `ψ/memory/retrospectives/...` — relative path, lands in your current cwd (worktree tree)
- ❌ `./ψ/memory/retrospectives/...` — same
- ❌ `<project-path>/ψ/memory/...` — absolute but wrong root; `project` is the product repo, not the vault
- ❌ `.agent/../ψ/memory/...` — symlink traversal may misresolve through the vault's own project subdir

Run `rrr`. A Workflow 2 retro is shorter than a Workflow 1 retro but the mandatory sections are the same: Outcome, What went well, What went slowly, Surprises, Honest Feedback, AI Diary, Next unanswered question.

Retro must capture:

- The commit range covered.
- Which files were fast-fixed vs deferred to Workflow 4.
- Any `[UNVERIFIED]` left in the docs and why.
- The next expected Workflow 2 trigger (next PR, expected area of change).
- Whether this pass opened a new PR (Step 8.B) or extended an existing PR #<n> (Step 8.A) — and if 8.A, the commit count layered + the cumulative range now in the PR title.

**After writing, verify no stray landed in the project tree:**

```bash
SLUG="<slug-you-used>"  # e.g., 15.06_w2-track-commit-admin-cancel-payout
# This MUST return empty — any hit = stray leak, follow recovery below.
find ~/Code/github.com/kokarat/mobiz-payment-gateway \
  -path '*/ψ/memory/*' -name "*${SLUG}*" \
  -not -path "*/.agent/*" 2>/dev/null
# And the canonical location MUST exist:
ls ~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/${SLUG}.md
```

**Recovery if stray found** (do NOT just delete — content may not be in vault yet):
```bash
STRAY="<stray-path-from-find>"
VAULT_DEST=~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/
mkdir -p "$VAULT_DEST"
# If vault copy doesn't exist yet, move; if identical copy exists, delete stray after diff
if [ -f "$VAULT_DEST/$(basename "$STRAY")" ]; then
  diff -q "$STRAY" "$VAULT_DEST/$(basename "$STRAY")" && rm "$STRAY" || echo "differs — merge manually"
else
  mv "$STRAY" "$VAULT_DEST"
fi
# Re-index so Oracle picks it up
(cd $(ghq list -p Soul-Brews-Studio/arra-oracle-v3) && bun run index)
```

---

## The ψ/ trap (why path discipline in Step 9 matters)

`ψ/memory/` looks like a vault-relative path but is not. The **canonical vault** lives at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ
```

surfaced to agents via the symlink `~/.arra-oracle-v2/ψ → <vault>/ψ`. Writes going through that symlink land in the vault correctly.

A **stray `ψ/` directory at the root of this project repo** (`mobiz-payment-gateway/ψ/`) would look identical to a vault path but:

1. **Not indexed by Oracle** — `arra_search` can't find it.
2. **Invisible to other agents** — defeats the "shared memory" design.
3. **May get git-tracked accidentally** — `ψ/` is NOT in this repo's `.gitignore` as of 2026-04-19. Once `git add` catches it, it enters the payment-gateway product repo's permanent history.

Historical incidents:
- **21 files** already committed to `mobiz-payment-gateway` git history from this trap, across three failed cleanup attempts (commits `414f568` / `2965cda` / `da4d13a`).
- **2026-04-19 15:06**: W2 run wrote its retro to `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md` (stray) instead of `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/19/15.06_...` (vault). Recovered by manually moving to vault + re-indexing (see `arra_search "ψ-trap-retro-leak"`).

Step 9's pre-write symlink check + post-write stray-find is the fix. Both must pass. Retro is not "done" until the stray check returns empty.

---

## The fast-fix vs full-pass decision (anti-pitfall)

This is the most frequent mis-call in Workflow 2. Use these heuristics:

**Fast-fix (stay in Workflow 2):**

- Single controller, ≤ 3 endpoints, no new model fields.
- Single model field added, no enum collision.
- Single middleware swap with same request/response shape.
- Scheduler internal change with unchanged cadence and unchanged side effects.

**Full-pass (escalate to Workflow 4 drift reconciliation, or Workflow 1 re-baseline):**

- A rename of an entity or enum that ripples through multiple files.
- A new top-level concept (new collection, new scheduler, new service).
- Cross-cutting change (e.g. every controller gained audit-trail middleware) — file one `#drift` for the theme, queue Workflow 4.
- Any change in `helpers/security.go`, `helpers/signature.go`, `helpers/jwt.go` — these are fast-fix-disqualified because security-sensitive. Escalate and CC `security_auditor`.

When in doubt, escalate. A deferred fast-fix costs one extra Workflow 4 pass; a wrong fast-fix costs silent drift.

---

## Definition of Done

This workflow is complete **only** when all are true:

- [ ] Every in-territory file in the commit range is either updated-and-cited or deferred with a `#drift` learning.
- [ ] Every updated doc section carries fresh `// verified: <path>@<new-short>` markers.
- [ ] Superseded claims are marked `SUPERSEDED` with a pointer (never deleted — P-001).
- [ ] `[UNVERIFIED]` markers added are < 5% of affected section's claims.
- [ ] `docs/.baseline` bumped **only** if no in-territory file was deferred; otherwise left at prior hash with deferral noted in retro.
- [ ] At least one `arra_learn` entry filed per durable fact (or an explicit retro note that the range had no durable facts).
- [ ] Git branch pushed; PR opened; **not merged**.
- [ ] **Telegram narrative summary posted (Step 8b)** — `telegram_send` returned `{ ok: true, message_id }`, or the fallback `#telegram-failed` learning was filed with the intended HTML body + error string. Message id recorded in the retro. For zero-doc-change passes, a short "no drift, baseline bumped" note was still sent to keep the channel cadence.
- [ ] Retrospective written at `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md` (**absolute path via vault symlink** — see Step 9 path discipline + §The ψ/ trap) with AI Diary + Honest Feedback. The retro is the state carrier; no separate handoff step.
- [ ] **Stray-check passed**: `find ~/Code/github.com/kokarat/mobiz-payment-gateway -path '*/ψ/memory/*' -name "*<slug>*" -not -path '*/.agent/*'` returned empty. The retro is NOT leaking into the product repo's working tree.
- [ ] Vault audit clean: `bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter` shows `✅ no double-wrap` + `✅ every indexed doc has a title:`.
- [ ] W2 trace (Step 2b) opened with `queryType="evolution"` and every commit in the range in `foundCommits`. If a prior baseline/W2 trace exists for this project, `arra_trace_link(prevTraceId=<head>, nextTraceId=W2_TRACE)` was called so the horizontal chain extends instead of forking.
- [ ] Cross-repo sibling check (Step 2c) ran: you either looked for a bank-bot W2 trace in the last 24h and linked (+ filed `#cross-repo-sync` learning), **or** you recorded in the retro that no cross-repo signal was found, **or** you deferred because you ran first and noted the expected back-link. "Forgot to check" is not one of the options.
- [ ] Step 0 ran to completion: Pass 1 (doc-anchored grep) left zero `answered`-status markers in pg-writer territory; Pass 2 (orphan scan) returned zero pg-writer-territory threads not found by Pass 1. On a daily-cron schedule, Step 0 must clear the same day it runs — Step 0 skip = zombie ageing.
- [ ] **One open W2 PR per repo:** Step 8.0 ran (`gh pr list --search "head:docs/track- state:open" --author "@me"`). If non-empty → this pass took 8.A (amend); if empty → 8.B (new). At end of pass, count of open `docs/track-*` PRs by `@me` on this repo ≤ 1. The watcher fires daily; without this gate, every settled-commit cycle stacks a fresh PR superseding the prior unmerged one.
- [ ] **Anchor discipline**: every `arra_thread(...)` call in this pass inserted a paired `[AWAITING_THREAD:<id>]` marker into a doc that is part of the same PR. Orphan thread count = 0. Check: `grep AWAITING_THREAD` in the PR diff ≥ count of `arra_thread(` calls recorded in the retro.

---

## Common pitfalls (learn from each one, file a learning if new)

- **Reading the diff instead of the post-change file.** The diff is a delta; the doc describes the destination state. If you only read the diff, you will miss interactions with pre-existing code that the diff assumes.
- **Bumping `.baseline` with deferrals outstanding.** If even one in-territory file was deferred, the baseline still lies about what's verified. Leave it at the prior hash.
- **Trusting the PR body.** PR descriptions are claim-ful (P-004). Verify against the code, not the narrative. Commit messages are first-draft claims too.
- **Not asking about ambiguity.** If the code has two plausible readings, mark `[UNVERIFIED]` and ask. Inventing a plausible-sounding semantics is the fastest way to make a doc silently wrong.
- **Skipping the retro on "small" passes.** A 10-minute Workflow 2 still has a retro — without it, the next writer (or future-you) has no signal on whether anything was missed.
- **Running Workflow 2 on a dirty tree.** A fast fix cited against a tree that isn't in git is a lie. Stash or abort.
- **`arra_learn(pattern=...)` expects prose, not a pre-wrapped markdown doc.** arra_learn wraps its own `---\ntitle: ...\n---` around whatever you pass as `pattern`. Passing a document that already contains a frontmatter block (e.g. an earlier arra_learn output, or hand-authored markdown starting with `---\ntitle: ...`) produces the nested **double-wrap** bug: filename begins `_title-*`, outer `title: ---`, two frontmatter blocks, `verify.sh` flags it. A tool-side strip-and-warn guard landed 2026-04-19 (Soul-Brews-Studio/arra-oracle-v3 `stripFrontmatterWrap`), but keep `pattern` as 1–2 paragraphs of plain prose and rely on the guard only as a safety net.

---

## Escalation

When this workflow produces a doc claim that needs **domain-expert verification** (financial, security, invariant-level — anywhere wrong docs would mislead operators), use the **thread-first** pattern. Never put the ask in the PR body: it dies on merge, Step 0 can't sweep it, next agent has no record.

**Thread-first pattern (canonical):**

1. Open the thread:
   `arra_thread(title="verify: <one-line claim>", message="<claim> @ <commit>; source: <file:line>; reviewer: <@role>")` → capture `thread_id`.
2. Anchor the claim in the doc: insert `[AWAITING_THREAD:<thread_id>]` inline at the exact section the thread is about.
3. PR body, single line: "Pending verification: `arra_thread_read(<id>)` — see `[AWAITING_THREAD:<id>]` markers. When reviewer calls `arra_thread_update(status="answered")`, next W2 Step 0 sweeps it automatically."
4. Do **NOT** ask the question in PR body prose or review comments. Step 0 only sees `[AWAITING_THREAD:*]` anchors in committed docs. Threads are the durable record; the PR is the delivery vehicle.

**Categories that trigger thread-first escalation:**

- **Financial-behavior change** (wallet ops, fees, settlements, payout expiry, wallets_change_logs invariants) → CC `code_reviewer` on the thread. Fast-fix still allowed if purely documentation, but flag in retro.
- **Security-sensitive change** (auth, RBAC, callbacks, MDR, OTP, signature validation) → stop the fast-fix. CC `security_auditor` on the thread. Do not land public-facing doc updates for this claim until the thread is `status="answered"`.
- **Invariant-level claim** describing behavior that domain experts must ratify (e.g., "X happens only when Y was previously Z") → same pattern; the thread is the durable record that the claim was verified (or corrected) at this commit.

**Other escalations (no thread needed):**

- Commit range reveals that a prior baseline claim was wrong (not the commit's fault — the baseline missed it) → file `#drift` with the original Workflow 1 commit as the provenance, not the current commit. This is P-004 in action.
- Commit touches both current and target systems (shared code) → stop. That contradicts SKILL §3 ("Current and Target, never mixed"). Human decision needed before proceeding.

### Memory/search/trace anomalies — escalate to brew-ops (non-blocking)

**Fire-and-forget.** Filing a handoff does NOT block this workflow or wait on brew-ops. Finish your pass normally — brew-ops picks up asynchronously on its next session. No `[AWAITING_...]` anchor, no Step 0 sweep. The handoff file itself is the durable record.

If your pass encounters one of these patterns and cannot resolve it in scope:

| Symptom | Likely cause |
|---|---|
| `arra_search` returned 0 for content you know exists | possible FTS5 / vector / tokenizer drift |
| `arra_learn` succeeded but search can't find the new entry | possible indexer / vector connect race |
| `arra_trace` succeeded but `arra_trace_get` returns missing fields | possible trace tool bug (e.g., 2026-04-21 trace project-corrupt incident) |
| `arra_supersede` says success but old doc still appears un-flagged | possible supersede chain breakage |
| Closed thread leaves `[AWAITING_THREAD:N]` markers stranded across repos | cross-repo orphan — see workflow-5 §13c |
| `verify.sh` fails with new pattern not covered by existing fixes | possible new corruption class |
| Path-typo files (`bank-bot<`, `pure-bot`, etc.) keep recurring | input-validation gap |

Don't try to debug in-pass. File a handoff at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ/inbox/handoff/<YYYY-MM-DD>_<HH-MM>_brew-ops_<topic>.md
```

Format per `arra-oracle-v3/.agent/skills/brew-ops/references/workflow-5-memory-audit.md` §How this workflow gets triggered → §B (Escalated handoff). brew-ops picks up on next fresh wake; **your workflow does not wait.**

If unsure whether to escalate: file a P2 handoff with `expected outcome: investigation only`. brew-ops can downgrade to "no action needed" cheaply; a missed real signal is more expensive.

---

## Relationship to other workflows

- **Before you run Workflow 2**: Workflow 1 must have produced a valid `docs/.baseline`.
- **After you run Workflow 2**: if you deferred anything, Workflow 4 has new items in its queue.
- **When Workflow 2 fails the escalation test**: Workflow 1 is the fallback for "too much changed"; Workflow 4 is the fallback for "found a drift that predates the commit range".
- **When the commit introduced a decision that the human approved**: file a tiny `arra_learn` with `#decision` tag in Workflow 2, and schedule Workflow 5 (ADR) as a separate follow-up — do not bundle ADR writing into Workflow 2.

---

## Change log for this workflow file

- 2026-04-16 — Initial draft by a Claude Code assistant during a debugging session for arra-oracle-v3. Written from the SKILL.md commit-tracking contract (§Commit tracking contract) and by mirroring Workflow 1's structure. **Not yet reviewed by the `technical_writer` agent** — treat as draft until the next `pg-writer-oracle` session ratifies it.
- 2026-04-17 — Added Step 2b (open a W2 trace with `queryType="evolution"`, then `arra_trace_link` to the prior baseline/W2 chain head). Each W2 pass is now a node in a horizontal chain that shows evolution over time: W1-baseline → W2₁ → W2₂ → … Future agents reconstruct the sequence with `arra_trace_chain(<any-node>)`. DoD tightened to require the trace and the link. Findings inside the pass (`#drift`, `[UNVERIFIED]`, deferrals) are still filed as `arra_learn` — not as child traces — because W2 work units are typically smaller than W1 and the per-finding child pattern there would be noise. If a single W2 pass grows large enough that per-finding children help, fall back to the W1 pattern and note it in the retro.
- 2026-04-17 — Added Step 2c (cross-repo sibling link). Motivation: daily W2 cron runs in mobiz + bank-bot often cover related commits (shared contract, callback shape, signature helper, OTP endpoint). When that happens, the two W2 traces chain to each other via `arra_trace_link` and a paired `arra_learn` tagged `#cross-repo-sync` records the semantic reason. Link direction is temporal (older = prev); readers should not over-interpret it as causal. If you run first and no other-repo trace exists yet, defer — the other repo's W2 will link back. DoD added a check that refuses "forgot to look."
- 2026-04-17 — Added **Step 0 (Resolve answered threads in territory)** as a blocking gate before Step 1. Motivation especially acute for W2: the daily cron re-runs the workflow every morning, so a skipped thread check ages a zombie thread by 24h per cycle. Scoping via doc-anchored grep (not title prefix) — see `workflow-thread-resolve.md`. DoD added two items: Step 0 clears to zero, and every `arra_thread(...)` in the pass inserts a paired `[AWAITING_THREAD]` marker (anchor discipline).
- 2026-04-18 — **Escalation rewritten thread-first.** Prior version said "CC `code_reviewer` in the PR description" for financial-behavior claims and "CC `security_auditor` via `arra_inbox`" for security. Both have the same failure mode: once the PR merges, the verification ask is buried — `arra_search` can't find it, next agent has no record, workflow Step 0 can't sweep it. The `[AWAITING_THREAD:*]` anchor + `arra_thread` infrastructure already exists for exactly this, and was asymmetrically underused. All verification-needed escalations now open a thread, anchor the doc, and carry a one-line pointer in the PR body — the thread is the durable record, the PR is only the delivery vehicle. Meta-workflow edit by `brew-ops` with human approval (not a technical-writer session); peer roles can ratify or counter-edit on their next pass.
- 2026-04-19 — **Step 8b (Telegram narrative summary) added** between Step 8 (Commit + PR) and Step 9 (Retrospective). W2 passes run daily and produce durable artefacts (PR, doc update, `arra_learn` entries, `#drift` learnings), but until this step existed the audience for each pass was implicit: the next agent, plus whoever happens to open the PR. There was no push channel where a human operator could passively keep up with the cadence. The step requires composing a ~500-char Thai-language narrative that weaves *why this pass exists* (trace back through memory for the upstream cause — thread, ratification, drift chain) with *what landed* (this pass's outputs), then sending via the `telegram_send` MCP tool (`github.com/Soul-Brews-Studio/mcp-telegram`). Audience is mixed (dev + stakeholder), format is Telegram HTML (`<b>`, `<i>`, `<code>`, `<a href>`), `chat_id` defaults to `TELEGRAM_DEFAULT_CHAT_ID` env set on MCP registration. Zero-doc-change passes still send a short "no drift, baseline bumped" note so the channel cadence reflects that the workflow actually ran. Fallback is `#telegram-failed` learning + continue — the PR is the load-bearing artefact; Telegram is the delivery vehicle. DoD tightened with a Step 8b acceptance line.
- 2026-04-19 (later, brew-ops) — **Step 9 retro path discipline + §The ψ/ trap added** after a live retro-leak observed on the 15:06 W2 pass. Prior Step 9 said only "Run `rrr`" — no path, no anti-trap warning. The agent wrote the retro to `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md` (stray in the product repo working tree) instead of `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/19/15.06_...` (vault via symlink). Not an agent failure — a spec ambiguity: `ψ/memory/...` looks like a vault path but resolves cwd-relative in a worktree. Observation triggered broader audit: 21 files already committed in mobiz git history from this exact trap across three failed cleanup-and-revert rounds (`414f568` / `2965cda` / `da4d13a`). Fix: Step 9 now mandates (a) pre-write `readlink` check on `~/.arra-oracle-v2/ψ`, (b) absolute-path-via-symlink for the destination, (c) explicit list of the 4 traps NOT to take, (d) post-write stray-find that must return empty, (e) documented recovery recipe if a stray is found. New `§The ψ/ trap` section at end-of-file explains the topology (vault vs symlink vs stray) + links the historical incidents. DoD tightened: one line for the absolute-path retro, one for the stray-check. Trap applies to all workflows that call `rrr` (W1/W4/W8/W9), but this pass fixes only W2 per scope; others inherit the same discipline on their next revision.
- 2026-04-19 (later, user) — **Step 8b Telegram length target bumped 500 → 700 chars.** Hard cap unchanged at 800 (physical screen constraint). Prior target was intentionally conservative (mobile-first) but in practice the backstory-weave + flow-affected line + learnings split rarely fit under 500 without dropping the "why" sentence — the exact part the audience needs most. 700 gives ~2 more sentences of breathing room while still keeping the message inside one Telegram screen. No template change; composers should spend the added budget on the *why-this-pass-exists* paragraph, not extra bullets.
- 2026-04-19 (later, user) — **§Common pitfalls: `arra_learn(pattern=...)` prose-only rule added** (sibling-synced with bank-bot W2 edit the same day). Backstory: six double-wrap learnings landed in the vault earlier today (2 mobiz, 4 bank-bot) because agents passed full markdown documents (including their own `---\ntitle: ...\n---` frontmatter) as `pattern`. arra_learn wraps its own frontmatter around whatever is passed, so a pre-wrapped input produces nested frontmatter, filename `_title-*`, and outer `title: ---` — the exact corruption signature verify.sh names "arra_learn double-wrap bug". A tool-side guard (`stripFrontmatterWrap` in Soul-Brews-Studio/arra-oracle-v3 `src/tools/learn.ts`) landed the same day and strips + warns on detection, but making the boundary explicit in the workflow means agents stop relying on the guard. verify.sh (Step 9d-equivalent pre-commit gate) still catches any that slip past; the pitfall bullet + tool guard are belt-and-suspenders.
- 2026-04-20 (brew-ops) — **Step 8 split into 8.0 (detect) → 8.A (amend) / 8.B (new), with a new DoD line "one open W2 PR per repo".** Trigger: the W2 watcher (`arra-oracle-v3/scripts/w2-watcher.sh`) fired 5× overnight 2026-04-19→20 (3 bot-writer + 2 pg-writer triggers; settle 30 min, min_gap 2 hr — all per design), producing 6 stacked W2 PRs (3 on mobiz, 3 on bank-bot) all from the same `.baseline` (`1ffafc1` for mobiz, `0ea0e80` for bank-bot). Each new PR fully superseded the previous because the prior version's branch was static while `.baseline` did not bump (Step 7 only bumps on completion of in-territory work — none completed because PRs were unmerged). Root cause: Step 8 always created a fresh branch + PR without checking for an open W2 PR on the same repo. **Empirical precedent** for the amend procedure: 2026-04-20 10:25 GMT+7 retro at `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/20/10.25_w2-extend-pr242-bank-rotation-f694dcd.md` documents pg-writer manually extending PR #242 (`1ffafc1..386f0a7` extended to cover `f694dcd`, body rewritten, trace chain `9e30baaf → 6b2543d9` linked). The retro's Honest Feedback section explicitly requested this spec change verbatim: *"If this pattern persists, add a §Extension sub-procedure to the workflow covering: (1) branch switch + merge main, (2) layer one commit per new in-range commit, (3) update PR body rather than opening a new one, (4) trace chain continuation. Would have saved me 5 minutes of second-guessing."* The new 8.A mirrors those four steps. `.baseline` discipline unchanged (still bumps only when Step 7's "no in-territory deferrals" gate passes — extending the PR doesn't bump it either, baseline discipline is anchored to merge-time, not write-time). Sibling-synced; bank-bot W2 gets identical change.
- 2026-04-22 (brew-ops, Gap 1 root-cause fix — incident #1) — **Step 2c detection bullet added + new §Sibling-flow-doc citation case (no defer)** (sibling-synced with bank-bot workflow-2-track-commit.md). Same rule text: a file in the range cited in a sibling flow doc is now a first-class cross-repo signal, overrides the "defer" branch, and mandates a `#cross-repo-sync` learning + `arra_handoff` to the sibling writer. See bank-bot copy for the originating incident (bank-bot `e3db48a` 2026-04-19 drifted 3 days against mobiz flow docs).
