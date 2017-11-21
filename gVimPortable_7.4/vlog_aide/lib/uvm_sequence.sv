# uvm_sequence (FILENAME, CLASSNAME)
`ifndef $(FILENAME)_SV
`define $(FILENAME)_SV
class $(CLASSNAME) extends uvm_sequence #(packet);
    `uvm_object_utils($(CLASSNAME))

    virtual task pre_body();
        starting_phase.raise_objection(this);
    endtask

    virtual task body();
    endtask

    virtual task post_body();
        starting_phase.drop_objection(this);
    endtask
endclass
`endif
