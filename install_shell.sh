#!/usr/bin/env bash

# Use Zsh
if [ $(echo $SHELL) != "/bin/zf\h" ]; then
  chsh -s `which zsh`;
fi

./dotfiles/install_fonts.sh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --skip-chsh"
brew install zsh zsh-completions wget

# Install oh-my-zsh
(cd .oh-my-zsh/custom && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git themes/powerlevel10k)
# Fix "insecure directories" warning
sudo chmod -R 755 ~/.oh-my-zsh

# update rc
./dotfiles/link.sh
touch ~/.localrc