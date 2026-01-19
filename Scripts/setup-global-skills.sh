#!/bin/bash
# Setup skills globally for Claude Code and Codex CLI
#
# Creates:
#   ~/agents/skills/ios-ui-validation/   ← actual skill
#   ~/.claude/skills/ios-ui-validation   ← symlink
#   ~/.codex/skills/ios-ui-validation    ← symlink

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_NAME="ios-ui-validation"

echo "Setting up global skills..."

# Create directories
mkdir -p ~/agents/skills ~/.claude/skills ~/.codex/skills

# Copy skill
if [ -d ~/agents/skills/$SKILL_NAME ]; then
    echo "Removing existing ~/agents/skills/$SKILL_NAME"
    rm -rf ~/agents/skills/$SKILL_NAME
fi
cp -r "$REPO_DIR/agents/skills/$SKILL_NAME" ~/agents/skills/
echo "✓ Copied $SKILL_NAME to ~/agents/skills/"

# Create symlinks
for dir in ~/.claude/skills ~/.codex/skills; do
    if [ -L "$dir/$SKILL_NAME" ] || [ -e "$dir/$SKILL_NAME" ]; then
        rm -rf "$dir/$SKILL_NAME"
    fi
    ln -s "../../agents/skills/$SKILL_NAME" "$dir/$SKILL_NAME"
    echo "✓ Symlinked $dir/$SKILL_NAME"
done

echo ""
echo "Done! Skill available for:"
echo "  • Claude Code (~/.claude/skills/$SKILL_NAME)"
echo "  • Codex CLI   (~/.codex/skills/$SKILL_NAME)"
