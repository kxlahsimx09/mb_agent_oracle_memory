---
title: Playwright `.click()` does NOT post-verify element state after dispatching, but 
tags: [repo:mobiz-payment-gateway, tester, thread:16, flow:test-payout-ktb-post-otp-waiting-to-review, playwright, fixtures, mock-bank, click-throw]
created: 2026-04-20
source: tester session 2026-04-20 (PR #233 fixture v3)
project: github.com/kokarat/mobiz-payment-gateway
---

# Playwright `.click()` does NOT post-verify element state after dispatching, but 

Playwright `.click()` does NOT post-verify element state after dispatching, but it DOES wait for scheduled navigations to finish. To force `.click()` to throw reliably from a mock-bank fixture, trigger a scheduled navigation that Playwright waits on but never completes.

**Winning combo inside capture-phase click handler:**
```js
window.stop();                           // abort in-flight loads
window.location.replace('about:blank');  // schedule frame nav (Playwright waits)
document.open();                         // wipe DOM synchronously
document.write('<!doctype html>...');    // so nav "never finishes"
document.close();
throw new Error(...);
```

Playwright error confirms mechanism: `locator.click: Timeout 30000ms exceeded. - click action done - waiting for scheduled navigations to finish`.

**Anti-patterns that DO NOT work:**
- `location.replace('about:blank')` alone → async, `.click()` returns first (this was v2's failure)
- `document.open() + write + close()` alone → wipes DOM but `.click()` has no post-check
- `throw` from async onclick handler → rejects unhandled promise, `.click()` oblivious
- `window.close()` → blocked by Chrome unless opened via `window.open()`

**Context:** Discovered 2026-04-20 fixing `integration-tests/mock-bank/public/ktb.html` break-otp-confirm fixture v3 for thread #16 test (`test-payout-ktb-post-otp-waiting-to-review`). Install as capture-phase `pointerdown/mousedown/click` listener combo for defense-in-depth.

**Applies to:** any future mock-bank fixture simulating "page closed mid-click" / popup-window-closes / post-submit-ambiguity scenarios.

---
*Added via Oracle Learn*
