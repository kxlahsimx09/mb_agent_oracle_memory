---
title: DEPLOYED + verified live (P-002): the wake_key-scoped §11l Stop hook is now in p
tags: [inbox-protocol, 11l, stop-hook, deploy, section-3c, wake-key, campaign-scope, brew-ops, fleet]
created: 2026-05-22
source: brew-ops / thread #214 (§3c deploy, 2026-05-22)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# DEPLOYED + verified live (P-002): the wake_key-scoped §11l Stop hook is now in p

DEPLOYED + verified live (P-002): the wake_key-scoped §11l Stop hook is now in production. #repo:arra-oracle-v3 #fleet #brew-ops #inbox #11l #decision

PR #88 merged @ `391420e` on `fork/feat/all-prs-rebased` (user-authorized). §3c deploy executed on the arra-oracle-v3 primary by brew-ops:
1. Verified primary clean on `feat/all-prs-rebased` + local HEAD `257ee58` is an ancestor of fork tip `391420e` (true fast-forward, §3c verify-before-discard passed — nothing to preserve).
2. `git -C <primary> fetch fork feat/all-prs-rebased && git merge --ff-only fork/feat/all-prs-rebased` → `257ee58 → 391420e`.
3. `bash scripts/install-inbox-loop-closure-hook.sh` → deployed to `~/.claude/hooks/inbox-loop-closure-hook.sh` (already registered in settings.json).
4. **No inbox-watcher restart** — #88's diff is 1 file (the hook, +57/−5); `inbox-watcher.sh` byte-unchanged, so the daemon (pid 52884) was left running and untouched. (The hook runs fresh per Stop; only watcher-CODE changes need the §3c.4 stop→start.)

**Verified LIVE** (smoke test against the deployed `~/.claude/hooks/` copy, not just the worktree): worker with only a sibling-campaign envelope → allow (exit 0), no cross-campaign mention (the original bug — GONE); orchestrator hub (sid spanning 2 wake_keys) → whole-dir block listing ALL campaigns (exemption holds). Deployed copy is byte-identical to the merged source; `in_scope()` present, orchestrator exemption present, the old false "this is expected, handle them" block text removed.

Completes [[2026-05-22_fix-implemented-unit-tested-awaits-user-merge]] (status: implemented→deployed) and [[2026-05-22_confirmed-diagnosis-p-002-observed-fix-proposed]]. The §11e sweep half (mb_agent_oracle_memory `17121f5`) was already live via the .agent symlink. Both surfaces now agree on the wake_key discriminator.

STILL-OPEN ADJACENT (NOT this fix): the multi-campaign hub still gets a duplicate orchestrator session minted per reply when reply-routing mis-takes the "owner worktree gone → --fresh + ownership-transfer" branch on a *live* hub (orchestrator wt-12 msg 927: #214 owner was rewritten wt-5→wt-12 despite wt-5 alive). §151/§11f watcher-side issue, adjacent to but not solved by the §214 orchestrator-exempt carve-out — candidate for a follow-up thread.

---
*Added via Oracle Learn*
