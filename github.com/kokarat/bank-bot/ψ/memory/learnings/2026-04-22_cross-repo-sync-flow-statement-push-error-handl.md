---
title: cross-repo-sync — flow `statement-push-error-handling-and-retry` is the bot-side
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:statement-push-error-handling-and-retry, cross-repo-sync, mobiz-payment-gateway, deposit-auto-match-from-statement, dedup-contract, no-retry-design]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# cross-repo-sync — flow `statement-push-error-handling-and-retry` is the bot-side

cross-repo-sync — flow `statement-push-error-handling-and-retry` is the bot-side zoom-in on the failure-mode span of mobiz's `deposit-auto-match-from-statement.md` steps 3–5 (POST ingest → dedup → 200 OK to bot). Classic caller/implementor split at a dedup contract.

**Counterpart mapping.** Mobiz `deposit-auto-match-from-statement.md` (W8 trace TBD) has steps 3 (`BankBot->>Gateway: POST /bot/bank-statements`), 4 (`Gateway->>Gateway: dedup + insert + async matcher kick`), 5 (`Gateway-->>BankBot: 200 OK body=inserted_count+skipped_count`). Those three steps are a single "ingest round-trip" at the caller's level of abstraction. The bot-side `deposit-auto-match-from-statement.md` (bot-side) covers the happy path. THIS new flow covers the FAILURE MODE span of that round-trip: 9 error classes + the load-bearing dedup-as-retry-substitute contract.

**Why this flow was missing until now.** The bot-side `deposit-auto-match` carries ONE line in §Error paths labeled `POST_5xx` with the comment "Rows NOT retried in this flow — they will reappear in the next tick's scrape". That single line is doing all the work of explaining the design — but it does NOT surface (a) that 4xx has identical handling (and different recovery semantics — schema drift never self-heals), (b) the four load-bearing assumptions that make no-retry correct, (c) what breaks when those assumptions break, (d) the `UPDATE_BALANCE_FAIL` cascade from 9a (bubble) vs 9b (caller try/catch per site), or (e) the `CURSOR_GET_FAIL` silent-swallow at step 1. The new flow extracts and unpacks all five.

**What the bot-side doc adds that the mobiz-side doc cannot see:**
1. Four load-bearing assumptions of the no-retry design — gateway dedup determinism, scrape idempotency, cursor-advance-on-success, bank-portal row retention window.
2. Nine failure modes of the three crossings, with the specific try/catch call sites for each.
3. The `[INTENTIONAL?]` / `[DRIFT]` flags on the silent-swallow and 4xx-log-spam behaviors — open questions that mobiz side cannot author because they are bot-internal.
4. The "slug contains 'and-retry' but code has zero explicit retry" framing — the doc's central tension, resolved by reframing cursor-reload as THE retry mechanism.

**What the mobiz-side doc covers that this doc references but does not re-explain:**
- The dedup key composition: `(account_number, transaction_date_bkk, amount, transaction_code)` + `balance_after` (KTB) / `description` (SCB). Named in bot-side flow §Implementation pointers via `// ext:` marker with mobiz breadcrumb reference.
- The `MatchNewStatements` async kick after successful ingest.
- The 30s retry ticker + 1-hour look-back window on mobiz side (statements older than 1h stop being auto-retried by gateway).
- The `match_status` taxonomy (pending/unmatched/fee/matched/review).

**Relationship to sibling flows in bank-bot:**
- `deposit-auto-match-from-statement.md` (bot-side) — happy path; this flow zooms into its §Error paths entry `POST_5xx`.
- `queue-claim-to-processing-state-machine.md` — cross-references the shared `KTB_SESSION_DEAD` sentinel handling.
- `bot-bootstrap-and-status-reporting.md` — potentially relevant for Q4 (auth-failure reporting) but currently out of scope.

**Search anchors for symmetric cross-repo queries:**
- `arra_search query="flow:statement-push-error-handling-and-retry cross-repo-sync"` — should return this breadcrumb.
- `arra_search query="statement-push mobiz-payment-gateway"` — should return this breadcrumb (names `mobiz-payment-gateway` in body).
- `arra_search query="dedup contract bank-bot"` — should return this breadcrumb + the mobiz-side ingest learnings via the dedup-key cross-reference.
- `arra_trace_get 251228a0-50f7-4c5f-925f-e8aaecd41e48` — returns the W8 root trace for this pass.

**Authoring status:** bot-first (same as `queue-claim-to-processing-state-machine`). Mobiz side does not yet have a dedicated "ingest-failure-and-retry" flow doc; the dedup contract it implies is documented inline in `deposit-auto-match-from-statement.md` rather than extracted. No action requested on mobiz side — current arrangement (dedup contract lives in mobiz's flow, failure consequences live in this bot flow) is already the right territory split.

---
*Added via Oracle Learn*
