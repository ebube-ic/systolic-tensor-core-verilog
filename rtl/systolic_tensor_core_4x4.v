`timescale 1ns / 1ps

module systolic_tensor_core_4x4 #(
    parameter integer SCALE_SHIFT=0
)(
        input wire clk,
        input wire reset,
        input wire start,
        input wire relu_en,
        input wire signed [7:0] a0_raw, a1_raw, a2_raw, a3_raw,
        input wire signed [7:0] b0_raw, b1_raw, b2_raw, b3_raw,
        output wire signed [7:0] c00, c01, c02, c03,
        output wire signed [7:0] c10, c11, c12, c13,
        output wire signed [7:0] c20, c21, c22, c23,
        output wire signed [7:0] c30, c31, c32, c33,
        output wire valid_out
    );
    wire ctrl_clr_accum;
    wire ctrl_enable;
    
    
    wire signed [7:0] a0_skewed, a1_skewed, a2_skewed, a3_skewed;
    wire signed [7:0] b0_skewed, b1_skewed, b2_skewed, b3_skewed;
    
    wire signed [31:0] c00_raw, c01_raw, c02_raw, c03_raw;
    wire signed [31:0] c10_raw, c11_raw, c12_raw, c13_raw;
    wire signed [31:0] c20_raw, c21_raw, c22_raw, c23_raw;
    wire signed [31:0] c30_raw, c31_raw, c32_raw, c33_raw;
    
    wire signed [31:0] c00_deskewed, c01_deskewed, c02_deskewed, c03_deskewed;
    wire signed [31:0] c10_deskewed, c11_deskewed, c12_deskewed, c13_deskewed;
    wire signed [31:0] c20_deskewed, c21_deskewed, c22_deskewed, c23_deskewed;
    wire signed [31:0] c30_deskewed, c31_deskewed, c32_deskewed, c33_deskewed;
    
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
        .c00(c00_raw), .c01(c01_raw), .c02(c02_raw), .c03(c03_raw),
        .c10(c10_raw), .c11(c11_raw), .c12(c12_raw), .c13(c13_raw),
        .c20(c20_raw), .c21(c21_raw), .c22(c22_raw), .c23(c23_raw),
        .c30(c30_raw), .c31(c31_raw), .c32(c32_raw), .c33(c33_raw)
    );
    systolic_deskew_2d_4x4 deskew_inst (
        .clk     (clk),
        .reset   (reset),
        .enable  (ctrl_enable),
        .c00_raw(c00_raw), .c01_raw(c01_raw), .c02_raw(c02_raw), .c03_raw(c03_raw),
        .c10_raw(c10_raw), .c11_raw(c11_raw), .c12_raw(c12_raw), .c13_raw(c13_raw),
        .c20_raw(c20_raw), .c21_raw(c21_raw), .c22_raw(c22_raw), .c23_raw(c23_raw),
        .c30_raw(c30_raw), .c31_raw(c31_raw), .c32_raw(c32_raw), .c33_raw(c33_raw),
        .c00(c00_deskewed), .c01(c01_deskewed), .c02 (c02_deskewed), .c03(c03_deskewed),
        .c10(c10_deskewed), .c11(c11_deskewed), .c12 (c12_deskewed), .c13(c13_deskewed),
        .c20(c20_deskewed), .c21(c21_deskewed), .c22 (c22_deskewed), .c23(c23_deskewed),
        .c30(c30_deskewed), .c31(c31_deskewed), .c32 (c32_deskewed), .c33(c33_deskewed)
    );
    quantizer_4x4 #(
        .SCALE_SHIFT(SCALE_SHIFT)
    ) quant_inst (
        .c00_in(c00_deskewed), .c01_in(c01_deskewed), 
        .c02_in(c02_deskewed), .c03_in(c03_deskewed),
        .c10_in(c10_deskewed), .c11_in(c11_deskewed), 
        .c12_in(c12_deskewed), .c13_in(c13_deskewed),
        .c20_in(c20_deskewed), .c21_in(c21_deskewed), 
        .c22_in(c22_deskewed), .c23_in(c23_deskewed),
        .c30_in(c30_deskewed), .c31_in(c31_deskewed), 
        .c32_in(c32_deskewed), .c33_in(c33_deskewed),
        .relu_en(relu_en),
        .c00_out(c00), .c01_out(c01), .c02_out(c02), .c03_out(c03),
        .c10_out(c10), .c11_out(c11), .c12_out(c12), .c13_out(c13),
        .c20_out(c20), .c21_out(c21), .c22_out(c22), .c23_out(c23),
        .c30_out(c30), .c31_out(c31), .c32_out(c32), .c33_out(c33)
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
