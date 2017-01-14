
" SDNet integer formats
syn match Number "\<\d\+\>"
syn match Number "\<0x\x\+\>"
" syntax match Number /^\d\+/
" syntax match Number /^0\(b\|B\)[01]\+/
" syntax match Number /^0\(x\|X\)\x\+/
" syntax match Number /^\(+\|-\)\=\d\+'\d\+/
syntax match Function /\(^\|\s\)\(apply\|valid\|select\|current\|extract\|add_header\|copy_header\|remove_header\|modify_field\|add_to_field\|add\|set_field_to_hash_index\|truncate\|drop\|no_op\|push\|pop\|count\|meter\|generate_digest\|resubmit\|recirculate\|clone_ingress_pkt_to_ingress\|clone_egress_pkt_to_ingress\|clone_ingress_pkt_to_egress\|clone_egress_pkt_to_egress\|register_write\|register_read\)/
syntax match PreProc /^#include/
syntax match Title /^#define/
syntax match Type /\(^\|\s\)\(length\|fields\|max_length\)\s/
syntax match Type /\(^\|\s\)\(width\|layout\|attributes\|type\|static\|result\|direct\|instance_count\|min_width\|saturating\)\s/
syntax match Special /\(bytes\|packets\)\s/
syntax match Tag /\(^\|\s\)\(control\|action\|table\|counter\|header_type\|header\|register\|parser\|metadata\|primitive_action\|meter\|parse_error\|default\)\s/
syntax match Tag /\(^\|\s\)\(reads\|actions\|min_size\|max_size\|size\|support_timeout\|action_profile\)/
syntax match Type /\(exact\|ternary\|lpm\|range\|valid\|mask\)\s/
syntax match Keyword /\(^\|\s\)\(if\|else if\|else\)/
" syntax match Comment /\/\/.*\n/
syntax match String /"[^"]*"/

" p4 comment formats
syn keyword P4CommentTodo contained TODO NOTE FIXME
syn match P4Comment  "//.*$"  contains=PXCommentTodo,@Spell
syn region P4CommentBlock  start="/\*"  end="\*/" contains=PXCommentTodo,@Spell

" Apply highlight groups to syntax groups defined above
command! -nargs=+ HiLink hi def link <args>
HiLink P4Comment            Comment
HiLink P4CommentBlock       Comment
