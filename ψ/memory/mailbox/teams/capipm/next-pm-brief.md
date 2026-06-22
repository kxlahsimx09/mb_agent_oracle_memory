# Brief → next-pm (campaign `capipm`) — mark CLIREAD-001..007 DONE on evidence + rule the LIVE gate

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway`.
**Workflow:** `docs/build-workflow.md` Step 4 — **only `next-pm` marks; the orchestrator never marks.** Mark ONLY on concrete per-step evidence you go and LOOK at. A claim with no artifact stays unproven.

## The epic to mark
`docs/requirements/epic-client-read-api.md` — stories **CLIREAD-001..007** (the merchant read/poll surface: deposit/payout status poll, get-by-id, list+filters+cursor, wallet balance, bank-code list, API-key self-cancel-deposit).

## The evidence (verify each by looking — don't take my word)
- **BUILD:** PR **#610** `feat(§ADR-26 CLIREAD-001..007)` **MERGED to `main`** (squash `70cfa55d0`). The 7 EFs + migration `20260619000100_cliread_client_read_poll_rpcs.sql` are on `origin/main`.
- **REVIEW:** `next-code-reviewer` **APPROVE** — read the **review BODY header** on PR #610 (`gh pr view 610 --json reviews`), NOT the gh state (self-authored PR → COMMENTED; body header is authoritative). Verdict: "APPROVE — conforms to §ADR-26 + epic + SPEC; clean composition; no blocking findings" (+ two explicitly non-blocking follow-ups: a composite pagination index + garbage-UUID→400/404; recorded for fast-follow, NOT blockers).
- **VERIFY/SEAL:** `next-tester` **58/58 PASS** (code-blind, DB ground-truth) → `next-investigator` **SEAL: 59/59 ground-truth checks, ZERO contradictions** at run-sha `c169acc` (= the merged HEAD). The seal grounded the hard teeth in raw tables: 0-lag `expired` (no write-on-read), cross-tenant 404 (reads) vs 403 (cancel), cursor no-overlap, filter narrow-only + tenant isolation, audit single-row idempotency.

## Rule the LIVE gate (§ADR-21 Step 3a) — applicability
The §ADR-21 LIVE gate runs ONE **golden MONEY journey** + recomputes the 4 money invariants from raw tables. **This epic is read-only / non-money:** CLIREAD-001..006 are pure reads; **CLIREAD-007 is a status-only deposit cancel** (`pending → cancelled`, **no wallet debit/credit, no money movement, callback-silent**). So the money-journey LIVE gate has nothing to exercise here — the precedent is the bene/`/bank-accounts` epic, where the **LIVE gate was ruled N/A — non-money epic**, and DONE was marked on build+review+seal. **You make the call:** if you concur it's N/A, record that ruling explicitly and mark DONE on the build+review+seal evidence; if you judge the cancel-write needs a LIVE check, name exactly what and route it back — don't wave it through, don't over-gate it.

## Mark
Per your marking convention, mark CLIREAD-001..007 **DONE** in `epic-client-read-api.md` (with the evidence refs: PR #610 / reviewer APPROVE / tester 58 / investigator SEAL 59-0 / LIVE-N/A ruling) and open the docs PR (or commit per your SKILL). Note the 2 non-blocking review follow-ups in the epic so they aren't lost. **Do NOT mark the deferred CR7 items** (they were never built — they stay deferred, not DONE).

Report back to the orchestrator: which stories you marked DONE, your LIVE-gate ruling, and the marking PR/commit.

Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.
