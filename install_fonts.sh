#!/usr/bin/env bash


if [ -d "fonts" ] 
then
    (cd fonts && git pull)
else
    git clone https://github.com/powerline/fonts.git
fi

pushd fonts

# Extra Powerlevel 10k Fonts
if [ ! -d "powerlevel10k" ] 
then
    mkdir powerlevel10k
fi

pushd powerlevel10k
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
popd

# Install them to Fonts
./install.sh

popd

brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font