# Dotfiles

This is my personal dotfiles repository. It is for bootstrapping new machines.

## Fresh Machine Setup

On a brand new machine, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyeotic/dotfiles/HEAD/init/install)"
```

This will:
1. Install git and curl via the system package manager
2. Install [Nix](https://determinate.systems/nix/) (Determinate Systems installer)
3. Clone this repo to `~/dotfiles`
4. Run the full init pipeline: install zsh, bootstrap home-manager, install apps, install nvm

If the repo is already cloned, run the init pipeline directly:

```bash
~/dotfiles/init/init
```

## Package Management (Nix + Home Manager)

All CLI tools are managed declaratively via [home-manager](https://github.com/nix-community/home-manager) in `nix/home.nix`. Fonts are also managed here (except on WSL).

### Adding or removing packages

Edit `nix/home.nix` and add/remove packages from the `home.packages` list, then apply:

```bash
nix-switch
```

Or equivalently: `~/dotfiles/nix/switch`

The switch script auto-detects your platform and username to select the right profile.

### Available profiles

| Profile             | Platform                     | Username |
| ------------------- | ---------------------------- | -------- |
| `kyeotic@macos`     | macOS (Apple Silicon)        | kyeotic  |
| `kyeotic@linux`     | Linux / WSL                  | kyeotic  |
| `tkye@macos`        | macOS (Apple Silicon) — work | tkye     |

Profiles are defined in `nix/flake.nix`. To add a new profile, add an entry to `homeConfigurations` with the appropriate system, username, and home directory.

### Packages not in Nix

These tools use their own installers (managed in `init/install_apps`):
- **deno** — curl installer
- **rust** — rustup
- **tfswitch** — curl installer
- **nvm** — curl installer (in `init/install_nvm`)
- **Phoenix** (macOS window manager) — manual install from [github.com/kasper/phoenix](https://github.com/kasper/phoenix)

## Dotfile Symlinks (Stow)

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks from this repo into your home directory:
- `home/` maps to `~/` (`.zshrc`, `.zsh_aliases`, `.gitconfig`, etc.)
- `.config/` maps to `~/.config/` (starship, kitty, fish, hypr, etc.)

Re-link after adding new dotfiles:

```bash
~/dotfiles/init/stow
```


## Install Mac Apps

```
curl -s 'https://api.macapps.link/en/discord-drive-vscode-docker-spotify-slack' | sh
```

* [Rectangle](https://rectangleapp.com/) - Window Manager
* [Clipy](https://github.com/Clipy/Clipy) - Multiple Clipboards
