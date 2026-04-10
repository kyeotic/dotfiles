# Deduplicate PATH entries
typeset -U path

# Homebrew (must be early — adds starship, direnv, completions to PATH)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/kyeotic/.zsh/completions:"* ]]; then export FPATH="/home/kyeotic/.zsh/completions:$FPATH"; fi
if [[ ":$FPATH:" != *":/Users/kyeotic/.zsh/completions:"* ]]; then export FPATH="/Users/kyeotic/.zsh/completions:$FPATH"; fi

# Starship
[[ ! -f ~/.starship-rc ]] || source ~/.starship-rc

# Shared Dotfiles
if [[ -a ~/.zsh_functions ]]; then source ~/.zsh_functions; fi
if [[ -a ~/.zsh_aliases ]]; then source ~/.zsh_aliases; fi
if [[ -a ~/.zsh_git ]]; then source ~/.zsh_git; fi
if [[ -a ~/.zsh_just_completions ]]; then source ~/.zsh_just_completions; fi

# Allow local-machine-only configuration
if [[ -a ~/.localrc ]]; then source ~/.localrc; fi

# Vault secrets
if [[ -f ~/.vault-env ]]; then source ~/.vault-env; fi

# Path
export PATH="/usr/local/bin:/usr/local/sbin:$HOME/bin:$PATH"
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/.local/kitty.app/bin" ] ; then
    PATH="$HOME/.local/kitty.app/bin:$PATH"
fi

# Disable flow control (frees Ctrl-S for fzf forward history search)
stty -ixon

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Tools
export EDITOR='code'
# export DENO_INSTALL=$HOME/.deno
# export PATH="$PATH:$DENO_INSTALL/bin"
# export PATH="$PATH:$HOME/.cargo/bin"
export AWS_PAGER=""


export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env" #deno
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env" #rust

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Force PATH dedup (export PATH=... in sourced scripts bypasses typeset -U)
path=("${path[@]}")

# bun completions
[ -s "/home/kyeotic/.bun/_bun" ] && source "/home/kyeotic/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
