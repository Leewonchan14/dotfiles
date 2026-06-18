# 🧑‍💻 Oh My Pi Coding Agent Configuration

이 파일은 Oh My Pi의 전역 설정과 사용자 환경을 설명합니다.
Oh My Pi는 이 파일을 읽어 사용자의 환경과 선호도를 이해하고 일관된 방식으로 작업합니다.

OMP(Oh My Pi)에 대해 질문받으면 `agent/skills/omp/`의 SKILL.md와 reference/ 문서를 참고하여 답변하세요.

---

## 📋 Dotfiles 관리 (GNU Stow)

모든 셸 및 개발 환경 설정은 `~/.dotfiles/`에서 **GNU Stow**로 관리됩니다.

### 구조

```
~/.dotfiles/
├── omp/           → ~/.omp/* (개별 파일/디렉토리 단위 symlink)          (Oh My Pi, active)
├── zsh/           → ~/.zshrc, ~/.config/zsh/, ~/.oh-my-zsh/custom     (Zsh + Oh My Zsh)
├── nvim/          → ~/.config/nvim/                                    (Neovim)
├── tmux/          → ~/.config/tmux/                                    (tmux)
├── pi/            → ~/.pi/*                                            (Pi, legacy)
├── karabiner/     → ~/.config/karabiner/assets/                        (Karabiner-Elements, 일부)
├── hammerspoon/   → ~/.hammerspoon/init.lua                            (Hammerspoon, init.lua만)
├── raycast/       → ~/.config/raycast/extensions                       (Raycast 스크립트)
├── fd/            → ~/.config/fd/                                      (fd)
├── vim/           → ~/.vimrc                                           (Vim)
├── brew/          → [STOW 안 됨] ~/.dotfiles/brew/Brewfile             (Homebrew)
├── docker/        → [STOW 안 됨] ~/.dotfiles/docker/Dockerfile         (Docker)
├── vscode/        → [STOW 안 됨] ~/Library/Application Support/Code/User/ 의 일반 파일 (VS Code)
└── .pi/           → [STOW 안 됨] pi runtime state                       (런타임 상태, legacy)
```

> ⚠️ 위 화살표(`→`)는 실제 symlink 경로를 나타냅니다. `brew`, `docker`, `vscode`, `.pi` 패키지는
> stow로 관리되지 않으며, dotfiles에 파일만 보관되어 있습니다. `pi/`는 이전 버전의 stow 패키지로,
> `omp/`가 현재 활성화된 패키지입니다.

### Stow 명령어

```bash
# 설정 적용 (심볼릭 링크 생성)
cd ~/.dotfiles && stow <package>

# 설정 제거
cd ~/.dotfiles && stow -D <package>

# 모든 설정 적용
cd ~/.dotfiles && stow */
```

### Oh My Pi Stow 패키지 구조

```
~/.dotfiles/omp/.omp/
├── AGENTS.md             # 본 파일 — 에이전트 설정 문서
├── package.json          # 사용자 확장 의존성 (@oh-my-pi/pi-coding-agent, @oh-my-pi/pi-tui, typebox)
├── agent/
│   ├── config.yml        # 에이전트 설정 (provider, theme 등)
│   ├── keybindings.yml   # TUI 키바인딩
│   ├── mcp.json          # MCP 서버 설정
│   └── skills/           # 스킬 (omp, vercel-react-best-practices, web-design-engineer)
```

### Oh My Pi 패키지 symlink 상세

`~/.dotfiles/omp/`는 **stow 기본값(folding)**으로 관리됩니다. 최상위 디렉토리/파일은 개별 symlink입니다:

| 대상 | symlink 경로 |
|------|------------|
| `~/.omp/AGENTS.md` | `../.dotfiles/omp/.omp/AGENTS.md` |
| `~/.omp/package.json` | `../.dotfiles/omp/.omp/package.json` |
| `~/.omp/agent/config.yml` | `../../.dotfiles/omp/.omp/agent/config.yml` |
| `~/.omp/agent/keybindings.yml` | `../../.dotfiles/omp/.omp/agent/keybindings.yml` |
| `~/.omp/agent/mcp.json` | `../../.dotfiles/omp/.omp/agent/mcp.json` |
| `~/.omp/agent/skills/omp` | `../../../.dotfiles/omp/.omp/agent/skills/omp` |
| `~/.omp/agent/skills/vercel-react-best-practices` | `../../../.dotfiles/omp/.omp/agent/skills/vercel-react-best-practices` |
| `~/.omp/agent/skills/web-design-engineer` | `../../../.dotfiles/omp/.omp/agent/skills/web-design-engineer` |

> **참고**: 이전에 있던 `settings.json`, `web-search.json`, `keybindings.json`은 dotfiles에서 제거되어 동기화되지 않습니다. `agent/extensions/` 디렉토리 역시 더 이상 존재하지 않습니다.

> **주의**: `~/.pi/agent/npm/`, `~/.pi/agent/git/`는 레거시 Pi 런타임에서 자동 생성되며, `~/.omp/agent/sessions/`는 omp에서 자동 생성됩니다. 이들은 dotfiles에서 관리하지 않습니다.

---

## ⚙️ Oh My Pi 설정 요약

| 항목 | 값 |
|------|------|
| **Provider** | `opencode-go` |
| **Default Model** | `deepseek-v4-flash` |
| **Thinking Level** | `xhigh` |
| **Theme** | `titanium` (dark) / `light` (light) |
| **개행 키바인딩** | `Shift+Enter` / `Ctrl+J` |
| **하드웨어 커서** | 활성화 (`showHardwareCursor: true`) |
| **Thinking 블록 숨김** | 활성화 (`hideThinkingBlock: true`) |
| **Vision Model** | `kimi-k2.6` (xhigh) |
| **Slow Model** | `deepseek-v4-pro` (xhigh) |
| **Smol Model** | `deepseek-v4-flash` (xhigh) |
| **Web Search** | Exa |
| **Symbol Preset** | Nerd |

### MCP 서버 (`agent/mcp.json`)

| 서버 | 방식 | directTools | 비고 |
|------|------|-------------|------|
| `chrome-devtools` | `npx -y chrome-devtools-mcp@latest --autoConnect` | true | 브라우저 자동화 |
| `notion` | OAuth (`https://mcp.notion.com/mcp`, lifecycle: lazy) | true | Notion API |

### 키바인딩 (`agent/keybindings.yml`)

```yaml
tui.input.newLine:
  - shift+enter
  - ctrl+j
app.exit:
  []
app.model.cycleForward:
  []
```

### 웹 검색 설정

`config.yml`의 `providers.webSearch` 필드로 설정됩니다. 별도의 `web-search.json`은 더 이상 사용되지 않습니다:

```yaml
providers:
  webSearch: exa
```

---

## 🪟 tmux 환경

**Prefix**: `Ctrl+A` (기본 `Ctrl+B` 대신 Screen 스타일)
**설정 파일**: `~/.dotfiles/tmux/.config/tmux/tmux.conf` → `~/.config/tmux/` (Stow, 디렉토리 단위 symlink)

### TPM 플러그인

| 플러그인 | 용도 |
|---------|------|
| `tpm` | tmux 플러그인 매니저 (필수, 설정 마지막 줄에서 로드) |
| `tmux-sensible` | 센서블 기본값 |
| `tmux-resurrect` | 세션 저장/복원 |
| `tmux-continuum` | 자동 저장 (60초 간격) + 시작 시 자동 복원 |
| `tmux-yank` | 시스템 클립보드로 yank (`copy-pipe-no-clear`) |
| `tmux-pain-control` | pane 분할/이동 단축키 |
| `tmux-fzf` | fzf 기반 tmux UI |
| `tmux-sessionx` | fzf 세션 선택기 (`prefix + o`), zoxide 모드, git 브랜치 표시 |
| `tmux-pane-tree` | pane 트리 탐색 |
| `tmux-cpu` | CPU/RAM 사용률 표시 (status bar) |
| `catppuccin/tmux` | Catppuccin Mocha 테마 |
| `tmux-copycat` | 카피 모드 파일 URL 검색 |
| `tmux-copy-toolkit` | 카피 모드 easymotion 점프, quick-open |
| `tmux-easymotion` | 1/2글자 검색 점프 (leap.nvim 스타일, `s`/`S`) |
| `tmux-smooth-scroll` | 카피 모드 부드러운 스크롤 |

### 한글 키바인딩

한글(두벌식) 입력 모드에서도 영문 키와 동일한 tmux 조작이 가능 (`-T prefix` 테이블):

| 키 | 한글 | 기능 |
|----|------|------|
| `prefix + n` | `prefix + ㅜ` | 다음 윈도우 |
| `prefix + p` | `prefix + ㅔ` | 이전 윈도우 |
| `prefix + h` | `prefix + ㅗ` | 왼쪽 pane |
| `prefix + j` | `prefix + ㅓ` | 아래 pane |
| `prefix + k` | `prefix + ㅏ` | 위쪽 pane |
| `prefix + l` | `prefix + ㅣ` | 오른쪽 pane |

### 핵심 설정

| 설정 | 값 | 설명 |
|------|-----|------|
| prefix | `Ctrl+A` | Screen 스타일 |
| mode-keys | `vi` | 복사 모드 vi 키 |
| extended-keys | `on` | 확장 키 지원 |
| extended-keys-format | `csi-u` | 확장키 형식 |
| assume-paste-time | `0` | 붙여넣기 즉시 적용 |
| status-interval | `30` | 상태바 갱신 주기 (초) |
| 복사 선택 | `v` | vi 복사 모드에서 선택 시작 |
| 복사 실행 | `y` | 선택 영역을 `pbcopy`/`xclip`으로 복사 |

### Catppuccin 테마

| 설정 | 값 |
|------|-----|
| flavour | `mocha` |
| window 스타일 | `rounded` |
| window flags | `icon` |
| window 이름 최대 | `15`자 (초과시 …) |
| CPU 표시 | tmux-cpu 스크립트 직접 호출 |

상태바 우측: CPU → 세션명 → 날짜/시간 순서로 표시.

### 카피 모드 플러그인

| 플러그인 | 키 | 기능 |
|---------|-----|------|
| `tmux-easymotion` | `s` | 1글자 점프 |
| `tmux-easymotion` | `S` | 2글자 점프 |
| `tmux-copy-toolkit` | `prefix + C-p` 비활성화 | `C-p` 기본 동작(previous-window) 유지 |

카피 모드에서 `s`/`S`를 prefix 없이 직접 사용 가능.

### Oh My Pi 호환 키바인딩

tmux 세션 안에서 Oh My Pi의 `Alt+↓`/`Alt+↑`가 정상 동작하도록 Alt+Arrow 키를 omp-tui가
인식하는 시퀀스로 전달합니다. 현재는 `Alt+↓`만 활성화되어 있습니다.

| 키 | 시퀀스 | 기능 |
|----|--------|------|
| `Alt+↓` (M-Down) | `Escape n` | Oh My Pi 후속 메시지 (`app.message.dequeue`) |

`Alt+↑` (M-Up → `Escape p`)는 omp의 `Alt+P` (모델 선택)와 충돌하여 제거되었습니다.

해당 설정은 tmux.conf에 추가되어 있습니다:
```tmux
# Alt+↑ → omp dequeue (Alt+Up) 와 충돌하므로 제거. omp 의 Alt+P(모델선택)로 인식됨.
bind-key -n M-Down send-keys Escape n
```
> **참고**: `Escape p`/`Escape n`은 readline Emacs 모드의 history 검색 시퀀스에서 유래했습니다.
> Kitty 프로토콜이 없는 환경에서 omp-tui가 Alt+Arrow를 인식하는 방법입니다.

### 자주 사용하는 명령어

```bash
tm           # 현재 디렉토리명으로 새 세션 생성
tma          # 기존 세션에 attach
tmux new -s <name>  # 이름 지정 새 세션
```

### 복원 워크플로

1. `tmux-resurrect`가 세션 상태를 주기적으로 저장
2. `tmux-continuum`이 60초 간격 자동 저장 + 재시작 시 자동 복원
3. `tmux-sessionx`로 `prefix + o` → fzf 세션 브라우징 및 전환 (zoxide 모드, git 브랜치 표시, preview ratio 55%)
---

## 💤 LazyVim (Neovim)

**설정 파일**: `~/.dotfiles/nvim/.config/nvim/` → `~/.config/nvim/` (Stow)

**기반**: [LazyVim](https://github.com/LazyVim/LazyVim) v8 — Folke의 Neovim 배포판

### 구조

```
~/.config/nvim/
├── init.lua                    # 진입점: require("config.lazy")
├── lazy-lock.json              # 플러그인 버전 잠금
├── lazyvim.json                # LazyVim extras 설정
├── stylua.toml                 # Lua 포맷터 설정 (2 spaces, 120 width)
├── lua/
│   ├── config/
│   │   ├── lazy.lua            # lazy.nvim 부트스트랩 + 플러그인 spec
│   │   ├── options.lua         # 추가 옵션 (기본 LazyVim 사용)
│   │   ├── keymaps.lua         # 추가 키맵 (기본 LazyVim 사용)
│   │   └── autocmds.lua        # 추가 autocmd (기본 LazyVim 사용)
│   └── plugins/
│       ├── flash.lua           # Flash.nvim — 향상된 모션 (s, S, r, R, <c-space>)
│       ├── lazygit.lua         # LazyGit 통합 (<leader>lg)
│       ├── snacks.lua          # Snacks.nvim picker (hidden, ignored)
│       └── telescope.lua       # Telescope find_files에 숨김 파일 포함
```

### 활성화된 Extras

| Extra | 설명 |
|-------|------|
| `ai.supermaven` | AI 코드 완성 (Supermaven) |
| `coding.yanky` | 향상된 yank/paste (히스토리, 하이라이트) |
| `editor.dial` | 숫자 증감 (`<C-a>` / `<C-x>`) |
| `editor.inc-rename` | LSP rename 인라인 UI |
| `editor.mini-diff` | Git diff 장식 (미니) |
| `editor.telescope` | Telescope 통합 |
| `formatting.prettier` | Prettier 포맷터 |
| `lang.docker` | Dockerfile 지원 |
| `lang.json` | JSON/JSON5/JSONC (schema store 포함) |
| `lang.yaml` | YAML 지원 |
| `test.core` | Neotest (테스트 러너) |
| `util.dot` | Graphviz dot 지원 |
| `util.mini-hipatterns` | 컬러 코드 하이라이트 |

### 핵심 스택

| 영역 | 도구 |
|------|------|
| **플러그인 매니저** | `lazy.nvim` (자동 부트스트랩) |
| **컴플리션** | `blink.cmp` (LazyVim v8 기본) |
| **LSP** | `mason.nvim` + `nvim-lspconfig` + `mason-lspconfig.nvim` |
| **포맷터** | `conform.nvim` (+ Prettier extra) |
| **린터** | `nvim-lint` |
| **파일 탐색** | `telescope.nvim` + `fzf-native` |
| **파서** | `nvim-treesitter` (textobjects, autotag 포함) |
| **상태 표시줄** | `lualine.nvim` |
| **테마** | `tokyonight.nvim` (LazyVim 기본) |
| **Git** | `lazygit.nvim` + `gitsigns.nvim` |
| **알림** | `noice.nvim` + `nui.nvim` |
| **세션** | `persistence.nvim` (자동 세션 복원) |
| **Todo** | `todo-comments.nvim` |
| **버퍼라인** | `bufferline.nvim` |

### 커스텀 플러그인 설정

| 플러그인 | 키맵 / 특징 |
|----------|------------|
| **flash.nvim** | `s`=Flash jump, `S`=Treesitter Flash, `r`=Remote Flash, `R`=Treesitter Search, `<c-space>`=Treesitter Incremental Selection, `<c-s>`=Toggle Flash Search |
| **lazygit.nvim** | `<leader>lg`=LazyGit 열기 |
| **snacks.nvim** | `picker`에서 `ignored=true`, `hidden=true` |
| **telescope.nvim** | `find_files`에서 `hidden=true` (숨김 파일 포함) |

### LSP 자동 설치 (Mason)

`mason.nvim`의 `ensure_installed`에는 `stylua`, `shellcheck`, `shfmt`, `flake8`이 등록되어 있으나, LazyVim이 필요에 따라 자동 설치하므로 실질적으로는 Mason이 LSP 서버를 온디맨드로 관리합니다.

### 작업 컨벤션 관련

- **편집기**: `nvim` (기본 셸 에디터)
- **Pager**: `nvim +Man!` (man page)
- **Lua 포맷**: `stylua` (2 spaces, 120 column width)
- **Git**: `lazygit` (`<leader>lg`로 neovim 내에서 실행)

---

## 🐚 셸 환경

### Zsh + Oh My Zsh

설정 파일: `~/.config/zsh/*.zsh` (모듈식 분할)

```bash
~/.dotfiles/zsh/
├── .zshrc                # 진입점
├── .oh-my-zsh/custom/    # Oh My Zsh 커스텀 플러그인
└── .config/zsh/
    ├── brew.zsh          # Homebrew
    ├── oh-my-zsh.zsh     # Oh My Zsh 설정
    ├── conda.zsh         # Conda
    ├── libpq.zsh         # PostgreSQL
    ├── tmux.zsh          # tmux 통합
    ├── fzf.zsh           # fzf
    ├── docker.zsh        # Docker
    ├── zoxide.zsh        # zoxide (스마트 cd)
    ├── alias.zsh         # 사용자 단축키
    ├── mise.zsh          # mise (dev tools 버전 관리)
    ├── ollama.zsh        # Ollama (로컬 LLM)
    ├── bun.zsh           # Bun
```

- **Pager**: `less -R` (기본) / `nvim +Man!` (man page)
- **Editor**: `nvim` (기본 에디터)

---

## 💡 작업 컨벤션

### 명령어 실행
- **위험 명령어** (`rm -rf`, `sudo`, `chmod 777` 등): permission-gate 확장이 승인 요청

### 브라우저 자동화
- `chrome-devtools` MCP 사용 가능 (웹 페이지 분석, 스크린샷, 폼 작성)
- Notion에 이미지를 업로드할 때는 Notion MCP를 사용하지 말고, chrome-devtools로 브라우저를 직접 열어 `/image` 블록을 생성하여 업로드

### 코드 품질
- LSP 통합으로 타입 체크, 자동완성, 정의 이동 사용
- TypeScript/React 작업 시 `vercel-react-best-practices` 스킬 참조

### 작업 방식
- 복잡한 작업 전 **brainstorm / grill** 스킬로 요구사항 명확히
- **subagent** 활용: scout → planner → worker → reviewer 순서
- 테스트가 필요한 경우 **TDD** 스킬 사용
- 완료 전 **verification** 스킬로 검증

---

## 🔗 참고

- Oh My Pi 공식 문서: [omp.sh](https://omp.sh)
- GitHub 저장소: [can1357/oh-my-pi](https://github.com/can1357/oh-my-pi)
- npm 패키지: [`@oh-my-pi/pi-coding-agent`](https://www.npmjs.com/package/@oh-my-pi/pi-coding-agent)
- 커뮤니티: [Oh My Pi Discord](https://discord.gg/4NMW9cdXZa)
- 오리지널 Pi 저장소: [badlogic/pi-mono](https://github.com/badlogic/pi-mono) (by [@mariozechner](https://github.com/mariozechner))

### CLI 사용

| 명령어 | 설명 |
|--------|------|
| `omp` | 대화형 세션 시작 |
| `omp run <prompt>` | 일회성 명령 실행 |
| `omp <subcommand> --help` | 하위 명령어 도움말 |
| `/model` | 활성 모델 전환 |
| `/hotkeys` | 활성 키바인딩 목록 |

### 핵심 기능

Oh My Pi는 [Pi](https://github.com/badlogic/pi-mono)의 포크로, 다음과 같은 기능을 추가 제공합니다:
- **해시라인 에디트** — 내용 해시 기반 정밀 편집
- **서브에이전트** — 병렬 태스크 위임
- **LSP 통합** — 13개 LSP 연산 (정의 이동, rename, 참조 등)
- **DAP 디버깅** — 27개 DAP 연산 (lldb, dlv, debugpy)
- **브라우저 자동화** — Puppeteer 기반 헤드리스 브라우저
- **eval** — Python/JavaScript 영구 커널
- **Hindsight 메모리** — 세션 간 컨텍스트 유지
- **Time-traveling Stream Rules** — 실시간 규칙 주입
- **40+ Provider** — Anthropic, OpenAI, Gemini, xAI 등 지원

### 설정 파일 구조

```
~/.omp/
├── AGENTS.md                # 본 파일 — 에이전트 설정 문서 (dotfiles symlink)
├── package.json             # dotfiles symlink
├── agent/
│   ├── config.yml           # 에이전트 설정 (provider, theme 등, dotfiles symlink)
│   ├── keybindings.yml      # 키바인딩 (dotfiles symlink)
│   ├── mcp.json             # MCP 서버 설정 (dotfiles symlink)
│   ├── agent.db             # 상태 저장소 (SQLite)
│   ├── history.db           # 세션 히스토리 (SQLite)
│   ├── models.db            # 모델 캐시 (SQLite)
│   ├── blobs/               # Blob 저장소
│   ├── sessions/            # 세션 히스토리 (.jsonl)
│   ├── terminal-sessions/   # 터미널 세션 파일
│   └── skills/              # 스킬 (dotfiles symlink)
│       ├── omp/
│       ├── vercel-react-best-practices/
│       └── web-design-engineer/
├── cache/                   # GitHub 캐시
├── logs/                    # 로그 파일
├── natives/                 # 네이티브 바이너리
└── plugins/                 # 플러그인 의존성 (node_modules)
    ├── package.json
    ├── bun.lock
    └── node_modules/
```

> **참고**: `puppeteer/` 디렉토리도 가끔 생성되지만, Puppeteer가 런타임에 자동 생성하는 캐시로 무시해도 됩니다.
