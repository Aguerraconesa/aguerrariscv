library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        pc_next_i : in std_logic_vector(31 downto 0);
        pc_o : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of pc is
    signal pc_reg : std_logic_vector(31 downto 0);
begin
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk_i) then
            pc_reg <= pc_next_i;
        end if;
    end process;

    pc_o <= pc_reg;

end architecture;