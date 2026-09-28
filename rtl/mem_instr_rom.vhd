-- ROM 256 Bytes
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prog_mem is
    port (
        adr_i   : in  std_logic_vector(31 downto 0);  -- Program Counter (byte address)
        dout_o  : out std_logic_vector(31 downto 0)   -- Instruction output
    );
end entity prog_mem;

architecture ROM of prog_mem is

    type mem_type is array (0 to 63) of std_logic_vector(31 downto 0);

    constant MEM : mem_type := (
        --         31      24 23      16 15       8 7        0
        0  => x"00000093",  -- addi x1, x0, 0    | 0000_0000 0000_0000 0000_0000 1001_0011
        1  => x"00100113",  -- addi x2, x0, 1    | 0000_0000 0001_0000 0000_0001 0001_0011
        2  => x"002081B3",  -- add  x3, x1, x2   | 0000_0000 0010_0000 1000_0001 1011_0011
        3  => x"003101B3",  -- add  x3, x2, x3   | 0000_0000 0011_0001 0000_0001 1011_0011  
        4  => x"0010A023",  -- sw   x1, 0(x1)    | 0000_0000 0001_0000 1010_0000 0010_0011
        5  => x"0000A103",  -- lw   x2, 0(x1)    | 0000_0000 0000_0000 1010_0001 0000_0011
        6  => x"00209463",  -- bne  x1, x2, +8   | 0000_0000 0010_0000 1001_0100 0110_0011
        others => x"00000013"  -- NOP: addi x0, x0, 0 | 0000_0000 0000_0000 0000_0000 0001_0011
    );

begin

    dout_o <= MEM(to_integer(unsigned(adr_i(31 downto 2))));

end architecture ROM;