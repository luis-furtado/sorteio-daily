# sorteio-daily

Sorteio diário de nomes que roda em pipeline (GitHub Actions) e posta o resultado no Slack de cada time. Ninguém repete até todos serem sorteados; ao fim da rodada, uma nova começa automaticamente.

## Estrutura

```
sorteio-daily/
├── .github/workflows/daily.yml   # Workflow com um job por time
├── teams/
│   ├── team-plus-canais.txt              # Participantes do time LMS
│   └── team-plus-ei.txt            # Participantes do time Admin
└── sorteio.sh                    # Script genérico de sorteio
```

## Como funciona

- **Participantes** ficam em arquivos `.txt` dentro de `teams/`, um nome por linha. Linhas com `#` são comentários e ignoradas.
- O estado de cada time (quem ainda não foi sorteado na rodada) fica em `.sorteio-state/<time>/remaining.txt`.
- A cada execução: sorteia um nome, remove da lista e imprime. Se a lista ficar vazia, reinicia com todos.
- No pipeline, o estado de cada time é cacheado de forma isolada entre execuções.

## Gerenciando times

Para adicionar ou remover participantes, edite o arquivo correspondente em `teams/`:

```
# teams/team-plus-canais.txt
Carletto
Deise
Alex
...
```

Para adicionar um terceiro time, crie `teams/team-novo.txt` e adicione um novo job em `.github/workflows/daily.yml` seguindo o mesmo padrão dos jobs existentes.

## Uso local

```bash
chmod +x sorteio.sh

# Sortear do time LMS
./sorteio.sh teams/team-plus-canais.txt

# Sortear do time Admin
./sorteio.sh teams/team-plus-ei.txt
```

Para testar do zero (nova rodada de um time):

```bash
rm -rf .sorteio-state/team-plus-canais
./sorteio.sh teams/team-plus-canais.txt
```

## Pipeline (GitHub Actions)

- **Agendamento:** seg–sex às 12:00 UTC (09:00 BRT) — ver `.github/workflows/daily.yml`.
- **Manual:** disparo via *Actions → Daily Draw → Run workflow*.
- **Jobs paralelos:** cada time roda de forma independente com seu próprio cache e webhook.

### Secrets necessários

Configure os secrets no repositório (*Settings → Secrets and variables → Actions*):

| Secret                    | Descrição                          |
|---------------------------|------------------------------------|
| `SLACK_WEBHOOK_URL_LMS`   | Webhook do canal Slack do time LMS |
| `SLACK_WEBHOOK_URL_ADMIN` | Webhook do canal Slack do time Admin |

> O antigo secret `SLACK_WEBHOOK_URL` não é mais utilizado e pode ser removido.

## Requisitos

- Bash
- `shuf` (GNU coreutils; já presente no Ubuntu/macOS com coreutils)
