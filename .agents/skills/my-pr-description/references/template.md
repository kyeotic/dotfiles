# PR Body Template

The fallback template, used when the repo has no `.github/pull_request_template.md` of
its own. A repo's own template always wins.

Both H2 sections stay, even on a trivial PR — "short" means short prose inside each
section, not a skipped section. `### Before / After` is optional: include it only when
there is something visual or behavioral worth putting side by side.

```markdown
## Description and Context

_What is missing or wrong today, and what asks for the change (design, ticket, incident)?
Include tickets, docs, and links, but only ones that actually exist; do not invent a
ticket number._

## New Behavior and Testing

_One short bullet per user-visible change. No unit-test or coverage notes._

### Before / After

| **Before**     | **After**      |
|----------------|----------------|
| _Old behavior_ | _New behavior_ |
```

Some general notes on tone and style.

DO the following:
- DO describe the problem and the intent motivating the change
- DO explain why this implementation was chosen, only when a reviewer would ask
- Summarize and *keep it short*

DO NOT do the following:
- Do NOT describe the files changed (the code diff already does that)
- Do NOT mention unit tests or automated coverage: what they cover, that they were added, or that they pass
- DO NOT exhaustively explain every detail of the context or change