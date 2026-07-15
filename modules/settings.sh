#!/data/data/com.termux/files/usr/bin/bash

settings_show() {
  ui_title
  ui_section "Configuracoes atuais"
  printf "AgentOS........: %s\n" "$AGENTOS_HOME"
  agentos_public_dirs_report
  printf "Busca padrao...: %s resultados\n" "$AGENTOS_DEFAULT_SEARCH_LIMIT"
  printf "Branch padrao..: %s\n" "$AGENTOS_DEFAULT_BRANCH"
  printf "Config usuario.: %s\n" "$AGENTOS_CONFIG_FILE"
}

settings_edit() {
  ui_title
  ui_section "Editar configuracoes"

  local value

  value="$(ui_prompt_back "Pasta de projetos [$AGENTOS_PROJECTS_DIR]")" || return 0
  [ -n "$value" ] && AGENTOS_PROJECTS_DIR="$value"

  value="$(ui_prompt_back "Pasta GitHub [$AGENTOS_GITHUB_DIR]")" || return 0
  [ -n "$value" ] && AGENTOS_GITHUB_DIR="$value"

  value="$(ui_prompt_back "Pasta de backups [$AGENTOS_BACKUP_DIR]")" || return 0
  [ -n "$value" ] && AGENTOS_BACKUP_DIR="$value"

  value="$(ui_prompt_back "Pasta de exportacoes [$AGENTOS_EXPORTS_DIR]")" || return 0
  [ -n "$value" ] && AGENTOS_EXPORTS_DIR="$value"

  value="$(ui_prompt_back "Resultados padrao [$AGENTOS_DEFAULT_SEARCH_LIMIT]")" || return 0
  [ -n "$value" ] && AGENTOS_DEFAULT_SEARCH_LIMIT="$value"

  value="$(ui_prompt_back "Branch padrao [$AGENTOS_DEFAULT_BRANCH]")" || return 0
  [ -n "$value" ] && AGENTOS_DEFAULT_BRANCH="$value"

  agentos_write_user_config
  agentos_init_dirs
  ui_ok "Configuracoes salvas."
}

settings_prepare_downloads() {
  ui_title
  ui_section "Preparar pastas no Download"

  if ! agentos_storage_ready; then
    ui_warn "A permissao de armazenamento ainda nao parece pronta."
    if cmd_exists termux-setup-storage && ui_confirm "Executar termux-setup-storage agora"; then
      termux-setup-storage
      ui_info "Confirme a permissao no Android e rode esta opcao de novo."
    fi
    return 1
  fi

  agentos_reset_public_dirs
  agentos_write_user_config
  agentos_init_dirs
  ui_ok "Pastas publicas criadas no Download."
  agentos_public_dirs_report
}

settings_git_identity() {
  ui_title
  ui_section "Identidade Git"

  local current_name
  local current_email
  local name
  local email

  current_name="$(git config --global user.name 2>/dev/null || true)"
  current_email="$(git config --global user.email 2>/dev/null || true)"

  printf "Nome atual..: %s\n" "${current_name:-nao configurado}"
  printf "Email atual.: %s\n\n" "${current_email:-nao configurado}"

  name="$(ui_prompt_back "Novo nome [$current_name]")" || return 0
  email="$(ui_prompt_back "Novo email [$current_email]")" || return 0
  [ -n "$name" ] && git config --global user.name "$name"
  [ -n "$email" ] && git config --global user.email "$email"
  git config --global init.defaultBranch "$AGENTOS_DEFAULT_BRANCH"
  git config --global pull.rebase false
  git config --global core.editor nano
  ui_ok "Identidade Git atualizada."
}

settings_open_config_hint() {
  ui_title
  ui_section "Editar arquivo de configuracao"
  mkdir -p "$(dirname "$AGENTOS_CONFIG_FILE")"
  [ -f "$AGENTOS_CONFIG_FILE" ] || agentos_write_user_config
  ui_info "No Termux, execute:"
  printf "nano \"%s\"\n" "$AGENTOS_CONFIG_FILE"
}

settings_export_report() {
  ui_title
  ui_section "Exportar relatorio"
  agentos_require_storage || return 1
  mkdir -p "$AGENTOS_EXPORTS_DIR"
  local file="$AGENTOS_EXPORTS_DIR/agentos_relatorio_$(date +%Y%m%d_%H%M%S).txt"

  {
    printf "AgentOS Mobile Kit - Relatorio\n"
    printf "Data: %s\n\n" "$(date)"
    printf "Configuracoes\n"
    agentos_public_dirs_report
    printf "Busca padrao: %s\n" "$AGENTOS_DEFAULT_SEARCH_LIMIT"
    printf "Branch: %s\n\n" "$AGENTOS_DEFAULT_BRANCH"
    printf "Git\n"
    git --version 2>/dev/null || true
    git config --global user.name 2>/dev/null || true
    git config --global user.email 2>/dev/null || true
    printf "\nGitHub CLI\n"
    gh --version 2>/dev/null | head -n 1 || true
    gh auth status 2>&1 || true
  } >"$file"

  ui_ok "Relatorio salvo em: $file"
}

menu_settings() {
  while true; do
    ui_title
    ui_header_small "Configuracoes"
    ui_menu_item "1" "Ver configuracoes"
    ui_menu_item "2" "Editar configuracoes"
    ui_menu_item "3" "Criar/ajustar pastas no Download"
    ui_menu_item "4" "Configurar identidade Git"
    ui_menu_item "5" "Mostrar comando para editar config"
    ui_menu_item "6" "Exportar relatorio para Download"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
    1)
      settings_show
      ui_pause
      ;;
    2)
      settings_edit
      ui_pause
      ;;
    3)
      settings_prepare_downloads
      ui_pause
      ;;
    4)
      settings_git_identity
      ui_pause
      ;;
    5)
      settings_open_config_hint
      ui_pause
      ;;
    6)
      settings_export_report
      ui_pause
      ;;
    0) return 0 ;;
    *)
      ui_warn "Opcao invalida."
      sleep 1
      ;;
    esac
  done
}
