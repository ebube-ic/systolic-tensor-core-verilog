`timescale 1ns / 1ps

import tensor_pkg::*;

module tb_tensor_core_axi;
    localparam int C_S_AXI_DATA_WIDTH = 32;
    localparam int C_S_AXI_ADDR_WIDTH = 7;
    localparam time CLK_PERIOD = 10ns;
    
    // Clock and Reset
    logic clk;
    logic rst_n;
    
    // AXI4-Lite interface Signals
    logic [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
    logic [2:0] s_axi_awprot;
    logic s_axi_awvalid;
    logic s_axi_awready;
    
    logic [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata;
    logic [(C_S_AXI_DATA_WIDTH / 8)-1:0] s_axi_wstrb;
    logic s_axi_wvalid;
    logic s_axi_wready;
    
    logic [1:0] s_axi_bresp;
    logic s_axi_bvalid;
    logic s_axi_bready;
    
    logic [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr;
    logic [2:0] s_axi_arprot;
    logic s_axi_arvalid;
    logic s_axi_arready;
    
    logic [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata;
    logic [1:0] s_axi_rresp;
    logic s_axi_rvalid;
    logic s_axi_rready;

    // Device Under Test (DUT)
    tensor_core_axi #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) dut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(rst_n),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );
    
    // 100 MHz Clock Generator
    always #(CLK_PERIOD / 2) clk = ~clk;
    
    // Master Bus Tasks: CPU Memory Operations
    task automatic axi_write (
        input logic [C_S_AXI_ADDR_WIDTH-1:0] addr,
        input logic [C_S_AXI_DATA_WIDTH-1:0] data
    );
        @(posedge clk);
        s_axi_awaddr <= addr;
        s_axi_awvalid <= 1'b1;
        s_axi_wdata <= data;
        s_axi_wvalid <= 1'b1;
        s_axi_wstrb <= 4'b1111;
        s_axi_bready <= 1'b1;
        
        fork
            begin 
                wait (s_axi_awready);
                @(posedge clk);
                s_axi_awvalid <= 1'b0;
            end
            begin 
                wait (s_axi_wready);
                @(posedge clk);
                s_axi_wvalid <= 1'b0;
            end
        join
        
        wait (s_axi_bvalid);
        @(posedge clk);
        s_axi_bready <= 1'b0;
    endtask
    
    task automatic axi_read (
        input logic [C_S_AXI_ADDR_WIDTH-1:0] addr,
        output logic [C_S_AXI_DATA_WIDTH-1:0] data
    );
        @(posedge clk);
        s_axi_araddr <= addr;
        s_axi_arvalid <= 1'b1;
        s_axi_rready <= 1'b1;
        
        wait (s_axi_arready);
        @(posedge clk);
        s_axi_arvalid <= 1'b0;
        wait (s_axi_rvalid);
        data = s_axi_rdata;
        @(posedge clk);
        s_axi_rready <= 1'b0;
    endtask
    
    // Golden Matrix Reference & Test Sequencer
    logic [31:0] read_reg;
    logic [31:0] actual_out [4];
    
    localparam logic [7:0] GOLDEN [4][4] = '{
        '{8'd8, 8'd8, 8'd4, 8'd9},
        '{8'd4, 8'd3, 8'd2, 8'd4},
        '{8'd4, 8'd2, 8'd3, 8'd2},
        '{8'd5, 8'd3, 8'd0, 8'd8}
    };
    
    initial begin 
        clk = 0;
        rst_n = 0;
        s_axi_awaddr = 0;
        s_axi_awprot = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arprot = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        
        #(CLK_PERIOD * 2);
        rst_n = 1;
        #(CLK_PERIOD * 2);
        
        $display("\n===================================================");
        $display("[AXI TB] Starting AXI-Lite Tensor Core Verification");
        $display("=====================================================");
        
        // Shift Configuration = 0;
        axi_write(7'h08, 32'h00000000);
        
        // Load Matrix A (Column Slices into Bank 1)
        axi_write(7'h10, {8'd0, 8'd2, 8'd1, 8'd1}); // Col 0
        axi_write(7'h14, {8'd3, 8'd0, 8'd1, 8'd2}); // Col 1
        axi_write(7'h18, {8'd0, 8'd1, 8'd1, 8'd3}); // Col 2
        axi_write(7'h1C, {8'd2, 8'd0, 8'd1, 8'd4}); // Col 3
        
        // Load Matrix B (Row Slices into Bank 1)
        axi_write(7'h20, {8'd1, 8'd1, 8'd0, 8'd2}); // Row 0
        axi_write(7'h24, {8'd2, 8'd0, 8'd1, 8'd1}); // Row 1
        axi_write(7'h28, {8'd0, 8'd1, 8'd2, 8'd0}); // Row 2
        axi_write(7'h2C, {8'd1, 8'd0, 8'd0, 8'd1}); // Row 3
        
        // Swap Ping Pong Banks
        axi_write(7'h00, 32'h00000002);
        
        // Start Execution
        axi_write(7'h00, 32'h00000001);
        
        // Poll Done bit
        read_reg = 0;
        while ((read_reg & 32'h00000002) == 0) begin 
            axi_read(7'h04, read_reg);
            #(CLK_PERIOD);
        end
        $display("[AXI TB] Execution Complete! Done Bit Detected.");
        
        // Read Output Matrix Rows
        axi_read(7'h40, actual_out[0]);
        axi_read(7'h44, actual_out[1]);
        axi_read(7'h48, actual_out[2]);
        axi_read(7'h4C, actual_out[3]);
        
        // Display Matrix Results
        $display("\n========== AXI ACCELERATOR RESULTS ==========");
        for (int r = 0; r < 4; r++) begin 
            $write("Row %0d | Expected: [ ", r);
            for (int c = 0; c < 4; c++) begin 
                $write("%4d", GOLDEN[r][c]);
            end
            $write(" ] Actual: [ ");
            $write("%4d", actual_out[r][7:0]);
            $write("%4d", actual_out[r][15:8]);
            $write("%4d", actual_out[r][23:16]);
            $write("%4d", actual_out[r][31:24]);
            $display(" ]");
        end
        $display("============================================\n");
        
        // Self Checking Assertions
        for (int r = 0; r < 4; r++) begin 
            if (actual_out[r][7:0] !== GOLDEN[r][0] || actual_out[r][15:8] !== GOLDEN[r][1] || 
            actual_out[r][23:16] !== GOLDEN[r][2] || actual_out[r][31:24] !== GOLDEN[r][3]) begin 
                $display("[TB FAILED] Data Mismatch in Row %0d", r);
                $finish;
            end
        end
        
        $display("[TB SUCCESS] AXI-Lite Register Interface Verified with Bit-Exact Results!\n");
        #(CLK_PERIOD * 5);
        $finish;
    end
endmodule
