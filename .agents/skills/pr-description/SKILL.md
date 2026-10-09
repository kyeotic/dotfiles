---
name: pr-description
description: Write a short, visual-first PR description (full body following the repo's PR template at .github/pull_request_template.md) from chat context and diff, leading with screenshots, GIFs, and generated diagrams instead of long prose. Use whenever the user asks to write, draft, regenerate, refresh, rewrite, or update a PR description or pull request body for the current branch or a specified PR. Do NOT use for title-only requests like "rewrite the PR title" — this skill always returns a full body.
---

Writes a short, visual-first PR description using chat, diff, and the PR template.

# Command instructions

Using the chat context and a final diff against the base branch, write a PR description following @.github/pull_request_template.md.

To get the correct diff (compatible with git worktrees and stacked PRs):

1. Get the current branch: `git rev-parse --abbrev-ref HEAD` → store as $CURRENT_BRANCH
2. Determine the base branch:
   - If `gt` is available, use `gt branch info` to get the Graphite parent branch
   - Otherwise, check if upstream is set: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
     - If upstream exists and is NOT `origin/$CURRENT_BRANCH`, strip the `origin/` prefix and use the local branch
     - Otherwise, use `main` as the base
3. Resolve the diff ref — choose local vs. remote based on whether the base is trunk:
   - **If $BASE_BRANCH is `main` (trunk)**: run `git fetch origin main` and diff against `origin/main` to ensure the diff is accurate even if local main is behind
   - **If $BASE_BRANCH is anything else (stack branch)**: use the local ref directly — stack parents may not exist on the remote yet
4. Generate the diff: `git diff $DIFF_REF...$CURRENT_BRANCH`

Set $TARGET to $CURRENT_BRANCH. If the user names a PR number instead, set $TARGET to that number and get its diff by state (`gh pr view "$TARGET" --json state,mergeCommit`):

- **Merged**: diff the merge or squash commit against its first parent, `git fetch origin main && git diff <mergeCommit.oid>^1 <mergeCommit.oid>`. `gh pr diff` can include a merged parent's files, and a bare `git show` of a merge commit can leave files out.
- **Open or closed**: `gh pr diff "$TARGET"`.

**Important**: Always use remote refs (e.g., `origin/main`) as the diff base to ensure the diff reflects only the changes in this branch. The sole exception is Graphite stack branch parents that may not exist on the remote yet — use local refs only in that case.

Use explicit branch names in all git commands—do not use HEAD directly.

**Read the existing description before writing.** If a PR exists for $TARGET, save its current body and treat it as input, not something to replace:

```bash
BEFORE=$(mktemp -t pr-body-before.XXXXXX.md)
gh pr view "$TARGET" --json body -q .body > "$BEFORE"
```

Keep what a person added or edited there, such as the author summary, extra context, links, media, or corrections to earlier generated text, unless the diff makes it wrong. If you can't tell whether a part was edited by hand, keep it and mention it to the user.

**Describe the end state only.** What merges is the final diff against the parent. Commit history is available to reviewers but is not what they are approving, so write every PR as if that diff is the only thing that ever existed — especially when regenerating for a branch you have been iterating on:

- The "before" state is always the parent branch, never an earlier commit on this branch. Avoid "previously", "had been", "used to", "now uses X instead of Y" for code that only ever existed here
- Something introduced and resolved within the branch never reached the parent, so it is not a fix. Describe what the code does, not what it stopped doing
- A file whose changes cancel out against the parent is not in the PR. Omit it rather than explaining that it nets to zero
- Your own detours count. What you learned while iterating belongs in chat unless it describes shipped behaviour

## Show, don't tell

Reviewers skim. A screenshot, GIF, or diagram gets understood in seconds, and a paragraph often gets skipped. Before writing any prose, decide what the reviewer should _see_, and produce it. Use the most specific row that fits the change:

| Change                                                                       | Visual                                                                                                                                          |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| UI, static result                                                            | Before/after screenshots: `node tools/capture.js <surface> [route]`                                                                             |
| UI interaction or flow                                                       | A GIF: record with `capture.js --rec`, then convert per the `pr-media` skill's **Make a GIF**. Keep the video only for clips longer than ~15s   |
| Concept that is hard to picture (multi-step behavior, timing, new user flow) | An animated explainer GIF you build from HTML/CSS (`pr-media` → **Render HTML to an image or recording**)                                       |
| State machine, rollout gating, feature flag or experiment arms               | A decision or state diagram image                                                                                                               |
| Schema change                                                                | An entity diagram image of the tables that changed                                                                                              |
| Backend flow, job pipeline, new service, request path                        | A diagram image of the flow                                                                                                                     |
| Refactor with no visible change                                              | A before/after diagram image of the structure that changed                                                                                      |
| Non-visual output (screen-reader text, API response, log output)             | A screenshot of the real output, or a generated image that lays out the literal before and after outputs. Never sentences describing the change |
| Config, lockfile, dependency bump, copy tweak                                | No visual. One sentence                                                                                                                         |

- Put the visual once, at the top of `## New Behavior and Testing`. Don't repeat it in `## Description and Context`.
- `### Before / After` holds images or literal one-line examples. Delete the heading and table when there's nothing to picture, or when the visual is already a single before/after image.
- A PR with visible UI changes must include real media. If capture isn't possible, say why in one line under `## UI Testing`.
- Media shows local, seeded, or staging data only, never real patient data. Upload with the `pr-media` skill (its **Choose the upload path** covers cloud workspaces).
- Mermaid is a last resort, for when you can't render an image. A rendered image reads better.

### Generating diagram images

1. Write a single-file HTML page with the diagram: boxes, arrows, short plain-word labels. Keep flow diagrams to about 8 nodes; comparison images can hold more. Show only the part the PR touches. Use Nourish colors (full palette in the `nourish-html` skill): page `#f8f7f6`, cards `#ffffff` with a `#e0dcd9` border, text `#4c4b49`, new or changed parts outlined in `#fe5000` on `#ffe3d6`, on/allowed `#dff6ea`, off/blocked `#fed7d7`. Skip emoji: the cloud sandbox has no emoji font, so they render as empty boxes.
2. Render it with the `render.js` script from the `pr-media` skill's **Render HTML to an image or recording**: `node tools/captures/render.js diagram.html diagram.png`. It uses whichever Playwright Chromium is installed, waits for fonts, shoots at 2x, and sizes the image to the page.
3. Open the PNG and check that it's legible and matches the diff. Fix and re-render until it does.
4. Reference it in the body as `![Short alt](<out>.png)`, using the same path you pass to `--attach` (see Output).

## Words: fewer, and only what the reviewer needs

The diff already shows _what_ changed. The words explain _why_ and _where to look_, and nothing else.

- **Keep the template.** Always keep every H2 from the PR template (`## Description and Context`, `## New Behavior and Testing`, `## UI Testing`, `## Database Changes`), even on tiny PRs. Never rename, replace, or add H2 sections. A requested style such as "ELI5" changes the tone of the text inside the sections, not the headings.
- **Leave room for the author.** Start the body with `<!-- ✍️ Author summary (optional): 1–2 lines in your own words. What should the reviewer know first? -->`, unfilled, so the author can add a line in their own words above the generated text. When regenerating, keep any text the author wrote themselves (in that slot, or a hand-written summary elsewhere) verbatim at the top.
- **Budget:**
  - `## Description and Context`: at most 3 sentences plus the Linear/Notion link.
  - `## New Behavior and Testing`: the visual first, then at most 3 bullets on testing. Cover the strategy and confidence, where reviewers should focus, and gaps you know about from the chat or the diff. Never invent testing claims or gaps. Don't list every covered case.
  - `## UI Testing`: for visible UI changes, keep the checklist and tick only platforms actually exercised. Otherwise replace the checklist with "N/A".
  - `## Database Changes`: if `schema.prisma` is unchanged, replace the checklist with "N/A". Otherwise leave the checklist unticked for the author.
- **Cut anything the reviewer doesn't need,** in prose and diagram labels alike: file paths, function, type, and variable names, code links, lists of tests, verification commands (`npm test`, typecheck, lint), changelog bullets ("Added `fooHelper`"), and branch history ("replaces #X", "not linked into the stack"). For a stacked PR, one line placing it in the stack is enough. Keep names the reviewer acts on, such as feature gates, experiment arms, and user-facing routes.
- **Voice:** plain words ("adds", "uses", "fixes", not "introduces", "leverages", "lands", "ships", "unlocks"). No filler ("Functionality is unchanged"). If a section is N/A, write "N/A". At most one em-dash per paragraph. Don't bold inline labels; use a real `###` heading or no label.
- **Final pass:** for each paragraph, ask "could an image replace this?" For each sentence, ask "would the reviewer miss this if it were gone?" Delete anything that fails either question.

**Voice rules (avoid AI-y prose):**

- Always keep every required H2 section from the template, even on tiny PRs. "Short" means short _prose inside each section_, not skipped sections
- Length scales with diff size. Trivial change = 1–2 sentences per prose section and no extra `###` subsections (e.g., skip `### Before / After` when there's nothing visual to compare). Don't pad a one-line lockfile sync into multiple paragraphs
- Use em-dashes (—) sparingly. At most one per paragraph; prefer periods or commas
- No hype verbs: "lands", "ships", "bakes in", "introduces", "powers", "unlocks", "leverages". Just say what it does ("adds", "uses", "fixes")
- No filler sentences. "Functionality is unchanged", "No runtime behavior change", "ships automatically because..." — if a section is N/A, write "N/A" and move on
- Plain words over fancy ones: "added" not "introduces", "uses" not "leverages", "fix" not "addresses"
- Reference an issue or ticket only if it actually appears in the branch name, a commit message, or the existing PR body. Do not guess a ticket number

**Avoid these anti-patterns (they just repeat the diff):**

- Listing function names and their parameters/return types
- Bullet points that read like a changelog ("Added `fooHelper` function", "Updated `barService` to call `baz`")
- Enumerating every test by name or listing verification commands as the testing strategy
- Multi-sentence bullet points.
- Large table cells in the Before/After section.
- Listing things that did not change or were left alone.
- Stating manual verification was run that you did not run. Just because it is marked as a required check does not mean it was done.

## Output: update remote PR if one exists, else copy-paste

After generating the description, check whether a PR exists for $TARGET:

```bash
gh pr view "$TARGET" --json number,url 2>/dev/null
```

- **If a PR exists**: check that nobody edited the body since you read it, then push. Do not print the generated description in chat.

  ```bash
  gh pr view "$TARGET" --json body -q .body | diff -q "$BEFORE" - >/dev/null || echo "PR body changed on GitHub"
  ```

  If it changed, don't overwrite yet. Show the user what changed, fold it into the new body, and wait for confirmation before pushing the merged version. Otherwise write the body to a temp file and push it via `gh pr edit`. Only update the body — don't touch the title (this skill is body-only; see the description metadata).

  ```bash
  TMP=$(mktemp -t pr-body.XXXXXX.md)
  cat > "$TMP" <<'PR_BODY_EOF'
  <full description here>
  PR_BODY_EOF
  gh pr edit "$TARGET" --body-file "$TMP" \
    --attach <each image/GIF/video path referenced in the body>
  ```

  `--attach` uploads each file and rewrites its local path in the body to the hosted URL. It needs gh ≥ 2.99 and a non-`ghu_` token. In a Conductor cloud workspace, follow the `pr-media` skill's **Choose the upload path** instead. Read the body back and confirm no local paths remain, then output the PR URL.

- **If no PR exists**: print the description in a markdown codeblock with a `pbcopy` one-liner, and list the media files so they can be passed to `--attach` (or dragged in) when the PR is created.

# User instructions (can be empty):

$ARGUMENTS
