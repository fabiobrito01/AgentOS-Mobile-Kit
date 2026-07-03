#!/data/data/com.termux/files/usr/bin/bash

set -e

pkg update -y
pkg upgrade -y
pkg install -y git curl wget gh openssh jq

if [ ! -d "$HOME/AgentOS-Mobile-Kit" ]; then
  git clone https://github.com/fabiobrito01/AgentOS-Mobile-Kit.git "$HOME/AgentOS-Mobile-Kit"
fi

cd "$HOME/AgentOS-Mobile-Kit"
chmod +x instalar.sh
bash instalar.sh
agentos
