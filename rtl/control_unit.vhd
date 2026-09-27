library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port (
        -- Intruction decoding
        opcode_i : in std_logic_vector(6 downto 0);
        funct3_i : in std_logic_vector(2 downto 0);
        funct7_i : in std_logic_vector(6 downto 0);

        alu_op_o : out std_logic_vector(3 downto 0);
        we_regfile_o : out std_logic;
        we_mem_o : out std_logic;
        alu_src_o : out std_logic;
        alu2reg_o : out std_logic;
        imm_rd_o : out std_logic;
        br_neg_o : out std_logic;
        branch_o : out std_logic
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
        when "0110011" => -- R-type
            alu_src_o <= '1';
            we_mem_o <= '0';
            we_regfile_o <= '1';
            alu2reg_o <= '1';
            imm_rd_o <= '0';
            br_neg_o <= '0';
            branch_o <= '0';
            case funct7_i is
            when "0000000" =>
                case funct3_i is
                    when "000" => -- ADD
                        alu_op_o <= "0000";
                    when "001" => -- SLL
                        alu_op_o <= "0010";
                    when "010" => -- SLT
                        alu_op_o <= "0100";
                    when "011" => -- SLTU
                        alu_op_o <= "0110";
                    when "100" => -- XOR
                        alu_op_o <= "1000";
                    when "101" => -- SRL
                        alu_op_o <= "1010";
                    when "110" => -- OR
                        alu_op_o <= "1100";
                    when "111" => -- AND
                        alu_op_o <= "1110";
                    when others =>
                        alu_op_o <= "0000"; -- Default to ADD for unknown funct3
                end case;
            when "0100000" =>
                case funct3_i is
                    when "000" => -- SUB
                        alu_op_o <= "0001";
                    when "101" => -- SRA
                        alu_op_o <= "1011";
                    when others =>
                        alu_op_o <= "0000"; -- Default to ADD for unknown funct3 
                end case;
            when others =>
                alu_op_o <= "0000"; -- Default to ADD for unknown funct7
            end case;

        when "0010011" => -- I-type inmmediate
            alu_src_o <= '0';
            we_mem_o <= '0';
            we_regfile_o <= '1';
            alu2reg_o <= '1';
            imm_rd_o <= '0';
            br_neg_o <= '0';
            branch_o <= '0';
            case funct3_i is
                when "000" => -- ADDI
                    alu_op_o <= "0000";
                when "111" => -- ANDI
                    alu_op_o <= "1110";
                when "110" => -- ORI
                    alu_op_o <= "1100";
                when "100" => -- XORI
                    alu_op_o <= "1000";
                when "010" => -- SLTI
                    alu_op_o <= "0100";
                when "011" => -- SLTUI
                    alu_op_o <= "0110";
                when others =>
                    alu_op_o <= "0000"; -- Default to ADDI for unknown funct3
            end case;

            case funct7_i is
                when "0000000" =>
                    case funct3_i is
                        when "001" => -- SLLI
                            alu_op_o <= "0010";
                        when "101" => -- SRLI
                            alu_op_o <= "1010";
                        when others =>
                            alu_op_o <= "0000"; -- Default to ADDI for unknown funct3
                    end case;
                when "0100000" =>
                    case funct3_i is
                        when "101" => -- SRAI
                            alu_op_o <= "1011";
                        when others =>
                            alu_op_o <= "0000"; -- Default to ADDI for unknown funct3
                    end case;
                when others =>
                    alu_op_o <= "0000"; -- Default to ADDI for unknown funct7
            end case;

        when "0000011" => -- Load
            alu_src_o <= '0';
            we_mem_o <= '0';
            we_regfile_o <= '1';
            alu2reg_o <= '0';
            imm_rd_o <= '0';
            br_neg_o <= '0';
            branch_o <= '0';

            case funct3_i is
                when "000" => -- LB
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when "001" => -- LH
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when "010" => -- LW
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when "100" => -- LBU
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when "101" => -- LHU
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when others =>
                    alu_op_o <= "0000"; -- Default to ADD for unknown funct3
            end case;

        when "0100011" => -- Store
            alu_src_o <= '0';
            we_mem_o <= '1';
            we_regfile_o <= '0';
            alu2reg_o <= '0';
            imm_rd_o <= '1';
            br_neg_o <= '0';
            branch_o <= '0';

            case funct3_i is
                when "000" => -- SB
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when "001" => -- SH
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when "010" => -- SW 
                    alu_op_o <= "0000"; -- ADD for address calculation offset
                when others =>
                    alu_op_o <= "0000"; -- Default to ADD for unknown funct3
            end case;

        when "1100011" => -- Branch
            alu_src_o <= '1';
            we_mem_o <= '0';
            we_regfile_o <= '0';
            alu2reg_o <= '0';
            imm_rd_o <= '0';
            branch_o <= '1';
            case funct3_i is
                when "100" => -- BLT
                    alu_op_o <= "0100"; -- SLT for comparison
                    br_neg_o <= '0';
                when "110" => -- BLTU
                    alu_op_o <= "0110"; -- SLTU for comparison
                    br_neg_o <= '0';
                when "101" => -- BGE
                    alu_op_o <= "0100"; -- SLT for comparison
                    br_neg_o <= '1';
                when "111" => -- BGEU
                    alu_op_o <= "0110"; -- SLTU for comparison
                    br_neg_o <= '1';
                when "000" => -- BEQ
                    alu_op_o <= "0011"; -- BEQ for comparison (new alu update)
                    br_neg_o <= '0';
                when "001" => -- BNE
                    alu_op_o <= "0011"; -- BEQ for comparison (new alu update)
                    br_neg_o <= '1'; 
                when others =>
                    alu_op_o <= "0000"; -- Default to ADD for unknown funct3
            end case;
        end case;
    end process;
end architecture;