# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
if [[ -a ~/.zsh_prompt ]]; then source ~/.zsh_prompt; fi
if [[ -a ~/.zsh_user ]]; then source ~/.zsh_user; fi
plugins=(git ssh-agent nvm aws kubectl dotenv rust)

source $ZSH/oh-my-zsh.sh

export EDITOR='code'

if [[ -a ~/.zsh_aliases ]]; then source ~/.zsh_aliases; fi
if [[ -a ~/.zsh_functions ]]; then source ~/.zsh_functions; fi

# Allow local-machine-only configuration

if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/tkye/dev/digital-library-api/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/tkye/dev/digital-library-api/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/tkye/dev/digital-library-api/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/tkye/dev/digital-library-api/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /Users/tkye/dev/digital-library-api/node_modules/tabtab/.completions/slss.zsh ]] && . /Users/tkye/dev/digital-library-api/node_modules/tabtab/.completions/slss.zsh