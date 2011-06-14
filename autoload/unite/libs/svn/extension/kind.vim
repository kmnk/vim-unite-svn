"==========================================================================
" FILE:     kind.vim
" AUTHOR:   kmnk    <kmnknmk+vim@gmail.com>
" Version:  0.1.0
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>
"==========================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:extension_list    = []

let s:svn_commit    = {
\   'description'   : 'svn commit this position',
\   'is_selectable' : 1,
\}
function! s:svn_commit.func(candidates)
    execute '! svn ci '
\         . join(map(a:candidates, 'v:val.action__path'))
endfunction
let s:svn_add  = {
\   'description'   : 'svn add this position',
\   'is_selectable' : 1,
\}
function! s:svn_add.func(candidates)
    execute '! svn add '
\             . join(map(a:candidates, 'v:val.action__path'))
endfunction
let s:svn_revert    = {
\   'description'   : 'svn revert this position',
\   'is_selectable' : 1,
\}
function! s:svn_revert.func(candidates)
    execute '! svn revert '
\             . join(map(a:candidates, 'v:val.action__path'))
endfunction
let s:svn_blame = {
\   'description'   : 'svn blame this position',
\   'is_selectable' : 0,
\}
function! s:svn_blame.func(candidates)
    execute 'Unite svn/blame:' . a:candidates.action__path
endfunction
let s:svn_delete  = {
\   'description'   : 'svn delete this position',
\   'is_selectable' : 1,
\}
function! s:svn_delete.func(candidates)
    execute '! svn delete '
\             . join(map(a:candidates, 'v:val.action__path'))
endfunction
let s:svn_log   = {
\   'description'   : 'svn log this position',
\   'is_selectable' : 0,
\}
function! s:svn_log.func(candidates)
    execute '! svn log ' . a:candidates.action__path
endfunction
let s:svn_diff   = {
\   'description'   : 'svn diff all file on this repository',
\   'is_selectable' : 1,
\}
function! s:svn_diff.func(candidates)
    execute 'Unite svn/diff:'
\         . join(map(a:candidates, 'v:val.action__path'), ':')
endfunction
let s:svn_resolved   = {
\   'description'   : 'svn resolved this position',
\   'is_selectable' : 1,
\}
function! s:svn_resolved.func(candidates)
    execute '! svn resolved '
\             . join(map(a:candidates, 'v:val.action__path'))
endfunction

function! unite#libs#svn#extension#kind#define()

    "{{{ kind
    "{{{ svn commit
    call unite#custom_action('source/svn/status/jump_list',
    \                        'commit',
    \                        s:svn_commit)
    call unite#custom_alias('source/svn/status/jump_list',
    \                        'ci',
    \                        'commit')
    "}}}
    "{{{ svn add
    call unite#custom_action('source/svn/status/jump_list',
    \                        'add',
    \                        s:svn_add)
    "}}}
    "{{{ svn revert
    call unite#custom_action('source/svn/status/jump_list',
    \                        'revert',
    \                        s:svn_revert)
    "}}}
    "{{{ svn blame
    call unite#custom_action('source/svn/status/jump_list',
    \                        'blame',
    \                        s:svn_blame)
    "}}}
    "{{{ svn delete
    call unite#custom_action('source/svn/status/jump_list',
    \                        'delete',
    \                        s:svn_delete)
    "}}}
    "{{{ svn log
    call unite#custom_action('source/svn/status/jump_list',
    \                        'log',
    \                        s:svn_log)
    "}}}
    "{{{ svn diff
    call unite#custom_action('source/svn/status/jump_list',
    \                        'diff',
    \                        s:svn_diff)
    call unite#custom_alias('source/svn/status/jump_list',
    \                        'di',
    \                        'diff')
    "}}}
    "{{{ svn resolved
    call unite#custom_action('source/svn/status/jump_list',
    \                        'resolved',
    \                        s:svn_resolved)
    "}}}
    "}}}

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: foldmethod=marker :
