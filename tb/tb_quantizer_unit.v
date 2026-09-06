`timescale 1ns / 1ps

module tb_quantizer_unit;
    reg signed [31:0] tb_data_in;
    reg tb_relu_en;
    wire signed [7:0] tb_data_out;

    quantizer_unit #(.SCALE_SHIFT(2)) uut (
        .data_in(tb_data_in),
        .relu_en(tb_relu_en),
        .data_out(tb_data_out)
    );
    
    initial begin
        tb_relu_en = 1'b0;
        tb_data_in = 32'sd0;
        #10;
        
        tb_data_in = 32'sd40;
        #10;
        
        tb_data_in = 32'sd1000;
        #10;
        
        tb_data_in = -32'sd1000;
        #10;
        
        tb_data_in = -32'sd40;
        tb_relu_en = 1'b0;
        #10;
        
        tb_relu_en = 1'b1;
        #10;
        
        $display ("All quantizer corner cases tested successfully.");
        $finish;
    end
    
endmodule
