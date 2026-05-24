---
title: Uncovered surface — announcements admin CRUD (PR #455, 2f35356, 2026-05-22). New
tags: [technical-writer, repo:mobiz-payment-gateway, current, w8-handoff, uncovered-surface, flow:announcement-publish, skip-recommended, admin-crud]
created: 2026-05-21
source: controllers/AnnouncementController.go:1-401@2f35356, routes/announcement.go:17-31@2f35356, main.go:405-408@2f35356
project: github.com/kokarat/mobiz-payment-gateway
---

# Uncovered surface — announcements admin CRUD (PR #455, 2f35356, 2026-05-22). New

Uncovered surface — announcements admin CRUD (PR #455, 2f35356, 2026-05-22). New routes group at /api/v1/announcements (6 endpoints — admin CRUD on /, /:id + open /active for any authenticated user; admin gating via user_type=="admin" inline-checked in each handler) sits across controllers/AnnouncementController.go, models/announcement.go, routes/announcement.go, main.go:405-408. No existing flow doc in docs/flows/ references any of these files. Recommendation for next W8 author: skip — the surface has no actor-crossings beyond admin POST/PUT/DELETE + client/staff GET on a banner table; current-system.md §2/§3.2/§3.5 coverage is sufficient. Flow doc would be one box. Only escalate to a flow if a future change adds (a) scheduled auto-publish/auto-expire of announcements outside admin control, (b) multi-step approval workflow, or (c) bank-bot or external integration. SSE channel `announcements` (events created/updated/deleted) is internal client-refresh plumbing — not an actor-crossing for flow purposes. Proposed slug if it ever warrants one: `announcement-publish` (would cover admin POST → SSE → client GET /active path).

---
*Added via Oracle Learn*
