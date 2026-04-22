---
title: maw wake's send-keys path truncates long multi-line prompts (Thai/HTML-heavy, ~6
tags: [brew-ops, repo:cross, fleet, mcp-tools, gotcha, maw-wake, silent-failure, send-keys, 2026-04-22]
created: 2026-04-22
source: commits 98ad1d6 (investigation wake fix) + 2769ed8 (watcher wakes fix) on arra-oracle-v3 feat/all-prs-rebased-2026-04-20 branch; live observations 2026-04-21 14:09 + 2026-04-22 01:27-02:30
project: github.com/soul-brews-studio/arra-oracle-v3
---

# maw wake's send-keys path truncates long multi-line prompts (Thai/HTML-heavy, ~6

maw wake's send-keys path truncates long multi-line prompts (Thai/HTML-heavy, ~600+ bytes). maw's internal "DONE" end-sentinel leaks mid-string, leaving zsh stuck at `cmdand cursh quote>` — claude never starts. But `maw wake` exits 0 (it successfully send-keys'd something), so callers' `if maw wake ...; then log success` runs the success path on silent failure.

**Fix: file-pointer pattern.** Write the full prompt to a file, send maw a short 1-line ASCII-only pointer:

```bash
PROMPT_FILE="$STATE_DIR/wake-prompts/<role>-<ts>.md"
printf '%s\n' "$long_prompt" > "$PROMPT_FILE"
WAKE_POINTER="อ่าน $PROMPT_FILE ให้จบก่อน — นั่นคือ task ของคุณ ครบทุกบรรทัด. ทำตามคำสั่งในไฟล์ทั้งหมด ห้ามข้าม."
maw wake <role> --fresh "$WAKE_POINTER"
```

**Why:** Keeps send-keys payload < 200 bytes ASCII, robust across shell parsers. Claude reads the file as its actual task.

**Bonus:** prompt file persists, reviewable/replayable — operator can rerun manually by `cd worktree && claude -p "$(cat <file>)"`.

**Observed sequence:**
- 2026-04-21 14:09 — regression investigation wake truncated at `test-deposit-collisiDONE`
- 2026-04-22 01:27/02:30 — pg-writer + bot-writer overnight wakes both truncated at `ให้ log ใน retro DONE` / `retro แล้วจDONE` → no W2/W9 ran all night, no Telegram

**Applied in:**
- `arra-oracle-v3/scripts/regression-then-investigate.sh` (investigation wake — commit `98ad1d6`)
- `arra-oracle-v3/scripts/w2-watcher.sh` (all 3 role wakes: pg-writer/bot-writer/pg-tester — commit `2769ed8`)

**Related upstream:** Different from the 2026-04-19 maw wake/hey hardening bundle (that one fixed shell-quoting in wake.ts). This is a send-keys payload-length + sentinel-leak issue in maw-js's pane communication path — worth a separate maw-js fix eventually. For now, consumer-side file-pointer workaround is durable.

**How to apply:** Any bash script calling `maw wake --fresh` with a long Thai/HTML/multi-line prompt. If the prompt is more than ~200 bytes or contains non-ASCII, use file-pointer. Short ASCII "run X" prompts stay inline fine.

---
*Added via Oracle Learn*
