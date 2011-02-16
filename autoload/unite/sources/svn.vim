"==========================================================================
" FILE:     svn.vim
" AUTHOR:   kmnk <kmnknmk+vim@gmail.com>
" Version: 0.1.0
"==========================================================================

let s:save_cpo  = &cpo
set cpo&vim

function! s:str2list(str)
    return split(a:str, '\n')
endfunction

let s:svn_commands  = [
\   'status',
\   'diff',
\   'blame',
\]

function! s:define_sources()
    let l:sources   = []
    for l:svn_command in s:svn_commands
        let l:source  = {
\           'svn_command'   : l:svn_command,
\           'name'          : 'svn/' . l:svn_command,
\       }
        function! l:source.gather_candidates(args, context)
            let l:obj   = unite#libs#svn#{self.svn_command}#new(a:args)
            return map(l:obj.get_unite_normalized_data(self.name), '{
\               "word"          : v:val.word,
\               "source"        : v:val.source,
\               "kind"          : v:val.kind,
\               "action__path"  : v:val.action__path,
\               "action__line"  : v:val.action__line,
\           }')
        endfunction
        call add(l:sources, l:source)
    endfor
    return l:sources
endfunction

function! unite#sources#svn#define()
    return s:define_sources()
endfunction

"{{{ kind
"{{{ svn commit
let s:svn_commit    = {
\   'description'   : 'svn commit this position',
\   'is_selectable' : 1,
\}
function! s:svn_commit.func(candidates)
    execute '! svn ci '
\         . join(map(a:candidates, 'v:val.action__path'))
    execute 'Unite svn/status'
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'commit',
\                        s:svn_commit)
call unite#custom_alias('source/svn/status/jump_list',
\                        'ci',
\                        'commit')
"}}}
"{{{ svn add
let s:svn_add  = {
\   'description'   : 'svn add this position',
\   'is_selectable' : 1,
\}
function! s:svn_add.func(candidates)
    execute '! svn add '
\             . join(map(a:candidates, 'v:val.action__path'))
    execute 'Unite svn/status'
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'add',
\                        s:svn_add)
"}}}
"{{{ svn revert
let s:svn_revert    = {
\   'description'   : 'svn revert this position',
\   'is_selectable' : 1,
\}
function! s:svn_revert.func(candidates)
    execute '! svn revert '
\             . join(map(a:candidates, 'v:val.action__path'))
    execute 'Unite svn/status'
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'revert',
\                        s:svn_revert)
"}}}
"{{{ svn blame
let s:svn_blame = {
\   'description'   : 'svn blame this position',
\   'is_selectable' : 0,
\}
function! s:svn_blame.func(candidates)
    execute 'Unite svn/blame:' . a:candidates.action__path
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'blame',
\                        s:svn_blame)
"}}}
"{{{ svn delete
let s:svn_delete  = {
\   'description'   : 'svn delete this position',
\   'is_selectable' : 1,
\}
function! s:svn_delete.func(candidates)
    execute '! svn delete '
\             . join(map(a:candidates, 'v:val.action__path'))
    execute 'Unite svn/status'
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'delete',
\                        s:svn_delete)
"}}}
"{{{ svn log
let s:svn_log   = {
\   'description'   : 'svn log this position',
\   'is_selectable' : 0,
\}
function! s:svn_log.func(candidates)
    execute '! svn log ' . a:candidates.action__path
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'log',
\                        s:svn_log)
"}}}
"{{{ svn diff
let s:svn_diff   = {
\   'description'   : 'svn diff all file on this repository',
\   'is_selectable' : 1,
\}
function! s:svn_diff.func(candidates)
    execute 'Unite svn/diff:'
\         . join(map(a:candidates, 'v:val.action__path'), ':')
endfunction
call unite#custom_action('source/svn/status/jump_list',
\                        'diff',
\                        s:svn_diff)
call unite#custom_alias('source/svn/status/jump_list',
\                        'di',
\                        'diff')
"}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
