#!/usr/bin/env bash

# Install Homebrew (works for MacOS, Linux, and WSL!)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure Shell (fish)
./dotfiles/install_shell

# Configure everything else (requires fish)
./dotfiles/install_fonts.fish
./dotfiles/install_nvm.fish
./dotfiles/install_apps.fish