fish_add_path /opt/homebrew/bin

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g theme_nerd_fonts yes
end

fish_ssh_agent

source ~/.zsh_aliases
direnv hook fish | source