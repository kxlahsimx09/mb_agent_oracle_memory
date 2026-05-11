---
title: Playwright `npx playwright install` auto-prunes cross-project browser binaries —
tags: [playwright, browser-cache, auto-prune, gotcha, infra, regression-flake, bank-bot, shared-cache, version-pinning]
created: 2026-05-09
source: Investigation 2026-05-09 18:55 GMT+7 — w2-watcher regression 20260509-011623 root-cause hunt; confirmed by re-install + green re-run 20260509-185632
project: github.com/kokarat/bank-bot
---

# Playwright `npx playwright install` auto-prunes cross-project browser binaries —

Playwright `npx playwright install` auto-prunes cross-project browser binaries — pinned older versions break silently

## Symptom

Test that was passing yesterday suddenly fails today. Bank-bot or any Playwright user crashes at startup with:

```
browserType.launch: Executable doesn't exist at
/Users/<u>/Library/Caches/ms-playwright/chromium_headless_shell-<NNNN>/...
```

The version `<NNNN>` (e.g. 1208) is **gone** from the cache, even though `node_modules/playwright/package.json` still pins a version that needs it.

## Root cause

macOS default `PLAYWRIGHT_BROWSERS_PATH=~/Library/Caches/ms-playwright/` is **shared across every project on the host**. When ANY other project runs `npx playwright install` with a newer Playwright (>= 1.50 ish), the install step prunes browser binaries that don't match that newer Playwright's required version. Your project, still on the older Playwright, finds its binary missing on next launch.

Trail of evidence on the cache:
```
$ ls -lt ~/Library/Caches/ms-playwright/
chromium_headless_shell-1217   May 7 17:44   ← someone installed this here
chromium_headless_shell-1208   <gone>        ← pruned as collateral
chromium_headless_shell-1200   Dec 17        ← pre-1208 leftover (lucky)
```

`node_modules/playwright/package.json` of the broken project pins e.g. `1.58.2` → which needs `chromium_headless_shell-1208`. The 1217 install nuked 1208.

## Recovery (one-shot)

```bash
cd <project-with-pinned-playwright>
npx playwright install chromium
```

Re-downloads the version this project's `node_modules/playwright` needs. ~250 MB.

## Durable fix (recommended for shared machines)

Isolate cache per project so cross-project installs can't reach in:

```bash
# in <project>/.env or test-runner script
export PLAYWRIGHT_BROWSERS_PATH=$PWD/.playwright-browsers
npx playwright install chromium
```

Now `<project>/.playwright-browsers/` holds only that project's binaries. Other projects' installs can't see or prune it.

## Live incident (this learning's source)

- 2026-05-06 → 2026-05-07 morning: `test-deposit-collision-dual.sh` ✅ in regression
- **2026-05-07 17:44**: chromium_headless_shell-1217 + chromium-1217 appeared in cache (someone elsewhere ran `npx playwright install`)
- **2026-05-07 18:10 onward**: same test ❌ — both SCB and KTB local bank-bots crash at `ensureBrowser` with "Executable doesn't exist at .../chromium_headless_shell-1208"
- 2026-05-09 18:55 fix: `cd bank-bot && npx playwright install chromium` re-downloaded 1208 → re-run regression `SINGLE_TEST=test-deposit-collision-dual.sh` → ✅ 49s

## Detection rule

When a Playwright-using bot/test fails with "Executable doesn't exist at .../chromium*-NNNN/", DO NOT classify as code bug. Check `~/Library/Caches/ms-playwright/` mtimes — a recent unrelated entry alongside missing-NNNN proves cross-project prune. This is **infra**, not regression.

## Why this isn't documented in Playwright

Playwright officially advertises `PLAYWRIGHT_BROWSERS_PATH=0` (= node_modules) and a global cache. The "auto-prune on install" behavior shipped quietly somewhere around 1.50+. The default is global (= shared) which makes hosts running multiple Playwright versions inherently fragile.

---
*Added via Oracle Learn*
