#!/usr/bin/env bash
set -euo pipefail

# vibecode-pro-max-kit installer
# Bootstraps the minimum files needed for vc-setup to run,
# then vc-setup handles the full install with safe merging.

REPO="https://github.com/withkynam/vibecode-pro-max-kit.git"
TMPDIR="/tmp/vc-kit-install-$$"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cleanup() { rm -rf "$TMPDIR" 2>/dev/null; }
trap cleanup EXIT

echo ""
echo "  vibecode-pro-max-kit installer"
echo "  ─────────────────────────────────"
echo ""

# Clone kit to temp
echo "  Fetching kit..."
git clone --depth 1 --quiet "$REPO" "$TMPDIR"

# Read version from manifest
VERSION=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$TMPDIR/vc-manifest.json','utf8')).version)" 2>/dev/null || echo "unknown")
echo "  Kit version: $VERSION"
echo ""

# Detect existing harness
if [ -d ".claude/agents" ] && [ -d ".claude/skills" ]; then
  EXISTING=true
  echo -e "  ${YELLOW}Existing harness detected.${NC}"
  echo "  vc-setup will merge safely (your configs are preserved)."
else
  EXISTING=false
  echo "  Fresh install — copying harness files..."
fi

# For fresh installs, copy everything now
# For existing installs, copy only vc-setup skill + seeds (vc-setup handles the rest)
if [ "$EXISTING" = false ]; then
  # Full bootstrap for fresh projects
  cp -R "$TMPDIR/.claude" .
  cp -R "$TMPDIR/.codex" .
  mkdir -p .agents
  ln -sf ../.claude/skills .agents/skills
  cp "$TMPDIR/CLAUDE.md" .
  cp "$TMPDIR/AGENTS.md" .
  cp "$TMPDIR/vc-manifest.json" .
  mkdir -p process
  cp -R "$TMPDIR/process/_seeds" process/
  cp -R "$TMPDIR/process/development-protocols" process/
  mkdir -p process/context/planning
  cp "$TMPDIR/process/context/planning/"*.md process/context/planning/ 2>/dev/null || true
  echo "$VERSION" > .vc-version
else
  # Minimal bootstrap for existing projects — just enough for vc-setup to run
  mkdir -p .claude/skills
  cp -R "$TMPDIR/.claude/skills/vc-setup" .claude/skills/
  cp -R "$TMPDIR/.claude/skills/vc-update" .claude/skills/
  cp -R "$TMPDIR/.claude/skills/vc-publish" .claude/skills/
  # Seeds needed for scaffold phase
  mkdir -p process
  [ ! -d "process/_seeds" ] && cp -R "$TMPDIR/process/_seeds" process/
  # Manifest needed for version tracking
  [ ! -f "vc-manifest.json" ] && cp "$TMPDIR/vc-manifest.json" .
fi

cleanup

echo ""
if [ "$EXISTING" = false ]; then
  echo -e "  ${GREEN}Harness installed.${NC}"
  echo ""
  echo "  Next steps:"
  echo "    1. cd into your project"
  echo "    2. Run: claude"
  echo '    3. Say:  "Run vc-setup"'
  echo ""
  echo "  vc-setup will study your codebase and auto-populate"
  echo "  project context, test configs, and feature areas."
else
  echo -e "  ${GREEN}Bootstrap complete.${NC}"
  echo ""
  echo "  Next step:"
  echo "    1. Run: claude"
  echo '    2. Say:  "Run vc-setup"'
  echo ""
  echo "  vc-setup will safely merge the full harness into your"
  echo "  existing setup — your configs and hooks are preserved."
fi
echo ""
