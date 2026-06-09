# next-writer — campaign p2pui (gateway UI removal)

**Task:** Remove misplaced P2P UI requirement+design from the **gateway** repo (mb-next-payment-gateway); it belongs in **mb-next-admin-portal** (`WUI-xxx`). Leave cross-repo pointers mirroring `epic-wallet-ledger.md → epic-wallet-ui.md (WUI-001..004)`.

**Branch:** `campaign/p2pui` (base `origin/main`) · **PR #359** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/359 (base `main`, **MERGEABLE**, OPEN — owner merges, NOT merged) · commit `5fb0413`

## Removed
- `docs/requirements/epic-p2p-matching-ui.md` (P2P-UI-001..007 + deferred)
- `docs/design/p2p-matching/ui/` (README, admin-dashboard, client-depositor, client-withdrawer)
- `next-ui_p2pdesign_findings.md` (leaked agent findings file at repo root)
- INDEX.md `## P2P Matching — UI` section + all P2P-UI-00x ids

## Cross-repo pointers added (→ mb-next-admin-portal `docs/requirements/epic-p2p-ui.md`, **WUI-115..121**, + `docs/design/p2p-matching/ui/`)
- epic-p2p-matching.md (UI note + Sources), INDEX.md (P2P note), design/p2p-matching/README.md (UI design note), requirements/README.md (catalog row), glossary.md (p2p depositor/withdrawer — removed dangling P2P-UI links).

## Verify: grep across docs/ (excl adr.md) → NO epic-p2p-matching-ui, NO P2P-UI ids, ui/ dir gone, junk file gone.

## Out of scope / flagged
- **docs/adr.md:4201** §ADR-17 propagation-set note still names `epic-p2p-matching-ui.md` — ADR text is **next-architect's** lane; recommend they scrub it.
- Root sibling findings files `next-architect_p2pmode_findings.md`, `next-writer_p2preq2_findings.md` still mention the old ids — not my deliverable, left untouched.
- poc/p2p-matching/web/ui.js — left (old PoC).

**For next-ui:** ensure admin-portal `epic-p2p-ui.md` (WUI-115..121) + `design/p2p-matching/ui/` exist so the gateway cross-repo links resolve.
