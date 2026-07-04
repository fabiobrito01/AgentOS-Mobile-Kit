# GitHub Explorer

O GitHub Explorer e o modulo para encontrar repositorios, estudar projetos e trazer codigo para o celular.

## Antes de usar

Instale e autentique:

```bash
pkg install gh git curl jq -y
gh auth login
gh auth status
```

Sem login, a busca publica ainda pode funcionar via API publica. Para fork, criar repo e push, o login e obrigatorio.

## Pesquisar repositorios

Abra:

```bash
agentos github
```

Escolha:

```text
1  Pesquisar repositorios
```

Exemplos de busca:

```text
flutter school app
python automation android
termux github tools
offline ai assistant
react native inventory
```

## Clonar para o celular

Depois da busca:

```text
2  Clonar para Download/Projetos
```

O projeto sera clonado em:

```text
~/storage/downloads/AgentOS/GitHub
```

## Fazer fork e clonar

Depois da busca:

```text
4  Forkar resultado para meu GitHub e clonar
```

Isso usa:

```bash
gh repo fork
```

O repositorio passa a existir na sua conta e tambem fica clonado no celular.

## Fluxo de acoes

Depois de pesquisar, escolha um numero de resultado. O AgentOS abre:

```text
1 Ver detalhes
2 Clonar para Download/Projetos
3 Fazer Fork para meu GitHub
4 Baixar ZIP
5 Abrir pagina do GitHub
6 Salvar nos favoritos
0 Voltar
```

## Subir projeto local para seu GitHub

Use:

```bash
agentos projetos
```

Depois escolha:

```text
5  Criar repositorio GitHub a partir de uma pasta
```

O AgentOS inicializa Git se precisar, cria o repositorio com `gh repo create` e envia o primeiro push.

## Favoritos e historico

Depois de pesquisar, voce pode salvar um resultado nos favoritos.

Arquivos salvos:

```text
~/storage/downloads/AgentOS/Favoritos/github_favoritos.tsv
~/storage/downloads/AgentOS/Historico/buscas_github.tsv
```

Tambem e possivel exportar a ultima busca para:

```text
~/storage/downloads/AgentOS/Exportacoes
```
