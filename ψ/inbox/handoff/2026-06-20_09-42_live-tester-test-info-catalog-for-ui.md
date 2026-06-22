---
from: next-live-tester
to: brew-ops
date: 2026-06-20T09:42:00+07:00
topic: Per-test INFO content for the Fleet-Town live-tester panel (the ⓘ button) — what / why / how / verify
status: spec/handoff — drop each block behind the matching test's ⓘ info button
tags: [#repo:cross, #fleet, #brew-ops, #handoff, #live-tester, #ui, #fleet-town, #docs]
---

# Handoff → brew-ops: ⓘ info content for every live-tester test

Companion to `2026-06-20_09-38_live-tester-run-ui-spec-for-fleet-town.md` (that = the suite/flag picker;
THIS = the ⓘ-button copy for each individual test). Each entry has the same 4 fields — wire one per
ticked test:

- **What** (เทสอะไร) · **Why** (ทำไม — the risk it guards) · **How** (อย่างไร) · **Verify** (สิ่งที่ถือว่าผ่าน + หลักฐาน)

> Universal note for the panel: the harness RUNS + records; it never declares PASS/FAIL. "Verify" below is
> the condition the leg colours GREEN on; the authoritative verdict is next-investigator's L3 raw-table
> recompute. Evidence per run = `evidence/live/<epic>/<X-Request-Id>/` (frame JSON + PNG + legs.json).

Source of truth: `poc/integration/src/live/*` + the README-*-journey.md set (PR #649). IDs match the
`leg()`/`step()` labels so you can key the ⓘ content by leg id.

═══════════════════════════════════════════════════════════════════════════════════════════════
# SUITE A — Tri-Epic (AUTH + BANK-BOT + DEPOSIT + PAYOUT + MT + KTB + ENFORCE)
═══════════════════════════════════════════════════════════════════════════════════════════════

## ACT I — AUTH (the real front door)

**I.1 — first-login 2FA enrolment (AUTH-002)**
- What: a brand-new factor-less user must enrol a TOTP factor before it can act.
- Why: an account with no second factor must NOT be able to perform sensitive actions — enrolment is the gate that makes every later AAL2 session possible; skipping it = password-only access to money surfaces.
- How: provision a throwaway user → `auth-login` (expect "enrolment required") → `/factors` enrol TOTP → `/challenge` → `/verify` with a live TOTP code.
- Verify: login signals enrolment-required AND the factor verifies (`factor_verified=true`).

**I.2 — login → AAL2 for all 8 users (AUTH-001/002)**
- What: the real front door issues an MFA-elevated (AAL2) session for every seeded role/entity type.
- Why: every privileged/money action in the whole journey rides an AAL2 bearer — if login→2FA→AAL2 doesn't actually elevate, the entire CE2 "no service_role shortcut" guarantee is hollow.
- How: for each of 8 users: `auth-login` (password) → `auth-2fa-verify` (TOTP) → decode JWT claims, via the anon key (never service_role).
- Verify: ≥1 session carries `aal=aal2`; the SessionBook that drives Acts II/III is populated.

**I.2b — admin-portal browser login (video evidence)**
- What: the real admin-portal login FORM works in a browser and the recorded video shows authenticated admin UI.
- Why: the API logins (I.2) never touch the browser — without this the owner-facing clips would be blank, and a broken portal login would go unnoticed.
- How: Playwright drives the live admin-portal login form for the super-admin seed (U-SA).
- Verify: the tour completes; screenshots/video capture the authenticated portal.

**I.3 — tenant isolation (AUTH-003/004)**
- What: each user sees ONLY the rows its tenant scope allows (RLS-authoritative).
- Why: a client admin reading another tenant's deposits is a data-leak/breach — the isolation must hold at the read surface, not just the write path.
- How: per role, an authenticated `tenant-read` on `deposits`; check the client-admin (U-C1A) sees only its own client's rows.
- Verify: U-C1A's visible client_ids are all == C1.

**I.4 — RBAC deny (AUTH-003 / ADMIN-004)**
- What: low-privilege roles are denied privileged actions.
- Why: a viewer approving a deposit, or a CS unlocking a user, would be privilege-escalation — the role matrix must reject, not silently allow.
- How: viewer calls `admin-deposit approve`; CS calls `admin-users-unlock` — both with valid AAL2 bearers.
- Verify: both return `403 permission_denied`.

**I.5 — lockout → unlock (AUTH-005)**
- What: repeated bad logins lock the account; only a super-admin can unlock; login then restores.
- Why: brute-force protection + a controlled recovery path — no lockout = credential stuffing; no admin-only unlock = self-service bypass.
- How: 6 wrong-password logins → super-admin `admin-users-unlock` → correct login.
- Verify: the 6th attempt is blocked AND the unlock returns 200 (post-unlock login restored).

**I.6 — machine auth (HMAC) + rate-limit (AUTH-006 / CLIENT-002)**
- What: machine-to-machine HMAC on the public deposits endpoint — valid accepted, forged rejected, per-client rate-limit observed.
- Why: the client wire is unauthenticated except by signature; a forged signature accepted = anyone mints deposits; no rate-limit = abuse.
- How: good HMAC create (expect 201); forged signature (v1=zeros, expect 401); a 12-burst counting 429s.
- Verify: good=201 AND forged=401 (rate-limit fail-open is counted, not required).

**I.7 — account lifecycle (AUTH-008/009/012)**
- What: disable blocks login; enable restores; forgot-password doesn't leak account existence.
- Why: deactivation must actually bar access; and a "forgot" that answers differently for real vs unknown emails is an account-enumeration oracle.
- How: `admin-users-disable` → login (blocked) → `admin-users-enable` → login (ok); `auth-change-password forgot` for an existing vs an absent email.
- Verify: disable=200, enable=200, login-while-disabled≠200, AND forgot(exists).status == forgot(absent).status (no leak).

**I.8 — step-up / AAL elevation (AUTH-007) — honest-limited**
- What: exercises the step-up posture/verify EFs WITHOUT pretending a step-up-gated action exists.
- Why: AUTH-007 has ZERO deployed call-sites (Phase-2 deferred) — claiming a green here would be false coverage; the test stays honest (always AMBER).
- How: `auth-step-up-posture` + `auth-step-up-verify` with the super-admin session.
- Verify: AMBER by design (EFs exercised; no gated money-out to assert) — never a false GREEN.

## ACT B — BANK-BOT seam (signs AS the bot with a real BK7 key)

**B.1 — per-account binding (BBOT-002)**
- What: a bot's per-account credential is blast-radius-bounded to exactly one account.
- Why: a key that can push statements for accounts it doesn't own could inject money rows into the wrong ledger.
- How: same key pushes to its OWN account (expect 2xx) then to a SIBLING account (expect reject).
- Verify: own < 300 AND cross-account ≥ 400 (403 bot_account_mismatch).

**B.5 — intake count-dedup (BBOT-001/005)**
- What: statement intake is idempotent via count-based dedup as the SOLE gate (no unique-index backstop).
- Why: the bot re-scans + re-pushes the same rows every tick; without dedup that double-credits — and the design deliberately relies on count-dedup, not a DB unique constraint.
- How: feed an identical statement batch twice; read `inserted` each time.
- Verify: first push inserts ≥1, second inserts 0.

**B.10 — claimed_by ownership (BBOT-011 / F-BBOT-iv)**
- What: only the bot that CLAIMED a withdrawal may finish (mark) it.
- Why: a foreign bot marking another's claim could settle/fail a payout it never executed → money moved on a lie.
- How: create payout → claim with bot A → bot B tries to mark (expect 403) → bot A marks (expect 2xx).
- Verify: foreign mark ≥ 400 AND owner mark < 300.

**B.10x — checkpoint + fetch-processing + transfer-proof (BBOT-011/012)**
- What: the claimed→processing checkpoint, the approver's processing view, and transfer-proof attachment.
- Why: the maker/approver dual-control + proof trail is the audit spine of an outbound transfer; gaps here mean unprovable money-out.
- How: claim → `recordBankRefs` (checkpoint) → `fetchProcessing` (approver sees it) → `setTransferProof` → mark success.
- Verify: checkpoint < 300 AND proof < 300 (item visible in processing).

**B.8 — OTP relay (BBOT-010)**
- What: an OTP producer-write plane + a per-account read plane, with info-leak collapse + cross-account isolation.
- Why: OTPs gate transfers; a never-posted ref must not leak existence (404 not 200-empty), and one account must not read another's OTP.
- How: post an OTP → read it back (same account) → read a never-posted ref → read with a different account's key.
- Verify: post<300, OTP matches, never-posted=404, cross-account=403.

**B.9 — fleet telemetry (BBOT-013)**
- What: heartbeat with availability validation + balance update.
- Why: the router uses availability + balance to pick banks; a bad availability accepted, or a balance not stamped, mis-routes real money.
- How: heartbeat(online) → heartbeat(garbage availability) → updateBalance.
- Verify: heartbeat<300, bad-availability=400, balance<300.

**B.3 — rotate / revoke (BBOT-004 K1/K2)**
- What: credential rotate (new key works) + revoke (old key dies immediately).
- Why: key rotation must not interrupt the bot, and a revoked key must be instantly dead — a lingering revoked key is a live credential leak.
- How: push pre-rotate → rotate → push with new key → revoke → push with old key. (Run on the maintenance bank to spare scb.)
- Verify: new key works after rotate AND post-revoke push = 401 (revoke mandatory).

## ACT II — DEPOSIT (client wire create unless noted)

**II.1 — create idempotency (DEPOSIT-001 / CLIENT-001 / §ADR-11)**
- What: a byte-identical replay returns the same deposit; same key + different body → conflict.
- Why: clients retry on network blips — a retry that creates a SECOND deposit double-charges; a key reused for a different amount must be refused, not silently overwritten.
- How: create → replay same key+body → replay same key + different amount.
- Verify: replay returns the SAME id AND the conflict = 409.

**II.2-A / II.2-B — match → credit → MDR fan-out (DEPOSIT-002 / WALLET-003/007)**
- What: a fed statement auto-matches the deposit → wallet credit + MDR split across partners (two profiles A/B).
- Why: this is the core money-in path; a missed match = customer paid but not credited; a wrong MDR split = partners mis-paid; conservation must be satang-exact.
- How: create → feed an in-statement of the amount → poll until paid; read change-logs (credit / mdr_distribute / mdr_skip).
- Verify: status=paid AND exactly 1 deposit_credit; (L3 recount: NET + Σpartner + residual = gross, satang-exact).

**II.3 — slip lane via the real /deposit portal UI (DEPOSIT-004/007/008)**
- What: manual slip upload → verify-now (genuine) → 6-check approve, driven through the real portal UI.
- Why: the manual lane is what staff use for slip deposits; the UI itself must work end-to-end (not just the EF), or operators can't finalize.
- How: admin (U-SA) drives uploadSlip/verifyNowGenuine/approveToPaid via Playwright (EF fallback if a UI step fails).
- Verify: GREEN only if paid AND all three steps were UI-driven; AMBER if paid via an API fallback (flag to harden the UI).

**II.3b — fraud BLOCK negative (DEPOSIT-007, V2 receiver-mismatch)**
- What: approving a slip whose receiver doesn't match must BLOCK → no credit.
- Why: the V2 receiver gate is anti-fraud — if a mismatched receiver still finalizes, forged-slip deposits get credited (direct money loss).
- How: genuine slip → approve with a `slip_receiver_proxy` whose last-4 matches no real account.
- Verify: approve ≥ 400 (V2_FRAUD), status ≠ paid, 0 deposit_credit.

**II.3c — forged-slip verdict (DEPOSIT-008 negative)**
- What: a "forged" verify verdict must not silently finalize the deposit.
- Why: a forged slip flagged by verification must never become paid — money-safety on the fraud signal.
- How: `verify-now thunder_verdict=forged` (→ checking) → approve with a clean proxy (forged isolated as the only signal).
- Verify: forged recorded (200, verdict=forged) AND money-safe (not paid, 0 credit).

**II.4 — force-approve guard (DEPOSIT-009)**
- What: the AU1 upload-gate refuses a mismatched slip unless an audited force-approve override is supplied.
- Why: overrides must be deliberate + audited — a silent bypass removes the human-accountability trail on a risky approve.
- How: upload a mismatched slip without the marker (expect 409) then with `force_approve` (expect 200 + override_audit_id).
- Verify: no-marker = 409 AU1_REFUSED AND with-marker < 300 carrying an override_audit_id.

**II.5 — collision park (DEPOSIT-005)**
- What: two same-amount deposits across clients + one ambiguous statement → refuse-to-guess, park for admin.
- Why: a statement carries no client identity; guessing which client owns the money = mis-credit; parking is the money-safe answer.
- How: two same-amount deposits (C1, C2) → feed one ambiguous in-statement → check neither credited.
- Verify: both deposits have 0 deposit_credit (parked for admin-deposit-resolve).

**II.6 — expiry (DEPOSIT-003 / CALLBACK-004)**
- What: a pending, slip-less deposit past its deadline → expired + `deposit.expired` callback, no credit.
- Why: stale deposits must close (not linger claimable) and the merchant must be told — without expiry, abandoned deposits could later be matched/credited wrongly.
- How: backdate `expires_at` → run `sweep_expired_deposits` → poll until expired.
- Verify: status=expired AND 0 deposit_credit (expired callback queued).

**II.7 — client deposit-cancel (DEPOSIT-010)**
- What: a client self-cancels its OWN pending deposit via an AAL2 session; idempotent; cross-tenant blocked.
- Why: clients need self-service cancel, but only via a logged-in session (not the machine key), only their own, and a re-cancel must not move money or fire callbacks.
- How: `deposits-cancel` with the client's AAL2 bearer → re-cancel → cancel a slip-present + a terminal deposit → cross-tenant attempt.
- Verify: cancel=200→cancelled, idempotent (cancelled_at stable), 0 callback/credit, SLIP_PRESENT/NOT_PENDING=409, cross-tenant=403.

**II.8 — read surface (DEPOSIT-013 / WALLET-001/002/006 / AUTH-004)**
- What: tenant-scoped deposit reads + the wallet triple (balance/frozen/available) + partner wallet.
- Why: dashboards depend on correct scoped reads + an accurate available-balance (= balance − frozen); a wrong triple misleads withdrawal decisions.
- How: per role tenant-read deposits; read the client wallet triple + a partner wallet.
- Verify: the wallet triple resolves (balance/frozen/available consistent).

**II.9 — resend callback (DEPOSIT-012 / CALLBACK-005)**
- What: resending a callback makes no state change and creates no new credit.
- Why: merchants re-request callbacks; a resend that re-credits or re-finalizes is a money-duplication bug (§9 invariant 4).
- How: count credits → `deposit-resend-callback` on the golden deposit → count again.
- Verify: resend < 500 AND deposit_credit unchanged.

**II.9b — callback signed + replay-proof (CALLBACK-002 / WC1/WC8/WC10)**
- What: every callback is well-formed + signed, carries a stable dedup identity, and re-signs per attempt.
- Why: merchants verify the signature + dedup on event-id; a malformed/unsigned/duplicate-id callback breaks their integration or double-processes.
- How: read the paid callback rows + attempts; trigger a resend; check signatures + identity stability.
- Verify: one stable event_id+dedup_key, resend reuses it, every attempt signature well-formed (+ distinct per attempt).

## ACT II.E — DEPOSIT system-bank ENFORCEMENT (falsifiable-by-pairing; dedicated enforce bank/client)

Each: a VIOLATING attempt must be rejected (exact code + 0 rows) AND a COMPLIANT attempt accepted (1 row). Why (shared): admin-configurable bank settings are only worth anything if the create path actually ENFORCES them — a no-op gate silently accepts what it should block.

**II.E1 — deposit amount band (DEPOSIT-001 AC#8)**
- What: per-bank `deposit_min_amount`/`maximum_deposit_amount`. How: set band [5000,9000]; create below/above/in-band. Verify: below & above = 400 AMOUNT_OUT_OF_RANGE/0 rows; in-band = 201/1 row.

**II.E2 — daily cap + lazy reset (DEPOSIT-001 AC#5/#7)**
- What: per-bank `maximum_number_of_deposits` + BKK-midnight lazy reset. How: cap=2, fill it, hit it; back-date the reset epoch, retry. Verify: #1/#2=201, #3=503 NO_BANK_AVAILABLE/0 rows, #4 (after back-dated reset)=201/1 row.

**II.E3 — per-bank deposit maintenance window (DEPOSIT-001 D1-12)**
- What: the bank's deposit maintenance window filters it out of the pool. How: window covering now → create; window moved to the past → create. Verify: in-window=503 NO_BANK_AVAILABLE/0 rows; out-of-window=201/1 row.

**II.E4 — client enable_deposit (DEPOSIT-001 D1-10)**
- What: the per-client deposit switch. How: set `enable_deposit=false`, create; restore, create. Verify: disabled=403 DEPOSIT_DISABLED_FOR_CLIENT/0 rows; re-enabled=201/1 row.

**II.E5 — global deposit maintenance (DEPOSIT-001 D1-11)**
- What: the global `app_settings.deposit_maintenance` kill-switch. How: set 'on', create; clear, create. Verify: on=503 DEPOSIT_MAINTENANCE/0 rows; cleared=201/1 row.

## ACT III — PAYOUT (client create + bot SIM OUT-lane + admin)

**III.1 — create + freeze + over-amount reject (PAYOUT-001)**
- What: creating a payout freezes GROSS in the client wallet; an over-amount is rejected.
- Why: funds must be reserved at create (so balance can't be double-spent), and an unaffordable payout must never enter the queue.
- How: snapshot wallet → create 1000 → re-read → create 999,999,999.
- Verify: frozen↑ by gross AND over-amount ≥ 400.

**III.2 — claim + settle (PAYOUT-002 / WALLET-003)**
- What: bot claims + marks success → wallet debited, MDR distributed, success callback.
- Why: the money-out happy path; a settle that doesn't debit = money left the bank but not the ledger.
- How: create → bot claim → mark success → read settle/mdr/callbacks.
- Verify: status=success, 1 payout_settle, 1 payout.success callback.

**III.3 — fail + release (PAYOUT-003)**
- What: bot marks failed → NO debit, freeze released, failed callback.
- Why: a failed transfer must return the frozen funds — a fail that still debits steals from the client.
- How: snapshot → create → mark failed (bank_timeout) → re-read.
- Verify: status=failed AND debit=0 (1 payout_unfreeze, balance restored).

**III.4 — review → reconcile, both outcomes (PAYOUT-004)**
- What: a review-state payout is resolved by admin reconcile to success OR failed; review sends no premature callback.
- Why: stuck payouts need a deterministic admin resolution, and a premature callback on 'review' would mislead the merchant.
- How: two payouts → both review → admin reconcile one→success, one→failed.
- Verify: outcome A=success, B=failed.

**III.5 — auto-reconcile from an outbound statement (PAYOUT-009 / MATCH-003)**
- What: a review payout is driven to success by a matching bank out-debit (system, not a human), matched by request_id.
- Why: the bank statement is the ground truth of money leaving — it must be able to settle a payout without a human, matched on the PAY-token.
- How: create with a PAY-prefixed reqId → feed an out-statement → poll `sweep_payout_reconcile`.
- Verify: status=success (statement matched, matched_link_step=payout_reconcile).

**III.6 — admin cancel a pending payout (PAYOUT-005)**
- What: admin cancels a still-pending payout → cancelled, freeze released, one cancelled callback.
- Why: ops must be able to pull back a not-yet-claimed payout and the funds must unfreeze.
- How: create (no bot claim) → `admin-payout-cancel`.
- Verify: status=cancelled.

**III.7 — auto-cancel: stale timeout + bank maintenance (PAYOUT-008/010)**
- What: a pending payout auto-cancels on stale timeout (flag-gated) and on bank maintenance, freeze released.
- Why: payouts must not hang forever, and a bank in maintenance can't execute — both must release funds, with distinct reasons.
- How: stale: backdate + enable flag → `sweep_stale_payouts`; maint: payout into the maintenance bank → `sweep_payouts_bank_maintenance`.
- Verify: both status=cancelled (distinct failure reasons).

**III.8 — admin correction failed → success (PAYOUT-012 / WALLET-003)**
- What: admin corrects a failed/review payout to success; ends as a clean success (one settle, one MDR).
- Why: a transfer the bank actually completed but the system marked failed must be correctable to truth — without double-paying.
- How: mark failed → `admin-payout-correct` → read settle/mdr/wallet.
- Verify: status=success (re-freeze-then-settle nets a clean single debit; MDR once).

**III.9 — reverse-settle + MDR clawback (PAYOUT-013 / WALLET-008)**
- What: reverse a settled payout → failed, MDR clawed back, conservation closes.
- Why: a settled payout later found bad must fully unwind — partner MDR clawed back, client recredited, no value created/destroyed.
- How: success → `admin-payout-reverse-settle` → sum clawback/shortfall/recredit.
- Verify: status=failed AND |Σclawback + Σshortfall − fee| < 0.005 (satang conservation).

**III.10 — resend callback + tenant-scoped read (PAYOUT-007 / AUTH-004)**
- What: resending a payout callback moves no money; payout reads are tenant-scoped.
- Why: idempotent callback resend (no second debit) + correct per-tenant payout visibility.
- How: success → count settle → `payout-resend-callback` → count again; per-role tenant-read payouts.
- Verify: resend < 500 AND settle count unchanged.

**III.11 — whole-lane conservation**
- What: after a full create→claim→settle→reverse cycle, every wallet returns to its EXACT pre-create satang.
- Why: the epic-seal money invariant — a complete round-trip must be value-neutral across ALL wallets (no leak anywhere).
- How: snapshot all wallets → run the cycle → snapshot again → diff.
- Verify: zero wallets drifted.

## ACT III.E — PAYOUT ENFORCEMENT (falsifiable-by-pairing; dedicated enforce bank/client)

**III.E1 — client enable_payout (PAYOUT-001 AC#5)**
- What: the per-client payout switch. Why: a disabled client must not be able to withdraw. How: `enable_payout=false` create (reject) → restore → create (accept). Verify: disabled=4xx PAYOUT_DISABLED/0 rows; re-enabled accepted/1 row.

**III.E2 — min_payout lower boundary (PAYOUT-001 AC#9)**
- What: the per-client minimum payout. Why: below-minimum withdrawals must be refused before any freeze. How: `min_payout=500`; create 499 (reject) → 500 (accept). Verify: below=400 AMOUNT_OUT_OF_RANGE/0 rows; at-min accepted/1 row.

**III.E3 — fair-router availability routing-exclusion (ADR-30 AC-1)**
- What: the router routes a pool payout ONLY to an `online` bank, excluding an `offline` one — even when offline is the LRU favourite.
- Why: routing money to a bank that's offline = a stuck/failed transfer; availability must override LRU, or the "fair" router sends work to a dead bank.
- How: 2-bank pool; make the LRU-favourite OFFLINE + the loser ONLINE; create a Mode-1 pool payout; read the assigned bank. Both directions.
- Verify: both directions route to the ONLINE bank (AMBER if it picks the offline favourite = no-op gate; BLOCKED if neither routes). (ADR-30 AC-2 stale-heartbeat / AC-3 withdrawal-band = not yet live.)

## ACT MT — multi-tenant depth (AUTH-004)

**MT.1 / MT.2 — sub-client (SC1) & 2nd-client (C2) money lane**
- What: a sub-client and a second client of the same merchant each run a full deposit→payout lane within scope.
- Why: tenancy depth — money must flow correctly for sub-clients and sibling clients, not just the primary C1.
- How: deposit via slip (2200) → paid; payout (800) claim→settle.
- Verify: deposit paid (1 credit) AND payout success (1 settle).

**MT.3 — concurrent two-client isolation (AUTH-004)**
- What: two clients creating deposits CONCURRENTLY stay isolated.
- Why: a race must not cross-contaminate ids/amounts/ownership — concurrency bugs leak one tenant's money into another's row.
- How: `Promise.all` create C1@313 + C2@314 → read both.
- Verify: distinct ids, amounts 313/314 not crossed, each row owned by its creator.

## ACT KTB — second-bank dialect

**K.1 — KTB inbound auto-match (BBOT-006 / MATCH-001 on ktb)**
- What: a deposit on the KTB bank routes to KTB, a fed ktb statement auto-matches, credits once.
- Why: proves the match/credit path is bank-dialect-agnostic — KTB isn't a special-case that silently breaks.
- How: KTB client create → confirm routed to KTB → feed a ktb in-statement → poll until paid.
- Verify: routed_to_ktb AND paid AND exactly 1 credit.

**K.2 — KTB outbound settle (BBOT-011 on ktb)**
- What: the payout claim→transfer→settle lane works on the KTB bank.
- Why: outbound money-out must also work on the second bank, including its (single-control) topology.
- How: create→claim→mark-success on ktb → read settle/callback.
- Verify: status=success, 1 settle, 1 payout.success.

## Woven money-safety FAULTS

**F-DEP-i — dup-credit guard**
- What/Why: re-approving an already-paid deposit must not double-credit (direct money duplication). How: re-approve the golden deposit; count credits. Verify: refused/idempotent AND exactly one deposit_credit (dup-credit=0).

**F-DEP-ii — callback retry (at-least-once, dup-egress=0)**
- What/Why: a flaky merchant endpoint must be RETRIED then delivered exactly once — not dropped, not duplicated. How: point the endpoint at a 500-once→200 receiver; trigger; observe attempts. Verify: attempt_count≥2 + merchant saw ≥2 POSTs + ONE callback_queue row + ONE credit.

**F-DEP-iii — dead-letter → P2.12 must-page**
- What/Why: callbacks that exhaust retries must dead-letter AND raise the must-page alert — "no alerts" must never silently mean "alerts dead". How: point at an always-500 receiver → 3×500 → dead_letter → fingerprint → #mb-alerts-p2. Verify: dead_letter within 15 min + fingerprint (GREEN if Keep-confirmed, else AMBER condition-met).

**F-PAY-i — double-reverse blocked**
- What/Why: reversing an already-reversed payout must be blocked with no second money move (fail-safe dedup). How: reverse once → reverse again; count reverse rows. Verify: 2nd reverse ≥ 400 AND reverse rows unchanged (exactly 1).

**F-PAY-ii — reverse-with-shortfall (wallet never negative)**
- What/Why: when an MDR recipient can't cover its clawback, log an audit-only shortfall — never force a wallet negative; conservation still closes. How: drain recipient wallets below their share → reverse. Verify: reverse < 400 + ≥1 mdr_unwind_shortfall + NO wallet negative.

**F-PAY-iii — false-success / false-failed alerts (MONITOR-003)**
- What/Why: the P2.16 (false-success) / P2.17 (false-failed) operator alerts are the signal that III.8/III.9 mis-states get caught. How: exercised via III.8 + III.9; confirm via Keep if `KEEP_ALERTS_API` set. Verify: GREEN only when Keep confirms p2.16/p2.17 (else AMBER; the #mb-alerts-p2 page is the surface).

═══════════════════════════════════════════════════════════════════════════════════════════════
# SUITE B — Automatch (the real deployed bot scraping the portal)
═══════════════════════════════════════════════════════════════════════════════════════════════

**L0-readiness** — What: every channel (gateway/bot/portal/tunnel) reachable before grading. Why: a half-deployed stack would produce false REDs; the gate must abort BLOCKED, not guess. How: probe botKeyAuth/bot-config/RPCs. Verify: channels structurally reachable.

**L1a-bot-witness** — What: the Fargate bot is credentialed via the real issuance path. Why: the whole journey depends on a live, properly-minted bot; a missing cred = nothing scrapes. How: read the bot_credentials audit row post-reset. Verify: live credential present (liveness proven by the L1c scrape).

**L1b-client-wire** — What: a deposit is created via the real client wire (CF Worker HMAC→GW4→EF). Why: proves the production create path, not a harness shortcut. How: POST /deposits-create signed. Verify: HTTP<300 + a deposit id.

**L1c-scrape-push** — What: the real (unmodified) bot scrapes the injected statement and pushes it over the PAIRED key. Why: this is the core bank-bot contract — the bot must read the portal and push authentically. How: /sim/inject an in-row → wait for the bank_statements row. Verify: statement landed with source identity + match_hash.

**L1d-automatch** — What: statement→auto-match→wallet credit→merchant callback (the golden money-in). Why: the headline path; failure = customer paid, not credited. How: kick sweep until deposit=paid; check credit + callback. Verify: paid + wallet credit logged + callback received.

**L1e-cursor** — What: the gateway-derived inbound cursor is correct and never regresses. Why: a wrong/regressing cursor re-scrapes or skips statements (dup or missed credit). How: read max transaction_date_bkk per direction. Verify: cursor advanced (int64 minute-level).

**L1f-deposit-batch** — What: N deposits coexist as unmatched rows then each auto-matches, credits once, no cross-match. Why: stresses the matcher under concurrency — proves no double-credit / no cross-match when many are pending. How: create N-1 + inject all → assert per-item paid/1-credit/1-stmt/own-amount. Verify: all paid, each credited once, one stmt row each, no cross-match. (Size = `DEPOSIT_COUNT`.)

**L1g-multi-candidate-park** — (= A II.5) cross-client ambiguity → review, neither credited. Verify: match_status=review, both uncredited, 0 callback.

**L1g2-degenerate-fifo** — What: same-client same-amount ambiguity → auto-pick the OLDEST (no park). Why: the sealed §FA1 carve-out — a single customer's repeat transfers must FIFO-resolve, not park forever. How: OLD then NEW deposit → inject one → expect matched. Verify: matched (not review), oldest won, old paid/1-credit, new pending/0.

**L1h-deposit-expiry** — (= A II.6) slip-less past deadline → expired + callback, no credit. Verify: expired, 0 credit.

**L1m-deposit-idem** — (= A II.1) replay=same id, conflict=409. Verify: same id on replay, 409 on key-reuse-different-body.

**L1j-client-cancel** — (= A II.7) AAL2 client self-cancel, idempotent, callback-silent, no wallet move, cross-tenant 403. Verify: 200→cancelled + idempotent + 0 cb/credit + 403 cross-tenant.

**L1n-mdr-fanout** — (= A II.2) 2-profile MDR split, satang-exact conservation. Verify: paid + NET+Σmdr+residual = gross (satang-exact) per profile.

**L4-withdraw-realbot** — What: a single payout driven 100% by the deployed bot (claim→OTP→transfer→re-scrape→reconcile→callback). Why: proves the FULL real-bot OUT lane, no harness shortcut. How: create→bot claims→portal auto-generates the out-row→bot re-scrapes→reconcile→success callback. Verify: claimed + out-row scraped + settled + payout.success. (SUPERSEDED by L4b when WITHDRAW_COUNT≥2.)

**L4b-withdraw-batch** — What: M payouts claimed as ONE batch (single batch_id), maker-per-item + one OTP approval, M out-rows reconciled. Why: the real batch behaviour ops rely on; proves one-batch-per-bank + per-item settle. How: create M back-to-back→bot batch-claim→settle all→M callbacks. Verify: created M, claimed M (single batch_id), out-rows M, settled M, M payout.success.

**L4f-stale-cancel** — (= A III.7 stale) stale payout → sweep cancel, freeze released, no debit. Verify: cancelled, freeze released, debit=0, 1 cancelled callback.

**L4m-maint-cancel** — (= A III.7 maint) bank-maintenance cancel (§ADR-9 code in callback payload). Verify: cancelled via maintenance path, freeze released, debit=0.

**L4k-payout-idem** — (= A III.10/idem) replay=same payout, freeze applied ONCE. Verify: same payout on replay, 1 freeze row (not doubled), 409 on conflict.

**L2a-steady-dedup** — What: the bot's steady-state over-scan re-pushes the boundary row each tick; count-dedup collapses it (NO restart). Why: proves dedup holds in normal operation (the restart variant is Suite C). How: wait ≥3 over-scan cycles; measure the stored count. Verify: bank_statements count stays EXACTLY constant (no dup insert).

**L2b-clawback** — What: a clawback out-row (อ้างอิง marker) is ingested unmatched; the original deposit is untouched. Why: a bank reversal must not auto-undo a credit (SP6 — reconcile is a named gap, not auto); the anchor must stay pristine. How: /sim/clawback → scrape the out-row → check the anchor. Verify: out-row unmatched, anchor credit/callback held (unchanged).

**L2c-deadletter-alert** — (= A F-DEP-iii) a 2nd deposit bound to a failing callback → dead_letter → P2.12 page. Verify: dead_letter + fingerprint to #mb-alerts-p2 (deposit #1 stays pristine). (`SKIP_DEADLETTER`.)

**L3-rotate-stretch** — What: rotate the bot credential mid-journey with overlap; the retiring key stays green for a tick, the new pair works. Why: zero-downtime key rotation in production. How: rotate(overlap) → probe crosses on retiring key → swap. Verify: overlap probe lands + swap green. (Opt-in `ROTATE_STRETCH`.)

**L1i-callback-signature** — (= A II.9b) every callback well-formed + per-attempt-distinct + merchant-dedup id. Verify: all signed, distinct per attempt, every row has a dedup id.

**LA-portal-refs** — What: every deposit/payout carries a descriptive portal request_id/ref_code. Why: debuggability — opaque refs make it impossible to trace a row back to its leg in the portal. How: read all refs for the run. Verify: all deposits + payouts carry descriptive refs.

═══════════════════════════════════════════════════════════════════════════════════════════════
# SUITE C — Restart (the only suite that restarts the bot)
═══════════════════════════════════════════════════════════════════════════════════════════════

**C0-anchor** — What: establish the surviving row R (deposit→paid) + a credit baseline that L2a re-scrapes. Why: precondition for the restart dedup test. How: create+inject+match. Verify: deposit matched→paid, R in bank_statements.

**L2a-dup-fault** — What: SP3 crash-restart dedup — restart the STMT bot; R must survive, the fresh bot re-scrapes it, count-dedup collapses the re-push. Why: a bot crash+restart must NOT re-credit a surviving row (the real-world failure the steady-state L2a can't fully prove). How: restart via SIGKILL/`BOT_RESTART_CMD` → wait → measure. Verify: R survived (no portal bounce) AND bank_statements count + credit + callbacks unchanged (dup-credit=0).

**P1-stuck-reconcile** — What: III.5 over a real restart — orphan a claim by restarting the payout bot, age it, sweep to review, then a matching out-debit settles it. Why: a bot that dies mid-claim must leave a recoverable (not lost, not double-paid) payout. How: claim→`BOT_RESTART_CMD` orphan→backdate claimed_at→`sweep_stale_claims`→review→match_payout_statement. Verify: payout review→success, statement matched_link_step=payout_reconcile.

**P2-amount-mismatch** — What: a mismatched out-debit (|diff|>50 THB) → amount_mismatch, payout STAYS review (never auto-fails). Why: the bank moved a different amount than expected — the system must flag, not silently fail/settle. How: inject an out-debit off by >50 → match_payout_statement. Verify: outcome=amount_mismatch AND payout stays review (mark_success NOT called).

═══════════════════════════════════════════════════════════════════════════════════════════════
# SUITE D — Fair-router (LRU distribution across a fleet)
═══════════════════════════════════════════════════════════════════════════════════════════════

**FR0** — What: L0 readiness — CF worker + the ONE shared portal + each account's selector-scoped control read. Why: fair-router needs the multi-account Path-B substrate live before any distribution claim. How: health/portal/per-account control probes. Verify: all reachable (else BLOCKED — brew-ops L0).

**FR1** — What: the fleet substrate — N SCB accounts exist, share ONE pool, all active, strangers deactivated, a pool client. Why: pool-scoped LRU only makes sense over a correctly-shaped fleet; a stray bank would skew routing. How: read bank rows + pool + deactivate strangers. Verify: 3 accounts active in ONE pool + a pool client (else BLOCKED).

**FRD1** — What: deposit LRU distribution — N deposits assigned with spread ≤ 1, all in-fleet, Σ=N. Why: "fair" must mean even — a skewed router overloads one account (cap/limits) and starves others. How: create N → read each `system_bank_account_id`. Verify: spread ≤ 1, all assigned in-fleet, count conserved.

**FRD2** — What: each deposit matches→paid via the per-account (login-scoped) scrape, credited once. Why: distribution is useless if the per-account bot can't then match its own slice. How: per-account inject → real bot scrapes its login → poll paid. Verify: all paid, credited exactly once.

**FRD2cb** — What: per-account the deposit.paid callback actually DELIVERED (not dead-letter) + merchant received it. Why: closes the silent-dead-letter gap — a per-account callback misconfig would dead-letter while the lane still shows paid/credited. How: stand up a receiver, repoint the client endpoint, assert delivery per account. Verify: callback_queue.status=delivered + merchant receipt, keyed per account (BLOCKED without the receiver seam).

**FRD3** — What: isolation — no cross-account match + no foreign amount in any account's portal slice. Why: per-login isolation is the security boundary of the shared portal; a leak = one account seeing/matching another's statements. How: check matched-statement system_bank_id + each slice's amounts. Verify: every matched stmt carries its OWN account's id + no foreign amount in any slice.

**FRP1** — What: payout LRU distribution — N Mode-1 (pool) payouts routed with spread ≤ 1, all in-fleet. Why: outbound fairness — even payout load across the fleet via the webhook router. How: create N Mode-1 → poll each `required_bank_account_id`. Verify: spread ≤ 1, all routed in-fleet.

**FRP2** — What: exactly-once claim + per-bank batch isolation — every row claimed_by == its routed bank, one batch_id per claiming bank, no batch spans two banks. Why: a claim crossing banks, or a row claimed by the wrong bank, would execute money on the wrong account. How: `claim_withdrawal_items` per account (drive) or observe the real bots. Verify: all claimed by the routed bank, distinct batch_id per bank, no cross-bank batch.

**FRP3** — What: per-account the payout.success callback DELIVERED. Why: same silent-dead-letter gap for the OUT lane. How: GATED — honest-SKIP in plain `drive` (rows never settle); asserts under `FAIRROUTER_CLAIM=observe` or `FAIRROUTER_FORCE_SETTLE=1`. Verify: callback_queue.status=delivered + merchant receipt per account (SKIP if not settled).

**FRX** — What: cross-bank method gate (SCB+KTB) — no deposit routes to a payout-only bank; payouts include it. Why: mixing banks with asymmetric methods must respect the method gate, or deposits land on a bank that can't accept them. How: under `FAIRROUTER_CROSSBANK=1` with a KTB payout-only account. Verify: deposit lane excludes KTB; payout lane includes it (method gate both ways).

═══════════════════════════════════════════════════════════════════════════════════════════════
# SUITE DEP — Deposit golden (standalone DEPOSIT+AUTH; subset path of A's ACT I+II)
═══════════════════════════════════════════════════════════════════════════════════════════════

**L0** — readiness gate (client→worker→EF→DB→tunnel on sinuw). Verify: reachable (else BLOCKED).
**L1-auth** — real front door login→2FA→AAL2 (= A's I.2). Verify: AAL2 session minted (anon key, no service_role).
**L1-create** — client QR deposit via CF worker HMAC→GW4 (= A's II.1 create half). Verify: 201 pending.
**L1-slip / L1-verify** — admin upload-slip (stays pending) → verify-now genuine → checking (= A's II.3 first half). Verify: slip recorded, status→checking.
**L1-approve / L1-callback** — admin approve → 6-check → finalize (credit+MDR) → paid → callback. Why: the manual money-in path end-to-end. Verify: paid + credited + callback delivered.
**F-i** — dup-credit=0 — re-approve a paid deposit must not double-finalize (= A F-DEP-i). Verify: refused/idempotent, exactly one credit.
**F-ii** — callback dup-egress=0 — flaky endpoint retried then delivered once (= A F-DEP-ii). Verify: attempts≥2 + delivered once.
**F-iii** — dead-letter → P2.12 must-page — always-fail endpoint → dead_letter → page (= A F-DEP-iii). Verify: dead_letter + fingerprint to #mb-alerts-p2.

---

## For brew-ops — embedding notes
- Key the ⓘ content by the leg/step id (the IDs above match `legs.json`).
- Suites A/B/DEP share several tests (noted "= A …" / "= …"); reuse the same ⓘ block if you de-dup by AC.
- Each block is intentionally 4 lines (What/Why/How/Verify) — render as labelled rows or a small table.
- "Verify" describes the GREEN condition; always pair with the panel's standing note that L3 owns the real verdict.
- If you want this as machine-readable JSON (one object per id with what/why/how/verify), ping next-live-tester — easy to emit from the same source.
