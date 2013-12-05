
let s:V = vital#of('thingspast')
let s:D = s:V.import('DateTime')

function! thingspast#util#format(text, width, ellipsis, style)
  let default_style = {
        \   'padding' : [0,1,0,3],
        \   'padding_fill' : ['','','',' '],
        \ }
  let style = extend(default_style, a:style)
  let horizontal_padding = style.padding[1] + style.padding[3]
  let vertical_padding = style.padding[0] + style.padding[1]

  let text_max_width = a:width - horizontal_padding

  let truncated_text = thingspast#util#truncate(a:text, text_max_width, a:ellipsis)

  let text = repeat(style.padding_fill[3], style.padding[3])
        \ . truncated_text
        \ . repeat(style.padding_fill[1], style.padding[1])

  return text
endfunction

function! thingspast#util#truncate(text, max_width, ellipsis)
  let ellipsis_width = strdisplaywidth(a:ellipsis)
  let text_width = strdisplaywidth(a:text)
  if text_width > a:max_width
    let truncated = s:V.strwidthpart(a:text, a:max_width - ellipsis_width)
    " for double width string
    if strdisplaywidth(truncated) != a:max_width - ellipsis_width
      let truncated .= ' '
    endif
    return truncated . a:ellipsis
  else
    return a:text
  endif
endfunction

function! thingspast#util#fill(text, width, fill_chr)
  let text_width = strdisplaywidth(a:text)
  return a:text . repeat(a:fill_chr, a:width - text_width)
endfunction

function! thingspast#util#combine_width(l, r, width)
  let text_width = strdisplaywidth(a:l . a:r)
  let l_truncated = thingspast#util#truncate(a:l, a:width - strdisplaywidth(a:r) - 1, '...')
  return l_truncated . repeat(' ', a:width - strdisplaywidth(l_truncated . a:r)) . a:r
endfunction

function! thingspast#util#pasttime(timestamp)
  let now = s:D.now().unix_time()
  let past = now - a:timestamp
  if past < 60
    return 'now'
  elseif past < 3600
    let vol = past / 60
    return vol . (vol > 1 ? ' minutes' : ' minute')
  elseif past < 86400
    let vol = past / 3600
    return vol . (vol > 1 ? ' hours' : ' hour')
  else
    let vol = past / 86400
    return vol . (vol > 1 ? ' days' : ' day')
  endif
endfunction
