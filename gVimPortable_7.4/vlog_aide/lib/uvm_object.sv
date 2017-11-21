# uvm_object (FILENAME, CLASSNAME, BASECLASS)
`ifndef $(FILENAME)_SV
`define $(FILENAME)_SV
class $(CLASSNAME) extends $(BASECLASS);
    
    `uvm_object_utils_begin($(CLASSNAME))
    `uvm_object_utils_end

    function new(string name = "$(CLASSNAME)");
        super.new(name);
    endfunction

endclass
`endif
