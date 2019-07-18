# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/tkye/.oh-my-zsh"
if [[ -a ~/.zsh_prompt ]]; then source ~/.zsh_prompt; fi
if [[ -a ~/.zsh_user ]]; then source ~/.zsh_user; fi
plugins=(git ssh-agent nvm npm aws kubectl dotenv)

source $ZSH/oh-my-zsh.sh


export EDITOR='code'

alias dev="cd ~/dev"
alias g="git"
alias k="kubectl"
alias t="terraform"
alias d="docker"
alias serve-http="http-server ./ -p 3000 -c-1 --silent"
alias gup="git fetch -u origin master:master && git checkout master && git pull && g-clean"
alias g-clean="git remote prune origin && git branch --merged | grep -v \"\*\" | grep -v master | grep -v dev | xargs -n 1 git branch -d"
alias g-clean-remote="git branch -r --merged | grep -v master | sed 's/origin\///' | xargs -n 1 git push --delete origin"
alias disk-usage="du -hsx * | sort -n -r"
alias file-size='ls -hlS'
alias docker-kill-all='docker rm -f $(docker ps -a -q)'

if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi