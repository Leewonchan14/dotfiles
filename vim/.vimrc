" ============================================================================
" Vim-Plug 플러그인 관리
" ============================================================================
call plug#begin('~/.vim/plugged')

" 필수 플러그인
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " LSP 자동완성
Plug 'preservim/nerdtree'                        " 파일 탐색기
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'                          " 파일 검색
Plug 'vim-airline/vim-airline'                   " 상태바
Plug 'vim-airline/vim-airline-themes'            " 상태바 테마
Plug 'tpope/vim-fugitive'                        " Git 통합
Plug 'airblade/vim-gitgutter'                    " Git 변경사항 표시

" 편집 도구
Plug 'tpope/vim-commentary'                      " 주석 처리 (gcc)
Plug 'jiangmiao/auto-pairs'                      " 자동 괄호 닫기
Plug 'tpope/vim-surround'                        " 괄호/따옴표 편집
Plug 'mg979/vim-visual-multi'                    " 멀티 커서

" TypeScript & React
Plug 'leafgarland/typescript-vim'                " TypeScript 문법
Plug 'peitalin/vim-jsx-typescript'               " TSX 지원
Plug 'MaxMEllon/vim-jsx-pretty'                  " JSX 문법 강조

" Python & Django
Plug 'vim-python/python-syntax'                  " Python 문법 강조
Plug 'davidhalter/jedi-vim'                      " Python 자동완성 보조

" 색상 테마
Plug 'morhetz/gruvbox'                           " Gruvbox 테마
Plug 'joshdick/onedark.vim'                      " One Dark 테마

" 코드 포매팅
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

call plug#end()

" ============================================================================
" 기본 설정
" ============================================================================
set nocompatible              " Vi 호환 모드 비활성화
filetype plugin indent on     " 파일 타입 감지 및 들여쓰기
syntax on                     " 문법 강조

" 편집기 설정
set number                    " 줄 번호 표시
set relativenumber            " 상대 줄 번호
set cursorline                " 현재 줄 강조
set showcmd                   " 명령어 표시
set showmatch                 " 괄호 매칭 표시
set wildmenu                  " 명령줄 자동완성
set laststatus=2              " 상태바 항상 표시
set encoding=utf-8            " UTF-8 인코딩

" 들여쓰기 설정
set autoindent                " 자동 들여쓰기
set smartindent               " 스마트 들여쓰기
set tabstop=2                 " 탭 너비
set shiftwidth=2              " 들여쓰기 너비
set expandtab                 " 탭을 스페이스로 변환
set softtabstop=2             " 탭 입력시 스페이스 개수

" Python 파일 전용 들여쓰기 (PEP 8)
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4

" 검색 설정
set hlsearch                  " 검색 결과 강조
set incsearch                 " 점진적 검색
set ignorecase                " 대소문자 무시
set smartcase                 " 대문자 포함시 대소문자 구분

" 편집 설정
set backspace=indent,eol,start " 백스페이스 동작
set mouse=a                    " 마우스 지원
" set clipboard=unnamedplus      " 시스템 클립보드 사용
set undofile                   " 영구 undo
set undodir=~/.vim/undo        " undo 파일 디렉토리
set backup                     " 백업 생성
set backupdir=~/.vim/backup    " 백업 디렉토리
set directory=~/.vim/swap      " 스왑 파일 디렉토리

" 디렉토리 생성
silent !mkdir -p ~/.vim/undo ~/.vim/backup ~/.vim/swap

" 성능 최적화
set updatetime=300            " CursorHold 이벤트 빠르게
set timeoutlen=500            " 키 매핑 대기 시간
set hidden                    " 버퍼 숨김 허용

" ============================================================================
" 색상 테마
" ============================================================================
set termguicolors             " True color 지원
set background=dark
colorscheme gruvbox           " gruvbox 또는 onedark 사용 가능
" colorscheme onedark

" ============================================================================
" NERDTree 설정
" ============================================================================
let NERDTreeShowHidden=1      " 숨김 파일 표시
let NERDTreeMinimalUI=1       " 미니멀 UI
let NERDTreeIgnore=['\.pyc$', '__pycache__', 'node_modules', '.git']

" 단축키
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Vim 시작시 NERDTree 자동 열기 (선택사항)
" autocmd VimEnter * NERDTree | wincmd p

" ============================================================================
" FZF 설정
" ============================================================================
" 단축키
nnoremap <C-p> :Files<CR>
nnoremap <C-g> :Rg<CR>
nnoremap <C-b> :Buffers<CR>

" ============================================================================
" CoC (Conqueror of Completion) 설정
" ============================================================================
" CoC 확장 자동 설치
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-pyright',
  \ 'coc-prettier',
  \ 'coc-eslint',
  \ 'coc-snippets',
  \ ]

" Tab으로 자동완성
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Enter로 자동완성 선택
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Ctrl+Space로 자동완성 트리거
inoremap <silent><expr> <c-space> coc#refresh()

" 정의로 이동
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" K로 문서 표시
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" 심볼 이름 변경
nmap <leader>rn <Plug>(coc-rename)

" 코드 포매팅
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" 코드 액션
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" 에러 탐색
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" ============================================================================
" Airline 설정
" ============================================================================
let g:airline_theme='gruvbox'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1

" ============================================================================
" Python 문법 강조
" ============================================================================
let g:python_highlight_all = 1

" ============================================================================
" Prettier 설정
" ============================================================================
" 저장시 자동 포매팅 (선택사항)
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

" 수동 포매팅 단축키
nmap <Leader>p :Prettier<CR>

" ============================================================================
" 커스텀 단축키 " ============================================================================
let mapleader = " "           " 리더 키를 스페이스로 설정

" 파일 저장 및 종료
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" 분할 화면
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>

" 분할 화면 간 이동
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 버퍼 이동
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>
nnoremap <leader>d :bdelete<CR>

" 검색 하이라이트 끄기
nnoremap <leader>/ :nohlsearch<CR>

" 전체 선택
nnoremap <leader>a ggVG

" 빠른 ESC
inoremap jk <ESC>
inoremap kj <ESC>

" ============================================================================
" Git Fugitive 단축키
" ============================================================================
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git log<CR>

" ============================================================================
" 파일 타입별 설정
" ============================================================================
" JavaScript/TypeScript
autocmd FileType javascript,typescript,typescriptreact,javascriptreact setlocal tabstop=2 shiftwidth=2

" HTML/CSS
autocmd FileType html,css,scss setlocal tabstop=2 shiftwidth=2

" Django 템플릿
autocmd BufNewFile,BufRead *.html set filetype=htmldjango

" ============================================================================
" 자동 명령어
" ============================================================================
" 파일 열 때 마지막 커서 위치로 이동
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" 저장시 후행 공백 제거
autocmd BufWritePre * :%s/\s\+$//e

" ============================================================================
" 추가 팁
" ============================================================================
" :PlugInstall - 플러그인 설치
" :PlugUpdate  - 플러그인 업데이트
" :PlugClean   - 사용하지 않는 플러그인 제거
" :CocInstall <extension> - CoC 확장 설치
" :CocConfig   - CoC 설정 파일 열기
