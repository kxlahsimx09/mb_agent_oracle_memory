# Workflow 2 — Document a New/Changed Feature (Track Commit) — bank-bot

> Reference document for the `technical_writer` agent (`bot-writer-oracle`).
> Read this file before running the workflow. Do not skim.

Bank-bot-flavored counterpart of mobiz's `workflow-2-track-commit.md`. Same discipline (surgical update driven by a specific commit range), different territory map.

Output of a successful Workflow 2 pass: updated doc sections with fresh `// verified:` citations, a bumped `docs/.baseline`, any new `arra_learn` entries, and — if a commit was too large to cover in a fast fix — one or more `#drift` learnings queued for Workflow 4.

---

## When to run this workflow

Run when **all** of the following are true:

- `docs/.baseline` exists (Workflow 1 has been executed at least once).
- `git log <baseline>..HEAD --stat` shows commits touching files in the territory map below.
- The commit range does **not** exceed ~5 files or ~300 LOC of behavior change in bot code. (Bot is smaller than mobiz; thresholds scaled down.)

Do **not** run this workflow:

- When `docs/.baseline` is missing — run Workflow 1 first.
- For a new bank adapter (e.g., `banks/kbank/` appears for the first time) — run Workflow 1 so the baseline anchors re-set cleanly.
- For a selector-only sweep across all banks simultaneously — if that happens, it's probably a bank-portal update event; run Workflow 1.
- To describe a target-bot change — that will be Workflow 3 when `bank-bot-next` exists.

---

## Preconditions

- [ ] `git status --porcelain` empty.
- [ ] `git fetch origin && git status -sb` shows no `behind` on the branch.
- [ ] `docs/.baseline` parsable.
- [ ] Oracle reachable (not strictly required; degrade gracefully and note in retro).
- [ ] At least **25 minutes** of focused time.

---

## Inputs you will read

1. `docs/.baseline` — anchor commit.
2. `git log <baseline>..HEAD --stat` — the commit range.
3. `git show <sha>` + `git show <sha> -- <file>` for each touched file in territory.
4. The current-state versions of the touched files (post-change is what the doc describes).
5. The existing doc sections that describe each file (see §Territory map).
6. Oracle — `arra_search` for any prior `#drift` on the same area. A commit often resolves an old drift as a side effect.
7. The PR description (if any) via `gh pr view <number>`. Intent signal; code still wins (P-004).

---

## Outputs you will produce

Required:

- Updated doc section(s) with new `// verified: <path>@<short>` citations against the new HEAD.
- `docs/.baseline` bumped to the new HEAD (two-line format Workflow 1 specifies).
- At least one `arra_learn` per durable fact uncovered. If the commit was pure cosmetic (e.g., comment typo, rename of an internal variable), no learning is needed — note in retro.

Conditionally produced:

- One or more `#drift` learnings — when a commit revealed that the **prior** doc text contradicted code that was already there (pre-dates the commit). Queue for Workflow 4.
- A **scope-overrun note** in the retro — if mid-workflow you discover the commit range is bigger than the threshold. Stop and escalate to Workflow 1.

Never produced in this workflow:

- Full re-read of the system (that is Workflow 1).
- A new top-level doc file.
- ADRs or runbooks.

---

## Territory map (which doc section owns which source)

Used by Step 3 to decide whether a touched file is in-territory for Workflow 2.

| Source pattern | Owning doc section | Fast-fix threshold |
|---|---|---|
| `app.js` | `docs/current-system.md` §2 Runtime loop | touches < 50 LOC |
| `banks/index.js`, `banks/base.js` | `docs/current-system.md` §3 intro | 1 change per pass |
| `banks/<bank>/selectors.js` | §3.N (the matching bank subsection) | 1–5 selectors renamed or added |
| `banks/<bank>/login.js` | §3.N | popup logic tweak, session-reuse tweak |
| `banks/<bank>/maker.js`, `transfer.js` | §3.N | batch size / retry tweak |
| `banks/<bank>/approver.js` | §3.N | OTP source/timeout tweak |
| `banks/<bank>/checker.js`, `statement.js` | §3.N | scraping shape tweak |
| `banks/<bank>/dashboard.js` | §3.N | balance parsing tweak |
| `banks/<bank>/index.js` | §3.N | module registration tweak |
| `core/api.js` | §4 Core → §4.1 | endpoint added/removed |
| `core/browser.js` | §4 Core → §4.2 | launch flag / context change |
| `core/sse.js` | §4 Core → §4.3 + §6 External | event type change |
| `core/otp_email.js` | §4 Core → §4.4 | IMAP pattern change |
| `core/otp_api.js` | §4 Core → §4.5 | poll interval / endpoint change |
| `core/logger.js`, `util.js`, `cursor.js`, `thai-roman.js` | §4 Core → §4.6 | helper semantics change |
| `workflow/<bank>-*.md` | §3.N (that bank's subsection) — cross-check narrative vs code | full workflow rewrite |
| `Dockerfile*`, `docker-compose.yml` | §5 Deployment | build / compose change |
| `scripts/*.sh`, `run-full-flow.sh` | §5 Deployment | ops-script change |
| `.env.example` | §5 Deployment (env table) | variable added/removed/renamed |
| `CLAUDE.md` | cross-check against §1–§5 (any deviation = `#drift`) | any edit |
| `README.md` | cross-check against §1–§5 | any edit |
| `package.json` | §1 Stack | dep added/removed/bumped meaningfully |

Files **outside** this table are out-of-territory for Workflow 2:

- `tests/*.test.js` → belongs to `tester` (future `bot-tester-oracle`; not yet active here).
- `node_modules/**` → vendor; never documented.
- `data/`, `data-*/` → runtime state directories; not documented.
- `ψ/**` (the legacy in-repo directory) → not canonical memory; not documented.

---

## Steps

### Step 0 — Resolve answered threads in territory (blocking, 3–10 min)

Before opening any new work, run `references/workflow-thread-resolve.md` (Pass 1 + Pass 2) to completion.

- **Pass 1 (primary)**: `grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\]' docs/current-system.md workflow README.md CLAUDE.md`. For every id: `arra_thread_read` → if `status="answered"` run the 4-step resolution block (read → classify → update doc + strip/transform marker → `arra_thread_update(status="closed")` + child trace).
- **Pass 2 (safety-net)**: `arra_threads(status="answered", limit=50)` — any id not seen in Pass 1 but clearly bot-writer territory = earlier pass leaked an anchor → file `#workflow-bug + #thread-orphan`.

**Gate:** Step 1 does not start until Pass 1 = 0 and Pass 2 = 0 unfiled. On a daily-cron schedule, Step 0 must clear the same day it runs — skipping ages zombie threads by 24h per cycle.

### Step 1 — Grounding (3 min)

```
arra_search query="technical-writer bank-bot <feature-from-commit-subject>" type=all limit=10
```

Note any prior `#drift` on the area.

### Step 2 — Read the range (5 min)

```
cat docs/.baseline
BASELINE=$(sed -n 's/^current-system-baseline: *//p' docs/.baseline)
git log --stat $BASELINE..HEAD
```

For each commit: read the stat, then `git show <sha>` for a narrative. Form a mental model of "which subsection(s) of `current-system.md` are affected."

Reject the fast path (escalate to Workflow 1) if:

- More than 5 files in the range.
- A new directory appeared under `banks/` (new bank adapter).
- `app.js` changed by > 50 LOC.
- `core/` had > 2 files touched.

### Step 2b — Open the W2 trace + chain to prior (1 min)

Each W2 pass is a follow-up on the most recent baseline (W1) or the most recent W2 for this project. It belongs in a **horizontal chain** (prev → next) so future agents can reconstruct the evolution of `current-system.md` over time without re-reading every retro.

```
arra_trace(
  query="track-commit — <prior-short>..<new-short> (<N> commits)",
  queryType="evolution",
  scope="project",
  project="github.com/kokarat/bank-bot",
  foundCommits=[ ...each commit in the range as { hash, shortHash, date, message } ]
)
# store returned trace_id as W2_TRACE

arra_trace_list(project="github.com/kokarat/bank-bot",
                queryType=["project","evolution"], depth=0, limit=5)
# pick the most recent entry — that's the chain head to extend
arra_trace_link(prevTraceId="<head>", nextTraceId=W2_TRACE)
```

If no prior project/evolution trace exists (first W2 after the very first W1 that pre-dates tracing), skip the `arra_trace_link` call and note it in the retro — the next W2 will chain to this one.

### Step 2c — Cross-repo sibling link (1–2 min, conditional)

Daily W2 cron runs across mobiz + bank-bot frequently touch **related** code (shared contract, callback URL shape, signature format, OTP flow, BOT_SECRET handshake). When both repos changed in the same 24h window for the same reason, chain the two W2 traces together so `arra_trace_chain(<either-W2>)` surfaces the sibling.

**Detect the cross-repo signal.** Any one of these is enough:

- A commit message in the range references the other repo by name (`mobiz-payment-gateway`, `mobiz`, `bank-bot`) or by a ticket id known to span both.
- A file in the range is part of the shared contract: callback payload shape, signature/HMAC header, OTP endpoint client, MDR code/enum, BOT_SECRET env usage.
- The PR description links the other repo's PR.
- A commit message mentions a shared concept (webhook version bump, callback header change, OTP endpoint rename, MDR code rename, signature scheme change).

If **no signal**, skip the rest of this step. Do not speculate.

**Look up the other repo's recent W2 trace.**

```
arra_trace_list(
  project="github.com/kokarat/mobiz-payment-gateway",
  queryType=["project","evolution"], depth=0, limit=5
)
# keep only traces whose created_at is within the last 24h
# pick the most recent one that covers commits landing on the same day or the day before
```

**Decide and link:**

- If a matching other-repo trace exists → `arra_trace_link(prevTraceId=<other-W2>, nextTraceId=W2_TRACE)` (the older of the two is always prev).
- If no trace yet (you ran before mobiz's W2 today) → **defer**. Do not force a parent trace. Mobiz's W2 will list bank-bot traces on its pass and link backward to you. Note the defer in the retro so the human can spot-check that the back-link landed.
- If more than one plausible other-repo trace exists → pick the most recent and file a one-line note in the retro explaining why. Ambiguity here is a signal to talk to the human via `arra_thread`.

**Always, when you link:** file an `arra_learn` tagged `#cross-repo-sync` that names both traces + the shared concept (e.g., "mobiz callback v2 ↔ bank-bot adapter selectors update"). This is the semantic record; the `arra_trace_link` is the navigation record.

**Caveat to keep in mind.** `arra_trace_link` is directional (prev → next) and was designed for temporal evolution. Here we're using it for a sibling-in-time relationship. Readers of `arra_trace_chain` will see the siblings in chronological order but should not over-read "prev → next" as a causal arrow across repos. The `#cross-repo-sync` learning is the authoritative description of *what the two W2 passes have in common*; the link is just the thread that keeps them findable.

### Step 3 — Per-file read + doc update (per file: 5–10 min)

For each in-territory file:

1. Open the current version (HEAD), not the diff. The doc describes the post-change state.
2. Identify the exact doc section from the territory map.
3. Update the section, bumping `// verified:` to the new short hash.
4. If the commit fixed a claim that was wrong even before it landed → add a `[DRIFT]` inline marker and queue a `#drift` learning for Workflow 4. Do **not** silently sweep old drifts into this pass.
5. If a `workflow/<bank>-*.md` narrative exists for this area, cross-check it. A narrative-vs-code mismatch is its own `#drift`.

### Step 4 — Bump `docs/.baseline` (1 min)

Overwrite the two-line file with the new HEAD hash and current ISO-8601 GMT+7 timestamp.

### Step 5 — Log learnings (5 min)

For each durable fact, emit `arra_learn` with the mandatory 3-layer tag set plus feature tags. Examples specific to bot work:

```yaml
tags:
  - technical-writer
  - repo:bank-bot
  - current
  - scb                # or ktb / kbank / bbl
  - selector           # or login / otp / session-reuse / approver / transfer
  # add #drift if this surfaces an old code-vs-doc gap, tag with trace
source: banks/scb/selectors.js:L<line>@<short>
```

### Step 6 — Commit + PR (3 min)

Branch: `docs/track-commit-<short-hash-range>`.

```
docs: track commit <short> — <one-line>

- Updated <sections> in docs/current-system.md
- Bumped docs/.baseline to <new-short>
- Logged <X> arra_learn entries

No bot code behavior changes.
```

PR body: list touched sections, link each new learning, include `**I will not merge this PR. Awaiting human review.**`

### Step 7 — Retrospective (3 min)

`rrr` to `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_bot-track-<short>.md`. AI Diary + Honest Feedback mandatory.

If multiple commits were covered in one session, write **one session-level retrospective** covering the whole range — not one retro per commit. (Mirrors the tester's workflow-2 rule: per-test handoffs are fine, but the retro is session-level. Same principle applies here: per-commit updates are fine, per-commit retros are over-granular.)

---

## Definition of Done

- [ ] Every in-territory touched file has its owning doc section updated.
- [ ] Every updated section has a new `// verified:` citation at the current HEAD.
- [ ] `docs/.baseline` bumped.
- [ ] `arra_learn` entries landed for each durable fact (or retro notes "pure cosmetic, no learnings").
- [ ] Each new `#drift` marker has its paired `arra_learn` for Workflow 4.
- [ ] Branch pushed, PR opened; **not merged**.
- [ ] Retrospective written (session-level, not per-commit).
- [ ] `arra_handoff` entry with PR pointer.
- [ ] Vault audit clean: `bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter` shows `✅ no double-wrap` + `✅ every indexed doc has a title:`.
- [ ] W2 trace (Step 2b) opened with `queryType="evolution"` and every commit in the range in `foundCommits`. If a prior baseline/W2 trace exists for `github.com/kokarat/bank-bot`, `arra_trace_link(prevTraceId=<head>, nextTraceId=W2_TRACE)` was called so the horizontal chain extends instead of forking.
- [ ] Cross-repo sibling check (Step 2c) ran: you either looked for a mobiz-payment-gateway W2 trace in the last 24h and linked (+ filed `#cross-repo-sync` learning), **or** you recorded in the retro that no cross-repo signal was found, **or** you deferred because you ran first and noted the expected back-link. "Forgot to check" is not one of the options.
- [ ] Step 0 ran to completion: Pass 1 left zero `answered`-status markers in bot-writer territory; Pass 2 returned zero bot-writer-territory threads not seen in Pass 1. Daily-cron W2 must clear same-day.
- [ ] **Anchor discipline**: every `arra_thread(...)` call in this pass inserted a paired `[AWAITING_THREAD:<id>]` marker into a doc in the same PR. Orphan thread count = 0.

---

## Common pitfalls

- **Scope creep.** A one-line commit that touches `core/api.js` plus three bank selectors is tempting to cover together. If it exceeds thresholds, split the workflow run or escalate.
- **Mixing multiple banks in one PR.** An update that re-renames a pattern across SCB and KTB simultaneously is two PR's worth of review attention — split.
- **Trusting the PR body over the code.** Intent vs behavior. P-004 applies.
- **Silently sweeping unrelated drifts.** If you notice an old drift while updating a section, file a `#drift` learning and move on — do NOT include it in this PR. Workflow 4 handles drift sweeps.
- **Forgetting the legacy vault.** The in-repo `ψ/` is not our memory. Do not cite from it, do not update it.

---

## Escalation

- **Commit range is larger than expected** → stop, escalate to Workflow 1.
- **Security-sensitive area** (BOT_SECRET flow, credential caching, OTP handling) → CC `security_auditor` when role exists; meanwhile, include human review as explicit reviewer on the PR.
- **Behavior the PR description doesn't cover** (silent change piggy-backing on a stated change) → add it to the doc update but call it out in the PR body and in the retro.

---

## Change log

- 2026-04-16 — Initial version, adapted from mobiz's `workflow-2-track-commit.md`. Territory map rewritten for Node.js + Playwright layout. Thresholds scaled down (bot repo is smaller). Session-level retro rule imported from tester's workflow-2.
- 2026-04-17 — Added Step 2b (open a W2 trace with `queryType="evolution"`, then `arra_trace_link` to the prior baseline/W2 chain head). Bank-bot W2 passes now extend the same horizontal chain the mobiz writer uses — `W1-baseline → W2₁ → W2₂ → …` — and future agents reconstruct the sequence with `arra_trace_chain(<any-node>)`. DoD tightened to require the trace and the link. Per-finding child traces are still filed at W1 scope; W2 findings remain at `arra_learn` granularity to avoid trace noise.
- 2026-04-17 — Added Step 2c (cross-repo sibling link). Motivation: daily W2 cron runs in mobiz + bank-bot often cover related commits (shared contract, callback shape, signature helper, OTP endpoint, BOT_SECRET handshake). When that happens, the two W2 traces chain to each other via `arra_trace_link` and a paired `arra_learn` tagged `#cross-repo-sync` records the semantic reason. Link direction is temporal (older = prev); readers should not over-interpret it as causal. If you run first and no mobiz trace exists yet, defer — mobiz's W2 will link back. DoD added a check that refuses "forgot to look."
- 2026-04-17 (later) — Added **Step 0 (Resolve answered threads in territory)** as a blocking gate. Daily W2 cron is especially exposed to zombie threads because it runs every morning, so a single missed resolution ages 24h per cycle. Scoping via doc-anchored grep — see `workflow-thread-resolve.md`. DoD added: Step 0 clears to zero, and every `arra_thread(...)` inserts a paired `[AWAITING_THREAD]` marker.
