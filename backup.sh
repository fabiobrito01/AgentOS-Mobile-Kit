#!/data/data/com.termux/files/usr/bin/bash
DEST="$HOME/storage/downloads/agentos_backup_$(date +%Y%m%d_%H%M%S).zip"
zip -r "$DEST" ~/AgentOS-Mobile-Kit ~/.bashrc ~/Scripts ~/Catalogos 2>/dev/null
echo "Backup salvo em: $DEST"
