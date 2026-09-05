`timescale 1ns / 1ps

module systolic_deskew_4x4(
        input clk, reset, enable,
        input wire signed [31:0] col0_in,
        input wire signed [31:0] col1_in,
        input wire signed [31:0] col2_in,
        input wire signed [31:0] col3_in,
        output reg signed [31:0] col0_out,
        output reg signed [31:0] col1_out,
        output reg signed [31:0] col2_out,
        output reg signed [31:0] col3_out
    );
    
    reg [31:0] c0_pipe1;
    reg [31:0] c0_pipe2;
    reg [31:0] c0_pipe3;
    
    reg [31:0] c1_pipe1;
    reg [31:0] c1_pipe2;
    
    reg [31:0] c2_pipe1;
    
    always @(posedge clk) begin 
        if (reset) begin 
            c0_pipe1 <= 32'sd0;
            c0_pipe2 <= 32'sd0;
            c0_pipe3 <= 32'sd0;
            col0_out <= 32'sd0;
            
            c1_pipe1 <= 32'sd0;
            c1_pipe2 <= 32'sd0;
            col1_out <= 32'sd0;
            
            c2_pipe1 <= 32'sd0;
            col2_out <= 32'sd0;
        end else if (enable) begin 
            c0_pipe1 <= col0_in;
            c0_pipe2 <= c0_pipe1;
            c0_pipe3 <= c0_pipe2;
            col0_out <= c0_pipe3;
            
            c1_pipe1 <= col1_in;
            c1_pipe2 <= c1_pipe1;
            col1_out <= c1_pipe2;
            
            c2_pipe1 <= col2_in;
            col2_out <= c2_pipe1;
            
            col3_out <= col3_in;
        end
    end
endmodule
