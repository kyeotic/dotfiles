#!/usr/bin/env bash

mkdir ~/.nvm
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"


bash -lic "nvm install 8 --lts"
bash -lic "nvm install 10 --lts"
bash -lic "nvm use 10"
bash -lic "nvm alias default 10"

# Install pnpm
curl -L https://unpkg.com/@pnpm/self-installer | node