`timescale 1ns / 1ps

module systolic_deskew_2d_4x4(
    input clk, reset, enable,
    input signed [31:0] c00_raw, c01_raw, c02_raw, c03_raw,
    input signed [31:0] c10_raw, c11_raw, c12_raw, c13_raw,
    input signed [31:0] c20_raw, c21_raw, c22_raw, c23_raw,
    input signed [31:0] c30_raw, c31_raw, c32_raw, c33_raw,
    output reg signed [31:0] c00, c01, c02, c03,
    output reg signed [31:0] c10, c11, c12, c13,
    output reg signed [31:0] c20, c21, c22, c23,
    output reg signed [31:0] c30, c31, c32, c33
    );
    
    reg signed [31:0] d6_c00 [0:5];
    reg signed [31:0] d5_c01 [0:4], d5_c10 [0:4];
    reg signed [31:0] d4_c02 [0:3], d4_c11 [0:3], d4_c20 [0:3];
    reg signed [31:0] d3_c03 [0:2], d3_c12 [0:2], d3_c21 [0:2], d3_c30 [0:2];
    reg signed [31:0] d2_c13 [0:1], d2_c22 [0:1], d2_c31 [0:1];
    reg signed [31:0] d1_c23, d1_c32;
    
    integer k;
    
    always @(posedge clk) begin 
        if (reset) begin 
            for (k=0; k<6; k=k+1) d6_c00[k] <= 32'sd0;
            for (k=0; k<5; k=k+1) begin d5_c01[k] <= 32'sd0; d5_c10[k] <= 32'sd0; end
            for (k=0; k<4; k=k+1) begin d4_c02[k] <= 32'sd0; d4_c11[k] <= 32'sd0; d4_c20[k] <= 32'sd0; end
            for (k=0; k<3; k=k+1) begin d3_c03[k] <= 32'sd0; d3_c12[k] <= 32'sd0; d3_c21[k] <= 32'sd0; d3_c30[k] <= 32'sd0; end
            for (k=0; k<2; k=k+1) begin d2_c13[k] <= 32'sd0; d2_c22[k] <= 32'sd0; d2_c31[k] <= 32'sd0; end
            d1_c23 <= 32'sd0; d1_c32 <= 32'sd0;
            
            c00 <= 32'sd0; c01 <= 32'sd0; c02 <= 32'sd0; c03 <= 32'sd0;
            c10 <= 32'sd0; c11 <= 32'sd0; c12 <= 32'sd0; c13 <= 32'sd0;
            c20 <= 32'sd0; c21 <= 32'sd0; c22 <= 32'sd0; c23 <= 32'sd0;
            c30 <= 32'sd0; c31 <= 32'sd0; c32 <= 32'sd0; c33 <= 32'sd0;
        end else if (enable) begin 
            d6_c00[0] <= c00_raw;
            for (k=0; k <5; k=k+1) begin 
                d6_c00[k+1] <= d6_c00[k];
            end
            c00 <= d6_c00[5];
            
            d5_c01[0] <= c01_raw; d5_c10[0] <= c10_raw;
            for (k=0; k<4; k=k+1) begin 
                d5_c01[k+1] <= d5_c01[k]; d5_c10[k+1] <= d5_c10[k];
            end
            c01 <= d5_c01[4]; c10 <= d5_c10[4];
            
            d4_c02[0] <= c02_raw; d4_c11[0] <= c11_raw; d4_c20[0] <= c20_raw;
            for (k=0; k<3; k=k+1) begin 
                d4_c02[k+1] <= d4_c02[k]; d4_c11[k+1] <= d4_c11[k]; d4_c20[k+1] <= d4_c20[k];
            end
            c02 <= d4_c02[3]; c11 <= d4_c11[3]; c20 <= d4_c20[3];
            
            d3_c03[0] <= c03_raw; d3_c12[0] <= c12_raw; d3_c21[0] <= c21_raw; d3_c30[0] <= c30_raw;
            for (k=0; k<2; k=k+1) begin 
                d3_c03[k+1] <= d3_c03[k]; d3_c12[k+1] <= d3_c12[k]; d3_c21[k+1] <= d3_c21[k]; d3_c30[k+1] <= d3_c30[k];
            end
            c03 <= d3_c03[2]; c12 <= d3_c12[2]; c21 <= d3_c21[2]; c30 <= d3_c30[2];
            
            d2_c13[0] <= c13_raw; d2_c22[0] <= c22_raw; d2_c31[0] <= c31_raw;
            d2_c13[1] <= d2_c13[0]; d2_c22[1] <= d2_c22[0]; d2_c31[1] <= d2_c31[0];
            c13 <= d2_c13[1]; c22 <= d2_c22[1]; c31 <= d2_c31[1];
            
            d1_c23 <= c23_raw; d1_c32 <= c32_raw;
            c23 <= d1_c23; c32 <= d1_c32;
            
            c33 <= c33_raw;
        end
    end
    
endmodule
