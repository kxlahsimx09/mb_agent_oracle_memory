---
title: **orchestrator dispatch — procedure violation: skipped Step 1 + 2 on cosmetic bu
tags: []
created: 2026-05-20
source: parent thread #180 — orchestrator dispatch to brew-ops, user redirected mid-dispatch to read SKILL (2026-05-20 19:19 GMT+7)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **orchestrator dispatch — procedure violation: skipped Step 1 + 2 on cosmetic bu

**orchestrator dispatch — procedure violation: skipped Step 1 + 2 on cosmetic bug fix to brew-ops, user redirected to SKILL (2026-05-20)**

Request: user said "ช่วย สั่ง brew-ops ให้แก้เรื่องนี้" — fix `bot.sh` log-order bug (`log()` defined at L100, called from `load_roles()` at L86, invoked top-level at L88 → falls through to macOS `/usr/bin/log` → "Unknown subcommand" noise in startup log).

**What I did wrong:**
1. Sent `telegram_send` first — wrong channel; Telegram is human↔bot, not agent↔agent.
2. After user corrected ("ใช้ thread inbox") I built an envelope but skipped Step 1 (memory refresh) and Step 2 (explicit classification).
3. Set `parent_thread: 180` on the envelope when classification was clearly 2a-trivial-direct (single agent, no aggregation needed) — SKILL workflow §2a says `parent_thread` field **omitted** for 2a.
4. Created parent thread #180 unnecessarily; 2a-trivial-direct skips parent thread entirely per workflow.

**User reaction:** `corrected` — pointed at SKILL and said "ลองอ่าน SKILL ของ role orchestrator ว่าควรจะปรับยังไงให้ dispatch ได้ถูกวิธี". This is the load-bearing signal: skipping the SKILL workflow is not tolerated even when the dispatch content is correct.

**Classification (after refresh):** 2a-trivial-direct (HIGH confidence — ≥3 prior 2a-accepted patterns for brew-ops cosmetic/audit dispatches: thread #116 fleet-purge, #156 fleet-debug, #158 audit).

**Outcome of correction:** envelope edited in-place to drop `parent_thread`/`parent_oracle`, added `classification: 2a-trivial-direct` field, kept `parent_session` (mandatory per §151). Awaits brew-ops reply on #180.

**Lesson (binding for future runs):**
- **Step 1 memory refresh is not optional even on requests that "seem trivial".** The 5 queries (`arra_search` × 3, `maw oracle ls`, `arra_threads`) take ~30 seconds and surface decision-authority confidence. Skipping them is the recurring failure mode the SKILL was written to prevent.
- **Classify explicitly before writing any envelope.** Label as 2a/2b/2c/2d in plain text in the dispatch announcement. The classification controls envelope shape (parent_thread present/omitted, parent thread opened/skipped, daemon active-thread update).
- **Read the SKILL + workflow-1-dispatch when in doubt about envelope structure** — examples in `for-<role>/handled/` are valid but variable; the SKILL is canonical.
- **Telegram is for narration to the user, not dispatch to agents.** If asked "tell <agent> X", the answer is always: inbox file. Telegram is downstream (chat-watcher pushes parent-thread messages).</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "2a-trivial-direct", "corrected", "procedure-violation", "skipped-memory-refresh", "skipped-classification", "envelope-shape", "brew-ops", "bot.sh-fix", "thread-180", "channel-confusion-telegram-vs-inbox"]

---
*Added via Oracle Learn*
