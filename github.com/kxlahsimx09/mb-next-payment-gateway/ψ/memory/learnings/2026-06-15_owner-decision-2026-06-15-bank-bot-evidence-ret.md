---
title: OWNER DECISION (2026-06-15): bank-bot evidence retention = INDEFINITE (no expiry
tags: [payout, supabase-storage, retention, pii, data-governance, owner-decision, deferred, project]
created: 2026-06-15
source: owner decision — retention deferred
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# OWNER DECISION (2026-06-15): bank-bot evidence retention = INDEFINITE (no expiry

OWNER DECISION (2026-06-15): bank-bot evidence retention = INDEFINITE (no expiry, no retention sweep) FOR NOW; the data-governance ADR (PDPA / AML, the gateway's first PII-at-rest store of real bank-slip images) is DEFERRED until there is real data to inform the policy ("เก็บไว้ไม่มีกำหนดก่อน เดี๋ยวค่อยมาแก้ทีหลัง ขอดู data จริงก่อน"). The bb2 Supabase Storage buckets (deposit-slips, bot-proof; PR #508) ship WITHOUT the SPEC §5 pg_cron retention sweep — it stays un-applied until a retention number is pinned. TRACKED FOLLOW-UP (not a blocker for the build): bank-slip + transfer-proof PII accumulates indefinitely → a growing PDPA/breach-liability surface; revisit the retention window + the data-governance ADR once real volume exists. Do not silently treat indefinite as permanent.

---
*Added via Oracle Learn*
