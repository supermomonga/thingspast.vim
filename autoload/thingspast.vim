let s:save_cpo = &cpo
set cpo&vim


function! thingspast#add(identity, scope, title, message, callback, callback_args)
  let g:thingspast_things[a:identity] = get(g:thingspast_things, a:identity, {
        \   'scopes': {}
        \ })
  let g:thingspast_things[a:identity]['scopes'][a:scope] = get(g:thingspast_things[a:identity]['scopes'], a:scope, {
        \   'name': a:scope,
        \   'things': []
        \ })
  let thing = {
        \   'plugin': a:identity,
        \   'scope': a:scope,
        \   'title': a:title,
        \   'message': a:message,
        \   'callback': a:callback,
        \   'callback_args': a:callback_args,
        \   'timestamp': s:dt.now().unix_time()
        \ }
  call insert(g:thingspast_things[a:identity]['scopes'][a:scope]['things'], thing)
  call thingspast#save()
  call thingspast#draw()
  " Hooks
  for Fn in values(g:thingspast_hooks.on_add)
    call Fn(thing)
  endfor
  " Open window
  if g:thingspast_open_on_add
    call g:thingspast#open()
  endif
endfunction


function! thingspast#execute(thing)
  call filter(g:thingspast_things, 'v:val != a:thing')
  call {a:thing.callback}(a:thing.callback_args)
endfunction


function! thingspast#scopes(identity)
  return keys(get(g:thingspast_things, a:identity, {}))
endfunction


function! thingspast#things(identity, scope)
  return get(get(g:thingspast_things, a:identity, {a:scope : []}), a:scope, [])
endfunction


function! thingspast#clear()
  let g:thingspast_things = {}
endfunction


function! thingspast#save()
  call writefile(split(s:json.encode(g:thingspast_things), "\n"), g:thingspast_cache_file)
endfunction


function! thingspast#load()
  if(!filereadable(g:thingspast_cache_file))
    let g:thingspast_things = {}
  else
    let g:thingspast_things = eval(join(readfile(g:thingspast_cache_file), "\n"))
  endif
  return g:thingspast_things
endfunction


function! thingspast#things()
  return exists('g:thingspast_things') ? g:thingspast_things : thingspast#load()
endfunction


function! thingspast#open()
  call s:bm.open('thingspast')
  setlocal filetype=thingspast
  setlocal buftype=nofile
  setlocal nonumber
  setlocal ambiwidth=double
  call thingspast#draw()
endfunction


function! thingspast#close()
  call s:bm.close()
endfunction


function! thingspast#draw()
  if thingspast#is_open()
    if thingspast#move()
      setlocal modifiable
      silent % delete _
      let window_width = winwidth(0)
      let things = thingspast#things()
      for plugin in keys(things)
        for scope in keys(things[plugin]['scopes'])
          if len(things[plugin]['scopes'][scope]['things']) > 0
            silent put =repeat('_', window_width)
            silent put =' ' . thingspast#util#combine_width(
                  \   plugin . ' - ' . scope,
                  \   '[' . len(things[plugin]['scopes'][scope]['things']) . ']',
                  \   window_width - 2
                  \ )
            for thing in things[plugin]['scopes'][scope]['things']
              silent put =' ' . g:thingspast_mark_arrow . ' ' .
                    \   thingspast#util#combine_width(
                    \     thing['title'],
                    \     thingspast#util#pasttime(thing['timestamp']),
                    \     window_width - 3 - strdisplaywidth(g:thingspast_mark_arrow)
                    \   )
              silent put =thingspast#util#format(thing['message'], window_width, '...', {})
            endfor
          endif
        endfor
      endfor
      normal! gg
      call thingspast#next_thing()
      setlocal nomodifiable
    endif
  endif
endfunction


function! thingspast#prev_thing()
  call search('\V\^\s' . g:thingspast_mark_arrow, 'b')
endfunction


function! thingspast#next_thing()
  call search('\V\^\s' . g:thingspast_mark_arrow)
endfunction


function! thingspast#is_open()
  return index(tabpagebuflist(), bufnr('thingspast')) != -1
endfunction


function! thingspast#move()
  let winnr = bufwinnr(bufnr('thingspast'))
  if winnr != -1
    execute winnr . 'wincmd w'
    return 1
  else
    return 0
  endif
endfunction


function! thingspast#toggle_list()
  if thingspast#is_open() == 1
    call thingspast#close()
  else
    call thingspast#open()
  endif
endfunction


function! thingspast#things_lines()
  return map(
        \   filter(
        \     map(getline(1, "$"),
        \     '[v:key, v:val]'
        \   ),
        \   'v:val[1] =~ ''\V\^\s' . g:thingspast_mark_arrow . ''''), 'v:val[0] + 1'
        \ )
endfunction


function! thingspast#current_index()
  let current_line = line('.')
  let things_lines = thingspast#things_lines()
  let index = index(things_lines, current_line)
  return index
endfunction


function! thingspast#things_list()
  let things_list = []
  let things = thingspast#things()
  for plugin in keys(things)
    for scope in keys(things[plugin]['scopes'])
      for thing in things[plugin]['scopes'][scope]['things']
        call add(things_list, thing)
      endfor
    endfor
  endfor
  return things_list
endfunction


function! thingspast#exec_thing()
  let current_index = thingspast#current_index()
  if current_index != -1
    let current_thing = thingspast#things_list()[current_index]
    if current_thing['callback'] != ''
      let command = current_thing['callback'] . '(' . current_thing['callback_args'] . ')'
      call eval(command)
    endif
    call thingspast#delete_thing(current_thing)
  endif
endfunction


function! thingspast#nth_thing(index)
  return thingspast#things_list()[a:index]
endfunction


function! thingspast#delete_thing(thing)
  call filter(g:thingspast_things[a:thing['plugin']]['scopes'][a:thing['scope']]['things'],
        \   'v:val["timestamp"] != "' . a:thing['timestamp'] . '"'
        \ )
  call thingspast#save()
  call thingspast#draw()
endfunction


function! thingspast#default_mappings_list()
  nmap <buffer> <CR>  <Plug>(thingspast#exec_thing)
  nmap <buffer> k  <Plug>(thingspast#prev_thing)
  nmap <buffer> j  <Plug>(thingspast#next_thing)
  nmap <buffer> <C-p>  <Plug>(thingspast#prev_thing)
  nmap <buffer> <C-n>  <Plug>(thingspast#next_thing)
endfunction


" Initialize
let g:thingspast_hooks = get(g:, 'thingspast_hooks', {})
let g:thingspast_hooks.on_add = get(g:thingspast_hooks, 'on_add', {})
let g:thingspast_open_on_add = get(g:, 'thingspast_open_on_add', 1)
let g:thingspast_mark_arrow = get(g:, 'thingspast_mark_arrow', '>')
let g:thingspast_split_width = get(g:, 'thingspast_split_width', 40)
let s:vital = vital#of('thingspast')
let s:json  = s:vital.import('Web.JSON')
let s:bm    = s:vital.import('Vim.BufferManager').new()
let s:dt    = s:vital.import("DateTime")
call s:bm.config({
      \   'range' : 'tabpage',
      \   'opener' : 'botright ' . g:thingspast_split_width . 'vsplit'
      \ })
let g:thingspast_cache_file = expand(get(g:, 'thingspast_cache_file', '~/.thingspast'))
call thingspast#load()

let &cpo = s:save_cpo
unlet s:save_cpo
