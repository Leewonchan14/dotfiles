# Installation & Authentication

---

## Install Methods

| Method | Command | Best for |
|---|---|---|
| Bun | `bun install -g @oh-my-pi/pi-coding-agent` | Already have Bun >= 1.3.14 |
| Installer script | `curl -fsSL https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh \| sh` | Anything else |
| mise | `mise use -g github:can1357/oh-my-pi` | Per-project version pinning |

The installer accepts `--source` (force Bun), `--binary` (force prebuilt), and `--ref <tag|branch|commit>` for pinning. Set `PI_INSTALL_DIR` to override install directory.

### Windows

```powershell
irm https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.ps1 | iex
```

### Verify

```bash
omp --version           # binary version on PATH
omp config path         # active agent dir (contains config.yml)
omp -p 'hello'          # round-trip a one-shot prompt
```

---

## Terminal Setup

omp uses the Kitty keyboard protocol. Kitty and iTerm2 work out of the box.

### Ghostty

```ini
# ~/.config/ghostty/config
keybind = alt+backspace=text:\x1b\x7f
keybind = shift+enter=text:\n
```

### wezterm

```lua
config.enable_kitty_keyboard = true
```

### Windows Terminal

Does not implement the protocol. Use `Ctrl+Enter` for newline instead of `Shift+Enter`.

---

## Authentication

### Three Ways to Authenticate

| Method | When to use | Example |
|---|---|---|
| Environment variable | Scripts, CI, first-run smoke tests | `ANTHROPIC_API_KEY=sk-ant-... omp` |
| `/login` | Interactive OAuth flow or key prompt | `/login anthropic` |
| config.yml / models.yml | Declarative pin per provider | `apiKey: MYCO_API_KEY` |

`/login` appends credentials (never overwrites). `/logout <provider>` clears them.

### OAuth-Capable Providers

| Provider | `/login` ID | Notes |
|---|---|---|
| Anthropic (Pro / Max) | `anthropic` | Browser flow against console.anthropic.com |
| OpenAI Codex | `openai` | ChatGPT account flow; usage-aware rotation |
| GitHub Copilot | `github-copilot` | Device-code flow; full Copilot catalog auto-enables |
| Gemini CLI | `gemini` | Google account flow |
| Z.AI | `zai` | Key-paste only |
| Cursor | `cursor` | Browser flow against cursor.com |

### Resolution Order

1. `--api-key` runtime override on the omp process
2. Stored API key in `agent.db` (round-robins when multiple keys for same provider)
3. Stored OAuth credential in `agent.db` (refreshed on demand)
4. Provider env var (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, etc.)
5. `apiKey` field in `models.yml`

When both API key and OAuth credential exist, API key wins. Set `ANTHROPIC_OAUTH_TOKEN` to force OAuth precedence.

### Remote Credential Vault (Auth Broker)

Multi-machine credential sharing:

```bash
# Server
omp auth-broker serve --bind 127.0.0.1:7700
omp auth-broker token issue --label laptop
omp auth-broker import --from-local

# Client
export OMP_AUTH_BROKER_URL=http://broker:7700
export OMP_AUTH_BROKER_TOKEN=bt_...
```

In broker mode, `/login`, `/logout`, and OAuth refresh all proxy through the remote vault. Client keeps a 5 min per-credential usage cache with jitter and a last-known-good fallback.

### Switching Providers Mid-Session

```bash
/model                    # model picker scoped to signed-in providers
/model openai/gpt-5.3-codex:high
omp --provider openai --model gpt-5.3-codex:high   # per-run override
```
