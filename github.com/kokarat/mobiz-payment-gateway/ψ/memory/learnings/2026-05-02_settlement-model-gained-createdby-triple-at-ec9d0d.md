---
title: Settlement model gained CreatedBy triple at ec9d0d7 (#374, 2026-05-02). `models.
tags: [technical-writer, repo:mobiz-payment-gateway, current, settlement, audit-trail, created-by, ec9d0d7, pr-374]
created: 2026-05-02
source: models/settlements.go:46-55@ec9d0d7 + controllers/SettlementController.go:307-346@ec9d0d7
project: github.com/kokarat/mobiz-payment-gateway
---

# Settlement model gained CreatedBy triple at ec9d0d7 (#374, 2026-05-02). `models.

Settlement model gained CreatedBy triple at ec9d0d7 (#374, 2026-05-02). `models.Settlements` now carries `CreatedBy primitive.ObjectID`, `CreatedByUsername string`, `CreatedByType string` (admin / client / partner / sub-client). All three `bson:"omitempty"`. Sister fields to the pre-existing `ApprovedBy*` triple. Populated in `SettlementController.CreateSettlement` from `c.Locals("user_id"|"username"|"user_type")`. Empty user_id (legacy / unauthenticated test paths) leaves the ObjectID zero rather than failing the create — matches the existing approve-flow fallback. Drives an upcoming Settlement page UI change to show "Requested: <user>" alongside the existing entity_name + ApprovedByUsername; without these, only the entity (client / partner) was attributable and admins couldn't tell which staff member or sub-user actually filed the settlement. Frontend rendering is a separate PR.

---
*Added via Oracle Learn*
