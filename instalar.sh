#!/data/data/com.termux/files/usr/bin/bash

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/AgentOS-Mobile-Kit"
BIN_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"

printf "\033[32m============================================================\033[0m\n"
printf "\033[1m  AgentOS Mobile Kit - Instalador oficial\033[0m\n"
printf "\033[32m============================================================\033[0m\n\n"

if ! command -v pkg >/dev/null 2>&1; then
  printf "[ERRO] Este instalador foi feito para rodar dentro do Termux.\n"
  exit 1
fi

printf "[1/6] Atualizando Termux...\n"
pkg update -y && pkg upgrade -y

printf "[2/6] Instalando dependencias essenciais...\n"
pkg install -y git curl wget gh openssh jq tar zip unzip nano vim tree rsync python nodejs

printf "[3/6] Preparando pastas...\n"
mkdir -p "$TARGET_DIR"

if command -v termux-setup-storage >/dev/null 2>&1; then
  printf "Solicitando acesso ao armazenamento do Android...\n"
  termux-setup-storage || true
  printf "Se o Android pedir permissao, aceite. Se necessario, rode o instalador novamente depois.\n"
fi

printf "[4/6] Copiando AgentOS...\n"
if [ "$PROJECT_DIR" != "$TARGET_DIR" ]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$PROJECT_DIR/" "$TARGET_DIR/"
  else
    cp -R "$PROJECT_DIR/." "$TARGET_DIR/"
  fi
fi

printf "[5/6] Instalando comando agentos...\n"
chmod +x "$TARGET_DIR/agentos" "$TARGET_DIR/instalar.sh"
find "$TARGET_DIR/modules" "$TARGET_DIR/lib" -type f -name "*.sh" -exec chmod +x {} \;
ln -sf "$TARGET_DIR/agentos" "$BIN_DIR/agentos"

printf "[6/6] Criando configuracao inicial...\n"
AGENTOS_HOME="$TARGET_DIR" "$TARGET_DIR/agentos" doctor >/dev/null 2>&1 || true

printf "\n\033[32mInstalacao concluida.\033[0m\n\n"
printf "Proximos passos:\n"
printf "  agentos\n"
printf "  agentos config\n"
printf "  agentos atualizar\n"
printf "  gh auth login\n\n"
