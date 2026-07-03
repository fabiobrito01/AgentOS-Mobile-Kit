#!/data/data/com.termux/files/usr/bin/bash

REPO="https://github.com/fabiobrito01/AgentOS-Mobile-Kit.git"
DEST="$HOME/AgentOS-Mobile-Kit"

clear
echo "==============================================="
echo "        AGENTOS MOBILE KIT - BOOTSTRAP"
echo "==============================================="
echo
echo "Instalando dependências básicas..."
echo

pkg update -y
pkg install -y git curl wget

echo
echo "Baixando AgentOS..."
echo

if [ -d "$DEST" ]; then
  echo "AgentOS já existe em: $DEST"
  cd "$DEST" || exit 1
  git pull
else
  git clone "$REPO" "$DEST"
  cd "$DEST" || exit 1
fi

echo
echo "Executando instalador..."
echo

chmod +x instalar.sh
bash instalar.sh

echo
echo "==============================================="
echo "Bootstrap concluído."
echo "Execute: agentos iniciar"
echo "==============================================="
