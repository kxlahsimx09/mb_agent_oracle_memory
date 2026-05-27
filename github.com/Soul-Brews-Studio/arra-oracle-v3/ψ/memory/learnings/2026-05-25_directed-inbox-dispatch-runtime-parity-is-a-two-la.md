---
title: Directed-inbox dispatch runtime parity is a two-layer contract, not just a watch
tags: [brew-ops, directed-inbox, codex, engine-parity, maw-js, session-cache]
created: 2026-05-25
source: brew-ops implementation 2026-05-25
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Directed-inbox dispatch runtime parity is a two-layer contract, not just a watch

Directed-inbox dispatch runtime parity is a two-layer contract, not just a watcher flag.

Implementation pattern:
1) The envelope may declare `engine: claude|codex`, `model: <name>`, and `reasoning_effort: <level>`.
2) inbox-watcher passes those through to `maw wake` as `--engine`, `--model`, and `--reasoning-effort` on both fresh and resume paths.
3) After T1 verification, the watcher caches runtime metadata beside the wake-key session id:
   - `thread-<K>.session-engine`
   - `thread-<K>.session-model`
   - `thread-<K>.session-reasoning-effort`
4) Later same-campaign resumes prefer cached runtime metadata over new envelope overrides. This prevents accidental mid-campaign engine/model switches.
5) maw-js owns engine-specific CLI translation: Claude gets `--model` + `--effort`; Codex gets `--model` + `-c model_reasoning_effort="<level>"`, and Codex resume keeps options before the session id (`codex resume [OPTIONS] <sid> [prompt]`).

Operational rule: role/oracle (`to: brew-ops`) and runtime (`engine: codex`, `model: gpt-5.5`) are separate axes. If runtime is omitted, fleet defaults apply; if a wake key already has a verified session, the cached runtime wins.

---
*Added via Oracle Learn*
