---
title: Vault Principle Provenance — Where Each Principle Actually Came From
type: learning
tags:
  - technical-writer
  - repo:arra-oracle-v2
  - cross
  - soul-brews-core-audit
  - governance
  - provenance
  - decision
  - ratified
related:
  - 2026-04-14_principle-nothing-deleted
  - 2026-04-14_principle-patterns-over-intentions
  - 2026-04-14_principle-external-brain-not-commander
  - 2026-04-14_principle-code-is-truth-docs-are-claims
source: >
  Audit conducted 2026-04-14 by technical_writer agent (Claude session, dev01)
  against ~/.arra-oracle/.claude/knowledge/oracle-philosophy.md@HEAD and the
  four principle files in ψ/memory/resonance/. Ratification by Mobiz (human)
  recorded in chat 2026-04-14 (GMT+7).
created: 2026-04-14
project: github.com/Soul-Brews-Studio/arra-oracle-v2
---

# Vault Principle Provenance — Where Each Principle Actually Came From

Governance trail for the four principles currently stored in `ψ/memory/resonance/` tagged `soul-brews-core`. This exists so future agents (and humans) can see at a glance which rules are inherited verbatim from the Oracle/Shadow philosophy source, which were expanded by a writer, and which were proposed and ratified locally. Without this trail, an agent reading the vault has no way to tell "ecosystem law" from "one writer's opinion that a human accepted."

## The four principles and their provenance

| ID | Title | Origin | Evidence | Status |
|---|---|---|---|---|
| P-001 | Nothing is Deleted | Inherited from `~/.arra-oracle/.claude/knowledge/oracle-philosophy.md` §"Core Principles" item 1 | `oracle-philosophy.md:7-10` | canonical |
| P-002 | Patterns Over Intentions | Same source, item 2 | `oracle-philosophy.md:12-15` | canonical |
| P-003 | External Brain, Not Commander | Same source, item 3 (renamed from "External Brain, Not Command" — technical_writer added the suffix `-er` to make the title a noun phrase) | `oracle-philosophy.md:17-20` | canonical (title diverged minimally) |
| P-004 | Code is Truth, Documents are Claims | **Proposed by technical_writer agent in session on 2026-04-14** while designing the two-instance writer role spanning current + target payment-gateway repos. Not present in upstream `oracle-philosophy.md`. | This file + the P-004 file's new `origin:` and `ratified_by:` frontmatter | **ratified locally** 2026-04-14 by Mobiz (human) |

## How the expansion happened

The upstream `oracle-philosophy.md` states each of P-001 through P-003 as **two or three bullet points only**. Total length of the source doc is 36 lines including whitespace and the "Oracle Keeps the Human Human" header quote.

The four files in `ψ/memory/resonance/` are **longer** — each has "Why", "Mechanics", and "Consequences" sections with concrete agent-operation examples.

Attribution of the expanded content:

- The **core statements** (one-sentence summary + the three/two source bullets) are from upstream.
- The **expansion sections** (Mechanics, Consequences, agent-operation examples, scope notes) were written by technical_writer on 2026-04-14 as operational elaboration. They represent the writer's reading of how the upstream principle *operates* in the Soul-Brews-Studio ecosystem, not new doctrine.
- Expansions for P-001, P-002, P-003 are commentary. The upstream statements remain the canonical reference — if they ever diverge from upstream, upstream wins (per P-004 itself, applied recursively).
- **P-004 is different**: it is not elaboration of an upstream principle, it is a new principle. It does not have an upstream source to defer to.

## Why P-004 was proposed

The `technical_writer` role's core job is reconciling **code** (what the system does) with **documents** (what we said it does). The ecosystem principles P-001 through P-003 describe how memory behaves but do not speak directly to that reconciliation. Without a named rule that "code wins for 'what the system does', documents win for 'what we meant'", the writer has no spine when code and doc disagree — the temptation is to "polish" the doc to look coherent, which violates P-002 (Patterns Over Intentions) silently.

P-004 makes that spine explicit. It gives drift a name and a mechanic: `[DRIFT]` markers, `#drift` tag, trace linking commit → doc → resolution. These mechanics are referenced elsewhere in this vault (`.agent/AGENTS.md` §8 Reality-first writing, `SKILL.md` §7 Doc-code drift is a bug) — they assume P-004 holds.

## The ratification decision

- **Proposer**: technical_writer agent (Claude), 2026-04-14.
- **Reviewer**: Mobiz (human, owner of `github.com/kokarat/mobiz-payment-gateway`).
- **Decision**: Ratify.
- **Reason given**: "ผมว่าดี" (I think it's good) — short-form affirmation in Thai, captured in the chat transcript.
- **Scope of ratification**: Local to the Soul-Brews-Studio vault as used by Mobiz's agent team. Not yet upstream.

This is a **local ratification**. It means:

1. All agents operating against this vault (pg-writer, tester, next-writer when spawned, etc.) treat P-004 as binding, at the same level as P-001 through P-003.
2. The P-004 file carries `tags: [..., ratified]` and frontmatter fields `origin: proposed-by-agent`, `ratified_by: Mobiz`, `ratified_at: 2026-04-14 (GMT+7)` — these signal status so no one needs to re-litigate.
3. This is **not** an upstream commitment. If maintainers of `github.com/Soul-Brews-Studio/arra-oracle-v2` later update `oracle-philosophy.md` to include (or contradict) P-004, we reconcile at that point. Meanwhile, no PR is blocking.

## What to do if P-004 ever gets promoted upstream

If a PR to `oracle-philosophy.md` later adds P-004 (or an equivalent), the reconciliation is:

1. If upstream wording matches the spirit of our P-004 → update our `source:` to cite `oracle-philosophy.md` and keep our ratification metadata as "local pre-ratification before upstream merge".
2. If upstream wording diverges → add a learning documenting the divergence, decide whether to adopt upstream verbatim or keep our phrasing locally, record the decision.

Per P-001 (Nothing is Deleted), the original local-ratification metadata is preserved either way.

## What this audit does NOT do

- It does not change P-001, P-002, or P-003 content. Those remain expanded commentary on upstream bullets.
- It does not remove P-004. The human ratified it; it stays.
- It does not propose a philosophy change at arra-oracle-v2 upstream. That is out of scope for `technical_writer`. A maintainer or the `system_architect` role (when it exists) can pick that up later if desired.

## Discipline for future principle additions

To avoid silent drift-by-authoring in the future, any agent proposing a new `type: principle` document **MUST**:

1. Check `~/.arra-oracle/.claude/knowledge/oracle-philosophy.md` (or wherever the ecosystem source lives at that time) to see whether the proposed principle is already covered.
2. If new, file the principle with frontmatter `origin: proposed-by-agent` and tag `#proposed` **instead of** `#soul-brews-core` until a human ratifies it.
3. On ratification: swap `#proposed` for `#ratified`, add `ratified_by:` / `ratified_at:` / `ratified_in_repo:` frontmatter, and write a learning (like this one) documenting the decision.
4. On rejection: move the file to `ψ/memory/learnings/` with tag `#rejected-principle` and keep it as a decision trace — do not delete (P-001).

This discipline was **not** followed when P-004 was initially created (it was tagged `#soul-brews-core` from the start, without an `origin:` marker). Recording that miss here so the pattern corrects going forward. This is P-002 applied to ourselves: the intent was "write a principle," the pattern was "write a principle with ecosystem-level authority it hadn't earned yet." Fixed now.

## Quick lookup for agents

If you are a future agent reading this and wondering "is principle X canonical upstream?", check the `origin:` and `ratified_by:` frontmatter on the principle file itself. Summary as of this audit:

- **No `origin:` field** OR `origin: upstream` → canonical from `oracle-philosophy.md`, bullets inherited verbatim.
- `origin: proposed-by-agent` + `#proposed` tag → pending ratification, treat as a strong suggestion, not a binding rule.
- `origin: proposed-by-agent` + `#ratified` tag + `ratified_by:` filled → binding within the ratifying scope (this vault / this repo team).

Currently in this vault:
- P-001, P-002, P-003 — no explicit `origin:` → canonical upstream, expanded locally.
- P-004 — `origin: proposed-by-agent`, `ratified_by: Mobiz` → ratified locally, not upstream.
