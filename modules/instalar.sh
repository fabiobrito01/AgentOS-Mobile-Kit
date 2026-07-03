#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

clear

echo "========================================================="
echo "                 AGENTOS NÚCLEO"
echo "========================================================="
echo
echo "Instalando ambiente..."
echo

pkg update -y
pkg upgrade -y

pkg install -y \
git \
python \
nodejs \
sqlite \
tar \
curl \
wget

mkdir -p "$BASE"

cp "$BASE/agentos" "$PREFIX/bin/agentos"
chmod +x "$PREFIX/bin/agentos"

echo
echo "Preparando estrutura..."
echo

agentos preparar

echo
echo "========================================================="
echo "        AGENTOS NÚCLEO INSTALADO COM SUCESSO"
echo "========================================================="
echo
echo "Agora execute:"
echo
echo "agentos iniciar"
echo
