

function! vimpad#toggle() abort
  if g:vimpad.id > 0
    call s:off()

  else
    call s:on()
  endif

endfunction

function! vimpad#on() abort
  call s:on()
endfunction

function! vimpad#off() abort
  call s:off()
endfunction

function! vimpad#refresh() abort
  if g:vimpad.id > 0
    call s:off()
    call s:on()
  endif
endfunction

function! s:get_visual_selection() "{{{
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)

    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]

    return lines
    " return join(lines, "\n")
endfunction "}}}

function! s:to_execute(index, value) "{{{
  " match a line if the line starts with echo/echom/call
  let regex = '\V\^\(echo\|echom\|call\)'

  if a:value.text =~ regex
    return 1
  else
    return 0
  endif

endfunction "}}}

function! s:getline_as_dict(start, end) "{{{
  let lines = getline(1, '$')
  let lnum = 0

  let lists = []
  for line in lines
    let obj = {}
    let obj.lnum = lnum
    let obj.text = line
    call add(lists, obj)

    let lnum += 1
  endfor

  return lists
endfunction "}}}

function! s:build_output(output) "{{{

  exec 'highlight vimpadOuput    guifg='..g:vimpad.fg_color 'guibg='..g:vimpad.bg_color

  let bg_color = synIDattr(hlID("Normal"), "bg")
  exec 'highlight vimpadSurround guifg='..g:vimpad.bg_color 'guibg='..bg_color


  exec 'highlight vimpadSurroundReverse guifg='..bg_color 'guibg='..g:vimpad.bg_color

  let output = []

  if g:vimpad.style ==# 'none'
    let output = [
          \[' '..a:output..' ', 'vimpadOuput'],
          \]
  elseif g:vimpad.style ==# 'round'
    let output = [
          \["\uE0B6", 'vimpadSurround'], 
          \[' '..a:output..' ', 'vimpadOuput'],
          \["\uE0B4", 'vimpadSurround'], 
          \]

  elseif g:vimpad.style ==# 'triangle-right'
    let output = [
          \["\uE0B0", 'vimpadSurroundReverse'], 
          \[' '..a:output..' ', 'vimpadOuput'],
          \["\uE0B0", 'vimpadSurround'], 
          \]


  elseif g:vimpad.style ==# 'triangle-left'
    let output = [
          \["\uE0B2", 'vimpadSurround'], 
          \[' '..a:output..' ', 'vimpadOuput'],
          \["\uE0B2", 'vimpadSurroundReverse'], 
          \]

  elseif g:vimpad.style ==# 'fire'
    let output = [
          \["\uE0C2", 'vimpadSurround'], 
          \[' '..a:output, 'vimpadOuput'],
          \["\uE0C0", 'vimpadSurround'], 
          \]

  elseif g:vimpad.style ==# 'custom'
    let output = [
          \[a:output, g:vimpad.output_hl],
          \]

    if s:conig.prefix != ''
      call insert(output, [g:vimpad.prefix, g:vimpad.prefix_hl])
    endif

    if s:conig.suffix != ''
      call insert(output, [g:vimpad.suffix, g:vimpad.suffix_hl], -1)
    endif

  endif

  if g:vimpad.space_count
    let space = repeat(' ', g:vimpad.space_count)
    call insert(output, [space])
  endif

  return output
endfunction "}}}

function! s:off() abort "{{{
  call nvim_buf_clear_namespace(0, g:vimpad.id, 0, -1)

  let g:vimpad.id = 0
endfunction "}}}

function! s:on() abort "{{{

  let lines = s:getline_as_dict(1, '$')

"  call Decho(string(lines))

  call filter(lines, function('s:to_execute'))

"  call Decho(string(lines))

  try
    silent source %
  catch /.*/
  endtry

  " execute the line and add output
  for line in lines
    try
      let output = nvim_exec(line.text, 1)
    catch /.*/
      let output = v:exception
    endtry
    let line.output = output
  endfor

"  call Decho(string(lines))

  let g:vimpad.id = nvim_create_namespace('vimpad')

  let bufnr = 0
  for line in lines
    let output = s:build_output(line.output)
    call nvim_buf_set_virtual_text(bufnr, g:vimpad.id, line.lnum, 
          \output,
          \{})
  endfor

  " echom output
"  call Decho('')

endfunction "}}}



" [TODO](2108210154)
