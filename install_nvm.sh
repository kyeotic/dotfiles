#!/usr/bin/env bash

mkdir ~/.nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
nvm install 8 --lts
nvm install 10 --lts

nvm use 10
nvm alias default 10