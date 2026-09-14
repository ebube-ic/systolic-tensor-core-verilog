`timescale 1ns / 1ps

module tensor_core_top #(
    parameter int N = ARRAY_SIZE,
    parameter int W = DATA_WIDTH,
    parameter int A = ACCUM_WIDTH
)(
    input logic clk,
    input logic rst_n,
    
    // Host Control & Status Interface
    input logic start,
    input logic swap_banks,
    input logic [3:0] shift_val,
    output logic busy,
    output logic done,
    output logic current_bank,
    
    // Host Memory Write Ports
    input logic host_we_a,
    input logic [$clog2(N)-1:0] host_addr_a,
    input vec_data_t host_wdata_a,
    
    input logic host_we_b,
    input logic [$clog2(N)-1:0] host_addr_b,
    input vec_data_t host_wdata_b,
    
    // Processed Output Matrix
    output logic out_valid,
    output matrix_out_t matrix_out
    );
    
    logic fsm_clr;
    logic fsm_in_ready;
    logic fsm_out_valid;
    
    // Ping Pong to Skew Buffer
    vec_data_t core_rdata_a;
    vec_data_t core_rdata_b;
    logic [$clog2(N)-1:0] core_raddr;
    
    // Skew Buffer to Systolic Grid
    vec_data_t skewed_a;
    vec_data_t skewed_b;
    
    // Systolic Grid Accumulator Output to Deskew Buffer
    matrix_accum_t grid_accum_out;
    
    // Deskew Buffer to Quantization/ReLU
    matrix_accum_t deskew_accum_out;
    
    // Simple Core Read Adress Generator
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n || fsm_clr) begin 
            core_raddr <= '0;
        end else if (fsm_in_ready) begin 
            core_raddr <= core_raddr + 1'b1;
        end else begin 
            core_raddr <= '0;
        end
    end
    
    // Gated Input Vectors (Array is zero when in_ready == 0)
    logic in_ready_d1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || fsm_clr) begin
            in_ready_d1 <= 1'b0;
        end else begin
            in_ready_d1 <= fsm_in_ready;
        end
    end
    
    vec_data_t gated_a, gated_b;
    genvar i;
    generate
        for (i = 0; i < N; i++) begin 
            assign gated_a[i] = in_ready_d1 ? core_rdata_a[i] : '0;
            assign gated_b[i] = in_ready_d1 ? core_rdata_b[i] : '0;
        end
    endgenerate
    
    // FSM Controller
    tensor_ctrl_fsm #(
        .N(N)
    ) u_ctrl_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .clr(fsm_clr),
        .busy(busy),
        .in_ready(fsm_in_ready),
        .out_valid(fsm_out_valid),
        .done(done)
    );
    
    // Ping Pong Buffer for Matrix A (Rows)
    ping_pong_buffer #(
        .N(N)
    ) u_buffer_a (
        .clk(clk),
        .rst_n(rst_n),
        .swap_banks(swap_banks),
        .current_bank(current_bank),
        .host_we(host_we_a),
        .host_addr(host_addr_a),
        .host_wdata(host_wdata_a),
        .core_raddr(core_raddr),
        .core_rdata(core_rdata_a)
    );
    
    // Ping Pong Buffer for Matrix B (Cols)
    ping_pong_buffer #(
        .N(N)
    ) u_buffer_b (
        .clk(clk),
        .rst_n(rst_n),
        .swap_banks(swap_banks),
        .current_bank(), // Shared Status
        .host_we(host_we_b),
        .host_addr(host_addr_b),
        .host_wdata(host_wdata_b),
        .core_raddr(core_raddr),
        .core_rdata(core_rdata_b)
    );
    
    // Skew Buffers (A & B)
    skew_buffer #(
        .N(N),
        .W(W)
    ) u_skew_a (
        .clk(clk),
        .rst_n(rst_n),
        .clr(fsm_clr),
        .data_in(gated_a),
        .data_out(skewed_a)
    );
    
    skew_buffer #(
        .N(N),
        .W(W)
    ) u_skew_b (
        .clk(clk),
        .rst_n(rst_n),
        .clr(fsm_clr),
        .data_in(gated_b),
        .data_out(skewed_b)
    );
    
    // Systolic Grid
    systolic_grid #(
        .N(N),
        .W(W),
        .A(A)
    ) u_grid (
        .clk(clk),
        .rst_n(rst_n),
        .clr(fsm_clr),
        .a_row_in(skewed_a),
        .b_col_in(skewed_b),
        .accum_out(grid_accum_out)
    );
    
    // Deskew Buffer
    deskew_buffer #(
        .N(N),
        .A(A)
    ) u_deskew (
        .clk(clk),
        .rst_n(rst_n),
        .clr(fsm_clr),
        .accum_in(grid_accum_out),
        .accum_out(deskew_accum_out)
    );
    
    // Quantization and ReLU
    quant_relu #(
        .N(N),
        .A(A),
        .W(W)
    ) u_quant_relu (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(fsm_out_valid),
        .shift_val(shift_val),
        .data_in(deskew_accum_out),
        .valid_out(out_valid),
        .data_out(matrix_out)
    );
endmodule
