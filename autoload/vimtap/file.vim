" TODO: summary
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
"   Put the script into your user or system VIM plugin directory (e.g.
"   ~/.vim/plugin). 

" DEPENDENCIES:
"   - Requires VIM 7.0 or higher. 

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

function! vimtap#file#IsFilespec( ... )
    if a:0 == 3
	let l:got = fnamemodify(a:1, ':p')
	let l:exp = a:2
	let l:description = a:3
    elseif a:0 == 2
	let l:got = expand('%:p')
	let l:exp = a:1
	let l:description = a:2
    else
	throw 'ASSERT: Must supply 2 or 3 arguments. '
    endif
    call vimtap#Like(substitute(l:got, '\\', '/', 'g'), '.*\V' . substitute(l:exp, '\\', '/', 'g') . '\$', l:description)
endfunction

function! vimtap#file#IsFile( description )
    call vimtap#Ok(filereadable(expand('%:p')), a:description . ' (file exists)')
endfunction
function! vimtap#file#IsNoFile( description )
    call vimtap#Ok(! filereadable(expand('%')), a:description . ' (no file)')
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
