#!/data/data/com.termux/files/usr/bin/bash

settings_show() {
  ui_title
  ui_section "Configuracoes atuais"
  printf "AgentOS........: %s\n" "$AGENTOS_HOME"
  printf "Projetos.......: %s\n" "$AGENTOS_PROJECTS_DIR"
  printf "GitHub.........: %s\n" "$AGENTOS_GITHUB_DIR"
  printf "Backups........: %s\n" "$AGENTOS_BACKUP_DIR"
  printf "Busca padrao...: %s resultados\n" "$AGENTOS_DEFAULT_SEARCH_LIMIT"
  printf "Branch padrao..: %s\n" "$AGENTOS_DEFAULT_BRANCH"
}

settings_edit() {
  ui_title
  ui_section "Editar configuracoes"

  local value

  value="$(ui_prompt "Pasta de projetos [$AGENTOS_PROJECTS_DIR]")"
  [ -n "$value" ] && AGENTOS_PROJECTS_DIR="$value"

  value="$(ui_prompt "Pasta GitHub [$AGENTOS_GITHUB_DIR]")"
  [ -n "$value" ] && AGENTOS_GITHUB_DIR="$value"

  value="$(ui_prompt "Pasta de backups [$AGENTOS_BACKUP_DIR]")"
  [ -n "$value" ] && AGENTOS_BACKUP_DIR="$value"

  value="$(ui_prompt "Resultados padrao [$AGENTOS_DEFAULT_SEARCH_LIMIT]")"
  [ -n "$value" ] && AGENTOS_DEFAULT_SEARCH_LIMIT="$value"

  value="$(ui_prompt "Branch padrao [$AGENTOS_DEFAULT_BRANCH]")"
  [ -n "$value" ] && AGENTOS_DEFAULT_BRANCH="$value"

  agentos_write_user_config
  agentos_init_dirs
  ui_ok "Configuracoes salvas."
}

menu_settings() {
  while true; do
    ui_title
    ui_header_small "Configuracoes"
    ui_menu_item "1" "Ver configuracoes"
    ui_menu_item "2" "Editar configuracoes"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) settings_show; ui_pause ;;
      2) settings_edit; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
