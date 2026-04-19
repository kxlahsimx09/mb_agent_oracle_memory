---
title: BOT_SECRET in bank-bot/.env.example is a placeholder (dev-confirmed 2026-04-17)
tags: [technical-writer, repo:bank-bot, current, security, env, thread-resolved, placeholder]
created: 2026-04-18
source: .env.example@2774dab + arra_thread:3 + docs/current-system.md §9a
project: github.com/kokarat/bank-bot
---

# BOT_SECRET in bank-bot/.env.example is a placeholder (dev-confirmed 2026-04-17)

BOT_SECRET in bank-bot/.env.example is a placeholder (dev-confirmed 2026-04-17)

**Why:** During W1 baseline at `95dbb70`, `docs/current-system.md` flagged the 64-char hex `BOT_SECRET` in `.env.example` as ambiguous (U-1) per the workflow's credential-escalation clause. Dev confirmed in Oracle thread #3 that the value is a placeholder — no live production secret is checked in. U-1 moved from §9 (Known unknowns) to §9a (Resolved questions) per P-001.

**How to apply:**
- Future W1/W2/W4 passes must not re-open this question; treat `.env.example` `BOT_SECRET` as a known placeholder unless the hex value changes and dev is re-asked.
- Any future review that spots a "real-looking" hex in `.env.example` should check the git history of that file first — if the value is unchanged from `7d4b50e`, it is the already-confirmed placeholder.
- If `.env.example` ever adopts a more obvious placeholder (`changeme`, `your-secret-here`), that is a separate cosmetic improvement, not a security event.

**Thread:** `arra_thread:3` — opened 2026-04-17 09:54 GMT+7, answered 2026-04-17 11:17 GMT+7 (human reply "ถาม dev มาแล้ว เค้าบอกว่า เป็นแค่ place_holder"), closed 2026-04-18 during W2 pass at `2774dab`.

**Trace chain:** W2 trace `c3d2a074-8cd3-4c54-89bf-4b4754787ae7` → child trace `e01f81fd-07c1-4666-a15d-50f9f1c7fa4d` (`thread 3 resolved`).

**Process note:** This thread was effectively-answered (`status="pending"` + last-message role `human`) since 2026-04-17. Workflow-2 Step 0 Pass 2's `arra_threads(status="answered")` filter returned 0 and missed it — consistent with the deployment quirk already documented in `workflow-thread-resolve.md` lines 94-104. Resolution ran mid-session when the human pointed it out. No new workflow-bug learning needed; the quirk is already captured.

---
*Added via Oracle Learn*
