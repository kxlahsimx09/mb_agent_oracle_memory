---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator
type: verdict
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_14-23_from-orchestrator_thread-13_dispatch-golden-journey-automatch.md
subject: "CAMPAIGN-CLOSING RUN — statement auto-match golden journey GREEN end-to-end on the AWS SIM stack (per-leg verdicts + evidence + investigator handoff)"
priority: high
needs_response: false
created: 2026-06-11T18:25:00+07:00
---

# Golden journey — GREEN end-to-end on the real AWS stack

**X-Request-Id (the investigator's ground-truth key): `live-bbot-1781176527471-e7cda45f`.**
Run on the §ADR-21 staging stack `sinuwgsqqyqzlpaavimf` + the real mb-next-bank-bot
(unmodified `banks/scb/*`) in SIM on ECS Fargate (`mb-next-bankbot-sim`) against the merged
SCB mock portal, over the PAIRED-key contract. No fixture-post, no localhost — the bot ran
on AWS per the owner directive.

## Per-leg verdict (I RUN; the PASS/FAIL is next-investigator's L3 recompute — AR2)

| Leg | Verdict | Evidence |
|---|---|---|
| L0 readiness gate | **GREEN** | botKeyAuth taxonomy live, bot-config deployed, mint/rotate RPCs present, portal control-plane auth OK |
| L1a bot witness | **GREEN** | live two-slot `bot_credentials` row + brew-ops `mint` audit row; liveness proven by the scrape itself |
| L1b client wire | **GREEN** | deposit `c10c2ac8…` created through the **real CF Worker** machine-auth path (Worker→EF GW4 — *the verify_failed drift from earlier runs is FIXED*, see below) |
| L1c scrape→push | **GREEN** | real bot scraped the injected row with unmodified `banks/scb/*`, pushed over PAIRED keys; `match_hash` present, source identity `KBANK / x9876` carried |
| **L1d auto-match** | **GREEN** | deposit `paid`; `matched_statement_id=ba46e1ac…`; wallet change-log 0→4 (credited net `final_amount=514.57`); merchant callback `deposit.paid status=PAID amount=524` delivered over the real WAN tunnel |
| L1e cursor | **GREEN** | I-derived int64 BKK-minute cursor `in=202606111815` (post-#409 BS-2 fix) |
| **L2b clawback (SP6)** | **GREEN** | `/sim/clawback` → out-row `2f87a9ba…` ingested as an ordinary debit, `match_status=unmatched` (unmatched-by-design), `อ้างอิง #1` marker preserved; original deposit `paid` untouched, **no wallet move, no extra callback** |
| **L2a dup-fault (SP3)** | **GREEN** | crash-restart lever drove a fresh task → bot re-read its gateway-derived cursor + re-scraped the append-only portal → **count-based dedup held: exactly 1 `bank_statements` row, credit unchanged** (dup-credit = 0) |
| L3 rotate stretch | SKIPPED (by design) | remote rotate is opt-in (`ROTATE_STRETCH=1`) — it strands the Fargate bot on a retiring key and the swap needs a brew-ops secret re-injection; not run unsolicited |

**Every mandated leg GREEN.** This closes the loop the campaign handoff aimed at: statement
auto-match E2E on real components, plus both zero-tolerance faults (SP3 dup-credit=0, SP6
clawback unmatched-by-design) proven through the real bot.

## Ground-truth trail (for the L3 recompute, keyed by the X-Request-Id)

- deposit `c10c2ac8-5ead-424c-9651-812f2afa30e9` — `request_id=live-bbot-1781176527471-e7cda45f`, `status=paid`, `amount=524`, `final_amount=514.57`, `system_bank_account_id=77777777-…-000000000001` (SCB), `matched_statement_id=ba46e1ac…`, `paid_at=11:16:02Z`.
- statement `ba46e1ac-eaaf-468e-a54c-8cb1e680c11b` — `amount=524 in`, `match_status=matched`, `matched_request_id=live-bbot-1781176527471-e7cda45f`, `source_bank_code=KBANK`, `source_account_no=x9876`, `match_hash=66bcede7…`.
- clawback out-row `2f87a9ba-fffd-488a-bd91-2b90cae4d80f` — `amount=524 out`, `match_status=unmatched`, `description="โอนกลับรายการ อ้างอิง #1 ธนาคารเรียกคืน"`.
- 4 `wallets_change_logs` rows from the finalize credit. Merchant callback in `/tmp/mock-merchant.jsonl` (committed as `log_merchant.txt`).

Evidence (append-only frames + manifest + trace/video) committed on PR #404 at
`poc/integration/evidence/live/bbot/live-bbot-1781176527471-e7cda45f/`.

## Two findings surfaced and resolved along the way (the gate earned its keep)

1. **Worker→EF GW4 assertion drift on staging (RESOLVED).** Runs 1–3 hit 401 `verify_failed` on every machine create (deposits + payouts) — a real "no client can create on staging" fault I routed (blocker envelope 17:15, thread #13 msg 100). **brew-ops re-synced the GW4 keyring; run 4 onward the real client wire is GREEN.** No harness lever needed for the closing run.
2. **BS-2 / D1-17 contract alignment (harness, not gateway).** Auto-match needs the injected statement amount to equal the deposit's stored amount, which DEPOSIT-001 D1-17 floors to whole baht (the QR embeds the integer the payer transfers). Fixed in the harness (whole-baht amount end-to-end) — not a gateway defect; #409's BS-2 int64 cursor fix is confirmed working (L1e GREEN).

## Process notes (no action needed)

- The bot + portal are **co-located in one Fargate task**, so the SP3 restart resets the in-memory portal and rotates the public IP. The harness now auto-resolves the live IP each launch via the fleet resolver — the run is repeatable without a manual slot edit.
- **Handoff to next-investigator filed** (`for-next-investigator/2026-06-11_18-25`, envelope-first) with the stamped X-Request-Id for the independent L3 ground-truth verdict. I do not pre-judge PASS/FAIL.

— next-live-tester, 2026-06-11 18:25 +07
