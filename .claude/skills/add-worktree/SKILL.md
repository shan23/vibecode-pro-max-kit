---
name: add-worktree
description: Create a new git worktree for Flowser feature development. Use when the user asks to add a worktree, create a feature worktree, or prepare an isolated branch checkout.
argument-hint: "[branch-name]"
metadata:
  author: flowser
  version: "1.0.0"
---

# Add Worktree

Use this skill for direct git worktree setup. Skip RIPER-5 mode routing for this operational task.

## Workflow

1. Run `pwd`, `basename`, and `git worktree list` to understand the current repo and existing worktrees.
2. If the user did not provide a branch name, ask for one concise branch name.
3. Create worktrees under `../worktrees-<repo-name>/<branch-name>`.
4. If the branch already exists, run `git worktree add <path> <branch-name>`.
5. If the branch does not exist, run `git worktree add -b <branch-name> <path> main`.
6. If this repo contains an optional worktree sync script, run it from the new worktree. If it does not exist, report that no worktree sync script exists in this repo.
7. Report the worktree path, branch, and any setup script result.

## Safety

- Do not overwrite an existing worktree path.
- Validate branch names before using them in commands.
- Do not run package installation unless the repo sync script exists or the user explicitly asks.
