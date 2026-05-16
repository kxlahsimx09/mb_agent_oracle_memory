// check-mermaid.mjs — Workflow-1 Step 8 mermaid parser gate.
//
// Validates every fenced ```mermaid block in one or more markdown files with
// the REAL mermaid parser — the same grammar Nextra renders the docs hub with.
// This replaces the old grep-for-known-bad-characters check, which was
// whack-a-mole: it caught the token class you already knew about (`->`, `-=`)
// and silently passed the next one (`;` regressed twice — see thread #132).
// A parser catches every structural-token class, known and future.
//
// Usage:   node check-mermaid.mjs <file.md> [<file.md> ...]
// Exit 0 = every block parses clean.
// Exit 1 = at least one block would break the docs-hub render.
//
// Requires `mermaid` resolvable from this script's directory. The Step-8
// recipe installs it into a throwaway dir and copies this script beside it:
//   mkdir -p /tmp/mmv && cd /tmp/mmv && bun add mermaid
//   cp <memory-repo>/.agent/skills/next-product-writer/references/check-mermaid.mjs /tmp/mmv/
//   node /tmp/mmv/check-mermaid.mjs <product-repo>/docs/requirements/epic-<slug>.md
import { readFileSync } from 'node:fs';
import mermaid from 'mermaid';

const FENCE = '`'.repeat(3);            // build the fence — never a literal triple-backtick token
let failed = 0, total = 0;
for (const file of process.argv.slice(2)) {
  const src = readFileSync(file, 'utf8');
  const re = new RegExp(FENCE + 'mermaid\\r?\\n([\\s\\S]*?)' + FENCE, 'g');
  let m, idx = 0;
  while ((m = re.exec(src)) !== null) {
    idx++; total++;
    const startLine = src.slice(0, m.index).split('\n').length;
    try {
      await mermaid.parse(m[1]);
      console.log('PASS  ' + file + ' block #' + idx + ' (line ' + startLine + ')');
    } catch (e) {
      failed++;
      console.error('FAIL  ' + file + ' block #' + idx + ' (line ' + startLine + '): ' + (e.message || e));
    }
  }
}
console.log('\n' + total + ' mermaid block(s), ' + failed + ' failure(s).');
process.exit(failed ? 1 : 0);
