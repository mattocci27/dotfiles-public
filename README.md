# Dotfiles for Linux containers

Configuration for Zsh, Neovim, Git, R, and radian inside Docker containers.

## Contents

- `zsh/`: History, completion, vi keybindings, prompt, and basic aliases
- `nvim/`: LazyVim configuration with R and Quarto support
- `git/`: Git settings, aliases, and global ignore rules
- `R/`: CRAN settings and Linux `~/.R/Makevars`
- `radian/`: R console appearance and editing settings
- `install.sh`: Configuration symlinks managed with GNU Stow

## Installation

Install `stow`, `zsh`, `git`, `nvim`, and R in the container first.
Use a Neovim version supported by the current LazyVim release.
Building R packages from source also requires GCC/G++, make, and the relevant development libraries.
`install.sh` only creates configuration symlinks; install software and R packages separately.

```sh
cd /path/to/dotfiles-public
sh install.sh
exec zsh
```

Clone or copy the repository anywhere, and keep it at that location after installation because the symlinks point to it.
In a Dockerfile, run the installer with `HOME` set to the home directory of the user who will use the configuration.

```dockerfile
# Run after installing dependencies and switching to the intended user.
COPY --chown=1000:1000 . /opt/dotfiles
RUN sh /opt/dotfiles/install.sh
CMD ["zsh"]
```

Replace `1000:1000` with the intended user's UID and GID.
If a volume mount replaces the home directory, run `install.sh` after mounting it.
The installer stops if existing files conflict. Back up or move those files before trying again.
You can rerun the installer. Its package list is fixed to `zsh nvim git R radian`.

## Zsh

On first startup, Zsh downloads Zinit and loads completion, autosuggestions, syntax highlighting, vi mode, and the Pure prompt.
The plugins are `zsh-completions`, `zsh-autosuggestions`, `fast-syntax-highlighting`, `zsh-vi-mode`, and `pure`.
The initial download requires Git and network access. If Zinit cannot be downloaded, the shell uses built-in completion and a fallback prompt.
Run `ZSH_SKIP_PLUGINS=1 zsh` to skip plugin downloads and loading.
Press `jj` to leave insert mode.

The following integrations are enabled when their tools are installed:

- `fzf`: `Ctrl-R` searches history; `Ctrl-X` selects a recent directory. `fp` selects a file, `vf` opens the selected file in Neovim, and `ff` searches directories.
- `ghq` + `fzf`: `Ctrl-G` selects a repository to navigate to.
- `zoxide`: `z` navigates directories. With `fzf`, `Ctrl-F` selects a destination.
- `eza`: Provides enhanced `ls` aliases.
- `batcat`: Available through the `bat` alias.
- `ripgrep`: Provides file discovery for fzf and search support for Neovim.

## Neovim / R

Neovim needs network access on first startup to download plugins.
Quarto configuration is included; install Quarto separately to render documents.
Install the R package `languageserver` to use an R language server.
To use radian, install `radian` separately in your Python environment.

`~/.R/Makevars` selects `g++` as the C++14 compiler and enables CPU-specific optimizations.
Review these flags before moving compiled packages to a different CPU.

## Git

Configure your own Git name and email in the container or individual projects.
For example, run these commands inside a Git repository to set a project-specific identity:

```sh
git config --local user.name "Your Name"
git config --local user.email "you@example.com"
```

Some interactive Git aliases require `fzf`.
