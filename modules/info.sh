#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

source "$BASE/configs/config.conf"

clear

echo "=============================================================="
echo "                    AGENTOS MOBILE KIT"
echo "                   INFORMAÇÕES DO SISTEMA"
echo "=============================================================="
echo
echo "Projeto...............: AgentOS Mobile Kit"
echo "Versão................: $VERSION"
echo "Build.................: $BUILD"
echo "Autor.................: $AUTHOR"
echo "Sistema...............: Android / Termux"
echo "Shell.................: Bash"
echo "Arquitetura...........: $(uname -m)"
echo
echo "Repositório...........:"
git config --get remote.origin.url
echo
echo "Branch................: $(git branch --show-current)"
echo "Último Commit.........: $(git rev-parse --short HEAD)"
echo
echo "Diretório.............: $BASE"
echo "Workspace.............: $BASE/workspace"
echo "Logs..................: $BASE/logs"
echo "Backups...............: $BASE/backups"
echo
echo "Espaço Livre..........:"
df -h "$HOME" | tail -1 | awk '{print $4}'
echo
echo "Status Git............:"
git status --short >/dev/null
if [ $? -eq 0 ]; then
    echo "Repositório OK"
else
    echo "Necessita verificação"
fi
echo
echo "=============================================================="
