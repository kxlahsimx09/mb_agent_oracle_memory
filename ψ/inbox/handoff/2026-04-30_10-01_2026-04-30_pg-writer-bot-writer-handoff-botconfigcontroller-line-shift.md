# Handoff to bot-writer — BotConfigController.go line-shift from mobiz b23a903

**From:** pg-writer (mobiz-payment-gateway W2 pass, 2026-04-30 GMT+7)
**To:** bot-writer (next W9 / flow-doc maintenance pass)
**Type:** Sibling-flow-doc citation case — pg-writer side per workflow-2-track-commit.md §Sibling-flow-doc citation case (no defer).

## Context

mobiz commit `b23a903` (PR #336, "Pullout DestCap: pre-credit dest + reserve settled-unsynced", landed 2026-04-29) modifies `controllers/BotConfigController.go` inside `UpdateBankBalance` (`PUT /api/v1/bot/balance`). The change adds a settled-unsynced inbound reservation alongside the existing pending reservation in the auto-pullout-trigger headroom check. ~+8 lines added at the pre-change line range 468-490.

## Why this is a handoff to you

`BotConfigController.go` is cited from three bank-bot flow docs (Implementation pointers / `// ext: kokarat/mobiz-payment-gateway`):

1. **`docs/flows/bot-bootstrap-and-status-reporting.md`** — cites `BotConfigController.go` for `getBotConfig` (no specific line range mentioned in citation; semantic content unchanged).
2. **`docs/flows/bot-otp-relay.md`** — cites lines `119-165` (GetOTP), plus `134-141`, `140-145`, `284-286` for OTP filter / TTL details. **All cited regions are above the modified region — no line shift to these citations.**
3. **`docs/flows/deposit-auto-match-from-statement.md`** — cites lines `494-640` for bank-statement ingest + dedup + async matcher kick (called `getBotConfig:494-640` style). **The +8-line addition inside `UpdateBankBalance` (~line 468-490) shifts this citation: line 494 in the pre-change file is now ~line 502.**

Semantically, none of the cited regions changed behavior. The deposit-auto-match flow is a pure citation line-shift drift.

## What you should do on next pass

1. Pull mobiz HEAD (`59bc640` or later) into your read-only checkout.
2. Re-resolve `controllers/BotConfigController.go` line ranges in `docs/flows/deposit-auto-match-from-statement.md`. Expected new range for the bank-statement ingest block: `~502-648` (verify against actual HEAD of mobiz-payment-gateway).
3. Update Implementation pointer with fresh `@<short-hash>` citation.
4. No semantic change to any flow doc — this is a line-shift-only drift.

## Trace pair

- pg-writer W2 trace: `d525a840-17a1-4ec7-aece-f60cd3cd54c4` (this pass, mobiz `a8fb64e..59bc640`)
- bot-writer most recent W2 trace: `ed040637-36ba-4e67-ad2d-6dd481029235` (2026-04-28, bank-bot `b74e745..4b968a4`) — older than 24h, so no temporal sibling chain. The handoff is the linkage.

## Cross-repo-sync learning

Filed at `github.com/kokarat/mobiz-payment-gateway/ψ/memory/learnings/2026-04-30_cross-repo-sync-mobiz-b23a903-336-pullout-dest.md` (id `learning_2026-04-30_cross-repo-sync-mobiz-b23a903-336-pullout-dest`).

## Priority

P3 — line-shift drift only, no semantic change. Pick up on next regular bot-writer pass; not urgent.
