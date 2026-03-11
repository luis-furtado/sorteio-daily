# sorteio-daily

Sorteio diário de nomes que roda em pipeline (GitHub Actions) e posta o resultado no Slack. Ninguém repete até todos serem sorteados; ao fim da rodada, uma nova começa automaticamente.

## Como funciona

- **Lista fixa** de participantes no script `sorteio.sh`.
- O estado (quem ainda não foi sorteado na rodada) fica em `.sorteio-state/remaining.txt`.
- A cada execução: sorteia um nome, remove da lista e imprime. Se a lista ficar vazia, reinicia com todos.
- No pipeline, o diretório `.sorteio-state` é cacheado entre execuções para manter a rodada.

## Uso local

```bash
chmod +x sorteio.sh
./sorteio.sh
```

O nome sorteado é impresso na saída. Para usar outro diretório de estado:

```bash
./sorteio.sh /caminho/para/estado
```

Para testar “do zero” (nova rodada):

```bash
rm -rf .sorteio-state
./sorteio.sh
```

## Pipeline (GitHub Actions)

- **Agendamento:** seg–sex às 12:00 UTC (09:00 BRT) — ver `.github/workflows/daily.yml`.
- **Manual:** disparo via *Actions → Daily Draw → Run workflow*.
- **Slack:** o workflow envia um POST para a URL do webhook. Configure o secret `SLACK_WEBHOOK_URL` no repositório.

Fluxo do job: checkout → restaura cache do estado → executa `sorteio.sh` → posta no Slack → salva cache do estado.

## Requisitos

- Bash
- `shuf` (GNU coreutils; já presente no Ubuntu/macOS com coreutils)
