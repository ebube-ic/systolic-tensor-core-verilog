`timescale 1ns / 1ps

module tensor_core_top(
        input wire clk,
        input wire reset,
        input wire start,
        input wire signed [31:0] vec_a,
        input wire signed [31:0] vec_b,
        output wire signed [31:0] accum_0,
        output wire signed [31:0] accum_1,
        output wire signed [31:0] accum_2,
        output wire signed [31:0] accum_3,
        output wire [31:0] dot_product_total,
        output wire valid_out
    );
    
    wire ctrl_clr_accum;
    wire ctrl_enable;
    
    pe_array_1d pe_array_inst (
        .clk(clk),
        .reset(reset),
        .vec_a(vec_a),
        .vec_b(vec_b),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .accum_0(accum_0),
        .accum_1(accum_1),
        .accum_2(accum_2),
        .accum_3(accum_3),
        .dot_product_total(dot_product_total)
    );
    
    tensor_controller_fsm controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .clr_accum(ctrl_clr_accum),
        .enable(ctrl_enable),
        .valid_out(valid_out)
    );
endmodule
