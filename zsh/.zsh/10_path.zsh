# Keep PATH supplied by the Docker image, adding user-installed tools.
typeset -U path PATH
for directory in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/bin"; do
  [[ -d "$directory" ]] && path=("$directory" $path)
done
unset directory
