module top(/*vlog_aide:auto_port*/);
output  [7:0]                           top_out0;
output reg signed [`DATA_WIDTH-1:0]     top_out1;
output [DOUT_WIDTH-1:0]                 top_out2;

/*vlog_aide:auto_define*/

always @(posedge clk)
     begin
         test_reg_3[4:0] <= {test_in_1,test_in_2};
         test_reg_4[3:1] <= {3{test_in_1}};
         test_reg_4[0] <= 0;
     end

always @(posedge clk)
     begin
         if (!nrst)
           test_reg_5 <= 4'b1010<<2;
     end

always @ (posedge clk) begin
    case (test_in_array_1)
        5'b00000: test_reg_6 <= 8'h11;
        default: test_reg_6 <= 0;
    endcase
end

assign test_wire1 = test_reg_6 + 7'd5;
assign test_wire2 = (test_reg5 <= 1)? 6'd0 : test_reg2 + test_reg1;
assign test_wire3[7:0] = (test_reg3 == 1)? 8'h1 :
                         (test_reg3 == 2)? 8'h3 : (test_reg3 == 4)? 8'h8 : 0;

always @(*)
    case (test_in_array_2)
        5'd1 : test_reg7[2:0] = test_wire1 << 1;
        5'd2 : test_reg7 = test_wire1 << 2;
        default : test_reg7 = test_wire1;
   endcase

reg signed [7:0] test_reg8;
always @(*)
    test_reg8 = test_wire2 + test_reg1;
always @(*) begin
    test_reg9[7:0] = (test_reg_6 == 15)? test_reg7 + test_reg6 : 0;
    test_reg8[7] = test_reg9[7];
end
inst1 dut1(
    .inst1_in3     (inst1_in3[5:0]),
    .inst1_in1     (inst1_in1),
    .inst1_in2     (inst1_in2),
    .inst1_in0     (inst1_in0),
    .inst1_in5     (inst1_in5[15:0]),
    .inst1_in4     (inst1_in4[`DATA_WIDTH-1:0]),
    .inst1_out4    (inst1_out4[31:0]),
    .inst1_out0    (inst1_out0),
    .inst1_out2    (inst1_out2),
    .inst1_out3    (inst1_out3[15:0])
);
inst2 #(8,16) dut2(/*vlog_aide:auto_inst inst2.v*/
    /*vlog_aide:auto_inst begin*/
    /*vlog_aide:auto_inst input ports*/
    .inst2_in2     (inst2_in2),
    .inst2_in5     (inst2_in5[7:0]),
    .inst2_in4     (inst2_in4[7:0]),
    .inst2_in0     (inst2_in0),
    .inst2_in3     (inst2_in3[7:0]),
    .inst2_in1     (inst2_in1),
    /*vlog_aide:auto_inst output ports*/
    .inst2_out0    (inst2_out0[15:0]),
    .inst2_out3    (inst2_out3[15:0]),
    .inst2_out1    (inst2_out1[15:0]),
    .inst2_out2    (inst2_out2[15:0])
    /*vlog_aide:auto_inst end*/
);
inst3 dut3(.inst3_in0(top_in0), .inst3_in1(top_in1), .inst3_out0(top_out0[7:0]));

endmodule
