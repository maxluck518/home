module inst1(/*vlog_aide:auto_port*/);

parameter DIN_WIDTH = 16;

input                   inst1_in0;
input                   inst1_in1, inst1_in2;
input [5:0]             inst1_in3;
input [`DATA_WIDTH-1:0] inst1_in4;
input [DIN_WIDTH-1:0]   inst1_in5;
output                  inst1_out0, inst1_out1;
output                  inst1_out2;
output [15:0]           inst1_out3;
output [DIN_WIDTH*2-1:0]        inst1_out4;

endmodule
