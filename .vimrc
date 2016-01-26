set number
set tabstop=4
set shiftwidth=4
set softtabstop=4
set encoding=utf-8
set fileencoding=utf-8

" 新しいウィンドウを開く場所
set splitbelow
set splitright

syntax on

" vi との互換性OFF
set nocompatible
"カーソルを行頭，行末で止まらないようにする
set whichwrap=b,s,h,l,<,>,[,]
"BSで削除できるものを指定する
" indent  : 行頭の空白
" eol     : 改行
" start   : 挿入モード開始位置より手前の文字
set backspace=indent,eol,start

" ファイル形式の検出を無効にする
filetype off

" Vundle を初期化
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle
Bundle 'gmarik/vundle'

" Perl
Bundle 'petdance/vim-perl'
Bundle 'hotchpotch/perldoc-vim'

" 入力補完
Bundle 'Shougo/neocomplete'
Bundle 'Shougo/neosnippet'
Bundle 'c9s/perlomni.vim'

" Quick Run
Bundle 'thinca/vim-quickrun'

" Syntastic
Bundle 'tpope/vim-pathogen'
Bundle 'scrooloose/syntastic'
call pathogen#infect()

" ファイル形式検出、プラグイン、インデントを ON
filetype plugin indent on

"==========================================
"neocomplete.vim
"==========================================
"use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" 自動で補完候補を出さない
let g:neocomplete#disable_auto_complete = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '¥*ku¥*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
  \ 'perl' : $HOME.'/.vim/dict/perl.dict'
  \}
" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '¥h¥w*'

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'

"==========================================
" Snippet
"==========================================
let s:my_snippets = $HOME.'/.vim/snippets/'
let g:neosnippet#snippets_directory = s:my_snippets

"==========================================
" Syntastic
"==========================================
let g:syntastic_enable_perl_checker = 1
let g:syntastic_perl_checkers = ['perl', 'podchecker']

"==========================================
"パッケージ名の自動チェック
"==========================================
function! s:get_package_name()
  let mx = '^\s*package\s\+\([^ ;]\+\)'
  for line in getline(1, 5)
    if line =~ mx
      return substitute(matchstr(line, mx), mx, '\1', '')
    endif
  endfor
  return ""
endfunction

function! s:check_package_name()
  let path = substitute(expand('%:p'), '\\', '/', 'g')
  let name = substitute(s:get_package_name(), '::', '/', 'g') . '.pm'
  if path[-len(name):] != name
    echohl WarningMsg
    echomsg "パッケージ名と保存されているパスが異なります。"
    echohl None
  endif
endfunction

au! BufWritePost *.pm call s:check_package_name()

"==========================================
" OMNIにPERL5LIBのモジュール群を追加
"==========================================
let s:cmd = $HOME.'/.vim/bin/update_omni.pl'
exec 'silent !' . s:cmd

" Plugin key-mappings.
inoremap <expr><Nul> pumvisible() ? "\<down>" : neocomplete#start_manual_complete()
imap <expr><C-k>
  \ neosnippet#expandable() <Bar><Bar> neosnippet#jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : "\<C-n>"
" SuperTab like snippets behavior.
imap <expr><TAB>
  \ neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB>
  \ neosnippet#expandable() <Bar><bar> neosnippet#jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" 補完をキャンセルしてカーソル移動
inoremap <expr><left> neocomplete#cancel_popup() . "\<left>"

map <C-c> :SyntasticCheck<CR>
map <C-r> <plug>(quickrun)
