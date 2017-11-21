# uvm_component (FILENAME, CLASSNAME, BASECLASS)
`ifndef $(FILENAME)_SV
`define $(FILENAME)_SV
class $(CLASSNAME) extends $(BASECLASS);
    
    `uvm_component_utils_begin($(CLASSNAME))
    `uvm_component_utils_end

    function new(string name = "$(CLASSNAME)", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase();

    endtask

endclass
`endif
