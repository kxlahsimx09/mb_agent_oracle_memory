---
title: BS-2 wire conformance fix (PR #409) — gateway statement-date drift was DOUBLE-la
tags: [next-dev, repo:mb-next-payment-gateway, next, deposit, bot-gateway-dispatch, bbot, contract-drift, build, gotcha, bs-2]
created: 2026-06-11
source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/409 @ e651e37 — supabase/migrations/20260611000200_bs2_statement_date_bkk_int64_wire.sql
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# BS-2 wire conformance fix (PR #409) — gateway statement-date drift was DOUBLE-la

BS-2 wire conformance fix (PR #409) — gateway statement-date drift was DOUBLE-layered: wire-name AND format

Context: brew-ops E2E smoke vs the live Fargate bot (thread #13 msg 92) — every `POST /bot-statements` 500'd, cursor leg "never-new".

What was actually wrong (sharper than the dispatch framing): `submit_statements_batch` read the internal COLUMN name `transaction_date_bkk` from the row JSON — but the wire field per the merged spec (bbot-adapter-endpoints-slice §3, BS-2) is `statement_date_bkk`. So the `::timestamptz` cast never even saw the bot's int64 — it cast NULL → NOT NULL violation → 500. The cursor RPC (`get_last_statement_dates`) emitted ISO strings where the bot compares numerically (`last_in_date_bkk || 0`). Spec + ADR §ADR-4b (B1 cursor shape, B6 row schema, B7 hash) + bot all agreed; ONLY the gateway implementation drifted — no contract re-cut, no architect escalation.

The fix shape (migration 20260611000200, one file, ZERO EF changes — both bot EFs pass JSON through):
- Boundary-only + symmetric: parse int64→timestamptz at intake, render timestamptz→int64 at the cursor. STORAGE stays timestamptz (`bank_statements.transaction_date_bkk`) because the matchers do interval arithmetic on it and the column name is gateway-internal per slice §8.
- Helper pair `_bkk_minute_to_ts(bigint)`/`_ts_to_bkk_minute(timestamptz)` pinned 'Asia/Bangkok' — fixed +07, no DST ⇒ injective + lossless round-trip; bigint equality ⇔ timestamptz equality, so the batch-side dedup leg can compare raw bigints.
- Parse ONCE per row; dedup leg, B7 match_hash minute, and INSERT all derive from that one parse ⇒ hash digits provably equal the digits the bot sent.
- Edge-case-E validation (design doc bot-gateway-contract §"E — precision"): missing key / JSON string / non-integral / non-calendar-minute all RAISE labeled `bad_statement_date_bkk:` (jsonb gotcha: `jsonb_typeof(v->'k') <> 'number'` is NULL-not-true for a MISSING key — need explicit `v->'k' IS NULL OR …`).

Verified on dev-1 via Management API direct-RPC (no EF needed): round-trip exact, push 2, re-push 0, cursor int64 4-key spec shape, stored instant 18:45 BKK = 11:45 UTC, 4 labeled rejections; sentinel rows cleaned.

Downstream consequences routed (not gate items): frozen PoC bot-sim `main-hosted.ts` + tester harness `_spec.ts` map `stmtDateBkk:"transaction_date_bkk"` rode the drifted shape — their pushes get loudly rejected once this lands on the tester stack; probes rebind to the spec (spec text unchanged). Staging redeploy after merge = db push ONLY, no EF redeploy.

Pattern worth keeping: when a "cast drift" is reported on a JSON-carrying RPC, check the JSON KEY NAME first — a column-name-vs-wire-name mismatch hides underneath the type mismatch and changes the failure mode (NULL violation, not cast error).

---
*Added via Oracle Learn*
