#!/data/data/com.termux/files/usr/bin/bash

REPO="AgentOS-Mobile-Kit"
USER_GITHUB="fabiobrito01"

echo "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"
read -s TOKEN
echo

echo "Criando .gitignore seguro..."
cat > .gitignore <<'EOT'
backups/
logs/
temporarios/
workspace/
exportacoes/
*.db
*.sqlite
*.log
*.tar.gz
.env
id_rsa
id_ed25519
EOT

echo "Criando repositório privado no GitHub..."
curl -s -H "Authorization: Bearer $TOKEN" \
-H "Accept: application/vnd.github+json" \
https://api.github.com/user/repos \
-d "{\"name\":\"$REPO\",\"private\":true}" > criar_repo.json

echo "Preparando Git local..."
git init
git branch -M main
git config user.name "Fabio Brito"
git config user.email "fabiobrito.01@gmail.com"

git remote remove origin 2>/dev/null
git remote add origin "https://$USER_GITHUB:$TOKEN@github.com/$USER_GITHUB/$REPO.git"

echo "Adicionando arquivos..."
git add .

echo "Criando commit..."
git commit -m "Versão oficial 1.0.0 do AgentOS Núcleo"

echo "Enviando para GitHub..."
git push -u origin main

echo "Criando tag v1.0.0..."
git tag -a v1.0.0 -m "Primeira versão estável do AgentOS Núcleo"
git push origin v1.0.0

echo
echo "Concluído:"
echo "https://github.com/$USER_GITHUB/$REPO"
