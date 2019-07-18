# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/tkye/.oh-my-zsh"
if [[ -a ~/.zsh_prompt ]]; then source ~/.zsh_prompt; fi
if [[ -a ~/.zsh_user ]]; then source ~/.zsh_user; fi
plugins=(git ssh-agent nvm npm aws kubectl dotenv)

source $ZSH/oh-my-zsh.sh

export EDITOR='code'

if [[ -a ~/.zsh_aliases ]]; then source ~/.zsh_aliases; fi

# Allow local-machine-only configuration

if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi