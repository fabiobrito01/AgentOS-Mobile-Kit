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
