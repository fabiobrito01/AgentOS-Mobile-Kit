# AgentOS Mobile Kit

Central para preparar o Termux do zero e usar o celular como ambiente de trabalho com Git, GitHub e projetos locais.

O objetivo do AgentOS Mobile Kit e simples: abrir uma tela organizada no Termux, escolher opcoes por numero e executar tarefas comuns sem decorar comandos longos.

## O que ele faz

- Atualiza o Termux.
- Instala ferramentas essenciais: Git, Curl, Wget, GitHub CLI, OpenSSH, JQ, Python, Node.js, Zip, Tar e utilitarios.
- Configura pastas padrao para projetos.
- Salva projetos, clones, backups e exportacoes dentro de `Download/AgentOS`, para voce acessar pelo gerenciador de arquivos do celular.
- Ajuda a autenticar o GitHub CLI.
- Pesquisa repositorios no GitHub por area, tecnologia ou ideia.
- Clona repositorios para o celular.
- Faz fork de repositorios para seu GitHub e clona em seguida.
- Cria repositorios no seu GitHub a partir de uma pasta local.
- Atualiza projetos existentes com `git pull`.
- Envia alteracoes com `git add`, `commit` e `push`.
- Cria e restaura backups basicos do AgentOS.
- Mostra diagnostico do ambiente.

## Instalacao rapida no Termux

Cole no Termux:

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

Depois, para autenticar o GitHub:

```bash
gh auth login
```

## Comando principal

```bash
agentos
```

Isso abre a central com menus:

1. Preparar / atualizar Termux
2. GitHub Explorer
3. Projetos e trabalho
4. Backup e restauracao
5. Configuracoes
6. Diagnostico
7. Ajuda e comandos

## Estrutura

```text
AgentOS-Mobile-Kit/
  agentos                 Comando principal
  instalar.sh             Instalador oficial
  configs/                Configuracoes padrao
  lib/                    Bibliotecas internas
  modules/                Menus e funcionalidades
  docs/                   Documentacao
  scripts/                Scripts auxiliares
  tests/                  Smoke test local
```

Pastas criadas no Termux:

```text
~/AgentOS-Mobile-Kit                    Instalacao do AgentOS
~/storage/downloads/AgentOS/Projetos    Projetos pessoais
~/storage/downloads/AgentOS/GitHub      Repositorios clonados
~/storage/downloads/AgentOS/Backups     Backups
~/storage/downloads/AgentOS/Exportacoes Relatorios e arquivos ZIP
```

## Comandos diretos

```bash
agentos                  # abre o menu
agentos atualizar         # atualiza Termux e instala ferramentas
agentos github            # abre GitHub Explorer
agentos projetos          # abre menu de projetos e trabalho
agentos trabalho          # atalho para o mesmo menu
agentos backup            # cria backup
agentos doctor            # diagnostico
agentos config            # configuracoes
agentos version           # versao
```

## GitHub Explorer

O menu GitHub permite:

- pesquisar repositorios;
- listar a ultima busca;
- clonar um resultado para `~/GitHub`;
- fazer fork para sua conta e clonar;
- verificar login do GitHub CLI;
- copiar/mostrar URL de um resultado.

Para usar fork, criar repo e push, voce precisa estar logado:

```bash
gh auth login
gh auth status
```

## Status

Versao atual: `2.1.0`

Esta versao substitui a estrutura antiga por uma base mais limpa, direta e organizada para uso real no Termux.

## Projeto publico e seguranca

O projeto pode ser publico. Ele nao deve guardar tokens, senhas, chaves SSH, arquivos `.env`, bancos locais, backups ou logs. Esses itens estao no `.gitignore`.

Use o GitHub CLI para login:

```bash
gh auth login
```

Nunca coloque token dentro dos scripts.
