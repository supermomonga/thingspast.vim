" ThingsPast.vim
" Version: 0.0.1
" Author : supermomonga (@supermomonga)

if exists('g:loaded_thingspast')
  finish
endif
let g:loaded_thingspast = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <Plug>(thingspast#exec_thing)  :<C-u>call thingspast#exec_thing()<CR>
nnoremap <Plug>(thingspast#toggle_list)  :<C-u>call thingspast#toggle_list()<CR>
nnoremap <Plug>(thingspast#prev_thing)  :<C-u>call thingspast#prev_thing()<CR>
nnoremap <Plug>(thingspast#next_thing)  :<C-u>call thingspast#next_thing()<CR>

let g:thingspast_set_default_mappings = get(g:, 'thingspast_set_default_mappings', 1)
if g:thingspast_set_default_mappings
  nmap <Space>n  <Plug>(thingspast#toggle_list)
endif

let g:thingspast_set_default_mappings_list = get(g:, 'thingspast_set_default_mappings_list', 1)
if g:thingspast_set_default_mappings_list
  augroup plugin-thingspast
    autocmd!
  augroup END
  autocmd plugin-thingspast BufEnter thingspast call thingspast#default_mappings_list()
endif


let &cpo = s:save_cpo
unlet s:save_cpo
