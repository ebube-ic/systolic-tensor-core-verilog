`timescale 1ns / 1ps

import tensor_pkg::*;

module tensor_ctrl_fsm #(
    parameter int N = ARRAY_SIZE
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    output logic clr,
    output logic busy,
    output logic in_ready,
    output logic out_valid,
    output logic done
    );
    
    localparam int TOTAL_RUN_CYCLES = (3 * N) - 1;
    
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        CLEAR = 2'b01,
        RUN = 2'b10,
        FINISH = 2'b11
    } state_t;
    
    state_t state;
    int cycle_cnt;
    
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            state <= IDLE;
            cycle_cnt <= '0;
            clr <= '0;
            busy <= '0;
            in_ready <= '0;
            out_valid <= '0;
            done <= '0;
        end else begin 
            clr <= '0;
            out_valid <= '0;
            done <= '0;
            case (state) 
                IDLE: begin 
                    busy <= '0;
                    in_ready <= '0;
                    cycle_cnt <= 0;
                    if (start) begin 
                        clr <= '1;
                        busy <= '1;
                        state <= CLEAR;
                    end
                end
                
                CLEAR: begin
                    in_ready <= '1;
                    cycle_cnt <= '0;
                    state <= RUN;
                end
                
                RUN: begin 
                    cycle_cnt <= cycle_cnt + 1;
                    
                    if (cycle_cnt == N - 1) begin 
                        in_ready <= '0;
                    end
                    
                    if (cycle_cnt == TOTAL_RUN_CYCLES - 1) begin
                        out_valid <= '1;
                        state <= FINISH;
                    end
                end
                
                FINISH: begin 
                    done <= '1;
                    busy <= '0;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
