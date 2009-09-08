" TODO: summary
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
"   Put the script into your user or system Vim autoload directory (e.g.
"   ~/.vim/autoload). 

" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 

" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	002	03-Feb-2009	Added IsFile() and IsNoFile(). 
"	001	30-Jan-2009	file creation

function! vimtap#file#IsFilename( exp, description ) 
    call vimtap#Is(expand('%:t'), a:exp, a:description)
endfunction

function! s:Canonicalize( filespec )
    return substitute(a:filespec, '\\', '/', 'g')
endfunction
function! vimtap#file#FilespecMatch( got, exp )
    if s:Canonicalize(fnamemodify(a:got, ':p')) =~# '\V' . s:Canonicalize(a:exp) . '\$'
	return [1, '']
    else
	return [0, "'" . a:got . "'\ndoes not match '" . a:exp . "'"]
    endif
endfunction
function! vimtap#file#IsFilespec( ... )
    if a:0 == 3
	let l:got = a:1
	let l:exp = a:2
	let l:description = a:3
	let l:what = 'filespec'
    elseif a:0 == 2
	let l:got = expand('%')
	let l:exp = a:1
	let l:description = a:2
	let l:what = 'current file'
    else
	throw 'ASSERT: Must supply 2 or 3 arguments. '
    endif

    let [l:isMatch, l:diag] =  vimtap#file#FilespecMatch(l:got, l:exp)
    call vimtap#Ok(l:isMatch, l:description)
    if ! l:isMatch
	call vimtap#Diag("Test '" . strtrans(l:description) . "' failed:\n" . l:what . ' ' . l:diag)
    endif
endfunction

function! vimtap#file#IsFile( description )
    call vimtap#Ok(filereadable(expand('%:p')), a:description . ' (file exists)')
endfunction
function! vimtap#file#IsNoFile( description )
    call vimtap#Ok(! filereadable(expand('%')), a:description . ' (no file)')
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
