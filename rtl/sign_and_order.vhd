library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_and_order is
    port (
        instr_i : in  std_logic_vector(31 downto 0);
        imm_o   : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of sign_and_order is
    signal imm_b : std_logic_vector(12 downto 0);
begin
    -- Reassemble B-type immediate from scattered instruction bits:
    -- imm[12]   = instr[31]
    -- imm[11]   = instr[7]
    -- imm[10:5] = instr[30:25]
    -- imm[4:1]  = instr[11:8]
    -- imm[0]    = '0' (always word-aligned)
    imm_b <= instr_i(31) & instr_i(7) & instr_i(30 downto 25) & instr_i(11 downto 8) & '0';

    -- Sign extend to 32 bits
    imm_o <= std_logic_vector(resize(signed(imm_b), 32));

end architecture;