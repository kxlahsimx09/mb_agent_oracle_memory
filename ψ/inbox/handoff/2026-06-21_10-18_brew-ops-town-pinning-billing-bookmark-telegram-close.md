---
from: brew-ops
date: 2026-06-21T10:16:00+07:00
topic: Fleet Town account-pinning saga (badge→BILLING), bookmark/respawn, Telegram alerts, + 401 fleet recovery — session CLOSE
status: ALL 6 PRs MERGED + DEPLOYED LIVE; fleet clean; one owner-gated follow-up
tags: [#repo:cross, #fleet, #fleet-town, #brew-ops, #account-pinning, #oauth, #billing, #notifications, #incident, #handoff]
---

# Handoff → next session (brew-ops): Town pinning/billing + bookmark + telegram CLOSE

**Full retro:** `ψ/memory/retrospectives/2026-06/21/10.16_brew-ops-town-pinning-billing-bookmark-telegram.md`
**State carrier:** auto-memory `town-pinned-recall-and-agent-resume.md` (has every detail + the 401 incident + the billing fix).

## SHIPPED this session — all MERGED + DEPLOYED LIVE (oracle-studio = ui-studio-oracle-studio fork; deploy = ff-resync primary + `vite build` + `systemctl restart fleet-town.service`)
- **#16 (the big one) — billing fix**: pinning now uses `CLAUDE_CONFIG_DIR=<plan.dir>`, NOT `CLAUDE_CODE_OAUTH_TOKEN`. Reason: the env token only sets `claude auth status`/the BADGE; actual inference BILLS whatever `CLAUDE_CONFIG_DIR`'s `.credentials.json` holds. Old token-pin → every "MaxpayPlus" agent billed the DEFAULT (midasgo). Proven via `strace -f -e openat` (token+default-dir reads midasgo creds 7×/maxpay 0×; config-dir reads maxpay 23×/0×). `server/account-dirs.ts ensureAccountDir()` replicates shared MCP(from ~/.claude.json)+hooks(symlink)+settings.hooks AND pre-sets `skipDangerousModePermissionPrompt`(settings.json) + repo-parent `hasTrustDialogAccepted`(.claude.json) so fresh dirs boot-to-work (else they HANG at the Bypass/trust prompt). Worktrees inherit parent-repo trust.
- **#12** setup-token pin (badge-survives-rotation) · **#13→#14** live-tester ⓘ info from canonical `live-test-info.json` (pg #657, Thai) · **#15** 🔖 bookmark+respawn agent (maw wake --wt, no --fresh, re-pin account) · **#17** ✈️ Telegram alerts (same server notify loop fires team-idle/agent-waiting to a chat; UI token+chatId; works web-closed; `~/.fleet-town/telegram.json` chmod600, token write-only).
- **maw-js #21** — orchestrator-spawned teammates inherit the orchestrator's pinned account (walk /proc ancestry; ACCOUNT_ENV_KEYS already includes CLAUDE_CONFIG_DIR → composes with #16, no maw change needed).

## OWNER-GATED FOLLOW-UP (deferred to avoid disrupting active work)
- Agents spawned BEFORE #16 deploy are still token-pinned → **still billing midasgo until RESPAWNED** on the config-dir pin. To switch them: 🔖 bookmark→respawn (now pins config-dir), or respawn orchestrators (maw-wake, --continue) + let them re-dispatch teammates. Team-spawned teammates can't be in-place resumed (pane dies on kill) — recover via their orchestrator.

## KEY GOTCHAS (durable)
- **badge ≠ billing**: never trust the town badge as proof of which account bills. Verify with strace-on-inference, not `claude auth status` (different credential path).
- **401 wave incident (17:49 06-20)**: root cause = account-side (maxpayplus1) session invalidation, NOT `/login` (which was 10min later, on a different account, and token-pinned agents don't even read that creds file). I misdiagnosed twice — check 401 TIMESTAMPS before blaming a coincident transcript event.
- **auth-plans.json**: put a setup-token in `spawnToken` (NOT `token`) or the usage panel 403s (setup-tokens lack the usage scope) → blank usage even while billing. Pasted tokens can carry a literal newline → JSON corruption.
- Notifications are SERVER-side (`fleet-town.service` notify loop, 8s tick) → fire even with web closed; Telegram now rides the same loop.

## Fleet state at close: clean (no leftover feature worktrees/branches; test agents cleaned up). fleet-town.service live (pid 1554056 at close), clean boot.
