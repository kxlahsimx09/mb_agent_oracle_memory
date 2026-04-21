---
title: W9 pass 2026-04-20: flow `scb-dual-control-withdrawal` touched by commits 1cf5e1
tags: [technical-writer, repo:bank-bot, current, flow-track, flow:scb-dual-control-withdrawal, flow-drift, drift]
created: 2026-04-20
source: docs/flows/scb-dual-control-withdrawal.md
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-04-20: flow `scb-dual-control-withdrawal` touched by commits 1cf5e1

W9 pass 2026-04-20: flow `scb-dual-control-withdrawal` touched by commits 1cf5e14..5665f79. Outcome: A=0, B=0, C=3 step drifts inserted (Step 2 clearStaleRecipients row-count fallback removed by `8f68dae`; Step 3 pre-submit safety guards consolidated + post-submit→waiting_to_review by `8f68dae`+`dd5966b`+`6ebee00`; Step 4 no-bankTxnId fallback → waiting_to_review by `9525cff`; Step 8 Approver Phase 2 never-Select-All + ABORT-on-zero-match by `0815737`), D=0, E=0, F=0. Pointers NOT hash-refreshed — SCB flow is still @466d56e and the intent was to mark semantic drifts, not re-verify the full pointer set (most lines in app.js are ≤1644 and unchanged, so A-refresh is safe but not required by this W9 pass). Flow still at S4-ratified-via-thread-18; no Class F trigger (drift count <50% of ~12 numbered steps).

Cross-repo: all four SCB drifts land inside bot territory — the mobiz sibling `withdrawal-queue-dispatch-and-claim` only sees a `// ext: kokarat/bank-bot` marker at its step 5, so mobiz W9 cannot detect these. See `#cross-repo-sync` learning for the boundary mapping.

---
*Added via Oracle Learn*
