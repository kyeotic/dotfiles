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

_What's the new behavior, and why is it covered well enough to merge? Describe the
testing strategy and where a reviewer should focus, not the commands that were run._

### Before / After

| **Before** | **After** |
| ---------- | --------- |
| _Old behavior_ | _New behavior_ |
```
