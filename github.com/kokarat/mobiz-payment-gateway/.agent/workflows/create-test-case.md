---
description: สร้าง Integration Test Case ใหม่ (Create New Integration Test Case)
---

# Create New Integration Test Case Workflow

This workflow creates new integration test scripts (.sh) for the Mobiz Payment Gateway.
The user can specify what to test, or the agent can analyze the codebase to suggest missing test coverage.

**Prerequisite Skill:** Before writing ANY test code, you MUST read the integration-test-writer SKILL by calling:
```
view_file /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/.agent/skills/integration-test-writer/SKILL.md
```
This skill contains ALL patterns, helper functions, boilerplate, and conventions required for writing tests.

## Step 1: Determine What to Test

### Option A — User Specified a Target
If the user specified what to test (e.g., "เทสการ topup", "test settlement flow", "test deposit expiry"):
- Confirm the scope with the user
- Skip to Step 2

### Option B — Auto-Discover Missing Coverage
If the user did NOT specify what to test, analyze the following to find test gaps:

1. **List existing test scripts:**
   ```bash
   ls -la /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/test-*.sh
   ```

2. **Identify tested flows from filenames:**
   - Deposit: basic, collision, FIFO (single/dual), burst, KTB, GoLogin, multi-bank
   - Payout: basic, KTB, burst
   - Mixed: deposit+payout flow, burst KTB
   - Multi-bank stress: KTB+SCB combined
   - Split-bank: KTB load balancing

3. **Identify UNTESTED flows by reading system-design.md and the codebase:**
   ```bash
   # Check available API endpoints
   grep -r "router\.\(Get\|Post\|Put\|Delete\)" /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/routes/
   # Check scheduler logic
   ls /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/scheduler/
   # Check service logic
   ls /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/services/
   ```

4. **Suggest missing test cases**, prioritized by business impact:
   - 🔴 **Critical (untested core flows):**
     - Topup flow (admin adds funds to client wallet)
     - Settlement flow (client requests withdrawal of wallet balance to their bank)
     - Deposit expiry (deposit times out, status → expired)
     - Pullout task (auto-transfer from system bank when balance exceeds threshold)
     - Direct transfer (manual bank-to-bank transfer)
   - 🟡 **Important (edge cases):**
     - Deposit with slip verification (Thunder API)
     - Payout insufficient wallet balance (should be rejected)
     - Concurrent deposits to same amount from different clients (collision resolution accuracy)
     - Callback delivery verification (webhook → callbackUrl)
     - MDR fee distribution across multiple partners
   - 🟢 **Nice-to-have:**
     - Rate limiting behavior
     - JWT token expiry during long test
     - Bot reconnection after crash
     - SSE event delivery verification

5. **Present the suggestions to the user** and ask which ones to create.

## Step 2: Read the Integration Test Writer SKILL

// turbo
```bash
# Read the SKILL.md to understand all test patterns
cat /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/.agent/skills/integration-test-writer/SKILL.md
```
You MUST read this file before writing any test code. It contains mandatory boilerplate, helper functions, and patterns.

## Step 3: Research the Target Feature

Before writing the test, understand the feature implementation:

1. **Read the relevant controller/service code** to understand:
   - API request/response format
   - Required fields and validation rules
   - Status transitions (e.g., pending → processing → completed)
   - Fee calculations

2. **Read the existing data model** (system-design.md) for the collections involved.

3. **Check if the mock-bank server needs changes** — some tests may require new mock endpoints:
   ```bash
   cat /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/mock-bank/server.js
   ```

4. **Summarize what you found** to the user and confirm the test approach before writing code.

## Step 4: Write the Test Script

### File Naming Convention
```
test-<flow-type>-<variant>.sh
```
Examples:
- `test-topup-flow.sh`
- `test-settlement-flow.sh`
- `test-deposit-expiry.sh`
- `test-payout-insufficient.sh`

### Writing Rules

1. **Follow the template from the SKILL** — header comment, source setup-infra.sh, cleanup trap, `--no-bot` support
2. **Use numbered steps** — Step 1: Verify, Step 2: Infra, Step 3: Data, etc.
3. **Every step gets a `log_step` call**
4. **Always include cross-check verification** at the end
5. **Support `TEST_RUNNER_MODE=1`** for CI
6. **Include Thai comments/names** for realistic testing data
7. **Make the test self-contained** — it should create ALL its own data, not depend on other tests
8. **Set the file as executable**: `chmod +x`

### Write the file
Save to:
```
/Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/test-<name>.sh
```

## Step 5: Make Executable + Validate

// turbo
```bash
chmod +x /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/test-<name>.sh
```

Validate the script parses correctly:
// turbo
```bash
bash -n /Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/test-<name>.sh
```

## Step 6: Register Test in ALL 3 Locations

**⚠️ MANDATORY — every new test MUST be registered in all 3 places:**

### 6a. Workflow Registry (for agent)
Update the "Available Test Scripts" list:
```
/Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/.agent/workflows/run-integration-tests.md
```

### 6b. Runner Script (terminal output)
Update the echo section in `run-integration-test.sh` (around line 76-82) to list the new test:
```
/Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/run-integration-test.sh
```

### 6c. Test Runner Web UI (CRITICAL — most important)
Register the test in the `TESTS` array inside `test-runner.html`:
```
/Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests/mock-bank/public/test-runner.html
```
Each test entry requires: `script`, `icon`, `name`, `category`, `bank`, `type`, `desc`, `details`.
If the test belongs to a new category, also:
1. Add a `.badge.<category>` CSS class (around line 117-127)
2. Add the category to the `CATEGORIES` array (around line 388-398)

## Step 7: Report to User

Provide a clear summary:
- What the test covers
- How to run it: `./test-<name>.sh` (after environment is up via `./run-integration-test.sh`)
- Expected behavior and pass/fail criteria
- Any limitations or known issues
