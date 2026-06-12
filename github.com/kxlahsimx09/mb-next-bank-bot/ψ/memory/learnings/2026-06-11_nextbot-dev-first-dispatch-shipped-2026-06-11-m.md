---
title: nextbot-dev first dispatch shipped (2026-06-11): mb-next-bank-bot Phase-1 adapte
tags: [nextbot-dev, repo:mb-next-bank-bot, next, bankbot, adapter, sim, decision, handoff]
created: 2026-06-11
source: thread #13 dispatch — PRs kxlahsimx09/mb-next-bank-bot#1 #2
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# nextbot-dev first dispatch shipped (2026-06-11): mb-next-bank-bot Phase-1 adapte

nextbot-dev first dispatch shipped (2026-06-11): mb-next-bank-bot Phase-1 adapter port + SCB mock portal — both as PRs awaiting next-code-reviewer.

PR #1 (BBOT-001..004 bot-side): core/api.js rewritten to the merged SPEC pair — ONE authHeaders() injector (PAIRED BOT_KEY identifier + BOT_KEY_SECRET HMAC per thread-13 msgs 46/48), exactly 3 endpoints (bot-config / bot-bank-statements-last / bot-statements), 11 legacy methods throw Phase2NotPortedError synchronously. app.js re-scoped to a 250-line statements-only runtime; core/secrets.js reads BANK_CREDENTIALS/BANK_EMAILS JSON env from the per-account fleet-secret slot (names defined here — provisioning must adopt them).

Key verified-not-guessed decisions:
1. The adapter MAPS scraper rows → contract rows: transaction_date_bkk → statement_date_bkk, and amounts are sent POSITIVE with direction carrying the sign — verified against match_payout_statement, which does abs(stmt.amount − payout_amount) vs positive payout amounts (a negative out-amount would never match).
2. BS-1 in-batch dedup equality = all scalar contract fields + raw_text, EXCLUDING bank_extras (it carries scrape-position `sequence`, which differs on a page-boundary re-read and would defeat the dedup).
3. Boot is one-attempt fail-closed: exit(1) on config failure; supervisor restart re-reads the slot env = the BK4 rotation recovery path. No retry layer anywhere (I-no-retry), no client sent-row cache (review-reject).
4. Integration flags for gateway lanes: bot EFs must run with verify_jwt OFF (SPEC pins only X-Bot-Key/X-Bot-Signature; the PoC simulator sent a Bearer anon key but the real adapter does not); bot-config EF still unbuilt (adapter parses response.data ?? response).
5. KTB login SMS-OTP dead-ends in Phase-1 by design (fillOTP → otp_api → getOTP stub throws); SCB viewer login needs no OTP.

PR #2 (BBOT-006..009): sim/mock-portal/ — SCB mock portal, zero deps (node:http). The BBOT-006 fidelity bar is an executable test (tests/mock-portal.fidelity.test.js): the UNMODIFIED banks/scb stack logs in and scrapes it in real Chromium (~67s). Mode-blind costs zero scraper change because banks/scb/selectors.js already reads BANK_URL from env at the seed — but tests must set BANK_URL/DATA_DIR BEFORE requiring banks/ or core/browser (require-time reads). Control plane uses X-Sim-Control-Secret (separate from BOT_KEY, boot-required); store is append-only (DELETE → 405); clawback = NEW direction='out' full-amount reversal row referencing the original.

Portal anti-contract (render these and dismissPopups/checkSession misfire): body text หมดอายุ/session/expire/ถูกให้ออกจากระบบ/เข้าสู่ระบบอีกครั้ง/กรุณาเข้าสู่ระบบ; any ตกลง button; role=dialog; class names containing banner/promotion/announcement/campaign/snackbar/toast/modal/dialog.

---
*Added via Oracle Learn*
