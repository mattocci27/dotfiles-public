# Track recently visited directories for cdr and fuzzy navigation.
autoload -Uz add-zsh-hook chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
  fi

  fzf-history-widget() {
    local selected
    selected=$(fc -rl 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | awk '!seen[$0]++' | fzf --query="$LBUFFER" --tiebreak=index +s) || return
    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }
  zle -N fzf-history-widget

  fzf-cdr() {
    local destination
    destination=$(cdr -l | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | fzf --query="$LBUFFER") || return
    [[ -n "$destination" ]] || return
    # cdr abbreviates paths with ~; expand it without evaluating shell input.
    [[ "$destination" == '~' || "$destination" == '~/'* ]] && destination="$HOME${destination:1}"
    BUFFER="cd -- ${(q)destination}"
    zle accept-line
  }
  zle -N fzf-cdr

  fzf-src() {
    local destination
    destination=$(ghq list -p | fzf --query="$LBUFFER") || return
    [[ -n "$destination" ]] || return
    BUFFER="cd -- ${(q)destination}"
    zle accept-line
  }
  zle -N fzf-src

  fzf-z-search() {
    local destination
    destination=$(zoxide query -l | fzf --query="$LBUFFER") || return
    [[ -n "$destination" ]] || return
    BUFFER="cd -- ${(q)destination}"
    zle accept-line
  }
  zle -N fzf-z-search

  fp() {
    if command -v bat >/dev/null 2>&1; then
      fzf --preview 'bat --style=numbers --color=always --line-range :500 -- {}' "$@"
    elif command -v batcat >/dev/null 2>&1; then
      fzf --preview 'batcat --style=numbers --color=always --line-range :500 -- {}' "$@"
    else
      fzf "$@"
    fi
  }
  vf() {
    local file
    file=$(fp) || return
    [[ -n "$file" ]] && nvim -- "$file"
  }
  ff() {
    command find . -type d -print | fzf "$@"
  }
fi
