# Handoff UPDATE — SUPERSEDES `2026-06-18_client-api-gaps-featweb`

**Reason:** a next-pm reconciliation (campaign `featweb`, 2026-06-19) found the earlier gap handoff is STALE. **6 of the 7 enumerated client-facing API gaps are ALREADY BUILT + SHIPPED on origin/main** via **PR #610 / §ADR-26 — epic `epic-client-read-api.md` (CLIREAD-001..007), marked DONE ✅** (squash `70cfa55`; origin/main HEAD `17bd863`). Quality gates at merge: REVIEW APPROVE · TESTER 58/58 · INVESTIGATOR SEAL 59/59. So most of the "to build" list in the prior handoff is **already done** — do NOT re-dispatch a build for them.

## NOW-BUILT on origin/main (6) — endpoints exist, registered, RPC-backed
- Deposit status poll + get-by-id → `client-deposit-status` (CLIREAD-001, public) + `client-deposits` get-by-id (CLIREAD-003)
- Payout status poll + get-by-id → `client-payout-status` (CLIREAD-002) + `client-payouts` (CLIREAD-003)
- List deposits/payouts, API-key + cursor pagination + filters → `client-deposits` / `client-payouts` (CLIREAD-004) (dedicated API-key EFs; leaves gotrue `tenant-read` untouched)
- Client wallet balance → `client-wallet-balance` (CLIREAD-005) `{balance,available,frozen}`
- Bank-code list → `client-bank-codes` (CLIREAD-006)
- Merchant self-cancel deposit via API-key → `client-deposit-cancel` (CLIREAD-007)

## STILL-OPEN — but DEFERRED / non-gap BY DESIGN (not accidental; per §ADR-26 CR7)
- Self-cancel **payout** = SAME/no-gap (neither system offers it). Self-serve **callback resend** = deferred (admin-only).
- R1 webhook retry depth (3 attempts/30s → dead-letter) — deliberate §ADR-9 divergence, kept.
- R2 slip upload (url-string, not multipart) — deferred (owner decision).
- Gateway day-budget caps (resolved-but-not-enforced) — deferred with the CF gateway.

## DOC STALENESS to fix (campaign-only artifacts, on branch `campaign/featweb` @ `b290c08`, 15 commits behind origin/main)
- `docs/api/gap-vs-current-maxpay.md` (does NOT exist on main — campaign-only): flip 8 merchant-API rows to built (cite CLIREAD/PR #610); mark "What we'd ADD" items 1–6 DONE; keep 7/8/9 as deferred.
- `docs/api-client/INDEX.md` LIVE-vs-GAP table + "bottom line": flip 6 GAP→LIVE (status poll/get-by-id deposit+payout, list, balance, bank-codes, self-cancel-deposit). PR #610 already flipped `status.md` + `balance-banks.md` on main but NOT INDEX.md. Keep self-cancel-payout + resend as GAP.
- The in-app `/docs` page (admin-web, served at featweb.3-1-0-33.sslip.io/docs) renders these markdown files → currently tells merchants 6 LIVE endpoints are "not implemented" = an active inaccuracy. Refresh after the doc flip.

## RECOMMENDED next action (orchestrator decision)
Prefer **reconciling `campaign/featweb` with origin/main** (15 behind) so it picks up the real CLIREAD endpoints + main's doc flips, THEN finish INDEX.md + gap-doc + rebuild `/docs` — rather than band-aid hand-editing stale copies. Evidence file: `next-pm_featweb_gapstatus_findings.md` (row-by-row edits) on `campaign/featweb` @ `5e5af51`.
