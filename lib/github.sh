#!/data/data/com.termux/files/usr/bin/bash

github_require_tools() {
  local missing=0
  for bin in git curl jq; do
    if ! cmd_exists "$bin"; then
      ui_error "Dependencia ausente: $bin"
      missing=1
    fi
  done
  return "$missing"
}

github_auth_status() {
  if ! cmd_exists gh; then
    ui_warn "GitHub CLI nao instalado."
    return 1
  fi

  gh auth status >/dev/null 2>&1
}

github_login() {
  if ! cmd_exists gh; then
    ui_error "Instale o GitHub CLI com: pkg install gh"
    return 1
  fi

  gh auth login
  gh auth status
}

github_encode_query() {
  jq -rn --arg q "$1" '$q|@uri'
}

github_search_repositories() {
  local query="$1"
  local limit="$2"
  local encoded
  local json="$AGENTOS_DATA_DIR/github_last_search.json"
  local tsv="$AGENTOS_DATA_DIR/github_last_search.tsv"

  github_require_tools || return 1
  mkdir -p "$AGENTOS_DATA_DIR"

  encoded="$(github_encode_query "$query")"
  limit="${limit:-$AGENTOS_DEFAULT_SEARCH_LIMIT}"

  ui_info "Consultando GitHub..."

  if github_auth_status; then
    gh api "search/repositories?q=$encoded&sort=stars&order=desc&per_page=$limit" > "$json"
  else
    curl -fsSL \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/search/repositories?q=$encoded&sort=stars&order=desc&per_page=$limit" \
      > "$json"
  fi

  jq -r '.items[] | [.full_name, (.description // ""), (.language // "N/A"), (.stargazers_count|tostring), .clone_url, .html_url] | @tsv' "$json" > "$tsv"
  agentos_require_storage >/dev/null 2>&1 && printf "%s\t%s\t%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$query" "$limit" >> "$AGENTOS_HISTORY_FILE"
  github_print_last_results
}

github_print_last_results() {
  local tsv="$AGENTOS_DATA_DIR/github_last_search.tsv"
  local n=1

  if [ ! -s "$tsv" ]; then
    ui_warn "Nenhuma busca salva ainda."
    return 1
  fi

  ui_section "Ultimos resultados"
  while IFS=$'\t' read -r full desc lang stars clone html; do
    printf "%b%2d%b  %s\n" "$C_GREEN" "$n" "$C_RESET" "$full"
    printf "     Linguagem: %s | Stars: %s\n" "$lang" "$stars"
    printf "     %s\n" "${desc:-Sem descricao}"
    printf "     %s\n\n" "$html"
    n=$((n + 1))
  done < "$tsv"
}

github_pick_result_field() {
  local index="$1"
  local field="$2"
  local tsv="$AGENTOS_DATA_DIR/github_last_search.tsv"
  awk -F '\t' -v row="$index" -v col="$field" 'NR == row { print $col }' "$tsv"
}

github_clone_result() {
  local index="$1"
  local clone_url
  local name
  agentos_require_storage || return 1

  clone_url="$(github_pick_result_field "$index" 5)"

  if [ -z "$clone_url" ]; then
    ui_error "Resultado invalido."
    return 1
  fi

  mkdir -p "$AGENTOS_GITHUB_DIR"
  name="$(basename "$clone_url" .git)"

  if [ -d "$AGENTOS_GITHUB_DIR/$name" ]; then
    ui_warn "A pasta ja existe: $AGENTOS_GITHUB_DIR/$name"
    return 1
  fi

  git clone "$clone_url" "$AGENTOS_GITHUB_DIR/$name"
}

github_clone_result_projects() {
  local index="$1"
  local clone_url
  local name
  agentos_require_storage || return 1

  clone_url="$(github_pick_result_field "$index" 5)"

  if [ -z "$clone_url" ]; then
    ui_error "Resultado invalido."
    return 1
  fi

  mkdir -p "$AGENTOS_PROJECTS_DIR"
  name="$(basename "$clone_url" .git)"

  if [ -d "$AGENTOS_PROJECTS_DIR/$name" ]; then
    ui_warn "A pasta ja existe: $AGENTOS_PROJECTS_DIR/$name"
    return 1
  fi

  git clone "$clone_url" "$AGENTOS_PROJECTS_DIR/$name"
}

github_fork_result() {
  local index="$1"
  local full_name
  agentos_require_storage || return 1

  full_name="$(github_pick_result_field "$index" 1)"

  if [ -z "$full_name" ]; then
    ui_error "Resultado invalido."
    return 1
  fi

  if ! github_auth_status; then
    ui_warn "Voce precisa autenticar o GitHub CLI antes de fazer fork."
    github_login || return 1
  fi

  mkdir -p "$AGENTOS_GITHUB_DIR"
  safe_cd "$AGENTOS_GITHUB_DIR" || return 1
  gh repo fork "$full_name" --clone=true --remote=true
}

github_open_result_url() {
  local index="$1"
  github_pick_result_field "$index" 6
}

github_download_zip_result() {
  local index="$1"
  local full
  local name
  local out
  agentos_require_storage || return 1

  full="$(github_pick_result_field "$index" 1)"
  if [ -z "$full" ]; then
    ui_error "Resultado invalido."
    return 1
  fi

  mkdir -p "$AGENTOS_EXPORTS_DIR/repositorios_zip"
  name="$(basename "$full")"
  out="$AGENTOS_EXPORTS_DIR/repositorios_zip/${name}_$(date +%Y%m%d_%H%M%S).zip"

  if cmd_exists gh && github_auth_status; then
    gh api "repos/$full/zipball" > "$out"
  else
    curl -LfsS "https://github.com/$full/archive/refs/heads/main.zip" -o "$out" || \
    curl -LfsS "https://github.com/$full/archive/refs/heads/master.zip" -o "$out"
  fi

  ui_ok "ZIP salvo em: $out"
}

github_show_result_details() {
  local index="$1"
  local full
  local desc
  local lang
  local stars
  local clone
  local html

  full="$(github_pick_result_field "$index" 1)"
  desc="$(github_pick_result_field "$index" 2)"
  lang="$(github_pick_result_field "$index" 3)"
  stars="$(github_pick_result_field "$index" 4)"
  clone="$(github_pick_result_field "$index" 5)"
  html="$(github_pick_result_field "$index" 6)"

  if [ -z "$full" ]; then
    ui_error "Resultado invalido."
    return 1
  fi

  ui_section "Detalhes do repositorio"
  printf "Repositorio....: %s\n" "$full"
  printf "Descricao......: %s\n" "${desc:-Sem descricao}"
  printf "Linguagem......: %s\n" "$lang"
  printf "Stars..........: %s\n" "$stars"
  printf "Clone..........: %s\n" "$clone"
  printf "URL............: %s\n" "$html"
}

github_add_favorite() {
  local index="$1"
  local full
  local lang
  local stars
  local html

  agentos_require_storage || return 1
  full="$(github_pick_result_field "$index" 1)"
  lang="$(github_pick_result_field "$index" 3)"
  stars="$(github_pick_result_field "$index" 4)"
  html="$(github_pick_result_field "$index" 6)"

  if [ -z "$full" ]; then
    ui_error "Resultado invalido."
    return 1
  fi

  mkdir -p "$(dirname "$AGENTOS_FAVORITES_FILE")"
  if grep -Fq "$full"$'\t' "$AGENTOS_FAVORITES_FILE" 2>/dev/null; then
    ui_warn "Este repositorio ja esta nos favoritos."
    return 0
  fi

  printf "%s\t%s\t%s\t%s\t%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$full" "$lang" "$stars" "$html" >> "$AGENTOS_FAVORITES_FILE"
  ui_ok "Favorito salvo: $full"
}

github_list_favorites() {
  agentos_require_storage || return 1
  ui_section "Favoritos GitHub"

  if [ ! -s "$AGENTOS_FAVORITES_FILE" ]; then
    ui_warn "Nenhum favorito salvo ainda."
    return 0
  fi

  awk -F '\t' '{ printf "%2d  %s | %s | stars: %s\n    %s\n", NR, $2, $3, $4, $5 }' "$AGENTOS_FAVORITES_FILE"
}

github_list_history() {
  agentos_require_storage || return 1
  ui_section "Historico de buscas"

  if [ ! -s "$AGENTOS_HISTORY_FILE" ]; then
    ui_warn "Nenhuma busca registrada ainda."
    return 0
  fi

  tail -n 20 "$AGENTOS_HISTORY_FILE" | awk -F '\t' '{ printf "%s | %s | limite %s\n", $1, $2, $3 }'
}

github_export_last_search() {
  local tsv="$AGENTOS_DATA_DIR/github_last_search.tsv"
  local out

  agentos_require_storage || return 1
  if [ ! -s "$tsv" ]; then
    ui_warn "Nenhuma busca salva para exportar."
    return 1
  fi

  mkdir -p "$AGENTOS_EXPORTS_DIR"
  out="$AGENTOS_EXPORTS_DIR/github_busca_$(date +%Y%m%d_%H%M%S).txt"
  {
    printf "AgentOS Mobile Kit - Resultado GitHub\n"
    printf "Data: %s\n\n" "$(date)"
    awk -F '\t' '{ printf "%2d. %s\n    Linguagem: %s | Stars: %s\n    %s\n    %s\n\n", NR, $1, $3, $4, $2, $6 }' "$tsv"
  } > "$out"
  ui_ok "Busca exportada para: $out"
}

github_result_actions() {
  local index="$1"

  while true; do
    ui_title
    github_show_result_details "$index" || return 1
    printf "\n"
    ui_menu_item "1" "Ver detalhes"
    ui_menu_item "2" "Clonar para Download/Projetos"
    ui_menu_item "3" "Fazer fork para meu GitHub"
    ui_menu_item "4" "Baixar ZIP"
    ui_menu_item "5" "Abrir/mostrar pagina do GitHub"
    ui_menu_item "6" "Salvar nos favoritos"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) github_show_result_details "$index"; ui_pause ;;
      2) github_clone_result_projects "$index"; ui_pause ;;
      3) github_fork_result "$index"; ui_pause ;;
      4) github_download_zip_result "$index"; ui_pause ;;
      5) github_open_result_url "$index"; ui_pause ;;
      6) github_add_favorite "$index"; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}

github_pick_result_actions() {
  local index
  index="$(ui_prompt_back "Numero do resultado")" || return 0
  github_result_actions "$index"
}
