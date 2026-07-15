#!/data/data/com.termux/files/usr/bin/bash

agentos_update_check() {
  ui_title
  ui_section "Atualizar AgentOS"
  safe_cd "$AGENTOS_HOME" || return 1

  if [ ! -d .git ]; then
    ui_error "Instalacao atual nao parece ser um clone Git."
    return 1
  fi

  git fetch origin main --tags
  local installed
  local remote_version
  local local_rev
  local remote_rev
  installed="$(cat "$AGENTOS_HOME/VERSION" 2>/dev/null || printf desconhecida)"
  local_rev="$(git rev-parse HEAD)"
  remote_rev="$(git rev-parse origin/main)"
  remote_version="$(git show origin/main:VERSION 2>/dev/null || printf desconhecida)"

  printf "Versao instalada: %s\n" "$installed"
  printf "Nova versao.....: %s\n" "$remote_version"
  printf "Commit local....: %s\n" "${local_rev:0:8}"
  printf "Commit remoto...: %s\n" "${remote_rev:0:8}"

  if [ "$local_rev" = "$remote_rev" ]; then
    ui_ok "AgentOS ja esta atualizado."
    return 0
  fi

  ui_warn "Atualizacao disponivel."
  ui_confirm "Deseja atualizar agora" || return 0
  git pull --ff-only
  chmod +x "$AGENTOS_HOME/agentos" "$AGENTOS_HOME/instalar.sh"
  find "$AGENTOS_HOME/modules" "$AGENTOS_HOME/lib" -type f -name "*.sh" -exec chmod +x {} \;
  ui_ok "AgentOS atualizado."
}

menu_system() {
  while true; do
    ui_title
    ui_header_small "Sistema"
    ui_menu_item "1" "Atualizar Termux"
    ui_menu_item "2" "Instalar ferramentas"
    ui_menu_item "3" "Permissoes"
    ui_menu_item "4" "Git"
    ui_menu_item "5" "GitHub CLI"
    ui_menu_item "6" "Pacotes"
    ui_menu_item "7" "Atualizar AgentOS"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
    1)
      termux_full_update
      ui_pause
      ;;
    2) menu_packages ;;
    3)
      termux_setup_storage
      ui_pause
      ;;
    4)
      termux_configure_git
      ui_pause
      ;;
    5)
      github_login
      ui_pause
      ;;
    6) menu_packages ;;
    7)
      agentos_update_check
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
