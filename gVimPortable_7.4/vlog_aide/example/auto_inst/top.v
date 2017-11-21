module top(/*vlog_aide:auto_port*/);

inst1 dut1(/*vlog_aide:auto_inst inst1.v*/);
inst2 #(8,16) dut2(/*vlog_aide:auto_inst inst2.v*/);

endmodule
