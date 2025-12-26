# 🍏 Dotfiles - Mac & Terminal Configuration

MacOS 설정과 터미널 환경을 Git으로 관리하는 워크스페이스입니다. `GNU Stow`를 사용하여 설정 파일을 효율적으로 관리하고 동기화합니다.

## 🛠 주요 구성 요소

- **Shell**: Zsh (with Oh My Zsh)
- **Editor**: Neovim, Vim
- **Package Manager**: Homebrew (Brewfile)
- **Utility**: tmux, fd, karabiner, raycast

## 🚀 설치 및 동기화 (Integrate)

새로운 환경에서 설정을 적용하는 방법입니다.

### 1. 전제 조건

Homebrew와 GNU Stow가 설치되어 있어야 합니다.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
```

### 2. 패키지 설치

`brew/Brewfile`에 정의된 모든 패키지를 설치합니다.

```bash
cd ~/.dotfiles/brew
brew bundle install
```

### 3. 심볼릭 링크 생성 (Stow)

`stow` 명령어를 사용하여 각 디렉토리의 설정을 홈 디렉토리(`~`)로 연결합니다.

```bash
cd ~/.dotfiles
stow zsh
stow nvim
stow tmux
stow vim
stow fd
# 필요한 다른 패키지들도 동일하게 수행
```

## 💾 관리 및 백업 (Backup)

설정이 변경되었을 때 최신 상태를 유지하거나 백업하는 방법입니다.

### 1. Homebrew 패키지 목록 업데이트 (Brewfile)

새로운 패키지를 설치했거나 삭제했다면 `Brewfile`을 업데이트합니다.

**✅ Brewfile 관리 규칙:**
- **VS Code 익스텐션 제외**: 환경마다 다를 수 있는 VS Code 익스텐션은 `Brewfile`에서 관리하지 않습니다.
- **업데이트 방법**: 아래 명령어를 수행하여 VS Code 익스텐션을 제외하고 업데이트합니다.

```bash
cd ~/.dotfiles/brew
brew bundle dump --force && grep -v "^vscode" Brewfile > Brewfile.tmp && mv Brewfile.tmp Brewfile
```

### 2. 설정 파일 변경사항 반영

`stow`를 통해 연결된 파일들은 이미 `.dotfiles` 폴더 내의 파일을 가리키고 있으므로, Git으로 커밋만 하면 됩니다.

```bash
cd ~/.dotfiles
git add .
git commit -m "Update configurations: $(date +'%Y-%m-%d')"
git push
```

### 3. 새로운 설정 파일 추가하기 (Adopt)

기존에 관리되지 않던 설정 파일을 `.dotfiles`에 새로 추가하는 방법입니다.

**예시: `~/.config/zsh` 디렉토리 추가**

```bash
# 1. dotfiles 내 해당 위치에 디렉토리 구조 생성
mkdir -p ~/.dotfiles/zsh/.config/zsh

# 2. 기존 설정 파일들을 dotfiles로 복사
cp -r ~/.config/zsh/* ~/.dotfiles/zsh/.config/zsh/

# 3. 기존 파일/디렉토리 백업 후 제거 (stow 충돌 방지)
mv ~/.config/zsh ~/.config/zsh.bak

# 4. stow로 심볼릭 링크 재생성
cd ~/.dotfiles
stow zsh

# 5. 정상 연결 확인 후 백업 삭제
ls -l ~/.config/zsh  # 심볼릭 링크 확인
rm -rf ~/.config/zsh.bak

# 6. Git에 변경사항 반영
git add zsh/.config/
git commit -m "Add new config files"
git push
```

> **💡 Tip**: `stow`는 패키지 디렉토리 내의 구조를 그대로 홈 디렉토리에 미러링합니다. 따라서 `~/.config/zsh`를 관리하려면 `.dotfiles/zsh/.config/zsh` 경로에 파일을 두어야 합니다.

## 📂 디렉토리 구조

```text
.dotfiles/
├── brew/        # Homebrew 패키지 리스트 (Brewfile)
├── zsh/         # Zsh 설정 (.zshrc, .config/zsh/*, Oh My Zsh custom)
├── nvim/        # Neovim 설정 (.config/nvim)
├── tmux/        # tmux 설정
├── karabiner/   # Karabiner-Elements 설정
└── raycast/     # Raycast 설정 및 스크립트
```
