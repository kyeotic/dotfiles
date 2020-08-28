# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
if [[ -a ~/.zsh_prompt ]]; then source ~/.zsh_prompt; fi
if [[ -a ~/.zsh_user ]]; then source ~/.zsh_user; fi
plugins=(git ssh-agent nvm aws kubectl dotenv rust)

source $ZSH/oh-my-zsh.sh


export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export EDITOR='code'
export DENO_INSTALL=$HOME/.deno
export PATH="$DENO_INSTALL/bin:$PATH"

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
