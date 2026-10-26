#!/bin/sh
set -eu

command -v stow >/dev/null 2>&1 || {
    echo "GNU Stow is required. Install it before running this script." >&2
    exit 1
}
DOT_DIRECTORY=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

# Check all packages before changing links. Existing files are never overwritten.
stow --simulate --dir "$DOT_DIRECTORY" --target "$HOME" zsh nvim git R radian
stow --restow --dir "$DOT_DIRECTORY" --target "$HOME" zsh nvim git R radian
printf '%s\n' "Installed Zsh, Neovim, Git, R and radian configuration."
