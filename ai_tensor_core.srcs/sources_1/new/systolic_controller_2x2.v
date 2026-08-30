`timescale 1ns / 1ps

module systolic_controller_2x2(
        input wire clk,
        input wire reset,
        input wire start,
        output reg clr_accum,
        output reg enable,
        output reg valid_out
    );
    
    localparam S_IDLE = 2'b00;
    localparam S_CLEAR = 2'b01;
    localparam S_COMPUTE = 2'b10;
    localparam S_DONE = 2'b11;
    
    reg [1:0] state_reg, next_state;
    reg [2:0] cycle_count;
    
    always @(posedge clk) begin
        if (reset) begin 
            state_reg <= S_IDLE;
            cycle_count <= 3'b000;
        end else begin 
            state_reg <= next_state; 
            if (state_reg == S_COMPUTE) begin 
                cycle_count <= cycle_count + 1;
            end else begin 
                cycle_count <= 3'b000;
            end
        end
    end
    
    always @(*) begin 
        next_state <= state_reg;
        case (state_reg) 
            S_IDLE: begin 
                if (start) begin 
                    next_state <= S_CLEAR;
                end
            end
            S_CLEAR: begin 
                next_state <= S_COMPUTE;
            end
            S_COMPUTE: begin 
                if (cycle_count == 2'd3) begin 
                    next_state <= S_DONE;
                end
            end
            S_DONE: begin 
                next_state <= S_IDLE;
            end
        endcase
    end
    
    always @(*) begin 
        clr_accum <= 1'b0;
        enable <= 1'b0;
        valid_out <= 1'b0;
        
        case (state_reg) 
            S_CLEAR: begin
                clr_accum <= 1'b1;
            end
            S_COMPUTE: begin 
                enable <= 1'b1;
            end
            S_DONE: begin 
                valid_out <= 1'b1;
            end
        endcase
    end
    
endmodule
