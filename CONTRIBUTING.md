# Contribuindo

Obrigado por querer melhorar o AgentOS Mobile Kit.

## Antes de enviar mudancas

1. Rode o smoke test:

```bash
bash tests/smoke.sh
```

2. Verifique scripts Shell:

```bash
shellcheck agentos instalar.sh lib/*.sh modules/*.sh tests/*.sh
```

3. Mantenha os scripts compativeis com Termux.

## Regras

- Nao commit credenciais, tokens, backups, `.env` ou chaves SSH.
- Menus devem ter opcao `0 Voltar`.
- Acoes destrutivas devem pedir confirmacao explicita.
- Dados do usuario devem ir para `~/storage/downloads/AgentOS`.
- Prefira funcoes pequenas e nomes claros.

## Pull requests

Explique:

- o que mudou;
- como testou;
- se mexeu em menus, instalacao ou GitHub.
