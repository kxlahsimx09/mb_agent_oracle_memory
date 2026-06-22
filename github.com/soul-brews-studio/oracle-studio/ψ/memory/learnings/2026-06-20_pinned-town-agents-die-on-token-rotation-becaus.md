---
title: ## Pinned town agents DIE on token rotation because spawn injects the EPHEMERAL 
tags: [brew-ops, fleet, account-pinning, oauth, token, claude-code, gotcha]
created: 2026-06-20
source: Oracle Learn
project: github.com/soul-brews-studio/oracle-studio
---

# ## Pinned town agents DIE on token rotation because spawn injects the EPHEMERAL 

## Pinned town agents DIE on token rotation because spawn injects the EPHEMERAL access token (not a setup-token)

**Symptom (owner-reported, seen ≥2×):** a Fleet-Town agent pinned to a Claude account has its `claude` session **close/die entirely** (not just the cosmetic badge glitch) when that account's token rotates (human re-login / refresh elsewhere). This is a DIFFERENT, more serious bug than the badge "pinned" name-loss that commit `00f4183` addressed — `00f4183` only fixed the cosmetic name (`hash(token)→plan` recall) and does NOT prevent the death.

**Root cause (traced in oracle-studio `feat/all-prs-rebased`):**
- `server/agents.ts:59-64` `spawnAgent()` pins an account by injecting `--env CLAUDE_CODE_OAUTH_TOKEN=<token>` where `<token> = planAccessToken(plan)`.
- For the (currently 3, all dir-based) plans in `~/.fleet-town/auth-plans.json`, `planAccessToken()` (`server/usage.ts:87-90`) reads the **ephemeral `accessToken` from that dir's `.credentials.json`** — which has `expiresAt` only **~1 hour** out and is **rotated/revoked on re-login**.
- `CLAUDE_CODE_OAUTH_TOKEN` is a **STATIC bearer token — Claude Code does NOT auto-refresh it** (confirmed: https://code.claude.com/docs/en/authentication.md). It is meant to hold a **`claude setup-token`** long-lived (~1 YEAR) token for headless/CI, NOT the ~1h accessToken.
- So the pinned agent freezes a ~1h, non-refreshable, re-login-revocable token → on expiry/rotation → **401 → claude exits → tmux pane/session closes** (death often leaves no clean JSONL error line; the message goes to the now-gone pane).

**Why they didn't just use `CLAUDE_CONFIG_DIR` (which auto-refreshes via its refresh token):** deliberate — `agents.ts:50` comment: token injection "keeps the default config dir so MCP/hooks/skills stay intact." `CLAUDE_CONFIG_DIR` only relocates `.credentials.json`; **MCP servers / hooks / skills live in `~/.claude`** and would be LOST if pinned to an alt dir (confirmed via docs). Plus a multi-agent-same-dir single-use-refresh-token race.

**Fix (recommended, preserves the default-config-dir design):** mint a per-account long-lived token via `claude setup-token` (run once per account, e.g. `CLAUDE_CONFIG_DIR=~/.claude-<acct> claude setup-token` — INTERACTIVE, owner-only), store it in `auth-plans.json` as a new `spawnToken` field, and have `spawnAgent` inject THAT instead of the ephemeral accessToken. Keep `dir` for the usage probe (its auto-refreshing creds are correct there). Badge stays correct for free because the setup-token never rotates + `recordPinned(spawnToken→name)` from `00f4183` recalls it. Fail-loud (refuse to spawn-pin) if no `spawnToken` rather than silently injecting a doomed ephemeral token.

Tags: brew-ops, repo:cross, fleet, account-pinning, oauth, token, claude-code, gotcha. Source: oracle-studio server/{agents,usage,plan-detect}.ts @ HEAD 00f4183 + ~/.claude/.credentials.json model + claude-code-guide docs verification 2026-06-20.

---
*Added via Oracle Learn*
