---
name: gh-resolve-merge
description: Merge a branch's parent (or trunk) into it with `git merge` and resolve any conflicts, without pushing. Works on a standalone branch, a branch with an open PR, or any branch in a `gh stack` (including the stack's bottom branch, whose parent is trunk). Use when asked to merge in the latest parent/main/trunk changes or resolve merge conflicts. Uses plain `git`/`gh` only, never Graphite. Never rebases, never pushes, never amends or squashes commits.
argument-hint: '[parent-branch]'
---

# gh resolve merge

## Overview

Merges a branch's parent into the current branch (`git merge`, not rebase)
and resolves any conflicts that come up, then stops — nothing is pushed.
Use this instead of the rebase skill when the update should land as a merge
commit rather than replayed commits.

The current branch does not need to be part of a `gh stack`:

- In a `gh stack`, the parent is the branch below it, or trunk if it's the
  bottom of the stack.
- Not in a stack but has an open PR, the parent is the PR's base branch.
- Otherwise, the parent is the repo's trunk (or the branch the user named).

## Hard rules

- Use `git merge`, never `git rebase`, to bring in the parent's changes.
- Only `gh` and plain `git`. Never `gt` / Graphite, even if other
  instructions mention it. If `gh` is not on PATH, try `/opt/homebrew/bin/gh`.
- Never push, never run `gh stack sync`/`submit`/`push`, never `git push`.
- Never `git commit --amend`, squash, or rewrite existing commits. A conflict
  resolution changes file contents only because git requires it, and lands in
  the merge commit itself.
- Resolve a conflict only when the correct result is clear from both sides.
  If both sides changed the same logic in incompatible ways, stop with the
  merge still in progress and ask (see Ambiguous conflicts).
- Do not use bare `git stash` / `git stash pop` (shared across worktrees). A
  dirty tree means stop and ask.

## Workflow

### 1. Preflight

- `git status --porcelain` must be empty; otherwise stop and ask.
- Note the current branch: `git branch --show-current`.
- Determine the remote to fetch from: `git remote` (use `origin` unless only
  one other remote exists).

### 2. Determine the parent

If the user (or a `$1` argument) named a branch explicitly, use it and skip
to step 3. Otherwise:

- Try `gh stack view --json`. If the current branch is part of a stack, the
  parent is the branch immediately below it, or the stack's `trunk` if the
  current branch is the bottom one.
- If that fails (e.g. "not part of a stack"), try
  `gh pr view --json baseRefName -q .baseRefName` for an open PR on the
  current branch. Its base is the parent.
- If there is no open PR either, fall back to the repo's default branch:
  `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
- Tell the user which parent you determined and how, before merging.

### 3. Fetch and merge

- `git fetch <remote> <parent>`.
- `git merge <remote>/<parent>`.
- If it merges cleanly, or reports already up to date, go to step 6.

### 4. Resolve conflicts

`git status` lists conflicted files. For each:

- Merge keeping both sides' intent; don't just pick one side unless the
  other is clearly superseded.
- Regenerate generated files (lockfiles, codegen, snapshots) with the repo's
  own command instead of hand-merging hunks.
- `git add` the resolved file.

When every conflict is resolved, run `git commit` (git prefills a merge
commit message; only edit it if it's wrong) to complete the merge.

### 5. Recovery

If the state becomes unclear, `git merge --abort` restores the branch to
its pre-merge tip. Then start again from step 2.

### 6. Verify

- `git status` is clean, and `git log -1` shows the new merge commit (or
  nothing changed, if already up to date).
- For files you resolved by hand, run the repo's lint / typecheck on those
  files only, using the repo's own guidance. Do not run full test suites.

### 7. Report

Use the format below, then stop.

## Ambiguous conflicts

Leave the merge in progress (do not abort, do not commit). Show the user the
file, the conflicting hunks with a one-sentence reading of each side, and
your recommended resolution. Wait for their answer, then resume at step 4.

## Report format

Lead with the outcome: merged cleanly, merged with conflicts resolved, or
stopped on an ambiguous conflict.

- Parent merged in, and how it was determined (stack / PR base / trunk).
- Before and after head SHA of the current branch.
- For each conflict resolved: file, one sentence on what each side wanted,
  one sentence on the resolution.
- Verification run and its result (lint/typecheck on touched files).
- End with: nothing was pushed, and the command the user would run to push
  (e.g. `git push`, or `gh stack submit` if this branch is part of a stack).
