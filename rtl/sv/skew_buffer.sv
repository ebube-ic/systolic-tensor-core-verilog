`timescale 1ns / 1ps

import tensor_pkg::*;

module skew_buffer #(
    parameter int N = ARRAY_SIZE,
    parameter int W = DATA_WIDTH
)(
    input logic clk,
    input logic rst_n,
    input logic clr,
    input vec_data_t data_in,
    output vec_data_t data_out
    );
    
    logic signed [W-1:0] shift_regs [N][N];
    
    assign data_out[0] = data_in[0];
    
    genvar r, s;
    generate
        for (r = 1; r < N; r++) begin : gen_skew_row
            always_ff @(posedge clk or negedge rst_n) begin 
                if (!rst_n || clr) begin 
                    shift_regs[r][0] <= '0;
                end else begin
                    shift_regs[r][0] <= data_in[r];
                end
            end
            for (s=1; s<r; s++) begin : gen_shift_chain
                always_ff @(posedge clk or negedge rst_n) begin 
                    if (!rst_n || clr) begin 
                        shift_regs[r][s] <= '0;
                    end else begin
                        shift_regs[r][s] <= shift_regs[r][s-1];
                    end
                end
            end
        assign data_out[r] = shift_regs[r][r-1];
        end
    endgenerate
endmodule
