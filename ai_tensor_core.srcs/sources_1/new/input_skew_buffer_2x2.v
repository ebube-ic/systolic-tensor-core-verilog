`timescale 1ns / 1ps

module input_skew_buffer_2x2(
    input wire clk,
    input wire reset,
    input wire clr_accum,
    input wire enable,
    input wire signed [7:0] a0_raw,
    input wire signed [7:0] a1_raw,
    input wire signed [7:0] b0_raw,
    input wire signed [7:0] b1_raw,
    output wire signed [7:0] a0_skewed,
    output reg signed [7:0] a1_skewed,
    output wire signed [7:0] b0_skewed,
    output reg signed [7:0] b1_skewed
    );
    
    assign a0_skewed = a0_raw;
    assign b0_skewed = b0_raw;
    
    always @(posedge clk) begin 
        if (reset) begin 
            a1_skewed <= 0;
            b1_skewed <= 0;
        end else if (clr_accum) begin 
            a1_skewed <= 0;
            b1_skewed <= 0;
        end else if (enable) begin 
            a1_skewed <= a1_raw;
            b1_skewed <= b1_raw;
        end
    end
    
endmodule
