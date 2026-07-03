# MANUAL DO USUÁRIO

# AgentOS Núcleo
Versão: 1.0.0

---

## O que é

O AgentOS Núcleo é uma central de ferramentas para desenvolvimento, automação e organização de projetos diretamente no Termux.

Seu objetivo é oferecer um ambiente simples, modular e totalmente em Português do Brasil.

---

## Iniciando

Abra o Termux e execute:

agentos

Será exibido o menu principal.

---

## Menu Principal

1. Desenvolvimento
2. Inteligência Artificial
3. GitHub
4. Plugins
5. Banco de Dados
6. Diagnóstico
7. Atualizações
8. Cópia de Segurança
9. Configurações

0. Sair

---

## Banco de Dados

Execute:

agentos db

O banco utiliza SQLite.

Tabelas existentes:

- configurações
- favoritos
- histórico
- logs
- plugins

---

## Diagnóstico

Execute:

agentos doctor

Realiza verificações do ambiente e informa possíveis problemas.

---

## Atualizações

Execute:

agentos update

Verifica e instala atualizações disponíveis.

---

## Cópia de Segurança

Execute:

agentos backup

Os backups são armazenados em:

~/AgentOS_Backups/

---

## GitHub

Acesse pelo menu GitHub.

Permite pesquisar projetos públicos e gerenciar recursos relacionados.

---

## Plugins

Permite:

- listar plugins
- instalar plugins
- remover plugins

---

## Estrutura do Projeto

configs/
database/
docs/
exports/
favoritos/
github/
logs/
modules/
plugins/
plugins_available/
plugins_installed/
releases/
scripts/
temp/
tests/

---

## Versão

Para consultar a versão:

agentos version

---

## Idioma

Toda a interface do AgentOS utiliza Português do Brasil.

---

## Recomendações

- Faça backups regularmente.
- Não altere arquivos internos sem necessidade.
- Instale apenas plugins confiáveis.
- Mantenha o sistema atualizado.

---

## Suporte

Projeto:
AgentOS Núcleo

Versão:
1.0.0

Idioma:
Português do Brasil

Autor:
Fabio Brito
