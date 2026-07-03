#!/data/data/com.termux/files/usr/bin/bash

clear

echo "===================================="
echo " AgentOS Mobile Kit Installer"
echo "===================================="

pkg update -y
pkg upgrade -y

pkg install -y \
git \
curl \
wget \
jq \
zip \
unzip \
tar \
tree \
nano \
vim \
htop \
tmux \
openssh \
python \
python-pip \
nodejs \
clang \
cmake \
make \
ripgrep \
fzf \
rsync \
gh

termux-setup-storage

mkdir -p ~/Projetos
mkdir -p ~/GitHub
mkdir -p ~/IA
mkdir -p ~/Scripts
mkdir -p ~/Backups
mkdir -p ~/Catalogos

git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor nano

echo
read -p "Digite seu nome: " NOME
git config --global user.name "$NOME"

read -p "Digite seu email GitHub: " EMAIL
git config --global user.email "$EMAIL"

npm install -g firebase-tools

cat >> ~/.bashrc <<'EOF'

alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'
alias gpu='git push'
alias c='clear'

alias projetos='cd ~/Projetos'
alias github='cd ~/GitHub'
alias scripts='cd ~/Scripts'
alias ia='cd ~/IA'

EOF

echo
echo "===================================="
echo "Instalação concluída!"
echo "Feche e abra o Termux."
echo "===================================="
