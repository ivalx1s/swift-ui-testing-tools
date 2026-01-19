#!/bin/bash
# Setup skills locally in a project for Claude Code and Codex CLI
#
# Usage: ./setup-project-skills.sh /path/to/your/project
#
# Creates:
#   <project>/agents/skills/ios-ui-validation/   ← actual skill
#   <project>/.claude/skills/ios-ui-validation   ← symlink
#   <project>/.codex/skills/ios-ui-validation    ← symlink

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_NAME="ios-ui-validation"

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/your/project"
    exit 1
fi

PROJECT_DIR="$(cd "$1" && pwd)"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Directory not found: $1"
    exit 1
fi

echo "Setting up skills in: $PROJECT_DIR"

# Create directories
mkdir -p "$PROJECT_DIR/agents/skills" "$PROJECT_DIR/.claude/skills" "$PROJECT_DIR/.codex/skills"

# Copy skill
if [ -d "$PROJECT_DIR/agents/skills/$SKILL_NAME" ]; then
    echo "Removing existing agents/skills/$SKILL_NAME"
    rm -rf "$PROJECT_DIR/agents/skills/$SKILL_NAME"
fi
cp -r "$REPO_DIR/agents/skills/$SKILL_NAME" "$PROJECT_DIR/agents/skills/"
echo "✓ Copied $SKILL_NAME to agents/skills/"

# Create symlinks
for dir in .claude/skills .codex/skills; do
    target="$PROJECT_DIR/$dir/$SKILL_NAME"
    if [ -L "$target" ] || [ -e "$target" ]; then
        rm -rf "$target"
    fi
    ln -s "../../agents/skills/$SKILL_NAME" "$target"
    echo "✓ Symlinked $dir/$SKILL_NAME"
done

# Remove hidden flags (macOS)
chflags nohidden "$PROJECT_DIR/.claude" 2>/dev/null || true
chflags nohidden "$PROJECT_DIR/.codex" 2>/dev/null || true

echo ""
echo "Done! Skill installed in $PROJECT_DIR"
echo ""
echo "Structure:"
echo "  agents/skills/$SKILL_NAME/   ← actual skill"
echo "  .claude/skills/$SKILL_NAME   ← symlink (Claude Code)"
echo "  .codex/skills/$SKILL_NAME    ← symlink (Codex CLI)"
echo ""
echo "Don't forget to add to .gitignore if needed:"
echo "  # Keep agents/ tracked, ignore dot folders if you prefer"
