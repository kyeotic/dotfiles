#!/usr/bin/env bash

rm -f ~/.zshrc ~/.zsh_prompt ~/.zsh_user
ln -sf dotfiles/.zshrc $HOME/.zshrc
ln -sf dotfiles/.zsh_prompt $HOME/.zsh_prompt
ln -sf dotfiles/.zsh_aliases $HOME/.zsh_aliases
ln -sf dotfiles/.zsh_functions $HOME/.zsh_functions
ln -sf dotfiles/.gitconfig.work $HOME/.gitconfig

# Hyper doesnt like symlinks, work backwards
cp dotfiles/.hyper.js $HOME/.hyper.js
rm dotfiles/.hyper.js
ln -sf $HOME/.hyper.js dotfiles/.hyper.js

echo "DEFAULT_USER="$USER" # Current User" >> ~/.zsh_user
