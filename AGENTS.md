# 🤖 Coding Agents Configuration

이 디렉토리는 **pi** (terminal coding harness) 및 관련 에이전트 설정을 관리합니다.

pi는 [pi.dev](https://pi.dev) — 터미널 기반 AI 코딩 에이전트입니다.

## pi 설정 (stow 패키지: `pi`)

`~/.dotfiles/pi/` 아래에 pi의 사용자 설정이 들어 있습니다.  
`stow pi` 명령어로 `~/.pi/`에 심볼릭 링크됩니다.

### 구조

```
pi/.pi/
├── package.json           # 사용자 확장(TypeScript) 의존성 (@earendil-works/pi-coding-agent, pi-tui, typebox)
├── tsconfig.json          # 확장 컴파일 설정 (ES2022, ESNext, bundler)
├── web-search.json        # 웹 검색 워크플로 (비활성화: {"workflow": "none"})
└── agent/
    ├── settings.json      # 전역 설정 (provider, model, theme, packages, subagents)
    ├── keybindings.json   # TUI 키바인딩
    ├── mcp.json           # MCP 서버 설정
    ├── extensions/        # 커스텀 확장
    │   ├── convenience-commands.ts   # /exit, /bye, /clear 명령어
    │   ├── permission-gate.ts        # 위험 명령어 sudo/rm 승인 요청
    │   ├── pi-tool-display/          # 툴 디스플레이 확장 (config.json)
    │   └── subagent/                 # 서브에이전트 설정 (config.json)
    └── skills/
        └── vercel-react-best-practices/  # React 성능 최적화 스킬 (Vercel Engineering, Jan 2026)
```

> **참고**: `settings.json`은 `~/.dotfiles/pi/.pi/` 직하가 아닌 `agent/` 하위에 위치합니다.
> 최상위에는 `settings.json`이 존재하지 않습니다.

### 주요 설정 (`agent/settings.json`)

| 항목 | 값 |
|------|------|
| **Provider** | `opencode-go` |
| **Default Model** | `deepseek-v4-flash` |
| **Thinking Level** | `xhigh` |
| **Theme** | `atom-one-dark` |
| **개행 키바인딩** | `Shift+Enter` / `Ctrl+J` |
| **하드웨어 커서** | 활성화 (`showHardwareCursor: true`) |
| **Thinking 블록 숨김** | 활성화 (`hideThinkingBlock: true`) |
| **마지막 변경로그** | `0.78.0` |

### 설치된 패키지 (settings.json)

| 패키지 | 설명 | 설치 방식 |
|--------|------|-----------|
| `pi-mcp-adapter` | MCP 어댑터 | npm |
| `pi-web-access` | 웹 접근 (브라우징, 검색) | npm |
| `pi-ansi-themes` | ANSI 테마 모음 (leblancfg) | git |
| `pi-lsp-extension` | LSP 통합 (진단, 점프, 자동완성) | npm |
| `pi-community-themes` | 커뮤니티 테마 모음 (hasit) | git |
| `pi-btw` | By The Way 유틸리티 | npm |
| `pi-subagents` | 서브에이전트 시스템 | npm |
| `pi-superpowers-plus` | plan-tracker, workflow-monitor (subagent 제외) | npm (선택적 확장) |
| `pi-grill-me` | Grill Me 인터뷰 모드 (majorgilles) | git |
| `pi-vision-proxy` | 이미지 자동 설명 (비전 모델 프록시) | npm |
| `pi-cmux` | cmux 터미널 멀티플렉서 통합 | npm |
| `pi-tool-display` | 툴 디스플레이 UI | npm |
| `pi-diff-review` | Diff 리뷰 확장 | npm |
| `pi-image-preview` | 이미지 미리보기 | npm |
| `@ygncode/pi-web` | pi-web (웹 기반 UI) | npm |

### 서브에이전트 설정

#### config.json (`agent/extensions/subagent/config.json`)

| 항목 | 값 | 설명 |
|------|-----|------|
| `parallel.maxTasks` | `20` | 최대 동시 태스크 수 |
| `parallel.concurrency` | `12` | 동시 실행 스레드 수 |

#### 모델 오버라이드 (`settings.json` 하위 `subagents.agentOverrides`)

모든 내장 서브에이전트 (planner, scout, worker, reviewer, oracle, researcher, context-builder, delegate)는  
`opencode-go/deepseek-v4-flash` 모델을 `xhigh` thinking 레벨로 사용합니다.

| 에이전트 | 용도 | 특이사항 |
|----------|------|---------|
| `planner` | 구현 계획 수립 | |
| `scout` | 코드베이스 빠른 탐색 | `output: false` (출력 파일 생성 안 함) |
| `worker` | 실제 코드 구현 | |
| `reviewer` | 코드 리뷰 | |
| `oracle` | 조언/방향성 검토 | |
| `researcher` | 웹/문서 리서치 | `output: false` |
| `context-builder` | 컨텍스트 수집 | |
| `delegate` | 범용 위임 | |

> `pi-superpowers-plus` 패키지는 `settings.json`에서 `!extensions/subagent/index.ts`로 서브에이전트 확장을 제외하여,
> `pi-subagents`와의 중복 로딩을 방지합니다.

### MCP 서버

| 서버 | 도구 | 연결 방식 |
|------|------|-----------|
| `chrome-devtools` | 브라우저 자동화 (29개 도구) | `npx chrome-devtools-mcp` (autoConnect, directTools) |
| `notion` | Notion API (16개 도구) | OAuth (lazy connect, directTools) |

### 커스텀 확장 (`~/.pi/agent/extensions/`)

| 확장 | 설명 |
|------|------|
| **convenience-commands.ts** | `/exit`, `/bye` (종료), `/clear` (세션 초기화) |
| **permission-gate.ts** | `rm -rf`, `sudo`, `chmod 777` 등 위험 명령어 실행 전 승인 요청 |
| **pi-tool-display/** | 도구 사용 시각화 (config.json으로 상세 설정 가능) |
| **subagent/** | 서브에이전트 설정 (config.json) |

### 키바인딩 (`agent/keybindings.json`)

```json
{
  "tui.input.newLine": ["shift+enter", "ctrl+j"],
  "app.exit": [],              // 기본 종료 단축키 비활성화
  "app.model.cycleForward": [] // 모델 순환 단축키 비활성화
}
```

### 웹 검색 설정 (`web-search.json`)

```json
{
  "workflow": "none"  // 검색 큐레이터(curator) 자동 실행 비활성화
}
```

### 확장 컴파일 설정 (`tsconfig.json`)

- **Target**: ES2022
- **Module**: ESNext (bundler resolution)
- **Strict**: 활성화
- **Include**: `agent/extensions/**/*.ts`

### pi-tool-display 상세 설정

pi-tool-display는 `config.json`을 통해 세부 동작을 제어합니다:

| 항목 | 값 | 설명 |
|------|-----|------|
| `readOutputMode` | `"hidden"` | 읽기 도구 출력 숨김 |
| `searchOutputMode` | `"hidden"` | 검색 도구 출력 숨김 |
| `mcpOutputMode` | `"hidden"` | MCP 도구 출력 숨김 |
| `bashOutputMode` | `"opencode"` | bash 출력 직접 표시 |
| `previewLines` | `8` | 접힌 미리보기 최대 줄 수 |
| `diffViewMode` | `"auto"` | 자동 diff 뷰 전환 |
| `diffSplitMinWidth` | `120` | 분할 diff 최소 폭 |
| `enableNativeUserMessageBox` | `false` | 네이티브 메시지 박스 비활성화 |

## 새 환경에서 복원

```bash
cd ~/.dotfiles && stow pi
cd ~/.pi && npm install
mkdir -p agent/sessions agent/npm agent/git
pi
```

> `agent/npm/`, `agent/git/`, `agent/sessions/` 디렉토리는 런타임에 자동 생성되므로 dotfiles에서 관리하지 않고 `.gitignore`에 등록되어 있습니다.
