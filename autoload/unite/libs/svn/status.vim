"==========================================================================
" FILE:     status.vim
" AUTHOR:   kmnk <kmnknmk+vim@gmail.com>
" Version: 0.1.0
"==========================================================================

let s:save_cpo  = &cpo
set cpo&vim

"{{{ symbol tables
let s:symbol_tables = [ 
\   {
\       ' ' : 'NoChange',
\       'A' : 'Added',
\       'C' : 'Conflicted',
\       'D' : 'Deleted',
\       'I' : 'Ignored',
\       'M' : 'Modified',
\       'R' : 'Replaced',
\       'X' : 'External',
\       '?' : '?',
\       '!' : '!',
\       '~' : '~',
\   },
\   {
\       ' ' : 'NoChange',
\       'C' : 'Conflicted',
\       'M' : 'Modified',
\   },
\   {
\       ' ' : 'NoLock',
\       'L' : 'Locked',
\   },
\   {
\       ' ' : '',
\       '+' : '+',
\   },
\   {
\       ' ' : 'NoSwitch',
\       'S' : 'Switched',
\   },
\   {
\       ' ' : '',
\       'K' : 'K',
\       'O' : 'O',
\       'T' : 'T',
\       'B' : 'B',
\   },
\   {
\       ' ' : '',
\       '*' : '*',
\   },
\]
"}}}

function! s:str2list(str)
    return split(a:str, '\n')
endfunction

function! s:get_lines()
    return s:str2list(system('svn st'))
endfunction

function! s:get_label_of(column, symbol)
    return s:symbol_tables[a:column][a:symbol]
endfunction

function! s:get_symbols_of(column)
    return keys(s:symbol_tables[a:column])
endfunction

"{{{ line pattern
function! s:line_pattern()
    let l:pattern
\       = '\m^'
\       . join(
\           map(range(0, len(s:symbol_tables) - 1), '
\               ''\([''
\             . join(s:get_symbols_of(v:val), "")
\             . '']\)''
\           '),
\           ''
\       )
\       . '\s\{}'
\       . '\(.\+\)'
\       . '$'
    return l:pattern
endfunction

function! s:is_status_line(line)
    return a:line =~ s:line_pattern()
endfunction
"}}}

function! s:get_data_list()
    return map(
\       filter(
\           s:get_lines(), '
\               s:is_status_line(v:val)
\           '
\       ), '
\           s:gen_data_by(matchlist(v:val, s:line_pattern()))
\       '
\   )
endfunction

function! s:gen_data_by(list)
    return {
\       'change'    : s:get_label_of(0, a:list[1]),
\       'path'      : a:list[8],
\   }
endfunction

function! unite#libs#svn#status#new()
    let l:obj   = {}

    function l:obj.initialize(args)
        let self.data_list  = s:get_data_list()
    endfunction

    function l:obj.get_unite_normalized_data(source)
        return map(
\           self.data_list, '{
\               "word"      : printf(
\                   "%-12s %s",
\                   "[" . v:val.change . "]", v:val.path
\               ),
\               "source"        : a:source,
\               "kind"          : "jump_list",
\               "action__path"  : v:val.path,
\               "action__line"  : 1,
\           }'
\       )
    endfunction

    return l:obj
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
