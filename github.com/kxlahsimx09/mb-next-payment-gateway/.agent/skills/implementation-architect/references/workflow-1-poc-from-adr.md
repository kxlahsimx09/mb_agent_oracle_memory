# Workflow 1 — PoC from ADR

> Reference document for the `implementation-architect` agent (`next-impl`).
> Read this file before running the workflow. Do not skim.

This workflow converts one ratified ADR slice into a runnable, falsifying PoC plus spec tests asserting the ADR's promised claims. It is the primary working loop of `implementation-architect`. Each pass picks **one ADR** (or one slice of a multi-claim ADR) and produces:

- a `poc/<adr-id>/` directory containing README + spec tests + minimum-viable source + fixtures (and conditionally an `evidence/` sub-dir with mined assets);
- one `arra_learn` summarizing outcome (`#poc-ready` / `#poc-drift` / `#poc-gap` + one `#decision` if a substrate choice was made);
- a retrospective at `ψ/memory/retrospectives/...` (AI Diary + Honest Feedback mandatory).

The workflow is **repeatable** — running it N times across the 12 ratified ADRs is the day-1 plan. PoCs are throwaway by design; cheapness rules in §6 of `SKILL.md` are non-negotiable.

---

## When to run this workflow

Run when **any** of the following is true:

- A `#decision` ADR carries `#poc-ready` from `next-architect` (default eligibility).
- A `#provisional` ADR carries `#poc-invite` (architect explicitly invites early validation).
- I pick any `#decision` ADR — gated by architect's `#defer-poc` veto.
- An answered thread resolves a `[AWAITING_THREAD]` anchor previously blocking a PoC.
- `next-architect` files a drift report (W2 fast-lane) on a passing PoC and the amendment requires re-validation.

Do **not** run this workflow for:

- Authoring or amending ADRs (architect's W1).
- Building production code (dev's lane).
- Auditing `#current` integration tests (pg-tester's W1).
- Designing wallet schema cross-cuts before a `wallet` ADR exists (surface as `[POC_GAP:wallet:cross-RPC-contention]` and stop).

---

## Preconditions

Before Step 0:

- [ ] The repo is clean (`git status --porcelain` empty in `mb-next-payment-gateway`). Stash or abort otherwise.
- [ ] `main` is up to date for both `mb-next-payment-gateway` (the product repo where `poc/` lives) and `mb_agent_oracle_memory` (where `.agent/` lives via symlink).
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). Hard prerequisite.
- [ ] No other `[POC_ACTIVE:<adr-id>]` marker exists for me — I serialize my own work; one PoC at a time.
- [ ] At least 90 minutes of focused time; rushed PoCs surface false-negative drift (substrate noise misread as ADR violation).

---

## Territory (paths I touch)

```
poc/<adr-id>/                                       # primary write surface
poc/<adr-id>/README.md                              # 1-page claims + scope + cite block
poc/<adr-id>/tests/*.spec.{ts,sql,go}               # spec tests, name == claim
poc/<adr-id>/src/                                   # minimum viable PoC
poc/<adr-id>/fixtures/                              # inline data + bank-quirk shapes
poc/<adr-id>/evidence/<source-slug>.{csv,log,json,md}  # CONDITIONAL — only when cite has a fixture asset

ψ/memory/learnings/                                 # arra_learn outputs
ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md    # rrr output
```

Files **not** in my territory (never edit):

- `docs/adr.md` and anything under `docs/design/` / `docs/api/` / `docs/data-model.md` — `next-architect`'s artifacts. I cite; I never patch.
- `supabase/functions/` / `supabase/migrations/` — `next-dev`'s production code. Even after `[POC_PROMOTED]`, dev forks; PoC dir stays frozen per P-001.
- `mobiz-payment-gateway/` / `bank-bot/` anything — `pg-writer` / `bot-writer` / `pg-tester` own their lanes. I read via `arra_search` + direct-read of `docs/flows/` / `integration-tests/` only.

---

## Inputs (priority order — cheap to expensive)

1. `docs/adr.md` HEAD — the ADR slice itself. Direct-read; do not summarize from memory.
2. **Vault (`arra_search`):** `#prior-art`, `#regression-candidate`, `#drift`, `#gotcha`, `#current` learnings tagged with the relevant subsystem slug. Architect's `#prior-art #w1-input-5` corpus is shared — re-mine only when (a) cite is older than the most-recent baseline, or (b) a `code:file.go:N@<sha>` pin is needed and not yet in the learning.
3. `mobiz-payment-gateway/docs/flows/*.md` + `bank-bot/docs/flows/*.md` direct-read — `// impl:` line-anchors are the highest-density source of substrate truth per byte.
4. `mobiz-payment-gateway/integration-tests/test-*.sh` + `mock-bank/FIXTURES.md` + `tests/*.go` — pre-curated real-case scenarios + bank-quirk shapes.
5. `pg-tester`'s `#coverage-gap` learnings — valid evidence inventory; cite like prior art.
6. mobiz repo source HEAD (`models/`, `services/`, `controllers/`, `scheduler/`) — last-resort when a `code:file:LN@<sha>` pin is needed and no learning carries it. Always re-pin with the actual current SHA.
7. `integration-tests/*.log` (~52,500 lines) — closest substrate to "raw text logs" without prod access. Use for behavior-shape evidence (sequencing under failure, race outcomes).
8. **Tier-C** (raw production Mongo, bank-bot Playwright archives, Telegram operator logs) — **NOT vault-resident**, **NOT required for Tier-1**. Tier-2/3 PoC author files `[ESCALATE_TO_HUMAN:thread-N:tier-c-evidence-channel:<artifact>]` per AGENTS.md §11h *before* scaffolding.

---

## The 8 steps

### Step 0 — Thread sweep

Resolve any `[AWAITING_THREAD:N]` anchors I or peer roles left in `poc/*/README.md`. Read each thread; if answered, fold the resolution into the affected README and remove the anchor. If still pending and load-bearing for the ADR I am about to PoC, **defer that ADR to a later pass** — the unresolved thread will produce a more efficient PoC after it closes.

### Step 0.5 — Directed-inbox sweep

Sweep `~/.arra-oracle-v2/ψ/inbox/for-next-impl/*.md` per AGENTS.md §11e. **Campaign-scope it (§11e / thread #214):** `for-next-impl/` is shared with any sibling `next-impl` session running a different campaign — handle **only** envelopes whose wake key (`parent_thread` else `thread`) matches the campaign you were woken for (the `inbox: <fname>` envelope); leave a sibling's envelopes in place (the watcher routes them to the right session). For each **in-scope** unread envelope:

- `consult` / `escalate` — read the cited thread, reply in-thread, then write the reply envelope to `for-{requestor-oracle}/`, then archive my own consult envelope per §11d.
- `notify` — fold the heads-up into my working notes; archive immediately.

If the inbox has any consult that supersedes the ADR I am about to PoC (e.g., architect filed a `[REOPEN_ADR]` for it), pause this run and address the consult first.

### Step 1 — Pick the ADR slice

Eligibility (most-restrictive first):

- (a) `#decision` ADR carrying `#poc-ready` from `next-architect` — default;
- (b) `#provisional` ADR with `#poc-invite` — architect-invited early validation;
- (c) any `#decision` ADR I pick — gated by architect's `#defer-poc` veto.

Day-1 Tier-1 ranking (Postgres-only-floor): **§ADR-3 → §ADR-4b → §ADR-4a → §ADR-4c**. Reasoning lives in `SKILL.md` §"Cheap PoC criterion".

Anchor `[POC_ACTIVE:<adr-id>]` in `poc/<adr-id>/README.md`. **One active marker at a time** — I serialize.

### Step 2 — Extract ADR promises (amended per parent #69 msg 175 §D)

Before writing any code, extract every assertable claim from the chosen ADR slice and list them in `poc/<adr-id>/README.md`. Each claim:

- ≤ 1 sentence;
- falsifiable by running code;
- classified — one of:
  - **behavior-shaped** (race outcomes, contention shapes, sequencing under failure) — **MUST cite ≥ 1 `#current` evidence source** before passing to Step 3 (see Step 3 cite block shape);
  - **structural** (schema, idempotency-key format, type signature, invariant on a column) — cite a `#current` precedent when one exists; otherwise note inline: *"no `#current` precedent — pure substrate assertion."*

Out-of-scope claims (operational, browser-real, cross-ADR cross-cut) documented explicitly with the reason — **don't fake the test**. Surface as `[POC_GAP:<adr-id>:<test-name>]` if the claim is load-bearing for the ADR but unfalsifiable cheaply.

**W1-Input-5 derivative discipline.** Architect's `#prior-art #w1-input-5` corpus is shared. Re-mine independently only when (i) cite is older than the most-recent baseline, or (ii) a code:line:commit pin is needed and not in the learning. New mines file `arra_learn #prior-art #w1-input-5` per W1's "expensive source becomes cheap source" rule — net: one shared corpus, no private mining lanes, no double-authoring.

### Step 3 — Scaffold the PoC (amended per §D)

Create `poc/<adr-id>/{README.md, tests/*.spec.*, src/, fixtures/}`. Each spec test:

- name == claim (test name and claim line read identically);
- docstring carries a **2-line evidence cite block**:
  ```
  // (a) ADR claim line-anchor: docs/adr.md §<adr-id> Decision N
  // (b) #current evidence:    <vault-learning-id> | integration-tests/<path>:LN
  //                            | <log-timestamp>  | docs/flows/<file>#<section>
  //                            | code:<file>.go:N@<sha>
  ```

If the cited case has a non-trivial fixture asset (CSV row, log lines, JSON shape sample), drop it under `poc/<adr-id>/evidence/<source-slug>.{csv,log,json,md}`. **No empty `evidence/` dirs** — directory existence is conditional on cite.

The PoC `README.md` collects every test's `(b)` line into a §evidence-cited block at the end so a reader gets the full provenance map without grepping the test files.

### Step 4 — Implement minimum viable PoC

Cheapness rules (binding):

- mock everything not under test (HTTP clients, browser, Telegram, scheduler, file-system caches);
- hardcode params (no config files, no env-driven knobs);
- one process / one binary (no multi-service compose unless the ADR claim is itself a multi-service contract);
- faithfulness to production wiring is `next-dev`'s lane — not mine.

If the substrate is Postgres-only (Tier-1 default), the PoC is a `schema.sql` + `rpc.sql` + pgTAP spec + a 50-line mock-bot script (when applicable). If Supabase escalation is justified (§ADR-8 / §ADR-4 — see SKILL.md §6), use a local `supabase` project with `--no-verify-jwt` for cheapness.

### Step 5 — Run tests + mutation tests; classify each failure

For each failing test, walk REPRODUCE → ISOLATE → DIAGNOSE → FIX (debug skill chain) and classify:

- **(a) PoC has a bug** — fix in Step 4 loop and re-run.
- **(b) ADR cannot hold under execution** — drift report (W2). Anchor `[POC_DRIFT:<adr-id>:thread-N]` in PoC README.
- **(c) ADR is silent on a load-bearing case** — drift report (W2) flagged as scope-extension.
- **(d) Test was implementation-grounded** — rewrite the test against the actual ADR claim; re-run.
- **(e) Mutation passed test** — the spec test isn't pinning the claim; rewrite. Mutation results land in PoC README §mutation-results.

Mutation tests run after a green test pass. Targets: stripping `FOR UPDATE`, swapping `INSERT` order in atomic RPCs, replacing `WHERE expires_at > now()` with `TRUE`, dropping `SKIP LOCKED`, re-ordering INSERTs in finalize bundles. If a small mutation passes the test, the test is implementation-grounded — rewrite per (e).

### Step 6 — Drift handling

(b) and (c) outcomes defer to W2 — see `references/workflow-2-drift-report-to-architect.md`. (a) / (d) / (e) loop within W1.

### Step 7 — `arra_learn` for non-drift outcomes

Pick the right tag based on outcome:

- `#decision` — substrate or fixture choice with rationale (e.g., "use pgTAP not pg_unit because mutation-test integration is cleaner");
- `#gotcha` — substrate pitfall surfaced (e.g., "pgTAP `lives_ok` swallows assertion failures inside `EXCEPTION WHEN OTHERS` — use `throws_ok` instead");
- `#poc-ready` — ADR validated, dev seed; pair with a candidate `[POC_PROMOTED]` once dev consumes;
- `#poc-gap` — deferred-design dependency surfaced (e.g., wallet-schema cross-cut needs its own ADR pass).

Mandatory tags: `implementation-architect` + `repo:mb-next-payment-gateway` + `next` + `<feature>` + `<special>` + (when applicable) `<fixture-source:*>` + `<fixture-incident:*>`.

### Step 8 — Retrospective

`rrr` short code → `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_<slug>.md`. AI Diary + Honest Feedback **mandatory** sections — those carry context that technical documentation alone cannot.

---

## Worked example — §ADR-4b finalize_deposit (activation-time inclusion)

**Claim:** *"`finalize_deposit` closes mobiz Q4a (paid + uncredited) unconditionally; `paid` + uncredited wallet structurally impossible."*

**Step 2 cite (vault search):**
- `2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no` (Q4a paid+uncredited drift)
- `2026-04-22_current-system-prior-art-stale-processing-triage` (related sweep-triage prior art)

**Step 3 cite block in `poc/4b/tests/finalize-closes-q4a-unconditionally.spec.sql`:**
```sql
-- (a) ADR claim line-anchor: docs/adr.md §ADR-4b Decision D5
-- (b) #current evidence:
--     ψ/memory/learnings/2026-04-22_current-system-prior-art-stale-processing-triage.md
--     integration-tests/test-deposit-collision-dual.sh:L42-67
--     services/transactionMatcher.go:592-701@37dfb26
```

**Asset:** `poc/4b/evidence/2026-04-22-stale-processing-triage.md` (the slice of the learning that names the Q4a bundle).

**Step 4 PoC:** `schema.sql` (deposits + transactions + wallet) + `finalize_deposit.sql` + pgTAP suite (3 tests: happy path, partial-failure injection, race-guard for `expires_at > now()`).

**Step 5 mutation tests:** strip `FOR UPDATE` from the SELECT, swap INSERT order so wallet update happens before transactions row, re-order so callback_queue INSERT precedes wallet update. Each mutation must produce a failing test — if not, rewrite the test per (e).

**Step 7 outcome (expected):** `#poc-ready` if all greens; `#poc-drift` if the partial-failure injection reveals the bundle is non-atomic in some classification — file W2.

---

## Step 0 sweep coordination with `next-architect`'s W1

`next-architect`'s W1 has a Step 0 (thread sweep) and a Step 0' (directed-inbox sweep). When I file a drift report (W2 below), the marker `[POC_DRIFT:<adr-id>:thread-N]` is what architect's Step 0 picks up. The retroactive backlog lane (W1 Input #6) — `arra_search type=learning #drift #poc cwd=<repo>` newest-first — is a separate sweep architect runs at ADR-baseline time. **Same artifact, two views**; I produce marker + `arra_learn #poc-drift` as one act.

---

## Failure modes and recovery

- **Forgot to anchor `[POC_ACTIVE]`** — another impl-architect session may parallel-PoC the same ADR. Drop the anchor at Step 1; remove only after Step 8.
- **Empty `evidence/` dir** — convention violation. Either drop the cite (the test is structural, not behavior-shaped) or land the asset.
- **Synthetic-only Tier-1 test slipped through** — re-run Step 2 mining; if still synthetic-only, mark `[POC_GAP]` and document in PoC README; do not hide the gap.
- **Mutation test passes** (5e) — the test was pinning the implementation, not the claim. Rewrite the test against the *claim wording*, not against the substrate behavior I observe.
- **Drift report on a `#poc-ready` ADR I just shipped** — pause active PoC, run W2, wait for architect's amendment, then re-validate.

---

## Step 0 sweep cheat-sheet

```bash
# Threads I'm anchored on
arra_search query="AWAITING_THREAD next-impl" type=all limit=20

# Inbox — then campaign-scope: handle only envelopes whose wake key
# (parent_thread||thread) matches the campaign you were woken for (§11e / #214)
ls ~/.arra-oracle-v2/ψ/inbox/for-next-impl/*.md 2>/dev/null

# Drifts on ADRs I might pick
arra_search query="poc-drift" type=learning limit=10

# `#poc-ready` candidates
arra_search query="poc-ready" type=learning limit=10
```

---

**Created:** 2026-05-04 (GMT+7) — activation per parent thread #69 msg 175 §I, sub-thread #74. Steps 2/3 incorporate the §D amendments inline (behavior-shaped vs structural classification + 2-line evidence cite + conditional `evidence/` directory + W1-Input-5 derivative discipline).
