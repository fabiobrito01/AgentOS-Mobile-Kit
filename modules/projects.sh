#!/data/data/com.termux/files/usr/bin/bash

projects_list() {
  ui_title
  ui_section "Pastas de projetos"
  printf "Projetos: %s\n" "$AGENTOS_PROJECTS_DIR"
  find "$AGENTOS_PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort || true
  printf "\nGitHub: %s\n" "$AGENTOS_GITHUB_DIR"
  find "$AGENTOS_GITHUB_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort || true
}

projects_pick_dir() {
  local dir
  dir="$(ui_prompt "Caminho da pasta do projeto")"
  if [ ! -d "$dir" ]; then
    ui_error "Pasta nao encontrada."
    return 1
  fi
  printf "%s" "$dir"
}

projects_git_status() {
  local dir
  dir="$(projects_pick_dir)" || return 1
  safe_cd "$dir" || return 1
  git status
}

projects_pull() {
  local dir
  dir="$(projects_pick_dir)" || return 1
  safe_cd "$dir" || return 1
  git pull --ff-only
}

projects_push_changes() {
  local dir
  local msg
  dir="$(projects_pick_dir)" || return 1
  msg="$(ui_prompt "Mensagem do commit")"
  [ -z "$msg" ] && msg="Atualizacao pelo AgentOS"

  safe_cd "$dir" || return 1
  git status --short

  if ! ui_confirm "Adicionar tudo, commitar e enviar"; then
    return 0
  fi

  git add .
  git commit -m "$msg" || ui_warn "Nada para commitar ou commit falhou."
  git push
}

projects_create_repo_from_dir() {
  local dir
  local repo
  local visibility

  if ! github_auth_status; then
    ui_warn "Voce precisa autenticar o GitHub CLI."
    github_login || return 1
  fi

  dir="$(projects_pick_dir)" || return 1
  repo="$(ui_prompt "Nome do repositorio no GitHub")"
  visibility="$(ui_prompt "Visibilidade [private/public]")"
  [ -z "$visibility" ] && visibility="private"

  safe_cd "$dir" || return 1

  if [ ! -d .git ]; then
    git init
    git branch -M "$AGENTOS_DEFAULT_BRANCH"
  fi

  git add .
  git commit -m "Primeira versao pelo AgentOS" || true
  gh repo create "$repo" "--$visibility" --source=. --remote=origin --push
}

menu_projects() {
  while true; do
    ui_title
    ui_header_small "Projetos locais"
    ui_menu_item "1" "Listar pastas de projetos"
    ui_menu_item "2" "Ver status Git de uma pasta"
    ui_menu_item "3" "Atualizar projeto existente (git pull)"
    ui_menu_item "4" "Enviar alteracoes para GitHub"
    ui_menu_item "5" "Criar repositorio GitHub a partir de uma pasta"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) projects_list; ui_pause ;;
      2) projects_git_status; ui_pause ;;
      3) projects_pull; ui_pause ;;
      4) projects_push_changes; ui_pause ;;
      5) projects_create_repo_from_dir; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
