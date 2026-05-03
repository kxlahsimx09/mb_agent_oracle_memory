---
title: W2 track-commit refresh — bank-bot 4b968a4..84e6649 covers two in-territory PRs 
tags: [technical-writer, repo:bank-bot, current, track-commit, scb, dashboard, balance, update-all, ops, fleet]
created: 2026-05-01
source: docs/current-system.md@84e6649 + commits 20289a3, 84e6649
project: github.com/kokarat/bank-bot
---

# W2 track-commit refresh — bank-bot 4b968a4..84e6649 covers two in-territory PRs 

W2 track-commit refresh — bank-bot 4b968a4..84e6649 covers two in-territory PRs that landed 2026-04-30. PR #110 (20289a3) hardens SCB dashboard balance scrape: the AccountSummary-Card heading-walk fallback used to fire on parsed value === 0, which mistook a legitimate "ยอดเงินสดที่ใช้ได้ 0.00" display (account fully held) for a scrape miss and overrode the real 0 with the next heading down (the account balance). The fix gates the fallback on whether the labelled regex matched (!availableMatch || !accountMatch); same guard for the alternate-label "ยอดเงินที่ใช้ได้" fallback. Observed 2026-04-30 on bank พร.เพชรทวี — page showed available=0 / account=296,670, bot reported available=296,670 to gateway, dispatcher believed there was cash. PR #110 also swaps the SCB→backend balance mapping at every api.updateBalance SCB call site: backend `balance` ← summary.availableBalance (SCB "ยอดเงินสดที่ใช้ได้"), backend `available_balance` ← summary.accountBalance (SCB "ยอดเงินในบัญชี"). Operator preference so system_banks UI shows the working pool the dispatcher draws against under "ใช้ได้". Wire format unchanged but field semantics swapped — cross-repo sibling-sync filed separately. PR #111 (84e6649) rewrites scripts/update-all.sh (43→96): install-dir auto-detect /opt/bank-bot/.git first then /opt/bank-payment-gateway/.git; `ssh -n` to keep outer loop stdin alive; merge stderr+stdout to LOG_FILE (default /tmp/bank-bot-update.log) and decide per-droplet status from `systemctl is-active`. Verified 2026-04-30 on 32/32 droplets. Sections updated: docs/current-system.md §3.1.7 (dashboard fallback + balance-mapping swap) and §5.3 (update-all.sh row). docs/.baseline bumped 4b968a4 → 84e6649.

---
*Added via Oracle Learn*
