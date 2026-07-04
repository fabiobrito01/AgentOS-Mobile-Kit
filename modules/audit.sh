#!/data/data/com.termux/files/usr/bin/bash

audit_owner() {
  local owner
  owner="$(gh api user --jq .login 2>/dev/null || true)"
  [ -z "$owner" ] && owner="$(ui_prompt_back "Usuario GitHub")"
  printf "%s" "$owner"
}

audit_recommendation() {
  local name="$1"
  local lower
  lower="$(printf "%s" "$name" | tr '[:upper:]' '[:lower:]')"

  case "$lower" in
    *agentos*|*ollama*|*open-webui*|*anything-llm*|*litellm*|*qdrant*|*crewai*|*langgraph*|*gpt-researcher*|*khoj*|*superagi*|*agenticseek*|*praisonai*|*agentuniverse*|*ailice*|*memmachine*|*deepanalyze*|*massgen*)
      printf "MANTER|IA, agentes, memoria ou assistente"
      ;;
    *flutter*|*escolar*|*gestao*|*printpapel*|*nomad*|*termux*|*mobile*)
      printf "MANTER|Projeto proprio ou base de trabalho"
      ;;
    *hexstrike*|*dark-moon*|*decepticon*|*hackathon*|*swe-af*)
      printf "REVISAR|Seguranca, laboratorio ou hackathon; revisar imagem publica"
      ;;
    *ultramax*|index|argo|*lua*)
      printf "ARQUIVAR?|Fora do foco atual ou nome pouco claro"
      ;;
    *)
      printf "REVISAR|Sem categoria clara"
      ;;
  esac
}

audit_fetch_repos() {
  ui_title
  ui_section "Buscar repositorios da sua conta"
  agentos_require_storage || return 1

  if ! github_auth_status; then
    ui_warn "Para incluir privados, autentique com GitHub CLI."
    github_login || return 1
  fi

  local owner
  local json="$AGENTOS_AUDIT_DIR/repos.json"
  local tsv="$AGENTOS_AUDIT_DIR/repos.tsv"

  owner="$(audit_owner)"
  [ -z "$owner" ] && return 1

  mkdir -p "$AGENTOS_AUDIT_DIR"
  gh repo list "$owner" --limit 1000 --json name,isPrivate,isFork,isArchived,primaryLanguage,updatedAt,description,url > "$json"

  jq -r '.[] | [.name, (.isPrivate|tostring), (.isFork|tostring), (.isArchived|tostring), (.primaryLanguage.name // "N/A"), .updatedAt, (.description // ""), .url] | @tsv' "$json" > "$tsv"
  ui_ok "Lista salva em: $tsv"
}

audit_classify_repos() {
  ui_title
  ui_section "Classificar repositorios"
  agentos_require_storage || return 1

  local tsv="$AGENTOS_AUDIT_DIR/repos.tsv"
  local out="$AGENTOS_AUDIT_DIR/repos_classificados.tsv"

  if [ ! -s "$tsv" ]; then
    ui_warn "Rode primeiro: Buscar repositorios da sua conta."
    return 1
  fi

  {
    printf "nome\tprivado\tfork\tarquivado\tlinguagem\tatualizado\trecomendacao\tmotivo\turl\n"
    while IFS=$'\t' read -r name priv fork archived lang updated desc url; do
      rec="$(audit_recommendation "$name")"
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$name" "$priv" "$fork" "$archived" "$lang" "$updated" "${rec%|*}" "${rec#*|}" "$url"
    done < "$tsv"
  } > "$out"

  column -t -s $'\t' "$out" 2>/dev/null | head -n 40 || head -n 40 "$out"
  ui_ok "Classificacao salva em: $out"
}

audit_export_report() {
  ui_title
  ui_section "Exportar relatorio"
  agentos_require_storage || return 1

  local classified="$AGENTOS_AUDIT_DIR/repos_classificados.tsv"
  local report="$AGENTOS_AUDIT_DIR/RELATORIO_GITHUB.md"

  if [ ! -s "$classified" ]; then
    audit_classify_repos || return 1
  fi

  {
    printf "# Relatorio GitHub - AgentOS\n\n"
    printf "Gerado em: %s\n\n" "$(date)"
    printf "## Regra de seguranca\n\n"
    printf "Nada foi excluido automaticamente. Candidatos devem ser arquivados ou apagados manualmente depois de revisao.\n\n"
    printf "## Repositorios classificados\n\n"
    printf "| Repo | Privado | Fork | Arquivado | Linguagem | Recomendacao | Motivo |\n"
    printf "|---|---:|---:|---:|---|---|---|\n"
    tail -n +2 "$classified" | while IFS=$'\t' read -r name priv fork archived lang updated rec reason url; do
      printf "| [%s](%s) | %s | %s | %s | %s | %s | %s |\n" "$name" "$url" "$priv" "$fork" "$archived" "$lang" "$rec" "$reason"
    done
  } > "$report"

  ui_ok "Relatorio salvo em: $report"
}

audit_show_candidates() {
  ui_title
  ui_section "Candidatos a revisar"
  local classified="$AGENTOS_AUDIT_DIR/repos_classificados.tsv"
  if [ ! -s "$classified" ]; then
    audit_classify_repos || return 1
  fi
  awk -F '\t' 'NR == 1 { next } $7 != "MANTER" { printf "%s | %s | %s\n", $1, $7, $8 }' "$classified"
}

audit_clone_repo() {
  ui_title
  ui_section "Clonar repositorio da sua conta"
  agentos_require_storage || return 1

  local owner
  local repo
  owner="$(audit_owner)"
  repo="$(ui_prompt_back "Nome do repositorio")" || return 0
  if [ -z "$owner" ] || [ -z "$repo" ]; then
    return 1
  fi

  mkdir -p "$AGENTOS_GITHUB_DIR"
  gh repo clone "$owner/$repo" "$AGENTOS_GITHUB_DIR/$repo"
}

catalog_write_turbo() {
  agentos_require_storage || return 1
  mkdir -p "$(dirname "$AGENTOS_CATALOG_FILE")"
  cat > "$AGENTOS_CATALOG_FILE" <<'EOF'
IA Local	ollama/ollama	Modelos locais e runtime para LLMs
IA Local	open-webui/open-webui	Interface web para modelos locais
IA Local	Mintplex-Labs/anything-llm	Workspace local com RAG e documentos
IA Local	ggerganov/llama.cpp	Inferencia local eficiente em C/C++
Agentes	crewAIInc/crewAI	Framework de agentes colaborativos
Agentes	langchain-ai/langgraph	Orquestracao de agentes e workflows
Agentes	assafelovic/gpt-researcher	Pesquisa automatizada com IA
Agentes	SuperAGI/SuperAGI	Plataforma de agentes
Automacao	n8n-io/n8n	Automacao visual e integrações
Automacao	activepieces/activepieces	Automacao open source
Automacao	FlowiseAI/Flowise	Construtor visual de fluxos LLM
Automacao	langgenius/dify	Apps LLM e workflows
Dados	qdrant/qdrant	Vector database
Dados	chroma-core/chroma	Vector database para IA
Dados	supabase/supabase	Backend open source completo
Mobile	flutter/flutter	SDK Flutter
Mobile	termux/termux-app	App Termux
Mobile	termux/termux-packages	Pacotes Termux
DevOps	docker/compose	Orquestracao Docker Compose
DevOps	gitpod-io/openvscode-server	VS Code no navegador
EOF
  ui_ok "Catalogo salvo em: $AGENTOS_CATALOG_FILE"
}

catalog_show_turbo() {
  ui_title
  ui_section "Catalogo Turbo"
  [ -s "$AGENTOS_CATALOG_FILE" ] || catalog_write_turbo || return 1
  awk -F '\t' '{ printf "%2d  [%s] %s\n    %s\n", NR, $1, $2, $3 }' "$AGENTOS_CATALOG_FILE"
}

catalog_pick_repo() {
  local index="$1"
  awk -F '\t' -v row="$index" 'NR == row { print $2 }' "$AGENTOS_CATALOG_FILE"
}

catalog_clone_pick() {
  catalog_show_turbo
  local index
  local repo
  index="$(ui_prompt_back "Numero para clonar")" || return 0
  repo="$(catalog_pick_repo "$index")"
  [ -z "$repo" ] && ui_error "Opcao invalida." && return 1
  mkdir -p "$AGENTOS_GITHUB_DIR"
  gh repo clone "$repo" "$AGENTOS_GITHUB_DIR/$(basename "$repo")"
}

catalog_fork_pick() {
  catalog_show_turbo
  local index
  local repo
  index="$(ui_prompt_back "Numero para fork no seu GitHub")" || return 0
  repo="$(catalog_pick_repo "$index")"
  [ -z "$repo" ] && ui_error "Opcao invalida." && return 1
  if ! github_auth_status; then
    github_login || return 1
  fi
  ui_warn "Forkar muitos repos pode poluir sua conta. Escolha so os que vai estudar ou usar."
  ui_confirm "Confirmar fork de $repo" || return 0
  gh repo fork "$repo" --clone=false
}

menu_audit() {
  while true; do
    ui_title
    ui_header_small "Auditoria GitHub e Catalogo Turbo"
    ui_menu_item "1" "Buscar todos os meus repositorios"
    ui_menu_item "2" "Classificar repositorios"
    ui_menu_item "3" "Exportar relatorio para Download"
    ui_menu_item "4" "Ver candidatos a revisar/arquivar"
    ui_menu_item "5" "Clonar repositorio da minha conta"
    ui_menu_item "6" "Gerar/atualizar Catalogo Turbo"
    ui_menu_item "7" "Ver Catalogo Turbo"
    ui_menu_item "8" "Clonar repo do Catalogo Turbo"
    ui_menu_item "9" "Forkar repo do Catalogo Turbo"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) audit_fetch_repos; ui_pause ;;
      2) audit_classify_repos; ui_pause ;;
      3) audit_export_report; ui_pause ;;
      4) audit_show_candidates; ui_pause ;;
      5) audit_clone_repo; ui_pause ;;
      6) catalog_write_turbo; ui_pause ;;
      7) catalog_show_turbo; ui_pause ;;
      8) catalog_clone_pick; ui_pause ;;
      9) catalog_fork_pick; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
