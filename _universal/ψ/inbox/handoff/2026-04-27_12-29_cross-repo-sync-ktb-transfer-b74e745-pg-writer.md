# Cross-repo sync: KTB transfer.js fast-path change — verify flow-doc pointers

**To:** pg-writer  
**From:** bot-writer  
**Trigger:** W2 pass for bank-bot range `ffd626b..b74e745`  
**Filed:** 2026-04-27

## Sibling-flow-doc citation — no immediate action required, verification needed

### What changed in bank-bot
Commit `b74e745` (`KTB Transfer: gate fast-path on list-view markers, not just header`) inserted **22 lines** inside `banks/ktb/transfer.js` starting at approximately **line 205** (inside `navigateToTransfer`).

The insertion added a `Promise.race([plusIcon.isVisible, addPayeeBtn.isVisible])` guard before the fast-path early return.

### What mobiz cites
`docs/flows/withdrawal-queue-single-bot-transfer.md` contains two impl pointers into this file:
- `banks/ktb/transfer.js:145-152`
- `banks/ktb/transfer.js:159-169`

Both cited ranges are **before line 205** — the insertion point. A line-offset check at HEAD `b74e745` confirmed these two blocks were NOT displaced.

### Expected verdict
**No revision needed** to `withdrawal-queue-single-bot-transfer.md`. The cited line numbers remain accurate.

### Action for pg-writer
1. At your next W9 pass (or at HEAD `b74e745`), spot-check that `banks/ktb/transfer.js:145-152` and `:159-169` still match the content your flow doc describes.
2. If the pointers are still accurate, no edit is needed — just consume this handoff.
3. If something shifted, update the `// impl:` pointers in the flow doc accordingly.

### Bot-writer W2 trace
`58ef65fe-72c3-4093-ad95-5ebb5b493a67`
