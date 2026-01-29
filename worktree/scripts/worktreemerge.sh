#!/bin/bash
# worktreemerge.sh - Merge current worktree branch and clean up
# Usage: worktreemerge.sh [target_branch]

set -e

TARGET_BRANCH="${1:-main}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
    echo "Error: Could not determine current branch"
    exit 1
fi

# Check if we're on the target branch
if [ "$CURRENT_BRANCH" = "$TARGET_BRANCH" ]; then
    echo "Error: Already on target branch ($TARGET_BRANCH). Switch to a feature worktree first."
    exit 1
fi

# Get current worktree path
WORKTREE_PATH=$(pwd)

# Check if this is a worktree (not the main working tree)
MAIN_WORKTREE=$(git worktree list | head -1 | awk '{print $1}')
if [ "$WORKTREE_PATH" = "$MAIN_WORKTREE" ]; then
    echo "Error: Current directory is the main working tree, not a worktree"
    echo "Please run this command from a worktree directory"
    exit 1
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# Fetch latest changes
echo "Fetching latest changes..."
git fetch origin "$TARGET_BRANCH" 2>/dev/null || true

# Go to main worktree
echo "Switching to main worktree..."
cd "$MAIN_WORKTREE"

# Checkout target branch
echo "Checking out $TARGET_BRANCH..."
git checkout "$TARGET_BRANCH"
git pull origin "$TARGET_BRANCH" 2>/dev/null || true

# Merge the feature branch
echo "Merging $CURRENT_BRANCH into $TARGET_BRANCH..."
if git merge "$CURRENT_BRANCH" --no-edit; then
    echo "✅ Merge successful!"

    # Remove the worktree
    echo "Removing worktree at $WORKTREE_PATH..."
    git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || rm -rf "$WORKTREE_PATH"

    # Delete the branch
    echo "Deleting branch $CURRENT_BRANCH..."
    git branch -d "$CURRENT_BRANCH" 2>/dev/null || git branch -D "$CURRENT_BRANCH"

    echo ""
    echo "✅ Cleanup complete!"
    echo "   Merged: $CURRENT_BRANCH -> $TARGET_BRANCH"
    echo "   Removed worktree: $WORKTREE_PATH"
    echo "   Deleted branch: $CURRENT_BRANCH"
    echo ""
    echo "You are now on branch: $TARGET_BRANCH"
else
    echo ""
    echo "❌ Merge failed due to conflicts"
    echo "Please resolve conflicts manually, then run:"
    echo "   git worktree remove $WORKTREE_PATH"
    echo "   git branch -d $CURRENT_BRANCH"
    exit 1
fi
