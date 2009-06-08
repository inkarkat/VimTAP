" TODO: summary
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
"   Put the script into your user or system Vim plugin directory (e.g.
"   ~/.vim/plugin). 

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
"	001	09-Jun-2009	file creation

function! vimtap#collections#IsUniqueSet( actualSet, expectedSet, description )
    let l:actualDict = {}
    for l:actual in a:actualSet
	let l:actualDict[l:actual] = 1
    endfor

    let l:expectedDict = {}
    for l:expected in a:expectedSet
	let l:expectedDict[l:expected] = 1
    endfor
    return vimtap#collections#IsSet( keys(l:actualDict), keys(l:expectedDict), a:description, 1 )
endfunction
function! vimtap#collections#IsSet( actualSet, expectedSet, description, ... )
    " a:1   isNoCopy	Flag to modify the passed sets in-place. 
    let l:actualSet   = sort( a:0 && a:1 ? a:actualSet   : copy(a:actualSet))
    let l:expectedSet = sort( a:0 && a:1 ? a:expectedSet : copy(a:expectedSet))

    let l:actualNum = len(l:actualSet)
    let l:expectedNum = len(l:expectedSet)

    let l:isFailure = 0
    let l:diag = ''

    let l:actualIdx = 0
    let l:expectedIdx = 0
    while 1
	if l:actualSet[l:actualIdx] == l:expectedSet[l:expectedIdx]
	    let l:actualIdx += 1
	    let l:expectedIdx += 1
	elseif l:actualSet[l:actualIdx] > l:expectedSet[l:expectedIdx]
	    let l:isFailure = 1
	    let l:diag .= "\nmissing " . string(l:expectedSet[l:expectedIdx])
	    let l:expectedIdx += 1
	elseif l:actualSet[l:actualIdx] < l:expectedSet[l:expectedIdx]
	    let l:isFailure = 1
	    let l:diag .= "\nextra   " . string(l:actualSet[l:actualIdx])
	    let l:actualIdx += 1
	endif

	if l:actualIdx >= l:actualNum
	    for l:expectedIdx in range(l:expectedIdx, l:expectedNum - 1)
		let l:diag .= "\nmissing " . string(l:expectedSet[l:expectedIdx])
	    endfor
	    break
	elseif l:expectedIdx >= l:expectedNum
	    for l:actualIdx in range(l:actualIdx, l:actualNum - 1)
		let l:diag .= "\nextra   " . string(l:actualSet[l:actualIdx])
	    endfor
	    break
	endif
    endwhile

    call vimtap#Ok(! l:isFailure, a:description)
    if l:isFailure
	call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:" . l:diag)
    endif
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
