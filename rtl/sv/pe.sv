`timescale 1ns / 1ps

module pe #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 32
)(
    input logic clk,
    input logic clr,
    input logic rst_n,
    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    output logic signed [DATA_WIDTH-1:0] a_out,
    output logic signed [DATA_WIDTH-1:0] b_out,
    output logic signed [ACCUM_WIDTH-1:0] accum
    );
    
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            a_out <= '0;
            b_out <= '0;
            accum <= '0;
        end else if (clr) begin 
            a_out <= '0;
            b_out <= '0;
            accum <= '0;
        end else begin 
            a_out <= a_in;
            b_out <= b_in;
            accum <= accum + (a_in * b_in);
        end
    end
endmodule
