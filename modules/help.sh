#!/data/data/com.termux/files/usr/bin/bash

agentos_help() {
  ui_title
  ui_section "Comandos rapidos"
  cat <<'EOF'
agentos
  Abre a central principal.

agentos atualizar
  Atualiza o Termux e instala as ferramentas essenciais.

agentos github
  Abre o GitHub Explorer.

agentos projetos
  Abre ferramentas para projetos locais.

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
