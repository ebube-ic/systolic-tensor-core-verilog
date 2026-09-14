`timescale 1ns / 1ps

import tensor_pkg::*;

module quant_relu #(
    parameter int N = ARRAY_SIZE,
    parameter int A = ACCUM_WIDTH,
    parameter int W = DATA_WIDTH
)(
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic [3:0] shift_val,
    input matrix_accum_t data_in,
    output logic valid_out,
    output matrix_out_t data_out
    );
    
    genvar r, c;
    generate
        for (r = 0; r < N; r++) begin : gen_quant_row 
            for (c = 0; c < N; c++) begin : gen_quant_col 
                logic signed [A-1:0] scaled_val;
                assign scaled_val = data_in[r][c] >>> shift_val;
                
                always_ff @(posedge clk or negedge rst_n) begin 
                    if (!rst_n) begin 
                        data_out[r][c] <= '0;
                    end else if (valid_in) begin 
                        if (scaled_val <= 0) begin 
                            data_out[r][c] <= '0;
                        end else if (scaled_val > 127) begin 
                            data_out[r][c] <= 8'd127;
                        end else begin 
                            data_out[r][c] <= scaled_val[W-1:0];
                        end
                    end
                end
            end
        end
    endgenerate
    
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            valid_out <= '0;
        end else begin 
            valid_out <= valid_in;
        end
    end
endmodule
