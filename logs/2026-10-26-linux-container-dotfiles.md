# Linux Container Dotfiles Cleanup

## Goal

Prepare a minimal public dotfiles repository for comfortable Zsh, Neovim, Git, R and radian use inside Docker containers.

## Important findings

- The original installer scanned top-level directories and assumed the repository lived at `~/dotfiles`.
- Zsh included personal synchronization, SSH, cloud, host-specific and macOS configuration.
- R's Linux Makevars was only deployed by the separate setup/deploy flow.
- Code and Zed settings had pre-existing local changes before cleanup.

## Changes and decisions

- Keep `zsh/`, `nvim/`, `git/`, `R/`, `radian/`, the installer and repository documentation/configuration. Remove unrelated application settings, setup/dependency scripts, utilities, agent configuration and old logs.
- Fix the install package list to `zsh nvim git R radian`; derive the repository path from the script location. Preflight all packages with Stow before restowing. Existing conflicting files cause a stop rather than being overwritten.
- Rename Linux Makevars to `R/.R/Makevars` so Stow deploys it directly; remove Darwin Makevars and simplify `.Rprofile` to CRAN configuration.
- Remove personal Git identity, Git LFS filter configuration and macOS Sourcetree integration; retain general Git settings and aliases.
- Remove Neovim's tmux integration and separate VS Code configuration; retain LazyVim and R / Quarto configuration.
- Initially simplified Zsh too far. Following user feedback, restore Zinit, Pure, autosuggestions, completions, syntax highlighting and zsh-vi-mode with `jj`.
- Retain fuzzy history, recent-directory navigation, ghq/zoxide navigation and file selection/preview. Guard optional command integrations. Do not restore synchronization, SSH, cloud or macOS settings.
- Preserve Docker-provided PATH and derive the Zsh repository root through its Stow symlink.
- Add `ZSH_SKIP_PLUGINS=1` for startup without plugins. Failed Zinit cloning falls back to built-in completion and prompt. Individual plugin download failures have not been verified.
- Update README with installation, Docker usage, optional tools and R/Git configuration guidance.
- Recreate `logs/` for this explicitly requested session log; it is excluded from installation by the fixed package list.

## Files changed

- `install.sh`, `README.md`, `.gitignore`
- `zsh/.zshrc`, `zsh/.zsh/{10_path,20_env,40_aliases,50_functions}.zsh`
- `git/.gitconfig`, `R/.Rprofile`, `R/.R/Makevars`
- Removed Zsh personal integration fragments and `.zprofile`, Darwin Makevars, Neovim tmux/VS Code integration, and unrelated top-level directories/files.
- `radian/` and Zsh's basic history/options configuration remain in place.

## Validation

- Shell syntax checks and `git diff --check` passed.
- Temporary-home Stow installation from another working directory, repeat installation and expected link resolution passed.
- Conflict test confirmed an existing `.zshrc` was preserved and installation stopped before creating other package links.
- Zsh startup with plugins skipped passed without stderr.
- Simulated Git clone failure confirmed fallback prompt startup.

## Current state and remaining work

- Changes are uncommitted; no commit or push was requested or performed.
- Docker execution, real Zinit/plugin installation and interactive bindings remain unverified.
- Neovim plugin installation and R/radian runtime behavior remain unverified.
- Best next action: build/run the intended Docker image and check an interactive Zsh session, plugin initialization, fuzzy bindings, Neovim and R/radian.
- Keep the restored Zsh usability features; do not repeat the earlier excessive simplification.
- Existing Code/Zed changes were copied before removal to `/var/folders/qy/qxft5n7x7dg39h2rjp8bwsh80000gn/T/dotfiles-public-prune-dgi085k6`. This is a temporary backup, outside the repository.
