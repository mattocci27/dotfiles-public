alias v='nvim'
alias ll='ls -lh'
alias la='ls -lah'
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -F'
  alias ll='eza -lh'
  alias la='eza -lah'
  alias tree='eza --tree'
fi
if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias -g L='| less'
alias -g G='| grep'
