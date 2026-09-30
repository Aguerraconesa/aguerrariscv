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

| Type | Instruction | Format | Operation |
|---|---|---|---|
| Arithmetic/Logic (reg-reg) | `add rd, rs1, rs2` | R | rd = rs1 + rs2 |
| Arithmetic/Logic (reg-reg) | `sub rd, rs1, rs2` | R | rd = rs1 - rs2 |
| Arithmetic/Logic (reg-reg) | `sll rd, rs1, rs2` | R | rd = rs1 << rs2[4:0] |
| Arithmetic/Logic (reg-reg) | `slt rd, rs1, rs2` | R | rd = (rs1 < rs2) signed |
| Arithmetic/Logic (reg-reg) | `sltu rd, rs1, rs2` | R | rd = (rs1 < rs2) unsigned |
| Arithmetic/Logic (reg-reg) | `xor rd, rs1, rs2` | R | rd = rs1 ^ rs2 |
| Arithmetic/Logic (reg-reg) | `srl rd, rs1, rs2` | R | rd = rs1 >> rs2[4:0] (logical) |
| Arithmetic/Logic (reg-reg) | `sra rd, rs1, rs2` | R | rd = rs1 >> rs2[4:0] (arithmetic) |
| Arithmetic/Logic (reg-reg) | `or rd, rs1, rs2` | R | rd = rs1 \| rs2 |
| Arithmetic/Logic (reg-reg) | `and rd, rs1, rs2` | R | rd = rs1 & rs2 |
| Arithmetic/Logic (immediate) | `addi rd, rs1, imm` | I | rd = rs1 + imm |
| Arithmetic/Logic (immediate) | `slti rd, rs1, imm` | I | rd = (rs1 < imm) signed |
| Arithmetic/Logic (immediate) | `sltiu rd, rs1, imm` | I | rd = (rs1 < imm) unsigned |
| Arithmetic/Logic (immediate) | `xori rd, rs1, imm` | I | rd = rs1 ^ imm |
| Arithmetic/Logic (immediate) | `ori rd, rs1, imm` | I | rd = rs1 \| imm |
| Arithmetic/Logic (immediate) | `andi rd, rs1, imm` | I | rd = rs1 & imm |
| Arithmetic/Logic (immediate) | `slli rd, rs1, shamt` | I | rd = rs1 << shamt |
| Arithmetic/Logic (immediate) | `srli rd, rs1, shamt` | I | rd = rs1 >> shamt (logical) |
| Arithmetic/Logic (immediate) | `srai rd, rs1, shamt` | I | rd = rs1 >> shamt (arithmetic) |
| Load | `lb rd, imm(rs1)` | I | rd = sign-extended byte |
| Load | `lh rd, imm(rs1)` | I | rd = sign-extended halfword |
| Load | `lw rd, imm(rs1)` | I | rd = word (32 bits) |
| Load | `lbu rd, imm(rs1)` | I | rd = zero-extended byte |
| Load | `lhu rd, imm(rs1)` | I | rd = zero-extended halfword |
| Store | `sb rs2, imm(rs1)` | S | stores the low byte of rs2 |
| Store | `sh rs2, imm(rs1)` | S | stores the low 16 bits of rs2 |
| Store | `sw rs2, imm(rs1)` | S | stores all 32 bits of rs2 |
| Conditional branch | `beq rs1, rs2, offset` | B | branch if rs1 == rs2 |
| Conditional branch | `bne rs1, rs2, offset` | B | branch if rs1 != rs2 |
| Conditional branch | `blt rs1, rs2, offset` | B | branch if rs1 < rs2 (signed) |
| Conditional branch | `bge rs1, rs2, offset` | B | branch if rs1 >= rs2 (signed) |
| Conditional branch | `bltu rs1, rs2, offset` | B | branch if rs1 < rs2 (unsigned) |
| Conditional branch | `bgeu rs1, rs2, offset` | B | branch if rs1 >= rs2 (unsigned) |