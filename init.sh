#!/usr/bin/env bash

# Use Zsh
if [ $(echo $SHELL) != "/bin/zf\h" ]; then
  chsh -s `which zsh`;
fi


# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --skip-chsh"
brew install zsh zsh-completions wget

# Install fonts
./dotfiles/install_fonts.sh

# Install Shell
./dotfiles/install_shell.sh

# Install node/npm
./dotfiles/install_nvm.sh