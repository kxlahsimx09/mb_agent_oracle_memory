## Handoff to bot-writer-oracle — matcher cascade gained `linkCheckingDeposit` step (mobiz #384)

**Sibling-flow-doc citation case (W2 Step 2c, no defer).** Filed by `pg-writer-oracle` against mobiz `20b6fa3` (#384, 2026-05-03).

**Affected sibling flow doc:** `bank-bot/docs/flows/deposit-auto-match-from-statement.md:105`
> *"For each newly-inserted statement row, mobiz goroutine-kicks `MatchNewStatements(accountNumber)` synchronously after the POST returns (mobiz sibling `services/transactionMatcher.go:1126`). A pending `ts_deposits` row matching the statement will be flipped to `paid` + wallet-credited + callback-fired within seconds of the bot's POST."*

**What changed in mobiz:** `services/transactionMatcher.go::matchDeposit` now runs an extra step between bank-qualified passes (`matchDepositKTB/SCB`) and the `linkPaidDeposit` fallback:

```
matchDepositKTB → matchDepositSCB → linkCheckingDeposit (NEW) → linkPaidDeposit (fallback)
```

`linkCheckingDeposit` scopes candidates by `system_bank_account_number + amount + status="checking" + is_matched != true`, filters by source-identity overlap on the statement (full-account or last4), breaks ties by smallest minute-delta. **It writes `bank_statements.match_status="matched" + matched_request_id` only — wallet, callback, and `deposit.status` are untouched.** Admin still approves the deposit manually.

**Why bot-writer might want to update the flow doc:** the synchronous-after-POST contract bank-bot's flow describes is still accurate (a pending deposit can still flip to paid within seconds), but slip-uploaded deposits have an additional intermediate outcome:

- statement arrives, matcher finds NO pending candidate but DOES find a matching `status=checking` candidate → the new step links the statement to the deposit silently and waits for admin approval. From bank-bot's vantage, the POST returns and `MatchNewStatements` runs, but the operator never sees the deposit auto-credited.

The current bank-bot doc's "deposit may flip to paid within seconds" framing remains correct for the pending-deposit path. An optional addition would be to mention the checking-deposit-link intermediate outcome so operators understand why some slip-uploaded deposits "matched but not yet credited."

**Suggested edit (low-risk, doc-only):** add a one-liner to bank-bot's flow §Postconditions or §Side effects: *"Slip-uploaded deposits in `status=checking` may be silently linked by the matcher (mobiz `linkCheckingDeposit`, #384) without flipping to `paid` — admin approval remains required, but the cross-reference is resolved so the V1 fraud check at approve time succeeds."*

**Relevant mobiz artefacts:**
- W2 trace: `c93d0c25-e494-43fb-87bb-a039ff14cea4`
- Cross-repo learning: `2026-05-03_cross-repo-sync-bank-bot-deposit-auto-match-flow-mobiz-link-checking-deposit-step` (filed by this pass)
- Mobiz fix commit: [`20b6fa3`](https://github.com/kokarat/mobiz-payment-gateway/commit/20b6fa3)
- Mobiz PR: #384

**No action required** if you decide the current bank-bot doc framing is sufficient. This handoff just makes the citation surface visible for your next W2/W9/W8 pass on the affected flow.
