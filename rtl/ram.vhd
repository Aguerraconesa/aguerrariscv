library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    port (
        clk_i : in std_logic;
         -- rst_i : in std_logic;
        addr_i : in std_logic_vector(31 downto 0);
        data_i : in std_logic_vector(31 downto 0);
        we_i : in std_logic;
        data_o : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of ram is
    -- ram of 4096 bytes
    type ram_type is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal ram_mem : ram_type := (others => (others => '0'));
begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if we_i = '1' then
                ram_mem(to_integer(unsigned(addr_i(11 downto 2)))) <= data_i;
            end if;
        end if;
    end process;

    data_o <= ram_mem(to_integer(unsigned(addr_i(11 downto 2))));

end architecture;