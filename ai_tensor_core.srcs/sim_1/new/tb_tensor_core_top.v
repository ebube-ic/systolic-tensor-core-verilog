`timescale 1ns / 1ps

module tb_tensor_core_top;
    reg tb_clk;
    reg tb_reset;
    reg tb_start;
    reg signed [31:0] tb_vec_a;
    reg signed [31:0] tb_vec_b;
    wire signed [31:0] tb_accum_0;
    wire signed [31:0] tb_accum_1;
    wire signed [31:0] tb_accum_2;
    wire signed [31:0] tb_accum_3;
    wire [31:0] tb_dot_product_total;
    wire tb_valid_out;
    
    tensor_core_top uut (
        .clk(tb_clk),
        .reset(tb_reset),
        .start(tb_start),
        .vec_a(tb_vec_a),
        .vec_b(tb_vec_b),
        .accum_0(tb_accum_0),
        .accum_1(tb_accum_1),
        .accum_2(tb_accum_2),
        .accum_3(tb_accum_3),
        .dot_product_total(tb_dot_product_total),
        .valid_out(tb_valid_out)
    );
    
    initial begin 
        tb_clk = 1'b0;
        forever #5 tb_clk = ~tb_clk;
    end
    
    initial begin 
        tb_reset = 1'b1;
        tb_start = 1'b0;
        tb_vec_a = 32'sd0;
        tb_vec_b = 32'sd0;
        #15;
        
        tb_reset = 1'b0;
        #10;
        
        // 1. Trigger Start Pulse (FSM moves to S_CLEAR)
        tb_start = 1'b1;
        #10;
        tb_start = 1'b0;
        #10;

        // 2. Cycle 0 (S_COMPUTE begins): Feed Vector 1
        // [4, 3, 2, 1] dot [2, 2, 2, 2] = 8 + 6 + 4 + 2 = 20
        tb_vec_a = {8'sd4, 8'sd3, 8'sd2, 8'sd1};
        tb_vec_b = {8'sd2, 8'sd2, 8'sd2, 8'sd2};
        #10;
        
        // 3. Cycle 1 (S_COMPUTE continues): Feed Vector 2
        // [1, -2, 3, 0] dot [5, 2, 1, 10] -> Note: b[0] set to 10
        // (1*5) + (-2*2) + (3*1) + (0*10) = 5 - 4 + 3 + 0 = 4
        // Running Total = 20 + 4 = 24
        tb_vec_a = {8'sd1, -8'sd2, 8'sd3, 8'sd0};
        tb_vec_b = {8'sd5,  8'sd2, 8'sd1, 8'sd10};
        #10;
        
        // 4. S_DONE: Clear bus and hold
        tb_vec_a = 32'sd0;
        tb_vec_b = 32'sd0;
        #40;        
        $finish;
    end
    endmodule
