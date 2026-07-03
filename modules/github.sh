#!/data/data/com.termux/files/usr/bin/bash

menu_github() {
  while true; do
    ui_title
    ui_header_small "GitHub Explorer"
    ui_menu_item "1" "Pesquisar repositorios"
    ui_menu_item "2" "Ver ultima busca"
    ui_menu_item "3" "Clonar resultado para o celular"
    ui_menu_item "4" "Forkar resultado para meu GitHub e clonar"
    ui_menu_item "5" "Autenticar / verificar GitHub CLI"
    ui_menu_item "6" "Mostrar URL de um resultado"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1)
        local query
        local limit
        query="$(ui_prompt "Pesquisar por area, tecnologia ou ideia")"
        limit="$(ui_prompt "Quantidade de resultados [$AGENTOS_DEFAULT_SEARCH_LIMIT]")"
        github_search_repositories "$query" "${limit:-$AGENTOS_DEFAULT_SEARCH_LIMIT}"
        ui_pause
        ;;
      2)
        ui_title
        github_print_last_results
        ui_pause
        ;;
      3)
        local index
        index="$(ui_prompt "Numero do resultado para clonar")"
        github_clone_result "$index"
        ui_pause
        ;;
      4)
        local index
        index="$(ui_prompt "Numero do resultado para fork+clone")"
        github_fork_result "$index"
        ui_pause
        ;;
      5)
        if github_auth_status; then
          gh auth status
        else
          github_login
        fi
        ui_pause
        ;;
      6)
        local index
        index="$(ui_prompt "Numero do resultado")"
        github_open_result_url "$index"
        ui_pause
        ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
