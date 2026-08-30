`timescale 1ns / 1ps

module systolic_tensor_core_4x4(
        input wire clk,
        input wire reset,
        input wire start,
        input wire signed [7:0] a0_raw, input wire signed [7:0] a1_raw, 
        input wire signed [7:0] a2_raw, input wire signed [7:0] a3_raw,
        input wire signed [7:0] b0_raw, input wire signed [7:0] b1_raw, 
        input wire signed [7:0] b2_raw, input wire signed [7:0] b3_raw,
        output wire signed [31:0] c00, output wire signed [31:0] c01, 
        output wire signed [31:0] c02, output wire signed [31:0] c03,
        output wire signed [31:0] c10, output wire signed [31:0] c11, 
        output wire signed [31:0] c12, output wire signed [31:0] c13,
        output wire signed [31:0] c20, output wire signed [31:0] c21, 
        output wire signed [31:0] c22, output wire signed [31:0] c23,
        output wire signed [31:0] c30, output wire signed [31:0] c31, 
        output wire signed [31:0] c32, output wire signed [31:0] c33,
        output wire valid_out
    );
    wire ctrl_clr_accum;
    wire ctrl_enable;
    
    
    wire signed [7:0] a0_skewed; wire signed [7:0] a1_skewed;
    wire signed [7:0] a2_skewed; wire signed [7:0] a3_skewed;
    wire signed [7:0] b0_skewed; wire signed [7:0] b1_skewed; 
    wire signed [7:0] b2_skewed; wire signed [7:0] b3_skewed;
    
    input_skew_buffer_4x4 skew_buf_inst (
        .clk(clk),
        .reset(reset),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .a0_raw(a0_raw), .a1_raw(a1_raw), .a2_raw(a2_raw), .a3_raw(a3_raw),
        .b0_raw(b0_raw), .b1_raw(b1_raw), .b2_raw(b2_raw), .b3_raw(b3_raw),
        .a0_skewed(a0_skewed), .a1_skewed(a1_skewed), .a2_skewed(a2_skewed), .a3_skewed(a3_skewed),
        .b0_skewed(b0_skewed), .b1_skewed(b1_skewed), .b2_skewed(b2_skewed), .b3_skewed(b3_skewed)
    );
    systolic_array_4x4 systolic_arr_inst (
        .clk(clk),
        .reset(reset),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .a0_in(a0_skewed), .a1_in(a1_skewed), .a2_in(a2_skewed), .a3_in(a3_skewed),
        .b0_in(b0_skewed), .b1_in(b1_skewed), .b2_in(b2_skewed), .b3_in(b3_skewed),
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );
    systolic_controller_4x4 controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .valid_out(valid_out)
    );
    
endmodule
