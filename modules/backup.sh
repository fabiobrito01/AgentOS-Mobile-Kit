#!/data/data/com.termux/files/usr/bin/bash

backup_create() {
  ui_title
  ui_section "Backup"
  agentos_require_storage || return 1
  mkdir -p "$AGENTOS_BACKUP_DIR"

  local file="$AGENTOS_BACKUP_DIR/agentos_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

  tar -czf "$file" -C "$AGENTOS_HOME" configs data logs 2>/dev/null

  ui_ok "Backup criado: $file"
}

backup_restore_latest() {
  ui_title
  ui_section "Restauracao"

  local file
  agentos_require_storage || return 1
  file="$(ls -t "$AGENTOS_BACKUP_DIR"/agentos_backup_*.tar.gz 2>/dev/null | head -n 1)"

  if [ -z "$file" ]; then
    ui_warn "Nenhum backup encontrado em $AGENTOS_BACKUP_DIR"
    return 1
  fi

  printf "Backup encontrado:\n%s\n\n" "$file"
  if ! ui_confirm "Restaurar este backup"; then
    return 0
  fi

  tar -xzf "$file" -C "$AGENTOS_HOME"
  ui_ok "Backup restaurado."
}

backup_list() {
  ui_title
  ui_section "Backups disponiveis"
  agentos_require_storage || return 1
  ls -lh "$AGENTOS_BACKUP_DIR"/agentos_backup_*.tar.gz 2>/dev/null || ui_warn "Nenhum backup encontrado."
}

menu_backup() {
  while true; do
    ui_title
    ui_header_small "Backup e restauracao"
    ui_menu_item "1" "Criar backup do AgentOS"
    ui_menu_item "2" "Listar backups"
    ui_menu_item "3" "Restaurar backup mais recente"
    ui_menu_item "0" "Voltar"
    printf "\n"
    read -r -p "Escolha: " op

    case "$op" in
      1) backup_create; ui_pause ;;
      2) backup_list; ui_pause ;;
      3) backup_restore_latest; ui_pause ;;
      0) return 0 ;;
      *) ui_warn "Opcao invalida."; sleep 1 ;;
    esac
  done
}
