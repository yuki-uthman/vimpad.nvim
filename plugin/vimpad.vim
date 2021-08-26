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

  let obj.style = get(g:, 'vimpad_style', 'lsp')
  let obj.style_error = get(g:, 'vimpad_style_error', 'lsp')
  let obj.space_count = get(g:, 'vimpad_add_space', 0)
  let obj.padding_count = get(g:, 'vimpad_add_padding', 0)

  if obj.style ==# 'lsp'
    let obj.prefix = get(g:, 'vimpad_prefix', '◼︎')

  elseif obj.style ==# 'custom'
    let obj.prefix = get(g:, 'vimpad_prefix', '')
    let obj.suffix = get(g:, 'vimpad_suffix', '')

  endif

  if obj.style_error ==# 'lsp'
    let obj.prefix_error = get(g:, 'vimpad_prefix_error', '✘')

  elseif obj.style_error ==# 'custom'
    let obj.prefix_error = get(g:, 'vimpad_prefix_error', '')
    let obj.suffix_error = get(g:, 'vimpad_suffix_error', '')

  endif

  return obj
endfunction "}}}

function! s:hi(group, fg, bg, attr) " {{{

  if hlexists(a:group)
    return
  endif

  " fg, bg, attr
  if a:fg != ''
    exec "hi " . a:group . " guifg=" .  a:fg
  endif
  if a:bg != ''
    exec "hi " . a:group . " guibg=" .  a:bg
  endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" .   a:attr
  endif
endfunction "}}}

function! s:setup_highlight() "{{{
  call s:hi('VimpadOutput', 'lightblue', 'bg', 'bold')
  call s:hi('VimpadOutputError', 'red', 'bg', 'bold')

endfunction "}}}

let g:vimpad = s:init_vimpad()
call s:setup_highlight()

nnoremap <silent><Plug>(vimpad-toggle)  :call vimpad#toggle()<CR>
nnoremap <silent><Plug>(vimpad-on)      :call vimpad#on()<CR>
nnoremap <silent><Plug>(vimpad-off)     :call vimpad#off()<CR>
nnoremap <silent><Plug>(vimpad-refresh) :call vimpad#refresh()<CR>
vnoremap <silent><Plug>(vimpad-execute) :<C-U>call vimpad#execute()<CR>

if exists('g:vimpad_refresh_on_save') && g:vimpad_refresh_on_save == 0

else
  augroup vimpad
      au!

      au BufWritePost *.vim call vimpad#refresh()
  augroup end
endif

let &cpo = s:save_cpo
unlet s:save_cpo
