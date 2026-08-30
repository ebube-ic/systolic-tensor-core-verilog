`timescale 1ns / 1ps

module systolic_pe(
        input wire clk,
        input wire reset,
        input wire clr_accum,
        input wire enable,
        input wire signed [7:0] a_in,
        input wire signed [7:0] b_in,
        output reg signed [7:0] a_out,
        output reg signed [7:0] b_out,
        output reg signed [31:0] accum
    );
    
    wire signed [31:0] mult_product;
    assign mult_product = a_in * b_in;
    
    always @(posedge clk) begin 
        if (reset) begin 
            a_out <= 8'sd0;
            b_out <= 8'sd0;
            accum <= 32'sd0;
        end else begin 
            if (clr_accum) begin 
                a_out <= 8'sd0;
                b_out <= 8'sd0;
                accum <= 32'sd0;
            end else if (enable) begin 
                accum <= accum + mult_product;
                a_out <= a_in;
                b_out <= b_in;
            end
        end
    end
    
endmodule
