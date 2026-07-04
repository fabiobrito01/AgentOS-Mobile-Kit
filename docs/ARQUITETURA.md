# Arquitetura

O AgentOS Mobile Kit foi reorganizado para ter poucas pecas, cada uma com responsabilidade clara.

## Entrada unica

```text
agentos
```

O arquivo `agentos` carrega configuracoes, bibliotecas e modulos. Ele tambem aceita comandos diretos como `agentos github` e `agentos doctor`.

## Bibliotecas

```text
lib/ui.sh        Cores, cabecalhos, menus e mensagens
lib/config.sh    Pastas, configuracao e logs
lib/system.sh    Funcoes de sistema e dependencias
lib/github.sh    Funcoes de busca, clone, fork e login GitHub
```

## Modulos

```text
modules/termux.sh     Atualizacao, pacotes, storage e Git
modules/packages.sh   Central de pacotes por categoria
modules/github.sh     Menu GitHub Explorer
modules/manager.sh    Gerenciamento da conta GitHub
modules/audit.sh      Auditoria de repositorios e Catalogo Turbo
modules/projects.sh   Projetos locais, pull, push e criacao de repo
modules/system_menu.sh Sistema, permissoes, pacotes e auto-update
modules/device.sh     Informacoes e manutencao segura do celular
modules/assistant.sh  Assistente de comandos
modules/backup.sh     Backup e restauracao
modules/settings.sh   Configuracoes
modules/doctor.sh     Diagnostico
modules/help.sh       Ajuda
```

## Dados locais

```text
data/github_last_search.json                   Ultima resposta bruta do GitHub
data/github_last_search.tsv                    Ultima busca em formato simples
logs/agentos.log                               Registro basico de sessoes
~/storage/downloads/AgentOS/Projetos           Projetos criados pelo usuario
~/storage/downloads/AgentOS/GitHub             Repositorios clonados
~/storage/downloads/AgentOS/Backups            Backups
~/storage/downloads/AgentOS/Exportacoes        Relatorios e ZIPs
~/storage/downloads/AgentOS/Favoritos          Favoritos do GitHub
~/storage/downloads/AgentOS/Historico          Historico de buscas
~/storage/downloads/AgentOS/AuditoriaGitHub    Relatorios de repositorios
~/storage/downloads/AgentOS/Catalogos          Catalogo Turbo
```

Essas pastas entram no `.gitignore`, porque sao dados do usuario.

## Principios

- Um comando principal.
- Um instalador oficial.
- Menus grandes o suficiente para serem uteis no celular.
- Scripts pequenos e legiveis.
- Nenhum token ou credencial salvo no projeto.
- Uso do GitHub CLI para operacoes autenticadas.
