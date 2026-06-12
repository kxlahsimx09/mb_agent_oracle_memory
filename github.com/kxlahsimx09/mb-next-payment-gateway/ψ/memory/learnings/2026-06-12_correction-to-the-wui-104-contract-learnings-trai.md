---
title: CORRECTION to the WUI-104 contract learning's trailing mdr-verdict (2026-06-12, 
tags: [next-pm, repo:mb-next-payment-gateway, next, progress, WUI-002, mdr_skip, mdr_shared, wallet, correction, coverage-matrix]
created: 2026-06-12
source: thread #18 msg #240 (WUI-002 framing reconcile); portal origin/main epic-wallet-ui.md + INDEX.md, gateway epic-wallet-ledger.md WALLET-008
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CORRECTION to the WUI-104 contract learning's trailing mdr-verdict (2026-06-12, 

CORRECTION to the WUI-104 contract learning's trailing mdr-verdict (2026-06-12, thread #18 reconcile): the WUI-002 story-attribution was INVERTED in my original verdict. Corrected canonical truth (verified portal origin/main: epic-wallet-ui.md §WUI-002 L69 + INDEX.md L12, gateway epic-wallet-ledger.md WALLET-008):

WUI-002 IS the `mdr_skip` dropped-MDR-revenue dashboard — read-only, cross-partner; aggregates wallet_change_logs rows WHERE operation='mdr_skip' (amount/partner/typed reason/residual-routed cross-ref) over a period. Substrate = gateway WALLET-003 (forward fan-out + mdr_skip) + WALLET-007 (typed mdr_skip reason_code). RBAC partner-revenue:view / wallet-log:view (§ADR-10 D4 + §Amendment 2026-05-31 RM1/RM2/R1 + §ADR-13 §Amendment 2026-06-07 WR2). The portal INDEX label is CORRECT and matches the story.

WHAT WAS WRONG in my WUI-104 mdr-verdict: I wrote "WUI-002 reads mdr_shared" (WRONG — it reads mdr_skip) and cited "WALLET-008 (partner-revenue:view)" as the dropped-revenue home (WRONG — the FINAL gateway WALLET-008 is the MDR-CLAWBACK substrate, mirror of WALLET-003; the OLD dropped-revenue WALLET-008 was renumbered → WUI-002). The technical distinction itself STANDS and is unchanged: mdr_shared = §ADR-10 D3 distribution-snapshot TABLE (positive who-got-what-share, INSERTed at finalize); mdr_skip = §ADR-10 D4 `operation` VALUE on wallet_change_logs (the skipped/un-creditable share). I only swapped which one WUI-002 maps to.

DOC STATUS: requirements docs (portal INDEX + epic-wallet-ui WUI-002 + gateway epic-wallet-ledger) are coherent + correct — NO doc edit, NO next-product-writer PR. The correction was to my own relayed mapping only.

MATRIX: next-ui's /mdr-shared screen reads the mdr_shared distribution table → does NOT satisfy WUI-002 → WUI-002 flips to NOT-BUILT (needs an mdr_skip dashboard). mdr_shared is bound by NO WUI wallet story (001..004 band).

The WUI-104 approve/reject contract (the primary content of learning_2026-06-12_wui-104-deposit-approvereject-actiondata-contrac) is UNAFFECTED — it did not depend on the WUI-002 mapping.

---
*Added via Oracle Learn*
