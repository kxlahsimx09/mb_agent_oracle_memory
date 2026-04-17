#!/bin/bash
# Verify that all project symlinks point at this central repo correctly.
# Also report vault_repo Oracle setting + ghost/orphan counts.

CENTRAL=$(ghq list -p kxlahsimx09/mb_agent_oracle_memory 2>/dev/null | head -1)
[ -z "$CENTRAL" ] && { echo "❌ central repo not in ghq"; exit 1; }
echo "Central: $CENTRAL"
echo ""

PROJECTS=(
  "github.com/kokarat/mobiz-payment-gateway"
  "github.com/kokarat/bank-bot"
)

GHQ_ROOT=$(ghq root 2>/dev/null | head -1)
[ -z "$GHQ_ROOT" ] && GHQ_ROOT="$HOME/Code"

echo "=== Oracle runtime symlink (~/.arra-oracle-v2/ψ) ==="
V2_PSI="$HOME/.arra-oracle-v2/ψ"
if [ -L "$V2_PSI" ]; then
  actual=$(readlink "$V2_PSI")
  expected="$CENTRAL/ψ"
  if [ "$actual" = "$expected" ]; then
    echo "  ✅ symlinked → central"
  else
    echo "  ⚠️  points elsewhere: $actual"
  fi
elif [ -d "$V2_PSI" ]; then
  echo "  ❌ real dir (not symlinked) — indexer reads duplicate content"
else
  echo "  ⊘ not present"
fi
echo ""

echo "=== symlink status ==="
for proj in "${PROJECTS[@]}"; do
  link="$GHQ_ROOT/$proj/.agent"
  target="$CENTRAL/$proj/.agent"
  if [ -L "$link" ]; then
    actual=$(readlink "$link")
    if [ "$actual" = "$target" ]; then
      echo "  ✅ $proj → linked"
    else
      echo "  ⚠️  $proj → WRONG TARGET ($actual)"
    fi
  elif [ -d "$link" ]; then
    echo "  ❌ $proj → real dir (not symlinked) at $link"
  elif [ -e "$link" ]; then
    echo "  ❌ $proj → unexpected file at $link"
  else
    echo "  ⊘ $proj → no .agent/ (project not set up)"
  fi
done

echo ""
echo "=== Oracle vault_repo setting ==="
ORACLE_DB="$HOME/.arra-oracle-v2/oracle.db"
if [ -f "$ORACLE_DB" ]; then
  setting=$(sqlite3 "$ORACLE_DB" "SELECT value FROM settings WHERE key='vault_repo';" 2>/dev/null)
  if [ -z "$setting" ]; then
    echo "  ❌ vault_repo NOT set — arra_learn will fall back to cwd"
    echo "  Fix: sqlite3 $ORACLE_DB \"INSERT INTO settings(key,value) VALUES('vault_repo','kxlahsimx09/mb_agent_oracle_memory');\""
  else
    echo "  vault_repo = $setting"
    if [ "$setting" = "kxlahsimx09/mb_agent_oracle_memory" ]; then
      echo "  ✅ points at central repo"
    else
      echo "  ⚠️  points elsewhere — double-check intended target"
    fi
  fi
else
  echo "  ⊘ Oracle DB not found at $ORACLE_DB"
fi

echo ""
echo "=== vault content counts ==="
echo -n "  learnings: "; find "$CENTRAL/ψ/memory/learnings" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' '
echo -n "  resonance: "; find "$CENTRAL/ψ/memory/resonance" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' '
echo -n "  retros:    "; find "$CENTRAL/ψ/memory/retrospectives" -name "*.md" 2>/dev/null | wc -l | tr -d ' '
echo -n "  handoffs:  "; find "$CENTRAL/ψ/inbox/handoff" -name "*.md" 2>/dev/null | wc -l | tr -d ' '

echo ""
echo "=== frontmatter health check (indexed content only) ==="
# indexer scans ψ/memory/{learnings,retrospectives,resonance}/ at REPO_ROOT
# and per-project at <central>/github.com/.../ψ/memory/... . Everything else
# (SKILL.md, AGENTS.md, workflow refs, handoffs) is config, not indexed content.
INDEXED_DIRS=()
for d in learnings retrospectives resonance; do
  INDEXED_DIRS+=("$CENTRAL/ψ/memory/$d")
  while IFS= read -r p; do INDEXED_DIRS+=("$p"); done < <(find "$CENTRAL/github.com" -type d -name "$d" 2>/dev/null)
done

broken_title=""
missing_title=""
for d in "${INDEXED_DIRS[@]}"; do
  [ -d "$d" ] || continue
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    if head -20 "$f" 2>/dev/null | grep -qE "^title:\s*---\s*$"; then
      broken_title="$broken_title$f"$'\n'
    elif ! head -20 "$f" 2>/dev/null | grep -q "^title:"; then
      missing_title="$missing_title$f"$'\n'
    fi
  done < <(find "$d" -name "*.md" 2>/dev/null)
done

if [ -n "$broken_title" ]; then
  echo "  ❌ files with 'title: ---' (arra_learn double-wrap bug):"
  echo "$broken_title" | grep -v '^$' | sed 's|^|    |'
else
  echo "  ✅ no double-wrap ('title: ---') titles in indexed content"
fi

if [ -n "$missing_title" ]; then
  echo "  ⚠️  indexed docs missing 'title:' field (legacy 'name:' format):"
  echo "$missing_title" | grep -v '^$' | sed 's|^|    |'
else
  echo "  ✅ every indexed doc has a title:"
fi

echo ""
echo "=== ghost check (DB rows with no file) ==="
if [ -f "$ORACLE_DB" ]; then
  ghosts=$(sqlite3 "$ORACLE_DB" "SELECT DISTINCT source_file FROM oracle_documents ORDER BY source_file;" | while read f; do
    # check in central vault first, then project vaults
    found=""
    [ -f "$CENTRAL/$f" ] && found=1
    for proj in "${PROJECTS[@]}"; do
      [ -f "$CENTRAL/$proj/$f" ] && found=1
    done
    [ -z "$found" ] && echo "$f"
  done)
  if [ -z "$ghosts" ]; then echo "  ✅ clean (0 ghosts)"; else echo "$ghosts" | sed 's/^/  GHOST: /'; fi
fi
