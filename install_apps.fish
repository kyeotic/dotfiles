#!/usr/bin/env fish

brew install awscli gettext git httpie jq \
  openssl pcre pcre2 python readline telnet \
  watch watchman wget yarn yq findutils bat exa fd
brew install warrensbox/tap/tfswitch
brew install --cask phoenix

# Deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install cargo-watch eza wasm-bindgen-cli cargo-generate cargo-make