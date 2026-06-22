---
title: Deployed-shape local test via docker-compose (the "deployed-mirror" pattern) — c
tags: [deployed-mirror, docker-compose, substrate-fidelity, redeploy-gate, local-supabase, testing, deployed-only-bugs]
created: 2026-06-17
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# Deployed-shape local test via docker-compose (the "deployed-mirror" pattern) — c

Deployed-shape local test via docker-compose (the "deployed-mirror" pattern) — campaign `dmirror`, 2026-06-17.

PROBLEM: "Clean-store single-process GREEN is a CONTRACT test, not a DEPLOYMENT test." The §ADR-21 bankbot live-test ran a clean-store in-memory contract test locally, so ~7 deployed-only bugs each surfaced one-at-a-time only on the deployed ECS substrate — every one a 25-45min fix→redeploy→re-run bounce (~7 for the withdraw lane).

PATTERN: mirror the DEPLOY substrate locally by running the SAME image (`build: context:., target:sim` — NO fork/copy, so same-code is STRUCTURAL not a discipline) under docker-compose with the deployed substrate knobs: real entrypoint (not a test factory), durable file store on a volume, ≥2 workers sharing it, a restart between maker-submit and approver-read, and the external gateway via LOCAL Supabase (`supabase start` — all 190 migrations apply, EFs serve, NO cloud-only blocker; repoint via app_settings UPDATE + service_role grants). Gate redeploy on "deployed-shape green" (`dmirror/gate.sh`, ~25s), NOT "clean-store green". Add a fast leg-only entrypoint (`drive-payout.sh`, 0.6s vs ~12min).

RESULT: reproduced 5/7 deployed-only bugs RED (in-memory session wipe, non-durable queue, cross-worker stale-read, FIFO-head stale-task, payout.success callback unwired) + caught a REAL deploy-blocker the contract test could never find (payout-app.js missing from the Docker image → MODULE_NOT_FOUND). 2/7 (CORS, approver tick-timing) are LB/edge BLIND-SPOTS — local Kong injects ACAO:* (masks CORS) + SIM inlines the todo (no async race) — so they MUST be asserted at staging, not locally. Sealed by next-investigator (gate teeth proven via RED-injection on 2 axes).

ADOPTION (so agents USE it, not build-then-ignore): enforced at the CHARTER layer — build-workflow.md + next-dev/next-tester/brew-ops charters redefine redeploy-readiness as deployed-shape green (clean-store/unit green NO LONGER sufficient); the orchestrator confirms gate-green before dispatching any redeploy (dispatch choke-point). PRs: bank-bot #20 (harness), gateway #556 (local-Supabase standup), build-workflow #558, charters #25; Dockerfile fix already on main (#17).

---
*Added via Oracle Learn*
