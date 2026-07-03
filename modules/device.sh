#!/data/data/com.termux/files/usr/bin/bash

device_space() {
  ui_title
  ui_section "Espaco de armazenamento"
  df -h "$HOME" 2>/dev/null || true
  if agentos_storage_ready; then
    printf "\n"
    df -h "$AGENTOS_TERMUX_DOWNLOADS" 2>/dev/null || true
  fi
}

device_large_files() {
  ui_title
  ui_section "Arquivos grandes no Download/AgentOS"
  agentos_require_storage || return 1
  find "$AGENTOS_PUBLIC_ROOT" -type f -printf "%s\t%p\n" 2>/dev/null | sort -nr | head -n 30 | awk '{ size=$1; $1=""; printf "%.1f MB %s\n", size/1024/1024, $0 }'
}

device_open_paths() {
  ui_title
  ui_section "Caminhos uteis"
  printf "Download Android....: %s\n" "$AGENTOS_TERMUX_DOWNLOADS"
  agentos_public_dirs_report
  printf "\nComandos rapidos:\n"
  printf "cd \"%s\"\n" "$AGENTOS_PUBLIC_ROOT"
  printf "cd \"%s\"\n" "$AGENTOS_PROJECTS_DIR"
  printf "cd \"%s\"\n" "$AGENTOS_GITHUB_DIR"
}

device_clean_safe() {
  ui_title
  ui_section "Limpeza segura"
  ui_info "Remove caches temporarios do AgentOS e cache de pacotes do Termux."
  if ! ui_confirm "Continuar"; then
    return 0
  fi
  rm -rf "$AGENTOS_TMP_DIR"/*
  pkg clean
  ui_ok "Limpeza concluida."
}

device_storage_fix() {
  ui_title
  ui_section "Corrigir acesso ao Download"
  if cmd_exists termux-setup-storage; then
    termux-setup-storage
    ui_info "Aceite a permissao no Android. Depois volte em Configuracoes e crie as pastas."
  else
    ui_error "termux-setup-storage nao encontrado."
  fi
}

device_export_info() {
  ui_title
  ui_section "Exportar informacoes do celular"
  agentos_require_storage || return 1
  mkdir -p "$AGENTOS_EXPORTS_DIR"
  local file="$AGENTOS_EXPORTS_DIR/celular_info_$(date +%Y%m%d_%H%M%S).txt"
  {
    printf "AgentOS - Informacoes do celular/Termux\n"
    printf "Data: %s\n\n" "$(date)"
    uname -a 2>/dev/null || true
    printf "\nEspaco:\n"
    df -h 2>/dev/null || true
    printf "\nPacotes principais:\n"
    for bin in git gh curl wget python node jq ssh; do
      show_command_version "$bin" "$bin" || true
    done
  } > "$file"
  ui_ok "Arquivo salvo em: $file"
}

menu_device() {
  while true; do
    ui_title
    ui_header_small "Meu celular / Termux"
    ui_menu_item "1" "Ver espaco livre"
    ui_menu_item "2" "Listar arquivos grandes do AgentOS"
    ui_menu_item "3" "Mostrar caminhos uteis"
    ui_menu_item "4" "Limpeza segura"
    ui_menu_item "5" "Corrigir permissao do Download"
    ui_menu_item "6" "Exportar informacoes para Download"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) device_space; ui_pause ;;
      2) device_large_files; ui_pause ;;
      3) device_open_paths; ui_pause ;;
      4) device_clean_safe; ui_pause ;;
      5) device_storage_fix; ui_pause ;;
      6) device_export_info; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
