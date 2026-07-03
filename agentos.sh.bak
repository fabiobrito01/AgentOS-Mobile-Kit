#!/data/data/com.termux/files/usr/bin/bash

while true; do
clear
echo "========================================="
echo "        AgentOS Mobile Kit"
echo "========================================="
echo
echo "[1] Instalar ambiente"
echo "[2] Atualizar ambiente"
echo "[3] Doctor / Diagnóstico"
echo "[4] Backup"
echo "[5] Restaurar"
echo "[6] Git status"
echo "[7] Abrir pastas"
echo "[8] Checklist de apps"
echo "[9] Catálogo de agentes IA"
echo "[0] Sair"
echo
read -p "Escolha: " OPCAO

case "$OPCAO" in
1) bash install.sh ;;
2) bash update.sh ;;
3) bash doctor.sh ;;
4) bash backup.sh ;;
5) bash restore.sh ;;
6) git status ;;
7) echo "Pastas: ~/Projetos ~/GitHub ~/IA ~/Scripts ~/Backups ~/Catalogos" ;;
8) cat checklists/apps_android.md ;;
9) bash scripts/catalogo_agentes_ia.sh ;;
0) exit ;;
*) echo "Opção inválida." ;;
esac

echo
read -p "Pressione ENTER para continuar..."
done
