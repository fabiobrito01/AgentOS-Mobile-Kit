#!/data/data/com.termux/files/usr/bin/bash

AGENTOS_HOME="${AGENTOS_HOME:-$HOME/AgentOS-Mobile-Kit}"
AGENTOS_CONFIG_FILE="$AGENTOS_HOME/configs/agentos.conf"
AGENTOS_DEFAULT_CONFIG="$AGENTOS_HOME/configs/default.conf"
AGENTOS_DATA_DIR="$AGENTOS_HOME/data"
AGENTOS_LOG_DIR="$AGENTOS_HOME/logs"
AGENTOS_TMP_DIR="$AGENTOS_HOME/tmp"
AGENTOS_WORKSPACE_DIR="$AGENTOS_HOME/workspace"
AGENTOS_TERMUX_DOWNLOADS="$HOME/storage/downloads"

agentos_load_config() {
  if [ -f "$AGENTOS_DEFAULT_CONFIG" ]; then
    # shellcheck disable=SC1090
    source "$AGENTOS_DEFAULT_CONFIG"
  fi

  if [ -f "$AGENTOS_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$AGENTOS_CONFIG_FILE"
  fi

  AGENTOS_PUBLIC_ROOT="${AGENTOS_PUBLIC_ROOT:-$HOME/storage/downloads/AgentOS}"
  AGENTOS_PROJECTS_DIR="${AGENTOS_PROJECTS_DIR:-$AGENTOS_PUBLIC_ROOT/Projetos}"
  AGENTOS_GITHUB_DIR="${AGENTOS_GITHUB_DIR:-$AGENTOS_PUBLIC_ROOT/GitHub}"
  AGENTOS_BACKUP_DIR="${AGENTOS_BACKUP_DIR:-$AGENTOS_PUBLIC_ROOT/Backups}"
  AGENTOS_EXPORTS_DIR="${AGENTOS_EXPORTS_DIR:-$AGENTOS_PUBLIC_ROOT/Exportacoes}"
  AGENTOS_DEFAULT_SEARCH_LIMIT="${AGENTOS_DEFAULT_SEARCH_LIMIT:-20}"
  AGENTOS_DEFAULT_BRANCH="${AGENTOS_DEFAULT_BRANCH:-main}"
}

agentos_storage_ready() {
  [ -d "$AGENTOS_TERMUX_DOWNLOADS" ]
}

agentos_init_dirs() {
  mkdir -p \
    "$AGENTOS_HOME" \
    "$AGENTOS_HOME/configs" \
    "$AGENTOS_HOME/lib" \
    "$AGENTOS_HOME/modules" \
    "$AGENTOS_HOME/docs" \
    "$AGENTOS_DATA_DIR" \
    "$AGENTOS_LOG_DIR" \
    "$AGENTOS_TMP_DIR" \
    "$AGENTOS_WORKSPACE_DIR"

  if agentos_storage_ready; then
    mkdir -p \
      "$AGENTOS_PUBLIC_ROOT" \
      "$AGENTOS_PROJECTS_DIR" \
      "$AGENTOS_GITHUB_DIR" \
      "$AGENTOS_BACKUP_DIR" \
      "$AGENTOS_EXPORTS_DIR"
  fi
}

agentos_require_storage() {
  if agentos_storage_ready; then
    mkdir -p \
      "$AGENTOS_PUBLIC_ROOT" \
      "$AGENTOS_PROJECTS_DIR" \
      "$AGENTOS_GITHUB_DIR" \
      "$AGENTOS_BACKUP_DIR" \
      "$AGENTOS_EXPORTS_DIR"
    return 0
  fi

  ui_error "A pasta de Download do Android ainda nao esta acessivel."
  ui_info "No Termux, rode: termux-setup-storage"
  ui_info "Depois feche e abra o Termux, ou volte ao menu e tente novamente."
  return 1
}

agentos_reset_public_dirs() {
  AGENTOS_PUBLIC_ROOT="$HOME/storage/downloads/AgentOS"
  AGENTOS_PROJECTS_DIR="$AGENTOS_PUBLIC_ROOT/Projetos"
  AGENTOS_GITHUB_DIR="$AGENTOS_PUBLIC_ROOT/GitHub"
  AGENTOS_BACKUP_DIR="$AGENTOS_PUBLIC_ROOT/Backups"
  AGENTOS_EXPORTS_DIR="$AGENTOS_PUBLIC_ROOT/Exportacoes"
}

agentos_public_dirs_report() {
  printf "Raiz publica...: %s\n" "$AGENTOS_PUBLIC_ROOT"
  printf "Projetos.......: %s\n" "$AGENTOS_PROJECTS_DIR"
  printf "GitHub.........: %s\n" "$AGENTOS_GITHUB_DIR"
  printf "Backups........: %s\n" "$AGENTOS_BACKUP_DIR"
  printf "Exportacoes....: %s\n" "$AGENTOS_EXPORTS_DIR"
}

agentos_write_user_config() {
  mkdir -p "$AGENTOS_HOME/configs"
  cat > "$AGENTOS_CONFIG_FILE" <<EOF
AGENTOS_PROJECTS_DIR="$AGENTOS_PROJECTS_DIR"
AGENTOS_GITHUB_DIR="$AGENTOS_GITHUB_DIR"
AGENTOS_BACKUP_DIR="$AGENTOS_BACKUP_DIR"
AGENTOS_EXPORTS_DIR="$AGENTOS_EXPORTS_DIR"
AGENTOS_PUBLIC_ROOT="$AGENTOS_PUBLIC_ROOT"
AGENTOS_DEFAULT_SEARCH_LIMIT="$AGENTOS_DEFAULT_SEARCH_LIMIT"
AGENTOS_DEFAULT_BRANCH="$AGENTOS_DEFAULT_BRANCH"
EOF
}

agentos_log() {
  mkdir -p "$AGENTOS_LOG_DIR"
  printf "%s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$AGENTOS_LOG_DIR/agentos.log"
}
