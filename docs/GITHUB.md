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
3  Clonar resultado para o celular
```

O projeto sera clonado em:

```text
~/GitHub
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
