#!/bin/sh

set -e

[ -z $TMPDIR ] && [ -d /tmp ] && TMPDIR="/tmp"

export PATH="$HOME/.local/bin:$PATH"

echo "Creating directories"
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/etc
mkdir -p $HOME/.local/share

echo "Installing piu"
curl -sfSL https://go.ponces.xyz/piu | bash

echo "Installing required packages"
export DEBIAN_FRONTEND=noninteractive
piu install -y bash curl ccze jq less tar unzip zsh

echo "Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	curl -sfSL https://go.ponces.xyz/zsh | bash
fi

echo "Installing zsh plugins"
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
	git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
	git clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

echo "Installing mise"
if ! command -v mise >/dev/null; then
    curl -sfSL https://go.ponces.xyz/mise | bash
fi

echo "Installing bitwarden CLI"
if ! command -v rbw >/dev/null; then
    curl -sfSL https://go.ponces.xyz/rbw | bash
fi

echo "Installing github CLI"
if ! command -v gh >/dev/null; then
    curl -sfSL https://go.ponces.xyz/github | bash
fi

echo "Installing azure CLI"
if ! command -v az >/dev/null; then
    curl -sfSL https://go.ponces.xyz/azure | bash
fi

echo "Installing chezmoi"
if ! command -v chezmoi >/dev/null; then
    curl -sfSL https://go.ponces.xyz/chezmoi | bash
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}"

echo "Running 'chezmoi $*'" >&2

# Replace current process with chezmoi
exec "$chezmoi" "$@"
