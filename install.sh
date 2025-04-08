#!/bin/sh

set -eu

export PATH="$HOME/.local/bin:$PATH"

echo "Creating directories"
mkdir -p $HOME/.local/{bin,share,etc}

echo "Installing piu"
curl -s https://raw.githubusercontent.com/ponces/piu/master/piu -o $HOME/.local/bin/piu
chmod +x $HOME/.local/bin/piu

echo "Installing required packages"
export DEBIAN_FRONTEND=noninteractive
piu i -y curl unzip zsh

echo "Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Installing zsh plugins"
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
	git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
	git clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

echo "Installing bitwarden CLI"
if [ ! -n "$CODESPACES" ] && [ ! -n "$REMOTE_CONTAINERS" ] && ! command -v bw >/dev/null; then
    curl -sfSL https://github.com/bitwarden/clients/releases/download/cli-v2025.3.0/bw-linux-2025.3.0.zip -o /tmp/bw.zip
    unzip -joq /tmp/bw.zip bw -d $HOME/.local/bin
    rm -f /tmp/bw.zip
    chmod +x $HOME/.local/bin/bw
fi

echo "Installing chezmoi"
if ! chezmoi="$(command -v chezmoi)"; then
    bin_dir="${HOME}/.local/bin"
    chezmoi="${bin_dir}/chezmoi"
    echo "Installing chezmoi to '${chezmoi}'" >&2
    if command -v curl >/dev/null; then
        chezmoi_install_script="$(curl -fsSL get.chezmoi.io)"
    elif command -v wget >/dev/null; then
        chezmoi_install_script="$(wget -qO- get.chezmoi.io)"
    else
        echo "To install chezmoi, you must have curl or wget installed." >&2
        exit 1
    fi
    sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
    unset chezmoi_install_script bin_dir
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}"

echo "Running 'chezmoi $*'" >&2

# Replace current process with chezmoi
exec "$chezmoi" "$@"
