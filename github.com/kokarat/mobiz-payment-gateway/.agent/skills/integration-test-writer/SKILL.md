---
name: integration-test-writer
description: >
  [SUPERSEDED 2026-04-16 by the `tester` skill — see superseded_by below.]
  Originally: Write integration test scripts (.sh) for the Mobiz Payment
  Gateway. Use this skill when creating new test cases for deposit, payout,
  withdrawal, or any end-to-end flow that requires mock-bank, bank-bot, and
  backend services.
superseded_by: .agent/skills/tester/SKILL.md
superseded_at: 2026-04-16
superseded_reason: >
  The `tester` role absorbs this skill's process and extends it with three
  responsibilities this skill did not cover: static validation of existing
  tests, coverage-gap analysis, and mock-bank drift detection. Per P-001
  (Nothing is Deleted) this file is preserved intact — its pattern library
  (template, helper functions, Patterns 1–11, pitfall list) remains the
  canonical reference for writing test code. When writing a new test, read
  BOTH this file (for the patterns) and the tester SKILL (for the process).
---

> **⚠️ SUPERSEDED 2026-04-16.** The `tester` role at
> `.agent/skills/tester/SKILL.md` is now authoritative for integration-test
> work. This file is kept as the canonical **pattern library** — its
> templates, helpers, patterns, and pitfalls are still current. Do not edit
> this file; file changes to the tester SKILL or to a new pattern-library
> document with a supersession pointer back here.

# Integration Test Writer

This skill provides patterns and conventions for writing integration test scripts for the Mobiz Payment Gateway project.

## Project Context

**Mobiz Payment Gateway** is a Go + Node.js payment system:
- **Go Backend API** — REST API (Fiber v2), MongoDB, Redis, schedulers (deposit matcher, withdrawal dispatcher)
- **Bank Bot** (Node.js) — Puppeteer browser automation for SCB/KTB internet banking
- **Mock Bank** (Node.js) — Simulates bank portals for testing
- **MongoDB** — test database: `payment_gateway_test`
- **Redis** — cache, pub/sub

## Test Infrastructure Architecture

```
┌─────────────────────────────────────────────────────┐
│  Test Script (.sh)                                  │
│  • Creates test data via API                        │
│  • Simulates customer actions via Mock Bank admin   │
│  • Monitors transaction status via polling          │
│  • Cross-checks final balances                      │
└────┬──────────────┬──────────────┬──────────────────┘
     │              │              │
┌────▼────┐   ┌────▼────┐   ┌────▼────┐
│ Backend │   │Mock Bank│   │Bank Bot │
│ :3099   │   │ :3098   │   │(puppeteer)│
└────┬────┘   └────┬────┘   └────┬────┘
     │              │              │
┌────▼────┐         │         ┌───▼────┐
│MongoDB  │         └─────────│ Mock   │
│ :27117  │                   │ Bank UI│
└─────────┘                   └────────┘
```

## File & Directory Structure

```
integration-tests/
├── run-integration-test.sh       # Environment launcher (infra only)
├── helpers/
│   ├── setup-infra.sh            # Shared functions (MUST source)
│   └── generate-signature.js      # API signature generator
├── mock-bank/
│   └── server.js                 # Mock bank server
├── docker-compose.yml            # MongoDB + Redis for tests
├── .env.test                     # Test environment variables
├── test-deposit-flow.sh          # Basic deposit test
├── test-payout-flow.sh           # Basic payout test
├── test-mixed-flow.sh            # Deposit + payout simultaneous
├── test-burst-deposit.sh         # High-volume deposit stress test
├── test-deposit-collision.sh     # Same-amount deposit matching test
├── test-deposit-fifo-single.sh   # FIFO matching (1 client, N deposits)
├── test-deposit-fifo-dual.sh     # FIFO matching (multi-client)
├── test-deposit-ktb.sh           # KTB-specific deposit test
├── test-payout-ktb.sh            # KTB-specific payout test
├── test-multi-bank-stress.sh     # Multi-bank KTB+SCB stress test
└── test-split-bank-ktb.sh        # Split bank load balancing
```

## Mandatory Test Script Template

Every test script MUST follow this exact template structure:

```bash
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
#  <Test Name> — <Category> Integration Test
#  <Thai description: what is being tested>
#
#  <Concept/Architecture notes>
#
#  Flow:
#    1. Verify services
#    2. Create infrastructure (admin/MDR/pool/bank/merchant)
#    3. Create clients + customer accounts
#    4. <Test-specific actions>
#    5. <Bot processing>
#    6. Monitor status
#    7. Verify / cross-check results
#
#  Config (env vars):         # if configurable
#    VAR=default              # description
#
#  Usage:
#    ./<script-name>.sh
#    ./<script-name>.sh --no-bot
#
#  Exit codes:
#    0 = All tests passed
#    1 = Test failed
# ═══════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source shared setup — MANDATORY
source "$SCRIPT_DIR/helpers/setup-infra.sh"

NO_BOT=false
BOT_PID=""
TEST_RESULT=0

for arg in "$@"; do
  case $arg in
    --no-bot) NO_BOT=true ;;
  esac
done

cleanup_<test_name>() {
  # ✅ Only kill the bot — do NOT call infra_cleanup here
  [ -n "$BOT_PID" ] && kill "$BOT_PID" 2>/dev/null
  exit $TEST_RESULT
}
trap cleanup_<test_name> EXIT

# ═══════════════════════════════════════════════════════════════════
#  Step 1: Verify Services (NEVER start them — they are already running)
# ═══════════════════════════════════════════════════════════════════
log_step "Step 1: Verify Services"

curl -sf "${BACKEND_URL}/swagger/index.html" > /dev/null 2>&1 || {
  log_fail "Backend not running at ${BACKEND_URL} — run ./run-integration-test.sh first"
  TEST_RESULT=1; exit 1
}
log_ok "Backend running"

curl -sf "${MOCK_BANK_URL}/api/session" > /dev/null 2>&1 || {
  log_fail "Mock Bank not running at ${MOCK_BANK_URL} — run ./run-integration-test.sh first"
  TEST_RESULT=1; exit 1
}
log_ok "Mock Bank running"

TS=$(date +%s)
seed_roles
setup_test_data "$TS" || { TEST_RESULT=1; exit 1; }
```

## Helper Functions (from setup-infra.sh)

After `source "$SCRIPT_DIR/helpers/setup-infra.sh"`, these are available:

### Logging
```bash
log "message"        # [TEST] message (blue)
log_step "title"     # ━━━ title ━━━ (purple section header)
log_ok "message"     #   ✓ message (green)
log_fail "message"   #   ✗ message (red)
log_warn "message"   #   ⚠ message (yellow)
log_info "message"   #   → message (default)
log_money "message"  #   💰 message (cyan)
```

### API Helper
```bash
api <METHOD> <path> [-d <data>]
# Calls ${BACKEND_URL}<path> with JWT_TOKEN in Authorization header
# Examples:
api POST "/api/v1/system-banks" -d '{"bank_name":"ไทยพาณิชย์",...}'
api GET "/api/v1/wallets/${W_ID}"
api PUT "/api/v1/pools/${POOL_ID}" -d '{"bank_accounts":[...]}'
```

### JSON Parsing
```bash
echo "$RESPONSE" | json_val "['data']['id']"
echo "$RESPONSE" | json_val "['data']['status']"
# Uses python3 — always include 2>/dev/null on json_val calls
```

### Infrastructure Setup
```bash
seed_roles                    # Creates super_admin role (idempotent)
setup_test_data "$TS"         # Creates: admin user, MDR profile, pool, merchant
                              # Exports: JWT_TOKEN, MDR_ID, POOL_ID, MERCHANT_ID
create_client "name" "prefix" # Creates client with wallet
                              # Returns via echo: "CLIENT_ID API_KEY API_SECRET WALLET_ID"
wait_for "$url" "name" 30     # Wait for HTTP 200 response (30s timeout)
```

### Service Control

> [!CAUTION]
> **Test scripts MUST NOT call `start_infra`, `start_backend`, `start_mock_bank`, or `infra_cleanup`.**
> These functions are reserved for `run-integration-test.sh` (the environment launcher) only.
> Calling them inside a test script will:
> - Kill the running backend/mock-bank (SIGKILL 9) that the runner manages
> - Trigger a cascade shutdown of the entire test environment
> - Cause the runner to exit unexpectedly
>
> The correct pattern for Step 1 is to **verify** that services are already running:
> ```bash
> curl -sf "${BACKEND_URL}/swagger/index.html" > /dev/null 2>&1 || {
>   log_fail "Backend not running — run ./run-integration-test.sh first"
>   TEST_RESULT=1; exit 1
> }
> log_ok "Backend running"
>
> curl -sf "${MOCK_BANK_URL}/api/session" > /dev/null 2>&1 || {
>   log_fail "Mock Bank not running — run ./run-integration-test.sh first"
>   TEST_RESULT=1; exit 1
> }
> log_ok "Mock Bank running"
> ```

The only functions that control services are available for reference but are **not for test scripts**:
```bash
# ❌ DO NOT call these in test scripts:
# start_infra       # Docker compose MongoDB + Redis  ← reserved for runner
# start_backend     # Build Go binary, start on :3099  ← reserved for runner
# start_mock_bank   # Start mock bank on :3098          ← reserved for runner
# infra_cleanup     # Kill all processes, docker down   ← reserved for runner
```

### Exported Variables (after setup_test_data)
```bash
$BACKEND_URL      # http://localhost:3099
$MOCK_BANK_URL    # http://localhost:3098
$BACKEND_PORT     # 3099
$MOCK_BANK_PORT   # 3098
$BANK_ACCOUNT     # 9999999999
$BOT_SECRET       # test-bot-secret-123
$PROJECT_DIR      # root of the project
$JWT_TOKEN        # Admin JWT token
$MDR_ID           # MDR profile ID
$POOL_ID          # Pool ID
$MERCHANT_ID      # Merchant ID
$HELPERS_DIR      # path to helpers/ directory
```

## Step-by-Step Patterns

### Pattern 1: Creating an SCB System Bank

> [!IMPORTANT]
> If the bank is used for **settlement**, the `method` list MUST include `"settlement"`
> and `working_status` MUST be set to `'ready'`. Without this the bot silently ignores jobs.

```bash
BANK_ACCOUNT_USE="${BANK_ACCOUNT}"  # or custom 10-digit number

BANK_RES=$(api POST "/api/v1/system-banks" -d "{
  \"bank_name\":\"ไทยพาณิชย์\",\"bank_code\":\"SCB\",\"account_number\":\"${BANK_ACCOUNT_USE}\",
  \"account_name\":\"บริษัท ทดสอบ จำกัด\",\"method\":[\"deposit\",\"payout\",\"settlement\"],\"status\":1,
  \"maximum_deposit_amount\":1000000,\"maximum_number_of_deposits\":999,
  \"promptpay\":\"0899999999\",\"promptpay_type\":\"mobile\"
}")
BANK_ID=$(echo "$BANK_RES" | json_val "['data']['id']")
if [ -z "$BANK_ID" ] || [ "$BANK_ID" = "None" ]; then
  # Fallback: lookup existing bank in MongoDB
  BANK_ID=$(cd "$SCRIPT_DIR" && docker compose exec -T mongodb mongosh payment_gateway_test --quiet --eval "
    const b = db.system_banks.findOne({account_number:'${BANK_ACCOUNT_USE}'});
    if (b) print(b._id.toString()); else print('');
  " 2>/dev/null | tr -d '[:space:]')
fi

# Link to pool
api PUT "/api/v1/pools/${POOL_ID}" -d "{\"bank_accounts\":[{\"bank_id\":\"${BANK_ID}\"}]}" > /dev/null

# Set balance + MUST reset working_status to 'ready' for bot to accept jobs
cd "$SCRIPT_DIR"
docker compose exec -T mongodb mongosh payment_gateway_test --quiet --eval "
  db.system_banks.updateOne(
    {_id: ObjectId('${BANK_ID}')},
    {\$set: {
      available_balance: 1000000,
      balance: 1000000,
      working_status: 'ready',   // ← REQUIRED for payout/settlement jobs
      working_task: '',
      working_at: null
    }}
  );
" > /dev/null 2>&1

# Set credentials for bot (method must match what the bank supports)
api PUT "/api/v1/system-banks/${BANK_ID}" -d "{
  \"method\":[\"deposit\",\"payout\",\"settlement\"],
  \"credentials\":{\"maker\":[{\"username\":\"testmaker\",\"password\":\"testpass\"}],\"approver\":[{\"username\":\"testapprover\",\"password\":\"testpass\"}]},
  \"emails\":{\"maker\":[{\"email\":\"maker@test.local\",\"password\":\"testpass\"}],\"approver\":[{\"email\":\"approver@test.local\",\"password\":\"testpass\"}]}
}" > /dev/null

# Create in mock ledger
curl -s -X POST "${MOCK_BANK_URL}/admin/accounts" \
  -H "Content-Type: application/json" \
  -d "{\"accountNumber\":\"${BANK_ACCOUNT_USE}\",\"bankCode\":\"SCB\",\"accountName\":\"บริษัท ทดสอบ จำกัด\",\"balance\":1000000,\"accountType\":\"system\"}" > /dev/null
```

### Pattern 2: Creating a KTB System Bank
```bash
# Same as SCB but with KTB-specific credentials
api PUT "/api/v1/system-banks/${BID}" -d "{
  \"method\":[\"deposit\",\"payout\"],
  \"credentials\":{\"transfer\":[{\"company_code\":\"TESTCORP\",\"username\":\"ktbuser\",\"password\":\"ktbpass\"}]},
  \"emails\":{\"transfer\":[{\"email\":\"ktb@test.local\",\"password\":\"testpass\"}]}
}" > /dev/null
```

### Pattern 3: Creating a Client
```bash
CLIENT_DATA=$(create_client "ร้านค้า-ชื่อ" "prefix_${TS}")
C_ID=$(echo "$CLIENT_DATA" | awk '{print $1}')
C_KEY=$(echo "$CLIENT_DATA" | awk '{print $2}')
C_SECRET=$(echo "$CLIENT_DATA" | awk '{print $3}')
W_ID=$(echo "$CLIENT_DATA" | awk '{print $4}')

# Fund wallet for payouts
api PUT "/api/v1/wallets/${W_ID}/balance" -d "{\"operation\":\"add\",\"amount\":100000,\"note\":\"Test fund\"}" > /dev/null
```

### Pattern 4: Creating a Deposit Request
```bash
TIMESTAMP=$(python3 -c "import time; print(int(time.time()*1000) + $RANDOM)")
SIG_RESULT=$(node "$HELPERS_DIR/generate-signature.js" jwt "${C_KEY}" "${C_SECRET}" "$TIMESTAMP")
SIGNATURE=$(echo "$SIG_RESULT" | json_val "['signature']")

DEP_RES=$(curl -s -X POST "${BACKEND_URL}/api/v1/deposit/create" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${C_KEY}" \
  -H "X-API-Secret: ${C_SECRET}" \
  -d "{
    \"accountNo\":\"${CUST_ACCOUNT}\",
    \"accName\":\"${CUST_NAME}\",
    \"bankCode\":\"${CUST_BANK}\",
    \"amount\":${AMOUNT},
    \"callbackUrl\":\"https://example.com/callback\",
    \"signature\":\"${SIGNATURE}\",
    \"timestamp\":${TIMESTAMP}
  }")

TXN=$(echo "$DEP_RES" | json_val "['data']['txnId']")
```

### Pattern 5: Simulating a Customer Bank Transfer

> [!WARNING]
> If your test uses a **custom system bank account** (not the default `BANK_ACCOUNT`),
> you MUST pass `systemBankAccount` in the payload.
> Without it, the mock bank routes the deposit to the default account and the bot sees 0 transactions.

```bash
# If using default BANK_ACCOUNT (9999999999):
curl -s -X POST "${MOCK_BANK_URL}/admin/simulate-deposit" \
  -H "Content-Type: application/json" \
  -d "{
    \"amount\": ${AMOUNT},
    \"senderBank\": \"${CUST_BANK}\",
    \"senderAccount\": \"${CUST_ACCOUNT}\",
    \"senderName\": \"${CUST_NAME}\"
  }" > /dev/null

# If using a custom system bank account (e.g., 9999888888):
curl -s -X POST "${MOCK_BANK_URL}/admin/simulate-deposit" \
  -H "Content-Type: application/json" \
  -d "{
    \"amount\": ${AMOUNT},
    \"senderBank\": \"${CUST_BANK}\",
    \"senderAccount\": \"${CUST_ACCOUNT}\",
    \"senderName\": \"${CUST_NAME}\",
    \"systemBankAccount\": \"${MY_BANK_ACCOUNT}\"
  }" > /dev/null
```

### Pattern 6: Creating a Payout Request

```bash
TIMESTAMP=$(python3 -c "import time; print(int(time.time()*1000) + $RANDOM)")
SIG_RESULT=$(node "$HELPERS_DIR/generate-signature.js" jwt "${C_KEY}" "${C_SECRET}" "$TIMESTAMP")
SIGNATURE=$(echo "$SIG_RESULT" | json_val "['signature']")

PAYOUT_RES=$(curl -s -X POST "${BACKEND_URL}/api/v1/payout/create" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${C_KEY}" \
  -H "X-API-Secret: ${C_SECRET}" \
  -d "{
    \"accountNo\":\"${DEST_ACCOUNT}\",
    \"accName\":\"${DEST_NAME}\",
    \"bankCode\":\"${DEST_BANK}\",
    \"amount\":${AMOUNT},
    \"callbackUrl\":\"https://example.com/callback\",
    \"signature\":\"${SIGNATURE}\",
    \"timestamp\":${TIMESTAMP}
  }")

PAY_TXN=$(echo "$PAYOUT_RES" | json_val "['data']['txnId']")
PAY_FEE=$(echo "$PAYOUT_RES" | json_val "['data']['payout_fee']")
```

### Pattern 7: Starting a Bank Bot

> [!IMPORTANT]
> `BANK_URL` MUST use the `?account=<accountNumber>` query param so the bot knows which mock account to log into.
> Format: `${MOCK_BANK_URL}/?account=${BANK_ACCOUNT}` — **NOT** `${MOCK_BANK_URL}/`

```bash
if [ "$NO_BOT" = true ]; then
  echo ""
  echo -e "${YELLOW}  Start the bank-bot manually:${NC}"
  echo "  cd ${PROJECT_DIR}/bank-bot"
  echo "  BANK_URL=${MOCK_BANK_URL}/?account=${BANK_ACCOUNT} HEADLESS=false DRY_RUN=false BANK_ACCOUNT=${BANK_ACCOUNT} BOT_SECRET=${BOT_SECRET} API_URL=${BACKEND_URL} POLL_INTERVAL=5000 DATA_DIR=./data node app.js"
  echo ""
else
  log_info "Starting bank bot..."
  [ ! -d "$PROJECT_DIR/bank-bot/node_modules" ] && { cd "$PROJECT_DIR/bank-bot" && npm install > /dev/null 2>&1; }

  cd "$PROJECT_DIR/bank-bot"
  BANK_URL="${MOCK_BANK_URL}/?account=${BANK_ACCOUNT}" \   # ← must include ?account= 
    HEADLESS=$([ "${TEST_RUNNER_MODE}" = "1" ] && echo true || echo false) \
    DRY_RUN=false \
    BANK_ACCOUNT="${BANK_ACCOUNT}" \
    BOT_SECRET="${BOT_SECRET}" \
    API_URL="${BACKEND_URL}" \
    POLL_INTERVAL=5000 \
    DATA_DIR=./data \
    node app.js > "$SCRIPT_DIR/bank-bot.log" 2>&1 &
  BOT_PID=$!
  log_ok "Bank bot started (PID: $BOT_PID)"
fi
```

### Pattern 8: Polling for Status (Deposit)
```bash
MAX_WAIT=300
for tick in $(seq 1 $MAX_WAIT); do
  CUR=$(curl -s "${BACKEND_URL}/api/v1/deposit/status/${TXN}" | json_val "['data']['status']" 2>/dev/null)
  if [ "$CUR" = "completed" ] || [ "$CUR" = "success" ] || [ "$CUR" = "paid" ]; then
    log_ok "Deposit completed"; break
  fi
  [ "$CUR" = "failed" ] && { log_fail "Deposit failed"; TEST_RESULT=1; break; }
  sleep 1
done
```

### Pattern 9: Polling for Status (Payout)

> [!WARNING]
> **Do NOT use the REST API** (`/api/v1/payout/status`) for completion polling when you need to verify
> MDR fee distribution afterwards. The REST API may return `completed` before the MDR distribution
> MongoDB transaction has fully committed, causing partner wallet reads to return stale values.
>
> Use **MongoDB direct** on `withdrawal_queue` instead, then `sleep 3` before reading partner wallets.

```bash
# CORRECT: MongoDB WQ direct poll (ensures MDR distribution is committed)
for tick in $(seq 1 300); do
  WQ_STATUS=$(cd "$SCRIPT_DIR" && docker compose exec -T mongodb mongosh payment_gateway_test --quiet --eval "
    const wq = db.withdrawal_queue.findOne({source_type: 'payout', request_id: '${PAY_TXN}'});
    if (wq) print(wq.status); else print('not_found');
  " 2>/dev/null | tr -d '[:space:]')

  if [ "$WQ_STATUS" = "success" ]; then
    log_ok "Payout completed (tick: $tick)"
    break
  elif [ "$WQ_STATUS" = "failed" ] || [ "$WQ_STATUS" = "cancelled" ]; then
    log_fail "Payout failed (status=$WQ_STATUS)"; TEST_RESULT=1; break
  fi
  sleep 1
done

[ -n "$BOT_PID" ] && kill "$BOT_PID" 2>/dev/null && BOT_PID=""

# REQUIRED: wait for MDR distribution transaction to commit before reading partner wallets
sleep 3

# ❌ WRONG: REST poll does not guarantee MDR commit timing
# for tick in $(seq 1 600); do
#   CUR=$(curl -s "${BACKEND_URL}/api/v1/payout/status/${PAY_TXN}" | json_val "['data']['status']")
#   [ "$CUR" = "completed" ] && break
# done
```

### Pattern 10: Settlement (Create + Approve + Poll)

> [!WARNING]
> Settlement has several pitfalls compared to deposit/payout:
> - Wallet MUST have sufficient balance BEFORE creating a settlement (it deducts immediately on creation)
> - Approve endpoint is `PUT /api/v1/settlements/{id}/approve` with `{"is_approved":1}` — NOT `/status`
> - The destination account MUST be registered in mock ledger for the bank-bot to transfer
> - Poll `withdrawal_queue` via **MongoDB direct** (most reliable) — do NOT use the REST API for polling

```bash
# Pre-req: fund wallet before creating settlement
FUND_AMOUNT=100000
api PUT "/api/v1/wallets/${W_ID}/balance" -d "{\"operation\":\"add\",\"amount\":${FUND_AMOUNT},\"note\":\"Fund for settlement test\"}" > /dev/null
log_ok "Wallet funded: +${FUND_AMOUNT} THB"

# Register destination in mock ledger
curl -s -X POST "${MOCK_BANK_URL}/admin/accounts" \
  -H "Content-Type: application/json" \
  -d "{\"accountNumber\":\"5556667777\",\"bankCode\":\"SCB\",\"accountName\":\"นาย ถอนเงิน ทดสอบ\",\"balance\":0,\"accountType\":\"customer\"}" > /dev/null

# Create settlement
STL_RES=$(api POST "/api/v1/settlements" -d "{
  \"entity_type\":\"client\",
  \"entity_id\":\"${C_ID}\",
  \"bank_code\":\"SCB\",
  \"bank_account_name\":\"นาย ถอนเงิน ทดสอบ\",
  \"bank_acc_no\":\"5556667777\",
  \"amount\":${STL_AMT},
  \"notes\":\"Integration test\"
}")
STL_ID=$(echo "$STL_RES" | json_val "['data']['id']")
[ -z "$STL_ID" ] || [ "$STL_ID" = "None" ] && { log_fail "Settlement creation failed"; TEST_RESULT=1; }

# Approve — use /approve endpoint (NOT /status)
APPROVE_RES=$(api PUT "/api/v1/settlements/${STL_ID}/approve" -d "{
  \"is_approved\":1,
  \"notes\":\"Approved by integration test\"
}")
APPROVE_OK=$(echo "$APPROVE_RES" | json_val "['success']")
[ "$APPROVE_OK" != "True" ] && [ "$APPROVE_OK" != "true" ] && { log_fail "Settlement approval failed"; TEST_RESULT=1; }

# Poll withdrawal_queue via MongoDB (more reliable than REST API)
SUCCESS=false
for tick in $(seq 1 120); do
  WQ_STATUS=$(cd "$SCRIPT_DIR" && docker compose exec -T mongodb mongosh payment_gateway_test --quiet --eval "
    const wq = db.withdrawal_queue.findOne({source_type: 'settlement', source_id: ObjectId('${STL_ID}')});
    if (wq) print(wq.status); else print('not_found');
  " 2>/dev/null | tr -d '[:space:]')

  if [ "$WQ_STATUS" = "success" ]; then
    log_ok "Settlement withdrawal completed (tick: $tick)"; SUCCESS=true; break
  elif [ "$WQ_STATUS" = "failed" ] || [ "$WQ_STATUS" = "cancelled" ]; then
    log_fail "Settlement failed in queue (status=$WQ_STATUS)"; TEST_RESULT=1; break
  fi
  sleep 2
done

[ "$SUCCESS" = false ] && log_warn "Settlement may still be processing"
```

### Pattern 11: Cross-Check Verification
```bash
# Wallet balance cross-check
EXPECTED_WALLET=$(python3 -c "
initial = float('${INITIAL_WALLET}')
dep_credit = ${DEP_AMT} * (1 - 1.5/100.0)    # 1.5% deposit fee
pay_debit = ${PAY_AMT} * (1 + 2.0/100.0)       # 2.0% payout fee
expected = initial + dep_credit - pay_debit
print(f'{expected:.2f}')
")
ACTUAL_WALLET=$(api GET "/api/v1/wallets/${W_ID}" | json_val "['data']['balance']")

WALLET_MATCH=$(python3 -c "
exp = float('${EXPECTED_WALLET}')
act = float('${ACTUAL_WALLET}')
print('MATCH' if abs(exp - act) < 0.02 else 'MISMATCH')
")

if [ "$WALLET_MATCH" = "MATCH" ]; then
  log_ok "✅ Wallet balance MATCHES expected"
else
  log_fail "❌ Wallet balance MISMATCH"
  TEST_RESULT=1
fi
```

### Pattern 11: Print Passbook (Ledger Visualization)
```bash
print_passbook() {
  local ACC=$1
  curl -s "${MOCK_BANK_URL}/admin/accounts/${ACC}" | python3 -c "
import sys,json
d=json.load(sys.stdin)
a=d['account']; s=d['statements']['items']
print(f'  Account: {a[\"bankCode\"]} {a[\"accountNumber\"]}  ({a[\"accountName\"]})')
print(f'  Balance: {a[\"formattedBalance\"]} THB')
print()
if s:
  print(f'  {\"Date\":<14} {\"Time\":<6} {\"Code\":<5} {\"Description\":<42} {\"Amount\":>12} {\"Balance\":>12}')
  print(f'  {\"-\"*14} {\"-\"*6} {\"-\"*5} {\"-\"*42} {\"-\"*12} {\"-\"*12}')
  for r in s:
    print(f'  {r[\"date\"]:<14} {r[\"time\"]:<6} {r[\"code\"]:<5} {r[\"description\"][:42]:<42} {r[\"amount\"]:>+12,.2f} {r[\"runningBalance\"]:>12,.2f}')
else:
  print('  (no statements)')
" 2>/dev/null
}
```

## Final Summary Pattern

```bash
if [ $TEST_RESULT -eq 0 ]; then
  echo ""
  echo -e "${GREEN}  ✅ ALL <TESTS> PASSED${NC}"
  echo -e "  Backend:   ${BACKEND_URL}"
  echo -e "  Mock Bank: ${MOCK_BANK_URL}"
  echo ""
  # ✅ EXIT CLEANLY — do NOT use `wait` or blocking loops here
  # The test script does NOT own the infrastructure.
  # run-integration-test.sh is responsible for keeping services running.
  exit 0
else
  echo ""
  echo -e "${RED}  ❌ <TEST> FAILED${NC}"
  exit 1
fi
```

> [!NOTE]
> The old pattern of `wait 2>/dev/null || while true; do sleep 3600; done` was only correct
> for **self-contained scripts** that start their own infrastructure. Since all test scripts
> now rely on `run-integration-test.sh` as the environment launcher, they must exit cleanly.

## Test Categories

| Category | Description | Example Tests |
|----------|-------------|---------------|
| **Basic Flow** | Single deposit/payout E2E | `test-deposit-flow.sh`, `test-payout-flow.sh` |
| **Collision** | Same-amount matching accuracy | `test-deposit-collision.sh`, `test-deposit-collision-dual.sh` |
| **FIFO** | Order-preserving matching | `test-deposit-fifo-single.sh`, `test-deposit-fifo-dual.sh` |
| **Burst/Stress** | High-volume performance | `test-burst-deposit.sh`, `test-burst-payout.sh` |
| **Multi-Bank** | Multiple KTB+SCB banks | `test-multi-bank-stress.sh`, `test-split-bank-ktb.sh` |
| **Mixed** | Deposit + Payout simultaneously | `test-mixed-flow.sh`, `test-mixed-burst-ktb.sh` |
| **Bank-Specific** | KTB vs SCB adapter | `test-deposit-ktb.sh`, `test-payout-ktb.sh` |

## MDR Fee Rates (from test MDR profile)

- Deposit fee: **1.5%** (deducted from credited amount)
- Payout fee: **2.0%** (added to wallet debit)
- Topup fee: **1.0%**
- Settlement fee: **1.0%**

## Mock Bank Admin API

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/accounts` | POST | Create bank account in mock ledger |
| `/admin/accounts/:number` | GET | Get account + statements |
| `/admin/simulate-deposit` | POST | Simulate inbound transfer |
| `/admin/reset` | POST | Reset all mock bank state |
| `/admin/set-config` | POST | Set JWT/URL for proxy |
| `/api/session` | GET | Health check (returns session data) |

## Key API Endpoints Used in Tests

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/v1/deposit/create` | POST | API Key + Secret | Create deposit request |
| `/api/v1/deposit/status/:txnId` | GET | None (public) | Check deposit status |
| `/api/v1/deposit/:txnId` | GET | API Key + Secret | Get deposit details |
| `/api/v1/payout/create` | POST | API Key + Secret | Create payout request |
| `/api/v1/payout/status/:txnId` | GET | None (public) | Check payout status |
| `/api/v1/wallets/:id` | GET | JWT | Get wallet balance |
| `/api/v1/wallets/:id/balance` | PUT | JWT | Add/deduct wallet balance |
| `/api/v1/system-banks` | POST | JWT | Create system bank |
| `/api/v1/system-banks/:id` | PUT | JWT | Update system bank |
| `/api/v1/pools/:id` | PUT | JWT | Update pool (link banks) |
| `/api/v1/clients` | POST | JWT | Create client |
| `/api/v1/withdrawal-queue` | GET | JWT | List withdrawal queue |

## Important Notes

1. **🚫 NEVER call infrastructure functions** — `start_infra`, `start_backend`, `start_mock_bank`, `infra_cleanup` are ONLY for `run-integration-test.sh`. Calling them in a test script kills the running environment (SIGKILL 9).
2. **Step 1 = verify, not start** — always check `curl -sf .../swagger/index.html` and `curl -sf .../api/session` at the beginning. Do NOT restart anything.
3. **Cleanup only kills the bot** — the `cleanup_<name>()` trap must only do `kill "$BOT_PID" 2>/dev/null`. No `infra_cleanup`.
4. **Exit cleanly** — on pass, do `exit 0`. No `wait` or `sleep 3600` loops. The runner keeps services alive.
5. **Always support `--no-bot` flag** — allows manual bot startup for debugging
6. **Cross-check is mandatory** — every test must verify final wallet + bank balances match expected values
7. **Use Thai names** — client/customer names in Thai for realistic testing
8. **Sleep after simulating deposits** — `sleep 2` before bot starts to ensure ledger commits
9. **BANK_ACCOUNT default** — `9999999999` for SCB, `7777xxxxxx` for KTB, `8888xxxxxx` for multi-SCB
10. **Unique timestamps** — always use `$(date +%s)` suffix for admin/client names to avoid collisions

### Settlement-Specific Pitfalls (learned from MDR test)

11. **`working_status` must be `'ready'`** — after creating/updating a system bank via MongoDB, always set `working_status: 'ready'`, `working_task: ''`, `working_at: null`. Without this the bot silently ignores payout/settlement jobs.
12. **`method` must include `"settlement"`** — if the bank will handle settlement withdrawals, the `method` array in both the create call and the `PUT /api/v1/system-banks/{id}` call must include `"settlement"`.
13. **Fund wallet BEFORE creating settlement** — settlement deducts `amount + fee` from wallet immediately on creation. If balance is 0 or insufficient, it fails silently.
14. **Approve endpoint is `/approve`, not `/status`** — use `PUT /api/v1/settlements/{id}/approve` with `{"is_approved":1}`. The `/status` endpoint is for rejection only.
15. **Register destination in mock ledger** — the bank account that will receive the settlement transfer must be created via `POST ${MOCK_BANK_URL}/admin/accounts` before approval, otherwise the bot transfer fails.
16. **Poll `withdrawal_queue` via MongoDB** — for settlement completion, query MongoDB directly: `db.withdrawal_queue.findOne({source_type:'settlement', source_id: ObjectId(...)})`. The REST API endpoint may not reflect the correct status field names.

### Payout-Specific Pitfalls (learned from MDR test)

17. **`method` must match ALL transaction types the bank handles** — if the bank will process topup, payout, settlement, and deposit, the `method` array must include ALL of them: `["deposit","payout","topup","settlement"]`. Missing one type means those jobs silently fail ("No topup-enabled bank account found" etc.).
18. **Poll WQ with `request_id`** — when querying the withdrawal queue for payout status, you must use the `request_id` (which matches `txnId`), because the payout create API does not return the internal `_id`. Like this: `db.withdrawal_queue.findOne({source_type: 'payout', request_id: '${PAY_TXN}'})`.
19. **Async MDR Distribution gotcha** — MDR distribution for Payout and Settlement finishes in an asynchronous goroutine *after* the WQ is marked `success`. A simple `sleep 3` is unreliable and can cause inter-step race conditions. Instead, **poll the partner wallet balance** (`findOne` query in a `seq 1 10` loop) until it updates to the expected value, or poll for the `mdr_shared` record creation. Do not proceed to the next test step until the async distribution fully hits the DB.

## Running Tests

```bash
# CORRECT workflow:

# Terminal 1 — start environment (keep running)
cd integration-tests
./run-integration-test.sh

# Terminal 2 — run the test (exits when done)
./test-<your-test>.sh

# ❌ WRONG — do NOT run test scripts in isolation without the runner:
# ./test-<your-test>.sh   # will fail at Step 1 (services not running)
```
