# aguerrariscv

Aguerrariscv is my own implementation of a processor based on the RISC-V ISA (RV32I).

## Microarchitecture

The processor follows the microarchitecture shown below (currently a sketch on paper):

![Hand-drawn schematic of the aguerrariscv microarchitecture](docs/schematic/fast_schematic_in_paper.jpeg)

## Supported instructions

The processor currently supports 33 instructions of the RV32I base set.
Not yet implemented: `jal`, `jalr`, `lui`, `auipc`, `ecall`, `ebreak` and `fence`.

<!-- aquí va la tabla -->

## Supported instructions

| Type | Instruction | Format |
|---|---|---|
| Arithmetic/Logic (reg-reg) | `add rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `sub rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `sll rd, rs1, rs2` | R |
| Arithmetic/Logic (reg-reg) | `slt rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `sltu rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `xor rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `srl rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `sra rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `or rd, rs1, rs2` | R | 
| Arithmetic/Logic (reg-reg) | `and rd, rs1, rs2` | R | 
| Arithmetic/Logic (immediate) | `addi rd, rs1, imm` | I |
| Arithmetic/Logic (immediate) | `slti rd, rs1, imm` | I | 
| Arithmetic/Logic (immediate) | `sltiu rd, rs1, imm` | I |
| Arithmetic/Logic (immediate) | `xori rd, rs1, imm` | I | 
| Arithmetic/Logic (immediate) | `ori rd, rs1, imm` | I |
| Arithmetic/Logic (immediate) | `andi rd, rs1, imm` | I | 
| Arithmetic/Logic (immediate) | `slli rd, rs1, shamt` | I | 
| Arithmetic/Logic (immediate) | `srli rd, rs1, shamt` | I | 
| Arithmetic/Logic (immediate) | `srai rd, rs1, shamt` | I | 
| Load | `lb rd, imm(rs1)` | I | 
| Load | `lh rd, imm(rs1)` | I | 
| Load | `lw rd, imm(rs1)` | I | 
| Load | `lbu rd, imm(rs1)` | I | 
| Load | `lhu rd, imm(rs1)` | I | 
| Store | `sb rs2, imm(rs1)` | S | 
| Store | `sh rs2, imm(rs1)` | S |
| Store | `sw rs2, imm(rs1)` | S | 
| Conditional branch | `beq rs1, rs2, offset` | B | 
| Conditional branch | `bne rs1, rs2, offset` | B | 
| Conditional branch | `blt rs1, rs2, offset` | B | 
| Conditional branch | `bge rs1, rs2, offset` | B | 
| Conditional branch | `bltu rs1, rs2, offset` | B |
| Conditional branch | `bgeu rs1, rs2, offset` | B | 