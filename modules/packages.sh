#!/data/data/com.termux/files/usr/bin/bash

packages_update_all() {
  ui_title
  ui_section "Atualizar Termux"
  command_preview "pkg update -y && pkg upgrade -y"
}

packages_search() {
  ui_title
  ui_section "Pesquisar pacote"
  local query
  query="$(ui_prompt_back "Nome ou palavra-chave")" || return 0
  pkg search "$query"
}

packages_install_custom() {
  ui_title
  ui_section "Instalar pacote"
  local names
  names="$(ui_prompt_back "Pacote(s), separados por espaco")" || return 0
  [ -z "$names" ] && return 0
  command_preview "pkg install -y $names"
}

packages_list_installed() {
  ui_title
  ui_section "Pacotes instalados"
  pkg list-installed | less
}

packages_presets() {
  while true; do
    ui_title
    ui_header_small "Central de pacotes por categoria"
    ui_menu_item "1" "Essencial do AgentOS"
    ui_menu_item "2" "Desenvolvimento"
    ui_menu_item "3" "Web e APIs"
    ui_menu_item "4" "Arquivos e produtividade"
    ui_menu_item "5" "Rede e diagnostico"
    ui_menu_item "6" "Banco de dados"
    ui_menu_item "7" "Interface de terminal"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
    1) pkg_install_group "Essencial do AgentOS" git curl wget gh openssh jq tar zip unzip nano vim tree rsync ;;
    2) pkg_install_group "Desenvolvimento" python nodejs clang make cmake pkg-config git ripgrep ;;
    3) pkg_install_group "Web e APIs" nodejs python curl jq openssl ;;
    4) pkg_install_group "Arquivos e produtividade" zip unzip tar tree rsync nano vim less fzf ;;
    5) pkg_install_group "Rede e diagnostico" curl wget openssh dnsutils net-tools nmap ;;
    6) pkg_install_group "Banco de dados" sqlite postgresql ;;
    7) pkg_install_group "Interface de terminal" tmux htop fzf ripgrep bat ;;
    0) return 0 ;;
    *)
      ui_warn "Opcao invalida."
      sleep 1
      ;;
    esac
    ui_pause
  done
}

menu_packages() {
  while true; do
    ui_title
    ui_header_small "Central de pacotes"
    ui_menu_item "1" "Atualizar tudo"
    ui_menu_item "2" "Instalar por categoria"
    ui_menu_item "3" "Pesquisar pacote"
    ui_menu_item "4" "Instalar pacote manualmente"
    ui_menu_item "5" "Listar pacotes instalados"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
    1)
      packages_update_all
      ui_pause
      ;;
    2) packages_presets ;;
    3)
      packages_search
      ui_pause
      ;;
    4)
      packages_install_custom
      ui_pause
      ;;
    5) packages_list_installed ;;
    0) return 0 ;;
    *)
      ui_warn "Opcao invalida."
      sleep 1
      ;;
    esac
  done
}
