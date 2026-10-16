# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing development environment configs across macOS, Linux, and WSL. Uses **GNU Stow** for symlink management. Linux uses **Homebrew** (`Brewfile.linux`) for CLI packages; macOS uses **nix-darwin** (`nix/`) for both packages and system defaults.

ALL CHANGES MUST WORK IN: Macos, Linux, WSL (windows linux)

## Working

When working ALWAYS start by making a markdown plan in thoughts/ unless the user says "skip plan"

- If a plan markdown already exists, or is provided by the user, work from the existing document instead of making a new one
- As you work update the thought markdown with changes and progress
- If you change the system or architecture documented in THIS DOCUMENT, UPDATE IT

DO NOT READ the .env file, it contains secrets that should NEVER be in the claude context They are part of the ENV VARs, so you can use them (WITHOUT READING THEM INTO CONTEXT)

## Omarchy

Some Linux machines run Omarchy (Arch + Hyprland); others (macOS, WSL, work machines) don't. Everything Omarchy-specific (Hyprland, the Omarchy bar/shell, themes and hooks, MangoHud, voxtype dictation, per-machine setup, things to check after `omarchy update`) is documented in `omarchy.md`, not here.

- **On an Omarchy machine, read `omarchy.md` before answering any OS question or doing any OS task**: desktop, window manager, bar, themes, monitors, input, audio, gaming, dictation, apps, packages, services, system config, troubleshooting. You're on Omarchy if `command -v omarchy` succeeds (the kernel name from `uname -r` also contains `omarchy`)
- On any machine, also read it before touching Omarchy config in this repo (`.config/hypr`, `.config/omarchy`, `.config/MangoHud`, `.config/voxtype`, `config-linux/omarchy`, `home/.local/share/applications/discord.desktop`). Those files are stowed everywhere but only used on Omarchy
- Put new Omarchy-specific notes in `omarchy.md` and keep this file platform-general

## Setup & Installation

Bootstrap: `curl -fsSL https://raw.githubusercontent.com/kyeotic/dotfiles/HEAD/scripts/install | bash`

The `scripts/` directory contains the installation pipeline (all steps are idempotent):
- `install` - Bootstrap script (installs git/curl on Linux, installs Nix on macOS, clones repo, runs init)
- `init` - Main orchestrator, runs: `install_shell` → `install_apps` → `vault-sync sync` → prompts (default no) to run `clone-active` → on Linux, prompts (default no) to run `setup-nas-mounts` → on Linux (non-WSL), prompts (default no) to run `setup-espanso`
- `clone-active` - Clones active personal repos into `~/dev` (skips existing); not run automatically since it's unwanted on work machines
- `setup-nas-mounts` - Linux only. Mounts KYE-NAS SMB shares (`nas`, `media`, `apps`) at `/mnt/<share>` via a marker-tagged fstab block with `x-systemd.automount`, using `~/.smb-share` (vault-sync) as credentials. Pins `kye-nas` in `/etc/hosts` via `nmblookup` when it doesn't resolve, and adds GTK bookmarks. Also available as the `setup-nas-mounts` shell function
- `setup-espanso` - Linux only (macOS uses its built-in text replacement). Installs espanso (text expander, AutoHotkey-style hotstrings; AutoKey is X11-only so it doesn't work on Hyprland). AUR `espanso-wayland-git`/`espanso-x11-git` (built from source; the `-bin` Debian builds segfault in wxWidgets on Arch and are removed if present) by `$XDG_SESSION_TYPE`, plus `sudo setcap cap_dac_override+p` on Wayland (re-run after espanso upgrades). Registers and starts the service. Hotstrings live in `.config/espanso/match/base.yml`. Also available as the `setup-espanso` shell function
- `install_shell` - Installs zsh; on Linux runs `brew bundle --file=Brewfile.linux`; on macOS runs `darwin-rebuild switch`
- `install_apps` - Installs tools not in Homebrew (deno, rust, tfswitch, nvm, kitty, claude; on Linux: fonts, and mangohud via the distro package manager)
- `stow` - Creates symlinks via GNU Stow mapping `home/` → `~/` and `.config/` → `~/.config/`; on Linux only, also `config-linux/` → `~/.config/`

To re-link after changes: `~/dotfiles/scripts/stow`

## Package Management

### Linux
CLI packages are declared in `Brewfile.linux` (Linuxbrew). To add/remove packages, edit `Brewfile.linux` and run `brew-up` (alias for `brew bundle --file=~/dotfiles/Brewfile.linux --no-upgrade`).

### macOS
CLI packages and system defaults are managed via nix-darwin. Packages are in `nix/home.nix`, system defaults (dock, keyboard, trackpad) in `nix/darwin.nix`. To apply, run `nix-switch` (alias for `~/dotfiles/nix/switch`).

### Both platforms
Tools not in Homebrew/nixpkgs (deno, rust, tfswitch, nvm, kitty, claude) use their own curl installers in `scripts/install_apps`.

macOS GUI apps are in `Brewfile` (casks only), applied by `scripts/install_apps`.

## Repository Structure

- **`home/`** - Files symlinked to `~/` (`.zshrc`, `.zsh_aliases`, `.zsh_functions`, `.zsh_git`, `.gitconfig`, `.starship-rc`). `.claude/CLAUDE.md` is the global Claude Code instructions file (e.g. use `pkexec` rather than `sudo` on Linux, since the agent's shell has no TTY); only the file is linked, since `~/.claude` is a real directory.
- **`.config/`** - Files symlinked to `~/.config/` (starship, kitty, ghostty, direnv, espanso).
- **`config-linux/`** - Linux-only files symlinked to `~/.config/` (macOS never gets them). Same stow dir and target as `.config/`, so a dir both packages share is unfolded into per-file links. Holds `ghostty/linux.conf`, which `.config/ghostty/config` loads with `config-file = ?linux.conf` (Ghostty has no per-OS conditionals); the `?` makes it optional, so it's skipped on macOS.
- **`scripts/`** - Installation and setup scripts (all bash, idempotent)
- **`nix/`** - nix-darwin flake for macOS (`flake.nix`, `home.nix`, `darwin.nix`, `switch`)
- **`Brewfile.linux`** - Homebrew CLI packages for Linux (and macOS via install_apps)
- **`Brewfile`** - Homebrew casks for macOS GUI apps
- **`.agents/`** - Agent-agnostic coding-agent skills (`.agents/skills/`), symlinked per-agent into `~/.claude/skills` and `~/.codex/skills`; add one with `scripts/agent-skill add <name>`, see `.agents/README.md`

## Key Conventions

- Shell config is split across `.zshrc` (main), `.zsh_aliases` (aliases), `.zsh_functions` (functions), `.zsh_git` (git helpers), and `.starship-rc` (prompt env setup)
- `.starship-rc` sources nix-daemon.sh on macOS, initializes starship, sets up zsh-autosuggestions and completions from `$(brew --prefix)/share/`
- Platform detection via `uname` (Darwin vs Linux); no NixOS-specific branches remain
- Username detection via `whoami` selects between personal (`kyeotic`) and work (`tkye`) profiles on macOS
- Machine-local overrides go in `~/.localrc` (sourced by `.zshrc` if present)
- Git config includes a conditional include for `.gitconfig.work` based on workspace path
