---
title: force-approve override gate switched from RBAC role list to JWT user_type=admin 
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, slip-fraud, rbac, force-approve, user_type, decision]
created: 2026-05-02
source: controllers/DepositController.go:2285-2308@f89e235
project: github.com/kokarat/mobiz-payment-gateway
---

# force-approve override gate switched from RBAC role list to JWT user_type=admin 

force-approve override gate switched from RBAC role list to JWT user_type=admin (mobiz f89e235 #369, 2026-05-02). Initial widening at 8b94f05 #367 changed `super_admin` only → `admin` or `super_admin` but kept the same shape — a loop over `c.Locals("roles").([]string)` testing each entry against `helpers.RoleAdmin` / `helpers.RoleSuperAdmin`. Front-line CS staff hold RBAC `role="cs"` while still sitting under `user_type="admin"`, so the role check still rejected them. Production trigger: deposit `DEP1777694125YFE422` (2 พ.ค. 2026) — CS user with `[force-approve]` in notes hit the V2 receiver-mismatch banner; same account succeeded only after being granted `super_admin`.

Fix at `controllers/DepositController.go:2303-2308@f89e235` reads `c.Locals("user_type").(string)` instead and returns `userType == "admin"`. The `[force-approve]` substring requirement is unchanged. The function is shared by V1 (#362) and V2 (#360), so both fraud paths now accept any admin-class staff (CS, finance, manager, super_admin) regardless of the specific RBAC role they were assigned. Customer-facing tokens (`user_type ∈ {client, sub-client, partner, merchant}`) and bot tokens (BotAuthMiddleware doesn't populate user_type) cannot bypass.

Why this matters going forward: the override-eligibility contract is now anchored on the staff-vs-customer JWT distinction, not on a small set of role names. Adding a new admin-class role (e.g. role="risk-ops") no longer requires a code change — provisioning the user with `user_type=admin` is sufficient. The marker requirement and the audit-log entries (`[Deposit] FRAUD OVERRIDE` / `[Deposit] FRAUD BLOCK`) remain the accountability surface.

Two prior W2 layers SUPERSEDED in `docs/current-system.md` §3.2: "super_admin only" (ef71420) and "admin or super_admin role" (8b94f05). The current-system row now describes the user_type gate as the live behaviour and lists both prior wordings as superseded.

Note: the squash-merge of #367 dropped the author's own follow-up commit 2efed09 which had already made this fix on the PR branch — #369 is the re-application against current main. Operational lesson recorded for future PR-review timing: a follow-up pushed during squash-prep can be lost.

---
*Added via Oracle Learn*
