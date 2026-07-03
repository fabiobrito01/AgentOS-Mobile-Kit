#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

clear

echo "=========================================="
echo "          AGENTOS NÚCLEO"
echo "=========================================="
echo
echo "Preparando ambiente..."
echo

mkdir -p "$BASE"/logs
mkdir -p "$BASE"/backups
mkdir -p "$BASE"/workspace
mkdir -p "$BASE"/exportacoes
mkdir -p "$BASE"/temporarios

touch "$BASE/database/agentos.db"

echo "✓ Estrutura verificada."

command -v git >/dev/null && echo "✓ Git"
command -v python >/dev/null && echo "✓ Python"
command -v node >/dev/null && echo "✓ Node.js"
command -v sqlite3 >/dev/null && echo "✓ SQLite"

echo
echo "Ambiente preparado com sucesso."
echo
echo "Agora execute:"
echo
echo "agentos iniciar"
echo
