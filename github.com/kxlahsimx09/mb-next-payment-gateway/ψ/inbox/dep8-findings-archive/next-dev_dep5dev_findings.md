# next-dev findings — DEPOSIT-005 (campaign dep5dev), 2026-06-04

**Role:** next-dev (Builder). **Branch:** `campaign/dep5dev`. **PR:** #328 (into `main`, **NOT merged** — parallel-build PR).
**Story:** DEPOSIT-005 — multi-candidate review / safety branch of DEPOSIT-002. Step 0 (SPEC-first) + Step 1 (build) of `docs/build-workflow.md`.

---

## 1. SPEC (Step 0 — published + broadcast)

- **Path:** `docs/spec/deposit-005-multi-candidate-review.md`
- **Branch:** `origin/campaign/dep5dev` (committed `5cbb209`, pushed early before the build per the SPEC-sharing norm).
- **Tester reads it via:** `git show origin/campaign/dep5dev:docs/spec/deposit-005-multi-candidate-review.md` (contract, never the code).
- **Broadcast:** sent branch+path to team-lead to relay to next-tester (campaign `dep5test`).

The SPEC names the full observable surface: the parsed-key ≥2-candidate trigger; the degenerate→FIFO-oldest auto-pick vs real-ambiguity/cross-client→`review` parking branch; the `match_deposits_cascade(uuid, timestamptz)` return outcomes (`finalized_fa1_degenerate` / `review` / `refused_temporal_unsafe_fa1` / `already_consumed`); the enriched `match_candidates` row shape; the new `match_note` column; the cascade/sweep exclusion of `review`; the `admin_resolve_multi_candidate` resolution path; and an AC→observable map (§7) for probe binding. The LIFO→FIFO fix is documented in §6.

---

## 2. Deploy artifact (Step 1 — handoff to brew-ops)

**One forward-only migration:**

- `supabase/migrations/20260604000010_deposit005_multi_candidate_review_fifo.sql`

Cross-stack `db push` to **tester + seal** is **brew-ops** (role-isolation refinement — next-dev holds only `dev-N` slots, not `tester.env`/`investigator.env`). I landed the migration on the PR branch; **brew-ops applies it to tester + seal**. I did **not** deploy it myself. (No local `psql` available for a parse-check; supabase CLI present but a live dev push needs the dev slot password — left to the deploy owner. The migration is `CREATE OR REPLACE` + additive `ADD COLUMN IF NOT EXISTS`, fully idempotent and forward-only; no landed migration was edited.)

---

## 3. What I built vs what already existed

### Already existed at HEAD (verified by reading the substrate — NOT rebuilt)
The DEPOSIT-005 skeleton was largely already in the deployed cascade (`20260603000030`) + admin-resolve migration (`20260519000008`):

- The Step-1 `≥2`-candidate branch that parks at `match_status='review'`.
- The degenerate carve-out **gate** `v_distinct_sources = 1 AND v_distinct_clients = 1` (the §ADR-4b §Amendment 2026-05-19 client-scoped tuple).
- **Cross-client parking** (AC#3): `v_distinct_clients > 1` falls through to `review` — already correct.
- The **NT-9 single-consumption guard** (`match_status NOT IN ('pending','unmatched') ⇒ already_consumed`) — money-safety (≤1 finalize ever) **and** the cascade-side **sweep-exclusion** of `review` statements (AC#4/#7).
- The `sweep_unmatched_statements` cron filter `match_status IN ('pending','unmatched')` — already excludes `review` (AC#4).
- **§ADR-20 clock binding** — `v_now := COALESCE(p_now, app_now())`, never wall-clock.
- The **admin resolution path** (AC#6): `admin_resolve_multi_candidate(...)` RPC + `admin-deposit-resolve` EF — runs `finalize_deposit` for the chosen deposit, flips the statement `review → matched` with `matched_request_id`, leaves the other candidates `pending`.

### What I actually built (the three deltas — base body verbatim otherwise)

1. **LIFO→FIFO fix (the critical bug).** See §4 below — AC#2.
2. **`match_candidates` enrichment** (AC#5). The review branch previously wrote bare `{deposit_id, request_id}`. Now one entry per matching deposit with the full shape: `deposit_id, request_id, client_name` (joined from `client.name`), `account_name, account_no, bank_code` (the `customer_bank_*` columns), `amount`, and `name_score`.
   - `name_score` is a **minimal deterministic placeholder** (`1.0` iff the statement `description` contains the deposit's `customer_bank_account_name`, else `0.0`). The full name-match **algorithm + admin-UI semantics are design-deferred** per the AC open question; it is surfaced for **admin visibility only and is never used to auto-pick** (Q4c safety). Tester note: assert the **key is present + numeric**, not a specific value.
3. **`match_note`** (AC#1). `bank_statements` had **no** such column. Added it (`ALTER TABLE ... ADD COLUMN IF NOT EXISTS match_note text`, nullable, additive) and write a human-readable note in the review branch: `"<N> deposits match last4=<last4> amount=<amount> dest=<dest_bank_code> — review required"` (e.g. `2 deposits match last4=4416 amount=200.00 dest=scb — review required`). NULL outside the review branch.

---

## 4. The LIFO→FIFO fix (the critical bug)

**Source:** vault learning `2026-06-04_deposit-005-impl-bug-latent-found-by-next-tester` — next-tester observed on the tester stack (`yupsevcrubgprsbujbpu`, 6 runs incl. 2 with `request_id` order reversed, 100% consistent under the §ADR-20 frozen clock) that the deployed degenerate auto-pick **credited the NEWEST-created deposit (LIFO)** and left the FIFO-oldest pending — the **opposite** of the ratified AC's FIFO "oldest created first".

**Root cause (deployed `20260603000030`, the §FA1 degenerate branch):**

```sql
ORDER BY abs(extract(epoch FROM (v_stmt.transaction_date_bkk - created_at))) ASC,  -- proximity-to-statement-time
         created_at ASC
LIMIT 1;
```

The **primary** sort key is the absolute time-distance between the statement's transaction time and each deposit's `created_at`. For a statement that arrives **after** both deposits (the normal case — money lands, then the bot scrapes), the **newest** deposit's `created_at` is closest to the statement time, so it sorts first → **LIFO**. The `created_at ASC` was only a secondary tiebreak, almost never reached.

**Fix (this build):** in the §FA1 degenerate branch only, replace the ORDER BY with pure FIFO-oldest:

```sql
ORDER BY created_at ASC, request_id ASC
LIMIT 1;
```

`request_id ASC` is a deterministic final tiebreak for the (rare) identical-`created_at` case. The proximity key is **intentionally kept** in Step-2a and Step-2b (terminal/checking cross-reference linking) — those steps legitimately want the closest-in-time deposit; only the degenerate auto-pick (a money-moving finalize) must be FIFO per the AC.

**Worked example (AC edge, now satisfied):** DEP1@10:00 (`abc123`) + DEP2@10:05 (`def456`), statement @10:06 → FIFO picks **DEP1** (the older), `matched_request_id='abc123'`; DEP2 stays `pending`. Pre-fix substrate picked DEP2.

**Money-safety unchanged:** ≤1 credited already held via the NT-9 single-consumption guard; this fix corrects **which** of the colliding (economically-identical, same-client) deposits wins, restoring determinism vs the ratified AC.

---

## 5. Scope notes / deferrals (flagged, not invented)

- **Admin-API HTTP endpoint surface is design-deferred** (AC open question; §ADR-4b D6 precedent). The resolution **finalize logic** (`admin_resolve_multi_candidate` RPC) is built and is the contract probes bind to. The `admin-deposit-resolve` EF exists as the HTTP surface, but its precise request/response wire shape is left to the admin-API ADR future — scoped minimally + flagged (like D4-11), not pinned in the SPEC.
- **`name_score` algorithm** — design-deferred (see §3).

---

## 6. Done-when status (this is NOT a self-mark of "done")

- ✅ SPEC published + broadcast (path + branch above).
- ✅ One PR (#328) opened into `main`, story DEPOSIT-005, **not merged**.
- ✅ FIFO-oldest fix included.
- ✅ Findings written (this file).
- ⏭️ **Handoffs (out of my lane):** brew-ops cross-stack deploy of `20260604000010` to tester + seal · next-tester builds probes off the SPEC (campaign `dep5test`, must never read my code) · next-code-reviewer review · next-investigator falsification · next-pm marks done on evidence. I do **not** self-mark done, do **not** merge, do **not** deploy.
