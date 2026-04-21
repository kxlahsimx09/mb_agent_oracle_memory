---
title: [DRIFT-keepalive-err-code-string-vs-constant] — callers of KTBModule.keepSession
tags: [drift, workflow-4, repo:bank-bot, current, flow:ktb-keepalive-session-rotation, ktb, keepalive, error-code-dispatch, string-literal-vs-constant, sentinel, thread-32, ratification-revise]
created: 2026-04-21
source: W8 ratification thread #32 Q2 REVISE — promote drift to W4 queue, 2026-04-21 GMT+7
project: github.com/kokarat/bank-bot
---

# [DRIFT-keepalive-err-code-string-vs-constant] — callers of KTBModule.keepSession

[DRIFT-keepalive-err-code-string-vs-constant] — callers of KTBModule.keepSessionAlive dispatch on string literal instead of exported sentinel

**What's drifting:** `KTBModule.keepSessionAlive` (`banks/ktb/index.js:232-312`) throws an error with `err.code = KTB_SESSION_DEAD` where `KTB_SESSION_DEAD = 'KTB_SESSION_DEAD'` is a module-local constant, additionally exposed as `KTBModule.KTB_SESSION_DEAD = 'KTB_SESSION_DEAD'` at `banks/ktb/index.js:339` specifically so callers can match without importing the whole module. The two actual call sites in `app.js` match on the **string literal** instead:

```js
// app.js:1836-1846 (transfer idle branch)
try {
  await bankModule.keepSessionAlive(session.page);
} catch (e) {
  if (e?.code === 'KTB_SESSION_DEAD') {   // ← string literal
    log.error('[Transfer] keepSessionAlive signaled session dead — resetting browser');
    try { await resetBrowser(); } catch (rbErr) {
      log.warn('[Transfer] resetBrowser after KTB_SESSION_DEAD failed', { error: rbErr?.message });
    }
    continue;
  }
  log.warn('[Transfer] keepSessionAlive error (non-fatal)', { error: e?.message });
}

// app.js:2129-2137 (pollLoop idle branch) — same string-literal pattern
```

**Why it works today:** both producer and consumer name the same string `'KTB_SESSION_DEAD'`. Dispatch succeeds, `resetBrowser` fires, recovery path runs end-to-end.

**Why it's a drift:** the sentinel value's export (`KTBModule.KTB_SESSION_DEAD`) was added at `:339` precisely to let callers match against the constant, not the literal — the literal is a developer-convenience artifact of the sentinel's string form, not the contract. A future rename of the sentinel value (e.g. `'KTB_SESSION_DEAD'` → `'KTB_SESSION_EXPIRED'` to align with a broader KTB error taxonomy, or `'SESSION_WEDGED'` to name the detail-page-stuck state more precisely) would:

1. Flip the producer side only (`banks/ktb/index.js:26` constant + `:339` export).
2. Leave both consumer sites intact with the OLD string.
3. Dispatch silently fails — `e.code === 'KTB_SESSION_DEAD'` never matches.
4. Caller falls through to the `log.warn` non-fatal branch.
5. `resetBrowser` never fires.
6. Bot stays wedged on the account-detail page until another failure path (e.g. `ensureLoggedIn` failing on next tick, or `MAX_LOGIN_FAILURES_BEFORE_RESET` threshold) eventually recycles the browser.

Silent, latent, debugging-hostile failure mode. Not a runtime bug at HEAD — purely a future-proofing gap.

**Why this is worth a W4 queue item rather than a §Error paths note:**

- Trivial fix: two-char edit per call site (`'KTB_SESSION_DEAD'` → `KTBModule.KTB_SESSION_DEAD`), total 4 characters changed across 2 lines in `app.js`.
- Requires importing `KTBModule` at the caller — but `app.js` already imports `bankModule` dynamically via `loadBankModule`. The fix is either:
  - (A) `KTBModule` class-level access: `const KTBModule = require('./banks/ktb')` at app.js top, then `e?.code === KTBModule.KTB_SESSION_DEAD`. Creates a hard dep on KTB from app.js even when the bot is configured for SCB.
  - (B) Expose sentinel via `bankModule.KTB_SESSION_DEAD` (instance-level, already available via the module loader at runtime). Cleaner because app.js already has `bankModule` as its polymorphic entry point.
  - (C) Expose via `bankModule.constructor.KTB_SESSION_DEAD`. Pedantically correct (accesses the class-level static through the instance) but noisier at the call site.
- Option (B) is idiomatic for the BaseBankModule pattern: the sentinel is a per-bank contract, and the polymorphic interface already handles per-bank method dispatch. Recommended.
- No runtime-behaviour change — just the dispatch robustness. Safe to land independently, no migration, no feature flag.

**Ratified via Oracle thread #32 (2026-04-21, Q2):** promote from §Error paths note to W4 queue item. This learning is the paired anchor that W4 will pick up.

**Anchor:** `docs/flows/ktb-keepalive-session-rotation.md §Error paths` — the flow doc references this learning by id. When W4 lands the fix, strip the drift callout + mark the §Error paths entry as `resolved in <PR>`.

**Owner:** bot-writer on `kokarat/bank-bot`. No cross-repo coordination needed.
**W8 trace:** `64ac74f3-0749-4d9b-9681-bf4bc3b6cba9` (parent).
**Source flow:** `flow:ktb-keepalive-session-rotation`.

Tags: drift, workflow-4, repo:bank-bot, current, flow:ktb-keepalive-session-rotation, ktb, keepalive, error-code-dispatch, string-literal-vs-constant, sentinel, thread-32, ratification-revise

---
*Added via Oracle Learn*
