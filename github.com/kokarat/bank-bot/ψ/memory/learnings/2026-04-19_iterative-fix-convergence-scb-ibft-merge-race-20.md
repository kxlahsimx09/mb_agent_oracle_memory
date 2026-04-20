---
title: Iterative fix convergence — SCB IBFT-merge race 2026-04-19. Five commits landed 
tags: [technical-writer, repo:bank-bot, current, scb, maker, iteration, revert-pattern, post-submit-navigation, pre-submit-guard]
created: 2026-04-19
source: git range b423eca..0ea0e80 (5 SCB maker commits)
project: github.com/kokarat/bank-bot
---

# Iterative fix convergence — SCB IBFT-merge race 2026-04-19. Five commits landed 

Iterative fix convergence — SCB IBFT-merge race 2026-04-19. Five commits landed in a single afternoon trying to stop SCB from merging a stale recipient into the current batch when the previous makerFlow call left the transfer page in a dirty state: 357dd7a navigated to dashboard after submit to force SCB to clear the transfer page; 3597cf9 clicked `ทำรายการอื่น` (MakeAnotherTransferBtn, added to selectors.js) from Playwright recording as a more reliable clearer; 1a76685 added a pre-submit abort if more than 1 recipient was visible; f825503 added a pre-submit amount-match abort; 8f68dae reverted everything except the two pre-submit checks after the navigation changes broke recipient adding. Lesson: when a race lives between two portal pages (submit-success vs add-recipient), post-submit cleanup is fragile because SCB's state machine disagrees with the bot's intent (the MakeAnother button reset more than intended). A pre-submit guard that refuses to click Submit when the page contradicts the intended batch is load-bearing because it can't break the happy path — it only fires on contradiction. The revert keeps the selector MakeAnotherTransferBtn out of selectors.js so future edits don't accidentally reintroduce the post-submit navigation path.

---
*Added via Oracle Learn*
