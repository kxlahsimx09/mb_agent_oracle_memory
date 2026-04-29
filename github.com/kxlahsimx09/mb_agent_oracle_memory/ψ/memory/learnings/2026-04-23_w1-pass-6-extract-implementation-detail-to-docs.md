---
title: W1 pass 6 — Extract implementation detail to `docs/design/withdrawal-lane/`; est
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, design-doc, refinement, w1, pass-6, withdrawal-queue, refactor, convention, adr-vs-design-doc, document-organization, user-surfaced]
created: 2026-04-23
source: docs/adr.md@da53223 + docs/design/withdrawal-lane/* + user dialogue 2026-04-22/23 surfacing the doc-organization drift
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 pass 6 — Extract implementation detail to `docs/design/withdrawal-lane/`; est

W1 pass 6 — Extract implementation detail to `docs/design/withdrawal-lane/`; establish ADR-vs-design-doc convention.

User-surfaced observation during pass-5 review: §ADR-4a had grown to ~450 lines across passes 1-5 — an order of magnitude larger than sibling ADRs (ADR-1..ADR-7 are each 10-30 lines). The content had drifted from decision-level to implementation-spec: full `claim_withdrawal_items` PL/pgSQL body (~40 lines), full Postgres schema with CHECK constraints and helper functions, sweep triage pseudocode, 3-phase-2-alternative balance-drift analysis. All this content is correct and valuable; it was misplaced, not wrong.

Pass 6 refactors: §ADR-4a shrinks to 51 lines (decision record only); implementation detail extracted into a new `docs/design/withdrawal-lane/` directory with five files. No decision content changes. No `arra_supersede` — passes 1-5 ratified direction stands unmodified; only the document organization changes.

## Files created under `docs/design/withdrawal-lane/`

- `README.md` — overview, full prior-art citation list, decision → implementation-file map.
- `schema.sql` — complete Postgres DDL (tables: pool, bank_account, pool_bank_account, bank_account_method, merchant, client, withdrawal_queue, sweep_incident_log, admin_review_queue; enums: pool_status, bank_account_status, working_status, method, source_type, queue_status; function: source_type_to_method; indexes for status/priority/created, bank_account_id partial, claimed_at for sweep, source_type+source_id).
- `claim-rpc.md` — full `claim_withdrawal_items` PL/pgSQL body with inline layered commentary (Layer 2a pool resolution, Layer 2b live method lookup, Layer 3 one-batch invariant, Layer 5 accumulator loop with strict budget + FOR UPDATE SKIP LOCKED + FIFO), companion `set_bank_transaction_id` RPC, bot-side contract for processing order, error codes table, pgTAP test plan sketch.
- `sweep-and-lifecycle.md` — pg_cron registration, Job 1 stuck-claimed triage via `bank_transaction_id` discriminator with full PL/pgSQL body for `sweep_triage_stuck_items`, Job 2 dead-broadcast detection, Edge Function orchestration pseudocode, `mark_failed` / `mark_waiting_to_review` / `mark_success` 4-step lifecycle RPC specifications, role-based access table, admin manual-override path.
- `realtime-filter.md` — subscribe filter syntax (Supabase Realtime Postgres Changes notation), bot-side computation TypeScript pseudocode, three worked-example event walkthroughs (pool payout, admin pullout, admin direct_transfer from deposit-only bank), race mechanics, cold vs hot bot behaviour, reconnect catch-up via `catchup_pending_for_bot` RPC, connection-count budget analysis, four edge cases (no-Mode-1-methods bot, pool membership change, Realtime service outage, plus testing checklist).
- `open-questions.md` — seven deferred implementation-level questions, each with status, concern, mitigation options table, and revisit trigger mapping to ADR-4a:
  1. `bank_transaction_id` discriminator robustness (dual-control assumption + 4 mitigation options A/B/C/D)
  2. Balance-snapshot drift under shared-use shape (3 Phase-2 options)
  3. `waiting_to_review` admin-resolution workflow (deferred to admin-review refine pass)
  4. Heartbeat mechanism design details
  5. `compute-claim-size` Edge Function tier bounds (needs production-metric validation)
  6. Budget semantics strict vs loose (tolerant option if strict causes under-utilization)
  7. Source-doc `batch_id` mirror dispatch implementation (dynamic SQL vs fixed CASE)

## Shrunk §ADR-4a retains only

- Context (including physical-constraint reframe paragraph for the single-batch invariant)
- Eight numbered Decisions (bullets, no code): two-mode schema + pool + Realtime+RPC + pre-claim gate + sweep + lifecycle + admin-override + resolution
- Security boundary paragraph (how Layer 2 closes the current-system gap)
- Consequences (high-level positive/negative, drift pointer to design doc)
- Trade-offs A through G as short summary bullets (alternative + rejection reason, no SQL)
- Revisit triggers (a) through (h)
- Prior art summary (citations pointer to design/README.md for full list)
- Resolved questions (#41, #42, #43 one-line each) + Deferred questions (pointer to open-questions.md)
- "Implementation: see design/withdrawal-lane/" pointer at end

Target reading time: ~5 minutes for the ADR; design docs consulted only when implementing.

## Convention established — ADR vs design doc

**ADR** = *which direction and why*. Terse. Decision-level. Reviewed during design, rarely changes once ratified.
- Good ADR content: "Realtime vs central dispatcher?", "Pool isolation in DB or convention?", "Revert vs triage on stuck items?"
- Signal a section is ADR-appropriate: it could reasonably have gone a different way; the rejection of alternatives is the core value.

**Design doc** (`docs/design/<subsystem>/`) = *how it's built*. Implementation spec. Iterated more freely as implementation details sharpen. Consumed by implementation agents.
- Good design-doc content: full SQL RPC bodies, enum values, state-machine transitions, exact column types, filter syntax, edge-case tables.
- Signal a section is design-doc-appropriate: it specifies a single right answer once the ADR-level direction is set.

**Drift signal:** "this ADR section is becoming an order of magnitude larger than its siblings." Pass 1→5 missed this signal because each pass added justifiable content; pass 6 catches the cumulative drift.

**Future architect workflow:** on every W1 refine pass, ask "does this belong in the ADR or a design doc?" *before* writing. Prefer the design doc for implementation specifics; prefer the ADR for load-bearing decisions.

## Meta-pattern — user peer review driving ADR hygiene

Session history over 2026-04-22 to 2026-04-23:
- Pass 1 (draft) → pass 2 (user ratifies threads #41/#42 + adds pool concept)
- Pass 2 → pass 3 (user asks me to verify claim; pg-writer Hypothesis 3 correction)
- Pass 3 → pass 4 (user notices required_method redundancy)
- Pass 4 → pass 5 (user notices per-row budget bug, balance drift, sweep-revert risk)
- Pass 5 → pass 6 (user notices the ADR has drifted too deep)

Each pass was user-observation-driven. The living-doc + experienced-peer-review loop catches class-of-bug issues the solo architect misses. Logged in the pass-5 learning too; this pass confirms the pattern holds for *document-organization* issues, not just technical issues.

## Related learnings

- `learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` — primary ADR decision record, unchanged.
- `learning_2026-04-22_w1-pass-3-cross-link-thread-43-classification` — fact correction (thread #43).
- `learning_2026-04-22_w1-pass-4-remove-requiredmethod-column-from` — schema hygiene.
- `learning_2026-04-22_w1-refine-pass-5-rpc-accumulator-sweep-triage` — RPC + sweep corrections.
- `learning_2026-04-22_current-system-prior-art-pool-data-model-shar` — pool sharing.
- `learning_2026-04-22_current-system-prior-art-withdrawalqueue-pool` — source-type enqueue split.
- `learning_2026-04-22_current-system-prior-art-stale-processing-triage` — PR #249 triage.
- Oracle threads #41, #42, #43 — all closed 2026-04-22.

## Recommendation for skill.md update (future)

`.agent/skills/system-architect/SKILL.md` §Framework currently describes five-phase design. Should add a §7 or §8 note on the ADR-vs-design-doc convention this pass established, with a pointer to this learning. Deferred — not in the architect's own repo territory (skill lives in central memory repo).

## Tags

system-architect, repo:mb-next-payment-gateway, next, adr, design-doc, refinement, w1, pass-6, withdrawal-queue, refactor, convention, adr-vs-design-doc, document-organization, user-surfaced, extract, living-document

---
*Added via Oracle Learn*
