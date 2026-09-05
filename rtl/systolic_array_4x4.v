`timescale 1ns / 1ps

module systolic_array_4x4(
        input wire clk,
        input wire reset,
        input wire clr_accum,
        input wire enable,
        input wire signed [7:0] a0_in, input wire signed [7:0] a1_in,
        input wire signed [7:0] a2_in, input wire signed [7:0] a3_in,
        input wire signed [7:0] b0_in, input wire signed [7:0] b1_in,
        input wire signed [7:0] b2_in, input wire signed [7:0] b3_in,
        output wire signed [31:0] c00, output wire signed [31:0] c01, output wire signed [31:0] c02, output wire signed [31:0] c03, 
        output wire signed [31:0] c10, output wire signed [31:0] c11, output wire signed [31:0] c12, output wire signed [31:0] c13, 
        output wire signed [31:0] c20, output wire signed [31:0] c21, output wire signed [31:0] c22, output wire signed [31:0] c23, 
        output wire signed [31:0] c30, output wire signed [31:0] c31, output wire signed [31:0] c32, output wire signed [31:0] c33        
    );
    parameter N = 4;
    
    wire signed [7:0] a_grid [0:N-1][0:N];
    wire signed [7:0] b_grid [0:N][0:N-1];
    wire signed [31:0] accum_grid [0:N-1][0:N-1];
    
    assign a_grid[0][0] = a0_in;
    assign a_grid[1][0] = a1_in;
    assign a_grid[2][0] = a2_in;
    assign a_grid[3][0] = a3_in;
    
    assign b_grid[0][0] = b0_in;
    assign b_grid[0][1] = b1_in;
    assign b_grid[0][2] = b2_in;
    assign b_grid[0][3] = b3_in;
    
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : ROW 
            for (j = 0; j < N; j = j + 1) begin: COL 
                systolic_pe systolic_pe_inst (
                    .clk(clk),
                    .reset(reset),
                    .clr_accum(clr_accum),
                    .enable(enable),
                    .a_in(a_grid[i][j]),
                    .b_in(b_grid[i][j]),
                    .a_out(a_grid[i][j+1]),
                    .b_out(b_grid[i+1][j]),
                    .accum(accum_grid[i][j])
                );
            end
        end
    endgenerate    
    
    assign c00 = accum_grid[0][0]; assign c01 = accum_grid[0][1]; assign c02 = accum_grid[0][2]; assign c03 = accum_grid[0][3];
    assign c10 = accum_grid[1][0]; assign c11 = accum_grid[1][1]; assign c12 = accum_grid[1][2]; assign c13 = accum_grid[1][3];
    assign c20 = accum_grid[2][0]; assign c21 = accum_grid[2][1]; assign c22 = accum_grid[2][2]; assign c23 = accum_grid[2][3];
    assign c30 = accum_grid[3][0]; assign c31 = accum_grid[3][1]; assign c32 = accum_grid[3][2]; assign c33 = accum_grid[3][3];
    
endmodule
