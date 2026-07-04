#!/data/data/com.termux/files/usr/bin/bash

agentos_help() {
  ui_title
  ui_section "Comandos rapidos"
  cat <<'EOF'
agentos
  Abre a central principal.

agentos atualizar
  Atualiza o Termux e instala as ferramentas essenciais.

agentos pacotes
  Abre a central de pacotes por categoria.

agentos github
  Abre o GitHub Explorer.

agentos manager
  Gerencia seus repositorios do GitHub.

agentos auditoria
  Audita seus repositorios e abre o Catalogo Turbo.

agentos projetos
  Abre o Workspace inteligente.

agentos sistema
  Abre a central do Termux e atualizacao do AgentOS.

agentos celular
  Abre informacoes, limpeza segura e caminhos do celular.

agentos assistente
  Mostra comandos prontos e pergunta antes de executar.

agentos backup
  Cria backup das configuracoes e dados do AgentOS.

agentos doctor
  Verifica dependencias, pastas, rede e GitHub CLI.

agentos config
  Mostra e altera configuracoes.

agentos version
  Mostra a versao instalada.
EOF
}
