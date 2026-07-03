# Seguranca

Este repositorio pode ser publico desde que continue seguindo estas regras:

- Nao salvar token GitHub no codigo.
- Nao salvar senha em scripts.
- Nao publicar `.env`.
- Nao publicar chaves SSH.
- Nao publicar backups pessoais.
- Nao publicar logs com caminhos ou dados sensiveis.
- Usar `gh auth login` para autenticacao.

## Onde ficam os dados do usuario

Os dados acessiveis pelo celular ficam em:

```text
~/storage/downloads/AgentOS
```

Dentro dessa pasta:

```text
Projetos/
GitHub/
Backups/
Exportacoes/
```

Essas pastas nao precisam entrar no repositorio.

## Antes de publicar

Rode:

```bash
grep -R "ghp_" .
grep -R "github_pat_" .
grep -R "Authorization: Bearer" .
```

Se aparecer algo, remova antes do commit.
