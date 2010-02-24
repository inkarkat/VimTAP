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
" Copyright: (C) 2009-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	004	09-Feb-2010	BUG: vimtap#file#IsFilespec() didn't consider
"				path boundaries when matching at the front. 
"				Added documentation. 
"	003	09-Sep-2009	Added IsntFilename(). 
"	002	03-Feb-2009	Added IsFile() and IsNoFile(). 
"	001	30-Jan-2009	file creation

function! vimtap#file#IsFilename( exp, description ) 
"*******************************************************************************
"* PURPOSE:
"   Tests whether the current buffer has a particular filename. 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   None. 
"* INPUTS:
"   a:exp   Expected filename (without paths). 
"   a:description   Description. 
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    call vimtap#Is(expand('%:t'), a:exp, a:description)
endfunction
function! vimtap#file#IsntFilename( exp, description ) 
    call vimtap#Isnt(expand('%:t'), a:exp, a:description)
endfunction

function! s:Canonicalize( filespec )
    return substitute(a:filespec, '\\', '/', 'g')
endfunction
function! vimtap#file#FilespecMatch( got, exp )
    let l:canonicalExp = s:Canonicalize(a:exp)
    let l:canonicalPathDelimitedExp = (l:canonicalExp =~# '^/' ? '' : '/') . l:canonicalExp
    if s:Canonicalize(fnamemodify(a:got, ':p')) =~# '\V' . l:canonicalPathDelimitedExp . '\$'
	return [1, '']
    else
	return [0, "'" . a:got . "'\ndoes not match '" . a:exp . "'"]
    endif
endfunction
function! vimtap#file#IsFilespec( ... )
"*******************************************************************************
"* PURPOSE:
"   Tests whether the passed or current filespec matches with the expected
"   filespec fragment, taking into consideration different path separators and
"   different base paths. 
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   None. 
"* INPUTS:
"   a:got   Optional: Actual filespec or current buffer's filespec. Is expanded
"	    to full path automatically. 
"   a:exp   Expected filespec (fragment). Is anchored at the end and must match
"	    on path boundaries; i.e. "bar.txt" will match "foo/bar.txt" but not
"	    "foobar.txt". 
"   a:description   Description. 
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
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
"*******************************************************************************
"* PURPOSE:
"   Tests whether the current buffer has been persisted to the file system. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   None. 
"* INPUTS:
"   a:description   Description. 
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    call vimtap#Ok(filereadable(expand('%:p')), a:description . ' (file exists)')
endfunction
function! vimtap#file#IsNoFile( description )
    call vimtap#Ok(! filereadable(expand('%')), a:description . ' (no file)')
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
