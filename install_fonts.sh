#!/usr/bin/env bash


git clone https://github.com/powerline/fonts.git
pushd fonts

# Extra Powerlevel 10k Fonts
mkdir powerlevel10k
pushd powerlevel10k
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
popd

# Install them to Fonts
./install.sh
popd