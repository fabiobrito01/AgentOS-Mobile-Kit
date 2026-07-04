# Politica de Seguranca

## Reportar vulnerabilidade

Se encontrar token exposto, comando destrutivo perigoso ou falha que possa apagar dados, abra uma issue privada ou entre em contato com o mantenedor.

## Escopo

Este projeto roda no Termux e pode executar comandos locais. Por isso:

- nenhuma credencial deve ser salva no repositorio;
- exclusao de repositorios deve exigir confirmacao;
- backups, logs e dados locais ficam fora do Git;
- autenticacao GitHub deve usar `gh auth login`.

## Boas praticas

Antes de publicar:

```bash
grep -R "ghp_" .
grep -R "github_pat_" .
grep -R "Authorization: Bearer" .
```

Se aparecer segredo real, remova e revogue imediatamente.
