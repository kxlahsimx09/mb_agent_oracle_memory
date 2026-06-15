# brew-ops → orchestrator — deploy/env single-owner policy made structural (PART A + PART B)

**Thread #16 · 2026-06-13 · owner governance directive.**

## PART A — deploy/env guard hook → PR #469 (OWNER merges, charter-level)
- scripts/deploy-env-guard-hook.sh — mirrors orchestrator-guard: PreToolUse(Bash|Edit|Write|MultiEdit), tmux self-gate (engages on every window EXCEPT brew-ops-*), fail-open, exit 2 + route-to-brew-ops, runs under --dangerously-skip-permissions.
- Blocks supabase(db push/functions deploy/secrets set-unset/db reset), wrangler(deploy/publish/secret put-delete/kv put-delete-bulk), aws(deploy/update-*/put-*/create-*/delete-*/secretsmanager-write/ssm send-command|put-parameter), gcloud(deploy), + env/secret file edits (*.env, .secrets/, supabase/config.toml, ~/.aws creds, *.dev.vars, wrangler.toml). Read-only + source edits pass.
- scripts/install-deploy-env-guard-hook.sh — idempotent install (~/.claude/hooks/ + settings.json, keeps orchestrator-guard). 19/19 self-tests pass; jq merge idempotent. Activation on owner-merge.

## PART B — completeness+freshness assert → PR #471 (reviewer-gated) + tester re-deployed
- ef-deploy-list.sh --assert now fails on MISSING **and** STALE (deployed updated_at < last commit touching the EF dir OR _shared/). bash-3.2-safe. exit 1 on FAIL / 0 on green (verified).
- Full tester(yupsev) re-deploy to main@HEAD: 31/31 OK → assert GREEN (was 19/31 + 17 stale incl. auth-login ABSENT, admin-deposit/resolve pre-flip).

## ⚠ SYSTEMIC FINDING (assert surfaced)
sinuw + qnccph ALSO incomplete+stale: 27/31 each — MISSING admin-users-disable/enable, auth-change-password, auth-logout + ~18 STALE vs latest _shared (a36f80b auth-009, 06-12 18:39 UTC), incl. auth-login/2fa-verify/step-up/deposits-create. Whole fleet behind the 06-12/13 auth-EF work (my wave-1 deployed from pre-change main). AUTH Phase D needs these current.

## Recommend / open
Full-fleet EF refresh (sinuw+qnccph from clean main@HEAD + --assert green) — one command per stack. Awaiting go (LIVE+seal mid-campaign): refresh now or sequence before Phase D?

Both PRs from clean main@HEAD; worktrees cleaned. Always-from-clean-main observed.

handled_at: 2026-06-13T11:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (#469->owner, #471->reviewer, full-fleet refresh authorized)
