# Decision Record — Slip-Bearing Past-Deadline Deposits Are Structurally Un-Auto-Matchable (campaign depmatch)

**From:** next-architect · **To:** next-writer + next-dev (propagation per §6) · **Date:** 2026-06-10
**Status:** **DECIDED — Option B RATIFIED `#decision` (owner GO 2026-06-10, "ผมเอา parity")**: keep the deadline as a hard auto-credit boundary — mobiz-verbatim port. Late money (statement arriving past `expires_at`) is **never auto-credited**; a human decides, via the existing admin paths. **NO code/migration change.** The architect lean was A; the owner chose B with the mobiz-parity evidence (§3) in hand — the write-guards are now *affirmed design*, not drift. Propagation is doc-side only: §6 below supersedes the §4 option-conditional change-lists.
**Snapshot:** all line refs at main `9e69725`. Re-verify anchors at HEAD before editing.

---

## 1. The contradiction (what is broken)

The 2026-06-01 **Two-Sweep Restoration** (§ADR-4c/§ADR-4d deptimer amendments, `docs/adr.md:1073-1081, 1823-1830`) made slip-bearing deposits **never expire**:

> *"a pending deposit **with** an uploaded slip **never expires**"* — and DA3 (`adr.md:1063`) promises: *"if a matching statement arrives the deposit finalizes to `paid` **regardless of slip presence** (first terminal wins, unchanged)."*

But the **write-side match guards were never updated** and still refuse anything past its deadline:

- **§ADR-4b D2 Step-1 candidate filter** (`adr.md:636`): `status='pending' AND (expires_at IS NULL OR expires_at > now())`
- **§ADR-4b D5 `finalize_deposit` race-guard** (`adr.md:661-663`, the 2026-04-29 amendment): `status='pending' AND is_matched=false AND (expires_at IS NULL OR expires_at > now())`

**This is not doc-only drift — the guards are live in deployed substrate:**

| Surface | Migration | Guard |
|---|---|---|
| `finalize_deposit` (latest) | `20260603000002_adr20_deposit_path_clock_and_residual.sql:227` | `AND (expires_at IS NULL OR expires_at > v_now)` |
| `match_deposits_cascade` Step-1 (latest, incl. FA1 carve-out branch) | `20260604000010_deposit005_multi_candidate_review_fifo.sql:136,150,221,235,257` | same clause on every Step-1 candidate query |

**Net effect:** a slip-bearing deposit whose deadline has passed is *alive* (never expires, per deptimer) but *structurally un-creditable by the auto-match lane* — Step-1 will not select it and `finalize_deposit` would refuse it even if selected. DA3's "auto-match still wins regardless of slip presence" is true only **before** the deadline.

**The asymmetry that proves it's a bug, not a design:** the READ side already got the slip-bearing carve-out — `v_deposits.effective_status` gained `AND slip_uploaded_at IS NULL` on its expiry CASE in `20260603000040_deposit003_expire_slipless.sql:119` (DA2), so a slip-bearing past-deadline row correctly reads `pending`, NOT `expired`. The whole stated purpose of the `expires_at` write-guard is to **mirror the view** (§ADR-4c D10 read/write contract; the 2026-04-29 amendment text says it exists so "an effectively-expired deposit can never be credited"). A slip-bearing past-deadline deposit is **not effectively expired anymore** — the view says `pending`, the write-guard still says `expired`. The mirror invariant is broken on the write side.

## 2. Exact blast radius (verified against deployed code)

- **Auto-match Step-1 + `finalize_deposit`:** REFUSE past-deadline rows — **this is the hole.**
- **Step-2a link (`checking` deposits):** `20260604000010:321` filters `status='checking'` with **no** `expires_at` clause — unaffected; statement-side linking for V1 fraud keeps working.
- **Step-2b link (terminals):** TL1 five-terminal set, statement-side-only — unaffected.
- **`admin_approve_paid`:** separate RPC (`20260605000010:343-352`), accepts `status IN ('pending','checking')`, **no** `expires_at` guard — the **manual path is open**. So today's de-facto behavior: every late statement on a slip-bearing deposit → admin queue → human approve through the 6-check fraud cascade.
- **Window where it bites:** a slip-bearing deposit is raw-`pending`-past-deadline from the moment its deadline passes until the slip-escalation sweep flips it to `checking` at `slip_uploaded_at + 5 min`. Bounded per deposit (≤ ~5-6 min typical), but **recurring at scale**: per-client deadlines run 5–15 min in production while slips routinely arrive near or after the deadline (that lateness is the entire reason DA1 slip-exclusion exists). After the flip, the row is `checking` and Step-1 exclusion is *ratified* mutual-exclusivity (§ADR-4d D6) — that part is by-design and NOT in scope here.
- **Who pays:** the customer (paid real money, waits on a human instead of seconds-level auto-credit), the admin queue (structural volume through the most error-prone, fraud-cascade-guarded path — exactly what the auto-match lane exists to avoid), and DEPOSIT-005 resolve (a picked candidate past deadline would also be refused by `finalize_deposit`, breaking the admin's pick with a confusing NULL).

## 3. The decision

### Option A — carve out the guard for slip-bearing rows *(architect lean)*

Predicate on **both** Step-1 candidate queries and the `finalize_deposit` race-guard becomes:

```sql
AND ( expires_at IS NULL
      OR expires_at > v_now
      OR slip_uploaded_at IS NOT NULL )   -- DA1/DA2 mirror: slip-bearing never expires
```

**For:**
1. **Restores the ratified D10 mirror-invariant** — write-guards exist to mirror `v_deposits.effective_status`; the view already carries the slip-absent carve-out (DA2, deployed), the write side must match. This framing makes Option A a *corrective* to an already-ratified contract, not a new policy.
2. **Honors DA3 verbatim** ("finalizes to `paid` regardless of slip presence, first terminal wins") with zero wording change.
3. **Money-safety unchanged:** the row being credited is still matched on the full Step-1 three-predicate key (destination + exact amount + source-identity) against a *real* inbound statement; the deposit can no longer become `expired` (DA1 removed it from the expire sweep), so there is no "credit an expired deposit" path being opened — `expired` is unreachable for slip-bearing rows by construction.
4. Keeps admin-queue volume down and the customer auto-credited in seconds — the system's core promise.

**Against / costs:** one forward migration + ADR amendment + epic/spec touch-ups (change-list §4); a statement can now auto-credit a deposit whose *displayed deadline* the end-user technically missed (business answer: the user DID pay and DID upload a slip — crediting is the correct outcome, and it is what DA3 already promises).

### Option B — affirm the status quo (admin-only credit past deadline)

Keep the guards; rewrite DA3 to say auto-match wins only **until the deadline**; for slip-bearing rows past deadline, the statement links via Step-2a/2b and an admin approves manually.

**For:** zero code change; a human reviews every late-payment edge.
**Against:** must *re-ratify DA3 with narrower wording* (the current text promises otherwise); accepts structural admin-queue load + slower customer credit; leaves the D10 write-mirror invariant permanently asymmetric (guard ≠ view) — every future reader re-discovers this as a bug; DEPOSIT-005 resolve must additionally special-case past-deadline candidates or surface a clean error.

**Why I lean A:** Option B doesn't remove the work — it converts an automatic, fully-audited atomic credit into recurring manual work through the force-approve-capable path, and it requires *amending ratified text* (DA3) to match the narrower behavior. Option A makes three SQL predicates match what the next-system ADR layer already says (DA3 + the DA2 read contract).

**Mobiz parity — CHECKED 2026-06-10** (repo `kokarat/mobiz-payment-gateway` @ `74ba557`, 2026-06-09):
- **Write side: mobiz behaves like Option B.** Both per-bank Step-1 matchers exclude past-deadline pending rows with NO slip carve-out (`services/transactionMatcher.go:160-163` KTB, `:246-247` SCB), with the intent comment *"Exclude expired QR deposits — if expired, must wait for admin approve via slip"*. `linkPaidDeposit` on an `expired` deposit is link-only → `match_status='pending_review'` → admin manual approve (`:577-590`; the function-header comment *"revives to 'paid' + updates wallet"* at `:480` is stale dead text — no revival branch exists). Expire sweep skips slip-bearing (`scheduler/deposit_expiry.go:85-97`); escalation at `slip_uploaded_at + 5 min` (`:168-186`). **So Option A is a deliberate divergence from mobiz current, NOT port-fidelity — and Option B is the verbatim port.**
- **Read side: mobiz is coherent where next-system is not.** Mobiz's effective-status read has NO slip carve-out — a slip-bearing past-deadline pending row READS `expired` (`controllers/DepositController.go:1636-1643`), so mobiz's match-refusal is coherent ("everyone sees expired; human decides"). Next-system **already deliberately diverged on the read side** (DA2, deployed `20260603000040:119`): the same row reads **`pending`**. The system therefore tells every consumer the deposit is alive while refusing to credit it when the money arrives — an incoherence mobiz never had.

**Net re-framing after the parity check:** the choice is NOT "bug-fix vs status quo". It is: **(A) complete the already-ratified DA2/deptimer divergence on the write side** (read says alive → match accepts; coherent; classic "deliberate divergence from mobiz current" pattern instance), or **(B) port mobiz's write behavior verbatim** and accept a documented read-write incoherence inside next-system (reads say `pending`, writes refuse) + a DA3 narrowing amendment. The lean stays **A**, now on coherence grounds rather than the (disproven) port-fidelity hope.

## 4. Propagation change-list **if Option A GO**

| # | Surface | Change |
|---|---|---|
| A1 | `docs/adr.md` §ADR-4b | New §Amendment (one block): D2 Step-1 filter + D5 race-guard gain the `OR slip_uploaded_at IS NOT NULL` arm — *"slip-bearing mirror of §ADR-4c DA1/DA2; restores the D10 read/write mirror broken by the 2026-06-01 Two-Sweep Restoration"*. Rewrite the stale inline predicates at `adr.md:636` + `:661-663` in place (per the §H3-Fix inline-correction precedent) so no third copy of the old guard survives. |
| A2 | NEW forward migration | Revise `finalize_deposit` (from `20260603000002` shape — keep `p_now`, `ALREADY_FINALIZED` disambiguation, residual-MDR body unchanged) + `match_deposits_cascade` (from `20260604000010` shape — apply to ALL Step-1 candidate queries incl. the FA1 degenerate-FIFO branch and the temporal-safety re-checks) with the 3-arm predicate. No schema change. |
| A3 | pgTAP / hosted assertions | New tests: (i) slip-bearing past-deadline `pending` + exact-key statement → `finalize_deposit` credits, callback `deposit.paid` queued; (ii) slip-LESS past-deadline → still refused (guard intact for the real expiry case); (iii) DEPOSIT-005 resolve on a past-deadline slip-bearing candidate → succeeds. |
| A4 | `docs/requirements/epic-deposit.md` | DEPOSIT-002: the late-statement edge (`:181`) gains one clause — *"…the matcher excludes expired deposits **(slip-less past-deadline; a slip-bearing deposit never expires and remains matchable while `pending`)**"*. DEPOSIT-003 edge `:250` ("write paths additionally check the deadline") gains the slip-bearing carve-out mirror note. DEPOSIT-004 step 3 already says "auto-match continues to run in parallel" — no change. |
| A5 | `docs/spec/deposit-slice.md` | D2 GAP table + §7 race rows: race-guard text updated to the 3-arm predicate (fold into the rev-10 reconcile pass already proposed for this file's stale enums). |
| A6 | `docs/design/` | `deposit-auto-expire/cross-cut-amendments.md` Amendment 2 (the section that calls slip-bearing→`checking` a "correctness gap", `:80-116`) gets its superseded banner citing A1 — fold into the already-proposed auto-expire sync pass. `matcher-cascade.md:30/99` predicate quotes updated. |

**If Option B GO instead:** B1 — §ADR-4c amendment narrowing DA3's wording ("auto-match wins regardless of slip presence **while the deposit is within its deadline**; past-deadline slip-bearing credit is admin-approve-only by design"); B2 — epic DEPOSIT-002/004 edge-case notes naming the admin-only window; B3 — DEPOSIT-005 resolve EF defined error for past-deadline candidates (`CANDIDATE_PAST_DEADLINE`, distinct from `ALREADY_FINALIZED`); B4 — §ADR-15 alert/queue-SLA consideration for the added `checking` volume. (No migration.)

## 5. Open sub-questions bundled with the GO (answer or defer explicitly)

1. **Mobiz parity check — DONE 2026-06-10**, results inline in §3 above (mobiz = Option B on the write side; next-system already diverged on the read side via DA2). A1's amendment text must cite Option A as a **deliberate divergence from mobiz current** (pattern instance), grounded on the DA2 read-contract coherence argument — not as port-fidelity.
2. **Volume sizing — BLOCKED on dpay MCP** (session invalid at check time; reconnect and re-run): late-credit volume/day (`status='paid' AND paid_at > expires_at`, split by slip-presence and `is_matched`) sizes how much manual admin work the deadline boundary creates today, and validates that `is_matched=true` late credits are ~0 (auto path closed in prod). Optional before GO; required before claiming queue-load numbers in the amendment.
3. **DEPOSIT-005 FA1 carve-out:** under Option A, may the degenerate-FIFO auto-pick select a past-deadline slip-bearing candidate? Lean: yes — same predicate everywhere (one rule, no special case); the FIFO winner is still same-client/same-source.
4. **Out of scope, stated to prevent scope-creep:** Step-1's exclusion of `checking` rows (§ADR-4d D6 mutual exclusivity) is ratified and untouched — once the escalation sweep flips the row, the statement links via Step-2a and the admin approves. This proposal only re-opens the raw-`pending` window.

---

## 6. RATIFIED propagation change-list (Option B — owner GO 2026-06-10; supersedes §4)

No migration, no EF change. Doc-side reconciliation so the affirmed behavior stops reading as a bug:

| # | Surface | Owner | Change |
|---|---|---|---|
| B1 | `docs/adr.md` §ADR-4c (+ §ADR-4b cross-ref) | next-architect | New §Amendment 2026-06-10 (one block, drafted text below): **(i)** DA3 narrowed — *"auto-match wins regardless of slip presence **while the deposit is within its deadline**; once `expires_at` passes, auto-credit is closed by design — the §ADR-4b Step-1 filter + D5 `finalize_deposit` race-guard (`expires_at > now()`, no slip carve-out) are AFFIRMED as the ratified boundary (mobiz-verbatim port: `transactionMatcher.go:160-163/:246-247` — 'Exclude expired QR deposits — if expired, must wait for admin approve via slip'; `linkPaidDeposit` expired→link-only→`pending_review`); late credit on a slip-bearing deposit is admin-approve-only (`admin_approve_paid`, entry `pending|checking`, deliberately deadline-unguarded)."* **(ii)** D10 mirror-invariant annotated with the **deliberate read-write asymmetry**: for a slip-bearing past-deadline row the view reads `pending` (DA2 — the client must not be told `expired` while the slip is under review) while the write-guard stays stricter than the view (no auto-credit) — asymmetry is BY DESIGN, documented here so the next reader does not re-file it as the bug this memo investigated. **(iii)** note the stale mobiz comment `transactionMatcher.go:480` ("revives to paid") is dead text — no revival branch exists; cited so no porter resurrects it. |
| B2 | `docs/requirements/epic-deposit.md` | next-writer | DEPOSIT-002 late-statement edge (`:181`) + DEPOSIT-003 `:250` + DEPOSIT-004 step 3/`:312`: add the one-clause boundary — a slip-bearing deposit past its deadline stays alive (`pending`→`checking`) but is **no longer auto-matchable**; the statement links via Step-2a/2b and **an admin credits it via DEPOSIT-007 approve**. Add one DEPOSIT-002 AC: statement arriving past deadline on a slip-bearing `pending` deposit → **no finalize, no credit, no callback**; statement remains for Step-2a linkage (testable form of the affirmed guard). Cite B1. |
| B3 | DEPOSIT-005 resolve EF (spec + EW1 wire pin) | next-dev (+architect pin) | A picked candidate that is raw-`pending` past deadline → `finalize_deposit` returns NULL today, surfacing as a confusing non-result. Define the error: resolve returns **409 `CANDIDATE_PAST_DEADLINE`** (distinct from `ALREADY_FINALIZED`), directing the admin to the DEPOSIT-007 approve path (which is the ratified late-credit surface). Lean recorded: do NOT add a bypass param to `finalize_deposit` — keep it single-guard. |
| B4 | §ADR-15 / monitoring | next-architect (later pass) | The `checking` queue is now the structural landing zone for ALL late slip-bearing money. Size the alert: volume query in §5.2 (blocked on dpay MCP reconnect) feeds either a threshold bump on P2.10-class queue-depth alerts or a new late-credit-rate signal. Non-blocking. |
| B5 | `docs/design/` | next-writer (fold into the already-proposed sync pass) | `deposit-auto-expire/cross-cut-amendments.md` Amendment 2 + `matcher-cascade.md` predicate quotes: annotate with B1 ("guard affirmed 2026-06-10; asymmetry vs view is by design"). |

**Closed sub-questions:** §5.1 done (evidence in §3). §5.3 → resolved by B3 (no FA1 special case needed — the FIFO branch keeps the same affirmed predicate). §5.4 unchanged (D6 untouched).

**§5.2 volume query — DONE 2026-06-10 (dpay prod, post-reconnect).** Results, feeding B4:
- **The auto path NEVER credits late — guard verified live.** All-time `status='paid' AND paid_at > expires_at`: **9 rows** out of ~1.67M auto-paid. 5 are boundary races ≤14 **seconds** past deadline (lock-window class, by design); 4 are one batch repair script on 2026-03-31 (paid_at within 4s of each other on day-old deposits) — zero organic late auto-credits. Hypothesis confirmed.
- **Mobiz field semantics (code-verified):** admin slip-approve sets only `status`+`updated_at` (`DepositController.go:230-231`) — never `paid_at`, and leaves `is_matched ≠ true` (`:177-178`). The manual population is `status='paid' AND is_matched≠true AND slip_uploaded_at≠null`.
- **Manual admin-slip-approve lane:** 30,927 all-time; **17,548 in the last 30 days ≈ 585/day** (~21.7M THB/30d) — over half of all-time volume landed in the last 30 days (recent growth). Of the last-30d lane, **10,402 ≈ 347/day** had the slip uploaded **after** the deadline — the late-money class Option B keeps manual.
- **Context:** auto-match paid last 30d = 1,191,454 (~39.7k/day) → the manual lane is **≈1.45%** of paid throughput; the late-class ≈0.86%.
- **B4 sizing:** the next-system `checking` queue must absorb ~600/day steady-state (~25/hr avg, plan 2–3× peak); alert thresholds and the DR8 `checking-count` badge should be sized against this, not against mobiz's historical (pre-growth) average. Note for ops capacity: Option B keeps this ~585/day human workload — it is today's production reality continuing, not new work.
