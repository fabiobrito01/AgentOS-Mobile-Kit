<p align="center">
  <a href="docs/MANUAL_USUARIO.md">
    <img src="assets/brand/agentos-mobile-banner.svg" alt="AgentOS Mobile Kit — clique para abrir o manual" width="100%">
  </a>
</p>

<h1 align="center">AgentOS Mobile Kit</h1>

<p align="center">Uma central profissional para transformar o Termux em ambiente de trabalho, GitHub, automação e desenvolvimento direto no celular. <strong>Clique no banner para abrir o manual.</strong></p>

<p align="center">
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0-blue"></a>
  <img alt="CI" src="https://img.shields.io/github/actions/workflow/status/fabiobrito01/AgentOS-Mobile-Kit/ci.yml?label=CI">
  <img alt="Shell" src="https://img.shields.io/badge/shell-bash-4EAA25">
  <img alt="Platform" src="https://img.shields.io/badge/platform-Termux%20%7C%20Android-00a86b">
  <img alt="GitHub Explorer" src="https://img.shields.io/badge/GitHub%20Explorer-core-111827">
  <img alt="Version" src="https://img.shields.io/badge/version-2.4.0-7c3aed">
</p>

---

## Visao geral

O AgentOS Mobile Kit deixa o Termux mais amigavel: voce abre um painel, escolhe numeros e executa tarefas de GitHub, projetos, pacotes, diagnostico e manutencao sem decorar comandos longos.

Ele salva projetos, clones, relatorios, favoritos e backups em:

```text
~/storage/downloads/AgentOS
```

Assim voce consegue acessar tudo pelo gerenciador de arquivos do Android.

## Instalacao

No Termux:

```bash
pkg update -y &&
pkg upgrade -y &&
pkg install git curl wget gh openssh jq -y &&
git clone https://github.com/fabiobrito01/AgentOS-Mobile-Kit.git ~/AgentOS-Mobile-Kit &&
cd ~/AgentOS-Mobile-Kit &&
bash instalar.sh &&
agentos
```

Se o repositorio estiver privado:

```bash
gh auth login
```

## Menu principal

```text
1  GitHub Explorer
2  GitHub Manager
3  Workspace
4  Sistema
5  Catalogo Turbo
6  Meu celular / Termux
7  Assistente de comandos
8  Backup e restauracao
9  Configuracoes
10 Diagnostico
11 Ajuda e comandos
0  Sair
```

## GitHub Explorer

O coracao do sistema. Depois de pesquisar um repositorio, o AgentOS abre uma tela de acoes:

```text
1  Ver detalhes
2  Clonar para Download/Projetos
3  Fazer fork para meu GitHub
4  Baixar ZIP
5  Abrir/mostrar pagina do GitHub
6  Salvar nos favoritos
0  Voltar
```

Tambem possui favoritos, historico e exportacao da ultima pesquisa.

## GitHub Manager

Area exclusiva para sua conta:

```text
1  Meus repositorios
2  Atualizar repositorios locais
3  Criar repositorio
4  Arquivar
5  Excluir
6  Catalogo Turbo
7  Exportar relatorio
0  Voltar
```

A exclusao exige confirmacao textual. O fluxo recomendado e arquivar antes de excluir.

## Workspace

Reconhece automaticamente projetos:

- Flutter
- Node
- Python
- Rust
- Go
- Android/Gradle
- Laravel

E sugere comandos especificos para cada tipo.

## Sistema

Central do Termux:

```text
1  Atualizar Termux
2  Instalar ferramentas
3  Permissoes
4  Git
5  GitHub CLI
6  Pacotes
7  Atualizar AgentOS
0  Voltar
```

## Diagnostico

Mostra em uma tela:

- espaco livre;
- memoria;
- bateria quando Termux:API estiver disponivel;
- velocidade HTTP;
- permissoes do Termux;
- GitHub autenticado;
- SSH;
- Git;
- ferramentas essenciais;
- pastas do AgentOS.

## Comandos diretos

```bash
agentos
agentos github
agentos manager
agentos projetos
agentos sistema
agentos auditoria
agentos pacotes
agentos celular
agentos assistente
agentos doctor
```

## Documentacao

- [Instalacao](docs/INSTALACAO.md)
- [Comandos](docs/COMANDOS.md)
- [GitHub Explorer](docs/GITHUB.md)
- [Auditoria GitHub](docs/AUDITORIA_GITHUB.md)
- [Pacotes](docs/PACOTES.md)
- [Meu celular](docs/CELULAR.md)
- [Assistente](docs/ASSISTENTE.md)
- [Arquitetura](docs/ARQUITETURA.md)
- [Seguranca](SECURITY.md)
- [Contribuindo](CONTRIBUTING.md)

## Licenca

Apache-2.0. Consulte [LICENSE](LICENSE).
