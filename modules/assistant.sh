#!/data/data/com.termux/files/usr/bin/bash

assistant_show_command() {
  local title="$1"
  local cmd="$2"
  ui_title
  ui_section "$title"
  command_preview "$cmd"
}

menu_assistant() {
  while true; do
    ui_title
    ui_header_small "Assistente de comandos"
    ui_info "Escolha o que voce quer fazer. O AgentOS mostra o comando antes."
    printf "\n"
    ui_menu_item "1" "Instalar ferramentas essenciais"
    ui_menu_item "2" "Autenticar GitHub"
    ui_menu_item "3" "Clonar repositorio por URL"
    ui_menu_item "4" "Criar projeto e abrir pasta"
    ui_menu_item "5" "Atualizar projeto atual"
    ui_menu_item "6" "Enviar projeto atual para GitHub"
    ui_menu_item "7" "Criar chave SSH"
    ui_menu_item "8" "Iniciar sessao tmux"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) assistant_show_command "Ferramentas essenciais" "pkg update -y && pkg upgrade -y && pkg install -y git curl wget gh openssh jq tar zip unzip nano vim tree rsync python nodejs" ;;
      2) assistant_show_command "Login GitHub" "gh auth login && gh auth status" ;;
      3)
        local url
        agentos_require_storage || { ui_pause; continue; }
        url="$(ui_prompt_back "URL do repositorio")" || continue
        assistant_show_command "Clonar repositorio" "git clone \"$url\" \"$AGENTOS_GITHUB_DIR/$(basename "$url" .git)\""
        ;;
      4)
        ui_info "Use a tela Projetos e trabalho -> Criar projeto do zero."
        ui_pause
        ;;
      5) assistant_show_command "Atualizar projeto atual" "git pull --ff-only" ;;
      6) assistant_show_command "Enviar alteracoes" "git status && git add . && git commit -m \"Atualizacao\" && git push" ;;
      7)
        local email
        email="$(ui_prompt_back "Email do GitHub")" || continue
        assistant_show_command "Criar chave SSH" "ssh-keygen -t ed25519 -C \"$email\""
        ;;
      8) assistant_show_command "Sessao tmux" "tmux new -s agentos" ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
