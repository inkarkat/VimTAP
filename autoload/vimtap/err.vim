" vimtap/err.vim: VimTAP assertions for Vim errors.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	06-Jun-2019	Include description in failure messages. Add
"                               s:Concat() helper.
"                               Add negative vimtap#err#NotThrown[Like]().
"                               Add negative vimtap#err#NoError[Like]().
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

function! s:Concat( description, message ) abort
    return a:description . (empty(a:description) ? '' : ' - ') . a:message
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
function! vimtap#err#NotThrown( expected, description )
    return vimtap#Isnt(substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', ''), a:expected, a:description)
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
function! vimtap#err#NotThrownLike( expected, description )
    return vimtap#Unlike(substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', ''), a:expected, a:description)
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
	call vimtap#Fail(s:Concat(a:description, 'expected exception'))
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
	call vimtap#Fail(s:Concat(a:description, 'expected exception'))
    catch
	call vimtap#err#ThrownLike(a:expected, a:description)
    endtry
endfunction
function! vimtap#err#Errors( expected, command, description )
    try
	" invoke object under test
	execute a:command
	call vimtap#Fail(s:Concat(a:description, 'expected error'))
    catch
	call vimtap#err#Thrown(a:expected, a:description)
    endtry
endfunction
function! vimtap#err#ErrorsLike( expected, command, description )
    try
	" invoke object under test
	execute a:command
	call vimtap#Fail(s:Concat(a:description, 'expected error'))
    catch
	call vimtap#err#ThrownLike(a:expected, a:description)
    endtry
endfunction
function! vimtap#err#NoError( ... )
"******************************************************************************
"* PURPOSE:
"   Tests whether a:command, when executed, does not cause an error / a:expected
"   as a particular error.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expected  Optional expected error. If omitted, no error at all should be
"               raised.
"   a:command   Ex command(s).
"   a:description   Description of test case.
"* RETURN VALUES:
"   Result of test.
"******************************************************************************
    let [l:expected, l:command, l:description] = (a:0 == 2 ? [''] + a:000 : a:000)
    try
	" invoke object under test
	execute l:command
	call vimtap#Pass(s:Concat(l:description, 'no error occurred'))
    catch
	if empty(l:expected)
	    call vimtap#Fail(s:Concat(l:description, printf('No error expected, but %s occurred', substitute(v:exception, '^\CVim\%((\a\+)\)\=:', '', ''))))
	else
	    call vimtap#err#NotThrown(l:expected, l:description)
	endif
    endtry
endfunction
function! vimtap#err#NoErrorLike( expected, command, description  )
    try
	" invoke object under test
	execute a:command
	call vimtap#Pass(s:Concat(a:description, 'no error occurred'))
    catch
	call vimtap#err#NotThrownLike(a:expected, a:description)
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
