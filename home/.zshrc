# Starship
[[ ! -f ~/.starship-rc ]] || source ~/.starship-rc

# Shared Dotfiles
if [[ -a ~/.zsh_functions ]]; then source ~/.zsh_functions; fi
if [[ -a ~/.zsh_aliases ]]; then source ~/.zsh_aliases; fi
if [[ -a ~/.zsh_git ]]; then source ~/.zsh_git; fi

# Allow local-machine-only configuration
if [[ -a ~/.localrc ]]; then source ~/.localrc; fi

# Path
export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export EDITOR='code'
# export DENO_INSTALL=$HOME/.deno
# export PATH="$PATH:$DENO_INSTALL/bin"
# export PATH="$PATH:$HOME/.cargo/bin"
export AWS_PAGER=""
. "/Users/tkye/.deno/env" #deno
. "$HOME/.cargo/env" #rust

# Nvm
export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion