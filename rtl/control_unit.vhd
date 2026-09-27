library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port (
        -- Intruction decoding
        opcode_i : in std_logic_vector(6 downto 0);
        funct3_i : in std_logic_vector(2 downto 0);
        funct7_i : in std_logic_vector(7 downto 0);

        alu_op_o : out std_logic_vector(3 downto 0);
        we_regfile_o : out std_logic;
        we_mem_o : out std_logic;
        alu_src_o : out std_logic;
        alu2reg_o : out std_logic;
        imm_rd_o : out std_logic;
        br_neg_o : out std_logic;
        branch_o : out std_logic;
    );
end entity;

architecture rtl of control_unit is
begin


    process(opcode_i, funct3_i, funct7_i)
    begin
        alu_op_o <= "0000";
        we_regfile_o <= '0';
        we_mem_o <= '0';
        alu_src_o <= '0';
        alu2reg_o <= '0';
        imm_rd_o <= '0';
        br_neg_o <= '0';
        branch_o <= '0';

    case opcode_i is