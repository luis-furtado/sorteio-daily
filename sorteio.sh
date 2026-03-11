#!/usr/bin/env bash
set -e

# Lista de participantes do sorteio
NOMES=("Carletto" "Deise" "Alex" "Luis Lenzi" "Luis Furtado" "Eder" "Leo")

# Diretório de estado (pode ser passado como 1º argumento; ideal para cache em pipeline)
STATE_DIR="${1:-.sorteio-state}"
STATE_FILE="${STATE_DIR}/remaining.txt"

mkdir -p "$STATE_DIR"

# Se não existe arquivo de estado ou está vazio, inicia nova rodada com todos os nomes
if [[ ! -s "$STATE_FILE" ]]; then
  printf "%s\n" "${NOMES[@]}" > "$STATE_FILE"
fi

# Lê restantes, sorteia um
SORTEADO=$(shuf -n 1 "$STATE_FILE")

# Remove o sorteado da lista; || true evita exit code 1 quando o arquivo fica vazio
grep -v -F -x "$SORTEADO" "$STATE_FILE" > "${STATE_FILE}.tmp" || true
mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Se acabou a rodada (arquivo vazio), reinicia com todos para a próxima execução
if [[ ! -s "$STATE_FILE" ]]; then
  printf "%s\n" "${NOMES[@]}" > "$STATE_FILE"
fi

echo "$SORTEADO"
