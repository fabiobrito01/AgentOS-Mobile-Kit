#!/data/data/com.termux/files/usr/bin/bash

projects_list() {
  ui_title
  ui_section "Pastas de projetos"
  agentos_require_storage || return 1
  printf "Projetos: %s\n" "$AGENTOS_PROJECTS_DIR"
  find "$AGENTOS_PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort || true
  printf "\nGitHub: %s\n" "$AGENTOS_GITHUB_DIR"
  find "$AGENTOS_GITHUB_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort || true
}

projects_pick_dir() {
  local dir
  dir="$(ui_prompt_back "Caminho da pasta do projeto")" || return 1
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
  msg="$(ui_prompt_back "Mensagem do commit")" || return 1
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
  repo="$(ui_prompt_back "Nome do repositorio no GitHub")" || return 1
  visibility="$(ui_prompt_back "Visibilidade [private/public]")" || return 1
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

projects_slug() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9._-'
}

projects_create_new() {
  ui_title
  ui_section "Criar projeto do zero"
  agentos_require_storage || return 1

  local raw_name
  local name
  local template
  local dir

  raw_name="$(ui_prompt_back "Nome do projeto")" || return 1
  name="$(projects_slug "$raw_name")"
  if [ -z "$name" ]; then
    ui_error "Nome invalido."
    return 1
  fi

  ui_section "Modelos"
  ui_menu_item "1" "Bash/Termux"
  ui_menu_item "2" "Python simples"
  ui_menu_item "3" "Node.js simples"
  ui_menu_item "4" "Web HTML/CSS/JS"
  ui_menu_item "5" "Documentacao / ideias"
  ui_menu_item "0" "Voltar"
  printf "\n"
  template="$(ui_choose "Escolha o modelo")" || return 1

  dir="$AGENTOS_PROJECTS_DIR/$name"
  if [ -e "$dir" ]; then
    ui_error "Ja existe: $dir"
    return 1
  fi

  mkdir -p "$dir"
  cat > "$dir/README.md" <<EOF
# $raw_name

Projeto criado pelo AgentOS Mobile Kit.

## Como usar

Descreva aqui o objetivo, comandos e proximos passos.
EOF
  cat > "$dir/.gitignore" <<'EOF'
.env
node_modules/
__pycache__/
*.log
*.tmp
dist/
build/
EOF

  case "$template" in
    1)
      cat > "$dir/main.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "Projeto Bash/Termux iniciado."
EOF
      chmod +x "$dir/main.sh"
      ;;
    2)
      cat > "$dir/main.py" <<'EOF'
def main():
    print("Projeto Python iniciado.")


if __name__ == "__main__":
    main()
EOF
      ;;
    3)
      cat > "$dir/package.json" <<EOF
{"name":"$name","version":"0.1.0","private":true,"scripts":{"start":"node index.js"}}
EOF
      cat > "$dir/index.js" <<'EOF'
console.log("Projeto Node.js iniciado.");
EOF
      ;;
    4)
      cat > "$dir/index.html" <<'EOF'
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Projeto Web</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <main>
    <h1>Projeto Web iniciado</h1>
    <button id="acao">Testar</button>
  </main>
  <script src="app.js"></script>
</body>
</html>
EOF
      cat > "$dir/style.css" <<'EOF'
body { font-family: system-ui, sans-serif; margin: 32px; background: #101820; color: #f4f7fb; }
button { padding: 10px 14px; border: 0; border-radius: 6px; background: #18a058; color: white; }
EOF
      cat > "$dir/app.js" <<'EOF'
document.getElementById("acao").addEventListener("click", () => alert("Funcionando."));
EOF
      ;;
    5)
      mkdir -p "$dir/docs"
      cat > "$dir/docs/PLANO.md" <<'EOF'
# Plano

## Objetivo

## Funcionalidades

## Tarefas

## Observacoes
EOF
      ;;
    *)
      ui_warn "Modelo nao reconhecido. Criado projeto basico."
      ;;
  esac

  safe_cd "$dir" || return 1
  git init
  git branch -M "$AGENTOS_DEFAULT_BRANCH"
  git add .
  git commit -m "Projeto inicial pelo AgentOS" >/dev/null 2>&1 || true

  ui_ok "Projeto criado em: $dir"
  ui_info "Para entrar nele no Termux:"
  printf "cd \"%s\"\n" "$dir"

  if ui_confirm "Criar repositorio no GitHub agora"; then
    local repo
    local visibility
    repo="$(ui_prompt_back "Nome do repositorio [$name]")" || return 0
    [ -z "$repo" ] && repo="$name"
    visibility="$(ui_prompt_back "Visibilidade [public/private]")" || return 0
    [ -z "$visibility" ] && visibility="public"

    if ! github_auth_status; then
      github_login || return 1
    fi
    gh repo create "$repo" "--$visibility" --source=. --remote=origin --push
  fi
}

projects_export_zip() {
  local dir
  local base
  local out
  agentos_require_storage || return 1
  dir="$(projects_pick_dir)" || return 1
  base="$(basename "$dir")"
  mkdir -p "$AGENTOS_EXPORTS_DIR"
  out="$AGENTOS_EXPORTS_DIR/${base}_$(date +%Y%m%d_%H%M%S).zip"
  (cd "$(dirname "$dir")" && zip -r "$out" "$base" >/dev/null)
  ui_ok "Exportado para: $out"
}

projects_show_cd() {
  local dir
  dir="$(projects_pick_dir)" || return 1
  ui_info "Copie e cole para entrar na pasta:"
  printf "cd \"%s\"\n" "$dir"
}

menu_projects() {
  while true; do
    ui_title
    ui_header_small "Projetos e trabalho no Termux"
    ui_menu_item "1" "Criar projeto do zero"
    ui_menu_item "2" "Listar pastas de trabalho"
    ui_menu_item "3" "Mostrar comando cd de uma pasta"
    ui_menu_item "4" "Ver status Git de uma pasta"
    ui_menu_item "5" "Atualizar projeto existente (git pull)"
    ui_menu_item "6" "Enviar alteracoes para GitHub"
    ui_menu_item "7" "Criar repositorio GitHub a partir de uma pasta"
    ui_menu_item "8" "Exportar projeto em ZIP para Download"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) projects_create_new; ui_pause ;;
      2) projects_list; ui_pause ;;
      3) projects_show_cd; ui_pause ;;
      4) projects_git_status; ui_pause ;;
      5) projects_pull; ui_pause ;;
      6) projects_push_changes; ui_pause ;;
      7) projects_create_repo_from_dir; ui_pause ;;
      8) projects_export_zip; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
