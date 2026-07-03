#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

echo "======================================"
echo "      AgentOS Update"
echo "======================================"
echo

cd "$BASE" || exit

if [ -d ".git" ]; then
    echo "Atualizando repositório..."
    git pull
else
    echo "Este projeto ainda não é um repositório Git."
    echo "Quando publicarmos no GitHub, a atualização será automática."
fi

echo
pkg update -y
pkg upgrade -y

echo
echo "Atualização concluída."
