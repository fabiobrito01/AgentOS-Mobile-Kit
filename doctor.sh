#!/data/data/com.termux/files/usr/bin/bash
clear
echo "===== AgentOS Doctor ====="
echo "Usuário: $(whoami)"
echo "Sistema: $(uname -a)"
echo "Git: $(git --version 2>/dev/null)"
echo "Python: $(python --version 2>/dev/null)"
echo "Node: $(node --version 2>/dev/null)"
echo "NPM: $(npm --version 2>/dev/null)"
echo "GH: $(gh --version 2>/dev/null | head -n 1)"
echo
df -h
