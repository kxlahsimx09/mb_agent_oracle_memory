---
title: Flow `deposit-slip-upload-admin-approve` Step 7 drift extension: the override-co
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, flow:deposit-slip-upload-admin-approve, step:7, force-approve, user_type]
created: 2026-05-02
source: docs/flows/deposit-slip-upload-admin-approve.md
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow `deposit-slip-upload-admin-approve` Step 7 drift extension: the override-co

Flow `deposit-slip-upload-admin-approve` Step 7 drift extension: the override-contract evolution acquired a fourth axis at f89e235 #369. Prior to this commit, the doc claim was "caller `user_type ∈ {admin, super_admin}`" — already partially off (super_admin is an RBAC role, not a user_type value) and still backed by an RBAC role-list check in code. f89e235 switched the helper `isAdminWithForceApprove` from `c.Locals("roles").([]string)` loop testing `helpers.RoleAdmin`/`helpers.RoleSuperAdmin` to `c.Locals("user_type").(string) == "admin"`, capturing every admin-class staff member (CS, finance, manager, super_admin) regardless of specific RBAC role.

Code is now at controllers/DepositController.go:2285-2308@f89e235; flow pointer remains at `:2295-2306@8b94f05` per W9 Class C convention to preserve the verification-gap signal. Doc claim text rewritten in the same edit pass to "user_type == admin (single value)"; the prior "user_type ∈ {admin, super_admin}" wording marked SUPERSEDED inline.

Open scope for W4/W8: §Error paths and §Sequence diagram still don't describe (a) any of the three pre-paid fraud-block branches (bot-path lockout, receiver-mismatch, V1 hash-collision) and (b) the override path now carries this fourth axis (gate dimension switched from RBAC role to user_type). The drift first noted at the W9 amend on 2026-05-02 03:00 (covering #360 + #361) and extended on 2026-05-02 05:45 (covering #362 + #364 + #366 + #367) now extends once more for #369. Still queued for a W8 revision rather than a piecemeal W9 fix because the §Sequence diagram needs new branches and the §Error paths section needs four new entries — neither can be authored in W9 scope.

Production trigger that motivated f89e235: deposit DEP1777694125YFE422 (2 พ.ค. 2026) — a CS user with role=cs and user_type=admin could not clear the V2 receiver-mismatch banner with `[force-approve]` until the same account was also granted super_admin role. Switching to user_type captured the case; same call succeeds without role change after f89e235.

---
*Added via Oracle Learn*
