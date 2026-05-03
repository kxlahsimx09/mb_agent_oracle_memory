---
title: force-approve override extended from super_admin only to admin+super_admin (mobi
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, slip-fraud, rbac, force-approve, decision]
created: 2026-05-01
source: controllers/DepositController.go:2285-2306@8b94f05
project: github.com/kokarat/mobiz-payment-gateway
---

# force-approve override extended from super_admin only to admin+super_admin (mobi

force-approve override extended from super_admin only to admin+super_admin (mobiz #367, 8b94f05, 2026-05-02). PRs #360 and #362 introduced fraud-block defenses on DepositController.UpdateDepositStatus with a "[force-approve]" notes-substring escape hatch; both PRs gated the override on RoleSuperAdmin only. In practice front-line admin staff need to clear false positives in real time (e.g. the V1 fallback false-positive on DEP17776655127CL4Q0 from 2 พ.ค. 2026, fixed structurally in #366 the same day) and routing every override through a super_admin bottleneck doesn't match operational reality. Fix: extract isAdminWithForceApprove(c, notes) helper that gates on RoleAdmin OR RoleSuperAdmin, and reuse it from both V1 and V2 call sites — any future fraud variant added to UpdateDepositStatus automatically inherits the same role + marker contract. Audit logs always record the actor and notes string ([Deposit] FRAUD OVERRIDE / [Deposit] FRAUD BLOCK), so the override remains accountable. The role-widening choice is a security/UX trade-off whose durability comes from the operator-policy reasoning: the override is a TH/EN-translated pinch-point with full audit, not an unrestricted bypass.

---
*Added via Oracle Learn*
