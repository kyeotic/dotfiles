# Dotfiles

This is my personal dotfiles repository. It is for bootstrapping new machines.

## Fresh Machine Setup

On a brand new machine, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyeotic/dotfiles/HEAD/scripts/install)"
```

This will:
1. Install git and curl (Linux only — pre-installed on macOS)
2. Install [Nix](https://determinate.systems/nix/) (macOS only, for nix-darwin system management)
3. Clone this repo to `~/dotfiles`
4. Run the full init pipeline: install zsh, install packages, install apps

If the repo is already cloned, run the init pipeline directly:

```bash
~/dotfiles/scripts/init
```

## Package Management

### Linux — Homebrew (`Brewfile.linux`)

All CLI tools on Linux are managed via [Linuxbrew](https://brew.sh/) in `Brewfile.linux`.

To add/remove packages, edit `Brewfile.linux` and apply:

```bash
brew-up
```

### macOS — nix-darwin (`nix/home.nix`)

CLI tools on macOS are managed via [nix-darwin](https://github.com/LnL7/nix-darwin) + home-manager in `nix/home.nix`. System defaults (dock, keyboard, trackpad) are in `nix/darwin.nix`.

To apply changes:

```bash
nix-switch
```

### Packages not in Homebrew

These tools use their own curl installers (managed in `scripts/install_apps`):
- **deno** — curl installer
- **rust** — rustup
- **tfswitch** — curl installer
- **nvm** — curl installer
- **kitty** — curl installer
- **claude** — curl installer

## Dotfile Symlinks (Stow)

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks from this repo into your home directory:
- `home/` maps to `~/` (`.zshrc`, `.zsh_aliases`, `.gitconfig`, etc.)
- `.config/` maps to `~/.config/` (starship, kitty, fish, hypr, etc.)

Re-link after adding new dotfiles:

```bash
~/dotfiles/scripts/stow
```

## macOS GUI Apps

macOS GUI apps are installed via `Brewfile` (casks only):

```bash
brew bundle --file=~/dotfiles/Brewfile
```
