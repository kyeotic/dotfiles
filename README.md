# Dotfiles

This is my personal dotfiles repository. It is for bootstrapping new machines.

# Use

First, make sure **zsh** is installed. MacOS has it by default. For Ubuntu, run

```
sudo apt install zsh
sudo apt-get install powerline fonts-powerline
```

# Install Homebrew

```
# MacOS
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Linux/WSL
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
```

## Init

To Setup dotfiles, run

```
git clone git@github.com:kyeotic/dotfiles.git
./dotfiles/init.sh
```

# Install Mac Apps

```
curl -s 'https://api.macapps.link/en/firefox-drive-vscode-docker-spotify-slack' | sh
```

* [Rectangle](https://rectangleapp.com/) - Window Manager
* [Clipy](https://github.com/Clipy/Clipy) - Multiple Clipboards
* [Hyper](https://hyper.is/) - Terminal (uses dotfiles config `.hyper.js`)

# Work Configuration

```
brew install aws-iam-authenticator awscli gettext gdbm git httpie jq kubernetes-cli kustomize openssl pcre pcre2 python readline telnet watch watchman wget yarn yq zsh zsh-completion
brew install warrensbox/tap/tfswitch
```

## Issues

Fixing "insecure directories"

```bash
sudo chmod -R 755 ~/.oh-my-zsh    
```