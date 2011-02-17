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
            let l:obj   = unite#libs#svn#{self.svn_command}#new()
            call l:obj.initialize(a:args)
            return map(obj.get_unite_normalized_data(self.name), '{
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

call unite#libs#svn#extension#kind#define()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
