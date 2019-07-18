#!/usr/bin/env bash

# Use Zsh
chsh -s `which zsh`

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh zsh-completions
git clone https://github.com/powerline/fonts.git
(cd fonts && ./install.sh)
(cd .oh-my-zsh/custom && git clone https://github.com/romkatv/powerlevel10k.git themes/powerlevel10k)

# update rc
./link.sh