"##### HEADER [ {{{ ]
" Plugin:       VimTAP
" Version:      0.2
" Author:       Meikel Brandmeyer <mb@kotka.de>
" Created:      Sat Apr 12 20:53:41 2008
" Last Change:  Mon Apr 14 2008
"
" License:
" Copyright (c) 2008 Meikel Brandmeyer, Frankfurt am Main
" 
" All rights reserved.
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
"
" Description:
" VimTAP is an implementation of the Test Anything Protocol for vim. It is
" intended to assist the developer with testing his scripts. TAP makes it easy
" to test a project with different languages using a common harness to
" interpret the test results.
"
" See Also:
" http://search.cpan.org/~petdance/TAP-1.00/TAP.pm
" http://testanything.org
"##### [ }}} ]

"##### PROLOG [ {{{ ]
let s:saved_cpo = &cpo
set cpo&vim
"##### [ }}} ]

"##### VARIABLES [ {{{ ]
"### VARIABLE s:test_number [ {{{ ]
" Description:
" The test_number keeps track of the number of tests run by the script.
"
let s:test_number = 0
"### [ }}} ]
"### VARIABLE s:tapOutputFilespec [ {{{ ]
" Description:
" Filespec to which the TAP output is written; if empty, it is inserted into the
" current buffer. 
"
let s:tapOutputFilespec = ''
"### [ }}} ]
"##### [ }}} ]

"##### FUNCTIONS [ {{{ ]
"### FUNCTION s:Quote [ {{{ ]
" Description:
" Quote the passed argument and convert it to a string. 
"
" Source:
function! s:Quote( expr )
	if type(a:expr) == type("")
		return "'" . strtrans(a:expr) . "'"
	else
		return string(a:expr)
	endif
endfunction
"### [ }}} ]
"### FUNCTION s:PerlOutput [ {{{ ]
" Description:
" Perl output implementation. 
" Each piece of text is written individually to the output file. 
"
" Source:
function! s:PerlOutput( text )
	if ! exists('s:isPerlInitialized')
		perl << EOF
			sub output
			{
				my ($status, $tapfile) = VIM::Eval('s:tapOutputFilespec');
				die "Didn't receive tap output filespec!" unless $status;
				my ($status, $tapOutput) = VIM::Eval('a:text');
				die "Didn't receive tap output!" unless $status;

				open(TAP, '>>', $tapfile) or die "Cannot open tap output file: $!";
				print TAP $tapOutput . "\n";
				close(TAP);
			}
EOF
		let s:isPerlInitialized = 1
	endif
	perl 'output();'
endfunction
"### [ }}} ]
"### FUNCTION s:VimFlushOutput [ {{{ ]
" Description:
" Vim output implementation: Final flush to the output file. 
"
" Source:
function! s:VimFlushOutput()
	" Note: This always writes with a linefeed character at the end of a
	" line, regardless of the 'fileformat' setting. Any TAP parser should
	" handle Unix-style line endings, right? 
	call writefile(s:tapOutput, s:tapOutputFilespec)
	unlet s:tapOutput
	autocmd! vimtap
endfunction
"### [ }}} ]
"### FUNCTION s:VimOutput [ {{{ ]
" Description:
" Vim output implementation. 
" Each piece of text is appended to an internal list variable, then flushed out
" to the output file when the output file is changed or Vim is closed. 
"
" Source:
function! s:VimOutput( text )
	if ! exists('s:tapOutput')
		let s:tapOutput = []
		augroup vimtap
			autocmd!
			autocmd VimLeavePre * call <SID>VimFlushOutput()
		augroup END
	endif
	call add(s:tapOutput, a:text)
endfunction
"### [ }}} ]
"### FUNCTION s:Output [ {{{ ]
" Description:
" Output one piece of text. Chooses output implementation based on existing capabilities. 
"
" Source:
function! s:Output( text )
	if empty(s:tapOutputFilespec)
		execute "normal i" . a:text . "\<CR>"
	elseif has('perl')
		call s:PerlOutput(a:text)
	else
		call s:VimOutput(a:text)
	endif
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Output [ {{{ ]
" Description:
" Set a file (or the current buffer) to which the TAP output is written. 
"
" Example:
"   call vimtap#Output('/tmp/test.tap')
"
" Source:
function! vimtap#Output( filespec )
	if ! empty(s:tapOutputFilespec) && ! has('perl')
		call s:VimFlushOutput()
	endif

	" Reset test numbering. 
	let s:test_number = 0

	let s:tapOutputFilespec = a:filespec
	if ! empty(s:tapOutputFilespec)
		" Convert to full path so that changes of CWD do not affect the test
		" output. 
		let s:tapOutputFilespec = fnamemodify(s:tapOutputFilespec, ':p')
	endif
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Plan [ {{{ ]
" Description:
" Write the test plan to the output buffer.
"
" Example:
"   call vimtap#Plan(10)
"
" Source:
function! vimtap#Plan(tests)
	call s:Output(printf("1..%d", a:tests))
	let s:test_number = 1
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Ok [ {{{ ]
" Description:
" Ok is the simplest test function. The first argument is the result of an
" arbitrary test. In case the test succeeded, an ok line is printed into the
" test buffer. Otherwise a not ok line is printed. The description is appended
" to the test line.
"
" Example:
"   call vimtap#Ok(x == y, "x is equal to y")
"   call vimtap#Ok(IsFoo(x), "x is Foo")
"
" Source:
function! vimtap#Ok(test_result, description)
	let result = a:test_result ? "ok" : "not ok"

	call s:Output(printf("%s %d - %s", result, s:test_number,
				\ strtrans(a:description)))

	let s:test_number += 1
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Is [ {{{ ]
" Description:
" Is is a bit more complicated than Ok. It takes two entities and compares
" them using ==. Some diagnostic output gives more information about, why the
" test failed than it is possible for Ok.
"
" Example:
"   call vimtap#Is(x, y, "x is equal to y")
"
" Source:
function! vimtap#Is(got, exp, description)
	let test_result = a:got == a:exp

	call vimtap#Ok(test_result, a:description)
	if !test_result
		call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:\n"
					\ . "expected: " . s:Quote(a:exp) . "\n"
					\ . "but got:  " . s:Quote(a:got) . "")
	endif
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Isnt [ {{{ ]
" Description:
" Isnt is similar to Is, but the generated value should be different from the
" supplied one.
"
" Example:
"   call vimtap#Isnt(x, y, "x is not equal to y")
"
" Source:
function! vimtap#Isnt(got, unexp, description)
	let test_result = a:got != a:unexp

	call vimtap#Ok(test_result, a:description)
	if !test_result
		call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:\n"
					\ . "got unexpected: "
					\ . s:Quote(a:got))
	endif
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Like [ {{{ ]
" Description:
" Like is similar to Is, but the it uses a regular expression which is matched
" against the passed in value. If the value matches the regular expression,
" then the test succeeds.
"
" Example:
"   call vimtap#Like(x, '\d\d', "x has two-digit number")
"
" Source:
function! vimtap#Like(got, re, description)
	let test_result = a:got =~ a:re

	call vimtap#Ok(test_result, a:description)
	if !test_result
		call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:\n"
					\ . "got: " . s:Quote(a:got) . "\n"
					\ . "does not match: /" . a:re . "/")
	endif
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Unlike [ {{{ ]
" Description:
" Unlike is similar to Like, but the regular expression must not match.
"
" Example:
"   call vimtap#Unlike(x, '^\s*$', "x contains non-whitespace")
"
" Source:
function! vimtap#Unlike(got, re, description)
	let test_result = a:got !~ a:re

	call vimtap#Ok(test_result, a:description)
	if !test_result
		call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:\n"
					\ . "got: " . s:Quote(a:got) . "\n"
					\ . "does match: /" . a:re . "/")
	endif
endfunction
"### [ }}} ]
"### FUNCTION vimtap#Diag [ {{{ ]
" Description:
" Print the given string into the output. Preface each line with a '#'.
"
" Example:
"   call vimtap#Diag("Some Diagnostic Message")
"
" Source:
function! vimtap#Diag(str)
	for line in split(a:str, '\(\r\n\|\r\|\n\)', 1)
		call s:Output("# " . line)
	endfor
endfunction
"### [ }}} ]
"##### [ }}} ]

"##### EPILOG [ {{{ ]
let &cpo = s:saved_cpo
unlet s:saved_cpo
"##### [ }}} ]
