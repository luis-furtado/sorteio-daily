#!/usr/bin/env bash
set -e

# Usage: ./sorteio.sh <members_file> [state_dir]
#
# members_file  Arquivo com um participante por linha (linhas com # são ignoradas).
# state_dir     Diretório de estado (opcional). Padrão: .sorteio-state/<nome-do-arquivo>
#
# Exemplo:
#   ./sorteio.sh teams/team-plus-canais.txt
#   ./sorteio.sh teams/team-plus-ei.txt /tmp/estado-admin

MEMBERS_FILE="${1:?Informe o arquivo de participantes. Ex: ./sorteio.sh teams/team-plus-canais.txt}"

if [[ ! -f "$MEMBERS_FILE" ]]; then
  echo "Arquivo não encontrado: $MEMBERS_FILE" >&2
  exit 1
fi

# Estado isolado por time — usa o nome do arquivo como namespace
TEAM_NAME="$(basename "$MEMBERS_FILE" .txt)"
STATE_DIR="${2:-.sorteio-state/${TEAM_NAME}}"
STATE_FILE="${STATE_DIR}/remaining.txt"

mkdir -p "$STATE_DIR"

# Carrega membros ignorando comentários e linhas vazias
load_members() {
  grep -v '^\s*#' "$MEMBERS_FILE" | grep -v '^\s*$'
}

# Se não existe arquivo de estado ou está vazio, inicia nova rodada com todos os nomes
if [[ ! -s "$STATE_FILE" ]]; then
  load_members > "$STATE_FILE"
fi

# Sorteia um participante da lista de restantes
SORTEADO=$(shuf -n 1 "$STATE_FILE")

# Remove o sorteado da lista; || true evita exit code 1 quando o arquivo fica vazio
grep -v -F -x "$SORTEADO" "$STATE_FILE" > "${STATE_FILE}.tmp" || true
mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Se acabou a rodada (arquivo vazio), reinicia com todos para a próxima execução
if [[ ! -s "$STATE_FILE" ]]; then
  load_members > "$STATE_FILE"
fi

echo "$SORTEADO"
