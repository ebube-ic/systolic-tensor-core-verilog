`timescale 1ns / 1ps

module tb_systolic_tensor_core_4x4;
    reg tb_clk;
    reg tb_reset;
    reg tb_start;
    reg signed [7:0] tb_a0_raw, tb_a1_raw, tb_a2_raw, tb_a3_raw;
    reg signed [7:0] tb_b0_raw, tb_b1_raw, tb_b2_raw, tb_b3_raw;
    wire signed [31:0] tb_c00, tb_c01, tb_c02, tb_c03;
    wire signed [31:0] tb_c10, tb_c11, tb_c12, tb_c13;
    wire signed [31:0] tb_c20, tb_c21, tb_c22, tb_c23;
    wire signed [31:0] tb_c30, tb_c31, tb_c32, tb_c33;
    wire tb_valid_out;
    
    systolic_tensor_core_4x4 uut (
        .clk(tb_clk),
        .reset(tb_reset),
        .start(tb_start),
        .a0_raw(tb_a0_raw), .a1_raw(tb_a1_raw), .a2_raw(tb_a2_raw), .a3_raw(tb_a3_raw),
        .b0_raw(tb_b0_raw), .b1_raw(tb_b1_raw), .b2_raw(tb_b2_raw), .b3_raw(tb_b3_raw),
        .c00(tb_c00), .c01(tb_c01), .c02(tb_c02), .c03(tb_c03),
        .c10(tb_c10), .c11(tb_c11), .c12(tb_c12), .c13(tb_c13),
        .c20(tb_c20), .c21(tb_c21), .c22(tb_c22), .c23(tb_c23),
        .c30(tb_c30), .c31(tb_c31), .c32(tb_c32), .c33(tb_c33),
        .valid_out(tb_valid_out)
    );
    
    initial begin 
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    
    initial begin 
        tb_reset = 1'b1;
        tb_start = 1'b0;
        tb_a0_raw = 8'sd0; tb_a1_raw = 8'sd0; tb_a2_raw = 8'sd0; tb_a3_raw = 8'sd0;
        tb_b0_raw = 8'sd0; tb_b1_raw = 8'sd0; tb_b2_raw = 8'sd0; tb_b3_raw = 8'sd0;
        #20;
        
        tb_reset = 1'b0;
        #10;
        tb_start = 1'b1;
        #10;
        
        tb_start = 1'b0;
        #10;
        
        tb_a0_raw = 8'sd1; tb_a1_raw = 8'sd1; tb_a2_raw = 8'sd2; tb_a3_raw = 8'sd0;
        tb_b0_raw = 8'sd1; tb_b1_raw = 8'sd0; tb_b2_raw = 8'sd0; tb_b3_raw = 8'sd0;
        #10;
        
        tb_a0_raw = 8'sd2; tb_a1_raw = 8'sd1; tb_a2_raw = 8'sd0; tb_a3_raw = 8'sd1;
        tb_b0_raw = 8'sd0; tb_b1_raw = 8'sd1; tb_b2_raw = 8'sd0; tb_b3_raw = 8'sd0;
        #10;
        
        tb_a0_raw = 8'sd3; tb_a1_raw = 8'sd1; tb_a2_raw = 8'sd2; tb_a3_raw = 8'sd0;
        tb_b0_raw = 8'sd0; tb_b1_raw = 8'sd0; tb_b2_raw = 8'sd1; tb_b3_raw = 8'sd0;
        #10;
        
        tb_a0_raw = 8'sd4; tb_a1_raw = 8'sd1; tb_a2_raw = 8'sd0; tb_a3_raw = 8'sd1;
        tb_b0_raw = 8'sd0; tb_b1_raw = 8'sd0; tb_b2_raw = 8'sd0; tb_b3_raw = 8'sd1;
        #10;
        
        tb_a0_raw = 8'sd0; tb_a1_raw = 8'sd0; tb_a2_raw = 8'sd0; tb_a3_raw = 8'sd0;
        tb_b0_raw = 8'sd0; tb_b1_raw = 8'sd0; tb_b2_raw = 8'sd0; tb_b3_raw = 8'sd0;
        #120;
        
        $finish;
    end
    
endmodule
