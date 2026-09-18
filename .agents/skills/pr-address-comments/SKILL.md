---
name: pr-address-comments
description: Fetch a PR's open review comments (humans and bots such as Codex), apply the fixable ones locally, and answer questions in chat. Use when asked to address, handle, respond to, or work through PR review comments or feedback. Never replies on GitHub, never commits, never pushes.
argument-hint: '[--min] [PR number | URL | branch] (defaults to current branch)'
---

Address review feedback on a pull request. All output goes to chat; nothing is
written to GitHub.

# Hard rules

- Do not comment, reply, resolve threads, or react on GitHub.
- Do not commit or push. Leave changes in the working tree.
- Do not paste the digest or raw API output into chat. Summarize it.
- Read only the files and ranges a comment points at. Do not read the whole diff.
- Do not change code for a comment you disagree with. Ask first (see Disagree).

# Steps

1. **Fetch the digest.** From this skill's directory:
   `bash scripts/fetch-pr-comments [--min] [PR]`
   It prints PR metadata, unresolved review threads with their replies, PR-level
   comments, and review summaries with a body. Bot comments (Codex, CI, Linear)
   are included by default; `--min` drops them. Resolved threads are never
   included. If no PR exists for the branch, say so and stop.

2. **Triage every thread** into exactly one bucket:
   - **Fix**: a concrete, correct change request. Includes nits. A thread where
     the PR author replied "fixing" or similar is still a Fix unless Done applies.
   - **Question**: the reviewer wants information, not a change.
   - **Disagree**: the request is wrong, a bad trade-off, or conflicts with the
     repo's conventions. Pushback is expected; reviewers and bots are often wrong.
   - **Done**: the line already changed after the comment (thread is marked
     `(outdated)`, or `git log -L<line>,+1:<path>` shows a later commit that
     handles it), or the code already matches what was asked.
     If a comment is ambiguous between Fix and Question, treat it as a Question.

3. **Apply fixes.** For each Fix, read the referenced range plus enough
   surrounding code to make the change safely. Make the minimal edit that
   satisfies the comment. Do not bundle unrelated cleanups.

4. **Verify** using the repo's own guidance (AGENTS.md, CLAUDE.md, or docs it
   points to). If the repo has none, lint and typecheck the touched files only.
   Run a test only when a comment is about that test. Do not run full suites.

5. **Report** in chat using the format below, then stop. Disagree items end
   with a question to the user; wait for their answer before changing that code.

# Report format

One row per thread, ordered Fix, Disagree, Question, Done:

| #   | Location | Reviewer | Bucket | Outcome |
| --- | -------- | -------- | ------ | ------- |

- **Fix**: what changed and where, one sentence.
- **Disagree**: why the request is wrong or worse, one or two sentences, then
  ask whether to apply it anyway.
- **Question**: the answer, for the user to relay. Do not draft a GitHub reply.
- **Done**: the commit or evidence showing it was already handled.

End with the files changed and the verification commands run with their result.
