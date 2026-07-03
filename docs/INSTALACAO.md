# Instalacao

Este projeto foi feito para rodar no Termux em Android.

## Instalar do zero

Cole este comando no Termux:

```bash
pkg update -y &&
pkg upgrade -y &&
pkg install git curl wget gh openssh jq -y &&
git clone https://github.com/fabiobrito01/AgentOS-Mobile-Kit.git ~/AgentOS-Mobile-Kit &&
cd ~/AgentOS-Mobile-Kit &&
chmod +x instalar.sh &&
bash instalar.sh &&
agentos
```

## O que o instalador faz

1. Atualiza o Termux.
2. Instala ferramentas essenciais.
3. Solicita permissao de armazenamento com `termux-setup-storage`.
4. Cria pastas padrao dentro do Download:
   - `~/storage/downloads/AgentOS/Projetos`
   - `~/storage/downloads/AgentOS/GitHub`
   - `~/storage/downloads/AgentOS/Backups`
   - `~/storage/downloads/AgentOS/Exportacoes`
5. Instala o comando global `agentos`.
6. Ajusta permissao dos scripts.

## Autenticar GitHub

Depois da instalacao:

```bash
gh auth login
gh auth status
```

Escolha GitHub.com e siga as instrucoes do GitHub CLI.

## Reabrir a central

```bash
agentos
```
