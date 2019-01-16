# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{bash_prompt,aliases}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
[[ -s ~/.bashrc ]] && source ~/.bashrc

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;

export EDITOR='code'
ssh-add -A #osx keychain identities

export HOMEBREW_GITHUB_API_TOKEN=ee4a70705209d9acfbd73b882420274c0466efeb
export GOPATH=$HOME/dev/go
export PATH=$PATH:$(go env GOPATH)/bin

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
