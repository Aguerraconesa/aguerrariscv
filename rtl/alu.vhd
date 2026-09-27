library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        operand_a_i : in std_logic_vector(31 downto 0);
        operand_b_i : in std_logic_vector(31 downto 0);
        result_o : out std_logic_vector(31 downto 0);
        opcode_i : in std_logic_vector(3 downto 0);
        zero_o : out std_logic
    );
end alu;

architecture rtl of alu is

    signal res_int : std_logic_vector(31 downto 0);

begin
    process(operand_a_i, operand_b_i, opcode_i)
        variable shamt : integer range 0 to 31;
    begin
        shamt := to_integer(unsigned(operand_b_i(4 downto 0)));
        case opcode_i is
            when "0000" =>  -- ADD
                res_int <= std_logic_vector(signed(operand_a_i) + signed(operand_b_i));

            when "0001" =>  -- SUB
                res_int <= std_logic_vector(signed(operand_a_i) - signed(operand_b_i));

            when "0010" =>  -- SLL
                res_int <= std_logic_vector(shift_left(unsigned(operand_a_i), shamt));

            when "0100" =>  -- SLT (con signo)
                if signed(operand_a_i) < signed(operand_b_i) then
                    res_int <= (0 => '1', others => '0');
                else
                    res_int <= (others => '0');
                end if;

            when "0110" =>  -- SLTU (sin signo)
                if unsigned(operand_a_i) < unsigned(operand_b_i) then
                    res_int <= (0 => '1', others => '0');
                else
                    res_int <= (others => '0');
                end if;

            when "1000" =>  -- XOR
                res_int <= operand_a_i xor operand_b_i;

            when "1010" =>  -- SRL
                res_int <= std_logic_vector(shift_right(unsigned(operand_a_i), shamt));

            when "1011" =>  -- SRA
                res_int <= std_logic_vector(shift_right(signed(operand_a_i), shamt));

            when "1100" =>  -- OR
                res_int <= operand_a_i or operand_b_i;

            when "1110" =>  -- AND
                res_int <= operand_a_i and operand_b_i;

            when others =>
                res_int <= (others => '0');

            end case;
        end process;

    result_o <= res_int;
    zero_o <= '1' when res_int = (res_int'range => '0') else '0';
        
end rtl;