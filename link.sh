#!/usr/bin/env bash

rm -f ~/.zshrc ~/.zsh_prompt ~/.zsh_user
ln -sf dotfiles/.zshrc $HOME/.zshrc
ln -sf dotfiles/.zsh_prompt $HOME/.zsh_prompt
ln -sf dotfiles/.zsh_aliases $HOME/.zsh_aliases
ln -sf dotfiles/.gitconfig.work $HOME/.gitconfig
echo "DEFAULT_USER="$USER" # Current User" >> ~/.zsh_user
