" vimtap/err.vim: VimTAP assertions for Vim errors.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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
    return vimtap#Is(substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', ''), a:expected, a:description)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
