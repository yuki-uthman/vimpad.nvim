" nvim-vimpad 
"
" Author: Yuki Yoshimine <yuki.uthman@gmail.com>
" Source: https://github.com/yuki-uthman/nvim-vimpad


if exists("g:loaded_vimpad")
  finish
endif
let g:loaded_vimpad = 1

let s:save_cpo = &cpo
set cpo&vim


" vnoremap <silent><Plug>(vimpad-run) :call vimpad#run('v')<CR>
nnoremap <silent><Plug>(vimpad-toggle) :call vimpad#toggle()<CR>
nnoremap <silent><Plug>(vimpad-on) :call vimpad#on()<CR>
nnoremap <silent><Plug>(vimpad-off) :call vimpad#off()<CR>

if !exists("g:vimpad_no_mappings") || ! g:vimpad_no_mappings
  " vmap <leader>r <Plug>(vimpad-run)
  nmap <leader>vo <Plug>(vimpad-on)
  nmap <leader>vf <Plug>(vimpad-off)
  nmap <leader>vt <Plug>(vimpad-toggle)
endif

" augroup vimpad
"     au!

"     au FocusGained * call flasher#cursor#flash()
" augroup end

let &cpo = s:save_cpo
unlet s:save_cpo
