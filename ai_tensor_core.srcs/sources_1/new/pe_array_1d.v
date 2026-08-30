`timescale 1ns / 1ps

module pe_array_1d(
        input wire clk,
        input wire reset,
        input wire clr_accum,
        input wire enable,
        input wire signed [31:0] vec_a,
        input wire signed [31:0] vec_b,
        output wire signed [31:0] accum_0,
        output wire signed [31:0] accum_1,
        output wire signed [31:0] accum_2,
        output wire signed [31:0] accum_3,
        output wire signed [31:0] dot_product_total
    );
    
    mac_unit_int8 pe0 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a(vec_a[7:0]),
        .b(vec_b[7:0]),
        .accum(accum_0)
    );
    mac_unit_int8 pe1 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a(vec_a[15:8]),
        .b(vec_b[15:8]),
        .accum(accum_1)
    );
    mac_unit_int8 pe2 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a(vec_a[23:16]),
        .b(vec_b[23:16]),
        .accum(accum_2)
    );
    mac_unit_int8 pe3 (
        .clk(clk),
        .reset(reset),
        .clr_accum(clr_accum),
        .enable(enable),
        .a(vec_a[31:24]),
        .b(vec_b[31:24]),
        .accum(accum_3)
    );
    
    assign dot_product_total = accum_0 + accum_1 + accum_2 + accum_3;    
endmodule
