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
modules/github.sh     Menu GitHub Explorer
modules/projects.sh   Projetos locais, pull, push e criacao de repo
modules/backup.sh     Backup e restauracao
modules/settings.sh   Configuracoes
modules/doctor.sh     Diagnostico
modules/help.sh       Ajuda
```

## Dados locais

```text
data/github_last_search.json   Ultima resposta bruta do GitHub
data/github_last_search.tsv    Ultima busca em formato simples
logs/agentos.log               Registro basico de sessoes
```

Essas pastas entram no `.gitignore`, porque sao dados do usuario.

## Principios

- Um comando principal.
- Um instalador oficial.
- Menus grandes o suficiente para serem uteis no celular.
- Scripts pequenos e legiveis.
- Nenhum token ou credencial salvo no projeto.
- Uso do GitHub CLI para operacoes autenticadas.
