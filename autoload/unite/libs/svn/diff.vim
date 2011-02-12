"==========================================================================
" FILE:     diff.vim
" AUTHOR:   kmnk <kmnknmk+vim@gmail.com>
" Version: 0.1.0
"==========================================================================

let s:save_cpo  = &cpo
set cpo&vim

function! s:str2list(str)
    return split(a:str, '\n')
endfunction

function! s:get_lines(args)
    return s:str2list(system('LANG=en_US.utf8 svn diff ' . join(a:args)))
endfunction

"{{{ index pattern
function! s:index_pattern()
    return '^Index: \(.\+\)$'
endfunction

function! s:is_index_line(line)
    return a:line =~ s:index_pattern()
endfunction

function! s:find_path_from(line)
    let l:matches   = matchlist(a:line, s:index_pattern())
    return l:matches[1]
endfunction
"}}}

"{{{ revision pettern
function! s:old_revision_pattern()
    return '^---.\+(\(revision [0-9]\+\))$\|'
\        . '^---.\+(\(working copy\))$'
endfunction

function! s:is_old_revision_line(line)
    return a:line =~ s:old_revision_pattern()
endfunction

function! s:find_old_revision_from(line)
    let l:matches   = matchlist(a:line, s:old_revision_pattern())
    if (strlen(l:matches[1]) > 0)
        return l:matches[1]
    else
        return l:matches[2]
    endif
endfunction

function! s:new_revision_pattern()
    return '^+++.\+(\(revision [0-9]\+\))$\|'
\        . '^+++.\+(\(working copy\))$'
endfunction

function! s:is_new_revision_line(line)
    return a:line =~ s:new_revision_pattern()
endfunction

function! s:find_new_revision_from(line)
    let l:matches   = matchlist(a:line, s:new_revision_pattern())
    if (strlen(l:matches[1]) > 0)
        return l:matches[1]
    else
        return l:matches[2]
    endif
endfunction
"}}}

"{{{ block pattern
function! s:block_pattern()
    return '^@@ '
\        . '-\([0-9]\+\)\(,\([0-9]\+\)\)\= '
\        . '+\([0-9]\+\)\(,\([0-9]\+\)\)\= '
\        . '@@$'
endfunction

function! s:is_block_first_line(line)
    return a:line =~ s:block_pattern()
endfunction

function! s:find_line_num_from(line)
    let l:matches   = matchlist(a:line, s:block_pattern())
    return l:matches[6]
endfunction
"}}}

"{{{ lines pattern
function! s:old_line_pattern()
    return '^-.\+$'
endfunction

function! s:is_old_line(line)
    return a:line =~ s:old_line_pattern()
endfunction

function! s:new_line_pattern()
    return '^+.\+$'
endfunction

function! s:is_new_line(line)
    return a:line =~ s:new_line_pattern()
endfunction

function! s:def_line_pattern()
    return '^[-+ ].\{}$'
endfunction

function! s:is_def_line(line)
    return a:line =~ s:def_line_pattern()
endfunction
"}}}

"{{{ get data list
function! s:get_data_list(args)
    let l:data_list = []

    for line in s:get_lines(a:args)
        if s:is_index_line(line)
            if exists('l:block')
                call add(l:file.blocks, l:block)
                unlet l:block
            endif
            if exists('l:file')
                call add(l:data_list, l:file)
            endif
            let l:file  = { 'blocks' : [] }
            let l:file.path = s:find_path_from(line)
        elseif s:is_old_revision_line(line)
            let l:file.old_revision = s:find_old_revision_from(line)
        elseif s:is_new_revision_line(line)
            let l:file.new_revision = s:find_new_revision_from(line)
        elseif s:is_block_first_line(line)
            if exists('l:block') && len(l:block.lines) > 0
                call add(l:file.blocks, l:block)
            endif
            let l:block = { 'lines'  : [] }
            let l:line_num  = s:find_line_num_from(line)
            let l:block.line_num    = l:line_num
        elseif s:is_def_line(line)
            call add(l:block.lines, {
\               'line'      : line,
\               'line_num'  : l:line_num
\           })
            if (! s:is_old_line(line))
                let l:line_num  += 1
            endif
        endif
    endfor

    if exists('l:block') && len(l:block.lines) > 0
        call add(l:file.blocks, l:block)
    endif
    if exists('l:file')
        call add(l:data_list, l:file)
    endif

    return l:data_list
endfunction
"}}}

function! s:gen_data_by(list)
    return {
\       'change'    : s:get_label_of(0, a:list[1]),
\       'lock'      : s:get_label_of(2, a:list[3]),
\       'switch'    : s:get_label_of(4, a:list[5]),
\       'path'      : a:list[8],
\   }
endfunction

function! unite#libs#svn#diff#new(args)
    let l:obj   = {}
    let l:obj.data_list = s:get_data_list(a:args)
echo l:obj.data_list

    function l:obj.get_normalized_data()
        let l:data  = []
        for file in self.data_list
            for block in file.blocks
                call add(l:data, {
\                   'word'      : '-+-+- diff of ' . file.path . ' '
\                               . '(old ' . file.old_revision . ') '
\                               . '(new ' . file.new_revision . ') ',
\                   'line_num'  : block.line_num,
\                   'path'      : file.path,
\               })
                for line in block.lines
                    call add(l:data, {
\                       'word'      : line.line,
\                       'line_num'  : line.line_num,
\                       'path'      : file.path,
\                   })
                endfor
            endfor
        endfor
        return l:data
    endfunction

    return l:obj
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
