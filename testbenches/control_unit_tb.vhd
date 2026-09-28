-- ============================================================
--  Testbench: control_unit_tb
--  Unit under test: control_unit (RISC-V control unit)
--
--  Signal meanings:
--    alu_op_o     : ALU operation code (4 bits)
--    we_regfile_o : write enable for register file
--    we_mem_o     : write enable for data memory
--    alu_src_o    : 1 = register operands, 0 = immediate operand
--    alu2reg_o    : 1 = ALU result to reg, 0 = memory data to reg
--    imm_rd_o     : 1 = use immediate for store offset
--    br_neg_o     : 1 = negate branch condition (BGE, BGEU, BNE)
--    branch_o     : 1 = instruction is a branch
--
--  Instruction types covered:
--    R-type  (opcode 0110011): ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
--    I-type  (opcode 0010011): ADDI, ANDI, ORI, XORI, SLTI, SLTUI, SLLI, SRLI, SRAI
--    Load    (opcode 0000011): LB, LH, LW, LBU, LHU
--    Store   (opcode 0100011): SB, SH, SW
--    Branch  (opcode 1100011): BEQ, BNE, BLT, BGE, BLTU, BGEU
--    Unknown opcode           : default outputs must be safe (all 0)
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit_tb is
end entity control_unit_tb;

architecture sim of control_unit_tb is

    -- --------------------------------------------------------
    -- Component declaration
    -- --------------------------------------------------------
    component control_unit is
        port (
            opcode_i     : in  std_logic_vector(6 downto 0);
            funct3_i     : in  std_logic_vector(2 downto 0);
            funct7_i     : in  std_logic_vector(6 downto 0);
            alu_op_o     : out std_logic_vector(3 downto 0);
            we_regfile_o : out std_logic;
            we_mem_o     : out std_logic;
            alu_src_o    : out std_logic;
            alu2reg_o    : out std_logic;
            imm_rd_o     : out std_logic;
            br_neg_o     : out std_logic;
            branch_o     : out std_logic
        );
    end component;

    -- --------------------------------------------------------
    -- DUT signals
    -- --------------------------------------------------------
    signal opcode     : std_logic_vector(6 downto 0) := (others => '0');
    signal funct3     : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7     : std_logic_vector(6 downto 0) := (others => '0');
    signal alu_op     : std_logic_vector(3 downto 0);
    signal we_regfile : std_logic;
    signal we_mem     : std_logic;
    signal alu_src    : std_logic;
    signal alu2reg    : std_logic;
    signal imm_rd     : std_logic;
    signal br_neg     : std_logic;
    signal branch     : std_logic;

    -- --------------------------------------------------------
    -- RISC-V opcode constants
    -- --------------------------------------------------------
    constant OPC_RTYPE  : std_logic_vector(6 downto 0) := "0110011";
    constant OPC_ITYPE  : std_logic_vector(6 downto 0) := "0010011";
    constant OPC_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OPC_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OPC_BRANCH : std_logic_vector(6 downto 0) := "1100011";

    -- funct7 constants
    constant F7_NORMAL : std_logic_vector(6 downto 0) := "0000000";
    constant F7_ALT    : std_logic_vector(6 downto 0) := "0100000";

    -- --------------------------------------------------------
    -- Helper: apply stimulus and wait for combinational settle
    -- --------------------------------------------------------
    procedure apply(
        signal opcode_s : out std_logic_vector(6 downto 0);
        signal funct3_s : out std_logic_vector(2 downto 0);
        signal funct7_s : out std_logic_vector(6 downto 0);
        opc : in std_logic_vector(6 downto 0);
        f3  : in std_logic_vector(2 downto 0);
        f7  : in std_logic_vector(6 downto 0)
    ) is
    begin
        opcode_s <= opc;
        funct3_s <= f3;
        funct7_s <= f7;
        wait for 10 ns;
    end procedure;

    -- --------------------------------------------------------
    -- Helper: check all control outputs in one call
    -- --------------------------------------------------------
    procedure check(
        test_name    : in string;
        -- observed
        got_aluop    : in std_logic_vector(3 downto 0);
        got_wereg    : in std_logic;
        got_wemem    : in std_logic;
        got_alusrc   : in std_logic;
        got_alu2reg  : in std_logic;
        got_immrd    : in std_logic;
        got_brneg    : in std_logic;
        got_branch   : in std_logic;
        -- expected
        exp_aluop    : in std_logic_vector(3 downto 0);
        exp_wereg    : in std_logic;
        exp_wemem    : in std_logic;
        exp_alusrc   : in std_logic;
        exp_alu2reg  : in std_logic;
        exp_immrd    : in std_logic;
        exp_brneg    : in std_logic;
        exp_branch   : in std_logic
    ) is
        variable pass : boolean := true;
        variable msg  : string(1 to 200) := (others => ' ');
    begin
        if got_aluop   /= exp_aluop   then pass := false; end if;
        if got_wereg   /= exp_wereg   then pass := false; end if;
        if got_wemem   /= exp_wemem   then pass := false; end if;
        if got_alusrc  /= exp_alusrc  then pass := false; end if;
        if got_alu2reg /= exp_alu2reg then pass := false; end if;
        if got_immrd   /= exp_immrd   then pass := false; end if;
        if got_brneg   /= exp_brneg   then pass := false; end if;
        if got_branch  /= exp_branch  then pass := false; end if;

        if pass then
            report "[PASS] " & test_name severity note;
        else
            report "[FAIL] " & test_name &
                   " | alu_op="     & to_string(got_aluop)  & "(exp " & to_string(exp_aluop)  & ")" &
                   " we_reg="       & std_logic'image(got_wereg)   & "(exp " & std_logic'image(exp_wereg)   & ")" &
                   " we_mem="       & std_logic'image(got_wemem)   & "(exp " & std_logic'image(exp_wemem)   & ")" &
                   " alu_src="      & std_logic'image(got_alusrc)  & "(exp " & std_logic'image(exp_alusrc)  & ")" &
                   " alu2reg="      & std_logic'image(got_alu2reg) & "(exp " & std_logic'image(exp_alu2reg) & ")" &
                   " imm_rd="       & std_logic'image(got_immrd)   & "(exp " & std_logic'image(exp_immrd)   & ")" &
                   " br_neg="       & std_logic'image(got_brneg)   & "(exp " & std_logic'image(exp_brneg)   & ")" &
                   " branch="       & std_logic'image(got_branch)  & "(exp " & std_logic'image(exp_branch)  & ")"
            severity error;
        end if;
    end procedure;

begin

    -- --------------------------------------------------------
    -- DUT instantiation
    -- --------------------------------------------------------
    DUT : control_unit
        port map (
            opcode_i     => opcode,
            funct3_i     => funct3,
            funct7_i     => funct7,
            alu_op_o     => alu_op,
            we_regfile_o => we_regfile,
            we_mem_o     => we_mem,
            alu_src_o    => alu_src,
            alu2reg_o    => alu2reg,
            imm_rd_o     => imm_rd,
            br_neg_o     => br_neg,
            branch_o     => branch
        );

    -- --------------------------------------------------------
    -- Stimulus process
    -- --------------------------------------------------------
    stim_proc : process
    begin

        report "======================================" severity note;
        report "  Simulation start: control_unit      " severity note;
        report "======================================" severity note;

        -- ====================================================
        -- R-TYPE (opcode 0110011)
        -- Control signals: alu_src=1, we_regfile=1, alu2reg=1
        --                  we_mem=0, imm_rd=0, br_neg=0, branch=0
        -- ====================================================
        report "--- R-type ---" severity note;

        -- ADD: funct7=0000000 funct3=000
        apply(opcode, funct3, funct7, OPC_RTYPE, "000", F7_NORMAL);
        check("R-type ADD",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- SUB: funct7=0100000 funct3=000
        apply(opcode, funct3, funct7, OPC_RTYPE, "000", F7_ALT);
        check("R-type SUB",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0001",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- SLL: funct7=0000000 funct3=001
        apply(opcode, funct3, funct7, OPC_RTYPE, "001", F7_NORMAL);
        check("R-type SLL",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0010",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- SLT: funct7=0000000 funct3=010
        apply(opcode, funct3, funct7, OPC_RTYPE, "010", F7_NORMAL);
        check("R-type SLT",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0100",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- SLTU: funct7=0000000 funct3=011
        apply(opcode, funct3, funct7, OPC_RTYPE, "011", F7_NORMAL);
        check("R-type SLTU",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0110",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- XOR: funct7=0000000 funct3=100
        apply(opcode, funct3, funct7, OPC_RTYPE, "100", F7_NORMAL);
        check("R-type XOR",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1000",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- SRL: funct7=0000000 funct3=101
        apply(opcode, funct3, funct7, OPC_RTYPE, "101", F7_NORMAL);
        check("R-type SRL",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1010",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- SRA: funct7=0100000 funct3=101
        apply(opcode, funct3, funct7, OPC_RTYPE, "101", F7_ALT);
        check("R-type SRA",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1011",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- OR: funct7=0000000 funct3=110
        apply(opcode, funct3, funct7, OPC_RTYPE, "110", F7_NORMAL);
        check("R-type OR",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1100",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- AND: funct7=0000000 funct3=111
        apply(opcode, funct3, funct7, OPC_RTYPE, "111", F7_NORMAL);
        check("R-type AND",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1110",        '1',     '0',      '1',      '1',     '0',     '0',      '0');

        -- ====================================================
        -- I-TYPE immediate (opcode 0010011)
        -- Control signals: alu_src=0, we_regfile=1, alu2reg=1
        --                  we_mem=0, imm_rd=0, br_neg=0, branch=0
        -- ====================================================
        report "--- I-type immediate ---" severity note;

        -- ADDI: funct3=000
        apply(opcode, funct3, funct7, OPC_ITYPE, "000", F7_NORMAL);
        check("I-type ADDI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- SLTI: funct3=010
        apply(opcode, funct3, funct7, OPC_ITYPE, "010", F7_NORMAL);
        check("I-type SLTI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0100",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- SLTUI: funct3=011
        apply(opcode, funct3, funct7, OPC_ITYPE, "011", F7_NORMAL);
        check("I-type SLTUI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0110",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- XORI: funct3=100
        apply(opcode, funct3, funct7, OPC_ITYPE, "100", F7_NORMAL);
        check("I-type XORI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1000",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- ORI: funct3=110
        apply(opcode, funct3, funct7, OPC_ITYPE, "110", F7_NORMAL);
        check("I-type ORI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1100",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- ANDI: funct3=111
        apply(opcode, funct3, funct7, OPC_ITYPE, "111", F7_NORMAL);
        check("I-type ANDI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1110",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- SLLI: funct7=0000000 funct3=001
        apply(opcode, funct3, funct7, OPC_ITYPE, "001", F7_NORMAL);
        check("I-type SLLI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0010",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- SRLI: funct7=0000000 funct3=101
        apply(opcode, funct3, funct7, OPC_ITYPE, "101", F7_NORMAL);
        check("I-type SRLI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1010",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- SRAI: funct7=0100000 funct3=101
        apply(opcode, funct3, funct7, OPC_ITYPE, "101", F7_ALT);
        check("I-type SRAI",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "1011",        '1',     '0',      '0',      '1',     '0',     '0',      '0');

        -- ====================================================
        -- LOAD (opcode 0000011)
        -- Control: alu_op=ADD(0000), alu_src=0, we_regfile=1,
        --          alu2reg=0, we_mem=0, imm_rd=0, branch=0
        -- ====================================================
        report "--- Load ---" severity note;

        -- LB: funct3=000
        apply(opcode, funct3, funct7, OPC_LOAD, "000", F7_NORMAL);
        check("Load LB",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '0',      '0',     '0',     '0',      '0');

        -- LH: funct3=001
        apply(opcode, funct3, funct7, OPC_LOAD, "001", F7_NORMAL);
        check("Load LH",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '0',      '0',     '0',     '0',      '0');

        -- LW: funct3=010
        apply(opcode, funct3, funct7, OPC_LOAD, "010", F7_NORMAL);
        check("Load LW",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '0',      '0',     '0',     '0',      '0');

        -- LBU: funct3=100
        apply(opcode, funct3, funct7, OPC_LOAD, "100", F7_NORMAL);
        check("Load LBU",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '0',      '0',     '0',     '0',      '0');

        -- LHU: funct3=101
        apply(opcode, funct3, funct7, OPC_LOAD, "101", F7_NORMAL);
        check("Load LHU",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '1',     '0',      '0',      '0',     '0',     '0',      '0');

        -- ====================================================
        -- STORE (opcode 0100011)
        -- Control: alu_op=ADD(0000), alu_src=0, we_regfile=0,
        --          alu2reg=0, we_mem=1, imm_rd=1, branch=0
        -- ====================================================
        report "--- Store ---" severity note;

        -- SB: funct3=000
        apply(opcode, funct3, funct7, OPC_STORE, "000", F7_NORMAL);
        check("Store SB",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '0',     '1',      '0',      '0',     '1',     '0',      '0');

        -- SH: funct3=001
        apply(opcode, funct3, funct7, OPC_STORE, "001", F7_NORMAL);
        check("Store SH",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '0',     '1',      '0',      '0',     '1',     '0',      '0');

        -- SW: funct3=010
        apply(opcode, funct3, funct7, OPC_STORE, "010", F7_NORMAL);
        check("Store SW",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '0',     '1',      '0',      '0',     '1',     '0',      '0');

        -- ====================================================
        -- BRANCH (opcode 1100011)
        -- Control: we_regfile=0, we_mem=0, alu2reg=0,
        --          imm_rd=0, branch=1, alu_src=1
        -- ====================================================
        report "--- Branch ---" severity note;

        -- BEQ: funct3=000 -> alu_op=0011, br_neg=0
        apply(opcode, funct3, funct7, OPC_BRANCH, "000", F7_NORMAL);
        check("Branch BEQ",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0011",        '0',     '0',      '1',      '0',     '0',     '0',      '1');

        -- BNE: funct3=001 -> alu_op=0011, br_neg=1
        apply(opcode, funct3, funct7, OPC_BRANCH, "001", F7_NORMAL);
        check("Branch BNE",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0011",        '0',     '0',      '1',      '0',     '0',     '1',      '1');

        -- BLT: funct3=100 -> alu_op=0100 (SLT), br_neg=0
        apply(opcode, funct3, funct7, OPC_BRANCH, "100", F7_NORMAL);
        check("Branch BLT",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0100",        '0',     '0',      '1',      '0',     '0',     '0',      '1');

        -- BGE: funct3=101 -> alu_op=0100 (SLT negated), br_neg=1
        apply(opcode, funct3, funct7, OPC_BRANCH, "101", F7_NORMAL);
        check("Branch BGE",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0100",        '0',     '0',      '1',      '0',     '0',     '1',      '1');

        -- BLTU: funct3=110 -> alu_op=0110 (SLTU), br_neg=0
        apply(opcode, funct3, funct7, OPC_BRANCH, "110", F7_NORMAL);
        check("Branch BLTU",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0110",        '0',     '0',      '1',      '0',     '0',     '0',      '1');

        -- BGEU: funct3=111 -> alu_op=0110 (SLTU negated), br_neg=1
        apply(opcode, funct3, funct7, OPC_BRANCH, "111", F7_NORMAL);
        check("Branch BGEU",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0110",        '0',     '0',      '1',      '0',     '0',     '1',      '1');

        -- ====================================================
        -- Unknown opcode: all outputs must default to 0
        -- ====================================================
        report "--- Unknown opcode ---" severity note;
        apply(opcode, funct3, funct7, "1111111", "000", F7_NORMAL);
        check("Unknown opcode defaults",
              alu_op, we_regfile, we_mem, alu_src, alu2reg, imm_rd, br_neg, branch,
              "0000",        '0',     '0',      '0',      '0',     '0',     '0',      '0');

        -- ====================================================
        report "======================================" severity note;
        report "  Simulation end                      " severity note;
        report "======================================" severity note;

        wait;
    end process;

end architecture sim;
