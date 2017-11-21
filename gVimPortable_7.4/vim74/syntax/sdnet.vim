" SDNet syntax file
" Language: PX
" Maintainer: Robert Halstead, Xilinx Labs Inc.
" Latest Revision: 20 May 2016

if exists("b:current_syntax")
    finish
endif

" SDNet keywords are case sensitive
syn case match

" SDNet object Types
syn keyword PXTypes class struct method map
syn keyword PXTypes Packet_input Packet_output

" SDNet built-in functions & IDs
syn keyword PXFunctions ParsingEngine EditingEngine LookupEngine TupleEngine
syn keyword PXFunctions System
syn keyword PXFunctions Packet Tuple Plain Section
syn keyword PXFunctions done

" SDNet keywords
syn keyword PXKeywords if else in out inout
syn keyword PXKeywords move_to_section update insert remove
syn keyword PXKeywords send_request receive_response
syn keyword PXKeywords request response Direct EM TCAM LPM
syn keyword PXKeywords packet_in packet_out connect

" SDNet integer formats
syn match PXIntDec "\<\d\+\>"
syn match PXIntHex "\<0x\x\+\>"

" SDNet comment formats
syn keyword PXCommentTodo contained TODO NOTE FIXME
syn match PXComment  "//.*$"  contains=PXCommentTodo,@Spell
syn region PXCommentBlock  start="/\*"  end="\*/" contains=PXCommentTodo,@Spell

" Apply highlight groups to syntax groups defined above
command! -nargs=+ HiLink hi def link <args>
HiLink PXTypes              Type
HiLink PXFunctions          Function
HiLink PXKeywords           Keyword
HiLink PXIntDec             Constant
HiLink PXIntHex             Constant
HiLink PXComment            Comment
HiLink PXCommentBlock       Comment

let b:current_syntax = "sdnet"

