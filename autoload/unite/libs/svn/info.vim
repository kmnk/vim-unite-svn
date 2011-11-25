"=============================================================================
" FILE:     info.vim
" AUTHOR:   kmnk    <kmnknmk+vim@gmail.com>
" Version:  0.1.0
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

" local functions {{{
function! s:get_lines(path)"{{{
  return split(system('LANG=en_US.utf8 svn info ' . a:path), '\n')
endfunction"}}}

function! s:get_data(path)"{{{
  let l:lines = s:get_lines(a:path)

  let l:data = []
  for l:line in l:lines
    let l:pairs = s:get_pairs(l:line)
    if len(l:pairs) > 0
      call add(l:data,
\              { 'word'  : l:pairs[1],
\                'title' : l:pairs[0] })
    endif
  endfor
  return l:data
endfunction"}}}

function! s:get_pairs(line)"{{{
  let l:matchedlist = matchlist(a:line, '^\(.\+\): \(.\+\)$')
  return l:matchedlist[1:2]
endfunction
"}}}

function! unite#libs#svn#info#new()"{{{
  let l:obj = {}

  function l:obj.initialize(params)
    if 0 == len(a:params)
      let l:target = expand('%')
    else
      let l:target = a:params[0]
    endif
    let self.data = s:get_data(l:target)
  endfunction

  function l:obj.get_unite_normalized_data(source)
    return map(self.data, '{
\     "word" : v:val.title . " : " . v:val.word,
\     "source" : a:source,
\     "description" : v:val.title,
\     "kind" : "completion",
\     "action__path"  : "",
\     "action__line"  : "",
\   }')
  endfunction

  return l:obj

endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker :
