\# Parameterized 2D Systolic Tensor Core in Verilog



A scalable, autonomous 2D Systolic Array matrix-matrix multiplication (GEMM) accelerator designed in synthesizable Verilog for FPGA neural network inferencing.



\---



\## Architectural Highlights



\* \*\*Precision\*\*: INT8 signed operands (activations and weights) with 32-bit signed accumulation registers per PE.

\* \*\*Scalable 2D Mesh\*\*: Parameterized systolic array (`N x N`) instantiated using Verilog nested `generate` blocks.

\* \*\*Wavefront Synchronization\*\*: Hardware input skew buffers align parallel matrix streams automatically into the diagonal processing wavefront.

\* \*\*Autonomous Timing Controller\*\*: Moore FSM coordinating zero-clearing, runtime execution, and valid strobing across the precise $3N - 2$ cycle compute window.

\* \*\*Output Stationary\*\*: Intermediate results accumulate locally within each Processing Element to minimize interconnect routing congestion.



\---



\## Module Breakdown



| Module | Description |

| :--- | :--- |

| `systolic\_pe` | Core MAC unit containing signed multiplier, accumulator, and East/South forwarding flip-flops |

| `systolic\_array\_4x4` | Parameterized 2D PE grid with nearest-neighbor spatial interconnects |

| `input\_skew\_buffer\_4x4` | Multi-stage delay registers delaying row/column $k$ by $k$ cycles |

| `systolic\_controller\_4x4` | 4-state Moore FSM controlling synchronous clears and $3N-2$ counter |

| `systolic\_tensor\_core\_4x4` | Top-level integrated wrapper exposing unskewed parallel inputs |

| `tb\_systolic\_tensor\_core\_4x4` | Testbench verifying full matrix multiplication against Identity matrices |



\---



\## Timing \& Wavefront Rule



For an $N \\times N$ matrix multiplication, data propagates through the grid diagonally:

\* \*\*Compute Latency\*\*: $3N - 2$ clock cycles (10 cycles for $4 \\times 4$).

\* \*\*FSM Latency\*\*: 1 cycle clear $\\rightarrow 3N - 2$ compute $\\rightarrow$ 1 cycle valid output pulse.



\---



\## Simulation \& Verification



Verified using \*\*AMD Vivado Simulator (XSim)\*\*. 



\### Identity Matrix Test Vector ($A \\times I\_4 = A$)

\* \*\*Input A\*\*: 4x4 matrix streaming sequentially across 4 cycles.

\* \*\*Input B\*\*: 4x4 identity matrix ($I\_4$).

\* \*\*Result\*\*: Output accumulators $C\_{00} \\dots C\_{33}$ reproduce matrix $A$ exactly upon assertion of `valid\_out`.



