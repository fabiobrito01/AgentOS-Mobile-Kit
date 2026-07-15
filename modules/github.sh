#!/data/data/com.termux/files/usr/bin/bash

menu_github() {
  while true; do
    ui_title
    ui_header_small "GitHub Explorer"
    ui_menu_item "1" "Pesquisar repositorios"
    ui_menu_item "2" "Ver detalhes / acoes de um resultado"
    ui_menu_item "3" "Clonar para Projetos"
    ui_menu_item "4" "Forkar para meu GitHub"
    ui_menu_item "5" "Salvar ZIP no Download"
    ui_menu_item "6" "Favoritos"
    ui_menu_item "7" "Historico"
    ui_menu_item "8" "Ultima pesquisa"
    ui_menu_item "9" "Autenticar / verificar GitHub CLI"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
    1)
      local query
      local limit
      query="$(ui_prompt_back "Pesquisar por area, tecnologia ou ideia")" || continue
      limit="$(ui_prompt_back "Quantidade de resultados [$AGENTOS_DEFAULT_SEARCH_LIMIT]")" || continue
      github_search_repositories "$query" "${limit:-$AGENTOS_DEFAULT_SEARCH_LIMIT}" && github_pick_result_actions
      ui_pause
      ;;
    2)
      github_pick_result_actions
      ui_pause
      ;;
    3)
      local index
      index="$(ui_prompt_back "Numero do resultado para clonar")" || continue
      github_clone_result_projects "$index"
      ui_pause
      ;;
    4)
      local index
      index="$(ui_prompt_back "Numero do resultado para fork")" || continue
      github_fork_result "$index"
      ui_pause
      ;;
    5)
      local index
      index="$(ui_prompt_back "Numero do resultado para baixar ZIP")" || continue
      github_download_zip_result "$index"
      ui_pause
      ;;
    6)
      ui_title
      github_list_favorites
      ui_pause
      ;;
    7)
      ui_title
      github_list_history
      ui_pause
      ;;
    8)
      ui_title
      github_print_last_results
      ui_pause
      ;;
    9)
      if github_auth_status; then
        gh auth status
      else
        github_login
      fi
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
