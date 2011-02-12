"==========================================================================
" FILE:     svn.vim
" AUTHOR:   kmnk <kmnknmk+vim@gmail.com>
" Version: 0.1.0
"==========================================================================

let s:save_cpo  = &cpo
set cpo&vim

let s:ret_list  = []

function! s:str2list(str)
    return split(a:str, '\n')
endfunction

"{{{ svn/status
let s:svn_status_source = {
\   'name' : 'svn/status',
\ }

function! s:svn_status_source.gather_candidates(args, context)
    let l:status_obj    = unite#libs#svn#status#new()
    return map(l:status_obj.get_normalized_data(), '{
\       "word" : v:val.word,
\       "source" : "svn/status",
\       "kind" : "jump_list",
\       "action__path" : v:val.path,
\       "action__line" : 1,
\   }')
endfunction
"}}}

"{{{ svn/diff
let s:svn_diff_source   = {
\   'name' : 'svn/diff',
\}

function! s:svn_diff_source.gather_candidates(args, context)
    let l:obj   = unite#libs#svn#diff#new(a:args)
    let l:ret_list  = l:obj.get_normalized_data()
    if (0 == len(l:ret_list))
        return [{
\           'word'      : 'no different or some error has occured',
\           'source'    : 'svn/diff',
\           'kind'      : 'common',             
\       }]
    else
        return map(l:ret_list, '{
\           "word"          : v:val.word,
\           "source"        : "svn/diff",
\           "kind"          : "jump_list",
\           "action__path"  : v:val.path,
\           "action__line"  : v:val.line_num,
\       }')
    endif
endfunction
"}}}

function! unite#sources#svn#define()
    return [
\       s:svn_status_source,
\       s:svn_diff_source
\   ]
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
    execute '! svn blame ' . a:candidates.action__path
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
