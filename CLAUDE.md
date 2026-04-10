# CLAUDE.md

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

## Setup & Installation

Bootstrap: `curl -fsSL https://raw.githubusercontent.com/kyeotic/dotfiles/HEAD/scripts/install | bash`

The `scripts/` directory contains the installation pipeline (all steps are idempotent):
- `install` - Bootstrap script (installs git/curl on Linux, installs Nix on macOS, clones repo, runs init)
- `init` - Main orchestrator, runs: `install_shell` → `install_apps`
- `install_shell` - Installs zsh; on Linux runs `brew bundle --file=Brewfile.linux`; on macOS runs `darwin-rebuild switch`
- `install_apps` - Installs tools not in Homebrew (deno, rust, tfswitch, nvm, kitty, claude, fonts on Linux)
- `stow` - Creates symlinks via GNU Stow mapping `home/` → `~/` and `.config/` → `~/.config/`

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

- **`home/`** - Files symlinked to `~/` (`.zshrc`, `.zsh_aliases`, `.zsh_functions`, `.zsh_git`, `.gitconfig`, `.starship-rc`)
- **`.config/`** - Files symlinked to `~/.config/` (starship, kitty, fish, direnv, hypr, conky, pipewire)
- **`scripts/`** - Installation and setup scripts (all bash, idempotent)
- **`nix/`** - nix-darwin flake for macOS (`flake.nix`, `home.nix`, `darwin.nix`, `switch`)
- **`Brewfile.linux`** - Homebrew CLI packages for Linux (and macOS via install_apps)
- **`Brewfile`** - Homebrew casks for macOS GUI apps
- **`autokey/`** - Linux text expansion phrases and scripts

## Key Conventions

- Shell config is split across `.zshrc` (main), `.zsh_aliases` (aliases), `.zsh_functions` (functions), `.zsh_git` (git helpers), and `.starship-rc` (prompt env setup)
- `.starship-rc` sources nix-daemon.sh on macOS, initializes starship, sets up zsh-autosuggestions and completions from `$(brew --prefix)/share/`
- Platform detection via `uname` (Darwin vs Linux); no NixOS-specific branches remain
- Username detection via `whoami` selects between personal (`kyeotic`) and work (`tkye`) profiles on macOS
- Machine-local overrides go in `~/.localrc` (sourced by `.zshrc` if present)
- Git config includes a conditional include for `.gitconfig.work` based on workspace path
