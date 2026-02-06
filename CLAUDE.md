# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing development environment configs across macOS, Linux, WSL, and NixOS. Uses **GNU Stow** for symlink management and **Nix + home-manager** for declarative package management.

ALL CHANGES MUST WORK IN: Macos, Linux, WSL (windows linux)

## Setup & Installation

Bootstrap: `curl -fsSL https://raw.githubusercontent.com/kyeotic/dotfiles/HEAD/init/install | bash`

The `init/` directory contains the installation pipeline (all steps are idempotent):
- `install` - Bootstrap script (installs git/curl, installs Nix, clones repo, runs init)
- `init` - Main orchestrator, runs: `install_shell` → `install_apps`
- `install_shell` - Installs zsh, runs `home-manager switch`, runs stow
- `install_apps` - Installs tools not in nixpkgs (deno, rust, tfswitch, nvm)
- `stow` - Creates symlinks via GNU Stow mapping `home/` → `~/` and `.config/` → `~/.config/`

To re-link after changes: `~/dotfiles/init/stow`

## Package Management

CLI packages are declared in `nix/home.nix` and installed via home-manager. To add/remove packages, edit `nix/home.nix` and run `nix-switch` (alias for `~/dotfiles/nix/switch`).

Profiles are defined in `nix/flake.nix` with a `mkHome` helper. The `nix/switch` script auto-detects platform and username via `whoami` to select the right profile.

Tools not in nixpkgs (deno, rust, tfswitch, nvm) use their own curl installers in `init/install_apps`.

## Repository Structure

- **`home/`** - Files symlinked to `~/` (`.zshrc`, `.zsh_aliases`, `.zsh_functions`, `.zsh_git`, `.gitconfig`, `.starship-rc`)
- **`.config/`** - Files symlinked to `~/.config/` (starship, kitty, fish, direnv, hypr, conky, pipewire)
- **`init/`** - Installation and setup scripts (all bash, idempotent)
- **`nix/`** - Standalone home-manager flake (`flake.nix`, `home.nix`, `switch`)
- **`nixos/`** - NixOS flake-based system config (separate, desktop only; `apply-config` to apply)
- **`phoenix/`** - macOS window manager config (JavaScript)
- **`autokey/`** - Linux text expansion phrases and scripts

## Key Conventions

- Shell config is split across `.zshrc` (main), `.zsh_aliases` (aliases), `.zsh_functions` (functions), `.zsh_git` (git helpers), and `.starship-rc` (prompt env setup)
- `.starship-rc` sources nix-daemon.sh (not on NixOS), initializes starship, sets up zsh-autosuggestions and completions from `~/.nix-profile/share/`
- Platform detection happens at install time and in `.zshrc` (checks for NixOS via `/etc/NIXOS`, macOS via `uname`)
- Username detection via `whoami` selects between personal (`kyeotic`) and work (`tkye`) profiles
- Machine-local overrides go in `~/.localrc` (sourced by `.zshrc` if present)
- Git config includes a conditional include for `.gitconfig.work` based on workspace path
- NixOS system changes are applied via `nixos/apply-config`, old generations cleaned with `nixos/trim-generations`
