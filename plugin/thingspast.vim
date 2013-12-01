" ThingsPast.vim
" Version: 0.0.1
" Author : supermomonga (@supermomonga)

if exists('g:loaded_thingspast')
  finish
endif
let g:loaded_thingspast = 1

let s:save_cpo = &cpo
set cpo&vim


let &cpo = s:save_cpo
unlet s:save_cpo
