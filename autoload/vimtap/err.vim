" vimtap/err.vim: VimTAP assertions for Vim errors.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	24-Mar-2014	Add vimtap#err#Throws() and variants that
"				already include the try...catch.
"	002	14-Jun-2013	Add vimtap#err#ThrownLike() variant.
"	001	23-Jan-2013	file creation

function! vimtap#err#Msg( expected, description )
"******************************************************************************
"* PURPOSE:
"   Tests whether v:errmsg is equal to a:expected.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expected  Expected contents of v:errmsg.
"   a:description   Description of test case.
"* RETURN VALUES:
"   Result of test.
"******************************************************************************
    return vimtap#Is(v:errmsg, a:expected, a:description)
endfunction

function! vimtap#err#Thrown( expected, description )
"******************************************************************************
"* PURPOSE:
"   Tests whether a:expected was thrown as an exception, either via :throw or
"   :echoerr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expected  Expected exception text (without the Vim prelude).
"   a:description   Description of test case.
"* RETURN VALUES:
"   Result of test.
"******************************************************************************
    return vimtap#Is(substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', ''), a:expected, a:description)
endfunction
function! vimtap#err#ThrownLike( expected, description )
"******************************************************************************
"* PURPOSE:
"   Tests whether something matching a:expected was thrown as an exception,
"   either via :throw or :echoerr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expected  Expected exception pattern (without the Vim prelude).
"   a:description   Description of test case.
"* RETURN VALUES:
"   Result of test.
"******************************************************************************
    return vimtap#Like(substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', ''), a:expected, a:description)
endfunction

function! vimtap#err#Throws( expected, command, description )
"******************************************************************************
"* PURPOSE:
"   Tests whether a:command, when executed, throws a:expected as a exception,
"   either via :throw or :echoerr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expected  Expected exception text (without the Vim prelude).
"   a:command   Ex command(s).
"   a:description   Description of test case.
"* RETURN VALUES:
"   Result of test.
"******************************************************************************
    try
	" invoke object under test
	execute a:command
	call vimtap#Fail('expected exception')
    catch
	call vimtap#err#Thrown(a:expected, a:description)
    endtry
endfunction
function! vimtap#err#ThrowsLike( expected, command, description )
"******************************************************************************
"* PURPOSE:
"   Tests whether a:command, when executed, throws a:expected as a exception,
"   either via :throw or :echoerr.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expected  Expected exception pattern (without the Vim prelude).
"   a:command   Ex command(s).
"   a:description   Description of test case.
"* RETURN VALUES:
"   Result of test.
"******************************************************************************
    try
	" invoke object under test
	execute a:command
	call vimtap#Fail('expected exception')
    catch
	call vimtap#err#ThrownLike(a:expected, a:description)
    endtry
endfunction
function! vimtap#err#Errors( expected, command, description )
    try
	" invoke object under test
	execute a:command
	call vimtap#Fail('expected error')
    catch
	call vimtap#err#Thrown(a:expected, a:description)
    endtry
endfunction
function! vimtap#err#ErrorsLike( expected, command, description )
    try
	" invoke object under test
	execute a:command
	call vimtap#Fail('expected error')
    catch
	call vimtap#err#ThrownLike(a:expected, a:description)
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
