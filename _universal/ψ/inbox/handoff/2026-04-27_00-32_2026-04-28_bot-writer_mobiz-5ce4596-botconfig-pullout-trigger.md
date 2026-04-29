# Handoff to bot-writer — mobiz 5ce4596 BotConfigController.go update

**From:** pg-writer W2 pass 2026-04-28  
**To:** bot-writer  
**Priority:** low (no immediate doc update needed)

## What happened

mobiz commit `5ce4596` (#323, 2026-04-27) modified `controllers/BotConfigController.go` — specifically the `UpdateBankBalance` function's auto-pullout trigger section (lines ~430–540).

**Changes in 5ce4596 to BotConfigController.go:**
- Added `SumPendingPulloutAmountsToDest` (inbound reservation guard): before deciding pullout amount, now subtracts pending/processing inbound pullouts to the same destination. Prevents two balance-trigger pullouts firing close together from exceeding the DestCap.
- Added `PickRandomDestCap(refillCfg.DestCapMin, refillCfg.DestCapMax)`: cap is now randomly drawn from a [100k–120k] band per trigger instead of a fixed single value.

## Why this matters to bot-writer

The three bank-bot flow docs that cite `BotConfigController.go` are:
- `docs/flows/bot-bootstrap-and-status-reporting.md` → `getBotConfig` (unchanged)
- `docs/flows/bot-otp-relay.md` → `GetOTP`, `SaveOTPLog` (unchanged)
- `docs/flows/deposit-auto-match-from-statement.md` → `SaveBankStatements` (unchanged)

**None of these cited functions were modified by 5ce4596.** The `PUT /bot/balance` request/response contract is unchanged. No existing bot flow doc needs revision.

## Action needed

None immediately. However, if bot-writer ever authors a flow doc for the balance-trigger-pullout flow (the bot calls `PUT /bot/balance` → gateway fires auto-pullout when `PulloutTriggerEnabled + balance >= threshold`), that doc should reference the inbound guard (`SumPendingPulloutAmountsToDest`) and random cap band (`PickRandomDestCap`, defaults 100k–120k THB) that were added in `5ce4596`.

Cross-repo-sync learning filed on mobiz side: `2026-04-27_cross-repo-sync-no-bot-doc-update-needed-mobiz.md`