#!/usr/bin/env bun
// Workflow-5 §13c — refined orphan-marker detector.
//
// Counts only LIVE anchors — a marker on a current, unresolved claim line —
// and never P-001 historical narration. The pre-2026-05-16 detector grepped
// every literal marker-string occurrence, so it counted change/revision-log
// bullets, archive files, [RESOLVED:…] entries and past-tense strip prose as
// live markers; the metric then grew every time a strip *succeeded*. See
// learning `2026-05-16_workflow-5-13c-orphan-detector-overcounts-narrati`.
//
//   live anchor  = survives every narration filter below
//   genuine orphan = a live anchor whose referenced thread is closed/answered
//
// Usage:  bun w5-orphan-marker-detect.mjs <repo-root> [<repo-root> …]
// Output: per-repo + fleet totals; each live anchor printed with thread status.

import { Database } from "bun:sqlite";
import { readFileSync } from "fs";
import { execSync } from "child_process";
import { basename } from "path";
import { homedir } from "os";

const MARKER = /\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED-STEP):(\d+)\]/g;
const HISTORY_HEADING = /^#{1,6}\s+(change|revision)\s*(log|history)\b/i;
const RESOLVED = /\[RESOLVED:|RESOLVED via |DRIFT-\d+[^\]]*RESOLVED/i;
const STRIP_NARRATION =
  /\b(stripped|replaced with|no remaining live marker|narrative preservation|originally filed|have been stripped|were stripped)\b/i;

// In scope = live-claim docs only: flow docs + the live ADR doc.
// Out of scope (§13c.7): current-system.md, test-index.md, runbooks, and
// revision-log-archive-*.md (whole-file historical record).
function inScope(relPath) {
  if (/revision-log-archive/i.test(relPath)) return false;
  if (/^docs\/flows\/[^/]+\.md$/.test(relPath)) return true;
  if (basename(relPath) === "adr.md") return true;
  return false;
}

// Line numbers (1-based) that sit inside a change/revision-log section — any
// line whose enclosing heading chain contains a history heading.
function historyLines(text) {
  const headingByLevel = {};
  const inHist = new Set();
  text.split("\n").forEach((line, i) => {
    const h = line.match(/^(#{1,6})\s+/);
    if (h) {
      const lvl = h[1].length;
      headingByLevel[lvl] = line;
      for (let d = lvl + 1; d <= 6; d++) delete headingByLevel[d];
    }
    if (Object.values(headingByLevel).some((hd) => HISTORY_HEADING.test(hd)))
      inHist.add(i + 1);
  });
  return inHist;
}

const db = new Database(homedir() + "/.arra-oracle-v2/oracle.db");
const threadStatus = new Map(
  db.query("SELECT id, status FROM forum_threads").all().map((r) => [r.id, r.status])
);

const repos = process.argv.slice(2);
if (repos.length === 0) {
  console.error("usage: bun w5-orphan-marker-detect.mjs <repo-root> …");
  process.exit(1);
}

let fLive = 0, fOrphan = 0, fExcluded = 0, fHits = 0;

for (const repo of repos) {
  let hits = [];
  try {
    hits = execSync(
      `grep -rnE '\\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED-STEP):[0-9]+\\]' "${repo}/docs/"`,
      { encoding: "utf8" }
    ).trim().split("\n").filter(Boolean);
  } catch {
    hits = [];
  }

  const histCache = new Map();
  const live = [];
  let excluded = 0;

  for (const h of hits) {
    const m = h.match(/^(.+?):(\d+):(.*)$/s);
    if (!m) continue;
    const [, file, lineNo, content] = m;
    const rel = file.replace(repo + "/", "");
    if (!inScope(rel)) { excluded++; continue; }
    if (!histCache.has(file))
      histCache.set(file, historyLines(readFileSync(file, "utf8")));
    if (histCache.get(file).has(+lineNo)) { excluded++; continue; }
    if (RESOLVED.test(content) || STRIP_NARRATION.test(content)) { excluded++; continue; }
    for (const mm of content.matchAll(MARKER)) {
      const st = threadStatus.get(+mm[2]) || "missing";
      live.push({ loc: `${rel}:${lineNo}`, marker: mm[0], status: st });
    }
  }

  const orphans = live.filter((l) => l.status === "closed" || l.status === "answered");
  fHits += hits.length;
  fExcluded += excluded;
  fLive += live.length;
  fOrphan += orphans.length;

  console.log(`\n=== ${basename(repo)} ===`);
  console.log(`  raw grep hits: ${hits.length}  |  excluded (narration/out-of-scope): ${excluded}`);
  console.log(`  live anchors: ${live.length}  |  genuine orphans: ${orphans.length}`);
  for (const l of live)
    console.log(`    ${orphans.includes(l) ? "ORPHAN" : "live  "}  ${l.loc}  ${l.marker}  thread=${l.status}`);
}

console.log(
  `\n=== FLEET TOTAL ===\n  raw hits=${fHits}  excluded=${fExcluded}  live=${fLive}  GENUINE ORPHANS=${fOrphan}`
);
