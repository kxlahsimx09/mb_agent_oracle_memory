---
title: next-ui role + impeccable integration — spec for scaffolding (campaign nextteam,
tags: [nextteam, next-ui, impeccable, ui-design, mb-next-payment-gateway, role-scaffold]
created: 2026-06-01
source: orchestrator campaign nextteam — next-ui role (owner GO 2026-06-01)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# next-ui role + impeccable integration — spec for scaffolding (campaign nextteam,

next-ui role + impeccable integration — spec for scaffolding (campaign nextteam, 2026-06-01, owner GO). 6th new role.

== ROLE next-ui ==
The UI Designer+Implementer for mb-next-payment-gateway. OWNS: the UI of admin-web (design + implementation) — components, design tokens (DESIGN.md), screen/dashboard views. Engine: claude. DOES NOT touch: backend EF/RPC/migrations (next-dev), ADRs (next-architect), tests (next-tester), the per-story acceptance text (next-product-writer). Boundary with next-pm: next-pm owns the DATA / what-to-show (progress board, /live swimlane, /probes data contract); next-ui owns the LOOK + UI implementation — they co-build the dashboards (writer=content vs ui=presentation analogy). Fits the DoD: UI PRs get an `impeccable detect` deterministic gate feeding next-code-reviewer; impeccable critique/audit = design review; live mode = iterate.

== TOOL: impeccable (impeccable.style) ==
NOT a design system to copy — it is a Claude-powered CLI/plugin workflow for iterating UI, and it runs ON Claude Code (our agents are Claude Code → native fit). Loop: plan→build→review→refine. 20 commands across 5 phases (Create: shape/craft; Evaluate: critique/audit; Refine: typeset/animate/colorize/...; Simplify: adapt/clarify/distill; Harden: optimize/polish/onboard). 
- Install: `/plugin marketplace add pbakaus/impeccable` (Claude Code plugin) OR `npx impeccable skills install` OR `npx skills add pbakaus/impeccable`.
- Detector (CI gate, NO LLM): `npx impeccable detect src/` — 41 deterministic rules, JSON output + exit codes for build gates → wire into UI-PR CI, feeds next-code-reviewer.
- Live mode (beta): pick an element in the running dev server, comment/stroke, get 3 variants swapped via framework HMR (needs a running dev server).
- Inherits the project's tokens/components/conventions from `tailwind.config.ts`, `DESIGN.md`, component dirs; uses optional `PRODUCT.md` for product context.
- Works with Claude Code, Cursor, Copilot, Gemini/Codex CLI.

== "ADD THIS SKILL" = TWO LAYERS ==
(1) impeccable PLUGIN = the tool (gives /impeccable commands) — installed via plugin marketplace / npx; next-ui invokes it. (2) next-ui ROLE SKILL.md = our fleet role (brew-ops scaffolds like the other roles) that references the impeccable workflow + commands.

== SETUP next-ui needs in the project (impeccable inherits these) ==
admin-web/DESIGN.md (tokens/conventions), admin-web/PRODUCT.md (product context), tailwind.config.ts (if Tailwind), `npx impeccable detect` in CI for UI PRs. Docs: https://impeccable.style/docs/ + /docs/getting-started/.

---
*Added via Oracle Learn*
