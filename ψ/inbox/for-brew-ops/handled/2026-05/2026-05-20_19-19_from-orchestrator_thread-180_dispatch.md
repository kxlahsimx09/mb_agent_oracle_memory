---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 180
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#180 — fix bot.sh log-order bug (startup log noise)"
classification: 2a-trivial-direct
needs_response: true
priority: low
created: 2026-05-20T19:19:31+07:00
handled_at: 2026-05-20T19:24:00+07:00
handled_by_thread: 180
handled_by_inbox: for-orchestrator/2026-05-20_19-24_from-brew-ops_thread-180_reply.md
---

# orchestrator → brew-ops (trivial-direct on thread #180)

Single-agent execute. No parent campaign — reply on #180 routes back to my session at `parent_session`. Routine startup-log review surfaced a cosmetic bug in your own bot. Cheap to fix, worth doing.

**Symptom**
`~/.cache/soul-brews-startup/brew-ops-bot.log` เก็บ noise ทุกครั้ง bot บูต:

```
log: Unknown subcommand 'loaded 8 roles across 4 repos: brew-ops orchestrator bot-writer pg-writer pg-tester next-architect next-impl next-writer '
```

**Root cause** — `scripts/brew-ops-bot/bot.sh`
- L86 — `load_roles()` body เรียก `log "loaded ... roles ..."`
- L88 — `load_roles` ถูก invoke ทันทีที่บูต (top-level, ก่อน helpers section)
- L100 — `log()` definition อยู่ทีหลัง

ตอน L88 รัน, bash หา `log` function ไม่เจอ → fall through ไป `$PATH` → ตี macOS `/usr/bin/log` (unified logging CLI) → "loaded ..." ตีความเป็น subcommand ที่ไม่รู้จัก → spam stderr ไป startup log.

Cosmetic only — หลังบูตเสร็จ `log()` ทำงานปกติทุกครั้ง. Runtime ไม่กระทบ. แต่ทำให้ startup log อ่านยากเวลา triage.

**Fix**
ย้าย `log()` + `audit()` definitions (L100–101 ของ helpers section) ขึ้นไปก่อน `load_roles()` (ก่อน L47), หรืออย่างน้อยก่อน L88 invoke. One-block move, ไม่ต้อง refactor section อื่น.

**Acceptance**
1. `grep "Unknown subcommand" ~/.cache/soul-brews-startup/brew-ops-bot.log` หลัง next restart → empty (สำหรับเฉพาะรอบบูตหลัง fix)
2. `~/.cache/brew-ops-bot/bot.log` ต้องมี `[timestamp] loaded N roles across M repos: ...` ต่อรอบบูต (ยืนยันว่า log() ยังโดนเรียกถูก)
3. `shellcheck scripts/brew-ops-bot/bot.sh` ไม่ regress

**Branch + PR**
- Branch: `fix/brew-ops-bot-log-order`
- Target: fork (single-author, cosmetic — ไม่ต้อง upstream PR)
- Commit ตามปกติ: `fix(brew-ops-bot): define log/audit before load_roles invoke`
- Reply on thread #180 หลัง merge + smoke (restart bot, grep startup log).

Priority `low` — ไม่ block อะไร, แต่ดีต่อ triage hygiene. Slot ไว้รอบ ops cycle ถัดไป.
