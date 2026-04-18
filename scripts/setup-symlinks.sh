#!/bin/bash
# Setup .agent/ symlinks from project repos to this central repo.
# Run once per machine after cloning mb_agent_oracle_memory via ghq.

set -e

CENTRAL=$(ghq list -p kxlahsimx09/mb_agent_oracle_memory 2>/dev/null | head -1)
if [ -z "$CENTRAL" ]; then
  echo "❌ mb_agent_oracle_memory not found in ghq. Run: ghq get kxlahsimx09/mb_agent_oracle_memory"
  exit 1
fi
echo "Central vault: $CENTRAL"
echo ""

# Project manifest — add new projects here and commit
PROJECTS=(
  "github.com/kokarat/mobiz-payment-gateway"
  "github.com/kokarat/bank-bot"
  "github.com/Soul-Brews-Studio/arra-oracle-v3"
)

GHQ_ROOT=$(ghq root 2>/dev/null | head -1)
[ -z "$GHQ_ROOT" ] && GHQ_ROOT="$HOME/Code"  # fallback for non-standard ghq setup

for proj in "${PROJECTS[@]}"; do
  target="$CENTRAL/$proj/.agent"
  link="$GHQ_ROOT/$proj/.agent"
  proj_dir="$GHQ_ROOT/$proj"

  if [ ! -d "$proj_dir" ]; then
    echo "⊘ skip: $proj (project repo not cloned at $proj_dir)"
    continue
  fi

  if [ ! -d "$target" ]; then
    echo "⊘ skip: $proj (no .agent/ in central at $target)"
    continue
  fi

  if [ -L "$link" ]; then
    current=$(readlink "$link")
    if [ "$current" = "$target" ]; then
      echo "✅ already linked: $proj"
      continue
    else
      echo "⚠️  relinking: $proj (was → $current)"
      rm "$link"
    fi
  elif [ -e "$link" ]; then
    # real dir/file exists — back up first
    backup="$link.bak-$(date +%Y%m%d-%H%M%S)"
    echo "💾 backup: $link → $backup"
    mv "$link" "$backup"
  fi

  ln -s "$target" "$link" && echo "🔗 linked: $proj"
done

echo ""
echo "=== Oracle runtime symlink (~/.arra-oracle-v2/ψ → central/ψ) ==="
# The Oracle indexer scans ORACLE_DATA_DIR (default ~/.arra-oracle-v2/) for ψ/.
# Symlink it into the central repo so the indexer and arra_learn see the same files.
V2_PSI="$HOME/.arra-oracle-v2/ψ"
CENTRAL_PSI="$CENTRAL/ψ"

if [ -L "$V2_PSI" ]; then
  current=$(readlink "$V2_PSI")
  if [ "$current" = "$CENTRAL_PSI" ]; then
    echo "✅ ~/.arra-oracle-v2/ψ already symlinked to central"
  else
    echo "⚠️  ~/.arra-oracle-v2/ψ points elsewhere ($current) — fix manually"
  fi
elif [ -d "$V2_PSI" ]; then
  backup="$V2_PSI.bak-$(date +%Y%m%d-%H%M%S)"
  echo "💾 backup: $V2_PSI → $backup"
  mv "$V2_PSI" "$backup"
  ln -s "$CENTRAL_PSI" "$V2_PSI" && echo "🔗 linked: ~/.arra-oracle-v2/ψ → $CENTRAL_PSI"
elif [ -e "$V2_PSI" ]; then
  echo "⚠️  ~/.arra-oracle-v2/ψ exists as non-dir non-link — fix manually"
else
  mkdir -p "$HOME/.arra-oracle-v2"
  ln -s "$CENTRAL_PSI" "$V2_PSI" && echo "🔗 linked: ~/.arra-oracle-v2/ψ → $CENTRAL_PSI"
fi

echo ""
echo "=== set Oracle vault_repo (DB setting) ==="
ORACLE_DB="$HOME/.arra-oracle-v2/oracle.db"
if [ -f "$ORACLE_DB" ]; then
  current_vr=$(sqlite3 "$ORACLE_DB" "SELECT value FROM settings WHERE key='vault_repo';" 2>/dev/null)
  if [ "$current_vr" = "kxlahsimx09/mb_agent_oracle_memory" ]; then
    echo "✅ vault_repo already set correctly"
  else
    ts=$(date +%s)000
    sqlite3 "$ORACLE_DB" "INSERT OR REPLACE INTO settings (key, value, updated_at) VALUES ('vault_repo', 'kxlahsimx09/mb_agent_oracle_memory', $ts);"
    echo "📝 vault_repo set to kxlahsimx09/mb_agent_oracle_memory"
  fi
else
  echo "⊘ Oracle DB not found at $ORACLE_DB (start Oracle server first)"
fi

echo ""
echo "Done. Run scripts/verify.sh to check state."
