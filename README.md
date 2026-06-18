# 🍏 Dotfiles — Mac & Terminal Configuration

macOS 설정과 개발 환경을 Git으로 관리하는 워크스페이스입니다.  
`GNU Stow`를 사용하여 설정 파일을 효율적으로 관리하고 동기화합니다.

> **Ubuntu / Linux Docker 컨테이너에서도 대부분 재현 가능합니다.**

---

## 🛠 주요 구성 요소

| 구성 | macOS | Ubuntu / Docker | 설명 |
|------|:-----:|:---------------:|------|
| **Zsh + Oh My Zsh** | ✅ | ✅ | 셸 환경 (Powerlevel10k, fzf, zoxide) |
| **Neovim + LazyVim** | ✅ | ✅ | 에디터 (Mason이 LSP 자동 설치) |
| **tmux** | ✅ | ✅ | 터미널 멀티플렉서 |
| **pi coding agent** | ✅ | ✅ | AI 코딩 에이전트 (Node.js) |
| **cmux** | ✅ | ✅ | pi 내장 터미널 멀티플렉서 |
| **fd** | ✅ | ✅ | 파일 검색 |
| **lazygit / lazydocker** | ✅ | ✅ | Git/Docker TUI |
| **mise** | ✅ | ✅ | Dev tools 버전 관리자 |
| **Bun** | ✅ | ✅ | JavaScript 런타임 |
| **VS Code** | ✅ | ✅ | (Linux는 apt로 설치) |

| **Homebrew (Brewfile)** | ✅ | ❌ | macOS 전용 패키지 매니저 |
| **Karabiner-Elements** | ✅ | ❌ | 키보드 리매퍼 (macOS 전용) |
| **Hammerspoon** | ✅ | ❌ | 창 관리자 (macOS 전용) |
| **Raycast** | ✅ | ❌ | 런처 (macOS 전용) |
| **iTerm2 / Rectangle 등** | ✅ | ❌ | macOS GUI 앱들 |

---

## 🚀 macOS 설치 가이드

### 1. 전제 조건

Homebrew와 GNU Stow가 설치되어 있어야 합니다.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
```

### 2. dotfiles 클론

```bash
git clone https://github.com/twoone14/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Homebrew 패키지 설치

Brewfile에 정의된 모든 패키지를 설치합니다.

```bash
cd ~/.dotfiles/brew
brew bundle install
```

> `brew bundle install`은 Brewfile에 정의된 모든 Homebrew formula와 cask를 한 번에 설치합니다.  
> 이미 설치된 것은 건너뛰고, 없는 것만 새로 설치합니다.

### 4. Stow로 설정 파일 적용

각 패키지 디렉토리를 `stow` 명령어로 홈 디렉토리에 심볼릭 링크합니다.

```bash
cd ~/.dotfiles

# 핵심 설정
stow zsh          # ~/.zshrc, ~/.config/zsh/*
stow nvim         # ~/.config/nvim/
stow tmux         # ~/.tmux.conf
stow vim          # ~/.vimrc
stow fd           # ~/.config/fd/

# pi coding agent
stow pi           # ~/.pi/

# macOS 전용 (없으면 스킵해도 무방)
stow karabiner    # ~/.config/karabiner/
stow hammerspoon  # ~/.hammerspoon/
stow raycast      # Raycast 설정

# 기타
stow cmux         # ~/.config/cmux/
stow vscode       # VS Code 설정
```

> **한 번에 적용하기:** `stow */` 명령어로 모든 패키지를 한 번에 적용할 수 있습니다.  
> 단, 일부 패키지가 중복 파일이 있으면 에러가 발생하므로, 최초에는 하나씩 적용하는 것을 권장합니다.

### 5. pi 설정 복원

pi는 `settings.json`에 패키지 목록이 정의되어 있어, `npm install`로 의존성을 설치하면 첫 실행 시 패키지가 자동 설치됩니다.

```bash
stow pi
cd ~/.pi && npm install
pi
```

> **💡 Note**: `agent/npm/`, `agent/git/` 디렉토리는 `pi` 실행 시 자동 생성되므로 dotfiles에서 관리하지 않습니다.  
> `agent/sessions/`도 런타임 데이터이므로 `.gitignore`에 등록되어 있습니다.

#### 현재 설치된 pi 패키지 (`agent/settings.json` 기준)

| 패키지 | 설명 | 설치 방식 |
|--------|------|-----------|
| `pi-mcp-adapter` | MCP 서버 연결 | npm |
| `pi-web-access` | 웹 검색, 브라우징 | npm |
| `pi-ansi-themes` | ANSI 테마 (leblancfg) | git |
| `pi-lsp-extension` | LSP 통합 (진단, 점프, 자동완성) | npm |
| `pi-community-themes` | 커뮤니티 테마 (hasit) | git |
| `pi-btw` | 유틸리티 | npm |
| `pi-subagents` | 서브에이전트 시스템 | npm |
| `pi-superpowers-plus` | plan-tracker, workflow-monitor (subagent 제외) | npm (선택적 확장) |
| `pi-grill-me` | 인터뷰 모드 (majorgilles) | git |
| `pi-cmux` | 터미널 멀티플렉서 | npm |
| `pi-tool-display` | 도구 사용 시각화 | npm |
| `pi-diff-review` | Diff 리뷰 | npm |
| `pi-image-preview` | 이미지 미리보기 | npm |
| `pi-vision-proxy` | 이미지 자동 설명 (비전 모델 프록시) | npm |
| `@ygncode/pi-web` | pi-web 웹 기반 UI | npm |

#### MCP 서버

| 서버 | 도구 | 방식 |
|------|------|------|
| `chrome-devtools` | 브라우저 자동화 (29개) | `npx chrome-devtools-mcp` (autoConnect, directTools) |
| `notion` | Notion API (16개) | OAuth (lazy connect, directTools) |

### 6. tmux plugin 설치

tmux를 처음 실행하면 TPM(Tmux Plugin Manager)이 설치되어 있지 않습니다.

```bash
# TPM 설치 (최초 1회)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmux 실행 후 prefix + I (대문자 I)로 플러그인 설치
tmux
# Ctrl+A, Shift+I  (plugin 설치)
```

### 7. LazyVim Neovim 설정

Neovim을 처음 실행하면 LazyVim이 자동으로 부트스트랩되고 모든 플러그인이 설치됩니다.

```bash
nvim
# 자동 설치 완료 후 :Lazy 확인
```

---

## 🐧 Ubuntu / Linux 설치 가이드

### 1. dotfiles 클론

```bash
git clone https://github.com/twoone14/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. 기본 시스템 패키지 설치

macOS의 Brewfile과 달리, Ubuntu는 `apt`로 필요한 패키지를 직접 설치합니다.

```bash
# 시스템 패키지
sudo apt update && sudo apt install -y \
    git curl wget ca-certificates \
    zsh tmux fzf \
    neovim build-essential pkg-config stow \
    fd-find ripgrep tree htop jq unzip xclip \
    fonts-powerline

# Node.js (pi 런타임)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

### 3. 추가 개발 도구 설치

```bash
# mise (dev tools version manager)
curl -fsSL https://mise.jdx.dev/install.sh | sh

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

# lazydocker
curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# gh (GitHub CLI)
sudo apt install -y gh

# Bun
curl -fsSL https://bun.sh/install | bash

# eza (modern ls replacement)
sudo apt install -y eza

# zoxide
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### 4. Oh My Zsh 설치

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 플러그인
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Powerlevel10k 테마
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 5. Stow로 설정 파일 적용

```bash
cd ~/.dotfiles

# macOS 전용 패키지(karabiner, hammerspoon, raycast)는 제외하고 적용
stow zsh nvim tmux vim fd pi cmux
```

> **⚠️ 주의**: Linux에서는 `brew/`, `karabiner/`, `hammerspoon/`, `raycast/` 패키지는 stow하지 마세요.  
> macOS 전용 절대 경로나 `.zshrc` 내 `kiro-cli`, `Antigravity` 관련 라인은 수동 제거가 필요할 수 있습니다.

### 6. macOS 전용 경로 정리 (필요시)

`.zshrc`에 macOS 전용 경로가 포함되어 있으면 제거하거나 주석 처리합니다.

```bash
# ~/.dotfiles/zsh/.zshrc 에서 아래 라인 제거 또는 주석
# [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && ...
# export PATH="/Users/twoone14/.antigravity/antigravity/bin:$PATH"
# export PATH="/Users/twoone14/.antigravity-ide/antigravity-ide/bin:$PATH"

# 제거 예시 (sed)
sed -i '/kiro-cli\|Antigravity/d' ~/.zshrc
```

### 7. pi 설정 복원

```bash
cd ~/.pi && npm install
pi
```

### 8. tmux plugin 설치

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux
# tmux 내에서 Ctrl+A, Shift+I 로 플러그인 설치
```

---

## 🐳 Docker 컨테이너 설정 가이드

Ubuntu Docker 컨테이너에서 pi coding agent를 포함한 전체 개발 환경을 실행할 수 있습니다.

### docker-compose.yml

```yaml
# ~/.dotfiles/docker/docker-compose.yml
services:
  pi-dev:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    volumes:
      - ~/.pi:/home/dev/.pi          # 기존 pi 설정 공유 (선택)
      - ~/.ssh:/home/dev/.ssh:ro     # SSH 키 공유
      - ../..:/workspace             # 작업 디렉토리 마운트
    environment:
      - OPENCODE_API_KEY=${OPENCODE_API_KEY}  # API 키 주입
    stdin_open: true
    tty: true

# 실행
docker compose -f docker/docker-compose.yml run --rm pi-dev
```

### Dockerfile 예시

`~/.dotfiles/docker/Dockerfile` — Ubuntu 24.04 베이스로 전체 환경을 빌드합니다.

> 자세한 내용은 [`docker/`](./docker/) 디렉토리를 참고하세요.

### macOS ↔ Docker 차이점

| 항목 | macOS | Docker (Ubuntu) |
|------|-------|-----------------|
| **패키지 매니저** | Homebrew (Brewfile) | apt + 수동 설치 |
| **클립보드** | `pbcopy` / `pbpaste` | `xclip` / `xsel` |
| **브라우저 MCP** | Chrome (GUI) | Headless Chrome |
| **Notion MCP** | OAuth 세션 유지 | 재인증 필요 |
| **Ollama** | 네이티브 | GPU 없으면 무의미 |
| **macOS GUI 앱** | iTerm2, Rectangle 등 | 해당 없음 |

---

## 💾 관리 및 백업 가이드

### 설정 변경 후 저장

설정 파일을 수정하면 dotfiles에 자동 반영됩니다 (심볼릭 링크).

```bash
cd ~/.dotfiles
git add -A
git commit -m "Update configurations: $(date +'%Y-%m-%d')"
git push
```

### Brewfile 업데이트 (macOS 전용)

새로운 Homebrew 패키지를 설치했다면 Brewfile을 업데이트합니다.

```bash
cd ~/.dotfiles/brew
brew bundle dump --describe --force
grep -v "^vscode" Brewfile > Brewfile.tmp && mv Brewfile.tmp Brewfile
```

> VS Code 익스텐션은 Brewfile에서 관리하지 않습니다 (환경마다 다를 수 있으므로).

### 새로운 설정 파일 추가 (Adopt)

기존에 관리되지 않던 파일을 dotfiles에 추가하는 방법:

```bash
# 예: ~/.config/kitty/ 디렉토리 추가
mkdir -p ~/.dotfiles/kitty/.config/kitty
cp -r ~/.config/kitty/* ~/.dotfiles/kitty/.config/kitty/
mv ~/.config/kitty ~/.config/kitty.bak   # 원본 백업 후 제거
cd ~/.dotfiles && stow kitty              # 심볼릭 링크 생성
ls -l ~/.config/kitty                     # 심볼릭 링크 확인
rm -rf ~/.config/kitty.bak                # 백업 삭제
git add kitty/
git commit -m "Add kitty config"
```

> **💡 Tip**: `stow`는 패키지 디렉토리 내의 경로 구조를 그대로 홈 디렉토리에 미러링합니다.  
> `~/.config/kitty/`를 관리하려면 `.dotfiles/kitty/.config/kitty/` 경로에 파일을 두어야 합니다.

### 설정 제거 (Unstow)

```bash
cd ~/.dotfiles
stow -D kitty    # 심볼릭 링크 제거 (원본 파일은 그대로)
```

---

## 📂 디렉토리 구조

```text
.dotfiles/
├── brew/         # Homebrew 패키지 리스트 (Brewfile) — macOS 전용
├── zsh/          # Zsh 설정 (.zshrc, .config/zsh/*, Oh My Zsh custom)
├── nvim/         # Neovim 설정 (.config/nvim/) — LazyVim
├── vim/          # Vim 설정 (.vimrc)
├── tmux/         # tmux 설정
├── pi/           # pi coding agent 설정 (.pi/)
├── cmux/         # cmux 설정 (.config/cmux/cmux.json)
├── fd/           # fd 설정 (.config/fd/)
├── vscode/       # VS Code 설정
│
├── karabiner/    # Karabiner-Elements 설정 — macOS 전용
├── hammerspoon/  # Hammerspoon 설정 — macOS 전용
├── raycast/      # Raycast 설정 — macOS 전용
│
├── docker/       # Dockerfile + docker-compose.yml — Ubuntu/Docker 전용
│
├── .gitignore
├── README.md     # 이 파일
└── AGENTS.md     # pi coding agent 상세 설정 문서
```

---

## 🔗 참고

- [GNU Stow](https://www.gnu.org/software/stow/) — 심볼릭 링크 매니저
- [pi.dev](https://pi.dev) — AI 코딩 에이전트
- [LazyVim](https://www.lazyvim.org/) — Neovim 배포판
- [Oh My Zsh](https://ohmyz.sh/) — Zsh 프레임워크
- [tmux TPM](https://github.com/tmux-plugins/tpm) — tmux 플러그인 매니저
- 자세한 pi 설정: [`AGENTS.md`](./AGENTS.md)
- Docker 환경 설정: [`docker/`](./docker/)
