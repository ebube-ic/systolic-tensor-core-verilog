`timescale 1ns / 1ps

module tb_systolic_deskew_4x4;
    reg tb_clk;
    reg tb_reset;
    reg tb_enable;
    reg signed [31:0] tb_col0_in;
    reg signed [31:0] tb_col1_in;
    reg signed [31:0] tb_col2_in;
    reg signed [31:0] tb_col3_in;
    wire signed [31:0] tb_col0_out;
    wire signed [31:0] tb_col1_out;
    wire signed [31:0] tb_col2_out;
    wire signed [31:0] tb_col3_out;
    
    systolic_deskew_4x4 uut (
        .clk(tb_clk),
        .reset(tb_reset),
        .enable(tb_enable),
        .col0_in(tb_col0_in),
        .col1_in(tb_col1_in),
        .col2_in(tb_col2_in),
        .col3_in(tb_col3_in),
        .col0_out(tb_col0_out),
        .col1_out(tb_col1_out),
        .col2_out(tb_col2_out),
        .col3_out(tb_col3_out)
    );
    
    initial begin 
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    
    initial begin 
        tb_reset = 1'b1;
        tb_enable = 1'b0;
        tb_col0_in = 32'sd0;
        tb_col1_in = 32'sd0;
        tb_col2_in = 32'sd0;
        tb_col3_in = 32'sd0;
        #20;
        
        tb_reset = 1'b0;        
        tb_enable = 1'b1;
        #10;
        
        tb_col0_in = 32'sd100;
        tb_col1_in = 32'sd0;
        tb_col2_in = 32'sd0;
        tb_col3_in = 32'sd0;
        #10;
        
        tb_col0_in = 32'sd0;
        tb_col1_in = 32'sd200;
        tb_col2_in = 32'sd0;
        tb_col3_in = 32'sd0;
        #10;        
        
        tb_col0_in = 32'sd0;
        tb_col1_in = 32'sd0;
        tb_col2_in = 32'sd300;
        tb_col3_in = 32'sd0;
        #10;        
        
        tb_col0_in = 32'sd0;
        tb_col1_in = 32'sd0;
        tb_col2_in = 32'sd0;
        tb_col3_in = 32'sd400;
        #10;
        
        tb_col3_in = 32'sd0;
        #40;
        
        $finish;
    end
endmodule
