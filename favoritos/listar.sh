#!/data/data/com.termux/files/usr/bin/bash

clear
echo "=========================================="
echo "      Favoritos AgentOS"
echo "=========================================="

if [ ! -f repositorios.csv ]; then
    echo "Nenhum favorito cadastrado."
    exit
fi

column -s, -t < repositorios.csv
