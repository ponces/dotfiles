#!/bin/sh

set -e

curl -sfSL https://go.ponces.dev/base | bash

if [ ! -z "$WSL_DISTRO_NAME" ]; then
    piu install -y wslu xdg-utils
fi

echo "Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	curl -sfSL https://go.ponces.dev/zsh | bash
fi

echo "Installing mise"
if ! command -v mise >/dev/null; then
    curl -sfSL https://go.ponces.dev/mise | bash
fi

echo "Installing Bitwarden CLI"
if ! command -v rbw >/dev/null; then
    curl -sfSL https://go.ponces.dev/rbw | bash
fi

echo "Installing GitHub CLI"
if ! command -v gh >/dev/null; then
    curl -sfSL https://go.ponces.dev/github | bash
fi

echo "Installing Azure CLI"
if ! command -v az >/dev/null; then
    curl -sfSL https://go.ponces.dev/azure | bash
fi

echo "Installing chezmoi"
if ! command -v chezmoi >/dev/null; then
    curl -sfSL https://go.ponces.dev/chezmoi | bash
fi

script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
set -- init --apply --source="${script_dir}"
exec "$chezmoi" "$@"
