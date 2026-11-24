---
name: stow-drift
description: Review dotfiles that something replaced with a real copy of a stowed symlink, and re-link them without losing changes. Use when a "Dotfiles link replaced" notification is clicked, when scripts/stow-drift-agent opens a session, or when asked about stow drift, a broken dotfiles link, a config that stopped syncing with ~/dotfiles, or a file that `scripts/stow` reported as a conflict.
---

# Stow drift

`~/dotfiles` links its files into `~` with GNU Stow. Some tools save a config by writing
a temp file and `mv`-ing it over the old one, which replaces the symlink with a regular
file. From then on the live config and the repo copy go separate ways. The live copy may
hold a change the user wants, or one they made by accident.

Never re-link, overwrite or delete before the user has chosen what to do with each file.
Removing the live copy without a backup loses the change for good.

## Find out what happened

For each file, work from evidence:

- **The diff** between the repo copy and the live file (the opening prompt includes it).
  Explain it in plain terms, e.g. "the bar background went from opaque to none".
- **What wrote it.** Mode `-rw-------` means a file made by `mktemp`. Compare the mtime
  with the journal (`journalctl --user --since … --until …`) and the pacman log. Known
  causes on Omarchy:
  - `omarchy-bar` (position, background, layout) saves `shell.json` through
    `omarchy-shell-config`'s `commit`, which runs `mv`. Double-clicking an empty spot on
    the bar runs `omarchy-bar background cycle`
  - Omarchy migrations and `omarchy refresh`. After `omarchy update`, the post-update
    hook runs `scripts/stow-drift` on its own
- **The repo history**: `git log -p -- <repo copy>`. A recent commit setting the value the
  live file undid suggests the live change was an accident.

Read `omarchy.md` ("Config in the repo") for what each Omarchy file holds.

## Offer a choice per file

- **Keep** the live change: copy it into the repo, for the user to review with `git diff`.
- **Drop** it: restore the repo copy.
- **Merge**: edit the repo copy by hand to take the parts the user wants.

An `unchanged` file has the same content as the repo copy, so re-linking it loses
nothing. Say so and re-link it once the user agrees.

## Re-link

`scripts/stow` and `scripts/stow-drift` both act on **every** drifted file, not just one.
`scripts/stow` moves each real file to a backup and links the repo copy, which is the
"drop" choice. `scripts/stow-drift` copies each changed file into the repo, unless the
repo copy has uncommitted changes, and then runs `scripts/stow`. So run
`scripts/stow-drift --list` first, settle every file it lists, and only then run one of
them.

To act on one file at a time:

1. Back it up: `cp -p <file> ~/.local/state/dotfiles/backup/$(date +%Y%m%d-%H%M%S)/<path
   relative to ~>` (create the directory first).
2. Keep: `cp <file> <repo copy>`. Merge: edit the repo copy. Drop: do nothing to the repo.
3. `rm <file>`, then run `scripts/stow` to link the repo copy.
4. Check: `ls -l <file>` shows a link into `~/dotfiles`, and `scripts/stow-drift --list`
   no longer lists it.

Tell the user where the backup is. Don't commit unless they ask.

If the cause will keep happening (a setting the user changes often from the bar), say so.
Each change will replace the link again and bring the notification back.
