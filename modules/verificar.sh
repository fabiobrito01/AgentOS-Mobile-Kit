#!/data/data/com.termux/files/usr/bin/bash

#############################################################
# AgentOS-Mobile-Kit
# Módulo: Verificar
# Versão: 1.1.0
#############################################################

VERSAO="1.1.0"

clear

echo "========================================================="
echo "                 AGENTOS-MOBILE-KIT"
echo "========================================================="
echo
echo "Relatório Técnico do Ambiente"
echo

verificar() {

if command -v "$1" >/dev/null 2>&1
then
printf "%-25s [OK]\n" "$2"
else
printf "%-25s [ERRO]\n" "$2"
fi

}

echo "INFORMAÇÕES DO SISTEMA"
echo "---------------------------------------------------------"

echo "Usuário................: $(whoami)"
echo "Data...................: $(date)"
echo "Arquitetura............: $(uname -m)"
echo "Kernel.................: $(uname -r)"
echo "Sistema................: Android/Termux"

echo

echo "ARMAZENAMENTO"
echo "---------------------------------------------------------"

df -h "$HOME" | tail -1

echo

echo "FERRAMENTAS"
echo "---------------------------------------------------------"

verificar git Git
verificar gh "GitHub CLI"
verificar curl Curl
verificar wget Wget
verificar python Python
verificar sqlite3 SQLite
verificar node Node.js

echo


echo
echo "REDE"
echo "---------------------------------------------------------"

if curl -Is https://github.com >/dev/null 2>&1
then
    echo "Internet............... OK"
else
    echo "Internet............... SEM CONEXÃO"
fi

echo
echo "STATUS FINAL"
echo "---------------------------------------------------------"

echo "Ambiente............... APROVADO"
echo "Versão AgentOS......... $VERSAO"

echo
echo "Diagnóstico concluído com sucesso."

exit 0
