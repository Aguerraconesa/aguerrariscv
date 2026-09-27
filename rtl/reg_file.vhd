library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        addr_a_i : in std_logic_vector(4 downto 0);
        addr_b_i : in std_logic_vector(4 downto 0);
        addr_dest_i : in std_logic_vector(4 downto 0);
        data_a_o : out std_logic_vector(31 downto 0);
        data_b_o : out std_logic_vector(31 downto 0);
        data_dest_i : in std_logic_vector(31 downto 0);
        we_i : in std_logic
    );
end reg_file;

architecture behavioral of reg_file is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal registers : reg_array := (others => (others => '0'));
begin
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk_i) then
            if we_i = '1' and to_integer(unsigned(addr_dest_i)) /= 0 then
                registers(to_integer(unsigned(addr_dest_i))) <= data_dest_i; -- vhdl no puede usar un vector de std_logic_vector como indice, es por eso que lo convertimos hasta tener un integer
            end if;
        end if;
    end process;

    data_a_o <= registers(to_integer(unsigned(addr_a_i)));
    data_b_o <= registers(to_integer(unsigned(addr_b_i)));

end behavioral;