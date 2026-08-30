`timescale 1ns / 1ps

module tb_mac_unit_int8_pipelined;
    reg tb_clk;
    reg tb_reset;
    reg tb_enable;
    reg tb_clr_accum;
    reg signed [7:0] tb_a;
    reg signed [7:0] tb_b;
    wire signed [31:0] tb_accum;
    
    mac_unit_int8_pipelined uut(
        .clk(tb_clk),
        .reset(tb_reset),
        .enable(tb_enable),
        .clr_accum(tb_clr_accum),
        .a(tb_a),
        .b(tb_b),
        .accum(tb_accum)
    );
    
    initial begin 
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    
    initial begin 
        tb_reset = 1'b1;
        tb_enable = 1'b0;
        tb_clr_accum = 1'b0;
        tb_a = 8'sd0;
        tb_b = 8'sd0;
        #15;
        
        tb_reset = 1'b0;
        tb_enable = 1'b1;
        
        tb_a = 8'sd3;
        tb_b = 8'sd4;
        #10;
        
        tb_a = 8'sd5;
        tb_b = 8'sd2;
        #10;
        
        tb_a = 8'sd2;
        tb_b = 8'sd2;
        #10;
        
        tb_a = 8'sd0;
        tb_b = 8'sd0;
        #10;
        
        $finish;
    end
    
endmodule
