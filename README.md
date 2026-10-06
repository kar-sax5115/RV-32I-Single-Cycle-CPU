# RV32I Single-Cycle CPU

A 32-bit **single-cycle processor** implementing the **RISC-V RV32I** base integer instruction set, written in Verilog and simulated in Xilinx Vivado. Each instruction is fetched, decoded, executed, and written back within a single clock cycle.

## Features

- **Instruction support:** R-type and I-type arithmetic/logic, shifts, set-less-than, loads, stores, all six branches, `JAL`, `JALR`, `LUI` and `AUIPC`
- **Area-efficient ALU:** one shared adder/subtractor handles `ADD`, `SUB` and every comparison, and one shifter handles `SLL`, `SRL` and `SRA` (left shift is done by bit reversal around a right shifter)
- **Sub-word memory access:** byte, halfword and word loads and stores, with sign or zero extension on loads
- **Combinational controller:** generates ALU operation, operand select, immediate select, write-back select, memory and PC control signals
- **Modular design:** every block is its own module, connected in `top.v`
- **Hardwired `x0`:** reads as zero and ignores writes

## Supported instructions

| Type | Instructions |
|---|---|
| R-type | `ADD` `SUB` `SLL` `SLT` `SLTU` `XOR` `SRL` `SRA` `OR` `AND` |
| I-type (ALU) | `ADDI` `SLTI` `SLTIU` `XORI` `ORI` `ANDI` `SLLI` `SRLI` `SRAI` |
| Loads | `LB` `LH` `LW` `LBU` `LHU` |
| Stores | `SB` `SH` `SW` |
| Branches | `BEQ` `BNE` `BLT` `BGE` `BLTU` `BGEU` |
| Jumps | `JAL` `JALR` |
| Upper immediate | `LUI` `AUIPC` |

`FENCE`, `ECALL` and `EBREAK` are not implemented. They are decoded as NOPs.

## Datapath overview

```
          +-----+      +-----------+      +----------+
   PC --->| inst|----->| Controller|----->| control  |
   |      | mem |      +-----------+      | signals  |
   |      +-----+            |            +----------+
   |         |               v
   |         |          +---------+     +-----+      +---------+
   |         +--------->| Reg File|---->| ALU |----->| Data Mem|
   |         |          +---------+     +-----+      +---------+
   |         |               ^             ^  |            |
   |         v               |             |  |            |
   |      +--------+         |        (rs1/PC, rs2/imm)     |
   |      | ImmGen |---------+-------------+                |
   |      +--------+                                        |
   |                                                        |
   +<-- next PC (PC+4 / PC+imm / JALR) <-- write-back mux <-+
                                       (ALU / MEM / PC+4 / imm)
```

## Module overview

| File | Description |
|---|---|
| `top.v` | Top-level module. Instantiates and connects all blocks. Inputs: `clk`, `rst` |
| `PC.v` | Program counter. Next PC is `PC+4`, `PC+imm` (branch taken or `JAL`), or `(rs1+imm) & ~1` (`JALR`). Resets to `0` |
| `inst_reg.v` | Instruction memory: 1024 x 32-bit words (4 KB), word addressed by `pc[11:2]` |
| `Register.v` | 32 x 32-bit register file with two read ports and one write port |
| `ImmGen.v` | Immediate generator for I, S, B, J and U formats |
| `Controller.v` | Main control unit. Decodes `opcode`, `funct3` and `funct7` |
| `ALU.v` | Arithmetic, logic, shift and compare unit |
| `DataMem.v` | 4 KB data memory (1024 x 32-bit) with byte, halfword and word access |
| `mux2to1.v` | Parameterized 2-to-1 mux, used for the ALU operand selects |
| `mux4to1.v` | Parameterized 4-to-1 mux, used for write-back selection |

## Control signals

| Signal | Meaning |
|---|---|
| `ALUSrcA` | `0` = `rs1`, `1` = PC |
| `ALUSrcB` | `0` = `rs2`, `1` = immediate |
| `imm_sel` | `000` I, `001` S, `010` B, `011` J, `100` U |
| `WBSel` | `00` ALU result, `01` memory data, `10` PC+4, `11` immediate |
| `pc_funct` | `1` = next PC is `PC + imm` |
| `jalr` | `1` = next PC is `(rs1 + imm) & ~1` |
| `RegWrite` | Enables register file write |
| `MemRead` / `MemWrite` | Enable data memory read / write |

### ALU operations

| Code | Op | Code | Op |
|---|---|---|---|
| `0000` | ADD | `1000` | Signed less than |
| `0001` | SUB | `1001` | Unsigned less than |
| `0010` | XOR | `1010` | Equal |
| `0011` | OR | `1011` | Not equal |
| `0100` | AND | `1100` | Unsigned greater or equal |
| `0101` | SLL | `1101` | Signed greater or equal |
| `0110` | SRL | | |
| `0111` | SRA | | |

For branches, the ALU compares `rs1` and `rs2` and puts the result in bit 0 of its output. The controller feeds that bit back as `pc_funct` to take or skip the branch.

## Getting started

### Requirements

- Xilinx Vivado (any recent version that supports Verilog simulation)

### Running a simulation

1. Create a new Vivado project and add everything in `sources_1/new/` as design sources, with `top` as the top module.
2. Write a testbench that instantiates `top`, drives `clk`, and pulses `rst` high at the start.
3. Load your program into instruction memory before releasing reset, for example:
   ```verilog
   initial $readmemh("program.mem", uut.inst_reg_mod.mem);
   ```
4. Run a behavioral simulation and inspect the PC, register file (`uut.reg_mod.register`) and data memory (`uut.datamem_mod.mem`) in the waveform viewer.

## Design notes

- **Memory map:** instruction and data memories are separate (Harvard style), each 4 KB. Addresses wrap on the low 12 bits.
- **Register file:** reads are combinational, writes happen on the rising clock edge.
- **Data memory:** reads are combinational, writes happen on the rising clock edge. Misaligned accesses are not trapped.
- **Unknown opcodes:** treated as NOPs. All control signals fall back to safe defaults.

## Possible future work

- 5-stage pipelined version with hazard detection and forwarding
- `FENCE`, `ECALL` and `EBREAK` support
- CSR instructions and the Zicsr extension
- M extension (multiply and divide)
- FPGA implementation with on-board I/O

## License

Add your preferred license here (for example MIT).
