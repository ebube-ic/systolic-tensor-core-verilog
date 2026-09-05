`timescale 1ns / 1ps

module systolic_array_2x2(
        input wire clk,
        input wire reset,
        input wire clr_accum,
        input wire enable,
        
        input wire signed [7:0] a0_in,
        input wire signed [7:0] b0_in,
        
        input wire signed [7:0] a1_in,
        input wire signed [7:0] b1_in,
        
        output wire signed [31:0] c00,
        output wire signed [31:0] c01,
        output wire signed [31:0] c10,
        output wire signed [31:0] c11
    );
    
    wire signed [7:0] a00_to_a01;
    wire signed [7:0] a10_to_a11;
    wire signed [7:0] b00_to_b10;
    wire signed [7:0] b01_to_b11;
    
    systolic_pe pe00 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a_in(a0_in),
        .b_in(b0_in),
        .a_out(a00_to_a01),
        .b_out(b00_to_b10),
        .accum(c00)
    );
    systolic_pe pe01 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a_in(a00_to_a01),
        .b_in(b1_in),
        .a_out(),
        .b_out(b01_to_b11),
        .accum(c01)
    );
    systolic_pe pe10 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a_in(a1_in),
        .b_in(b00_to_b10),
        .a_out(a10_to_a11),
        .b_out(),
        .accum(c10)
    );
    systolic_pe pe11 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a_in(a10_to_a11),
        .b_in(b01_to_b11),
        .a_out(),
        .b_out(),
        .accum(c11)
    );
    
endmodule
