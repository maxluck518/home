`ifndef TEST_SV
`define TEST_SV
class test extends uvm_sequence_item;
    typedef enum {A, B, C} user_type1_e;
    typedef enum {D,
                  E,
                  F} user_type2_e;
    int         test1;
    string      test2;
    user_class  test3;
    int         test4[];
    user_type1_e        test5[3];
    user_type2_e        test6[$];
    user_class          test7[int];
    
    `uvm_object_utils_begin(test)
    `uvm_object_utils_end

    function new(string name = "test");
        super.new(name);
    endfunction

endclass
`endif
