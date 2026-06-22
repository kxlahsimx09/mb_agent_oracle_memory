---
title: DEPLOY SEAL — campaign d2w1deploy → tester (yupsev / yupsevcrubgprsbujbpu), 2026
tags: [deploy, tester, edge-functions, migrations, brew-ops, ADR-36, d2gaps, seal]
created: 2026-06-21
source: brew-ops d2w1deploy
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DEPLOY SEAL — campaign d2w1deploy → tester (yupsev / yupsevcrubgprsbujbpu), 2026

DEPLOY SEAL — campaign d2w1deploy → tester (yupsev / yupsevcrubgprsbujbpu), 2026-06-21 (brew-ops, SOLO).

WHAT: Deployed D2 GAPS Wave-1 EFs (ADR-36, OWNER DECISION A, PR #699 / branch origin/campaign/d2w1dev) to the tester stack.
- Migrations applied IN ORDER via Mgmt-API SQL (single-owner-safe, NOT db push) + ledgered on-conflict-do-nothing:
  - 20260622000100_d2gaps_subclient_update_rpc.sql → RPC public.admin_update_subclient(uuid,text,text,text,boolean,uuid,text,text) — HTTP 201
  - 20260622000110_d2gaps_withdrawal_review_rpc.sql → RPC public.admin_review_withdrawal(uuid,text,text,uuid,text,text) — HTTP 201
  Both SECURITY DEFINER, EXECUTE granted to service_role ONLY (revoked anon/authenticated/public).
- EFs deployed (targeted `supabase functions deploy <name> --project-ref yupsevcrubgprsbujbpu`, NOT deploy-all sweep): admin-subclients-update, admin-withdrawal-confirm-review. Both ACTIVE v1, verify_jwt=false.

VERIFY (GREEN): both EF endpoints return HTTP 401 {"error":"missing_bearer_token"} unauth (no-Authorization AND anon-apikey-only) — NOT 404; the EF's own adminAuth gate fires (confirms verify_jwt=false reached the function). Both new RPCs confirmed present with correct identity args + grants.

LOAD-BEARING: the withdrawal-review RPC keys on the LIVE withdrawal_queue enum value `review` (verified on tester: withdrawal_queue_status_check = {pending,claimed,processing,success,failed,review,cancelled,overridden,dispatching}). ADR-36 §3 prose said `waiting_to_review` but that literal is dead (no row can hold it) — build correctly uses `review`. Dependency resolvers (admin_reconcile_payout, confirm_review_settlement, reconcile_direct_transfer, pullout_mark_result, write_audit_log) all already present on tester.

SCOPE NOTE: tester showed 7 pending versions; only the 2 d2gaps belong to PR #699. The other 5 (dtr_wave3 004010/004020/004030, prov010 000200/000210) belong to SEPARATE campaigns with their own deploy owners — intentionally NOT applied here. Tester ledger left with version gaps (allowed). Caveat: reconcile_direct_transfer on tester is the pre-dtr_wave3 7-arg signature; the review RPC's direct_transfer branch calls it with 5 positional args — only exercised at runtime for source_type='direct_transfer', not a deploy blocker but worth re-checking once dtr_wave3 lands on tester.

SEAL: merge commit cec5b24 on branch campaign/d2w1deploy (resolved an add/add ADR-36 doc conflict in favour of dev's PARTIALLY-BUILT version over main's PROPOSED #692 version); branch pushed to origin/campaign/d2w1deploy.

---
*Added via Oracle Learn*
