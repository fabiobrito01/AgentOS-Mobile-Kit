#!/data/data/com.termux/files/usr/bin/bash

clear
echo "=========================================="
echo "         GitHub Explorer"
echo "=========================================="
echo

read -s -p "Token GitHub: " TOKEN
echo
read -p "Pesquisar: " QUERY
echo
read -p "Quantidade (10-100): " LIMIT

[ -z "$LIMIT" ] && LIMIT=30

mkdir -p ~/Catalogos/GitHub

URL="https://api.github.com/search/repositories?q=$(echo "$QUERY" | sed 's/ /+/g')&sort=stars&order=desc&per_page=$LIMIT"

curl -s \
-H "Authorization: Bearer $TOKEN" \
-H "Accept: application/vnd.github+json" \
"$URL" \
> ~/Catalogos/GitHub/resultados.json

jq -r '.items[] |
"\(.name)|⭐ \(.stargazers_count)|\(.language // "N/A")|\(.owner.login)|\(.html_url)"' \
~/Catalogos/GitHub/resultados.json \
> ~/Catalogos/GitHub/resultados.txt

cat ~/Catalogos/GitHub/resultados.txt

echo
echo "=========================================="
echo "Arquivo salvo em:"
echo "~/Catalogos/GitHub/resultados.txt"
echo "=========================================="
