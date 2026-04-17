---
title: MDR Shared date filter must be parsed in Asia/Bangkok — time.Parse gives UTC
name: MDR Shared date filter must be parsed in Asia/Bangkok — time.Parse gives UTC
description: As of 48ad80b (2026-04-16, PR #169), MDRSharedController parses YYYY-MM-DD date filters via time.ParseInLocation with a module-level bangkokLoc (Asia/Bangkok with FixedZone +7h fallback). time.Parse alone returns UTC and drops every record created 00:00-07:00 BKK.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - mdr
  - timezone
source: controllers/MDRSharedController.go:24-55 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# MDR Shared date filter must be parsed in Asia/Bangkok

## Fact

`controllers.MDRSharedController` gained a module-level helper on 2026-04-16:

```go
var bangkokLoc = func() *time.Location {
    l, err := time.LoadLocation("Asia/Bangkok")
    if err != nil {
        return time.FixedZone("BKK", 7*3600)
    }
    return l
}()

func parseDateRangeBKK(startDate, endDate string) (start, end time.Time, hasStart, hasEnd bool) {
    // time.ParseInLocation("2006-01-02", …, bangkokLoc)
    // end-of-day adds 23h59m59.999ms
}
```

All three handlers use it: `GetAllMDRSharedLogs`, `GetMDRSharedStats`, `GetPartnerDistributionSummary`. The helper returns `time.Time` values that represent Bangkok-local date boundaries (expressed as UTC in the returned struct) so they drop straight into Mongo filters without further conversion.

## Why

Prior to this commit the handlers used `time.Parse("2006-01-02", startDate)` which returns UTC. A "today = 2026-04-16" filter from the Bangkok-facing UI was therefore matching 2026-04-16 00:00 UTC → 2026-04-16 23:59 UTC, which is 07:00 → 07:00 the NEXT day in Bangkok. Every `mdr_shared` record created between 00:00 and 07:00 BKK got silently dropped. Triggered in production at 03:27 BKK when the whole page ended up empty even though clearing the filter returned rows.

## How to apply

- Any controller that accepts a YYYY-MM-DD string from a Bangkok-facing UI and filters a Mongo `created_at` against it must parse in Asia/Bangkok.
- Prefer the shared `parseDateRangeBKK` pattern: one `time.LoadLocation` at init, fallback `FixedZone("BKK", 7*3600)` if tzdata is missing, end-of-day `+23h59m59.999ms`. Don't reinvent.
- `FixedZone` fallback is important because the runtime container image may strip tzdata. If your DST situation is complex enough that the Fixed fallback is wrong, reject the filter instead of silently dropping rows.
- Don't use this pattern where the input is `created_date_bkk` (YYYYMMDDHHMMSS int64) — that field is already Bangkok-local and compares as a numeric range with no tz conversion.

## Trace

commit `3b7e0f1` (specifically `48ad80b` #169) → docs/current-system.md §3.2 (mdr-shared row) → resolution PR #173
