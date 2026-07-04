#!/data/data/com.termux/files/usr/bin/bash

manager_require_auth() {
  if github_auth_status; then
    return 0
  fi
  ui_warn "GitHub CLI precisa estar autenticado."
  github_login
}

manager_my_repos() {
  ui_title
  ui_section "Meus repositorios"
  manager_require_auth || return 1
  gh repo list --limit 100 --json name,visibility,isPrivate,isArchived,updatedAt,url \
    --jq '.[] | [.name,.visibility,.isArchived,.updatedAt,.url] | @tsv' | column -t -s $'\t'
}

manager_update_local_repos() {
  ui_title
  ui_section "Atualizar repositorios locais"
  agentos_require_storage || return 1
  find "$AGENTOS_PROJECTS_DIR" "$AGENTOS_GITHUB_DIR" -maxdepth 2 -type d -name .git 2>/dev/null | while read -r gitdir; do
    repo_dir="$(dirname "$gitdir")"
    printf "\n==> %s\n" "$repo_dir"
    (cd "$repo_dir" && git pull --ff-only) || true
  done
}

manager_create_repo() {
  ui_title
  ui_section "Criar repositorio"
  manager_require_auth || return 1
  local name
  local visibility
  name="$(ui_prompt_back "Nome do repositorio")" || return 0
  visibility="$(ui_prompt_back "Visibilidade [public/private]")" || return 0
  [ -z "$visibility" ] && visibility="public"
  gh repo create "$name" "--$visibility"
}

manager_archive_repo() {
  ui_title
  ui_section "Arquivar repositorio"
  manager_require_auth || return 1
  local repo
  repo="$(ui_prompt_back "Repositorio completo (usuario/repo)")" || return 0
  ui_warn "Arquivar deixa o repositorio somente leitura."
  ui_confirm "Confirmar arquivamento de $repo" || return 0
  gh api -X PATCH "repos/$repo" -f archived=true
}

manager_delete_repo() {
  ui_title
  ui_section "Excluir repositorio"
  manager_require_auth || return 1
  local repo
  local confirm
  repo="$(ui_prompt_back "Repositorio completo (usuario/repo)")" || return 0
  ui_error "Exclusao e destrutiva. Prefira arquivar."
  confirm="$(ui_prompt_back "Digite EXCLUIR para continuar")" || return 0
  [ "$confirm" = "EXCLUIR" ] || { ui_warn "Cancelado."; return 0; }
  gh repo delete "$repo"
}

menu_manager() {
  while true; do
    ui_title
    ui_header_small "GitHub Manager"
    ui_menu_item "1" "Meus repositorios"
    ui_menu_item "2" "Atualizar repositorios locais"
    ui_menu_item "3" "Criar repositorio"
    ui_menu_item "4" "Arquivar"
    ui_menu_item "5" "Excluir"
    ui_menu_item "6" "Catalogo Turbo"
    ui_menu_item "7" "Exportar relatorio"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) manager_my_repos; ui_pause ;;
      2) manager_update_local_repos; ui_pause ;;
      3) manager_create_repo; ui_pause ;;
      4) manager_archive_repo; ui_pause ;;
      5) manager_delete_repo; ui_pause ;;
      6) menu_audit ;;
      7) audit_export_report; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
