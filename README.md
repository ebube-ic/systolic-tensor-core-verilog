# Parameterized 2D Systolic Tensor Core with AXI4-Lite Interface

A scalable, synthesizable 2D Systolic Array matrix-matrix multiplication (GEMM) accelerator designed in SystemVerilog for edge AI inferencing and hardware-accelerated linear algebra. The architecture integrates an autonomous compute mesh, wavefront deskew networks, fused INT8 post-processing quantization, dual ping-pong memory buffers, and a memory-mapped AXI4-Lite host slave interface.

---

## Architectural Highlights

* **Precision:** Signed INT8 operands (activations and weights), 32-bit signed internal accumulation, and quantized signed INT8 activation outputs.
* **Scalable 2D Mesh:** Parameterized systolic array ($N \times N$) instantiated with nearest-neighbor spatial pipeline interconnects.
* **Output-Stationary Dataflow:** Dot products accumulate locally within each Processing Element (PE) register to minimize global interconnect switching and power dissipation.
* **Wavefront Synchronization:** 
  * **Input Skew Network:** Progressive $k$-cycle shift registers align incoming matrix streams into diagonal processing wavefronts.
  * **2D Output Deskew Network:** Coordinate-delay shift registers compensating $(2N - 2) - (i + j)$ cycles present all $N \times N$ results simultaneously on the exact same clock edge.
* **Fused Quantization & Activation:** Integrated post-processing pipeline executing runtime-configurable arithmetic right-shift scaling (`shift_val`), saturation clamping ($[-128, +127]$), and zero-overhead ReLU activation.
* **Decoupled Memory Staging:** Dual ping-pong memory banks isolate host AXI write transactions from active systolic compute cycles.
* **System-on-Chip Bus Integration:** Memory-mapped **AXI4-Lite Slave** interface supporting standard CPU register transactions for host matrix staging, execution dispatching, status polling, and row-major result extraction.

---

## Hardware Architecture & RTL Elaboration

The design bridges domain-specific compute pipelines with standard microprocessor bus infrastructures. The top-level wrapper (`tensor_core_axi`) decodes AXI transactions, routes matrix streams into dual ping-pong RAMs, asserts execution pulses to the sequencer, and latches outputs for host readback.

### RTL Elaborated Schematic

![RTL Elaborated Architecture](./RTL%20Elaboration.png)

---

## Memory Map (AXI4-Lite Slave)

Base Address: `0x4000_0000` (7-bit word-aligned addressing)

| Offset | Register Name | Access | Description |
| :--- | :--- | :---: | :--- |
| `0x00` | **REG_CTRL**   | W     | Bit 0: `start_pulse` (self-clearing)<br>Bit 1: `swap_banks` |
| `0x04` | **REG_STATUS** | R     | Bit 0: `busy`<br>Bit 1: `done` (latched / sticky)<br>Bit 2: `current_bank` |
| `0x08` | **REG_CONFIG** | R/W   | Bits [3:0]: Arithmetic right-shift post-processing parameter |
| `0x10` - `0x1C` | **MEM_A_0 .. 3** | W | Matrix A column slices (4 bytes packed little-endian per 32-bit word) |
| `0x20` - `0x2C` | **MEM_B_0 .. 3** | W | Matrix B row slices (4 bytes packed little-endian per 32-bit word) |
| `0x40` - `0x4C` | **OUT_ROW_0 .. 3** | R | Computed output matrix rows (4 signed INT8 values packed) |

---

## Timing & Wavefront Sequencing

For an $N \times N$ matrix multiplication, data propagates through the grid along diagonal wavefronts:
* **Wavefront Propagation:** Inputs are skewed by spatial index delay ($i, j$).
* **Output Realignment:** Deskew stages insert $(2N - 2) - (i + j)$ cycles of compensation delay.
* **FSM Latency Sequence:**
  1. `S_IDLE`: Awaiting start pulse.
  2. `S_CLEAR`: 1 cycle synchronous accumulator zeroing.
  3. `S_COMPUTE`: Pipelined systolic MAC execution and deskew pipeline propagation ($3N - 1$ cycles).
  4. `S_DONE`: Asserts done flag and latches parallel output matrix registers.

---

## Verification & Simulation

Verified using **AMD Vivado Simulator (XSim)** across both standalone systolic execution and full AXI bus transactions.

### 1. AXI-Lite End-to-End Handshake and Matrix Write Staging
Demonstrating address-write handshakes, ping-pong buffer bank swapping, and accelerator execution launch across the AXI4-Lite slave interface:

![AXI Write Handshake Waveform](./Waveform1.png)

### 2. Output Deskew Settling & Result Readback
The self-checking testbench (`tb_tensor_core_axi.sv`) polls status register `0x04` for execution completion, reads rows `0x40` through `0x4C`, and verifies bit-exact signed outputs against a golden matrix reference model:

![AXI Read and Result Waveform](./Waveform2.png)

---

## Physical Synthesis & Implementation (AMD Artix-7)

Synthesized using AMD Vivado targeting the **XC7A100T-CSG324-1** FPGA:

* **Target Device:** AMD Artix-7 `xc7a100tcsg324-1`
* **Timing Closure:** All user constraints met (0 failing endpoints out of 3,277)
* **Target Period:** 10.000 ns (100 MHz)
* **Worst Negative Slack (WNS):** +2.067 ns
* **Worst Hold Slack (WHS):** +0.142 ns
* **Worst Pulse Width Slack (WPWS):** +4.500 ns
* **Total Negative Slack (TNS):** 0.000 ns
* **Maximum Operating Frequency ($F_{\max}$):** 126.06 MHz
* **Slice LUT Utilization:** 4,318 / 63,400 (6.81%)
* **Slice Register Utilization:** 3,112 / 126,800 (2.45%)
* **Dedicated Arithmetic Carry:** 456 `CARRY4` primitives
* **Clock Buffers:** 1 `BUFG`

---

## Repository Structure

```text
├── rtl/
│   └── sv/
│       ├── tensor_pkg.sv         # Data types, dimensions, and register macros
│       ├── pe.sv                 # Multiply-accumulate Processing Element
│       ├── systolic_grid.sv      # 4x4 2D spatial PE grid
│       ├── skew_buffer.sv        # Shift register input skew alignment
│       ├── deskew_buffer.sv      # Inverse coordinate deskew alignment
│       ├── quant_relu.sv         # Shift, saturation clamp, and ReLU unit
│       ├── tensor_ctrl_fsm.sv    # Master sequencer FSM
│       ├── ping_pong_buffer.sv   # Dual-bank decoupled memory
│       ├── tensor_core_top.sv    # Systolic accelerator engine integration
│       └── tensor_core_axi.sv    # Memory-mapped AXI4-Lite slave wrapper
├── tb/
│   └── sv/
│       ├── tb_tensor_core_axi.sv # AXI bus master self-checking testbench
│       └── tb_tensor_core_top.sv # Core-level direct testbench
├── RTL Elaboration.png           # Elaborated gate schematic
├── Waveform1.png                 # AXI write and staging waveform
├── Waveform2.png                 # AXI read and verification waveform
└── README.md
