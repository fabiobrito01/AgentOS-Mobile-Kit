#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

clear

echo "========================================================="
echo "                   AGENTOS NÚCLEO"
echo "========================================================="
echo
echo "Restaurando ambiente..."
echo

if [ ! -d "$HOME/AgentOS_Backups" ]; then
    echo "Nenhuma pasta de backup encontrada."
    exit 1
fi

ARQUIVO=$(ls -t "$HOME"/AgentOS_Backups/*.tar.gz 2>/dev/null | head -n1)

if [ -z "$ARQUIVO" ]; then
    echo "Nenhum backup encontrado."
    exit 1
fi

echo
echo "Backup localizado:"
echo "$ARQUIVO"
echo

read -p "Deseja restaurar este backup? (s/n): " OP

if [ "$OP" != "s" ]; then
    echo
    echo "Operação cancelada."
    exit
fi

tar -xzf "$ARQUIVO" -C "$HOME"

echo
echo "✓ Backup restaurado."
echo "✓ Ambiente recuperado."
echo
echo "Execute:"
echo
echo "agentos preparar"
echo
