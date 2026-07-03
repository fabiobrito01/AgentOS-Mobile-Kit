#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"
DB="$BASE/database/agentos.db"

db_log() {
  TIPO="$1"
  MSG="$2"
  DATA="$(date '+%Y-%m-%d %H:%M:%S')"

  sqlite3 "$DB" "INSERT INTO logs (tipo, mensagem, data) VALUES ('$TIPO', '$MSG', '$DATA');"
}

db_add_history() {
  PESQUISA="$1"
  DATA="$(date '+%Y-%m-%d %H:%M:%S')"

  sqlite3 "$DB" "INSERT INTO historico (pesquisa, data) VALUES ('$PESQUISA', '$DATA');"
}
