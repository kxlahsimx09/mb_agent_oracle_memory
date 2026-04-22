## Hand-off to `mock-bank-sync-check`

**From:** `tester` agent (mobiz-payment-gateway, 2026-04-20 GMT+7)
**Repo:** `github.com/kokarat/mobiz-payment-gateway`
**Tags:** `repo:mobiz-payment-gateway` · `mock-bank-sync-check` · `fixtures` · `workflow:tester-w2` · `flow:payout-scb-post-otp-waiting-to-review`

### Why this hand-off

User asked tester to add `integration-tests/test-payout-scb-post-otp-waiting-to-review.sh` — the SCB analogue of the existing KTB drift reproducer (`test-payout-ktb-post-otp-waiting-to-review.sh`).

Workflow-2 Step 3 inventory showed the SCB equivalent of `/admin/ktb/break-otp-confirm` does **not exist** in mock-bank. Per workflow Step 3e, mock changes never inline into a test PR — handed off here instead. The tester test PR is blocked on this fixture landing.

### Required deliverable A — `/admin/scb/break-otp-confirm` fixture (mirror of KTB)

Mirror the KTB fixture surfaces 1:1 against the SCB approver flow. Concrete refs:

**Bot side — what we are simulating** (read-only context for you):
- `bank-bot/banks/scb/approver.js:582-590` — confirm-OTP `try/catch`. When the `page.getByTestId(APPROVER.OTP_CONFIRM).click()` throws, returns `{ status: 'waiting_to_review', error: 'Confirm OTP failed (OTP may have been submitted): ...' }`.
- `bank-bot/banks/scb/selectors.js:53` — `OTP_CONFIRM: 'otp-form.confirm'`.
- `bank-bot/app.js:1645` and `:1714` — dispatcher already routes `waiting_to_review` correctly (thread #16 fix landed). So this test will be expected-green from day 1 (regression tripwire), unlike the KTB test which was forward-looking pre-fix.

**Mock-bank changes (the actual deliverable):**

1. **Server endpoint (3b)** — `integration-tests/mock-bank/server.js`. Mirror `:563-589` (KTB block) but namespaced `scb`:
   ```
   POST /admin/scb/break-otp-confirm  { account_number, enabled }
   GET  /admin/scb/break-otp-confirm
   GET  /admin/scb/break-otp-confirm/status?account=<n>
   ```
   Backed by `state.scbBreakOtpConfirm = new Set()`. Same shape as KTB — copy-paste-rename is fine.

2. **Client-side (3c)** — `integration-tests/mock-bank/public/index.html`. The OTP confirm button is at `:205`:
   ```html
   <button data-testid="otp-form.confirm" class="btn btn-primary" onclick="confirmOtp()">ยืนยัน</button>
   ```
   Mirror KTB's pattern from `ktb.html:430-446` (status fetch on page load with `?account=` param) and `:800-823` (capture-phase pointerdown/mousedown/click breaker that calls `window.stop() + location.replace('about:blank') + document.open/write/close + throw`). Variable name suggestion: `_scbBrkOtpConfirm`. Selector for the breaker: `#otp-section button[data-testid="otp-form.confirm"]` (the OTP section is gated visible by `.show` class, see `index.html:90-91, 193, 547`).

   Critical gate from the 2026-04-20 KTB lesson (Oracle thread #26): the status fetch MUST pass `?account=` from the URL query, not rely on session cookie. SCB's index.html already reads `?account=` for login (`:478-481`) — same pattern applies for the fixture probe.

3. **Synchronous fallback** — mirror `ktb.html:825-833`: inside `confirmOtp()` itself, before the `fetch('/api/otp/...)` call, if `_scbBrkOtpConfirm === true` then `document.open/write/close + throw` — defense in depth in case the capture-phase listener missed (button re-render).

4. **Smoke-test the round-trip** before you commit (Step 3d in workflow):
   - Toggle ON for an SCB account
   - Probe `/admin/scb/break-otp-confirm/status?account=<n>` — expect `enabled:true`
   - Open `/?account=<n>` headless, drive to OTP, click confirm — observe the document gets wiped + Playwright timeout fires (the bot-side `.click()` throw)

### Required deliverable B — `integration-tests/mock-bank/FIXTURES.md` (per Oracle thread #28)

This is the gating dependency for restoring workflow-2 Step 3f. Thread #28 has the full audit context — read it before starting.

**Minimum viable FIXTURES.md** to restore Step 3f: at least both confirmed fixtures documented in the canonical shape from thread #28 message:

- `/admin/ktb/break-otp-confirm` (already authored — copy from thread #28 message verbatim)
- `/admin/scb/break-otp-confirm` (your new addition — same shape)

Each entry: admin endpoint(s), status probe, client behavior + line refs, mechanism (window.stop + location.replace + document.open/write/close → Playwright timeout), gate conditions (account filter via `?account=`, pre-login fetch timing gotcha), applies-to (which bank page + which bot click), used-by (test script).

The audit candidates listed in thread #28 (`hide-approver`, `inject-pending`, `delay-pending`, `shuffle-pending`, `delays`, `set-config`, `set-balance`, `add-statement`) can be left as TODO sections at the bottom — the tester team will fill them in opportunistically per thread #28's "let it accumulate organically" guidance. Just don't claim FIXTURES.md is comprehensive when it isn't.

### Required deliverable C — restore workflow-2 Step 3f

Once FIXTURES.md exists with both `break-otp-confirm` entries, edit `.agent/skills/tester/references/workflow-2-add-new-test-case.md`:

1. Remove the HTML comment block at `:194-200` (`Step 3f intentionally omitted pending …`).
2. Insert the Step 3f section per the template in thread #28 message ("Once FIXTURES.md exists — restore workflow-2 Step 3f").
3. Add a `**Revised:** 2026-04-20 (GMT+7, part 5) — Step 3f restored (FIXTURES.md seeded with break-otp-confirm × 2 per thread #28).` footer entry.
4. Close Oracle thread #28 with a one-line "FIXTURES.md seeded — Step 3f restored — PR #N" message.

### What NOT to do

- **Do NOT inline the test script.** That comes after this PR merges. The tester will resume on the next session via `Resume SCB test` task (currently blocked by this hand-off).
- **Do NOT delete the legacy KTB fixture entries.** P-001.
- **Do NOT mark FIXTURES.md as complete** until at least the audit candidates from thread #28 are evaluated — leave them as TODO sections so future tester sessions document them while in context.

### Suggested branch + commits

`feat/mock-bank-scb-break-otp-confirm-fixture`

Recommended split into 3 commits within one PR for review clarity:
1. `mock-bank: add /admin/scb/break-otp-confirm endpoint + state` (server.js)
2. `mock-bank: add SCB break-otp-confirm client-side breaker` (index.html)
3. `docs: seed FIXTURES.md and restore workflow-2 Step 3f (closes Oracle thread #28)` (FIXTURES.md + workflow-2 edit)

### Cross-references

- **Tester thread that triggered this:** SCB test scope confirmation (this session, 2026-04-20).
- **Oracle threads:** #16 (closed, dispatcher fix), #26 (3-surface mock-bank readiness lesson), #28 (FIXTURES.md audit + Step 3f restore — this gates the workflow-2 edit).
- **Reference test (KTB analogue):** `integration-tests/test-payout-ktb-post-otp-waiting-to-review.sh`.
- **Reference fixture (KTB):** `integration-tests/mock-bank/server.js:563-589`, `integration-tests/mock-bank/public/ktb.html:430-446, 793-823, 825-833`.

### Resume signal back to tester

When this PR merges, the blocked tester task (`Resume SCB test after fixture PR merges`) becomes unblocked. The follow-on test PR will use `bash $(...)/integration-tests/test-payout-scb-post-otp-waiting-to-review.sh` runtime-verified against the new fixture per workflow-2 Step 5 Part B.
