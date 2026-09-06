`timescale 1ns / 1ps

module quantizer_4x4 #(
    parameter integer SCALE_SHIFT=0
)(
    input wire signed [31:0] c00_in, c01_in, c02_in, c03_in,
    input wire signed [31:0] c10_in, c11_in, c12_in, c13_in,
    input wire signed [31:0] c20_in, c21_in, c22_in, c23_in,
    input wire signed [31:0] c30_in, c31_in, c32_in, c33_in,
    input wire relu_en,
    output wire signed [7:0] c00_out, c01_out, c02_out, c03_out,
    output wire signed [7:0] c10_out, c11_out, c12_out, c13_out,
    output wire signed [7:0] c20_out, c21_out, c22_out, c23_out,
    output wire signed [7:0] c30_out, c31_out, c32_out, c33_out
    );
    
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q00 (.data_in(c00_in), .relu_en(relu_en), .data_out(c00_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q01 (.data_in(c01_in), .relu_en(relu_en), .data_out(c01_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q02 (.data_in(c02_in), .relu_en(relu_en), .data_out(c02_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q03 (.data_in(c03_in), .relu_en(relu_en), .data_out(c03_out));
    
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q10 (.data_in(c10_in), .relu_en(relu_en), .data_out(c10_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q11 (.data_in(c11_in), .relu_en(relu_en), .data_out(c11_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q12 (.data_in(c12_in), .relu_en(relu_en), .data_out(c12_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q13 (.data_in(c13_in), .relu_en(relu_en), .data_out(c13_out));
  
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q20 (.data_in(c20_in), .relu_en(relu_en), .data_out(c20_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q21 (.data_in(c21_in), .relu_en(relu_en), .data_out(c21_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q22 (.data_in(c22_in), .relu_en(relu_en), .data_out(c22_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q23 (.data_in(c23_in), .relu_en(relu_en), .data_out(c23_out));
    
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q30 (.data_in(c30_in), .relu_en(relu_en), .data_out(c30_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q31 (.data_in(c31_in), .relu_en(relu_en), .data_out(c31_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q32 (.data_in(c32_in), .relu_en(relu_en), .data_out(c32_out));
    quantizer_unit #(.SCALE_SHIFT(SCALE_SHIFT)) q33 (.data_in(c33_in), .relu_en(relu_en), .data_out(c33_out));
endmodule
