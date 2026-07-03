# ESPECIFICAÇÃO TÉCNICA

## Comando

**agentos verificar**

---

# 1. Objetivo

O comando **agentos verificar** tem como finalidade realizar uma análise completa do ambiente do AgentOS-Mobile-Kit, verificando sua integridade, organização e estado operacional antes da utilização.

Sua principal função é identificar problemas de configuração, dependências ausentes, inconsistências na estrutura do projeto e possíveis falhas que possam comprometer o funcionamento do sistema.

Ao término da execução, o comando deverá informar de forma clara se o ambiente está apto para utilização ou se necessita de alguma intervenção.

---

# 2. Escopo

O comando executará apenas verificações e diagnósticos.

Nenhum arquivo do projeto deverá ser alterado durante sua execução.

Toda análise será realizada em modo somente leitura, garantindo que nenhuma configuração existente seja modificada.

---

# 3. Verificação da Estrutura do Projeto

O sistema deverá verificar automaticamente a existência dos diretórios considerados obrigatórios para o funcionamento do AgentOS-Mobile-Kit.

Entre eles:

- configs
- modules
- github
- database
- docs
- plugins_available
- plugins_installed
- releases
- logs
- backups
- workspace

Caso algum diretório esteja ausente, o relatório deverá informar o problema e recomendar a ação necessária para sua correção.

---

# 4. Verificação dos Arquivos Obrigatórios

O comando deverá confirmar a existência dos principais arquivos do projeto, incluindo:

- agentos
- VERSION
- README.md
- CHANGELOG.md
- MANUAL_DO_USUARIO.md

Arquivos ausentes deverão ser destacados no relatório final.

---

# 5. Verificação das Dependências

O AgentOS deverá verificar automaticamente a disponibilidade das seguintes ferramentas:

- Git
- GitHub CLI
- Bash
- Curl
- Wget
- Python
- Node.js
- SQLite
- Tar

Para cada dependência deverão ser apresentados:

- Situação (Instalada ou Não instalada);
- Versão encontrada;
- Recomendação caso exista algum problema.

---

# 6. Verificação do Git

O sistema deverá analisar:

- Branch atualmente utilizada;
- Remote configurado;
- Alterações locais pendentes;
- Último commit realizado;
- Estado geral do repositório.

---

# 7. Verificação do GitHub

O comando deverá confirmar:

- Autenticação do GitHub CLI;
- Repositório conectado;
- Release atual;
- Comunicação com o GitHub.

---

# 8. Verificação do Banco de Dados

O sistema deverá verificar:

- Existência do banco SQLite;
- Permissão de acesso;
- Integridade básica do banco;
- Disponibilidade para utilização.

---

# 9. Verificação dos Backups

O comando deverá informar:

- Existência da pasta de backup;
- Quantidade de backups disponíveis;
- Data do backup mais recente;
- Integridade básica do arquivo encontrado.

---

# 10. Verificação do Espaço de Armazenamento

O sistema deverá apresentar:

- Espaço livre disponível;
- Espaço utilizado pelo AgentOS-Mobile-Kit;
- Situação geral do armazenamento.

---

# 11. Relatório Final

Ao finalizar a análise, o AgentOS deverá apresentar um relatório organizado contendo o resultado de todas as verificações realizadas.

Exemplo:

Estrutura.................. OK

Arquivos................... OK

Dependências............... OK

Git........................ OK

GitHub..................... OK

Banco de Dados............. OK

Backups.................... OK

Espaço..................... OK

----------------------------------------

STATUS GERAL

Situação................... APROVADO

Problemas encontrados...... 0

Avisos..................... 0

Ambiente pronto para utilização.

---

# 12. Tratamento de Problemas

Sempre que alguma inconsistência for identificada, o relatório deverá apresentar:

- Componente analisado;
- Problema encontrado;
- Possível causa;
- Ação recomendada para correção.

Exemplo:

GitHub..................... ERRO

Problema:

Usuário não autenticado.

Correção recomendada:

gh auth login

---

# 13. Critérios de Aprovação

O ambiente será considerado aprovado quando:

- Todos os diretórios obrigatórios estiverem presentes;
- Todos os arquivos obrigatórios existirem;
- Todas as dependências estiverem instaladas;
- O banco de dados estiver acessível;
- O repositório Git estiver íntegro;
- O GitHub CLI estiver autenticado;
- Não existirem erros críticos.

---

# 14. Benefícios

A implementação do comando **agentos verificar** permitirá que o usuário valide rapidamente a integridade do ambiente antes de iniciar qualquer atividade, reduzindo o risco de falhas durante o desenvolvimento, instalação, atualização ou recuperação do sistema.

Além disso, este comando servirá como ferramenta oficial de diagnóstico da versão 1.1.0, tornando-se uma das principais funcionalidades de suporte e manutenção do AgentOS-Mobile-Kit.

---

# Status da Especificação

**Projeto:** AgentOS-Mobile-Kit

**Versão:** 1.1.0

**Documento:** Especificação Técnica

**Situação:** Aguardando implementação.
