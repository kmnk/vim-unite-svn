"==========================================================================
" FILE:     blame.vim
" AUTHOR:   kmnk <kmnknmk+vim@gmail.com>
" Version: 0.1.0
"==========================================================================

let s:save_cpo  = &cpo
set cpo&vim

function! s:str2list(str)
    return split(a:str, '\n')
endfunction

function! s:get_lines(arg)
    return s:str2list(system('LANG=en_US.utf8 svn blame ' . a:arg))
endfunction

"{{{ line pattern
function! s:line_pattern()
    return '\m^'
\        . '\s\{}\(\d\+\)'
\        . '\s\{}\([^[:space:]]\+\)'
\        . '\s\(.\{}\)$'
endfunction

function! s:is_line(line)
    return a:line   =~ s:line_pattern()
endfunction

function! s:find_element_from(line)
    let l:matches   = matchlist(a:line, s:line_pattern())
    return {
\       'revision'  : l:matches[1],
\       'user'      : l:matches[2],
\       'line'      : l:matches[3],
\   }
endfunction
"}}}

"{{{ get data
function! s:get_data(arg)
    let l:lines = s:get_lines(a:arg)
    let l:data  = {
\       'list'      : [],
\       'str_len'   : {
\           'line_num'  : 0,
\           'revision'  : 0,
\           'user'      : 0,
\       }
\   }

    for i in range(0, len(l:lines) - 1)
        if s:is_line(l:lines[i])
            let l:element   = s:find_element_from(l:lines[i])
            call add(l:data.list, l:element)
            let l:data.list[i].line_num = i + 1
            let l:data.list[i].path     = a:arg
            for key in ['revision', 'user']
                if strlen(l:data.list[i][key]) > l:data.str_len[key]
                    let l:data.str_len[key] = strlen(l:data.list[i][key])
                endif
            endfor
        endif
    endfor

    let l:data.str_len.line_num = strlen(len(l:data.list))

    return l:data
endfunction
"}}}

function! unite#libs#svn#blame#new()
    let l:obj   = {}

    function l:obj.initialize(args)
        if 0 == len(a:args)
            let l:target    = expand('%')
        else
            let l:target    = a:args[0]
        endif
        let self.data   = s:get_data(l:target)
    endfunction

    function l:obj.get_unite_normalized_data(source)
        return map(self.data.list, '{
\           "word"      : printf(
\               "% " . self.data.str_len.line_num . "s "
\             . "% " . self.data.str_len.revision . "d "
\             . "% " . self.data.str_len.user     . "s "
\             . "%s",
\               v:val.line_num,
\               v:val.revision,
\               v:val.user,
\               v:val.line,
\           ),
\           "source"        : a:source,
\           "kind"          : "jump_list",
\           "action__path"  : v:val.path,
\           "action__line"  : v:val.line_num,
\       }')
    endfunction

    return l:obj
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
