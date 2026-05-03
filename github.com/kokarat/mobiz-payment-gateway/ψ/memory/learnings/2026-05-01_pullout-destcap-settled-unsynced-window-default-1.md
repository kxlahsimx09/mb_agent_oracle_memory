---
title: Pullout DestCap settled-unsynced window: default 15 → 60 minutes, now operator-t
tags: [technical-writer, repo:mobiz-payment-gateway, current, pullout, destcap, settled-unsynced, app-settings, incident-driven]
created: 2026-05-01
source: services/pulloutDemand.go:26-49,124-260@c5ee388
project: github.com/kokarat/mobiz-payment-gateway
---

# Pullout DestCap settled-unsynced window: default 15 → 60 minutes, now operator-t

Pullout DestCap settled-unsynced window: default 15 → 60 minutes, now operator-tunable (mobiz c5ee388 #351, 2026-05-01). `services.SumSettledPulloutAmountsToDest` (§6.4) hard-floors its lookback cutoff at `(now − window)` so a stale `balance_updated_at` cannot inflate the aggregation into a full-table scan. The window jumped from a hardcoded 15 minutes to a default of 60 minutes, sourced via `getAppSettingFloat(SettingKeyPulloutSettledUnsyncedWindowMin, DefaultPulloutSettledUnsyncedWindowMin)` — values ≤ 0 fall back to default. New constants in services/pulloutDemand.go: `SettingKeyPulloutSettledUnsyncedWindowMin = "pullout_settled_unsynced_window_minutes"` and `DefaultPulloutSettledUnsyncedWindowMin float64 = 60`. Trigger: 2026-05-01 overflow incident on bank 4212114916 — cap band 99.5k–105.5k, peak balance 408,838 (4× cap), 14 large pullouts (≥40k each, total 785,712) landed in 24h with `amount == random_amount` (DestCap guard never trimmed/skipped). Root cause: 4 concurrent pullout tasks (1,200 inbound/day) against a min_amount of 40k = each pullout consumes 38–76% of headroom; bot scrape lagged the credits by 8–12 min, so the 15-min hard floor clamped `cutoff` NEWER than the actual settle time and dropped the legitimate unsynced reservation. Why hard-floor instead of trusting `balance_updated_at` directly: payout banks under heavy load occasionally have buggy scrape paths leaving the field stale for hours; trusting them blindly would explode the aggregation. Tier 3 fix only — Tiers 1 (reduce concurrent task pressure) and 2 (lower min_amount for finer reduction granularity) are operator-side per-dest changes applied separately. New app_settings key listed in §4 AppSettings row.

---
*Added via Oracle Learn*
