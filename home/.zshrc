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
. "$HOME/.deno/env" #deno
. "$HOME/.cargo/env" #rust

# SSH
# Start ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s >/dev/null)"
  
  # Add all private keys in .ssh directory (excluding known_hosts, config, etc)
  find ~/.ssh -type f -not -name "*.pub" -not -name "known_hosts" -not -name "authorized_keys" -not -name "config" -exec grep -l "PRIVATE KEY" {} \; 2>/dev/null | xargs -r ssh-add 2>/dev/null
fi

# Nvm
export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion