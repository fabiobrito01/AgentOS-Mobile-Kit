#!/data/data/com.termux/files/usr/bin/bash

termux_full_update() {
  ui_title
  ui_section "Atualizacao completa"
  ui_info "Isso executa pkg update, pkg upgrade e instala ferramentas essenciais."

  if ! ui_confirm "Continuar"; then
    return 0
  fi

  run_step "Atualizando bibliotecas do Termux" pkg update -y
  run_step "Atualizando pacotes instalados" pkg upgrade -y
  run_step "Instalando ferramentas essenciais" pkg install -y git curl wget gh openssh jq tar zip unzip nano vim tree rsync python nodejs ripgrep fzf htop tmux sqlite less
  agentos_log "Termux atualizado"
}

termux_setup_storage() {
  ui_title
  ui_section "Permissao de armazenamento"
  if cmd_exists termux-setup-storage; then
    termux-setup-storage
    ui_ok "Permissao solicitada. Confirme no Android se aparecer a janela."
    ui_info "Depois rode: agentos config -> Criar/ajustar pastas no Download"
  else
    ui_warn "termux-setup-storage nao encontrado. Execute isso dentro do Termux."
  fi
}

termux_configure_git() {
  ui_title
  ui_section "Configuracao Git"
  local name
  local email

  name="$(ui_prompt_back "Nome para commits")" || return 0
  email="$(ui_prompt_back "Email do GitHub")" || return 0

  git config --global user.name "$name"
  git config --global user.email "$email"
  git config --global init.defaultBranch "$AGENTOS_DEFAULT_BRANCH"
  git config --global pull.rebase false
  git config --global core.editor nano

  ui_ok "Git configurado."
}

menu_termux() {
  while true; do
    ui_title
    ui_header_small "Preparar / atualizar Termux"
    ui_menu_item "1" "Atualizar Termux e instalar ferramentas"
    ui_menu_item "2" "Configurar permissao de armazenamento"
    ui_menu_item "3" "Configurar nome/email do Git"
    ui_menu_item "4" "Login no GitHub CLI"
    ui_menu_item "5" "Ver versoes instaladas"
    ui_menu_item "6" "Abrir central de pacotes"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
    1)
      termux_full_update
      ui_pause
      ;;
    2)
      termux_setup_storage
      ui_pause
      ;;
    3)
      termux_configure_git
      ui_pause
      ;;
    4)
      github_login
      ui_pause
      ;;
    5)
      agentos_doctor
      ui_pause
      ;;
    6) menu_packages ;;
    0) return 0 ;;
    *)
      ui_warn "Opcao invalida."
      sleep 1
      ;;
    esac
  done
}
