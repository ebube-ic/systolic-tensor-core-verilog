`timescale 1ns / 1ps

module tb_tensor_controller_fsm;
    reg tb_clk;
    reg tb_reset;
    reg tb_start;
    wire tb_clr_accum;
    wire tb_enable;
    wire tb_valid_out;
    
    tensor_controller_fsm uut (
    .clk(tb_clk),
    .reset(tb_reset),
    .start(tb_start),
    .clr_accum(tb_clr_accum),
    .enable(tb_enable),
    .valid_out(tb_valid_out)
    );
    
    initial begin 
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    
    initial begin 
        tb_reset = 1'b1;
        tb_start = 1'b0;
        #15;
        
        tb_reset = 1'b0;
        #10;
        
        tb_start = 1'b1;
        #10;
        tb_start = 1'b0;
        
        #50;
        $finish;
    end
endmodule
