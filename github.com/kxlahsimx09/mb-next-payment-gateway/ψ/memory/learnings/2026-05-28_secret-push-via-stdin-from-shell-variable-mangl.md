---
title: ## Secret push via stdin from shell variable mangles JSON values — use `--env-fi
tags: [brew-ops, cf-gateway, wrangler, supabase, secrets, deploy, gotcha, thread-254]
created: 2026-05-28
source: brew-ops deploy session, thread #254, 2026-05-28 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Secret push via stdin from shell variable mangles JSON values — use `--env-fi

## Secret push via stdin from shell variable mangles JSON values — use `--env-file` (supabase) or `cat file |` (wrangler)

**Context:** CF gateway-in-front PoC deploy (thread #254, msg 1219). Hosted Supabase `swqosfqrpmrhnebhksgd`, CF Worker `mb-next-cf-gateway`.

**Observation:** Pushing JSON-valued secrets via `printf '%s' "$VAR" | wrangler secret put NAME` AND `supabase secrets set "GW4_VERIFY_KEYS=$VAR"` (where $VAR came from `source env-file`) corrupted the value — the corruption only surfaces at runtime when the value is `JSON.parse`'d, not at push time. Both the CF Worker and the Supabase Edge Function returned 500/401 with cryptic errors (`SyntaxError: Expected property name or '}' in JSON at position 1` in Worker; `unknown_kid` in EF) that took ~30min to isolate.

**Diagnostic chain (re-usable):**
1. EF returns 500 + "Internal Server Error" plain-text body (Deno uncaught throw).
2. `wrangler tail --format json` captures the actual exception text — the only way to see Worker exceptions without code changes.
3. For Supabase EFs, `supabase secrets list` shows a SHA-256 digest of each value. Compute `printf '%s' "$VAL" | shasum -a 256` locally and compare — mismatch = corruption.

**The fix:**
- **wrangler:** `cat /path/to/value.json | wrangler secret put NAME` (file → stdin works; shell-variable → stdin mangles).
- **supabase:** `supabase secrets set --env-file <path>` where the file has one `KEY=value` per line, value verbatim. NOT `supabase secrets set "KEY=$VAR"`.
- Verify by hashing: `printf '%s' "$VAL" | shasum -a 256` must match `supabase secrets list` digest.

**Why:** the shell/CLI combo strips/transforms double-quotes inside unquoted JSON value somewhere on the path from `source env-file` → `$VAR` → `printf` → stdin → CLI parse. Could not pin which layer; `--env-file` / `cat file` route bypasses the whole chain.

**Tags:** #brew-ops #repo:mb-next-payment-gateway #cf-gateway #supabase #wrangler #secrets #gotcha #thread-254 #next

---
*Added via Oracle Learn*
