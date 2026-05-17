---
title: methodology — validate mermaid diagrams by parsing, not by character-grep.
tags: [next-product-writer, repo:cross, next, mermaid, docs-site, workflow, feedback, process, bot-writer, pg-writer, sibling-sync]
created: 2026-05-16
source: .agent/skills/next-product-writer/references/workflow-1-author-requirement.md@1d3dc33
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# methodology — validate mermaid diagrams by parsing, not by character-grep.

methodology — validate mermaid diagrams by parsing, not by character-grep.

A grep-for-known-bad-characters check on mermaid blocks is whack-a-mole: it catches the structural-token class you already know about and silently passes the next one. On mb-next-payment-gateway's epic-payout.md this regressed three times — `" -> "` (PR #117→#118), `" -= "` missed by that fix (→PR #122), then `;` on PAYOUT-009 in PR #133 (thread #132), which slipped a `-`-starter-token grep entirely because the grep was never written to know `;` is also a mermaid statement separator.

The fix: before opening any PR that adds/edits a mermaid block, run every fenced ```mermaid block through the REAL mermaid parser — `mermaid.parse()` from the `mermaid` npm package. It uses the same grammar Nextra renders the docs hub with, needs no browser/DOM, runs in ~1s, and exits non-zero on any block that would break the render. A parser catches every structural-token class — `;`, `->`, `-=`, `--`, `-x`, `-)`, and every future reserved token — whereas a hand-written character regex catches only the classes its author remembered.

Implemented for next-product-writer as Workflow-1 Step 8 (mandatory, blocking gate) + a committed harness `references/check-mermaid.mjs`. SIBLING-SYNC: the same recurrence risk exists in any writer workflow that emits mermaid — bot-writer / pg-writer flow-track W8/W9. Those workflows should adopt the same parser gate in place of any character-grep mermaid check.

Structural tokens that break a sequenceDiagram message string (text after the `Actor->>Actor:` colon): `;` (statement separator), `->` `-=` `--` `-x` `-)` (`-`-starter arrow tokens). Safe: word-internal hyphens (`pre-claim`, `HMAC-signed`), `+=`, and the actor arrows `->>` / `-->>` themselves.

Source: thread #132 (orchestrator escalation). Fix landed: epic-payout.md PAYOUT-009 `;`→`,` (PR #133 branch, commit 31ff8b4); W1 Step 8 + check-mermaid.mjs (mb_agent_oracle_memory@1d3dc33).

---
*Added via Oracle Learn*
