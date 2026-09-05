`timescale 1ns / 1ps

module tb_systolic_tensor_core_2x2;
    reg tb_clk;
    reg tb_reset;
    reg tb_start;
    reg signed [7:0] tb_a0_in;
    reg signed [7:0] tb_b0_in;
    reg signed [7:0] tb_a1_in;
    reg signed [7:0] tb_b1_in;
    wire signed [31:0] tb_c00;
    wire signed [31:0] tb_c01;
    wire signed [31:0] tb_c10;
    wire signed [31:0] tb_c11;
    wire tb_valid_out;
    
    systolic_tensor_core_2x2 uut (
        .clk(tb_clk),
        .reset(tb_reset),
        .start(tb_start),
        .a0_in(tb_a0_in),
        .b0_in(tb_b0_in),
        .a1_in(tb_a1_in),
        .b1_in(tb_b1_in),
        .c00(tb_c00),
        .c01(tb_c01),
        .c10(tb_c10),
        .c11(tb_c11),
        .valid_out(tb_valid_out)
    );
    
    initial begin 
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    
    initial begin 
        tb_reset = 1'b1;
        tb_start = 1'b0;
        tb_a0_in = 1'b0;
        tb_b0_in = 1'b0;
        tb_a1_in = 1'b0;
        tb_b1_in = 1'b0;
        #10;
        
        tb_reset = 1'b0;
        #10;
        tb_start = 1'b1;
        #10;
        tb_start = 1'b0;
        #10;
        
        tb_a0_in = 8'sd1;        tb_a1_in = 8'sd3;
        tb_b0_in = 8'sd5;        tb_b1_in = 8'sd6;
        #10;
        
        tb_a0_in = 8'sd2;        tb_a1_in = 8'sd4;
        tb_b0_in = 8'sd7;        tb_b1_in = 8'sd8;
        #10;
        
        tb_a0_in = 8'sd0;        tb_a1_in = 8'sd0;
        tb_b0_in = 8'sd0;        tb_b1_in = 8'sd0;
        #50;
        
        $finish;
    end
    
endmodule
