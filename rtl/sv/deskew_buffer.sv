`timescale 1ns / 1ps

import tensor_pkg::*;

module deskew_buffer #(
    parameter int N = ARRAY_SIZE,
    parameter int A = ACCUM_WIDTH
)(
    input logic clk,
    input logic rst_n,
    input logic clr,
    input matrix_accum_t accum_in,
    output matrix_accum_t accum_out
    );
    
    localparam int MAX_LATENCY = (2 * N) - 2;
    
    genvar r, c;
    generate 
        for (r = 0; r < N; r++) begin : gen_deskew_row 
            for (c = 0; c < N; c++) begin : gen_deskew_col 
                localparam int DELAY = MAX_LATENCY - (r + c);
                if (DELAY == 0) begin : gen_pass_through 
                    assign accum_out[r][c] = accum_in[r][c];
                end else begin : gen_delay_pipeline 
                    logic signed [A-1:0] shift_reg [DELAY];
                    always_ff @(posedge clk or negedge rst_n) begin 
                        if (!rst_n || clr) begin 
                            for (int k = 0; k < DELAY; k++)
                                shift_reg[k] <= '0;
                        end else begin 
                            shift_reg[0] <= accum_in[r][c];
                            for (int k = 1; k < DELAY; k++) begin 
                                shift_reg[k] <= shift_reg[k-1];
                            end
                        end
                    end
                    assign accum_out[r][c] = shift_reg[DELAY-1];
                end
            end
        end
    endgenerate
endmodule
