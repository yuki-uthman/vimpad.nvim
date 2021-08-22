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

function! s:init_vimpad() abort "{{{
  let obj = {}

  let obj.id = 0

  let obj.style = get(g:, 'vimpad_style', 'round')
  let obj.bg_color = get(g:, 'vimpad_bg_color', 'Red')

  let obj.fg_color = get(g:, 'vimpad_fg_color', 'White')
  let obj.space_count = get(g:, 'vimpad_add_space', 0)

  " used if style is custom
  let obj.output_hl = get(g:, 'vimpad_output_hl', 'Error')
  let obj.prefix = get(g:, 'vimpad_prefix', '')
  let obj.prefix_hl = get(g:, 'vimpad_prefix_hl', 'Error')
  let obj.suffix = get(g:, 'vimpad_suffix', '')
  let obj.suffix_hl = get(g:, 'vimpad_suffix_hl', 'Error')

  return obj
endfunction "}}}

let g:vimpad = s:init_vimpad()

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

augroup vimpad
    au!

    au BufWritePost *.vim call vimpad#refresh()
augroup end

let &cpo = s:save_cpo
unlet s:save_cpo
