set tabstop=4 shiftwidth=4 expandtab
syntax on
filetype indent on
set ruler
set number
set background=dark

"highlight SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
highlight SpellErrors term=reverse cterm=reverse
let spell_auto_type = "tex,mail,text,html,tmpl,sgml,otl,cvs,none,txt"


""" Return to last position in file
if has("autocmd")
  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.txt set tw=78
  autocmd BufRead *.rb set ts=2 sw=2
  autocmd BufRead /tmp/mutt-* set tw=78
  autocmd BufRead *.0 set tw=78
  " tmpl files are usually html
  autocmd BufRead *.tmpl set filetype=html
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line ("'\"") <= line("$") |
        \   exe "normal g'\"" |
        \ endif
endif


""" Insert date on meta-date
command Insdate :read !date +\%Y\%m\%d\ \%H:\%M:\%S<CR>


""" GPG stuff
set backupskip+=*.gpg

function! s:gpg_decrypt()
  " Decrypt the file, prompting for the passphrase.
  :%!gpg --decrypt 2>&1
  set nobin
endfunction

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff
augroup encrypted
  au!
  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
  " We don't want a swap file, as it writes unencrypted data to disk
  autocmd BufReadPre,FileReadPre      *.gpg setlocal noswapfile bin
  " Decrypt the contents after reading the file, reset binary file format
  " and run any BufReadPost autocmds matching the file name without the .gpg
  " extension
  "\ execute "'[,']!gpg --decrypt --default-recipient-self" |
  autocmd BufReadPost,FileReadPost *.gpg call s:gpg_decrypt()
  "\ execute "'[,']!gpg -d" |
  "\ setlocal nobin |
  "\ execute "doautocmd BufReadPost " . expand("%:r")

  " Set binary file format and encrypt the contents before writing the file
  autocmd BufWritePre,FileWritePre *.gpg
        \ setlocal bin |
        \ '[,']!gpg -c
  "\ '[,']!gpg --encrypt --default-recipient-self
  " After writing the file, do an :undo to revert the encryption in the
  " buffer, and reset binary file format
  autocmd BufWritePost,FileWritePost *.gpg
        \ silent u |
        \ setlocal nobin

  "    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
  "    autocmd BufReadPre,FileReadPre      *.gpg let shsave=&sh
  "    autocmd BufReadPre,FileReadPre      *.gpg let &sh='sh'
  "    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
  "    "autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt --default-recipient-self 2> /dev/null
  "    autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg -d 2> /dev/null
  "    autocmd BufReadPost,FileReadPost    *.gpg let &sh=shsave
  "    " Switch to normal mode for editing
  "    autocmd BufReadPost,FileReadPost    *.gpg set nobin
  "    autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|unlet ch_save
  "    autocmd BufReadPost,FileReadPost    *.gpg execute ":doautocmd BufReadPost " . expand("%:r")
  "    " Convert all text to encrypted text before writing
  "    autocmd BufWritePre,FileWritePre    *.gpg set bin
  "    autocmd BufWritePre,FileWritePre    *.gpg let shsave=&sh
  "    autocmd BufWritePre,FileWritePre    *.gpg let &sh='sh'
  "    "autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg --encrypt --default-recipient-self 2>/dev/null
  "    autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg -c 2>/dev/null
  "    autocmd BufWritePre,FileWritePre    *.gpg let &sh=shsave
  "    " Undo the encryption so we are back in the normal text, directly
  "    " after the file has been written.
  "    autocmd BufWritePost,FileWritePost  *.gpg silent u
  "    autocmd BufWritePost,FileWritePost  *.gpg set nobin
augroup END

