syntax on

" From https://vim.fandom.com/wiki/Converting_tabs_to_spaces
set tabstop=4
set shiftwidth=4
set expandtab

" https://askubuntu.com/questions/24544/what-is-the-default-vim-colorscheme
set background=dark

" From https://vi.stackexchange.com/a/2163
set backspace=indent,eol,start

" From https://superuser.com/a/365323
set ruler
" Ruler 12 characters wide showing line_number,column_number
set rulerformat=%12(%l,%v%)

" From https://csswizardry.com/2017/03/configuring-git-and-vim/
autocmd FileType gitcommit set textwidth=72 tabstop=2 shiftwidth=2
