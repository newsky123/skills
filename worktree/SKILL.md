---
name: worktree
description: Git worktree workflow management for feature development. Use when working with git worktrees, creating feature branches with worktree isolation, or merging and cleaning up worktree branches. Provides two commands - worktreenew for creating new feature worktrees (can extract feature name from openspec), and worktreemerge for merging feature branches back to main and cleaning up the worktree.
---

# Git Worktree Workflow

Manage git worktrees for isolated feature development with automatic branch creation and cleanup.

## Commands

### /worktreenew [feature_name]

Create a new git worktree for feature development.

```bash
bash scripts/worktreenew.sh [feature_name]
```

**Parameters:**
- `feature_name` (optional): Name for the feature branch. If omitted, extracts from openspec file.

**Behavior:**
1. If no feature name provided, search for openspec files (`openspec.md`, `OPENSPEC.md`, `spec.md`, `SPEC.md`)
2. Extract feature name from openspec title or `feature:`/`name:` field
3. Create branch `feature/<feature_name>` from latest main/master
4. Create worktree at `../worktrees/<feature_name>`

**Example:**
```bash
# With explicit name
bash scripts/worktreenew.sh user-authentication

# Auto-extract from openspec
bash scripts/worktreenew.sh
```

### /worktreemerge [target_branch]

Merge current worktree branch into target and clean up.

```bash
bash scripts/worktreemerge.sh [target_branch]
```

**Parameters:**
- `target_branch` (optional): Branch to merge into. Default: `main`

**Behavior:**
1. Verify no uncommitted changes
2. Switch to main worktree
3. Checkout and pull target branch
4. Merge feature branch
5. Remove worktree directory
6. Delete feature branch

**Example:**
```bash
# Merge to main (default)
bash scripts/worktreemerge.sh

# Merge to develop
bash scripts/worktreemerge.sh develop
```

## Workflow

```
1. Start feature:     /worktreenew my-feature
2. Work in worktree:  cd ../worktrees/my-feature
3. Commit changes:    git add . && git commit -m "..."
4. Merge & cleanup:   /worktreemerge
```

## Notes

- Worktrees are created in `../worktrees/` relative to repository root
- Branch naming convention: `feature/<feature_name>`
- Feature names are sanitized (lowercase, hyphens)
- Merge conflicts must be resolved manually before cleanup completes
