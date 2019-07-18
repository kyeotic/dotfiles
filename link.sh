#!/usr/bin/env bash

rm ~/.zshrc ~/.zsh_prompt ~/.zsh_user
ln -sf dotfiles/.zshrc $HOME/.zshrc
ln -sf dotfiles/.zsh_prompt $HOME/.zsh_prompt
echo "DEFAULT_USER="$USER" # Current User" >> ~/.zsh_user
cat dotfiles/zshrc-extend >> $HOME/.zshrc