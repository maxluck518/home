module inst2(
 input                  inst2_in0,
 input                  inst2_in1, inst2_in2,
 input [DIN_WIDTH-1:0]  inst2_in3,
 input [7:0]            inst2_in4, inst2_in5,
 output reg signed [15:0]       inst2_out0,
 output [DOUT_WIDTH-1:0]        inst2_out1, inst2_out2,
 output reg [DIN_WIDTH*2-1:0]   inst2_out3
);
parameter DIN_WIDTH = 16,
          DOUT_WIDTH = 32;

endmodule
