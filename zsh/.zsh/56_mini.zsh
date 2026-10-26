mini-on-home-lan() {
  ssh \
    -o BatchMode=yes \
    -o ConnectTimeout=2 \
    -o ConnectionAttempts=1 \
    mac-mini-local true \
    >/dev/null 2>&1
}

mini-host() {
  case "$1" in
    -a)
      echo "mac-mini-ali"
      return 0
      ;;
    -s)
      echo "mac-mini-sakura"
      return 0
      ;;
  esac

  if mini-on-home-lan; then
    echo "mac-mini-local"
  else
    echo "mac-mini-ali"
  fi
}

mini-rsync-build-opts() {
  local stamp="$1"
  local exclude_file="$MINI_RSYNC_EXCLUDES"

  MINI_RSYNC_OPTS=(
    -a
    -v
    --no-owner
    --no-group
    --no-perms
    --omit-dir-times
    --delete
    --itemize-changes
    --human-readable
    --partial
    --rsync-path=/opt/homebrew/bin/rsync
  )

  if [[ -f "$exclude_file" ]]; then
    MINI_RSYNC_OPTS+=("--filter=. $exclude_file")
  else
    MINI_RSYNC_OPTS+=(
      "--filter=H .DS_Store"
      --exclude '.rsync-trash/'
      --exclude '2-Areas/Research/MS/On-hold/'
      --exclude '2-Areas/Research/MS/Published/'
      --exclude '4-Archives/'
    )
  fi
}

push-mini() {
  local host ans stamp
  host=$(mini-host "$1")
  stamp=$(date "+%Y%m%d-%H%M%S")
  mini-rsync-build-opts "$stamp"
  echo "Using host: $host"

  echo "🔍 DRY RUN (Air → $host)"
  rsync "${MINI_RSYNC_OPTS[@]}" --dry-run \
    "$WORKSPACE/" \
    "${host}:$THUNDER_WORKSPACE/" || return 1

  echo
  read "ans?🚀 Execute? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  echo "🚀 EXECUTE (Air → $host)"
  rsync "${MINI_RSYNC_OPTS[@]}" \
    "$WORKSPACE/" \
    "${host}:$THUNDER_WORKSPACE/"
}

pull-mini() {
  local host ans stamp
  host=$(mini-host "$1")
  stamp=$(date "+%Y%m%d-%H%M%S")
  mini-rsync-build-opts "$stamp"
  echo "Using host: $host"

  echo "🔍 DRY RUN ($host → Air)"
  rsync "${MINI_RSYNC_OPTS[@]}" --dry-run \
    "${host}:$THUNDER_WORKSPACE/" \
    "$WORKSPACE/" || return 1

  echo
  read "ans?🚀 Execute? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  echo "🚀 EXECUTE ($host → Air)"
  rsync "${MINI_RSYNC_OPTS[@]}" \
    "${host}:$THUNDER_WORKSPACE/" \
    "$WORKSPACE/"
}

push-ms() {
  local host ans host_arg section name src dst stamp

  # Consume an optional host selector before reading the MS section and name.
  case "$1" in
    -a|-s)
      host_arg="$1"
      shift
      ;;
  esac

  section="$1"
  name="$2"

  if [[ -z "$section" || -z "$name" ]]; then
    echo "Usage: push-ms [-a|-s] <On-hold|Published> <name>"
    return 1
  fi

  case "$section" in
    On-hold|Published) ;;
    *)
      echo "Error: section must be 'On-hold' or 'Published'"
      return 1
      ;;
  esac

  host=$(mini-host "$host_arg")
  stamp=$(date "+%Y%m%d-%H%M%S")
  mini-rsync-build-opts "$stamp"

  src="$WORKSPACE/2-Areas/Research/MS/${section}/${name}.stub/"
  dst="$THUNDER_WORKSPACE/2-Areas/Research/MS/${section}/${name}.stub/"

  if [[ ! -d "$src" ]]; then
    echo "Error: source not found: $src"
    return 1
  fi

  echo "Using host: $host"
  echo "🔍 DRY RUN (Air → $host)"
  rsync "${MINI_RSYNC_OPTS[@]}" --dry-run \
    "$src" \
    "${host}:$dst" || return 1

  echo
  read "ans?🚀 Execute push-ms? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  echo "🚀 EXECUTE (Air → $host)"
  rsync "${MINI_RSYNC_OPTS[@]}" \
    "$src" \
    "${host}:$dst"
}


pull-ms() {
  local host ans host_arg section name src dst stamp

  # Consume an optional host selector before reading the MS section and name.
  case "$1" in
    -a|-s)
      host_arg="$1"
      shift
      ;;
  esac

  section="$1"
  name="$2"

  if [[ -z "$section" || -z "$name" ]]; then
    echo "Usage: pull-ms [-a|-s] <On-hold|Published> <name>"
    return 1
  fi

  case "$section" in
    On-hold|Published) ;;
    *)
      echo "Error: section must be 'On-hold' or 'Published'"
      return 1
      ;;
  esac

  host=$(mini-host "$host_arg")
  stamp=$(date "+%Y%m%d-%H%M%S")
  mini-rsync-build-opts "$stamp"

  src="$THUNDER_WORKSPACE/2-Areas/Research/MS/${section}/${name}.stub/"
  dst="$WORKSPACE/2-Areas/Research/MS/${section}/${name}.stub/"

  echo "Using host: $host"
  echo "🔍 DRY RUN ($host → Air)"
  rsync "${MINI_RSYNC_OPTS[@]}" --dry-run \
    "${host}:$src" \
    "$dst" || return 1

  echo
  read "ans?🚀 Execute pull-ms? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  echo "🚀 EXECUTE ($host → Air)"
  rsync "${MINI_RSYNC_OPTS[@]}" \
    "${host}:$src" \
    "$dst"
}

vault-rsync-build-opts() {
  local stamp="$1"
  local exclude_file="$VAULT_RSYNC_EXCLUDES"

  VAULT_RSYNC_OPTS=(
    -a
    -v
    --no-owner
    --no-group
    --no-perms
    --omit-dir-times
    --delete
    --itemize-changes
    --human-readable
    --partial
  )

  if [[ -f "$exclude_file" ]]; then
    VAULT_RSYNC_OPTS+=("--filter=. $exclude_file")
  else
    VAULT_RSYNC_OPTS+=(
      "--filter=H .DS_Store"
      --exclude '.rsync-trash/'
    )
  fi
}

push-vault-backup() {
  local ans stamp
  local src="$THUNDER_ROOT/"
  local dst="$VAULT_BACKUP/"

  if [[ ! -d "$src" ]]; then
    echo "❌ Source not found: $src"
    return 1
  fi

  if [[ ! -d "$VAULT_ROOT" ]]; then
    echo "❌ Vault is not mounted: $VAULT_ROOT"
    return 1
  fi

  mkdir -p "$dst"

  stamp=$(date "+%Y%m%d-%H%M%S")
  vault-rsync-build-opts "$stamp"

  echo "🔍 DRY RUN (ThunderDrive → Vault/Backup)"
  rsync "${VAULT_RSYNC_OPTS[@]}" --dry-run \
    "$src" \
    "$dst" || return 1

  echo
  read "ans?🚀 Execute backup sync? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  echo "🚀 EXECUTE (ThunderDrive → Vault/Backup)"
  rsync "${VAULT_RSYNC_OPTS[@]}" \
    "$src" \
    "$dst"
}

push-radiko-backup() {
  local ans stamp src dst history
  src="$THUNDER_ROOT/3-Resources/Media/radiko/"
  dst="$VAULT_BACKUP/3-Resources/Media/radiko/"

  if [[ ! -d "$src" ]]; then
    echo "❌ Source not found: $src"
    return 1
  fi

  if [[ ! -d "$VAULT_ROOT" ]]; then
    echo "❌ Vault is not mounted: $VAULT_ROOT"
    return 1
  fi

  mkdir -p "$dst"

  stamp=$(date "+%Y%m%d-%H%M%S")
  history="$VAULT_ROOT/Backup-History/radiko/$stamp"
  vault-rsync-build-opts "$stamp"
  VAULT_RSYNC_OPTS+=(--backup "--backup-dir=$history")

  echo "🔍 DRY RUN (ThunderDrive/radiko → Vault/Backup/radiko)"
  rsync "${VAULT_RSYNC_OPTS[@]}" --dry-run \
    "$src" \
    "$dst" || return 1

  echo
  read "ans?🚀 Execute radiko backup sync? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  mkdir -p "$history"
  echo "🚀 EXECUTE (ThunderDrive/radiko → Vault/Backup/radiko)"
  rsync "${VAULT_RSYNC_OPTS[@]}" \
    "$src" \
    "$dst"
}

pull-vault-backup() {
  local ans stamp
  local src="$VAULT_BACKUP/"
  local dst="$THUNDER_ROOT/"

  if [[ ! -d "$src" ]]; then
    echo "❌ Source not found: $src"
    return 1
  fi

  if [[ ! -d "$dst" ]]; then
    echo "❌ ThunderDrive is not mounted: $dst"
    return 1
  fi

  stamp=$(date "+%Y%m%d-%H%M%S")
  vault-rsync-build-opts "$stamp"

  echo "🔍 DRY RUN (Vault/Backup → ThunderDrive)"
  rsync "${VAULT_RSYNC_OPTS[@]}" --dry-run \
    "$src" \
    "$dst" || return 1

  echo
  read "ans?🚨 Restore from Vault/Backup to ThunderDrive? (y/N): "
  [[ "$ans" != "y" ]] && echo "❌ Cancelled" && return 0

  echo "🚀 EXECUTE (Vault/Backup → ThunderDrive)"
  rsync "${VAULT_RSYNC_OPTS[@]}" \
    "$src" \
    "$dst"
}
