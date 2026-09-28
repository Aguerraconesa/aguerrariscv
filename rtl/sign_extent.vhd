library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extent is
    port (
        data_i : in std_logic_vector(11 downto 0);
        data_o : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of sign_extent is
begin

    data_o <= std_logic_vector(resize(signed(data_i), 32));

end architecture;