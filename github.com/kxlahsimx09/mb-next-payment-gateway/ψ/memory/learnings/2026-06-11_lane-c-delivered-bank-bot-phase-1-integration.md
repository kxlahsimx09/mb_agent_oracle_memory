---
title: # Lane C delivered — bank-bot Phase-1 integration SPEC (PR #391) binds auth to B
tags: [next-product-writer, repo:cross, next, spec, bot-gateway-dispatch, deposit-lane, bank-bot, integration-contract, acceptance-criteria, handoff, decision, s2-ratified, adr-7, adr-4b, bk7, thread-13]
created: 2026-06-11
source: docs/spec/bbot-adapter-auth-slice.md + docs/spec/bbot-adapter-endpoints-slice.md @ PR #391; §ADR-7 §Amendment 2026-06-11 (PR #389)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# # Lane C delivered — bank-bot Phase-1 integration SPEC (PR #391) binds auth to B

# Lane C delivered — bank-bot Phase-1 integration SPEC (PR #391) binds auth to BK7 pre-merge

next-writer authored the mb-next-bank-bot ↔ gateway integration SPEC (campaign bankbot Lane C, thread #13 msg #44) → PR #391 `spec/bbot-adapter-phase1`, docs-only. Two house-layout slices ≤250 lines each:

- `docs/spec/bbot-adapter-auth-slice.md` — bot-side of the §ADR-7 §Amendment 2026-06-11 BK7 wire contract: X-Bot-Key/X-Bot-Signature, canonicals `${t}.${raw_body}` (POST) / `${t}.${method}.${path}` (no-body GET, WC3 ~5-min replay), 401 bot_key_missing/bot_key_invalid/bot_signature_invalid/bot_timestamp_expired vs 403 bot_account_mismatch with FAIL-CLOSED rules (no retry, no fallback header, no cross-account retry), K1 two-slot rotation tolerance (zero-downtime mid-overlap swap; retire→401→slot re-read), ONE authHeader() injector at BotAPI.request() seam, env `BOT_SECRET` retired (BK2) → `BOT_KEY`+`BOT_KEY_SECRET` from per-account fleet-secret slot. Every auth AC marked "per §ADR-7 §Amendment 2026-06-11 (PR #389, ratification pending)" — strip on #389 merge.
- `docs/spec/bbot-adapter-endpoints-slice.md` — 3 Phase-1 touchpoints (cursor GET direction-aware I-derived, last_date_bkk deprecated-legacy; POST bot-statements with BS-1..5 where BS-5 batch≤200 is REGULARIZED from code-only into a binding AC (413 batch_too_large); bot-config GET per D4 hybrid with the credentials/emails-keys-ABSENT invariant). 500 raw-detail passthrough SPEC'D DOWN to {error}-only (gateway change rides Lane 1.3). Dedup framing: count-based in submit_statements_batch = SOLE gate; bank_transaction_id payout-only/absent; dropped uq_bank_statements_dedup_in not cited. I-no-retry all 3 crossings. PHASE2_NOT_PORTED stubs: 11 legacy BotAPI methods throw synchronously (no HTTP, no silent null); bot-queue-mark/bot-balance EFs must NOT be wired (D2 pin). §8 reconciliation ledger dispositions all architect flags.
- cross-repo.md refreshed: bot identity service-role-JWT framing realized as §ADR-7 bot-tier key (BK1/BK5/BK6); spec pair back-linked; mb-next-bank-bot seed 9405272 named.

Traceability: epic BBOT-002/004 [PENDING-ARCHITECT thread-13 D3] resolve to BK1/BK3/BK4/BK5 (auth slice §7 table; epic file stays next-pm's to patch post-#389-merge). BBOT-005 SIM source pinned as a client of the same POST contract.

OPEN PIN (non-blocking, flagged in-spec §1): BK7 pins the wire surface but not whether the botk_ key string doubles as the HMAC signing secret or a paired secret accompanies it (§ADR-7 base = pair; Lane-1.1 bot_credentials.secret_hash reads either way). SPEC absorbs both behind authHeader() + two slot fields (equal if unified); one architect line on thread #13 hard-pins it.

Pattern worth keeping: when an upstream amendment PR is unmerged but its wire contract is declared STABLE by the architect, the SPEC can bind to the contract clauses verbatim and carry a strip-on-merge ratification marker on every dependent AC — the bot team builds to contract, not code, and nothing reworks at merge.

---
*Added via Oracle Learn*
