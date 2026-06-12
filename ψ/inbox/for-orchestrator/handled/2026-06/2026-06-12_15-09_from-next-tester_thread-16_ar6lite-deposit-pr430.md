---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator-buildteam
type: reply
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: "AR6-LITE VERDICT — DEPOSIT golden journey (PR #430 @ 39500824): (i) template-deltas/auth front-door PASS · (ii) 3 re-mapped faults PASS · (iii) admin-slip channel-realism PASS-with-lean (needs ONE honest-limit line on the DEPOSIT L5 record). Two of my prior #404 leans (F-C2 callback-count, F-C3 global-count) are FIXED here; F-C1 L2-iii now CARRIED. No blocker."
needs_response: false
priority: high
created: 2026-06-12T15:09:00+07:00
---

# AR6-LITE — DEPOSIT golden journey (PR #430 @ `39500824`, reviewed from PR head)

LIGHTER scope per the AR6 ruling (bootstrap template already validated via #404). Code-blind on
`supabase/`; reviewed the 11 code/doc files at head (not the 24 evidence files, except a secrets sweep).
Complementary to next-code-reviewer's gate. Quick secrets sweep: **clean** — `api_key_secret` redacted;
the lone `botk_FHNEx89` is a `bot_key_prefix` (public-identifier half, evidence file 008), not a secret.

| Dimension | Verdict |
|---|---|
| (i) Deltas from the validated template — the auth front-door leg (CE2/CE3) | **PASS** |
| (ii) The 3 re-mapped faults (dup-credit / dup-egress / dead-letter→P2.12) | **PASS** |
| (iii) Channel-realism — the ADMIN upload-slip path vs the customer-facing slip EF | **PASS-with-lean** |
| **Overall AR6-LITE** | **PASS-with-leans — valid DEPOSIT+AUTH gate artifact; one actionable item (the honest-limit line, iii-1).** No blocker against #430. |

---

## (i) Deltas / auth front-door (CE2/CE3) — PASS

**The new auth front door is real and well-bounded.**
- **CE2 boundary correctly drawn.** `seedReturningAdmin` is SETUP/TRANSPORT only (gotrue admin REST +
  service_role; a fresh per-run admin with a verified TOTP factor) — explicitly "NOT the front door"
  (`entry-auth.ts:40-65`). `adminFrontDoorLogin` is THE front door: enters with the **anon key + a LIVE
  computed TOTP code** through the real custom EFs `auth-login` → `auth-2fa-verify` → **AAL2**
  (`entry-auth.ts:68-91`), and the returned AAL2 bearer drives **every** admin action
  (`admin-actions.ts:22`, `deposit-journey.ts:85-87`) — **no service_role shortcut**. The login asserts
  `requires_2fa` actually fired (`:71-72`); verify asserts a real AAL2 token (`:80`). TOTP is computed
  live (RFC-6238, `:103-111`) — genuine 2FA, no bypass.
- **CE3 auth-axis frame.** The decoded `aal`/`amr`/`session_id`/`sub` + `factorId`/`userId` are framed
  with the exact L3 read recipe (`auth.mfa_factors WHERE user_id=<sub> status=verified` +
  `auth.sessions WHERE id=<session_id> aal2`, `entry-auth.ts:84-89`). Correctly **frames** the
  identifiers rather than reading `auth.*` (PostgREST doesn't expose it — `db.ts:10-13,64-66`).
- **Dual-epic gating** is conditional on both epic-seals GREEN (`deposit-journey.ts:6-8`) — sound.

**Other deltas are faithful reuses of the #404 template — and two of my prior leans are FIXED:**
- ONE X-Request-Id minted once + stamped on **every** HTTP **including the service-role reads**
  (`journey-context.ts:36,61`; `db.ts:23,36`) — tighter than #404.
- **Client front door is hard-required** (no GW4 fallback lever; `entry-client.ts:8-9,45` throws if not
  201) → **my #404 lean F-M1 (fenced lever) does not recur.**
- **Ground-truth reads are deposit-SCOPED** (`db.ts:51-58`, `reference_id`/`source_id = depositId`) →
  **closes my #404 lean F-C3 (global uncorrelated count).**
- `restSelect` throws on non-2xx (`db.ts:25`) — adopts the #418 loud-on-error discipline.
- Harness RUNS, never verdicts (`deposit-journey.ts:3-4,56`; `db.ts:6-8`); append-only via the
  validated `capture.ts`.

*Lean (i)-a (note, not a defect):* the `L1-auth-frontdoor` leg GREEN keys on the decoded JWT `aal` claim
(`deposit-journey.ts:79`) — a self-reported claim; the load-bearing proof is L3's `auth.sessions`
re-read, which is correctly framed. Consistent with harness-never-verdicts.

## (ii) The 3 re-mapped faults — PASS

Re-mapped vs the 06-30 design (old fault-i MOCK_BANK dup-txn → now the bbot SP3, certified #404; old
fault-iii "no deployed alert" → resolved, P2.12 live KF3 #414) — `faults.ts:1-15`, README.

- **F-i — slip-lane dup-credit=0** (`faults.ts:41-54`): adversarial re-`approve` on the already-`paid`
  golden deposit (`admin-actions.ts:52-55`); asserts the deposit-scoped `deposit_credit` count stays
  `1→1`. Maps the zero-tolerance dup-credit rule onto the **slip/admin** lane (distinct from bbot
  statement-dedup). ✔
- **F-ii — callback dup-egress=0** (`faults.ts:57-78` + `mock-merchant.ts` `/flaky`): `/flaky` returns
  500 once per `txnId` then 200 (dedup keyed on `txnId`, `mock-merchant.ts` diff); asserts
  `delivered ∧ attempt_count≥2 ∧ credits==1 ∧ paidRows==1`, and corroborates with the merchant POST
  count. Captures `dedup_key`+`event_id` (`db.ts:58`). → **closes my #404 lean F-C2 (callback-count now
  gated in a dup-fault leg).** ✔
- **F-iii — dead-letter → P2.12 must-page** (`faults.ts:81-104`): `/fail` 3×500 → `dead_letter`,
  fingerprint `p2.12-<row id>`, within-15-min, optional `KEEP_ALERTS_API` confirm (else AMBER + the
  owner-visible Keep→Telegram page is the L5 surface). Same pattern I reviewed in **#419**. → **carries
  the L2-iii must-page leg my #404 AR6 F-C1 flagged as OWED for the DEPOSIT epic.** ✔

All three are correlated to the deposit, tri-state honest (GREEN/AMBER/RED), and never crash the run
(`deposit-journey.ts:97-98`).

*Lean (ii)-a (L3-coordination note, not a defect):* the run drives **3 terminal `paid` deposits** under
ONE X-Request-Id (golden + F-ii@712 + F-iii@713). Per-deposit assertions are correct, but
next-investigator's **conservation (Σ) recompute must sum across all 3** (2 delivered callbacks + 1
dead-letter), not assume one. The harness frames each separately, so L3 has the data — flagging so the
seal recompute scopes by deposit, not by run-total.

## (iii) Channel-realism — the ADMIN upload-slip path — PASS-with-lean

**The carried-from-seed note, assessed.** The journey exercises slip-upload via the **ADMIN** path
(`admin-deposit action=upload-slip`, behind the AAL2 front door — `admin-actions.ts:24-26`), because the
**customer-facing client-tier slip EF shape is not in the harness SPEC set** (the journey documents this
honestly at `admin-actions.ts:12-14` + README). The DEPOSIT contracts it drives (DEPOSIT-009 upload-slip,
008 verify-now, 007 approve→finalize) are admin-deposit actions.

**Assessment:** the slip→verify→approve→finalize **money mechanics** (slip stored / status stays pending
→ `checking` → 6-check cascade → credit+MDR → `paid` → callback) are **genuinely exercised end-to-end
behind a real AAL2 front door** — the credit/MDR/callback are identical regardless of *who* uploaded the
slip. So the admin path **is acceptable for the DEPOSIT-epic L5 money proof.** What it does **not** prove
is the *customer-facing* slip submission front door (a distinct auth tier + request shape), **if one
exists** in Phase-1.

**Finding (iii)-1 (actionable):** add **one honest-limit line** to the DEPOSIT-epic L4 owner card / L5
gate record so the owner ACCEPT is informed — verbatim suggestion:
> *"Slip-upload is exercised via the ADMIN path (`admin-deposit action=upload-slip`) behind a real AAL2
> front door; the customer-facing client-tier slip-submission EF is not in the SPEC set and is not
> exercised by this gate."*
This mirrors how ADR-21 states the M1-SIM scraper gap (honest-limits 1–2) and the #404 declared
non-coverage. The journey already surfaces it in-code — it just needs to surface on the **owner-visible
record** too. **Route to next-architect/next-pm:** does a customer-facing slip EF exist in Phase-1? If
**NO** → the line becomes *"slip resolution is admin-only by design (no gap)"*; if **YES** → it is a real
honest-limit (that front door is unexercised — a candidate future leg / M2). Either way, one line belongs
on the record; that requirement is **why this dimension is PASS-with-lean rather than PASS.**

---

## Bottom line

#430 is a **valid DEPOSIT+AUTH live-gate artifact** — the auth front door is real (CE2/CE3 clean), the
three faults map to the zero-tolerance rules and are deposit-correlated, and it **fixes two of my #404
leans (F-C2, F-C3) and carries the L2-iii leg (F-C1)** I'd flagged as owed. **No blocker.** The single
actionable item is the **honest-limit line for the admin-slip path (iii-1)** on the DEPOSIT-epic gate
record — a gate-record/L4 item, not a code change to the harness. (The dual-epic conservation note (ii-a)
is for next-investigator's L3 recompute.)

— next-tester (campaign livegate), AR6-LITE on PR #430, 2026-06-12 15:09 +07

handled_at: 2026-06-12T20:00:00+07:00
handled_by: orchestrator-buildteam-wt26
