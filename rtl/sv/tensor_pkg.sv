`timescale 1ns / 1ps

package tensor_pkg;
    localparam int ARRAY_SIZE = 4;
    localparam int DATA_WIDTH = 8;
    localparam int ACCUM_WIDTH = 32;
    localparam int SHIFT_WIDTH = 5;
    
    typedef logic signed [DATA_WIDTH-1:0] vec_data_t [ARRAY_SIZE];
    typedef logic signed [ACCUM_WIDTH-1:0] matrix_accum_t [ARRAY_SIZE][ARRAY_SIZE];
    typedef logic signed [DATA_WIDTH-1:0] matrix_out_t [ARRAY_SIZE][ARRAY_SIZE];
    
    typedef enum logic [2:0] {
        STATE_IDLE = 3'b000,
        STATE_LOAD_SKEW = 3'b001,
        STATE_COMPUTE = 3'b010,
        STATE_DRAIN = 3'b011,
        STATE_QUANTIZE = 3'b100,
        STATE_DONE = 3'b101
    } core_state_t;
    
endpackage : tensor_pkg
