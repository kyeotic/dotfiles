# Agent Skills

Agent-agnostic skills, shared by every coding agent.

Claude Code and Codex read the same format — `<skills-dir>/<name>/SKILL.md` with YAML
frontmatter — so each skill is written once here and linked into both.

The `.agents/` name follows the [Agent Skills open standard](https://agentskills.io),
which is also what project repos use for their own skill directories.

```
skills/          canonical skill sources (edit these)
claude/skills/   symlinks -> ../../skills/<name>, linked into ~/.claude/skills
codex/skills/    symlinks -> ../../skills/<name>, linked into ~/.codex/skills
```

## Adding a skill

```sh
scripts/agent-skill add <name>              # both agents
scripts/agent-skill add <name> codex        # one agent only
```

That creates `.agents/skills/<name>/SKILL.md` from a stub if it does not exist, symlinks
it under each named agent, and links it into that agent's config dir. Re-running is
safe. Then fill in the SKILL.md.

`scripts/agent-skill link` relinks everything; `scripts/stow` calls it, so the normal
re-link flow still works.

A skill that genuinely cannot be shared can live directly in `claude/skills/` or
`codex/skills/` as a real directory instead of a symlink.

Linking is per-skill rather than whole-directory, because `~/.claude/skills` and
`~/.codex/skills` also hold skills installed by other tools. An existing real directory
at a target path is left alone with a warning.

## Writing skills

Keep them tool-agnostic: shell commands (`git`, `gh`) rather than any one agent's
built-in tools, and no references to a specific agent's UI or slash commands.
