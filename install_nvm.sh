#!/usr/bin/env bash

mkdir ~/.nvm
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"


bash -lic "nvm install --lts=Dubnium" # node 10
bash -lic "nvm install --lts=Erbium" # node 12
bash -lic "nvm use 12"
bash -lic "nvm alias default 12"

# Install pnpm
curl -L https://unpkg.com/@pnpm/self-installer | node