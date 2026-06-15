# next-investigator — EPIC-SEAL findings: BANK-BOT-INTEGRATION (Phase-1, statements-only)

**Verdict: 🟢 GREEN — SEAL ISSUED** (gateway-side, with named deferred items; none money-safety-blocking). The one prior open item — F1 BS-2 error-shape — was **DISPOSED by next-architect 2026-06-12 (option b)**, and its disposition *confirms* the gateway behavior sealed here (§4.1).

- **Epic:** `docs/requirements/epic-bank-bot-integration.md` — BBOT-001..009 + the MATCH-001 intake seam (gateway-side contract).
- **Target:** `mb-next-payment-gateway` @ `origin/main` HEAD **e69bc76**.
- **Seal stack:** qnccph (`qnccphgykzdydebmdwdf`, investigator.env slot), migration head **20260612000050** confirmed.
- **Method:** independent behavioral re-derivation — drove the real SECURITY-DEFINER functions + read the EF surface, my own fixtures, injected virtual clock (`app_now()`/`sys_clock`), **every PASS falsified**, **everything in `BEGIN…ROLLBACK`**. Stack left byte-for-byte as found (see §Isolation).
- **Role of prior evidence:** the bankbot2 golden-journey L3 PASS, reg28's bbot-substrate cert, and the merged build set were **read but not trusted as substitute** — all gateway-side conclusions below are my own re-derivation. Prior evidence is cited only for the bot-side halves that have no gateway surface to drive.
- **Date:** 2026-06-12 (GMT+7). **This seal is the G1 prereq** for the (deferred) bbot LIVE/L5 leg.

---

## 1. What was sealed (gateway-side surfaces)

| Surface | Story | Verdict |
|---|---|---|
| `submit_statements_batch` count-based dedup (sole gate) | BBOT-001 / MATCH-001 | 🟢 |
| I-derived cursor `get_last_statement_dates` (MAX per direction) | BBOT-001 | 🟢 |
| sparse `match_hash` pre-compute at insert (B7) | BBOT-001 | 🟢 |
| 200-row batch cap (413 `batch_too_large`) — EF-level | BBOT-001 | 🟢 (code-only) |
| no Idempotency-Key required (§ADR-11 exempt) | BBOT-001 | 🟢 |
| `verify_bot_request` per-account binding (401/403, BK3/BK7) | BBOT-002 | 🟢 |
| `botKeyAuth` EF mapping + no `x-bot-secret` fallback (BK2 cutover) | BBOT-002 | 🟢 |
| `mint_bot_credential` one-active-per-account + audit | BBOT-002 | 🟢 |
| `bot-config` EF serves non-secret only (D4 hybrid) | BBOT-003 | 🟢 |
| `rotate_bot_credential` K1 two-slot overlap | BBOT-004 | 🟢 |
| `revoke_bot_credential` K2 immediate + blast-radius isolation | BBOT-004 | 🟢 |
| dup-credit fault gateway lever (dedup + NT-9 single-consumption) | BBOT-005 | 🟢 |
| clawback `direction='out'` unmatched-by-design (zero money movement) | BBOT-009 | 🟢 |
| mock-portal fidelity / injection / append-only (bot-side) | BBOT-006/007/008 | 🟢 (bot-side, no gateway surface) |

---

## 2. Behavioral re-derivation evidence (all `BEGIN…ROLLBACK` on qnccph)

### BBOT-001 — intake / adapter-port gateway contract
- **Count-based dedup is the SOLE gate.** Schema check: the only unique index on `bank_statements` is the PK on `id`; `uq_bank_statements_dedup_in` is **gone** (dropped `20260515000003`), only the non-unique `idx_bank_statements_dedup_composition` remains. Behavior of `submit_statements_batch`:
  - First push `[R]` → 1 inserted, table=1.
  - Re-push same `[R]` → **0 inserted**, table stays 1 (`existing_count(1) >= batch_count(1)` → skip).
  - **Falsified:** a *distinct* row (amount differs) → 1 inserted, table=2 — proves it is composition-specific, not blanket-skip-on-2nd-call.
  - Within-batch genuinely-identical pair `[R3,R3]` → **both** insert (no unique backstop); re-scrape of that pair → **0** inserted (2≥2 collapses) — the §ADR-21 SP3 "genuinely-identical pair preserved, re-scrape collapses" property.
- **I-derived cursor** `get_last_statement_dates(acct)` returned `{last_in_date_bkk: MAX(in), last_out_date_bkk: MAX(out), last_date_bkk: GREATEST, total_records}`. Fresh empty account → all `null` + `total 0`; second read identical (restart self-heals). Source-derived, no stored cursor. ✔
- **`match_hash` B7:** for `direction='in'` the stored hash was **byte-equal to my independent `sha256(account||upper(src_bank)||amount*100||YYYYMMDDHH24MI)` recompute**; `direction='out'` → `NULL`. Computed at insert from raw fields, not bot-supplied. ✔
- **200-cap (BS-5):** enforced in `bot-statements/index.ts` (`transactions.length > 200 → 413 batch_too_large`) — **EF-level, not in the RPC** (matches reconciliation note #2: code-only, no SPEC AC yet). ✔
- **No Idempotency-Key:** `bot-bank-statements-last` is read-only & explicitly out of §ADR-11 scope; `bot-statements` dedup is count-based, no key header required. ✔
- **BS-2 wire shape:** `statement_date_bkk` given as a string → labeled RPC exception `bad_statement_date_bkk: … (want YYYYMMDDHHMM int64 per BS-2)`; non-integral → `bad_statement_date_bkk: … (want integral …)`. Not coerced; surfaces to the EF as an opaque `500 submit_statements_failed` with no silent insert. ✔ *(This is the RATIFIED Phase-1 behavior per the F1 BS-2 disposition — §4.1.)*

### BBOT-002/003/004 — bot-tier auth + credential lifecycle (`verify_bot_request`, virtual-clock-driven)
- **HMAC roundtrip happy path:** mint → sign canonical with returned secret → `verify_bot_request` ⇒ `ok=true`, returns the bound `bank_account_id`. (Also proves the investigator-slot `BOT_CRED_ENC_KEY` correctly decrypts `secret_enc`.)
- **Falsified bad signature** ⇒ `bot_signature_invalid` (401-class).
- **BK3 per-account binding:** A-key naming account B via `system_bank_id` ⇒ `bot_account_mismatch` (403); same via `account_number` ⇒ `bot_account_mismatch` (403).
- **Unknown key** ⇒ `bot_key_invalid` (401). **Replay window:** a 10-min-old timestamp (valid sig) ⇒ `bot_timestamp_expired` (checked before signature; driven by the injected `sys_clock`).
- **EF mapping** (`_shared/bot-auth.ts`): `bot_account_mismatch → 403`, all other failures → 401; missing `x-bot-key → 401 bot_key_missing`; **no `x-bot-secret` fallback path exists** (BK2 cutover, no interim) — verified at source.
- **Rotate K1 (two-slot overlap, 3600s):** during overlap **both** old and new keys verify; after advancing the virtual clock +2h (past the 1h `retire_at`) the **old key is refused** (`bot_key_invalid`) while the **new key still verifies**.
- **Revoke K2 (immediate):** revoked 2 rows; the new A-key is **refused on its next crossing** (no grace). **Blast radius = account-only:** account B's key remained `ok=true` after A was revoked.
- **Mint guard:** a 2nd active mint for an account ⇒ `bot_credential_exists` (one active : one account).
- **Audit:** `mint` / `rotate` / `revoke` each wrote one `audit_log` row (`resource_type='bot_credential'`, `resource_id`=account, actor named) — §ADR-13 admin-write + audit. ✔
- **BBOT-003 D4 hybrid:** `bot-config` EF selects only operational columns (`id, system_bank_code, bank_name, account_number, account_name, is_active`) — **no `credentials`/`emails` keys**. The gateway DB **structurally cannot serve a portal password**: `bank_account` has no credential/password column, and `bot_credentials.secret_enc` holds only the §ADR-7 HMAC secret, not bank-portal creds. Secret portal/email creds live only in the per-account fleet-secret slot. ✔

### BBOT-005 / BBOT-009 — gateway-side fault contracts
- **Dup-credit fault — two-layer gateway guarantee:**
  1. **Dedup:** re-scraped identical IN row → 0 inserted → exactly one `bank_statements` row.
  2. **NT-9 single-consumption:** a statement forced to `match_status='matched'`, re-cascaded ⇒ `already_consumed` (no re-finalize). **Falsified:** reset to `pending`, re-cascaded ⇒ `no_match` (not `already_consumed`) — the guard keys on consumption status, not blanket. Together: at most one finalize per logical statement.
  - The "real bot scrapes the **mock portal** with unmodified `banks/*` code" half is bot-side (`mb-next-bank-bot`); it has **no gateway surface to drive** and is cited from the bankbot2 golden-journey L3 PASS (X-Request-Id `live-bbot-1781194462394-63b1c818`, SP3 split stack; AR2 money-invariants independently recomputed at that time).
- **Clawback OUT unmatched-by-design (Phase-1 negative test):** an injected `direction='out'` clawback row ⇒ IN-cascade `non_inbound_skipped` + payout matcher `no_request_id` ⇒ `match_status='unmatched'`. **Zero money movement asserted** (wallet balance-sum unchanged, wallet rows unchanged, `ts_deposits` unchanged). The original credit is **not auto-reversed**. ✔ `match_payout_statement` only ever touches `withdrawal_queue`/`ts_payouts` — it never touches `ts_deposits`/`wallet`, so a deposit-referencing clawback structurally cannot reverse a credit in Phase-1.

### BBOT-006/007/008 — mock-portal test components
Live bot-side in `mb-next-bank-bot sim/`. **No gateway-side surface to seal.** The gateway contract they bind to is the same direction-agnostic intake EFs + count-based dedup, which absorbs re-scrapes over an append-only list (proven above). Fidelity (unmodified scrapers), the SIM-only injection secret separate from `BOT_KEY`, and the no-delete append-only store are bot-repo invariants — validated in the bankbot2 golden journey; named bot-side-owned, not re-derived here.

---

## 3. Isolation / stack hygiene

- All fixtures ran inside `BEGIN…ROLLBACK`; the injected `sys_clock` change reverted on rollback (now back to `mode='real'`).
- **Residue check (post-run):** zero `SEAL-*` `bank_account` rows, zero `bot_credentials` bound to my fixture UUIDs, zero `audit_log` rows from actor `sealtest`. `write_audit_log` is a plain transactional INSERT (not autonomous/dblink), so my audit writes rolled back too.
- Counts on the shared stack moved during my session (`audit_log` 434→447, `bot_credentials` 15→20) — this is **concurrent activity from another fleet agent**, **not** my residue (the targeted residue check above is clean). Migration head unchanged at `20260612000050`.
- I did **not** touch sinuw, dev-N slots, PR #433, or any tunnel.

---

## 4. NAMED items (not sealed over — named, not fixed)

### 4.1 DISPOSED (next-architect, 2026-06-12 — option b; was the only "pending" item)
- **F1 BS-2 error-shape pair (2 lane-1 REDs) — DISPOSED, NOT a blocker.** next-architect ruled (PR #435 `docs/test-index.md §F1`; ψ envelope `2026-06-12_16-59_f1-bs2-disposition-to-next-tester.md`; findings `next-architect_bbotseal_findings.md`) that the gateway's **HTTP 500 `submit_statements_failed` + no-silent-insert** is the **RATIFIED Phase-1 behavior**, per the contract of record: `bot-gateway-contract.md §6 step 6` ("RPC raises exception → 500, no SQL leak"), `bbot-adapter-endpoints-slice.md §3/§5` (no 4xx `bad_statement_date_bkk`; opaque 500 the bot never parses). The graceful 4xx the `bk-auth.ts` BS-2 probe legs assert is **NOT ratified**.
  - **This CONFIRMS my seal:** my independent re-derivation observed precisely (a) the RPC raises the labeled `bad_statement_date_bkk` internally (string + non-integral legs), and (b) the EF collapses it to the opaque `500 {error:"submit_statements_failed"}` with **no SQL/driver detail** and **no silent insert** (`inserted ≠ 1`) — byte-identical to what the architect verified at e69bc76. The 2 REDs are **RED-against-the-probe-expectation, not a gateway defect**.
  - **Residual:** a mechanical **probe rebind owned by next-tester** (assert 500 + no-silent-insert, drop the 4xx/substring checks; leave the cursor-int64 echo leg). Not a substrate/EF change. **Not a seal blocker.**
  - Reconciliation note #3's raw-error leak is **closed at HEAD** in the deployed EF. (The frozen **PoC** handler `poc/integration/src/gateway/handlers/bot.ts:55` still leaks `detail` — architect gap **G-8**, P-001-frozen / non-gate, not the seal target.)
  - **Phase-2 PARKED (non-gate):** a future 400 surfacing of `bad_statement_date_bkk` for monitor-003 P2.8 observability would need its own ADR amendment — do **not** pre-assert it.

### 4.2 NAMED GAP (owned elsewhere, by design)
- **SP6 deposit-reversal reconcile = MATCH-003.** Auto-reverse-credit-on-clawback + §ADR-15 alert is **correctly ABSENT** in Phase-1 (BBOT-009 emits the row + asserts unmatched only). Owned by next-pm/next-writer at MATCH-003 (§ADR-10 `mdr_clawback`). Named-deferred.

### 4.3 NAMED-DEFERRED (out of Phase-1 scope)
- **KTB = Phase-1.5** (mock-portal SCB-first; KTB `company_code`/full-account/silent-fail dialect deferred) — bot-side.
- **Phase-2 surfaces:** withdrawal/queue lane, OTP relay, balance/heartbeat, fleet-control, REAL-BANK M2. `bot-balance`/`bot-queue-mark` EFs are deployed but **ahead of their epic** — confirmed **not** wired into the Phase-1 3-touchpoint intake surface.
- **Reconciliation SPEC-pass items (gateway-internal drifts, not seal blockers):** #2 batch-cap-200 EF-code-only (no SPEC AC); #4 eager per-row dual-matcher calls vs the documented single fire-and-forget — functionally fine, each matcher self-filters by direction (`match_deposits_cascade → non_inbound_skipped` for OUT; `match_payout_statement → non_outbound_skipped` for IN), confirmed by drive; #5 stale `uq_bank_statements_dedup_in` references in some migration headers + `bot-balance` request-shape (Phase-2).

### 4.4 Out of scope (per the seal task)
- The **LIVE/L5 run** itself is deferred until after the wt-26 composed run. This seal is the G1 prereq, not the L5 leg.

---

## 5. Conclusion

Every gateway-side behavioral contract of the BANK-BOT-INTEGRATION epic (BBOT-001..009 + the MATCH-001 intake seam) was independently re-derived on qnccph @ `20260612000050`, every PASS falsified, all isolated. The money-safety spine — **count-based dedup as the sole gate**, **B7 match_hash**, **per-account auth binding (401/403)**, **K1/K2 rotate/revoke**, **two-layer dup-credit guarantee**, and **clawback-OUT zero-money-movement** — is sound. The named items are an error-shape disposition (pending architect), a by-design Phase-1 gap (MATCH-003), and out-of-Phase-1 deferrals — **none block the seal**.

**EPIC-SEAL: 🟢 GREEN — ISSUED.**

— next-investigator (team bbotseal), 2026-06-12
