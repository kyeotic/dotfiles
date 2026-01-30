# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing development environment configs across macOS, Linux, and NixOS. Uses **GNU Stow** for symlink management and **Homebrew** as the cross-platform package manager.

## Setup & Installation

Bootstrap: `curl -fsSL https://raw.githubusercontent.com/kyeotic/dotfiles/HEAD/init/install | bash`

The `init/` directory contains the installation pipeline:
- `install` - Bootstrap script (clones repo, installs build tools)
- `init` - Main orchestrator, runs: `install_shell` → `install_apps` → `install_nvm` → `install_fonts`
- `stow` - Creates symlinks via GNU Stow mapping `home/` → `~/` and `.config/` → `~/.config/`

To re-link after changes: `~/dotfiles/init/stow`

## Repository Structure

- **`home/`** - Files symlinked to `~/` (`.zshrc`, `.zsh_aliases`, `.zsh_functions`, `.zsh_git`, `.gitconfig`, `.starship-rc`)
- **`.config/`** - Files symlinked to `~/.config/` (starship, kitty, fish, direnv, hypr, conky, pipewire)
- **`init/`** - Installation and setup scripts (all bash, no shebangs on some — run with `bash`)
- **`nix/`** - NixOS flake-based system config (`apply-config` to apply changes)
- **`phoenix/`** - macOS window manager config (JavaScript)
- **`autokey/`** - Linux text expansion phrases and scripts

## Key Conventions

- Shell config is split across `.zshrc` (main), `.zsh_aliases` (aliases), `.zsh_functions` (functions), `.zsh_git` (git helpers), and `.starship-rc` (prompt env setup)
- Platform detection happens at install time and in `.zshrc` (checks for NixOS via `/etc/NIXOS`, macOS via `uname`)
- Machine-local overrides go in `~/.localrc` (sourced by `.zshrc` if present)
- Git config includes a conditional include for `.gitconfig.work` based on workspace path
- NixOS changes are applied via `nix/apply-config`, old generations cleaned with `nix/trim-generations`
