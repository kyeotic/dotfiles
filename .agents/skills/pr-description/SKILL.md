---
name: pr-description
description: Write a PR description (full body following the repo's PR template if it has one, otherwise references/template.md) from chat context and diff. Use whenever the user asks to write, draft, regenerate, refresh, rewrite, or update a PR description or pull request body for the current branch or a specified PR. Do NOT use for title-only requests like "rewrite the PR title" — this skill always returns a full body.
---

Writes a PR description using chat, diff, and the PR template.

# Command instructions

Using the chat context and a final diff against the base branch, write a PR description
following the template. Use the repo's own `.github/pull_request_template.md` when it has
one; otherwise use `references/template.md` from this skill.

To get the correct diff (compatible with git worktrees and stacked PRs):

1. Get the current branch: `git rev-parse --abbrev-ref HEAD` → store as $CURRENT_BRANCH
2. Determine the base branch:
   - If this branch is part of a stack, use `gh stack view` to get the parent branch.
     This setup uses the `gh stack` CLI — never Graphite (`gt`), even if other
     instructions say to
   - Otherwise, check if upstream is set: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
     - If upstream exists and is NOT `origin/$CURRENT_BRANCH`, strip the `origin/` prefix and use the local branch
     - Otherwise, use the repo's default branch (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`) as the base
3. Resolve the diff ref — choose local vs. remote based on whether the base is trunk:
   - **If $BASE_BRANCH is the default branch (trunk)**: run `git fetch origin $BASE_BRANCH` and diff against `origin/$BASE_BRANCH` to ensure the diff is accurate even if the local branch is behind
   - **If $BASE_BRANCH is anything else (stack branch)**: use the local ref directly — stack parents may not exist on the remote yet
4. Generate the diff: `git diff $DIFF_REF...$CURRENT_BRANCH`

**Important**: Always use remote refs (e.g., `origin/main`) as the diff base to ensure the diff reflects only the changes in this branch. The sole exception is stack branch parents that may not exist on the remote yet — use local refs only in that case.

Use explicit branch names in all git commands—do not use HEAD directly.

**Describe the end state only.** What merges is the final diff against the parent. Commit history is available to reviewers but is not what they are approving, so write every PR as if that diff is the only thing that ever existed — especially when regenerating for a branch you have been iterating on:

- The "before" state is always the parent branch, never an earlier commit on this branch. Avoid "previously", "had been", "used to", "now uses X instead of Y" for code that only ever existed here
- Something introduced and resolved within the branch never reached the parent, so it is not a fix. Describe what the code does, not what it stopped doing
- A file whose changes cancel out against the parent is not in the PR. Omit it rather than explaining that it nets to zero
- Your own detours count. What you learned while iterating belongs in chat unless it describes shipped behaviour

**Write for a human reviewer, not a parser.** The diff already shows _what_ changed; the description should explain _why_ and _how to think about it_.

- Describe behavior at a level a human reviewer can skim. Bullet points are fine for structure, but they should summarize behavior, not mirror the diff
- Call out non-obvious design decisions and trade-offs only when a reviewer would actually ask. Skip "we chose X over Y" framing on decisions nobody would question
- For the testing section, describe the testing strategy and confidence level, not the verification command history. The section should help a reviewer understand why the PR is covered well enough and where to focus review
- Useful topics to cover when relevant include:
  - The main behavior or risk area covered by automated tests
  - The level of coverage used, such as service-level tests for business rules, controller smoke tests for request wiring, component tests for UI behavior, or end-to-end/manual checks for user flows
  - Edge cases, regressions, permissions, feature flags, stale-client behavior, or error states that were intentionally covered
  - Any meaningful gaps, intentionally omitted tests, or blocked validation that affects reviewer confidence
  - Manual verification that exercised behavior not well represented by automated tests
- Do not turn the testing section into a command log. Avoid `Tested with:` followed by exact commands like `npm test`, `npm run lint-*`, targeted test-file invocations, typecheck commands, or lists of every test file. Those exact commands and pass/fail details belong in the agent's chat rather than the PR description
- DO NOT report test coverage or test passing status. This is already reported by CI and the PR status. The description should focus on _what_ was tested and _how_ to think about it, not whether it passed
- If the repo's template has sections the author owns (deploy checklists, DB migration checkboxes, screenshots), leave them for the author — write "N/A" only when the change genuinely does not touch that area

**Voice rules (avoid AI-y prose):**

- Always keep every required H2 section from the template, even on tiny PRs. "Short" means short _prose inside each section_, not skipped sections
- Length scales with diff size. Trivial change = 1–2 sentences per prose section and no extra `###` subsections (e.g., skip `### Before / After` when there's nothing visual to compare). Don't pad a one-line lockfile sync into multiple paragraphs
- Use em-dashes (—) sparingly. At most one per paragraph; prefer periods or commas
- No hype verbs: "lands", "ships", "bakes in", "introduces", "powers", "unlocks", "leverages". Just say what it does ("adds", "uses", "fixes")
- No filler sentences. "Functionality is unchanged", "No runtime behavior change", "ships automatically because..." — if a section is N/A, write "N/A" and move on
- Don't bold inline labels (`**Visual changes**`, `**Testing**`) inside a paragraph. Either use a real `###` heading or skip the label entirely
- Plain words over fancy ones: "added" not "introduces", "uses" not "leverages", "fix" not "addresses"
- Reference an issue or ticket only if it actually appears in the branch name, a commit message, or the existing PR body. Do not guess a ticket number

**Avoid these anti-patterns (they just repeat the diff):**

- Listing function names and their parameters/return types
- Bullet points that read like a changelog ("Added `fooHelper` function", "Updated `barService` to call `baz`")
- Enumerating every test by name or listing verification commands as the testing strategy
- Multi-sentence bullet points.
- Large table cells in the Before/After section.

## Output

Always output to chat, do not update the actual PR body.
