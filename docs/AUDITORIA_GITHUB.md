# Auditoria GitHub e Catalogo Turbo

Abra com:

```bash
agentos auditoria
```

## Auditoria

A auditoria usa o GitHub CLI para listar seus repositorios, inclusive privados quando voce estiver autenticado.

```bash
gh auth login
agentos auditoria
```

O painel gera:

```text
~/storage/downloads/AgentOS/AuditoriaGitHub/repos.json
~/storage/downloads/AgentOS/AuditoriaGitHub/repos.tsv
~/storage/downloads/AgentOS/AuditoriaGitHub/repos_classificados.tsv
~/storage/downloads/AgentOS/AuditoriaGitHub/RELATORIO_GITHUB.md
```

As recomendacoes sao:

- `MANTER`: combina com seus trabalhos de IA, agentes, automacao, app ou projeto proprio.
- `REVISAR`: pode ser util, mas precisa de contexto, descricao ou organizacao.
- `ARQUIVAR?`: parece fora do foco atual ou com nome pouco claro.

Nada e excluido automaticamente.

## Catalogo Turbo

O Catalogo Turbo e uma lista curada de repos fortes para desenvolver projetos maiores:

- IA local;
- agentes;
- automacao;
- dados;
- mobile;
- DevOps.

Voce pode clonar ou forkar um item escolhido. O painel pede confirmacao antes de fork.
