---
title: ## Reviewer rubric upgrade — schema-layer vs SEMANTICS-layer verification of thi
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, gotcha, keep, monitoring, adr-15, workflow-yaml, third-party-engine, semantics-vs-schema, checklist]
created: 2026-06-11
source: PR #408 + #410 reviews 2026-06-11; keephq/keep@v0.53.0 source
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Reviewer rubric upgrade — schema-layer vs SEMANTICS-layer verification of thi

## Reviewer rubric upgrade — schema-layer vs SEMANTICS-layer verification of third-party-engine artifacts (Keep 0.53.0, PRs #408→#410): static source-checking must cover how the engine EVALUATES, not just what shapes it accepts

PR #408 (Telegram routing) was approved after verifying provider SCHEMAS against upstream keephq/keep@v0.53.0 (method signatures, auth-config fields, trigger fields exist). The live smoke then FAILED on three semantic bugs the schema layer cannot see — each verified independently during the #410 re-review:

1. **Template-engine evaluation semantics**: Keep renders mustache (chevron), NOT Jinja — `assert: "{{ steps.X.results | length > 0 }}"` never evaluates (pipe = unresolvable key → falsy → action skipped EVEN WITH ROWS). The bug predated #408 and was masked because every earlier "green" run had 0 rows. Check: what ENGINE renders the expressions, and does the syntax in the artifact belong to that engine?
2. **Data-shape-at-runtime**: the postgres provider returns POSITIONAL TUPLES (plain cursor + fetchall, no dict option) — `{{ foreach.value.<column> }}` can never resolve; fix = `{{ foreach.value.N }}` (chevron's `_get_key` final fallback is `scope[int(child)]`) with the SQL column order pinned as a commented contract + `c{N}_` aliases + `::text` casts. Check: what does the provider RETURN, and can the templating actually address it?
3. **Comparison/type semantics**: `only_on_change: [status]` is structurally inert on 0.53.0 — workflowmanager.py:487 compares getattr(event, field) (AlertStatus ENUM) vs previous_alert.event.get(field) (deserialized STRING) → never equal → guard passes everything. Replacement: trigger CEL `firingCounter == 1` — verified chain: calculated_firing_counter (first=1, re-raise=prev+1, per-event sequential) computed in __save_to_db BEFORE insert_events; CEL activation = event.dict()→json_to_cel so the counter is a plain int; ACK resets to 0 (post-ack re-fire re-pages, correct); resolved never resets (honest Phase-1 limit). Robust to the observed trigger-event DOUBLING (doubled re-raise → both ≥2 → 0 pages; doubled first → 1,2 → 1 page).

Also worth keeping: `throttle: one_until_resolved` keys on the WORKFLOW's last run (get_last_workflow_run), not the alert fingerprint — in a nothing-ever-resolves Phase-1 it passes a 1-page/0-page smoke and then silently suppresses every later DIFFERENT alert. An alternative that passes the smoke but fails production is the most dangerous kind — reject with source citation in the artifact header (the #410 router header does this; exemplary negative documentation).

Operational gotcha (brew-ops): Keep 0.53.0 workflow upload always CREATES, never revises — every re-sync must DELETE the old workflow IDs first.

Rubric addition: for any artifact executed by a third-party engine (workflow YAML, alert rules, CI config), the review covers BOTH layers — (a) schema: fields/signatures the engine accepts; (b) semantics: how the engine evaluates the expressions, what shape the data has at runtime, and the types on each side of every comparison the design depends on. A deploy-side smoke with explicit pass criteria (run#1=1 page, re-raise=0) remains the final arbiter — design the smoke so a wrong-mechanism pass is impossible (the one_until_resolved case shows a smoke that CAN be passed wrongly).

Source: PRs https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/408 + /pull/410 reviews 2026-06-11; brew-ops FINAL DISPATCH execution evidence; keephq/keep@v0.53.0 + chevron source.

---
*Added via Oracle Learn*
