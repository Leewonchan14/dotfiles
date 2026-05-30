# 🤖 Coding Agents Configuration

이 디렉토리는 **pi** (terminal coding harness) 및 관련 에이전트 설정을 관리합니다.

pi는 [pi.dev](https://pi.dev) — 터미널 기반 AI 코딩 에이전트입니다.

## pi 설정 (stow 패키지: `pi`)

`~/.dotfiles/pi/` 아래에 pi의 사용자 설정이 들어 있습니다.  
`stow pi` 명령어로 `~/.pi/`에 심볼릭 링크됩니다.

### 구조

```
pi/.pi/
├── settings.json          # pi 전역 설정 (provider, model, theme, packages)
├── package.json           # 사용자 확장(TypeScript) 의존성
├── tsconfig.json          # 확장 컴파일 설정
├── web-search.json        # 웹 검색 워크플로 설정
└── agent/
    ├── settings.json      # 에이전트별 설정 (model override, keybindings 등)
    ├── keybindings.json   # TUI 키바인딩
    ├── mcp.json           # MCP 서버 설정
    ├── extensions/        # 커스텀 확장
    │   ├── convenience-commands.ts   # /exit, /bye, /clear 명령어
    │   ├── permission-gate.ts        # 위험 명령어 sudo/rm 승인 요청
    │   ├── analyze-image/            # 이미지 분석 확장
    │   └── pi-tool-display/          # 툴 디스플레이 확장
    └── skills/
        └── vercel-react-best-practices/  # React 성능 최적화 스킬
```

### 주요 설정

| 항목 | 값 |
|------|------|
| **Provider** | `opencode-go` |
| **Default Model** | `deepseek-v4-flash` |
| **Thinking Level** | `xhigh` |
| **Theme** | `atom-one-dark` |

### 설치된 패키지 (settings.json)

| 패키지 | 설명 |
|--------|------|
| `pi-mcp-adapter` | MCP 어댑터 |
| `pi-web-access` | 웹 접근 (브라우징, 검색) |
| `pi-image-subagent` | 이미지 분석 서브에이전트 |
| `pi-ansi-themes` | ANSI 테마 모음 |
| `pi-lsp-extension` | LSP 통합 확장 |
| `pi-community-themes` | 커뮤니티 테마 모음 |
| `pi-btw` | By The Way 유틸리티 |
| `pi-subagents` | 서브에이전트 시스템 |
| `pi-superpowers-plus` | 슈퍼파워 플러스 (plan-tracker, workflow-monitor) |
| `pi-grill-me` | Grill Me 인터뷰 모드 |
| `pi-cmux` | cmux 터미널 멀티플렉서 통합 |
| `pi-tool-display` | 툴 디스플레이 UI |
| `pi-diff-review` | Diff 리뷰 확장 |
| `pi-image-preview` | 이미지 미리보기 |

### 서브에이전트 모델 오버라이드

모든 내장 서브에이전트 (planner, scout, worker, reviewer, oracle, researcher, context-builder, delegate)는  
`opencode-go/deepseek-v4-flash` 모델을 `xhigh` thinking 레벨로 사용합니다.

### MCP 서버

| 서버 | 도구 | 연결 방식 |
|------|------|-----------|
| `chrome-devtools` | 브라우저 자동화 (29개 도구) | `npx chrome-devtools-mcp` (autoConnect) |

### 커스텀 확장

- **convenience-commands.ts** — `/exit`, `/bye` (종료), `/clear` (세션 초기화)
- **permission-gate.ts** — `rm -rf`, `sudo`, `chmod 777` 등 위험 명령어 실행 전 승인 요청

### 키바인딩

```json
{
  "tui.input.newLine": ["shift+enter", "ctrl+j"]
}
```

## 새 환경에서 복원

```bash
cd ~/.dotfiles && stow pi
cd ~/.pi && npm install
mkdir -p agent/sessions agent/npm agent/git
pi
```

> `agent/npm/`, `agent/git/`, `agent/sessions/` 디렉토리는 런타임에 자동 생성되므로 dotfiles에서 관리하지 않고 `.gitignore`에 등록되어 있습니다.
