#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"
DESTINO="$BASE/backups"

mkdir -p "$DESTINO"

ARQUIVO="backup_$(date +%Y%m%d_%H%M%S).tar.gz"

clear

echo "=============================================================="
echo "                  AGENTOS MOBILE KIT"
echo "                   BACKUP OFICIAL"
echo "=============================================================="
echo

echo "Criando backup..."

tar -czf "$DESTINO/$ARQUIVO" \
"$BASE/configs" \
"$BASE/database" \
"$BASE/docs" \
"$BASE/logs" \
"$BASE/modules" \
"$BASE/workspace" \
2>/dev/null

echo
echo "Backup concluído com sucesso."
echo
echo "Arquivo:"
echo "$DESTINO/$ARQUIVO"
echo
echo "=============================================================="

exit 0
