#!/data/data/com.termux/files/usr/bin/bash

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_step() {
  local label="$1"
  shift
  printf "%s...\n" "$label"
  if "$@"; then
    ui_ok "$label"
    return 0
  fi
  ui_error "$label"
  return 1
}

termux_install_packages() {
  pkg update -y && pkg upgrade -y
  pkg install -y git curl wget gh openssh jq tar zip unzip nano vim tree rsync python nodejs ripgrep fzf htop tmux sqlite
}

show_command_version() {
  local bin="$1"
  local label="$2"

  if cmd_exists "$bin"; then
    printf "%-18s %s\n" "$label:" "$($bin --version 2>/dev/null | head -n 1)"
    return 0
  fi

  printf "%-18s %s\n" "$label:" "nao instalado"
  return 1
}

safe_cd() {
  cd "$1" || {
    ui_error "Nao foi possivel entrar em: $1"
    return 1
  }
}

pkg_install_group() {
  local label="$1"
  shift
  ui_section "$label"
  printf "Pacotes: %s\n\n" "$*"
  if ui_confirm "Instalar/atualizar este grupo"; then
    pkg install -y "$@"
  fi
}

command_preview() {
  ui_section "Comando sugerido"
  printf "%s\n" "$1"
  if ui_confirm "Executar agora"; then
    eval "$1"
  fi
}
