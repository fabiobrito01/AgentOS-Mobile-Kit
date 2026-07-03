#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/AgentOS-Mobile-Kit"

while true; do
clear
echo "======================================="
echo "      AgentOS Plugin Manager"
echo "======================================="
echo
echo "[1] Listar plugins disponíveis"
echo "[2] Listar plugins instalados"
echo "[3] Instalar plugin"
echo "[4] Remover plugin"
echo "[0] Voltar"
echo
read -p "Escolha: " OP

case "$OP" in
1)
  clear
  echo "Plugins disponíveis:"
  echo
  for P in "$BASE"/plugins_available/*; do
    [ -d "$P" ] || continue
    CONF="$P/plugin.conf"
    ID=$(grep '^ID=' "$CONF" | cut -d= -f2- | tr -d '"')
    NAME=$(grep '^NAME=' "$CONF" | cut -d= -f2- | tr -d '"')
    VERSION=$(grep '^VERSION=' "$CONF" | cut -d= -f2- | tr -d '"')
    DESCRIPTION=$(grep '^DESCRIPTION=' "$CONF" | cut -d= -f2- | tr -d '"')
    echo "$ID - $NAME v$VERSION"
    echo "  $DESCRIPTION"
    echo
  done
;;

2)
  clear
  echo "Plugins instalados:"
  cat "$BASE/plugins_installed/list.db" 2>/dev/null || echo "Nenhum plugin instalado."
;;

3)
  read -p "ID do plugin: " PLUGIN
  SRC="$BASE/plugins_available/$PLUGIN"
  DEST="$BASE/plugins_installed/$PLUGIN"

  if [ ! -d "$SRC" ]; then
    echo "Plugin não encontrado."
  else
    cp -r "$SRC" "$DEST"
    echo "$PLUGIN" >> "$BASE/plugins_installed/list.db"
    echo "Plugin instalado: $PLUGIN"
  fi
;;

4)
  read -p "ID do plugin: " PLUGIN
  rm -rf "$BASE/plugins_installed/$PLUGIN"
  grep -v "^$PLUGIN$" "$BASE/plugins_installed/list.db" > "$BASE/plugins_installed/list.tmp"
  mv "$BASE/plugins_installed/list.tmp" "$BASE/plugins_installed/list.db"
  echo "Plugin removido: $PLUGIN"
;;

0)
  exit
;;

*)
  echo "Opção inválida."
;;
esac

echo
read -p "ENTER para continuar..."
done
