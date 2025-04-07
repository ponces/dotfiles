#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

if [ ! -n "$CODESPACES" ] && [ ! -n "$REMOTE_CONTAINERS" ] && ! command -v bw >/dev/null; then
	curl -sfSL https://github.com/bitwarden/clients/releases/download/cli-v2025.3.0/bw-linux-2025.3.0.zip -o /tmp/bw.zip
	unzip -joq /tmp/bw.zip bw -d $HOME/.local/bin
	rm -f /tmp/bw.zip
	chmod +x $HOME/.local/bin/bw
fi

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
# exec: replace current process with chezmoi
exec "$chezmoi" "$@"
