#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

clear

echo "========================================================="
echo "                   AGENTOS NÚCLEO"
echo "========================================================="
echo
echo "Encerrando sessão..."
echo

DATA=$(date +"%d/%m/%Y %H:%M:%S")

echo "Sessão encerrada: $DATA" >> "$BASE/logs/sessoes.log"

echo "✓ Sessão registrada."
echo "✓ Histórico atualizado."
echo
echo "Lembre-se de executar uma cópia de segurança caso tenha alterado arquivos importantes."
echo
echo "Até a próxima."
echo
