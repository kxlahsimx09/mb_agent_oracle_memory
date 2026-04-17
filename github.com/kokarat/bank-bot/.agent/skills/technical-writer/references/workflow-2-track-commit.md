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
