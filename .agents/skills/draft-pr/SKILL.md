---
name: draft-pr
description: Push changes and create a draft PR whose body follows /pr-description (visual-first, short prose)
disable-model-invocation: true
---

> **Graphite users**: Use `/gt-submit` instead for stack-aware PR submission.

Pushes changes and creates a draft PR using the PR template, with the body written by `/pr-description` (requires gh CLI to be configured).

# Command instructions

This command pushes your current changes and creates a draft pull request.

## Step 1: Gather context

1. Get the current branch: `git rev-parse --abbrev-ref HEAD` → store as $CURRENT_BRANCH
2. Determine the base branch:
   - If `gt` is available, use `gt branch info` to get the Graphite parent branch
   - Otherwise, check if upstream is set: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
     - If upstream exists and is NOT `origin/$CURRENT_BRANCH`, strip the `origin/` prefix and use the local branch
     - Otherwise, use `main` as the base
   - **Stacks with an empty base/marker branch:** if a Graphite ancestor branch has no commits of its own, stack submission fails with "GitHub does not allow empty PRs". Fix with `gt checkout <first-real-branch> && gt move --onto main` (leaves the marker branch intact) or delete the marker branch.
3. Resolve the diff ref — choose local vs. remote based on whether the base is trunk:
   - **If $BASE_BRANCH is `main` (trunk)**: run `git fetch origin main` and diff against `origin/main` to ensure the diff is accurate even if local main is behind
   - **If $BASE_BRANCH is anything else (stack branch)**: use the local ref directly — stack parents may not exist on the remote yet
4. Generate the diff: `git diff $DIFF_REF...$CURRENT_BRANCH`
5. Get commit messages: `git log $DIFF_REF..$CURRENT_BRANCH --oneline`

**Important**: Always use remote refs (e.g., `origin/main`) as the diff base to ensure the diff reflects only the changes in this branch. The sole exception is Graphite stack branch parents that may not exist on the remote yet — use local refs only in that case.

Use explicit branch names in all git commands—do not use HEAD directly.

## Step 2: Push changes

Push the current branch to origin with upstream tracking:

```bash
git push -u origin $CURRENT_BRANCH
```

## Step 3: Write PR description

Using the chat context and diff, write a PR description following @.github/pull_request_template.md.

Write the body by following the `pr-description` skill (`.agents/skills/pr-description/SKILL.md`): its **Describe the end state only**, **Show, don't tell**, and **Words** sections. Skip its diff and output steps; this skill has already gathered the diff and handles creating the PR.

Keep the list of media paths you produce: Step 4 passes them to `gh pr create` as `--attach` flags. In a Conductor cloud workspace `--attach` is refused (`ghu_` token), so leave it off and follow **Choose the upload path** in the `pr-media` skill.

## Step 4: Create draft PR

Use the GitHub CLI to create a draft PR. Use `--body-file -` to safely handle multi-line descriptions with special characters:

```bash
echo "$PR_DESCRIPTION" | gh pr create --draft --base "<base-branch>" --title "<PR title>" --body-file -
```

If the description references captured media, add one `--attach <path>` per file so gh uploads
them and rewrites the references (gh ≥ 2.99):

```bash
echo "$PR_DESCRIPTION" | gh pr create --draft --base "<base-branch>" --title "<PR title>" --body-file - \
  --attach tools/captures/before.png --attach tools/captures/after.png --attach tools/captures/demo.webm
```

After creating the PR, output the PR URL so the user can easily access it.

# User instructions (can be empty):

$ARGUMENTS
