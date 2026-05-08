---
title: blacklistAutoDetect.go: extractRecipientName + mightHaveTitle silent-fail repair
tags: [technical-writer, repo:mobiz-payment-gateway, current, blacklist, regex, post-deploy-fix]
created: 2026-05-07
source: services/blacklistAutoDetect.go:1-371@06ce544
project: github.com/kokarat/mobiz-payment-gateway
---

# blacklistAutoDetect.go: extractRecipientName + mightHaveTitle silent-fail repair

blacklistAutoDetect.go: extractRecipientName + mightHaveTitle silent-fail repair AND titleRegex full-word + start-anchor extension (18f6917 #418 + 06ce544 #419, 2026-05-07).

PR #401 (blacklist auto-detect, 7c8033b 2026-05-05) silently rejected EVERY titled depositor for ~36 hours after deploy. Two helper functions assumed a description shape production never sees.

Root cause #1 — extractRecipientName. Split on the first space, expecting "x1234 NAME". KTB/SCB inbound rows are "รับโอนจาก KBANK x3782 ด.ญ. สุวนีย์ นุชรุ" — first-space split returned "KBANK x3782 ด.ญ. ..." (Latin first byte).

Root cause #2 — mightHaveTitle. The 1-byte UTF-8 sniff at byte 0 (looking for the Thai 0xE0 lead byte) tripped on the Latin "K" of "KBANK x3782 ..." and rejected the row before the full regex ever ran. ~95% rejection rate originally claimed; in practice it was 100% rejection on KTB/SCB inbound and on KTB outbound that emit "TR to KTB x1234 พระ ..." — both have a Latin prefix.

Confirmed via repro on real production samples: 0 blacklists created/updated in the last 24h despite 136 bank_statements with matched_request_id and a Thai honorific in description.

Fix in 18f6917 #418:
- new package-level regex `recipientAfterMaskedAccount = /x\d{3,}\s+(.+)$/` — matches everything after the masked-account token "x{4+ digits} ". `extractRecipientName` tries this first, falls back to first-space split for legacy "x1234 NAME" shapes.
- `mightHaveTitle` now scans the FIRST 32 BYTES for any 0xE0 lead byte (was: byte 0 only). Names retaining a Latin bank-code prefix still pass; the budget remains microseconds per call.

Categories extension in 06ce544 #419:
- titleRegex anchored at `^(...)` — RE2 only tries position 0 instead of every byte, faster and prevents mid-string surnames like "น.ส. อังคณา พระสว่าง" from tripping the alt `พระ[ก-ฮ]` and getting flagged as `category=other` by classifyTitle.
- Full-word ranks added: army (ร้อยตรี/ร้อยโท/ร้อยเอก, พันตรี/โท/เอก, พลตรี/โท/เอก, จ่าสิบเอก/โท/ตรี, สิบเอก/โท/ตรี); police (ร้อยตำรวจ/พันตำรวจ/พลตำรวจ/สิบตำรวจ/จ่าสิบตำรวจ/ดาบตำรวจ); navy (เรือตรี/โท/เอก, นาวาตรี/โท/เอก, เรืออากาศ, นาวาอากาศ); monk + พระมหา. classifyTitle per-category regexes were extended in lock-step so new matches land in the correct category instead of `other`.

Together these are the post-deploy correction for the silent rejection found ~36h after #401 went live. After both PRs detection actually fires.

---
*Added via Oracle Learn*
