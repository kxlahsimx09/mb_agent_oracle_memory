---
title: **Semantic-unique fraud signal beats content-derived signal — prefer transaction
tags: [fraud-detection, design-pattern, semantic-signal, unique-identifier, duplicate-detection, preventive-check]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Semantic-unique fraud signal beats content-derived signal — prefer transaction

**Semantic-unique fraud signal beats content-derived signal — prefer transaction-IDs, refs, semantic keys over image-hashes, similarity scores, heuristic tuples.**

When designing fraud-detection or duplicate-detection, choose signals that are **semantically unique-per-real-event** wherever the data permits. Properties of semantic signals:

1. **Zero false positives by construction** — e.g. PromptPay `transRef` is issued by the bank per real transfer; two slips with the same `transRef` cannot legitimately come from different transfers. No interpretation needed.
2. **Resilient to content variation** — image hashes break when the fraudster re-renders / Photoshops / crops. OCR-extracted semantic refs survive all of those.
3. **Human-readable error messages** — "slip references transRef `016133201255APP00908` already claimed by deposit DEP1778677752EIG9DK at 2026-05-13 20:14 by AMPAYCS5_EARTH" beats "slip image hash collides with deposit X" — admin can act on the former.
4. **Self-contained lookup** — no external service dependency (vs Thunder cloud isDuplicate).

**Worked example (G3 V1.5 design, 2026-05-20):** mobiz's V1 uses slip-image-hash → admin-role silently bypasses + can be fooled by image variation. Next-system V1.5 uses Thunder-OCR'd `slip_verify_result.rawSlip.transRef` instead → catches the 12 production-confirmed slip-reuse cases with 0 false positives, deterministic, no external lookup at gate time.

**Generalizable pattern:** when a fraud-detection design has a choice between (a) hashing-the-content vs (b) keying-on-the-semantic-id-the-content-references — pick (b) unless (a) catches a class (b) genuinely cannot. The two are complementary (e.g. V1 hash + V1.5 transRef cover different attack shapes — image-tampering vs slip-image-reuse), but if you have to choose, semantic is the higher-quality primary.

---
*Added via Oracle Learn*
