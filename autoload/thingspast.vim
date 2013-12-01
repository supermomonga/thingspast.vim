let s:save_cpo = &cpo
set cpo&vim


function! thingspast#add(identity, scope, title, message, callback, callback_args)
  let g:thingspast_things[a:identity] = get(g:thingspast_things, a:identity, {
        \   'scopes': []
        \ })
  let g:thingspast_things[a:identity][a:scope] = get(g:thingspast_things[a:identity], a:scope, {
        \   'name': a:name,
        \   'things': []
        \ })
  call add(g:thingspast_things[a:identity][a:scope], {
        \   'title': a:title,
        \   'message': a:message,
        \   'callback': a:callback,
        \   'callback': a:callback_args
        \ })
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


function! thingspast#save()
  call writefile(split(g:thingspast_things, "\n"), g:thingspast_cache_file)
endfunction


function! thingspast#load()
  if(!filereadable(g:thingspast_cache_file))
    let g:thingspast_things = {}
  else
    let g:thingspast_things = eval(join(readfile(g:thingspast_cache_file), "\n"))
  endif
  return g:thingspast_things
endfunction


" Initialize
let s:vital = vital#of('thingspast')
let s:json  = s:vital.import('Web.JSON')
let g:thingspast_cache_file = expand(get(g:, 'thingspast_cache_file', '~/.thingspast'))
call thingspast#load()

let &cpo = s:save_cpo
unlet s:save_cpo
