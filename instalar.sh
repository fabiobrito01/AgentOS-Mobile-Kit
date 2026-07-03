#!/data/data/com.termux/files/usr/bin/bash

#############################################################
# AgentOS-Mobile-Kit
# Instalador Oficial
# Versão: 1.1.0
#############################################################

VERSAO="1.1.0"

clear

echo "========================================================="
echo "             AGENTOS MOBILE KIT"
echo "           INSTALADOR OFICIAL"
echo "========================================================="
echo
echo "Versão................: $VERSAO"
echo

echo "[1/6] Verificando ambiente..."

pkg update -y >/dev/null 2>&1

echo "[2/6] Instalando dependências..."

pkg install -y \
git \
curl \
wget \
python \
nodejs \
sqlite >/dev/null 2>&1

echo "[3/6] Verificando GitHub CLI..."

if ! command -v gh >/dev/null 2>&1
then
    pkg install -y gh >/dev/null 2>&1
fi

echo "[4/6] Criando estrutura..."

mkdir -p \
"$HOME/AgentOS-Mobile-Kit"/{docs,logs,modules,configs}

echo "[5/6] Ajustando permissões..."

chmod -R 755 "$HOME/AgentOS-Mobile-Kit"

echo "[6/6] Finalizando..."

echo
echo "==============================================="
echo " Instalação concluída com sucesso."
echo "==============================================="
echo
echo "Agora execute:"
echo
echo "agentos iniciar"
echo
