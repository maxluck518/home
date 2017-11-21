amenu UVM-Utilities.--Template--        :
amenu UVM-Utilities.uvm_component       :call Uvm_component("uvm_component")<CR>
amenu UVM-Utilities.uvm_driver          :call Uvm_component("uvm_driver")<CR>
amenu UVM-Utilities.uvm_agent           :call Uvm_component("uvm_agent")<CR>
amenu UVM-Utilities.uvm_env             :call Uvm_component("uvm_env")<CR>
amenu UVM-Utilities.uvm_test            :call Uvm_component("uvm_test")<CR>
amenu UVM-Utilities.uvm_object          :call Uvm_object("uvm_object")<CR>
amenu UVM-Utilities.uvm_sequence_item   :call Uvm_object("uvm_sequence_item")<CR>
amenu UVM-Utilities.uvm_transaction     :call Uvm_object("uvm_transaction")<CR>
amenu UVM-Utilities.uvm_sequence        :call Uvm_sequence()<CR>
amenu UVM-Utilities.--Automatic--       :
amenu UVM-Utilities.AutoField           :AutoField<CR>

command -nargs=* AutoField      :0,$ !perl $VLOG_AIDE_HOME/src/auto_field.pl <args>

function Uvm_component(component_type)
    let classname = bufname("%")
    let classname = substitute(classname, '\..*$', "", "")
    let define = toupper(classname)
    let command = "$VLOG_AIDE_HOME/src/macro.pl uvm_component.sv " . define . " " . classname . " " . a:component_type
    let line = system(command)
    let lines = split(line, "\n")
    call setline(1, lines)
endfunction

function Uvm_object(object_type)
    let classname = bufname("%")
    let classname = substitute(classname, '\..*$', "", "")
    let define = toupper(classname)
    let command = "$VLOG_AIDE_HOME/src/macro.pl uvm_object.sv " . define . " " . classname . " " . a:object_type
    let line = system(command)
    let lines = split(line, "\n")
    call setline(1, lines)
endfunction

function Uvm_sequence()
    let  classname = bufname("%")
    let classname = substitute(classname, '\..*$', "", "")
    let define = toupper(classname)
    let command = "$VLOG_AIDE_HOME/src/macro.pl uvm_sequence.sv " . define . " " . classname
    let line = system(command)
    let lines = split(line, "\n")
    call setline(1, lines)
endfunction

