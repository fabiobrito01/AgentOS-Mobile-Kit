#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

clear

echo "=============================================================="
echo "                  AGENTOS MOBILE KIT"
echo "                  ATUALIZAÇÃO OFICIAL"
echo "=============================================================="
echo
echo "Verificando repositório..."
echo

cd "$BASE" || exit 1

git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Sistema já está atualizado."
    exit 0
fi

echo "Nova atualização encontrada."
echo
echo "Atualizando..."

git pull origin main

echo
echo "Atualização concluída."
echo
echo "Versão instalada:"
git describe --tags --always 2>/dev/null

exit 0
