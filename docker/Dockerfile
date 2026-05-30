# syntax=docker/dockerfile:1
FROM ubuntu:24.04

LABEL description="pi coding agent development environment"
LABEL maintainer="twoone14"

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/zsh
ENV EDITOR=nvim
ENV PAGER='less -R'
ENV MANPAGER='nvim +Man!'

# ============================================================
# 1. 기본 시스템 패키지
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 필수
    git curl wget ca-certificates gnupg lsb-release \
    # 셸
    zsh tmux fzf \
    # 개발 도구
    neovim build-essential pkg-config stow \
    # 유틸리티
    fd-find ripgrep tree htop jq unzip xclip \
    # 런타임 의존성
    libfuse2 libxi6 libxtst6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# 2. Node.js (pi 런타임)
# ============================================================
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && corepack enable \
    && npm install -g npm@latest

# ============================================================
# 3. pi coding agent 설치
# ============================================================
# https://pi.dev/docs/installation
RUN npm install -g @earendil-works/pi-coding-agent@latest

# pi 설정 디렉토리 (dotfiles에서 overlay)
RUN mkdir -p /home/dev/.pi/agent/{extensions,skills,sessions,npm,git}
RUN mkdir -p /home/dev/.config

# ============================================================
# 4. 추가 개발 도구
# ============================================================
# mise (dev tools version manager)
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh

# lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin \
    && rm lazygit.tar.gz lazygit

# lazydocker
RUN curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# gh (GitHub CLI)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh

# Bun
RUN curl -fsSL https://bun.sh/install | bash

# eza (modern ls)
RUN curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    && apt-get update && apt-get install -y eza

# zoxide
RUN curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# ============================================================
# 5. Oh My Zsh
# ============================================================
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# ============================================================
# 6. Chrome DevTools MCP 의존성 (headless Chrome)
# ============================================================
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# 7. 사용자 설정
# ============================================================
RUN useradd -m -s /bin/zsh dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /workspace

# dotfiles를 clone하고 stow로 적용하는 entrypoint
COPY --chown=dev:dev entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER dev
ENV HOME=/home/dev

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/zsh"]
