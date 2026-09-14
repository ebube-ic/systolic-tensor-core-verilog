`timescale 1ns / 1ps

import tensor_pkg::*;

module tb_tensor_core_top;
    localparam int N = ARRAY_SIZE;
    localparam int W = DATA_WIDTH;
    localparam int A = ACCUM_WIDTH;
    localparam time CLK_PERIOD = 10ns; // 100MHz Clock
    
    logic clk;
    logic rst_n;
    
    // Control Signals
    logic start;
    logic swap_banks;
    logic [3:0] shift_val;
    logic busy;
    logic done;
    logic current_bank;
    
    // Host Memory Write Ports
    logic host_we_a;
    logic [$clog2(N)-1:0] host_addr_a;
    vec_data_t host_wdata_a;
    
    logic host_we_b;
    logic [$clog2(N)-1:0] host_addr_b;
    vec_data_t host_wdata_b;
    
    // Outputs
    logic out_valid;
    matrix_out_t matrix_out;
    
    // DEVICE UNDER TEST (DUT)
    tensor_core_top #(
        .N(N),
        .W(W),
        .A(A)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .swap_banks(swap_banks),
        .shift_val(shift_val),
        .busy(busy),
        .done(done),
        .current_bank(current_bank),
        .host_we_a(host_we_a),
        .host_addr_a(host_addr_a),
        .host_wdata_a(host_wdata_a),
        .host_we_b(host_we_b),
        .host_addr_b(host_addr_b),
        .host_wdata_b(host_wdata_b),
        .out_valid(out_valid),
        .matrix_out(matrix_out)
    );
    
    // Clock Generation
    always #(CLK_PERIOD / 2) clk = ~clk;
    
    // Golden Reference Model & Test Data
    logic signed [W-1:0] mat_a [N][N];
    logic signed [W-1:0] mat_b [N][N];
    logic signed [A-1:0] golden_c [N][N];
    
    // Compute expected result in software
    function void compute_golden();
        for (int r = 0; r < N; r++) begin 
            for (int c = 0; c < N; c++) begin 
                golden_c[r][c] = 0;
                for (int k = 0; k < N; k++) begin 
                    golden_c[r][c] += mat_a[r][k] * mat_b[k][c];
                end
            end
        end
    endfunction
    
    // Main Test Stimulus
    initial begin 
        // Initialize inputs
        clk = 0;
        rst_n = 0;
        start = 0;
        swap_banks = 0;
        shift_val = 0;
        host_we_a = 0;
        host_addr_a = '0;
        host_wdata_a = '{default: '0};
        host_we_b = 0;
        host_addr_b = '0;
        host_wdata_b = '{default: '0};
        
        // Define Matrix A (Rows)
        mat_a[0] = '{8'd1, 8'd2, 8'd3, 8'd4};
        mat_a[1] = '{8'd1, 8'd1, 8'd1, 8'd1};
        mat_a[2] = '{8'd2, 8'd0, 8'd1, 8'd0};
        mat_a[3] = '{8'd0, 8'd3, 8'd0, 8'd2};
        
        // Define Matrix B (Cols)
        mat_b[0] = '{8'd2, 8'd0, 8'd1, 8'd1};
        mat_b[1] = '{8'd1, 8'd1, 8'd0, 8'd2};
        mat_b[2] = '{8'd0, 8'd2, 8'd1, 8'd0};
        mat_b[3] = '{8'd1, 8'd0, 8'd0, 8'd1};
        
        compute_golden();
        
        // Apply System Reset
        #(CLK_PERIOD * 2);
        rst_n = 1;
        #(CLK_PERIOD * 2);
        
        // 5. Load Matrices A and B into Ping Pong Bank 1 (host writes to inactive bank)
        $display("[TB] Loading Matrix A and B into Ping-Pong Buffer...");
        for (int i = 0; i < N; i++) begin 
            @(posedge clk);
            host_we_a <= 1;
            host_addr_a <= i;
            host_wdata_a <= '{mat_a[0][i], mat_a[1][i], mat_a[2][i], mat_a[3][i]};
            
            host_we_b <= 1;
            host_addr_b <= i;
            host_wdata_b <= {mat_b[i][0], mat_b[i][1], mat_b[i][2], mat_b[i][3]};
        end
        
        @(posedge clk);
        host_we_a <= 0;
        host_we_b <= 0;
        
        // Swap Banks so Core can read the date we just loaded
        @(posedge clk);
        swap_banks <= 1;
        @(posedge clk);
        swap_banks <= 0;
        #(CLK_PERIOD * 2);
        
        // Pulse Start
        $display("[TB] Starting Systolic Computation...");
        @(posedge clk);
        start <= 1;
        @(posedge clk);
        start <= 0;
        
        // Wait for completion
        wait(done == 1);
        #1;
        
        // Display and Verify Output
        $display("\n============ Matrix Multiplication Results ============");
        for (int r = 0; r < N; r++) begin 
            $write("Row %0d | Expected: [", r);
            for (int c = 0; c < N; c++) $write("%4d", golden_c[r][c]);
            $write(" ] Actual: [");
            for (int c = 0; c < N; c++) $write("%4d", matrix_out[r][c]);
            $display(" ]");
        end
        $display("=======================================================\n");
        
        // Self-Checking Assertion
        for (int r = 0; r < N; r++) begin 
            for (int c = 0; c < N; c++) begin 
                if (matrix_out[r][c] !== golden_c[r][c][W-1:0]) begin
                    $display("[TB ERROR] Mismatch at (%0d, %0d)! Expected: %0d, Got %0d",
                                r, c, golden_c[r][c][W-1:0], matrix_out[r][c]);
                    $finish;
                end
            end
        end
        
        $display("[TB SUCCESS] All 16 matrix elements matched perfectly! Test PASSED.\n");
        #(CLK_PERIOD * 5);
        $finish;
    end
endmodule
