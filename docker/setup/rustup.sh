#!/bin/bash

set -x
set -euo pipefail

# shellcheck disable=SC1091
source /lib.sh

main() {
  local td
  td="$(mktemp -d)"
  builtin pushd "${td}"

  local url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"
  curl --retry 3 --proto '=https' --tlsv1.2 -sSf "$url" > rustup-init
  curl --retry 3 --proto '=https' --tlsv1.2 -sSf "$url.sha256" > rustup-init.sha256
  # Remove "target/x86_64-unknown-linux-gnu/release/" string from rustup-init.sha256
  sed -i 's:\*target/x86_64-unknown-linux-gnu/release/::' rustup-init.sha256
  sha256sum -c rustup-init.sha256
  chmod +x rustup-init
  ./rustup-init --no-modify-path --default-toolchain "$RUSTUP_DEFAULT_TOOLCHAIN" --profile minimal -y
  rustup target add "$RUST_TARGET"
  chmod -R a+w "$RUSTUP_HOME" "$CARGO_HOME"

  # Pre-fetch the registry index
  cargo init --name tmp .
  cargo fetch

  builtin popd
  rm -rf "${td}"
  rm "${0}"
}

main "${@}"
