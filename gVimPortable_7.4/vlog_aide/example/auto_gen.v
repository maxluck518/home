module auto_gen();

always @(posedge clk) begin
    din_d0 <= #`FFD din;
    /*vlog_aide:auto_gen i=1,10,1 begin
    din_d$(i) <= din_d$(i-1);
    vlog_aide:auto_gen i, end*/
end

/*vlog_aide:auto_gen i=0,9,1 begin
pe_cell cell$(i)(.clk(clk), .din(din[$(i*8+7):0]), .dout(dout_$(i)[7:0]));
vlog_aide:auto_gen i, end*/

always @(posedge clk) begin
    if (rst_n) begin
        /*vlog_aide:auto_gen i=0,3,1 j=0,2,1 begin
        mem_$(i)_$(j) = 8'h0;
        vlog_aide:auto_gen i,j, end*/
    end
    else begin
        case (addr_i)
        /*vlog_aide:auto_gen i=0,3,1 begin
        $(i) : begin
            case (addr_j)
            /*vlog_aide:auto_gen j=0,2,1 begin
            $(j) : mem_$(i)_$(j) = din;
            vlog_aide:auto_gen j, end*/
            endcase
        end
        vlog_aide:auto_gen i, end*/
        endcase
    end
end

endmodule
