#!/bin/bash
# worktreenew.sh - Create a new git worktree for a feature branch
# Usage: worktreenew.sh [feature_name]

set -e

FEATURE_NAME="$1"
WORKTREE_BASE_DIR="../worktrees"

# If no feature name provided, try to get from openspec
if [ -z "$FEATURE_NAME" ]; then
    # Look for openspec file in current directory or common locations
    OPENSPEC_FILE=""
    for f in openspec.md OPENSPEC.md spec.md SPEC.md; do
        if [ -f "$f" ]; then
            OPENSPEC_FILE="$f"
            break
        fi
    done

    if [ -n "$OPENSPEC_FILE" ]; then
        # Try to extract feature name from openspec (look for title or feature field)
        FEATURE_NAME=$(grep -E "^#\s+|^feature:|^Feature:|^name:|^Name:" "$OPENSPEC_FILE" | head -1 | sed 's/^#\s*//;s/^[Ff]eature:\s*//;s/^[Nn]ame:\s*//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    fi

    if [ -z "$FEATURE_NAME" ]; then
        echo "Error: No feature name provided and could not extract from openspec"
        echo "Usage: worktreenew.sh <feature_name>"
        exit 1
    fi
    echo "Extracted feature name from openspec: $FEATURE_NAME"
fi

# Sanitize feature name (lowercase, replace spaces with hyphens, remove leading/trailing hyphens)
FEATURE_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | sed 's/^-*//;s/-*$//')

# Create branch name
BRANCH_NAME="feature/$FEATURE_NAME"
WORKTREE_PATH="$WORKTREE_BASE_DIR/$FEATURE_NAME"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get the main branch name (main or master)
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$MAIN_BRANCH" ]; then
    # No remote, try to detect local main branch
    if git show-ref --verify --quiet refs/heads/main; then
        MAIN_BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        MAIN_BRANCH="master"
    else
        # Use current branch as base
        MAIN_BRANCH=$(git branch --show-current)
    fi
fi

# Create worktree base directory if it doesn't exist
mkdir -p "$WORKTREE_BASE_DIR"

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "Branch $BRANCH_NAME already exists"
    # Check if worktree already exists
    if git worktree list | grep -q "$WORKTREE_PATH"; then
        echo "Worktree already exists at $WORKTREE_PATH"
        exit 0
    fi
    # Create worktree with existing branch
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
    # Create new branch and worktree from main
    git fetch origin "$MAIN_BRANCH" 2>/dev/null || true
    # Try remote first, then local
    if git show-ref --verify --quiet "refs/remotes/origin/$MAIN_BRANCH"; then
        git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "origin/$MAIN_BRANCH"
    else
        git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$MAIN_BRANCH"
    fi
fi

echo ""
echo "✅ Worktree created successfully!"
echo "   Branch: $BRANCH_NAME"
echo "   Path: $WORKTREE_PATH"
echo ""
echo "To start working:"
echo "   cd $WORKTREE_PATH"
