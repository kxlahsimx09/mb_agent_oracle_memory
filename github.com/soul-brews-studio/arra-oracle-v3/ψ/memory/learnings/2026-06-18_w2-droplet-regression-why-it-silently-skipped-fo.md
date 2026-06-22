---
title: W2 droplet regression — why it silently skipped for ~2 days + two gotchas (threa
tags: [brew-ops, regression, droplet, w2-watcher, REGRESSION_HOST, systemd, proc-environ, gotcha, ordering-bug, pg-tester]
created: 2026-06-18
source: brew-ops 2026-06-18 — thread #21 pg-regression droplet wiring
project: github.com/soul-brews-studio/arra-oracle-v3
---

# W2 droplet regression — why it silently skipped for ~2 days + two gotchas (threa

W2 droplet regression — why it silently skipped for ~2 days + two gotchas (thread #21, 2026-06-18).

SYMPTOM: pg-tester W1 wakes fired daily but `arra-oracle-v3/scripts/regression-then-investigate.sh` ABORTED every run at Step 2.5 "bank-bot is not a git repo" → 0/28 tests run from ~2026-06-16..18; channel saw only 🟡 "Regression skipped". The EC2 fleet host has NO local $MOBIZ/bank-bot clone and no usable Docker — by design regression is meant to delegate to the DO droplet (temp-mb-regression-droplet 178.128.93.199) via REGRESSION_HOST. See [[2026-06-12_fleet-infra-temp-mb-regression-droplet-17812]].

REAL (sole) BUG = ORDERING. The droplet-delegation block (`if [ -n "${REGRESSION_HOST:-}" ]`) sat AFTER the local Step 2/2.5 git-sync + bank-bot precondition, so a host without a local bank-bot clone aborted BEFORE ever reaching delegation. FIX: gate the whole local git-sync (Step 2 + 2.5) behind `if [ -z "${REGRESSION_HOST:-}" ]; then ... fi` so when REGRESSION_HOST is set the script skips straight to the delegation block → exit. regression-on-droplet.sh syncs the droplet's OWN mobiz+bank-bot clones (git fetch/merge on /root/Code/...), so local clones are irrelevant on the delegate path.

GOTCHA 1 — /proc/PID/environ is a RED HERRING for runtime exports. w2-watcher.sh:199 runs `export REGRESSION_HOST=${REGRESSION_HOST:-root@178.128.93.199}` at startup. A var exported at RUNTIME does NOT appear in the PARENT's /proc/PID/environ (that is a snapshot from execve), but forked CHILDREN DO inherit it (it shows in the CHILD's /proc/environ). So the watcher's regression children had REGRESSION_HOST all along — never conclude "env missing" from /proc/<parent>/environ. (A restart is therefore NOT needed to make delegation work; children nohup-exec regression-then-investigate.sh fresh each trigger and inherit the env.)

GOTCHA 2 — w2-watcher is a systemd --user service: `w2-watcher.service` (Restart=always, RestartSec=10/15, WorkingDirectory=main checkout). `bash scripts/w2-watcher.sh stop` only triggers a systemd respawn within ~10-15s (new PID). Proper restart = `systemctl --user restart w2-watcher.service`. Restart is only needed to change the watcher's OWN startup env, not to pick up script edits.

VALIDATION 2026-06-18: full 28-test suite on droplet via fixed path = 25/28 PASS (59m, fresh down -v + up --build). The 3 reds are all pre-existing and NOT infra/not the fix: (a) test-payout-admin-cancel = known dispatcher-timing flake (WQ flipped to processing before the pending assertion; cancel-guard behavior itself correct); (b) test-payout-ktb-post-otp-waiting-to-review = the test self-declares "Expected failure at HEAD (thread #16 drift active) — flips green after bank-bot merges the waiting_to_review dispatcher branch"; (c) test-deposit-slip-fraud = V2 fraud-gate assertions fail (backend-log grep for "FRAUD BLOCK/OVERRIDE" + last-4 payload parse return empty) while V1 + ALL HTTP behavior is correct → test↔prod drift on the V2 path, tester domain to classify (stale test vs real V2 logging regression). test-deposit-refund now PASSES (350s) — the redis-fwd droplet provisioning fix is holding.

---
*Added via Oracle Learn*
