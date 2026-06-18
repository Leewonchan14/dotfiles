# Configuration & CLI

---

## Config File: `~/.omp/agent/config.yml`

Persistent settings in a plain YAML tree. Missing keys fall through to built-in defaults.

### Edit Methods

| Method | Command |
|---|---|
| In-session menu | `/settings` |
| Shell commands | `omp config <action>` |
| Text editor | Edit file directly (validated on next load) |

```bash
omp config list                          # full tree
omp config get modelRoles.default        # one key
omp config set theme.dark catppuccin-macchiato
omp config reset theme.dark              # back to schema default
omp config path                          # print active config.yml path
```

### Precedence (highest → lowest)

1. CLI flag (`--slow`, `--no-pty`, `--api-key`, …)
2. Environment variable (`PI_SLOW_MODEL`, `ANTHROPIC_API_KEY`, …)
3. `~/.omp/agent/config.yml`
4. Built-in default

Override config directory: `PI_CODING_AGENT_DIR` overrides parent directory; `PI_CONFIG_DIR` renames config root.

---

## Top-Level Config Keys

| Key | What it controls |
|---|---|
| `theme` | Terminal palette (`theme.dark` / `theme.light` names a built-in or user palette) |
| `modelRoles` | Role → model map (default, smol, slow, plan, commit) |
| `steeringMode` | How queued steering messages drain: `one-at-a-time` (default) or `all` |
| `followUpMode` | How queued follow-ups drain: `one-at-a-time` (default) or `all` |
| `interruptMode` | `immediate` (default) or `wait` |
| `tools.discoveryMode` | Whether on-disk tools auto-register or require explicit allow-list |
| `debug.enabled` | Surfaces debug tool and DAP-backed flows. Off by default. |
| `extensions` | Explicit extension paths picked up beyond auto-discovery |
| `skills` | Per-skill enable/disable map |
| `images.autoResize` | Auto-shrink attached images before send. On by default. |
| `searxng` | Self-hosted web-search endpoint config |
| `hindsight.*` | Hindsight memory bank connection |
| `memory.backend` | Memory backend: `off` (default), `local`, `hindsight` |

---

## Common Config Examples

### Model Roles

```yaml
modelRoles:
  default: anthropic/claude-sonnet-4-5
  smol:    anthropic/claude-haiku-4-5
  slow:    anthropic/claude-opus-4-6:high
  plan:    openai/gpt-5.3-codex:high
  commit:  anthropic/claude-haiku-4-5
```

The commit role drives the `/commit` pipeline. Bump to stronger model when commit messages drift.

### Message Queue

```yaml
steeringMode:  one-at-a-time   # or: all
followUpMode:  one-at-a-time   # or: all
interruptMode: immediate       # or: wait
```

### Debug Tool

```yaml
debug:
  enabled: true
```

### Theme

```yaml
theme:
  dark:  catppuccin-macchiato
  light: solarized-light
```

> A malformed `config.yml` blocks startup. Always validate with `omp config list` after a manual edit.

---

## Keybinding Remaps

Separate file at `~/.omp/agent/keybindings.json` (not in config.yml):

```json
{
  "app.model.cycleForward": "ctrl+p",
  "app.plan.toggle": "alt+shift+p",
  "app.clipboard.copyPrompt": ["alt+shift+c", "ctrl+shift+c"]
}
```

Action IDs are namespaced (e.g. `app.model.cycleForward`, `tui.editor.undo`, `app.plan.toggle`). Run `/hotkeys` for the full list. Legacy short names are auto-migrated on load.

---

## CLI Reference

### Session Flags

| Flag | What it does |
|---|---|
| `-p "prompt"` / `--print` | One-shot prompt, plain text output |
| `-c` | Continue most recent session in cwd |
| `-r [prefix]` | Resume session by id prefix |
| `--fork <id\|path>` | Resume into new file, leave original untouched |
| `--no-session` | Ephemeral (nothing on disk) |
| `--export <session.jsonl> [output]` | Batch-render session to HTML |

### Mode Flags

| Flag | What it does |
|---|---|
| `--mode json` | NDJSON output for piping |
| `--mode rpc` | JSON-RPC over stdio for SDK/clients |
| `--mode acp` | Agent Client Protocol for editors |

### Model Flags

| Flag | What it does |
|---|---|
| `--plan <model-id>` | Override plan role model per-run |
| `--slow <model-id>` | Override slow role model |
| `--provider <name>` | Bind a single provider |
| `--model <id>` | Set model for this run |
| `--list-models` | List available models per role |

### Skill Flags

| Flag | What it does |
|---|---|
| `--skills <p1,p2,…>` | Comma-separated glob patterns; only matching skills kept |
| `--no-skills` | Disable skill discovery entirely for this run |

### Config Flags

| Flag | What it does |
|---|---|
| `config list` | Print full config tree |
| `config get <key>` | Get one value |
| `config set <key> <value>` | Set a key |
| `config reset <key>` | Reset to schema default |
| `config path` | Print active config.yml path |

---

## Environment Variables

### Provider API Keys

| Variable | Provider |
|---|---|
| `ANTHROPIC_API_KEY` | Anthropic |
| `OPENAI_API_KEY` | OpenAI |
| `GEMINI_API_KEY` | Google Gemini |
| `XAI_API_KEY` | xAI |
| `GROQ_API_KEY` | Groq |
| `MISTRAL_API_KEY` | Mistral |
| `OPENROUTER_API_KEY` | OpenRouter |
| `ZAI_API_KEY` | Z.AI |

### omp Configuration

| Variable | What it sets |
|---|---|
| `PI_SLOW_MODEL` | Default slow-priority model |
| `PI_PLAN_MODEL` | Plan role model |
| `PI_CODING_AGENT_DIR` | Override `~/.omp/agent/` |
| `PI_CONFIG_DIR` | Override config root directory |
| `PI_INSTALL_DIR` | Install directory override |
| `ANTHROPIC_OAUTH_TOKEN` | Force OAuth precedence for Anthropic |
| `OMP_AUTH_BROKER_URL` | Remote credential vault URL |
| `OMP_AUTH_BROKER_TOKEN` | Remote credential vault token |
