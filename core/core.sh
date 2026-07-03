#!/data/data/com.termux/files/usr/bin/bash

CONFIG="$HOME/AgentOS-Mobile-Kit/configs/config.conf"

clear

echo "======================================"
echo "        AgentOS Core"
echo "======================================"

if [ -f "$CONFIG" ]; then
    source "$CONFIG"
    echo "Versão........: $VERSION"
    echo "Usuário.......: $OWNER"
    echo "Resultados....: $DEFAULT_RESULTS"
else
    echo "Configuração não encontrada."
fi

echo
