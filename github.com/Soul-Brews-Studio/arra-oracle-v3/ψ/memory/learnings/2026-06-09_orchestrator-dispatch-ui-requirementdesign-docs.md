---
title: orchestrator dispatch — UI requirement/design docs belong in mb-next-admin-porta
tags: [orchestrator, team-dispatch, ui-docs-convention, mb-next-admin-portal, wui-namespace, ui-substrate-split, next-ui, mb-next-payment-gateway, cross-repo-pointer, p2pui, findings-file-leak, repo:arra-oracle-v3, fleet]
created: 2026-06-09
source: orchestrator session 2026-06-09 — campaign p2pui (UI relocation fix)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — UI requirement/design docs belong in mb-next-admin-porta

orchestrator dispatch — UI requirement/design docs belong in mb-next-admin-portal (WUI-xxx), NEVER the gateway repo. CONVENTION (mb-next payment fleet): UI requirement epics live in `kxlahsimx09/mb-next-admin-portal/docs/requirements/epic-<x>-ui.md` with the `WUI-xxx` story namespace (existing: epic-auth-ui.md, epic-deposit-ui.md, epic-wallet-ui.md; highest id WUI-114 as of 2026-06-09). The backend gateway `kxlahsimx09/mb-next-payment-gateway` holds ONLY the substrate/backend epic (`epic-<x>.md`) plus a CROSS-REPO POINTER — e.g. gateway INDEX.md "Wallet & Ledger": "the operator/admin console UI stories live in mb-next-admin-portal (docs/requirements/epic-wallet-ui.md, WUI-001..004)". The owning role is next-ui dispatched with --repo github.com/kxlahsimx09/mb-next-admin-portal.

MISTAKE (campaign p2preq, 2026-06-08): the orchestrator dispatched next-ui to author `epic-p2p-matching-ui.md` (P2P-UI-xxx ids) INTO the gateway's docs/requirements/ — wrong repo AND wrong namespace. The owner caught it ("P2p matching ui ปนอยู่ใน mb-next-docs... ควรจะไปอยู่อีกที่ไหม เพราะเป็น ui"). FIX (campaign p2pui, 2026-06-09): next-ui ports it to admin-portal as `epic-p2p-ui.md` (renumber P2P-UI-001..007 → WUI-115..121) + the design-ui dir → admin-portal; next-writer removes the misplaced files from the gateway (epic-p2p-matching-ui.md + docs/design/p2p-matching/ui/ + a leaked next-ui_p2pdesign_findings.md junk file) and leaves cross-repo pointers.

RULE: when dispatching ANY UI requirement/design work in this fleet, route next-ui to mb-next-admin-portal and use WUI- ids — never write UI epics into the gateway. Also: agent `*_findings.md` files must NOT be committed into product repos (one leaked to gateway main via PR #354) — they belong in ψ/memory/mailbox/ (the finish-script --merge target), not the repo tree.

---
*Added via Oracle Learn*
