`timescale 1ns / 1ps

import tensor_pkg::*;

module ping_pong_buffer #(
    parameter int N = ARRAY_SIZE
)(
    input logic clk,
    input logic rst_n,
    input logic swap_banks,
    output logic current_bank,
    input logic host_we,
    input logic [$clog2(N)-1:0] host_addr,
    input vec_data_t host_wdata,
    input logic [$clog2(N)-1:0] core_raddr,
    output vec_data_t core_rdata
    );
    
    logic bank_sel;
    assign current_bank = bank_sel;
    
    vec_data_t bank0 [N];
    vec_data_t bank1 [N];
    
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            bank_sel <= 1'b0;
        end else if (swap_banks) begin 
            bank_sel <= ~bank_sel;
        end
    end
    
    always_ff @(posedge clk) begin 
        if (host_we) begin 
            if (bank_sel == 1'b0) begin 
                bank1[host_addr] <= host_wdata;
            end else begin 
                bank0[host_addr] <= host_wdata;
            end
        end
    end
    
    always_ff @(posedge clk) begin 
        if (bank_sel == 1'b0) begin 
            core_rdata <= bank0[core_raddr];
        end else begin 
            core_rdata <= bank1[core_raddr];
        end
    end
endmodule
