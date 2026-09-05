`timescale 1ns / 1ps

module tb_pe_array_1d;
        reg tb_clk;
        reg tb_reset;
        reg tb_clr_accum;
        reg tb_enable;
        reg signed [31:0] tb_vec_a;
        reg signed [31:0] tb_vec_b;
        wire signed [31:0] tb_accum_0;
        wire signed [31:0] tb_accum_1;
        wire signed [31:0] tb_accum_2;
        wire signed [31:0] tb_accum_3;
        wire signed [31:0] tb_dot_product_total;
        
        pe_array_1d uut (
            .clk(tb_clk),
            .reset(tb_reset),
            .clr_accum(tb_clr_accum),
            .enable(tb_enable),
            .vec_a(tb_vec_a),
            .vec_b(tb_vec_b),
            .accum_0(tb_accum_0),
            .accum_1(tb_accum_1),
            .accum_2(tb_accum_2),
            .accum_3(tb_accum_3),
            .dot_product_total(tb_dot_product_total)
        );
        
        initial begin 
            tb_clk = 1'b0;
            forever #5 tb_clk = ~tb_clk;
        end
        
        initial begin 
            tb_reset = 1'b1;
            tb_enable = 1'b0;
            tb_clr_accum = 1'b0;
            tb_vec_a = 32'sd0;
            tb_vec_b = 32'sd0;
            #15;
            
            tb_reset = 1'b0;
            tb_enable = 1'b1;
            
            tb_vec_a = {8'sd4, 8'sd3, 8'sd2, 8'sd1};
            tb_vec_b = {8'sd2, 8'sd2, 8'sd2, 8'sd2};
            #10;
            
            tb_vec_a = {8'sd1, -8'sd2, 8'sd3, 8'sd0};
            tb_vec_b = {8'sd5, 8'sd2, 8'sd1, 8'sd0};
            #10;
        
            $finish;
        end
endmodule
