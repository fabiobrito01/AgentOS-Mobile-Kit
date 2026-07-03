#!/data/data/com.termux/files/usr/bin/bash

agentos_doctor() {
  ui_title
  ui_section "Diagnostico"

  local errors=0

  printf "Home AgentOS....: %s\n" "$AGENTOS_HOME"
  printf "Download Android: %s\n" "$AGENTOS_TERMUX_DOWNLOADS"
  printf "Usuario.........: %s\n" "$(whoami 2>/dev/null || printf desconhecido)"
  printf "Sistema.........: %s\n" "$(uname -a 2>/dev/null || printf desconhecido)"
  printf "Data............: %s\n" "$(date)"
  printf "\n"

  ui_section "Ferramentas"
  for item in "git:Git" "curl:Curl" "wget:Wget" "gh:GitHub CLI" "ssh:OpenSSH" "jq:JQ" "tar:Tar" "zip:Zip" "python:Python" "node:Node.js"; do
    bin="${item%%:*}"
    label="${item#*:}"
    if ! show_command_version "$bin" "$label"; then
      errors=$((errors + 1))
    fi
  done

  ui_section "Pastas"
  for dir in "$AGENTOS_HOME" "$AGENTOS_DATA_DIR" "$AGENTOS_LOG_DIR"; do
    if [ -d "$dir" ]; then
      ui_ok "$dir"
    else
      ui_error "$dir"
      errors=$((errors + 1))
    fi
  done

  if agentos_storage_ready; then
    ui_ok "$AGENTOS_TERMUX_DOWNLOADS"
    for dir in "$AGENTOS_PUBLIC_ROOT" "$AGENTOS_PROJECTS_DIR" "$AGENTOS_GITHUB_DIR" "$AGENTOS_BACKUP_DIR" "$AGENTOS_EXPORTS_DIR"; do
      if [ -d "$dir" ]; then
        ui_ok "$dir"
      else
        ui_error "$dir"
        errors=$((errors + 1))
      fi
    done
  else
    ui_error "$AGENTOS_TERMUX_DOWNLOADS nao acessivel"
    errors=$((errors + 1))
  fi

  ui_section "GitHub"
  if github_auth_status; then
    ui_ok "GitHub CLI autenticado"
  else
    ui_warn "GitHub CLI nao autenticado ou ausente"
  fi

  ui_section "Rede"
  if cmd_exists curl && curl -Is https://github.com >/dev/null 2>&1; then
    ui_ok "Acesso ao GitHub"
  else
    ui_warn "Nao foi possivel confirmar acesso ao GitHub"
  fi

  ui_section "Status final"
  if [ "$errors" -eq 0 ]; then
    ui_ok "Ambiente pronto para uso."
    return 0
  fi

  ui_error "Foram encontrados $errors problema(s). Rode: agentos atualizar"
  return 1
}
