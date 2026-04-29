---
title: **Pullout scheduler DestCap + headroom-below-MinAmount policy (mobiz-payment-gat
tags: [pullout, scheduler, destcap, headroom, minamount, payout-bank]
created: 2026-04-27
source: W2 backlog repair 2026-04-27, commits 2c611cc #316 + 3b629e9 #322
project: github.com/kokarat/mobiz-payment-gateway
---

# **Pullout scheduler DestCap + headroom-below-MinAmount policy (mobiz-payment-gat

**Pullout scheduler DestCap + headroom-below-MinAmount policy (mobiz-payment-gateway, 2026-04-27)**

Two related policies added in `2c611cc` #316 and `3b629e9` #322. Applies to PullOutScheduler (`scheduler/scheduler.go`), auto-trigger path in `BotConfigController`, and manual execute-now in `PullOutTaskController`.

**DestCap policy (#316):** When the destination bank is a payout-method bank (`services.IsPayoutDest`), the computed pullout amount is trimmed to `headroom = DestCap − dest.Balance`. `DestCap` reads from `app_settings.pullout_refill_dest_cap`; falls back to `services.DefaultPulloutRefillDestCap` when zero. If `headroom ≤ 0` the tick is skipped — destination is already at or over cap.

**Headroom-below-MinAmount (#322):** if `amount > headroom` AND `headroom > 0`, the scheduler sends exactly `headroom` even when `headroom < task.MinAmount`. The rationale: `MinAmount` is a normal-operation floor to avoid tiny transfers; it is NOT a blocking constraint when the system needs to fill the last few baht to reach exactly the cap. Operators configuring `MinAmount` accept it being waived in the cap-trim branch.

// verified: scheduler/scheduler.go:256-295@3b629e9, controllers/PullOutTaskController.go:990-1020@3b629e9

---
*Added via Oracle Learn*
