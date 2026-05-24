---
title: DRIFT-2 (deployment helpers absent from CLAUDE.md) extended 2026-05-24 by W2 pas
tags: [technical-writer, repo:bank-bot, current, drift, deployment, aws, claude-md-gap]
created: 2026-05-23
source: docs/current-system.md §8 DRIFT-2
project: github.com/kokarat/bank-bot
---

# DRIFT-2 (deployment helpers absent from CLAUDE.md) extended 2026-05-24 by W2 pas

DRIFT-2 (deployment helpers absent from CLAUDE.md) extended 2026-05-24 by W2 pass fdab647..9245f3f: the entire AWS EC2 deployment family (create-bot-aws.sh + 6 *-aws.sh siblings + README-AWS.md, PR #119 / 9245f3f) is not mentioned anywhere in CLAUDE.md. CLAUDE.md's "Droplet Deployment" section is DigitalOcean-only and describes a "$6/mo DigitalOcean Droplet" with no AWS path at all. This is the largest single addition to DRIFT-2 to date — a whole parallel cloud, not one more helper script. W4 candidate: CLAUDE.md "Droplet Deployment" § should be generalized to cover both clouds or gain an explicit AWS subsection pointing at scripts/README-AWS.md. docs/current-system.md §5.3 (new AWS sub-block) + §8 DRIFT-2 now carry the accurate state; the drift is the CLAUDE.md side, not current-system.md.

---
*Added via Oracle Learn*
