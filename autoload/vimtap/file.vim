" vimtap#file.vim: VimTAP assertions for files.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"
" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	006	05-May-2014	Use tr() instead of substitute().
"				Add vimtap#file#Is() for a simple canonicalized
"				comparison without simplification or path
"				conversion.
"	005	25-Feb-2010	BUG: vimtap#file#IsFilespec() reported failure
"				but identical paths when fnamemodify() does not
"				expand a nonexisting a:got. Checking for this
"				special case.
"				Added a simplify() call in s:Canonicalize() to
"				anticipate mismatches with /paths/./like/this.
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

function! vimtap#file#Is( got, exp, description )
    return vimtap#Is(tr(a:got, '\', '/'), tr(a:exp, '\', '/'), a:description)
endfunction

function! s:Canonicalize( filespec )
    return tr(simplify(a:filespec), '\', '/')
endfunction
function! vimtap#file#FilespecMatch( got, exp )
    let l:canonicalExp = s:Canonicalize(a:exp)
    let l:canonicalPathDelimitedExp = (l:canonicalExp =~# '^/' ? '' : '/') . l:canonicalExp
    " To compare the filespecs, we must first expand whatever we got into a
    " full filespec.
    let l:got = fnamemodify(a:got, ':p')

    if s:Canonicalize(l:got) =~# '\V' . l:canonicalPathDelimitedExp . '\$'
	return [1, '']
    elseif l:got ==# a:got && s:Canonicalize(l:got) ==# l:canonicalExp
	" If a:got does not exist, the expansion via fnamemodify() may give up
	" and return it unchanged (especially on Linux). In this case, the
	" original comparison may fail because no path components have been
	" preprended, so l:got may not start with '/' (what we prepend to a:exp
	" to make it a path-delimited match). Detect this special situation and
	" compare both for equality instead.
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
