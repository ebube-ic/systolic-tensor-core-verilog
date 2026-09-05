`timescale 1ns / 1ps

module systolic_tensor_core_2x2(
        input wire clk,
        input wire reset,
        input wire start,
        input wire signed [7:0] a0_in,
        input wire signed [7:0] b0_in,
        input wire signed [7:0] a1_in,
        input wire signed [7:0] b1_in,
        output wire signed [31:0] c00,
        output wire signed [31:0] c01,
        output wire signed [31:0] c10,
        output wire signed [31:0] c11,
        output wire valid_out
    );
    
    wire ctrl_clr_accum;
    wire ctrl_enable;
    wire signed [7:0] a0_skewed;
    wire signed [7:0] b0_skewed;
    wire signed [7:0] a1_skewed;
    wire signed [7:0] b1_skewed;
    
    input_skew_buffer_2x2 skew_buf_inst (
        .clk(clk),
        .reset(reset),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .a0_raw(a0_in),
        .b0_raw(b0_in),
        .a1_raw(a1_in),
        .b1_raw(b1_in),
        .a0_skewed(a0_skewed),
        .b0_skewed(b0_skewed),
        .a1_skewed(a1_skewed),
        .b1_skewed(b1_skewed)
    );
    
    systolic_array_2x2 systolic_array_inst (
        .clk(clk),
        .reset(reset),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .a0_in(a0_skewed),
        .b0_in(b0_skewed),
        .a1_in(a1_skewed),
        .b1_in(b1_skewed),
        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );
    
    systolic_controller_2x2 controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .valid_out(valid_out)
    );
endmodule
