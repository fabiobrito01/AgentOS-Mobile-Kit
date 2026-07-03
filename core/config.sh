#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"
DB="$BASE/database/agentos.db"

config_set() {
sqlite3 "$DB" \
"INSERT OR REPLACE INTO configs(chave,valor)
VALUES('$1','$2');"
}

config_get() {
sqlite3 "$DB" \
"SELECT valor FROM configs WHERE chave='$1';"
}
