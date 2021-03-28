#!/usr/bin/env bash

# Use Zsh
if [ $(echo $SHELL) != "/bin/zf\h" ]; then
    chsh -s `which zsh`;
fi

brew install zsh zsh-completions wget

if [ -d "$HOME/.oh-my-zsh" ] 
then
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --skip-chsh"
    (cd .oh-my-zsh/custom && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git themes/powerlevel10k)
fi

git config --global init.defaultBranch main

# Fix "insecure directories" warning
sudo chmod -R 755 ~/.oh-my-zsh

# Install Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || return 0

# update rc
./dotfiles/link.sh
touch ~/.localrc