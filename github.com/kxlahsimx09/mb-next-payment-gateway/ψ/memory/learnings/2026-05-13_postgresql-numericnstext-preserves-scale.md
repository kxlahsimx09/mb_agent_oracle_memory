---
title: **PostgreSQL `numeric(N,S)::text` preserves scale — client-side hash compute mus
tags: [postgresql, numeric-scale, hash-composition, v1-fraud, client-server-parity]
created: 2026-05-13
source: PoC Phase B sprint 2026-05-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **PostgreSQL `numeric(N,S)::text` preserves scale — client-side hash compute mus

**PostgreSQL `numeric(N,S)::text` preserves scale — client-side hash compute must match.**

When statement-side hash is composed in SQL via:
```sql
encode(sha256(
  (account_number ||
   upper(source_bank_code) ||
   (amount * 100)::text ||      -- amount is numeric(18,2)
   to_char(date, 'YYYYMMDDHH24MI')
  )::bytea
), 'hex')
```

`(300.13 * 100)::text` returns `"30013.00"` — NOT `"30013"`. PG numeric arithmetic preserves max scale across operands.

If client-side (TypeScript / JS) needs to compute identical hash for collision lookup (e.g., V1 slip-reuse detection in PoC mb-next-payment-gateway), must mirror exactly:
```ts
const cents = Math.round(amount * 100).toFixed(2);  // "30013.00" — not toString() which gives "30013"
```

**How surfaced (2026-05-13 PR #94 V1 load-bearing test):** Initial TS hash compute used `Math.round(amount * 100).toString()` → produced "30013" → hash mismatch with bank_statements.match_hash → V1 detection silently failed to fire (test "passed" because admin_decision='reject' workaround masked it). Verified mismatch via psql round-trip:
```
sha256(... + '30013' + ...)      → 650c58e7681d1fefffa9601f6720b6272e6c789156a8fda99dd5d64b599196dc
sha256(... + '30013.00' + ...)   → 69f95434290e87a43d976858b583fac0dfa5c05410152ea8cfc804874503395e  ← server's hash
```

**How to apply:**
- Whenever computing a hash/fingerprint client-side that must equal SQL-side composition, do psql round-trip verification: hand-compose the inputs in psql, then compose same in client lang, diff hashes.
- For `numeric(N,S)::text` specifically: use `.toFixed(scale)` in JS/TS not `.toString()`.
- Other gotchas: `to_char` Asia/Bangkok timezone offset = UTC+7 hardcoded in TS; date precision matters (YYYYMMDDHH24MI = minute granularity = ±60s grace).

Pattern instance: PoC mb-next-payment-gateway V1 fraud detection (§ADR-4d V1 slip-reuse collision lookup).

---
*Added via Oracle Learn*
