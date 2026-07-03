#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/Catalogos/AgentesIA"
mkdir -p "$BASE"

read -s -p "Token GitHub: " TOKEN
echo
read -p "Quantidade de resultados: " LIMITE
[ -z "$LIMITE" ] && LIMITE=30

QUERY='ai agent llm autonomous agent stars:>100'

curl -s \
-H "Authorization: Bearer $TOKEN" \
-H "Accept: application/vnd.github+json" \
"https://api.github.com/search/repositories?q=$(echo "$QUERY" | sed 's/ /+/g')&sort=stars&order=desc&per_page=$LIMITE" \
> "$BASE/agentes_ia.json"

jq -r '.items[] | "\(.name) | ⭐ \(.stargazers_count) | \(.language // "N/A") | \(.html_url)"' "$BASE/agentes_ia.json" \
> "$BASE/agentes_ia.txt"

cp "$BASE/agentes_ia.txt" ~/storage/downloads/

echo "Catálogo salvo em Downloads: agentes_ia.txt"
