#!/usr/bin/env bash

rm -f ~/.zshrc ~/.zsh_prompt ~/.zsh_user
ln -sf dotfiles/.zshrc $HOME/.zshrc
ln -sf dotfiles/.zsh_aliases $HOME/.zsh_aliases
ln -sf dotfiles/.zsh_functions $HOME/.zsh_functions
ln -sf dotfiles/.gitconfig.work $HOME/.gitconfig

# Hyper and p10k require hardlinkes
rm $HOME/.p10k.zsh
rm $HOME/.hyper.js
ln dotfiles/.p10k.zsh $HOME/.p10k.zsh
ln dotfiles/.hyper.js $HOME/.hyper.js 

echo "DEFAULT_USER="$USER" # Current User" >> ~/.zsh_user
