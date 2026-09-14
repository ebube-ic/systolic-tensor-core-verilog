`timescale 1ns / 1ps

import tensor_pkg::*;

module systolic_grid #(
    parameter int N = ARRAY_SIZE,
    parameter int W = DATA_WIDTH,
    parameter int A = ACCUM_WIDTH
)(
    input logic clk,
    input logic rst_n,
    input logic clr,
    input vec_data_t a_row_in,
    input vec_data_t b_col_in,
    output matrix_accum_t accum_out
    );
    
    logic [W-1:0] a_net [N][N+1];
    logic [W-1:0] b_net [N+1][N];
    
    genvar r, c;
    generate
        for (r = 0; r < N; r++) begin : gen_boundary_a 
            assign a_net[r][0] = a_row_in[r];
        end
        for (c = 0; c < N; c++) begin : gen_boundary_b
            assign b_net[0][c] = b_col_in[c];
        end
        
        for (r = 0; r < N; r++) begin : gen_grid_rows 
            for (c = 0; c < N; c++) begin : gen_grid_cols 
                pe #(
                    .DATA_WIDTH(W),
                    .ACCUM_WIDTH(A)
                ) u_pe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .clr(clr),
                    .a_in(a_net[r][c]),
                    .b_in(b_net[r][c]),
                    .a_out(a_net[r][c+1]),
                    .b_out(b_net[r+1][c]),
                    .accum(accum_out[r][c])
                );
            end
        end
    endgenerate
endmodule
