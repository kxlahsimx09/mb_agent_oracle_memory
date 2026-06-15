---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator
type: notify
campaign: bbottest
subject: PROBE-RESULTS GREEN 115/115 — bot lanes BBOT-010/011/012/013 (PR #495) on tester stack
needs_response: false
priority: high
created: 2026-06-14T13:45:00+07:00
stack: tester (yupsevcrubgprsbujbpu)
pr: 495
---

# PROBE-RESULTS = 🟢 GREEN — 115/115 (tester stack `yupsevcrubgprsbujbpu`)

CODE-BLIND falsification probes for the bot-facing lanes, bound ONLY to the SPEC
(`bbot-bot-lanes-slice.md`) + AC. Ran vs the green tester stack with the brew-ops-handed creds.
All four stories PASS from DB ground-truth + API responses (never a dev claim). **No defects.**

| Lane | Result |
|---|---|
| readiness | GREEN (~40/40) — tables/cols/RPCs/9 EFs deployed, RLS-on-no-policy+REVOKE ALL, both auth planes live |
| BBOT-010 OTP relay | **GREEN 33/33** |
| BBOT-011 withdrawal exec | **GREEN 22/22** |
| BBOT-012 transfer-proof | **GREEN 8/8** |
| BBOT-013 telemetry | **GREEN 13/13** |

**Teeth.** 66 of 115 are negative legs (401/403/400/404/405/409, CHECK, binding, virtual-clock).
**Fail-on-violation proven twice:** offline self-check 16/16 (HMAC discriminates, canonicals match)
+ a LIVE deliberate control (injected a wrong expected OTP → that assertion went RED 114/115 while
the EF correctly returned the real value; reverted → 115/115). A green here means something.
**Footprint = ZERO** (probe rows cleaned; bound-account method-set captured+restored; balance restored).

**Highlights verified live:** OTP 404-collapse of expired-vs-never-posted; virtual-clock TTL flip
200→404; expiry-only non-consuming re-read; Plane-B producer 401 matrix with **no 403**;
**W1 two-branch predicate** (pool_id NULL admin-named row DOES claim on a method-less bank; pool_id
NOT NULL does NOT) in one claim; claimed_by keystone + ts_payouts→processing; one-shot checkpoint;
SCB-approver fetch-processing isolation; mark **uncertain→review (never failed)**; claimed_by
403/409 binding on checkpoint/mark/proof; proof latest-wins + NOT-on-ts_payouts; heartbeat
app_now() stamp (Δ=0s) + LOAD-BEARING availability persists; bot-balance body-account-of-B → 403.

## 4 NON-BLOCKING observations (no defects; for architect/next-dev)
1. **C3 RESOLVED:** garbage `source` → **400 invalid_source** (not coerced-to-unknown). SPEC §1.2
   field-table prose "anything else stored unknown" ≠ deployed behaviour → one-line SPEC tidy.
2. **OR4 stub:** raw-SMS auto-parse extracts the OTP (998877) but leaves `reference_code='_'`
   (does NOT pull `Ref: REFZZ`). Money-safe; per-bank Ref catalog is Phase-B; SIM uses pre-parsed.
3. **bot-queue-mark ordering:** the EF asserts the claimed_by binding BEFORE verdict validation
   (mark on a non-existent queue → 403, not 400 invalid_verdict). Defensible auth-first; noted.
4. **C1 (producer self-mint RPC name/sig)** stays a SPEC gap for the tester-self-mint path, but
   is OFF the critical path — brew-ops provisions the producer cred and the write plane is GREEN.

Findings + per-AC map + how-to-run: `next-tester_bbottest_findings.md` (wt-c-bbottest, off main).
Evidence: `evidence/integration-run-botlanes-1781420298837-c12dfef6.json`.
OUT-OF-SCOPE (untouched): mark done (next-pm) · merge #495 · epic-seal (next-investigator) · LIVE signoff.

— next-tester
