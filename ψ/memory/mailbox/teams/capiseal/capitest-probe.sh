#!/usr/bin/env bash
# cliread-probe.sh — de-biased probe harness for CLIREAD-001..007 (campaign capitest, next-tester).
#
# Binds EVERY assertion off the SPEC (origin/campaign/capibuild:docs/spec/client-read-api.md) and
# the AC (origin/main:docs/requirements/epic-client-read-api.md). NEVER reads next-dev's supabase/
# implementation. Ground-truth = tester Postgres via the Supabase Management API SQL endpoint
# (read-only GETs for truth; INSERTs only to construct test fixtures).
#
# Stack = tester (ref yupsevcrubgprsbujbpu). Source .secrets/slots/tester.env first.
#
# Subcommands:
#   gate      stack-readiness: 7 EFs respond (not platform-404) + freshness
#   seed      (re)create isolated, tagged fixtures
#   clean     delete fixtures
#   probe     run all CLIREAD-001..007 probes (assumes seeded)
#   selftest  prove the assertion engine FAILS on a violation (trust-the-green check)
#   all       gate -> seed -> probe  (default)
set -uo pipefail

REF="yupsevcrubgprsbujbpu"
MGMT="https://api.supabase.com/v1/projects/$REF/database/query"
BASE="${SUPABASE_URL%/}/functions/v1"
ANON="${SUPABASE_ANON_KEY:-}"

# ---- deterministic fixture identifiers (stable across runs => idempotent) ----
MA="a11a0001-0000-4000-8000-000000000a01"   # merchant for client A
MB="b22b0002-0000-4000-8000-000000000b02"   # merchant for client B (distinct tenant)
CA="c11ead00-0000-4000-8000-0000000000a1"   # client A (probe subject)
CB="c11ead00-0000-4000-8000-0000000000b1"   # client B (cross-tenant)
KEYA="cliread_probe_key_A_b7f3a9c2"          # A's api_key  (X-Client-Id value)
KEYB="cliread_probe_key_B_c8e4d1a5"          # B's api_key
WALA="c11ead00-0000-4000-8000-00000000a111"  # A's wallet
UNKNOWN="00000000-dead-4000-8000-000000000000" # never-exists id
# deposits under A
D_EXPIRED="d0000000-0000-4000-8000-00000000e001" # pending+slipless+past-expiry  (0-lag)
D_PAID="d0000000-0000-4000-8000-00000000e002"    # paid (paidAmount)
D_CANCEL="d0000000-0000-4000-8000-00000000e003"  # pending+slipless+future (fresh-cancel subject)
D_SLIP="d0000000-0000-4000-8000-00000000e004"    # pending+slip-present (SLIP_PRESENT)
D_CHECK="d0000000-0000-4000-8000-00000000e005"   # checking
D_PEND2="d0000000-0000-4000-8000-00000000e006"   # pending+slipless+future (paging/list)
D_REJ="d0000000-0000-4000-8000-00000000e007"     # rejected
DB1="d0000000-0000-4000-8000-00000000b001"       # deposit owned by B (cross-tenant)
# payouts under A
P_OK="9a000000-0000-4000-8000-00000000f001"      # success
P_FAIL="9a000000-0000-4000-8000-00000000f002"    # failed (+failure_message)
P_PROC="9a000000-0000-4000-8000-00000000f003"    # processing
PB1="9a000000-0000-4000-8000-00000000b001"       # payout owned by B (cross-tenant)

PASS=0; FAIL=0; FAILED_LIST=()
RESULTS_JSON="${RESULTS_JSON:-cliread-results.ndjson}"

c_grn(){ printf '\033[32m%s\033[0m' "$1"; }
c_red(){ printf '\033[31m%s\033[0m' "$1"; }

# record a per-AC outcome
rec(){ # rec <PASS|FAIL> <story> <ac> <detail>
  local st="$1" story="$2" ac="$3" det="${4:-}"
  if [ "$st" = PASS ]; then PASS=$((PASS+1)); printf '  [%s] %-12s %s\n' "$(c_grn PASS)" "$story" "$ac";
  else FAIL=$((FAIL+1)); FAILED_LIST+=("$story | $ac | $det"); printf '  [%s] %-12s %s  -- %s\n' "$(c_red FAIL)" "$story" "$ac" "$det"; fi
  printf '{"story":"%s","ac":"%s","result":"%s","detail":"%s"}\n' "$story" "$ac" "$st" "${det//\"/\'}" >> "$RESULTS_JSON"
}

sqlq(){ # sqlq <SQL> -> JSON array on stdout (error JSON surfaces, not swallowed)
  curl -sS -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg q "$1" '{query:$q}')" "$MGMT" 2>/dev/null
}
sqlscalar(){ sqlq "$1" | jq -r '.[0] | (to_entries[0].value) // empty' 2>/dev/null; }

# EF callers: set globals HTTP and BODY. Public calls auto-fallback to anon transport if kong-401.
HTTP=""; BODY=""
_call(){ # _call METHOD path [curl args...]
  local m="$1" p="$2"; shift 2
  local tmp; tmp="$(mktemp)"
  HTTP="$(curl -s -o "$tmp" -w '%{http_code}' -X "$m" "$@" "$BASE/$p")"
  BODY="$(cat "$tmp")"; rm -f "$tmp"
}
ef_public(){ # ef_public METHOD path
  _call "$1" "$2"
  # transport fallback: a kong 401 (missing apikey) is not the EF's contract — retry w/ anon
  if [ "$HTTP" = 401 ] && printf '%s' "$BODY" | grep -qi 'No API key\|apikey\|Missing authorization'; then
    _call "$1" "$2" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"
  fi
}
ef_key(){ # ef_key METHOD path KEY [extra curl args]
  local m="$1" p="$2" k="$3"; shift 3
  _call "$m" "$p" -H "X-Client-Id: $k" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" "$@"
}
ef_nokey(){ _call "$1" "$2" -H "apikey: $ANON" -H "Authorization: Bearer $ANON" "${@:3}"; }
jget(){ printf '%s' "$BODY" | jq -r "$1" 2>/dev/null; }

# =====================================================================================
# GATE — stack readiness
# =====================================================================================
cmd_gate(){
  echo "== STACK-READINESS GATE (tester $REF) =="
  local blocked=0
  for ef in client-deposit-status/$UNKNOWN client-payout-status/$UNKNOWN client-deposits client-payouts \
            client-wallet-balance client-bank-codes client-deposit-cancel; do
    ef_nokey GET "$ef"
    local name="${ef%%/*}"
    if printf '%s' "$BODY" | grep -q '"code":"NOT_FOUND".*Requested function was not found'; then
      printf '  %-26s %s (platform-404: NOT DEPLOYED)\n' "$name" "$(c_red 'MISSING')"; blocked=1
    else
      printf '  %-26s responds HTTP %s %s\n' "$name" "$HTTP" "$(c_grn OK)"
    fi
  done
  if [ "$blocked" = 1 ]; then
    echo ">> GATE: BLOCKED — EF(s) not deployed. Surface to orchestrator; do NOT probe."; return 1
  fi
  echo ">> GATE: EFs respond. Proceeding."; return 0
}

# =====================================================================================
# SEED / CLEAN
# =====================================================================================
WCL="c11ead00-0000-4000-8000-00000000c111"   # wallet change-log (append-only: insert-once)
cmd_clean(){
  # Non-destructive: wallets_change_logs is append-only and merchant_config is FK-locked by
  # callback_queue, so full teardown is impossible. Best-effort delete of the deletable test rows.
  sqlq "delete from ts_deposits where client_id in ('$CA','$CB'); delete from ts_payouts where client_id in ('$CA','$CB'); select 'cleaned' r;" >/dev/null 2>&1 || true
  echo "clean: best-effort (append-only wcl + FK-locked merchant retained; fixtures are upserted)"
}
cmd_seed(){
  # Idempotent UPSERTs (no deletes). final_amount on ts_deposits is GENERATED (amount-deposit_fee).
  local seedsql
  seedsql="
  insert into merchant_config(id,name,callback_url,secret,status) values
    ('$MA','CLIREAD Probe Merchant A','https://example.invalid/cb','s_a','active'),
    ('$MB','CLIREAD Probe Merchant B','https://example.invalid/cb','s_b','active')
   on conflict (id) do nothing;
  insert into client(id,name,merchant_id,api_key,expired_deposit_seconds,status) values
    ('$CA','CLIREAD Probe Client A','$MA','$KEYA',900,'active'),
    ('$CB','CLIREAD Probe Client B','$MB','$KEYB',900,'active')
   on conflict (id) do update set name=excluded.name, merchant_id=excluded.merchant_id,
     api_key=excluded.api_key, expired_deposit_seconds=excluded.expired_deposit_seconds, status='active';
  insert into wallet(id,owner_type,owner_id,balance,frozen,is_active) values
    ('$WALA','client','$CA',10000.00,500.00,true)
   on conflict (id) do update set balance=10000.00, frozen=500.00, is_active=true;
  insert into wallets_change_logs(id,wallet_id,operation,amount,balance_before,balance_after,reference_type,frozen_before,frozen_after,created_at)
    values ('$WCL','$WALA','credit',10000.00,0,10000.00,'probe',0,500.00, now() - interval '10 minutes')
   on conflict (id) do nothing;
  insert into ts_deposits(id,request_id,client_id,amount,deposit_fee,method,callback_url,status,expires_at,paid_at,slip_image_url,slip_uploaded_at,failure_code,failure_message,cancelled_at,last_admin_action_type,created_at) values
   ('$D_EXPIRED','CLIREAD-PROBE-DEP-EXPIRED','$CA',1000.00,20.00,'qr','https://example.invalid/cb','pending', now() - interval '1 hour', null,null,null,null,null,null,null, now() - interval '1 minutes'),
   ('$D_PAID',   'CLIREAD-PROBE-DEP-PAID',   '$CA',1000.00,20.00,'qr','https://example.invalid/cb','paid',    now() + interval '1 hour', now() - interval '30 minutes', null,null,null,null,null,null, now() - interval '2 minutes'),
   ('$D_CANCEL', 'CLIREAD-PROBE-DEP-CANCEL', '$CA',1500.00,20.00,'qr','https://example.invalid/cb','pending', now() + interval '1 hour', null,null,null,null,null,null,null, now() - interval '3 minutes'),
   ('$D_SLIP',   'CLIREAD-PROBE-DEP-SLIP',   '$CA',2000.00,20.00,'manual_transfer','https://example.invalid/cb','pending', now() + interval '1 hour', null,'https://example.invalid/slip.png', now() - interval '5 minutes',null,null,null,null, now() - interval '4 minutes'),
   ('$D_CHECK',  'CLIREAD-PROBE-DEP-CHECK',  '$CA',2500.00,20.00,'qr','https://example.invalid/cb','checking', now() + interval '1 hour', null,null,null,null,null,null,null, now() - interval '5 minutes'),
   ('$D_PEND2',  'CLIREAD-PROBE-DEP-PEND2',  '$CA',3000.00,20.00,'qr','https://example.invalid/cb','pending', now() + interval '1 hour', null,null,null,null,null,null,null, now() - interval '6 minutes'),
   ('$D_REJ',    'CLIREAD-PROBE-DEP-REJ',    '$CA',3500.00,20.00,'qr','https://example.invalid/cb','rejected', now() + interval '1 hour', null,null,null,'admin_rejected','rejected by admin',null,null, now() - interval '7 minutes'),
   ('$DB1','CLIREAD-PROBE-DEP-BCROSS','$CB',1234.00,20.00,'qr','https://example.invalid/cb','pending', now() + interval '1 hour', null,null,null,null,null,null,null, now() - interval '2 minutes')
   on conflict (id) do update set request_id=excluded.request_id, client_id=excluded.client_id, amount=excluded.amount,
     deposit_fee=excluded.deposit_fee, method=excluded.method, callback_url=excluded.callback_url, status=excluded.status,
     expires_at=excluded.expires_at, paid_at=excluded.paid_at, slip_image_url=excluded.slip_image_url,
     slip_uploaded_at=excluded.slip_uploaded_at, failure_code=excluded.failure_code, failure_message=excluded.failure_message,
     cancelled_at=excluded.cancelled_at, last_admin_action_type=excluded.last_admin_action_type, created_at=excluded.created_at;
  insert into ts_payouts(id,request_id,client_id,amount,payout_fee,final_amount,status,dest_bank_code,dest_bank_name,dest_account_number,dest_account_name,bank_transaction_id,failure_code,failure_message,completed_at,callback_url,created_at) values
   ('$P_OK',  'CLIREAD-PROBE-PAY-OK',  '$CA',500.00,5.00,495.00,'success','kbank','Kasikornbank','1234567890','Acme Co','BANKREF123',null,null, now() - interval '20 minutes','https://example.invalid/cb', now() - interval '2 minutes'),
   ('$P_FAIL','CLIREAD-PROBE-PAY-FAIL','$CA',700.00,5.00,695.00,'failed','scb','Siam Commercial Bank','2234567890','Acme Co',null,'bank_rejected','system_error',null,'https://example.invalid/cb', now() - interval '3 minutes'),
   ('$P_PROC','CLIREAD-PROBE-PAY-PROC','$CA',900.00,5.00,895.00,'processing','bbl','Bangkok Bank','3234567890','Acme Co',null,null,null,null,'https://example.invalid/cb', now() - interval '4 minutes'),
   ('$PB1','CLIREAD-PROBE-PAY-BCROSS','$CB',456.00,5.00,451.00,'pending','kbank','Kasikornbank','9999999999',null,null,null,null,null,'https://example.invalid/cb', now() - interval '2 minutes')
   on conflict (id) do update set request_id=excluded.request_id, client_id=excluded.client_id, amount=excluded.amount,
     payout_fee=excluded.payout_fee, final_amount=excluded.final_amount, status=excluded.status, dest_bank_code=excluded.dest_bank_code,
     dest_bank_name=excluded.dest_bank_name, dest_account_number=excluded.dest_account_number, dest_account_name=excluded.dest_account_name,
     bank_transaction_id=excluded.bank_transaction_id, failure_code=excluded.failure_code, failure_message=excluded.failure_message,
     completed_at=excluded.completed_at, created_at=excluded.created_at;
  select 'seeded' as r;"
  local out; out="$(sqlq "$seedsql")"
  if printf '%s' "$out" | grep -q seeded; then echo "seed: OK"; else echo "seed: FAILED -> $out"; return 1; fi
  echo -n "  precond v_deposits.effective_status(D_EXPIRED)="
  sqlscalar "select effective_status from v_deposits where id='$D_EXPIRED'"
}

# =====================================================================================
# PROBES
# =====================================================================================
epoch(){ date -u -d "$1" +%s 2>/dev/null || echo 0; }

probe_001(){
  echo "-- CLIREAD-001 deposit status poll (public) --"
  # shape on a known paid deposit
  ef_public GET "client-deposit-status/$D_PAID"
  [ "$HTTP" = 200 ] && rec PASS CLIREAD-001 "200 public poll (no client auth)" || rec FAIL CLIREAD-001 "200 public poll" "HTTP=$HTTP body=$BODY"
  [ "$(jget '.txnId')" = "$D_PAID" ] && rec PASS CLIREAD-001 "txnId = native ts_deposits.id" || rec FAIL CLIREAD-001 "txnId native id" "got $(jget '.txnId')"
  [ "$(jget '.amount')" = "1000" ] && rec PASS CLIREAD-001 "amount = gross" || rec FAIL CLIREAD-001 "amount" "got $(jget '.amount')"
  [ "$(jget '.status')" = "paid" ] && rec PASS CLIREAD-001 "status field present (paid)" || rec FAIL CLIREAD-001 "status paid" "got $(jget '.status')"
  [ "$(jget '.paidAmount')" = "1000" ] && rec PASS CLIREAD-001 "paidAmount = amount when paid" || rec FAIL CLIREAD-001 "paidAmount" "got $(jget '.paidAmount')"
  # field set exactly (parity field set)
  local keys; keys="$(printf '%s' "$BODY" | jq -rc '[keys_unsorted[]]|sort|join(",")')"
  [ "$keys" = "amount,expiresAt,paidAmount,paidAt,status,txnId" ] && rec PASS CLIREAD-001 "exact parity field set" || rec FAIL CLIREAD-001 "field set" "keys=$keys"
  # paidAmount null when not paid (gate on a real 200 so a down EF can't false-pass on a missing field)
  ef_public GET "client-deposit-status/$D_CANCEL"
  { [ "$HTTP" = 200 ] && [ "$(jget '.status')" != paid ] && [ "$(jget '.paidAmount')" = null ]; } && rec PASS CLIREAD-001 "paidAmount null when !paid" || rec FAIL CLIREAD-001 "paidAmount null" "HTTP=$HTTP status=$(jget '.status') paidAmount=$(jget '.paidAmount')"
  # 0-LAG lazy-expiry TEETH — beat the every-minute sweep-expired-deposits cron: set up D_EXPIRED
  # fresh (pending, just-past expiry, slip-less) and poll inside the sub-minute window; retry on race.
  local zl_ok=0 zl_detail="" attempt eff pre post
  for attempt in 1 2 3 4 5 6; do
    sqlq "update ts_deposits set status='pending', expires_at=now()-interval '3 seconds', slip_image_url=null, slip_uploaded_at=null, expired_at=null, cancelled_at=null where id='$D_EXPIRED'" >/dev/null
    pre="$(sqlscalar "select status from ts_deposits where id='$D_EXPIRED'")"
    [ "$pre" = pending ] || { zl_detail="setup race (pre=$pre)"; continue; }
    ef_public GET "client-deposit-status/$D_EXPIRED"
    eff="$(jget '.status')"
    post="$(sqlscalar "select status from ts_deposits where id='$D_EXPIRED'")"
    if [ "$eff" = expired ] && [ "$post" = pending ]; then zl_ok=1; break; fi
    [ "$eff" = expired ] && zl_detail="sweep flipped physical to '$post' inside poll window (eff=expired ok, race)" || zl_detail="eff=$eff post=$post body=$(printf '%s' "$BODY"|head -c 120)"
  done
  [ "$zl_ok" = 1 ] && rec PASS CLIREAD-001 "0-lag: poll reads expired while physical stays pending (no write-on-read)" || rec FAIL CLIREAD-001 "0-lag lazy-expiry teeth" "$zl_detail"
  # unknown -> 404 deposit_not_found
  ef_public GET "client-deposit-status/$UNKNOWN"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = deposit_not_found ]; } && rec PASS CLIREAD-001 "unknown id -> 404 deposit_not_found" || rec FAIL CLIREAD-001 "unknown 404" "HTTP=$HTTP body=$BODY"
  # 405 non-GET
  ef_public POST "client-deposit-status/$D_PAID"
  [ "$HTTP" = 405 ] && rec PASS CLIREAD-001 "non-GET -> 405" || rec FAIL CLIREAD-001 "405 method" "HTTP=$HTTP body=$BODY"
}

probe_002(){
  echo "-- CLIREAD-002 payout status poll (public) --"
  ef_public GET "client-payout-status/$P_FAIL"
  [ "$HTTP" = 200 ] && rec PASS CLIREAD-002 "200 public poll" || rec FAIL CLIREAD-002 "200" "HTTP=$HTTP body=$BODY"
  [ "$(jget '.txnId')" = "$P_FAIL" ] && rec PASS CLIREAD-002 "txnId = native ts_payouts.id" || rec FAIL CLIREAD-002 "txnId" "got $(jget '.txnId')"
  [ "$(jget '.status')" = failed ] && rec PASS CLIREAD-002 "status (failed)" || rec FAIL CLIREAD-002 "status" "got $(jget '.status')"
  [ "$(jget '.amount')" = "700" ] && rec PASS CLIREAD-002 "amount" || rec FAIL CLIREAD-002 "amount" "got $(jget '.amount')"
  [ "$(jget '.failureReason')" = "system_error" ] && rec PASS CLIREAD-002 "failureReason <- failure_message" || rec FAIL CLIREAD-002 "failureReason" "got $(jget '.failureReason')"
  local keys; keys="$(printf '%s' "$BODY" | jq -rc '[keys_unsorted[]]|sort|join(",")')"
  [ "$keys" = "amount,bankTransactionId,failureReason,status,txnId" ] && rec PASS CLIREAD-002 "exact parity field set" || rec FAIL CLIREAD-002 "field set" "keys=$keys"
  # success payout: bankTransactionId present, failureReason null
  ef_public GET "client-payout-status/$P_OK"
  { [ "$(jget '.bankTransactionId')" = "BANKREF123" ] && [ "$(jget '.failureReason')" = null ]; } && rec PASS CLIREAD-002 "success: bankTxnId set, failureReason null" || rec FAIL CLIREAD-002 "success projection" "bt=$(jget '.bankTransactionId') fr=$(jget '.failureReason')"
  ef_public GET "client-payout-status/$UNKNOWN"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = payout_not_found ]; } && rec PASS CLIREAD-002 "unknown -> 404 payout_not_found" || rec FAIL CLIREAD-002 "unknown 404" "HTTP=$HTTP body=$BODY"
}

probe_003(){
  echo "-- CLIREAD-003 get-by-id own (X-Client-Id) --"
  ef_key GET "client-deposits/$D_CHECK" "$KEYA"
  [ "$HTTP" = 200 ] && rec PASS CLIREAD-003 "own deposit 200" || rec FAIL CLIREAD-003 "own deposit 200" "HTTP=$HTTP body=$BODY"
  [ "$(jget '.txnId')" = "$D_CHECK" ] && rec PASS CLIREAD-003 "deposit txnId" || rec FAIL CLIREAD-003 "deposit txnId" "got $(jget '.txnId')"
  [ "$(jget '.status')" = checking ] && rec PASS CLIREAD-003 "deposit status (effective)" || rec FAIL CLIREAD-003 "deposit status" "got $(jget '.status')"
  { [ "$(jget '.fee')" = "20" ] && [ "$(jget '.netAmount')" = "2480" ] && [ "$(jget '.requestId')" = "CLIREAD-PROBE-DEP-CHECK" ]; } && rec PASS CLIREAD-003 "deposit detail fields (fee/netAmount/requestId)" || rec FAIL CLIREAD-003 "deposit detail" "fee=$(jget '.fee') net=$(jget '.netAmount') req=$(jget '.requestId')"
  ef_key GET "client-payouts/$P_OK" "$KEYA"
  { [ "$HTTP" = 200 ] && [ "$(jget '.txnId')" = "$P_OK" ] && [ "$(jget '.destBankCode')" = kbank ] && [ "$(jget '.netAmount')" = "495" ]; } && rec PASS CLIREAD-003 "own payout 200 + detail" || rec FAIL CLIREAD-003 "own payout" "HTTP=$HTTP body=$BODY"
  # cross-tenant -> 404 (RLS-unreachable, indistinguishable from unknown)
  ef_key GET "client-deposits/$DB1" "$KEYA"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = deposit_not_found ]; } && rec PASS CLIREAD-003 "cross-tenant deposit -> 404 (RLS-unreachable)" || rec FAIL CLIREAD-003 "cross-tenant deposit 404" "HTTP=$HTTP body=$BODY"
  ef_key GET "client-payouts/$PB1" "$KEYA"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = payout_not_found ]; } && rec PASS CLIREAD-003 "cross-tenant payout -> 404" || rec FAIL CLIREAD-003 "cross-tenant payout 404" "HTTP=$HTTP body=$BODY"
  # unknown -> 404 (same shape as cross-tenant)
  ef_key GET "client-deposits/$UNKNOWN" "$KEYA"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = deposit_not_found ]; } && rec PASS CLIREAD-003 "unknown deposit -> 404 (== cross-tenant shape)" || rec FAIL CLIREAD-003 "unknown 404" "HTTP=$HTTP body=$BODY"
  # auth: missing header -> 401
  ef_nokey GET "client-deposits/$D_CHECK"
  [ "$HTTP" = 401 ] && rec PASS CLIREAD-003 "missing X-Client-Id -> 401" || rec FAIL CLIREAD-003 "missing key 401" "HTTP=$HTTP body=$BODY"
  ef_key GET "client-deposits/$D_CHECK" "totally-bogus-key-xyz"
  [ "$HTTP" = 401 ] && rec PASS CLIREAD-003 "invalid key -> 401" || rec FAIL CLIREAD-003 "invalid key 401" "HTTP=$HTTP body=$BODY"
}

probe_004(){
  echo "-- CLIREAD-004 list own + cursor + filters --"
  # full own deposit set (ground-truth ids)
  local own_ids; own_ids="$(sqlq "select id from ts_deposits where client_id='$CA' order by created_at desc, id desc" | jq -rc '[.[].id]|sort|join(",")')"
  local own_n; own_n="$(sqlscalar "select count(*) from ts_deposits where client_id='$CA'")"
  # unfiltered list (limit high) -> all own, only own
  ef_key GET "client-deposits?limit=200" "$KEYA"
  local got_ids; got_ids="$(printf '%s' "$BODY" | jq -rc '[.data[].txnId]|sort|join(",")')"
  [ "$HTTP" = 200 ] && [ "$got_ids" = "$own_ids" ] && rec PASS CLIREAD-004 "list returns exactly own deposit set" || rec FAIL CLIREAD-004 "list own set" "n_db=$own_n got=$got_ids body=$(printf '%s' "$BODY" | head -c 200)"
  # TEETH (a): two cursor pages cover set, no overlap/no gap
  ef_key GET "client-deposits?limit=3" "$KEYA"
  local p1; p1="$(printf '%s' "$BODY" | jq -rc '[.data[].txnId]')"; local cur; cur="$(jget '.nextCursor')"
  local p1n; p1n="$(printf '%s' "$BODY" | jq -r '.count')"
  ef_key GET "client-deposits?limit=3&cursor=$cur" "$KEYA"
  local p2; p2="$(printf '%s' "$BODY" | jq -rc '[.data[].txnId]')"
  local union; union="$(jq -nc --argjson a "$p1" --argjson b "$p2" '($a+$b)')"
  local union_sorted; union_sorted="$(printf '%s' "$union" | jq -rc 'sort|join(",")')"
  local union_uniq; union_uniq="$(printf '%s' "$union" | jq -rc 'unique|join(",")')"
  local first6; first6="$(sqlq "select id from ts_deposits where client_id='$CA' order by created_at desc, id desc limit 6" | jq -rc '[.[].id]|sort|join(",")')"
  if [ "$union_sorted" = "$union_uniq" ] && [ "$union_sorted" = "$first6" ]; then
    rec PASS CLIREAD-004 "cursor: 2 pages cover set, no overlap/no gap"
  else
    rec FAIL CLIREAD-004 "cursor paging teeth" "p1=$p1 p2=$p2 union=$union_sorted expect=$first6"
  fi
  # nextCursor null on last page (gate on a real 200 + data array)
  ef_key GET "client-deposits?limit=200" "$KEYA"
  { [ "$HTTP" = 200 ] && printf '%s' "$BODY" | jq -e '.data|type=="array"' >/dev/null && [ "$(jget '.nextCursor')" = null ]; } && rec PASS CLIREAD-004 "nextCursor null on last (non-full) page" || rec FAIL CLIREAD-004 "nextCursor null" "HTTP=$HTTP nextCursor=$(jget '.nextCursor')"
  # TEETH (b): filters narrow within own. status=paid (sweep-stable terminal — avoids pending/checking race)
  ef_key GET "client-deposits?status=paid&limit=200" "$KEYA"
  local fdb; fdb="$(sqlq "select id from v_deposits where client_id='$CA' and effective_status='paid'" | jq -rc '[.[].id]|sort|join(",")')"
  local fgot; fgot="$(printf '%s' "$BODY" | jq -rc '[.data[].txnId]|sort|join(",")')"
  { [ "$fgot" = "$fdb" ] && printf '%s' "$BODY" | jq -e 'all(.data[]; .status=="paid")' >/dev/null; } && rec PASS CLIREAD-004 "filter status=paid ⊆ own & matches effective_status" || rec FAIL CLIREAD-004 "status filter" "got=$fgot db=$fdb"
  # amount range filter
  ef_key GET "client-deposits?amountMin=2000&amountMax=3000&limit=200" "$KEYA"
  printf '%s' "$BODY" | jq -e 'all(.data[]; .amount>=2000 and .amount<=3000)' >/dev/null && rec PASS CLIREAD-004 "filter amountMin/Max narrows" || rec FAIL CLIREAD-004 "amount range" "body=$(printf '%s' "$BODY"|head -c 200)"
  # transactionId (request_id) exact
  ef_key GET "client-deposits?transactionId=CLIREAD-PROBE-DEP-PAID&limit=200" "$KEYA"
  { [ "$(printf '%s' "$BODY" | jq -r '.data|length')" = 1 ] && [ "$(jget '.data[0].txnId')" = "$D_PAID" ]; } && rec PASS CLIREAD-004 "filter transactionId exact" || rec FAIL CLIREAD-004 "transactionId" "body=$(printf '%s' "$BODY"|head -c 200)"
  # TEETH (c): another tenant's merchantId -> [] (gate on a real 200 + data array of length 0)
  ef_key GET "client-deposits?merchantId=$MB&limit=200" "$KEYA"
  { [ "$HTTP" = 200 ] && printf '%s' "$BODY" | jq -e '.data|type=="array" and length==0' >/dev/null; } && rec PASS CLIREAD-004 "another tenant merchantId -> [] (cannot widen)" || rec FAIL CLIREAD-004 "merchantId other -> []" "HTTP=$HTTP body=$(printf '%s' "$BODY"|head -c 120)"
  # own merchantId -> own rows (positive narrowing)
  ef_key GET "client-deposits?merchantId=$MA&limit=200" "$KEYA"
  [ "$(printf '%s' "$BODY" | jq -rc '[.data[].txnId]|sort|join(",")')" = "$own_ids" ] && rec PASS CLIREAD-004 "own merchantId -> own rows" || rec FAIL CLIREAD-004 "own merchantId" "got=$(printf '%s' "$BODY"|jq -rc '[.data[].txnId]|sort|join(",")')"
  # bad cursor -> 400 invalid_cursor (cleanly-transmitted garbage; avoid %-malformed URLs that trip the edge)
  ef_key GET "client-deposits?cursor=notabase64cursor" "$KEYA"
  { [ "$HTTP" = 400 ] && [ "$(jget '.error')" = invalid_cursor ]; } && rec PASS CLIREAD-004 "bad cursor -> 400 invalid_cursor" || rec FAIL CLIREAD-004 "bad cursor 400" "HTTP=$HTTP body=$BODY"
  # payouts list also own-only
  ef_key GET "client-payouts?limit=200" "$KEYA"
  local pdb; pdb="$(sqlq "select id from ts_payouts where client_id='$CA'" | jq -rc '[.[].id]|sort|join(",")')"
  [ "$(printf '%s' "$BODY" | jq -rc '[.data[].txnId]|sort|join(",")')" = "$pdb" ] && rec PASS CLIREAD-004 "payouts list = own set" || rec FAIL CLIREAD-004 "payouts list" "got=$(printf '%s' "$BODY"|jq -rc '[.data[].txnId]|sort|join(",")') db=$pdb"
}

probe_005(){
  echo "-- CLIREAD-005 wallet balance --"
  ef_key GET "client-wallet-balance" "$KEYA"
  [ "$HTTP" = 200 ] && rec PASS CLIREAD-005 "200 wallet" || rec FAIL CLIREAD-005 "200" "HTTP=$HTTP body=$BODY"
  { [ "$(jget '.clientId')" = "$CA" ] && [ "$(jget '.balance')" = 10000 ] && [ "$(jget '.frozen')" = 500 ] && [ "$(jget '.available')" = 9500 ]; } \
    && rec PASS CLIREAD-005 "balance/frozen/available (available = balance - frozen)" \
    || rec FAIL CLIREAD-005 "balance math" "cid=$(jget '.clientId') bal=$(jget '.balance') frz=$(jget '.frozen') avail=$(jget '.available')"
  [ "$(jget '.name')" = "CLIREAD Probe Client A" ] && rec PASS CLIREAD-005 "name = client.name" || rec FAIL CLIREAD-005 "name" "got $(jget '.name')"
  # updatedAt = latest wallets_change_logs.created_at
  local efua dbua; efua="$(epoch "$(jget '.updatedAt')")"; dbua="$(epoch "$(sqlscalar "select max(created_at) from wallets_change_logs where wallet_id='$WALA'")")"
  { [ "$efua" != 0 ] && [ "$efua" = "$dbua" ]; } && rec PASS CLIREAD-005 "updatedAt = latest change-log created_at" || rec FAIL CLIREAD-005 "updatedAt" "ef=$(jget '.updatedAt') db_epoch=$dbua"
  # client B has no wallet -> 404 wallet_not_found
  ef_key GET "client-wallet-balance" "$KEYB"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = wallet_not_found ]; } && rec PASS CLIREAD-005 "no wallet -> 404 wallet_not_found" || rec FAIL CLIREAD-005 "wallet_not_found" "HTTP=$HTTP body=$BODY"
}

probe_006(){
  echo "-- CLIREAD-006 bank-code list --"
  ef_key GET "client-bank-codes" "$KEYA"
  [ "$HTTP" = 200 ] && rec PASS CLIREAD-006 "200 bank codes" || rec FAIL CLIREAD-006 "200" "HTTP=$HTTP body=$BODY"
  local dbcodes efcodes; dbcodes="$(sqlq "select bank_code from bank order by bank_code" | jq -rc '[.[].bank_code]|join(",")')"
  efcodes="$(printf '%s' "$BODY" | jq -rc '[.data[].code]|join(",")')"
  [ "$efcodes" = "$dbcodes" ] && rec PASS CLIREAD-006 "codes = bank.bank_code set, ordered by code" || rec FAIL CLIREAD-006 "code set/order" "ef=$efcodes db=$dbcodes"
  # name = bank_name; load-bearing pair present
  local kbn; kbn="$(printf '%s' "$BODY" | jq -r '.data[]|select(.code=="kbank").name')"
  [ "$kbn" = "Kasikornbank" ] && rec PASS CLIREAD-006 "name = bank.bank_name" || rec FAIL CLIREAD-006 "name" "kbank name=$kbn"
  # project-what-exists: decoration fields ABSENT (only code/name keys)
  local extra; extra="$(printf '%s' "$BODY" | jq -rc '[.data[0]|keys_unsorted[]]|sort|join(",")')"
  [ "$extra" = "code,name" ] && rec PASS CLIREAD-006 "decoration fields absent (only code,name)" || rec FAIL CLIREAD-006 "P-004 project-what-exists" "row keys=$extra"
}

probe_007(){
  echo "-- CLIREAD-007 self-cancel deposit (write contract) --"
  # fresh-cancel subject must be pending. audit_log is APPEND-ONLY (delete blocked) -> measure audit DELTA,
  # not absolute count (prior-run cancel rows persist).
  local AUDITQ="select count(*) from audit_log where resource_id='$D_CANCEL' and resource_type='deposit' and action_type='cancel' and actor_type='client'"
  sqlq "update ts_deposits set status='pending', cancelled_at=null, last_admin_action_type=null where id='$D_CANCEL'" >/dev/null
  local a0; a0="$(sqlscalar "$AUDITQ")"
  # fresh cancel -> 200 cancelled
  ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$D_CANCEL\"}"
  local fresh_ok=0; { [ "$HTTP" = 200 ] && [ "$(jget '.cancelled')" = true ] && [ "$(jget '.status')" = cancelled ]; } && { fresh_ok=1; rec PASS CLIREAD-007 "fresh cancel -> 200 cancelled"; } || rec FAIL CLIREAD-007 "fresh cancel 200" "HTTP=$HTTP body=$BODY"
  # DB: physical status cancelled + cancelled terminal (!= expired)
  local pstat; pstat="$(sqlscalar "select status from ts_deposits where id='$D_CANCEL'")"
  [ "$pstat" = cancelled ] && rec PASS CLIREAD-007 "DB: terminal = cancelled (≠ expired)" || rec FAIL CLIREAD-007 "DB cancelled terminal" "status=$pstat"
  # audit: exactly ONE NEW client-actor cancel row (delta a1-a0)
  local a1; a1="$(sqlscalar "$AUDITQ")"
  { [ "$fresh_ok" = 1 ] && [ "$((a1-a0))" = 1 ]; } && rec PASS CLIREAD-007 "exactly 1 new audit_log row on fresh cancel (deposit/cancel/client)" || rec FAIL CLIREAD-007 "audit delta on fresh cancel" "a0=$a0 a1=$a1 delta=$((a1-a0))"
  # last_admin_action_* must NOT fire for client actor
  local laa; laa="$(sqlscalar "select coalesce(last_admin_action_type,'<null>') from ts_deposits where id='$D_CANCEL'")"
  { [ "$fresh_ok" = 1 ] && [ "$laa" = "<null>" ]; } && rec PASS CLIREAD-007 "last_admin_action_* NOT set for client actor" || rec FAIL CLIREAD-007 "no admin denorm" "fresh_ok=$fresh_ok last_admin_action_type=$laa"
  # idempotent re-cancel -> 200, no 409, NO new audit row (delta a2-a1 == 0)
  ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$D_CANCEL\"}"
  local a2; a2="$(sqlscalar "$AUDITQ")"
  { [ "$HTTP" = 200 ] && [ "$(jget '.status')" = cancelled ] && [ "$((a2-a1))" = 0 ]; } && rec PASS CLIREAD-007 "idempotent re-cancel -> 200, no new audit row" || rec FAIL CLIREAD-007 "idempotent re-cancel" "HTTP=$HTTP body=$BODY audit_delta=$((a2-a1))"
  # NOT_PENDING (paid deposit) -> 409
  ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$D_PAID\"}"
  { [ "$HTTP" = 409 ] && [ "$(jget '.code')" = NOT_PENDING ]; } && rec PASS CLIREAD-007 "paid deposit -> 409 NOT_PENDING" || rec FAIL CLIREAD-007 "409 NOT_PENDING" "HTTP=$HTTP body=$BODY"
  # SLIP_PRESENT -> 409 (D_SLIP must be pending+slip at cancel time; sweep-slip-escalation races it to checking)
  local sp_ok=0 sp_detail="" a sst
  for a in 1 2 3 4 5 6; do
    sqlq "update ts_deposits set status='pending', slip_image_url='https://example.invalid/slip.png', slip_uploaded_at=now()-interval '5 minutes', cancelled_at=null where id='$D_SLIP'" >/dev/null
    sst="$(sqlscalar "select status from ts_deposits where id='$D_SLIP'")"
    [ "$sst" = pending ] || { sp_detail="setup race (status=$sst)"; continue; }
    ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$D_SLIP\"}"
    if [ "$HTTP" = 409 ] && [ "$(jget '.code')" = SLIP_PRESENT ]; then sp_ok=1; break; fi
    sp_detail="HTTP=$HTTP body=$(printf '%s' "$BODY"|head -c 120)"
  done
  [ "$sp_ok" = 1 ] && rec PASS CLIREAD-007 "slip-present (pending+slip) -> 409 SLIP_PRESENT" || rec FAIL CLIREAD-007 "409 SLIP_PRESENT" "$sp_detail"
  # 403 cross-tenant (B's deposit, A's key) -- DISTINCT from reads' 404 model
  ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$DB1\"}"
  { [ "$HTTP" = 403 ] && [ "$(jget '.error')" = forbidden ]; } && rec PASS CLIREAD-007 "cross-tenant cancel -> 403 forbidden (≠ read 404)" || rec FAIL CLIREAD-007 "403 cross-tenant" "HTTP=$HTTP body=$BODY"
  # 404 unknown
  ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$UNKNOWN\"}"
  { [ "$HTTP" = 404 ] && [ "$(jget '.error')" = deposit_not_found ]; } && rec PASS CLIREAD-007 "unknown cancel -> 404 deposit_not_found" || rec FAIL CLIREAD-007 "404 unknown" "HTTP=$HTTP body=$BODY"
  # 400 missing deposit_id
  ef_key POST "client-deposit-cancel" "$KEYA" -H 'Content-Type: application/json' -d "{}"
  { [ "$HTTP" = 400 ] && [ "$(jget '.error')" = missing_deposit_id ]; } && rec PASS CLIREAD-007 "missing deposit_id -> 400" || rec FAIL CLIREAD-007 "400 missing id" "HTTP=$HTTP body=$BODY"
  # 401 missing key
  ef_nokey POST "client-deposit-cancel" -H 'Content-Type: application/json' -d "{\"deposit_id\":\"$D_PEND2\"}"
  [ "$HTTP" = 401 ] && rec PASS CLIREAD-007 "missing X-Client-Id -> 401" || rec FAIL CLIREAD-007 "401 missing key" "HTTP=$HTTP body=$BODY"
}

cmd_probe(){
  : > "$RESULTS_JSON"
  probe_001; probe_002; probe_003; probe_004; probe_005; probe_006; probe_007
  echo
  echo "================= SUMMARY ================="
  echo "PASS=$PASS  FAIL=$FAIL"
  if [ "$FAIL" -gt 0 ]; then printf 'FAILURES:\n'; printf '  - %s\n' "${FAILED_LIST[@]}"; fi
  echo "results -> $RESULTS_JSON"
  [ "$FAIL" -eq 0 ]
}

# =====================================================================================
# SELFTEST — prove the engine FAILS on a violation (trust-the-green)
# =====================================================================================
cmd_selftest(){
  echo "== HARNESS SELFTEST (must show both a PASS and a FAIL) =="
  local sp=$PASS sf=$FAIL
  # a deliberately TRUE assertion
  [ "1" = "1" ] && rec PASS SELFTEST "control: true assertion records PASS" || rec FAIL SELFTEST "control true" "engine broken"
  # a deliberately FALSE assertion -> must record FAIL
  [ "1" = "2" ] && rec PASS SELFTEST "should-not-happen" || rec FAIL SELFTEST "control: false assertion records FAIL (expected)" "intentional"
  # a real EF-shaped violation: assert a known-good body has a WRONG field
  BODY='{"txnId":"x","status":"paid","amount":1000}'
  [ "$(jget '.status')" = "expired" ] && rec PASS SELFTEST "wrong-expectation" || rec FAIL SELFTEST "control: contradicts body -> FAIL (expected)" "status was paid not expired"
  local dp=$((PASS-sp)) df=$((FAIL-sf))
  echo "selftest produced: PASS+=$dp FAIL+=$df"
  if [ "$dp" -ge 1 ] && [ "$df" -ge 2 ]; then echo ">> SELFTEST OK: engine records green AND red. A later green is trustworthy."; return 0
  else echo ">> SELFTEST BROKEN: engine did not fail-on-violation."; return 1; fi
}

main(){
  [ -n "${SUPABASE_ACCESS_TOKEN:-}" ] || { echo "source .secrets/slots/tester.env first (SUPABASE_ACCESS_TOKEN unset)"; exit 2; }
  command -v jq >/dev/null || { echo "jq required"; exit 2; }
  case "${1:-all}" in
    gate) cmd_gate;;
    seed) cmd_seed;;
    clean) cmd_clean; echo cleaned;;
    probe) cmd_probe;;
    selftest) : > "$RESULTS_JSON"; cmd_selftest;;
    all) cmd_gate && cmd_seed && cmd_probe;;
    *) echo "usage: $0 {gate|seed|clean|probe|selftest|all}"; exit 2;;
  esac
}
main "$@"
