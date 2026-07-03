#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"
DEST="$HOME/AgentOS_Backups"

mkdir -p "$DEST"

ARQUIVO="$DEST/backup_$(date +%Y%m%d_%H%M%S).tar.gz"

echo
echo "Criando backup..."
echo

tar -czf "$ARQUIVO" \
"$BASE/configs" \
"$BASE/database" \
"$BASE/plugins_installed" \
"$BASE/catalogos" \
"$BASE/scripts" \
"$BASE/docs" 2>/dev/null

echo
echo "Backup criado:"
echo "$ARQUIVO"
