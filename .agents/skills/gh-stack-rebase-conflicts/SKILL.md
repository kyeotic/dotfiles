---
name: gh-stack-rebase-conflicts
description: Rebase every branch of the current `gh stack` onto its parent and trunk, resolving merge conflicts branch by branch, without pushing. Use when asked to rebase, restack, or update a stack, or when `gh stack view` shows ⚠ needs-rebase, or when `gh stack sync` reports rebase conflicts. Uses the `gh stack` CLI only, never Graphite. Never pushes, never submits, never amends or squashes PR commits.
argument-hint: '[--downstack | --upstack | --no-trunk] [branch]'
---

Rebase a `gh stack` locally and resolve conflicts on every branch. Nothing is
pushed; the user pushes afterwards with their own tool.

# Hard rules

- Only `gh stack` and plain `git`. Never `gt` / Graphite, even if other
  instructions mention it. If `gh` is not on PATH, try `/opt/homebrew/bin/gh`.
- Never push. Never run `gh stack sync`, `gh stack submit`, `gh stack push`,
  or `git push`. `sync` force-pushes on success, so it is off limits here.
- Never `git commit --amend`, squash, drop, reorder, or otherwise rewrite the
  commits being replayed. A conflict resolution changes the content of an
  existing commit only because git requires it; do not add new commits.
- Resolve a conflict only when the correct result is clear from both sides.
  If both sides changed the same logic in incompatible ways, stop with the
  rebase still in progress and ask (see Ambiguous conflicts).
- Do not use bare `git stash` / `git stash pop` (the stash is shared across
  worktrees). A dirty tree means stop and ask.

# Steps

1. **Preflight.**
   - `git status --porcelain` must be empty; otherwise stop and ask.
   - `gh stack view --json`: note `trunk`, the ordered `branches[]`, and which
     are `isMerged`. Not in a stack: say so and stop.
   - `git worktree list`: a stack branch checked out elsewhere cannot be
     rebased and makes `gh stack rebase` roll back. Run `--downstack` from the
     branch below it and report the rest as skipped.
   - `git fetch <remote> <trunk>`. If no worktree has trunk checked out, also
     `git fetch <remote> <trunk>:<trunk>` so the tool records bases against a
     current local trunk.

2. **Audit recorded bases.** `$(git rev-parse --git-dir)/gh-stack` stores a
   `base` per branch, used as the old base for `git rebase --onto`. A stale
   base replays parent commits, showing up as dozens of picks and conflicts
   in files the stack never touched. For each open branch, bottom first,
   `git log --oneline <recorded-base>..<branch>` must list only the branch's
   own commits. The correct base is the parent's tip; for the first open
   branch it is `git merge-base <branch> <remote>/<trunk>` once it has been
   rebased past a squash-merged parent (never that parent's recorded `base`).
   Fix a wrong entry by backing the file up and rewriting `base` with jq.

3. **Snapshot for verification.** `gh stack view --json > /tmp/gh-stack-before.json`
   after the audit, so each branch's pre-rebase `base..head` range is on record.

4. **Rebase.** Run `gh stack rebase` with any flags the user passed
   (`--downstack`, `--upstack`, `--no-trunk`, or a branch name). It fetches,
   rebases the bottom branch onto trunk, then cascades upward. If it exits
   cleanly, go to step 7.

5. **Resolve conflicts, one stop at a time.** When it stops:
   - If `git merge-base --is-ancestor REBASE_HEAD <remote>/<trunk>` succeeds,
     the commit being replayed is already on trunk: stale base. Run
     `gh stack rebase --abort` and go back to step 2.
   - Otherwise merge each conflicted file keeping both sides' intent.
     Regenerate generated files (lockfiles, codegen, snapshots) with the
     repo's command instead of merging hunks.
   - `git add` the files and run `gh stack rebase --continue` (not
     `git rebase --continue`, so the tool advances to the next branch). If it
     reports no stack rebase in progress but git has one, finish with
     `git rebase --continue` and re-run `gh stack rebase`.

6. **Recovery.** If the state becomes unclear (wrong branch checked out,
   metadata out of step, a rebase you did not expect), `gh stack rebase --abort`
   restores every branch to its pre-rebase tip. Then start again from step 2.

7. **Verify.**
   - `gh stack view` shows no ⚠ on the branches you rebased.
   - Repeat the step 2 audit; the tool may have just recorded a stale base.
   - For each rebased branch, compare the before and after ranges:
     `git range-diff <before.base>..<before.head> <after.base>..<after.head>`
     using the SHAs from `/tmp/gh-stack-before.json` and a fresh
     `gh stack view --json`. Every commit should be `=` except the ones whose
     conflicts you resolved (`!`). Anything else (`<` dropped, `>` added, or
     an unexpected `!`) means something went wrong; investigate before reporting.
   - For files you resolved by hand, run the repo's lint / typecheck on those
     files only, using the repo's own guidance. Do not run full test suites.

8. **Report** using the format below, then stop.

# Ambiguous conflicts

Leave the rebase in progress (do not abort, do not continue). Show the user
the file, the conflicting hunks with a one-sentence reading of each side, and
your recommended resolution. Wait for their answer, then resume at step 5.

# Report format

Lead with the outcome: rebased fully, rebased partially (which branches were
skipped and why), or stopped on an ambiguous conflict.

| Branch | Before head | After head | Conflicts | Files |
| ------ | ----------- | ---------- | --------- | ----- |

- One row per branch in stack order, bottom first. Merged branches get a
  single "merged, skipped" row.
- For each conflict resolved: file, one sentence on what each side wanted,
  one sentence on the resolution.
- Any stale/invalid base the audit repaired, before and after SHA.
- Verification run and its result (range-diff summary, lint/typecheck on
  touched files).
- End with: nothing was pushed, and the exact command the user would run to
  push (for example `gh stack submit`) is theirs to run.
