

function! vimpad#toggle() abort

  if !exists('s:vimpad')
    let s:vimpad = s:init_vimpad()
  endif

  if s:vimpad.id > 0
    call s:off()

  else
    call s:on()
  endif

endfunction

function! vimpad#on() abort
  echom 'vimpad turning on'

  call s:on()

endfunction

function! vimpad#off() abort
  echom 'vimpad turning off'
  call s:off()

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

function! s:build_output(output)

  exec 'highlight vimpadOuput    guifg='..s:config.fg_color 'guibg='..s:config.bg_color

  let bg_color = synIDattr(hlID("Normal"), "bg")
  exec 'highlight vimpadSurround guifg='..s:config.bg_color 'guibg='..bg_color


  exec 'highlight vimpadSurroundReverse guifg='..bg_color 'guibg='..s:config.bg_color

  let output = []

  if s:config.style ==# 'none'
    let output = [
          \[' '..a:output..' ', 'vimpadOuput'],
          \]
  elseif s:config.style ==# 'round'
    let output = [
          \["\uE0B6", 'vimpadSurround'], 
          \[a:output, 'vimpadOuput'],
          \["\uE0B4", 'vimpadSurround'], 
          \]

  elseif s:config.style ==# 'triangle-right'
    let output = [
          \["\uE0B0", 'vimpadSurroundReverse'], 
          \[' '..a:output..' ', 'vimpadOuput'],
          \["\uE0B0", 'vimpadSurround'], 
          \]


  elseif s:config.style ==# 'triangle-left'
    let output = [
          \["\uE0B2", 'vimpadSurround'], 
          \[' '..a:output..' ', 'vimpadOuput'],
          \["\uE0B2", 'vimpadSurroundReverse'], 
          \]

  elseif s:config.style ==# 'fire'
    let output = [
          \["\uE0C2", 'vimpadSurround'], 
          \[' '..a:output, 'vimpadOuput'],
          \["\uE0C0", 'vimpadSurround'], 
          \]

  elseif s:config.style ==# 'custom'
    let output = [
          \[a:output, s:config.output_hl],
          \]

    if s:conig.prefix != ''
      call insert(output, [s:config.prefix, s:config.prefix_hl])
    endif

    if s:conig.suffix != ''
      call insert(output, [s:config.suffix, s:config.suffix_hl], -1)
    endif

  endif

  if s:config.space_count
    let space = repeat(' ', s:config.space_count)
    call insert(output, [space])
  endif

  return output
endfunction

function! s:init_config() abort
  let obj = {}

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
endfunction

function! s:init_vimpad() abort
  let obj = {}

  let obj.id = 0

  return obj
endfunction

function! s:off() abort
  call nvim_buf_clear_namespace(0, s:vimpad.id, 0, -1)

  let s:vimpad.id = 0
endfunction


function! s:on()

  if !exists('s:vimpad')
    let s:vimpad = s:init_vimpad()
  endif

  if !exists('s:config')
    let s:config = s:init_config()
  endif

  if s:vimpad.id > 0
    call s:off()
  endif
  redraw
  
  " call Decho(string(s:vimpad))

  silent source %

  let lines = s:getline_as_dict(1, '$')

"  call Decho(string(lines))

  call filter(lines, function('s:to_execute'))

"  call Decho(string(lines))

  " execute the line and add output
  for line in lines
    let output = nvim_exec(line.text, 1)
    let line.output = output
  endfor

"  call Decho(string(lines))

  let s:vimpad.id = nvim_create_namespace('vimpad')

  let bufnr = 0
  for line in lines
    let output = s:build_output(line.output)
    call nvim_buf_set_virtual_text(bufnr, s:vimpad.id, line.lnum, 
          \output,
          \{})
  endfor

  " echom output
"  call Decho('')
endfunction

" [TODO](2108210154)
