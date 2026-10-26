# Resolve the repository through the Stow symlink.
DOTFILES_ROOT="${${(%):-%N}:A:h:h}"
for file in "$DOTFILES_ROOT/zsh/.zsh/"*.zsh(N); do
  source "$file"
done

# Keep a usable shell even when plugin installation is unavailable.
autoload -Uz compinit promptinit
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode
zvm_after_init() {
  if command -v fzf >/dev/null 2>&1; then
    bindkey -M viins '^R' fzf-history-widget
    bindkey -M viins '^x' fzf-cdr
    command -v ghq >/dev/null 2>&1 && bindkey -M viins '^g' fzf-src
    command -v zoxide >/dev/null 2>&1 && bindkey -M viins '^f' fzf-z-search
  fi
  return 0
}

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ${ZSH_SKIP_PLUGINS:-0} != 1 ]]; then
  if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]] && command -v git >/dev/null 2>&1; then
    if command mkdir -p "${ZINIT_HOME:h}"; then
      command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" ||
        print -u2 'Zinit installation failed; using built-in Zsh configuration.'
    fi
  fi
fi

if [[ ${ZSH_SKIP_PLUGINS:-0} != 1 && -f "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"
  zinit light zsh-users/zsh-completions
  compinit
  zinit light zsh-users/zsh-autosuggestions
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
  ZVM_READKEY_ENGINE=zle
  zinit light jeffreytse/zsh-vi-mode
  PURE_CMD_MAX_EXEC_TIME=10
  zinit ice pick"async.zsh" src"pure.zsh"
  zinit light sindresorhus/pure
  zinit light zdharma-continuum/fast-syntax-highlighting
else
  compinit
  promptinit
  prompt walters
fi
zvm_after_init

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
