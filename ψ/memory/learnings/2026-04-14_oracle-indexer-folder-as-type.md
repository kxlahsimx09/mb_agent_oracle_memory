---
title: Oracle Indexer Uses Folder-as-Type, Not Frontmatter-as-Type
type: learning
tags: [soul-brews-core, oracle-shadow, indexer-behavior, technical-writer, pattern-discovered, gotcha]
related: [2026-04-14_principle-patterns-over-intentions, 2026-04-14_principle-code-is-truth-docs-are-claims]
source: src/indexer/parser.ts@HEAD (arra-oracle-v2)
source_commit: verified 2026-04-14 against src/indexer/parser.ts lines 62-101 and src/indexer/cli.ts lines 32-37
created: 2026-04-14
project: github.com/Soul-Brews-Studio/arra-oracle-v2
---

# Oracle Indexer Uses Folder-as-Type, Not Frontmatter-as-Type

The Oracle indexer determines a document's `type` field **from the subdirectory the file lives in**, not from the `type:` key in the document's YAML frontmatter. The frontmatter `type:` is informational only — the indexer never reads it.

## Evidence

`src/indexer/cli.ts` declares the three source paths as a fixed mapping:

```ts
sourcePaths: {
  resonance:       'ψ/memory/resonance',
  learnings:       'ψ/memory/learnings',
  retrospectives:  'ψ/memory/retrospectives',
}
```

Each subdirectory is handed to a different parser:

- `parseResonanceFile()` → hard-codes `type: 'principle'` (parser.ts:34, 46)
- `parseLearningFile()`  → hard-codes `type: 'learning'`  (parser.ts:84, 94)
- `parseRetroFile()`     → hard-codes `type: 'retro'`     (parser.ts:127)

None of these parsers read the frontmatter `type:` field. They read `title`, `tags`, and `project` from frontmatter — and that's it.

## Consequence (observed, not intended)

On 2026-04-14, four documents written with `type: principle` in frontmatter were placed in `ψ/memory/learnings/` and indexed as `type: learning`. The Oracle Studio UI showed them under "Learning", not "Principle". The frontmatter was technically correct, the filesystem placement was wrong.

Fix applied: `mv ψ/memory/learnings/2026-04-14_principle-*.md ψ/memory/resonance/` → re-index → Studio now shows them under "Principle".

## Mechanics (for future writers)

When writing a vault document, decide **placement first**:

| Intent | Destination folder | Indexed type |
|---|---|---|
| An axiom / manifesto / invariant ("we do X because Y, always") | `ψ/memory/resonance/` | `principle` |
| A factual observation / discovery / gotcha / decision trace | `ψ/memory/learnings/` | `learning` |
| End-of-session reflection (AI Diary, Honest Feedback) | `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md` | `retro` |

The `type:` key in frontmatter is allowed but cosmetic — keep it to match the folder, for human readers of the raw file.

## Why this matters for the tagging convention

The 3-layer tagging convention in `.agent/AGENTS.md` §7a is enforced by **us**, not by the indexer. The indexer will happily index a file with missing tags. That means:

- Discipline is entirely on the writer. Reviewers must check tags at PR time.
- The payoff for tagging discipline is search quality, not indexer acceptance.
- A file placed in the wrong folder produces a silently-wrong `type` — there is no warning.

## Connection to existing principles

This is P-002 (Patterns Over Intentions) observed in the wild: I *intended* `type: principle` via frontmatter, but the system actually does what the code does, not what I meant. Recording the pattern so future writers (including my sibling `next-writer` instance) do not repeat the mistake.

It is also an instance of P-004 (Code is Truth, Documents are Claims): the code said "folder determines type" all along. The frontmatter `type:` key was a document claim that contradicted the code. Code won, as expected.

## Open question

Whether to propose a parser change that honors frontmatter `type:` as an override is out of scope for `technical_writer` — that belongs to whoever owns arra-oracle. Filing this as a learning, not an issue. If maintainers want to tighten the contract, they have the evidence here.
