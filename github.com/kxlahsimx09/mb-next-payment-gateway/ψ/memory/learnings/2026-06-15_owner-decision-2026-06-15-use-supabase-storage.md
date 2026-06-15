---
title: OWNER DECISION (2026-06-15): use SUPABASE STORAGE as the UNIFIED blob store for 
tags: [payout, proof-url, supabase-storage, blob-store, owner-decision, bank-bot, project]
created: 2026-06-15
source: owner decision — bb2proof
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# OWNER DECISION (2026-06-15): use SUPABASE STORAGE as the UNIFIED blob store for 

OWNER DECISION (2026-06-15): use SUPABASE STORAGE as the UNIFIED blob store for BOTH deposit slips AND payout proof/screenshot images ("slip ควรเก็บที่ supabase store, proof ก็ควรเก็บที่เดียวกัน"). This OVERRIDES the bb2gaps architect proof_url design (PR #504, docs/design/withdrawal-bot-lane/success-proof-url-contract.md), whose §ADR-6 T1 assumption was "NO Supabase Storage bucket, NO multipart-upload EF; bytes live in an external blob store/CDN". The next-gen gateway IS Supabase, so Supabase Storage is native + co-located (no separate AWS/S3). Implications: (1) there WILL be a Supabase Storage bucket; (2) the bot uploads the slip/proof image and passes the resulting URL to bot-transfer-proof (gateway still stores only the opaque URL pointer); (3) the bot-side byte→URL upload was NEVER built in #next — core/payout-marks.js:27 passes a file PATH (shotPath) into uploadScreenshot(queueId, screenshotUrl) which expects a URL, so error_screenshot_url would be a local path, not an uploaded URL (latent gap, surfaced by the owner's storage question). Build = bot-side Supabase Storage upload (capture → upload → URL) + the bucket + access pattern (recommend gateway-issued signed upload URL via createSignedUploadUrl so the bot doesn't hold a long-lived storage key). #current uploads bytes via multipart to the mobiz backend (core/api.js:93 → CDN); #next inverts this to bot-uploads-direct + gateway-URL-pointer.

---
*Added via Oracle Learn*
