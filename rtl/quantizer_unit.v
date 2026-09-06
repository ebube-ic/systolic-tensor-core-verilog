`timescale 1ns / 1ps

module quantizer_unit #(
    parameter integer SCALE_SHIFT = 0
)(
    input wire signed [31:0] data_in,
    input wire relu_en,
    output reg signed [7:0] data_out
    );
    
    wire signed [31:0] shifted_data;
    assign shifted_data = data_in >>> SCALE_SHIFT;
    
    always @(*) begin 
        if (shifted_data > 32'sd127) begin 
            data_out = 8'sd127;
        end else if (shifted_data < -32'sd128) begin 
            data_out = -8'sd128;
        end else begin 
            data_out = shifted_data[7:0];
        end
        
        if (relu_en && (data_out < 8'sd0)) begin 
            data_out = 8'sd0;
        end
    end
endmodule
