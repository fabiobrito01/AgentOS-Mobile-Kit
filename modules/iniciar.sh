#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

clear

echo "========================================================="
echo "                   AGENTOS NÚCLEO"
echo "========================================================="
echo
echo "Iniciando sessão..."
echo

mkdir -p "$BASE/logs"
mkdir -p "$BASE/workspace"

DATA=$(date +"%d/%m/%Y %H:%M:%S")

echo "===================================" >> "$BASE/logs/sessoes.log"
echo "Sessão iniciada: $DATA" >> "$BASE/logs/sessoes.log"

echo "Data........: $DATA"
echo "Projeto.....: AgentOS Núcleo"
echo "Versão......: 1.0.0"
echo "Idioma......: Português do Brasil"
echo
echo "Workspace:"
echo "$BASE/workspace"
echo
echo "Logs:"
echo "$BASE/logs"
echo
echo "Backup:"
echo "$BASE/backups"
echo
echo "Tudo pronto."
echo
echo "Abrindo menu principal..."
sleep 2

bash "$BASE/menu_principal.sh"
