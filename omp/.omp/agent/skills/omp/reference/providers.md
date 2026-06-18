# Providers & Authentication

---

## Three Ways to Authenticate

| Method | When to use | Example |
|---|---|---|
| Environment variable | Scripts, CI, first-run smoke tests | `ANTHROPIC_API_KEY=sk-ant-... omp` |
| `/login` | Interactive. Walks OAuth flow or prompts for key. | `/login anthropic` |
| config.yml / models.yml | Declarative. Pin a key (or env var name) per provider. | `apiKey: MYCO_API_KEY` |

`/login` appends credentials (never overwrites). `/logout <provider>` clears them. Everything stored in `~/.omp/agent/agent.db` — back that file up when migrating machines.

---

## OAuth-Capable Providers

These providers support browser-based sign-in instead of pasting a raw key.

| Provider | `/login` ID | Notes |
|---|---|---|
| Anthropic (Pro / Max) | `anthropic` | Browser flow against console.anthropic.com. Falls back to key prompt if you cancel. |
| OpenAI Codex | `openai` | ChatGPT account flow. Usage-aware rotation skips keys near 5h or weekly cap. |
| GitHub Copilot | `github-copilot` | Device-code flow against github.com or Enterprise host. Full Copilot catalog auto-enables. |
| Gemini CLI | `gemini` | Google account flow; uses same credential as the `gemini` CLI. |
| Z.AI | `zai` | Key-paste only (no browser flow). `/login zai` is the supported entry point. |
| Cursor | `cursor` | Browser flow against cursor.com. |

Every other provider authenticates with an API key via its `*_API_KEY` env var or `/login` (which prompts for the key).

---

## Credential Resolution Order

When omp needs a credential for a provider, it walks this list and returns the first hit:

1. `--api-key` runtime override on the omp process
2. Stored API key in `agent.db` (round-robins when multiple keys for same provider)
3. Stored OAuth credential in `agent.db` (refreshed on demand before each call)
4. Provider env var (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `ZAI_API_KEY`, …)
5. `apiKey` field in `models.yml` (checked as env-var name first, then literal token)

When both an API key and OAuth credential exist for the same provider, the API key wins. Set `ANTHROPIC_OAUTH_TOKEN` explicitly to force OAuth precedence.

---

## Model Switching

```bash
/model                    # opens model picker scoped to signed-in providers
/model openai/gpt-5.3-codex:high   # set directly
omp --provider openai --model gpt-5.3-codex:high   # per-run override
```

Switching does not log out the previous provider. See `skill://omp/reference/configuration.md` for persistent model role configuration.

---

## Remote Credential Vault (Auth Broker)

Multi-machine setups share one credential set:

```bash
# Server (run once)
omp auth-broker serve --bind 127.0.0.1:7700
omp auth-broker token issue --label laptop
omp auth-broker import --from-local

# Client (every machine)
export OMP_AUTH_BROKER_URL=http://broker:7700
export OMP_AUTH_BROKER_TOKEN=bt_...
```

In broker mode, `/login`, `/logout`, and OAuth refresh proxy through the remote vault. Local `agent.db` stays empty. Client keeps a 5 min per-credential usage cache with jitter and a last-known-good fallback.

### Auth Gateway

Pair the broker with `omp auth-gateway serve` — a forward-proxy that injects broker-resolved credentials into OpenAI Chat, Anthropic Messages, and OpenAI Responses requests. Point clients at the gateway's base URL with a bearer token.
