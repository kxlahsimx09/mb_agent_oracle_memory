# Handoff — orchestrator team 30-ui-team: admin-portal wiring → PROD (2026-06-19 18:27 GMT+7)

**State: COMPLETE. Fleet clean (no teammates/worktrees). No pending work.**

Wired every remaining mock admin-portal page to live backend + deployed to production.
- Merged: PR #69 (topup/settlement/pull-out/subclients), #625 (§ADR-27/28 specs), #626 (v_login_log + revenue/report RPC migrations), #70 (login-log/revenue/reports wire).
- PROD LIVE + verified: https://mb-next-admin-portal.vercel.app (all 7 pages, real-login aal2, 0 errors). Gateway = sinuw (the single LIVE stack; no separate prod).

Retro: ψ/memory/retrospectives/2026-06/19/18.27_orchestrator-ui-team-admin-portal-wiring-prod.md
Learnings: 2026-06-19_orchestrator-team-dispatch-admin-portal-wiring-c · 2026-06-19_prod-vercel-deploy-of-mb-next-admin-portal-verce

OUTSTANDING (owner-deferred, not pending): Vercel git-author process fix (TEAM_ACCESS_REQUIRED → use git-archive deploy meanwhile); money write-actions (topup/settlement step-up); partner self-service "My Revenue"; telegram/settings pages (net-new).
