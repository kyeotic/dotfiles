# PR Body Template

The fallback template, used when the repo has no `.github/pull_request_template.md` of
its own. A repo's own template always wins.

Both H2 sections stay, even on a trivial PR — "short" means short prose inside each
section, not a skipped section. `### Before / After` is optional: include it only when
there is something visual or behavioral worth putting side by side.

```markdown
## Description and Context

_What is the context and motivation behind this PR? Include tickets, docs, and links —
but only ones that actually exist; do not invent a ticket number._

## New Behavior and Testing

_What's the new behavior, and why is it covered well enough to merge?_

### Before / After

| **Before**     | **After**      |
|----------------|----------------|
| _Old behavior_ | _New behavior_ |
```

Some general notes on tone and style.

DO the following:
- DO Describe the context motivating the change
- DO Describe the reason the specific implementation was selected if others were considered
- Summarize and *keep it short*

DO NOT do the following:
- Do NOT describe the files changed (the code diff already does that)
- Do NOT enumerate the results of automated tests that were run or created
- DO NOT exhaustively explain every detail of the context or change