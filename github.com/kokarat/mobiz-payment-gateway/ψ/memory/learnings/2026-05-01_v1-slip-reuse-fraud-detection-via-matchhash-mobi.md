---
title: V1 slip-reuse fraud detection via match_hash (mobiz #362, 44f8634, 2026-05-02). 
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, slip-fraud, v1-hash, fraud-detection, bank-statements, match-hash]
created: 2026-05-01
source: controllers/DepositController.go:899-945@44f8634 + services/slipMatchHash.go:1-363@44f8634 + services/transactionMatcher.go:729-814@44f8634
project: github.com/kokarat/mobiz-payment-gateway
---

# V1 slip-reuse fraud detection via match_hash (mobiz #362, 44f8634, 2026-05-02). 

V1 slip-reuse fraud detection via match_hash (mobiz #362, 44f8634, 2026-05-02). DepositController.UpdateDepositStatus runs a third defense layer after bot-path lockout (#361) and receiver-mismatch (#360): when the deposit carries a slip_verify_result and is moving to status=paid, it computes SHA-256(dest_account|sender_bank_short|amount_satang|YYYYMMDDHHMM) and looks up bank_statements.match_hash within the same BKK calendar day. Sender account is intentionally excluded from the hash because Thai bank masks vary by issuer (KBANK middle-4, BBL front-4+last-3, KTB last-3) — overlap on slip's sender.account.bank.account vs statement's source_account_no is the secondary scorer (1=hash-only, 2=3-digit overlap, 3=4-digit overlap). Fraud signal: matched statement's matched_request_id points to a different deposit AND the score qualifies (any ownership conflict on hash path; score >= 2 on structured fallback). Inline match_hash compute on inbound bank_statement insert (controllers/BotConfigController.go:746-757) means the historical backfill is no longer required for V1 detection. Companion retroactive scan in services/transactionMatcher.go::checkRetroactiveSlipFraud surfaces the inverse window — when a real statement matches deposit X, scan paid-by-slip deposits Y with the same dest+amount in the same BKK day, flag both for admin review (no auto wallet reversal). Pre-paid block + retroactive flag together close the same-destination duplicate-credit hole left by #360.

---
*Added via Oracle Learn*
