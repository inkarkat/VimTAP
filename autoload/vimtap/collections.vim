" vimtap/collections.vim: VimTAP assertions for collections.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.

" Copyright: (C) 2009-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	01-Dec-2014	Add vimtap#collections#DoesNotContain().
"	003	23-Jan-2013	Rename to vimtap#collections#Contains() for
"				consistency with the other VimTAP functions.
"	002	09-Jan-2010	Added documentation.
"				Added vimtap#collections#contains().
"	001	09-Jun-2009	file creation

function! vimtap#collections#IsUniqueSet( actualSet, expectedSet, description )
"*******************************************************************************
"* PURPOSE:
"   Tests whether all unique elements of a:expectedSet are contained in a:actualSet and
"   vice versa, in any order. Both sets must contain the same elements in value;
"   duplicates are removed.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:actualSet	    (Unsorted) list of actual items.
"   a:expectedSet   (Unsorted) list of expected items.
"   a:description   Description of test case.
"* RETURN VALUES:
"   None.
"*******************************************************************************
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
"*******************************************************************************
"* PURPOSE:
"   Tests whether all elements of a:expectedSet are contained in a:actualSet and
"   vice versa, in any order. Both sets must contain the same elements, both in
"   number and value.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:actualSet	    (Unsorted) list of actual items.
"   a:expectedSet   (Unsorted) list of expected items.
"   a:description   Description of test case.
"   a:1   isNoCopy  Flag to modify the passed sets in-place.
"* RETURN VALUES:
"   None.
"*******************************************************************************
    let l:actualSet   = sort( a:0 && a:1 ? a:actualSet   : copy(a:actualSet))
    let l:expectedSet = sort( a:0 && a:1 ? a:expectedSet : copy(a:expectedSet))

    let l:actualNum = len(l:actualSet)
    let l:expectedNum = len(l:expectedSet)

    let l:isFailure = 0
    let l:diag = ''

    let l:actualIdx = 0
    let l:expectedIdx = 0
    while 1
	if l:actualIdx >= l:actualNum
	    for l:expectedIdx in range(l:expectedIdx, l:expectedNum - 1)
		let l:isFailure = 1
		let l:diag .= "\nmissing " . string(l:expectedSet[l:expectedIdx])
	    endfor
	    break
	elseif l:expectedIdx >= l:expectedNum
	    for l:actualIdx in range(l:actualIdx, l:actualNum - 1)
		let l:isFailure = 1
		let l:diag .= "\nextra   " . string(l:actualSet[l:actualIdx])
	    endfor
	    break
	endif

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
    endwhile

    call vimtap#Ok(! l:isFailure, a:description)
    if l:isFailure
	call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:" . l:diag)
    endif
endfunction

function! vimtap#collections#Contains( actual, expected, description )
"*******************************************************************************
"* PURPOSE:
"   Tests whether all elements of a:expected are contained in a:actual in any
"   order; i.e. whether a:expected is a subset of a:actual.
"   In case of Lists, the same element can be contained multiple times in
"   a:expected; it must then be contained as least as many times in a:actual.
"* TODO:
"   Implement for Dictionaries.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:actual	List or Dictionary of actual items.
"   a:expected	Same type as a:actual; List or Dictionary of expected items.
"   a:description   Description of test case.
"* RETURN VALUES:
"   None.
"*******************************************************************************
    let l:usedIndices = {}
    let l:isFailure = 0
    let l:diag = ''

    for l:item in a:expected
	let l:startIndex = 0
	while 1
	    let l:index = index(a:actual, l:item, l:startIndex)
	    if l:index == -1
		let l:isFailure = 1
		let l:diag .= "\nmissing " . string(l:item)
		break
	    else
		if has_key(l:usedIndices, l:index)
		    let l:startIndex = l:index + 1
		else
		    let l:usedIndices[l:index] = 1
		    break
		endif
	    endif
	endwhile
    endfor

    call vimtap#Ok(! l:isFailure, a:description)
    if l:isFailure
	call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:" . l:diag)
    endif
endfunction
function! vimtap#collections#DoesNotContain( actual, expected, description )
"*******************************************************************************
"* PURPOSE:
"   Tests whether none of the elements of a:expected are contained in a:actual in any
"   order; i.e. whether a:expected and a:actual are disjunct.
"* TODO:
"   Implement for Dictionaries.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:actual	List or Dictionary of actual items.
"   a:expected	Same type as a:actual; List or Dictionary of expected items.
"   a:description   Description of test case.
"* RETURN VALUES:
"   None.
"*******************************************************************************
    let l:isFailure = 0
    let l:diag = ''

    for l:item in a:expected
	let l:index = index(a:actual, l:item)
	if l:index != -1
	    let l:isFailure = 1
	    let l:diag .= "\nextra " . string(l:item)
	endif
    endfor

    call vimtap#Ok(! l:isFailure, a:description)
    if l:isFailure
	call vimtap#Diag("Test '" . strtrans(a:description) . "' failed:" . l:diag)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
