`timescale 1ns / 1ps

module input_skew_buffer_4x4(
        input wire clk,
        input wire reset,
        input wire clr_accum,
        input wire enable,
        input wire signed [7:0] a0_raw, input wire signed [7:0] a1_raw, input wire signed [7:0] a2_raw, input wire signed [7:0] a3_raw,
        input wire signed [7:0] b0_raw, input wire signed [7:0] b1_raw, input wire signed [7:0] b2_raw, input wire signed [7:0] b3_raw,
        output wire signed [7:0] a0_skewed, output reg signed [7:0] a1_skewed, output reg signed [7:0] a2_skewed, output reg signed [7:0] a3_skewed,
        output wire signed [7:0] b0_skewed, output reg signed [7:0] b1_skewed, output reg signed [7:0] b2_skewed, output reg signed [7:0] b3_skewed
    );
    
    assign a0_skewed = a0_raw;
    assign b0_skewed = b0_raw;
    
    reg signed [7:0] a2_pipe_1;
    reg signed [7:0] b2_pipe_1;

    reg signed [7:0] a3_pipe_1;
    reg signed [7:0] b3_pipe_1;
    reg signed [7:0] a3_pipe_2;
    reg signed [7:0] b3_pipe_2;
    
    always @(posedge clk) begin 
        if (reset || clr_accum) begin 
            a1_skewed <= 8'sd0;
            b1_skewed <= 8'sd0;
            a2_pipe_1 <= 8'sd0;
            a2_skewed <= 8'sd0;
            b2_pipe_1 <= 8'sd0;
            b2_skewed <= 8'sd0;
            a3_skewed <= 8'sd0;
            a3_pipe_1 <= 8'sd0;
            a3_pipe_2 <= 8'sd0;
            b3_skewed <= 8'sd0;
            b3_pipe_1 <= 8'sd0;
            b3_pipe_2 <= 8'sd0;
        end else if (enable) begin 
            a1_skewed <= a1_raw;
            b1_skewed <= b1_raw;
            
            a2_pipe_1 <= a2_raw; a2_skewed <= a2_pipe_1;
            b2_pipe_1 <= b2_raw; b2_skewed <= b2_pipe_1;
            
            a3_pipe_1 <= a3_raw; a3_pipe_2 <= a3_pipe_1; a3_skewed <= a3_pipe_2;
            b3_pipe_1 <= b3_raw; b3_pipe_2 <= b3_pipe_1; b3_skewed <= b3_pipe_2;
        end
    end
    
endmodule
