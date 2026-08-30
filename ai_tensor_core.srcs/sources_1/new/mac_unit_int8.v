`timescale 1ns / 1ps

module mac_unit_int8(
        input wire clk,
        input wire reset,
        input wire enable,
        input wire clr_accum,
        input wire signed [7:0] a,
        input wire signed [7:0] b,
        output reg signed [31:0] accum
    );
    
    wire signed [15:0] mult_product;
    assign mult_product = a * b;
    
    always @(posedge clk) begin 
        if (reset || clr_accum) begin 
            accum <= 32'sd0;
        end else if (enable) begin 
            accum <= accum + mult_product;
        end
    end
endmodule
