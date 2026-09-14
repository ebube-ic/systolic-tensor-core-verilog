`timescale 1ns / 1ps

import tensor_pkg::*;

module tensor_core_axi#(
    parameter int C_S_AXI_DATA_WIDTH = 32,
    parameter int C_S_AXI_ADDR_WIDTH = 7
)(
    // AXI4-Lite Clock and Reset
    input logic s_axi_aclk,
    input logic s_axi_aresetn,
    
    // Write Address Channel
    input logic [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input logic [2:0] s_axi_awprot,
    input logic s_axi_awvalid,
    output logic s_axi_awready,
    
    // Write Data Channel
    input logic [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input logic [(C_S_AXI_DATA_WIDTH-1)/8:0] s_axi_wstrb,
    input logic s_axi_wvalid,
    output logic s_axi_wready,
    
    // Write Response Channel
    output logic [1:0] s_axi_bresp,
    output logic s_axi_bvalid,
    input logic s_axi_bready,
    
    // Read Address Channel
    input logic [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input logic [2:0] s_axi_arprot,
    input logic s_axi_arvalid,
    output logic s_axi_arready,
    
    // Read Data Channel
    output logic [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0] s_axi_rresp,
    output logic s_axi_rvalid,
    input logic s_axi_rready
    );
    
    localparam int N = ARRAY_SIZE;
    localparam int W = DATA_WIDTH;
    localparam int A = ACCUM_WIDTH;
    
    // Register Address Offsets
    localparam logic [6:0] ADDR_CTRL = 7'h00;
    localparam logic [6:0] ADDR_STATUS = 7'h04;
    localparam logic [6:0] ADDR_CONFIG = 7'h08;
    
    // Internal Core Interface Signals
    logic start_pulse;
    logic swap_banks_pulse;
    logic [3:0] shift_val_reg;
    logic busy_sig;
    logic done_sig;
    logic current_bank_sig;
    
    logic host_we_a;
    logic [$clog2(N)-1:0] host_addr_a;
    vec_data_t host_wdata_a;
    
    logic host_we_b;
    logic [$clog2(N)-1:0] host_addr_b;
    vec_data_t host_wdata_b;
    
    logic out_valid_sig;
    matrix_out_t matrix_out_sig;
    
    logic done_latched;
    
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin 
        if (!s_axi_aresetn) begin 
            done_latched <= 1'b0;
        end else begin 
            if (start_pulse) begin
                done_latched <= 1'b0;
            end else if (done_sig) begin 
                done_latched <= 1'b1;
            end
       end
    end
    
    // Holding Registers for the Output Matrix so the CPU can read it anytime
    matrix_out_t matrix_out_latched;
    
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin 
        if (!s_axi_aresetn) begin 
            matrix_out_latched <= '{default: '0};
        end else if (out_valid_sig) begin 
            matrix_out_latched <= matrix_out_sig;
        end
    end
    
    // AXI-Lite Write Engine
    logic aw_en;
    
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin 
        if (!s_axi_aresetn) begin 
            s_axi_awready    <= 1'b0;
            s_axi_wready     <= 1'b0;
            s_axi_bvalid     <= 1'b0;
            s_axi_bresp      <= 2'b00;
            aw_en            <= 1'b1;
            start_pulse      <= 1'b0;
            swap_banks_pulse <= 1'b0;
            shift_val_reg    <= 4'd0;
            host_we_a        <= 1'b0;
            host_we_b        <= 1'b0;
            host_addr_a      <= '0;
            host_addr_b      <= '0;
            host_wdata_a     <= '{default: '0};
            host_wdata_b     <= '{default: '0};
        end else begin
            // Single-cycle self-clearing pulses
            start_pulse <= 1'b0;
            swap_banks_pulse <= 1'b0;
            host_we_a <= 1'b0;
            host_we_b <= 1'b0;
            
            // Handshake logic for AW and W Channels
            if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en) begin 
                s_axi_awready <= 1'b1;
                s_axi_wready <= 1'b1;
                aw_en <= 1'b0;
                
                // Decode Adress and Write Data
                case (s_axi_awaddr[6:0]) 
                    ADDR_CTRL: begin 
                        start_pulse <= s_axi_wdata[0];
                        swap_banks_pulse <= s_axi_wdata[1];
                    end
                    
                    ADDR_CONFIG: begin 
                        shift_val_reg <= s_axi_wdata[3:0];
                    end
                    
                    // Matrix A Drawers (0x10, 0x14, 0x18, 0x1C)
                    7'h10, 7'h14, 7'h18, 7'h1C: begin 
                        host_we_a <= 1'b1;
                        host_addr_a <= s_axi_awaddr[3:2];
                        host_wdata_a <= '{s_axi_wdata[7:0], s_axi_wdata[15:8], s_axi_wdata[23:16], s_axi_wdata[31:24]};
                    end
                    
                    // Matrix B Drawers (0x20, 0x24, 0x28, 0x2C)
                    7'h20, 7'h24, 7'h28, 7'h2C: begin 
                        host_we_b <= 1'b1;
                        host_addr_b <= s_axi_awaddr[3:2];
                        host_wdata_b <= '{s_axi_wdata[7:0], s_axi_wdata[15:8], s_axi_wdata[23:16], s_axi_wdata[31:24]};
                    end
                    
                    default: ;
                endcase
            end else begin 
                s_axi_awready <= 1'b0;
                s_axi_wready <= 1'b0;
            end
            
            // Write Response (B) Channel
            if (s_axi_awready && s_axi_wready && ~s_axi_bvalid) begin 
                s_axi_bvalid <= 1'b1;
                s_axi_bresp <= 2'b00;
            end else if (s_axi_bvalid && s_axi_bready) begin 
                s_axi_bvalid <= 1'b0;
                aw_en <= 1'b1;
            end
        end
    end
    
    // AXI-Lite Read Engine
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin 
        if (!s_axi_aresetn) begin 
            s_axi_arready <= 1'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rresp <= 2'b00;
            s_axi_rdata <= 32'd0;
        end else begin 
            // Address Read Handshake 
            if (~s_axi_arready && s_axi_arvalid) begin
                s_axi_arready <= 1'b1;
                s_axi_rvalid  <= 1'b1;
                s_axi_rresp   <= 2'b00; // 'OKAY'

                // Decode Read Address
                case (s_axi_araddr[6:0])
                    ADDR_STATUS: begin
                        s_axi_rdata <= { 29'd0, current_bank_sig, done_latched, busy_sig };
                    end

                    ADDR_CONFIG: begin
                        s_axi_rdata <= { 28'd0, shift_val_reg };
                    end

                    // Output Matrix Rows (0x40, 0x44, 0x48, 0x4C)
                    7'h40: s_axi_rdata <= { matrix_out_latched[0][3], matrix_out_latched[0][2],
                                            matrix_out_latched[0][1], matrix_out_latched[0][0] };
                    7'h44: s_axi_rdata <= { matrix_out_latched[1][3], matrix_out_latched[1][2],
                                            matrix_out_latched[1][1], matrix_out_latched[1][0] };
                    7'h48: s_axi_rdata <= { matrix_out_latched[2][3], matrix_out_latched[2][2],
                                            matrix_out_latched[2][1], matrix_out_latched[2][0] };
                    7'h4C: s_axi_rdata <= { matrix_out_latched[3][3], matrix_out_latched[3][2],
                                            matrix_out_latched[3][1], matrix_out_latched[3][0] };

                    default: s_axi_rdata <= 32'd0;
                endcase
            end else begin 
                s_axi_arready <= 1'b0;
            end
            
            // Clear RVALID once master accepts the data
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end
    
    // Instantiate Core 
    tensor_core_top #(
        .N(N),
        .W(W),
        .A(A)
    ) u_core (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .start(start_pulse),
        .swap_banks(swap_banks_pulse),
        .shift_val(shift_val_reg),
        .busy(busy_sig),
        .done(done_sig),
        .current_bank(current_bank_sig),
        .host_we_a(host_we_a),
        .host_addr_a(host_addr_a),
        .host_wdata_a(host_wdata_a),
        .host_we_b(host_we_b),
        .host_addr_b(host_addr_b),
        .host_wdata_b(host_wdata_b),
        .out_valid(out_valid_sig),
        .matrix_out(matrix_out_sig)  
    );
endmodule
