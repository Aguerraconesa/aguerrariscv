-- ============================================================
--  Testbench: reg_file_tb
--  Unit under test: reg_file (RISC-V 32x32 register file)
--  Cases covered:
--    - Reset clears all registers
--    - x0 is hardwired to 0 (write ignored)
--    - Basic write then read
--    - Write enable low: data must NOT change
--    - Simultaneous read of two different registers
--    - Overwrite an existing register
--    - Read address 0 always returns 0
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file_tb is
end entity reg_file_tb;

architecture sim of reg_file_tb is

    -- --------------------------------------------------------
    -- Component declaration
    -- --------------------------------------------------------
    component reg_file is
        port (
            clk_i       : in  std_logic;
            rst_i       : in  std_logic;
            addr_a_i    : in  std_logic_vector(4 downto 0);
            addr_b_i    : in  std_logic_vector(4 downto 0);
            addr_dest_i : in  std_logic_vector(4 downto 0);
            data_a_o    : out std_logic_vector(31 downto 0);
            data_b_o    : out std_logic_vector(31 downto 0);
            data_dest_i : in  std_logic_vector(31 downto 0);
            we_i        : in  std_logic
        );
    end component;

    -- --------------------------------------------------------
    -- DUT signals
    -- --------------------------------------------------------
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal addr_a    : std_logic_vector(4 downto 0) := (others => '0');
    signal addr_b    : std_logic_vector(4 downto 0) := (others => '0');
    signal addr_dest : std_logic_vector(4 downto 0) := (others => '0');
    signal data_a    : std_logic_vector(31 downto 0);
    signal data_b    : std_logic_vector(31 downto 0);
    signal data_dest : std_logic_vector(31 downto 0) := (others => '0');
    signal we        : std_logic := '0';

    -- --------------------------------------------------------
    -- Clock: 10 ns period (100 MHz)
    -- --------------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;

    -- --------------------------------------------------------
    -- Helper: write a value to a register and wait one cycle
    -- --------------------------------------------------------
    procedure write_reg(
        signal clk_s       : in  std_logic;
        signal addr_dest_s : out std_logic_vector(4 downto 0);
        signal data_dest_s : out std_logic_vector(31 downto 0);
        signal we_s        : out std_logic;
        addr               : in  integer;
        data               : in  std_logic_vector(31 downto 0)
    ) is
    begin
        addr_dest_s <= std_logic_vector(to_unsigned(addr, 5));
        data_dest_s <= data;
        we_s        <= '1';
        wait until rising_edge(clk_s);
        wait for 1 ns; -- small delta to let outputs settle
    end procedure;

    -- --------------------------------------------------------
    -- Helper: check one output port against expected value
    -- --------------------------------------------------------
    procedure check(
        test_name : in string;
        got       : in std_logic_vector(31 downto 0);
        expected  : in std_logic_vector(31 downto 0)
    ) is
    begin
        if got = expected then
            report "[PASS] " & test_name severity note;
        else
            report "[FAIL] " & test_name &
                   " | expected: 0x" & to_hstring(expected) &
                   "  got: 0x"       & to_hstring(got)
            severity error;
        end if;
    end procedure;

begin

    -- --------------------------------------------------------
    -- DUT instantiation
    -- --------------------------------------------------------
    DUT : reg_file
        port map (
            clk_i       => clk,
            rst_i       => rst,
            addr_a_i    => addr_a,
            addr_b_i    => addr_b,
            addr_dest_i => addr_dest,
            data_a_o    => data_a,
            data_b_o    => data_b,
            data_dest_i => data_dest,
            we_i        => we
        );

    -- --------------------------------------------------------
    -- Clock generation
    -- --------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    -- --------------------------------------------------------
    -- Stimulus process
    -- --------------------------------------------------------
    stim_proc : process
    begin

        report "======================================" severity note;
        report "  Simulation start: reg_file          " severity note;
        report "======================================" severity note;

        -- ====================================================
        -- 1. Reset: all registers must read as 0
        -- ====================================================
        report "--- Reset ---" severity note;
        rst <= '1';
        we  <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        rst <= '0';

        -- Read a few registers to confirm reset
        addr_a <= std_logic_vector(to_unsigned(1,  5));
        addr_b <= std_logic_vector(to_unsigned(15, 5));
        wait for 1 ns;
        check("Reset: x1  = 0", data_a, (others => '0'));
        check("Reset: x15 = 0", data_b, (others => '0'));

        -- ====================================================
        -- 2. x0 is hardwired to 0 (write must be ignored)
        -- ====================================================
        report "--- x0 hardwired zero ---" severity note;
        write_reg(clk, addr_dest, data_dest, we, 0, x"DEADBEEF");
        we      <= '0';
        addr_a  <= std_logic_vector(to_unsigned(0, 5));
        wait for 1 ns;
        check("x0 stays 0 after write attempt", data_a, (others => '0'));

        -- ====================================================
        -- 3. Basic write then read (x1 = 0xCAFEBABE)
        -- ====================================================
        report "--- Basic write / read ---" severity note;
        write_reg(clk, addr_dest, data_dest, we, 1, x"CAFEBABE");
        we     <= '0';
        addr_a <= std_logic_vector(to_unsigned(1, 5));
        wait for 1 ns;
        check("x1 = 0xCAFEBABE", data_a, x"CAFEBABE");

        -- ====================================================
        -- 4. Write enable low: register must NOT change
        -- ====================================================
        report "--- Write enable disabled ---" severity note;
        -- x2 currently holds 0; try to write without we
        addr_dest <= std_logic_vector(to_unsigned(2, 5));
        data_dest <= x"12345678";
        we        <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        addr_a <= std_logic_vector(to_unsigned(2, 5));
        wait for 1 ns;
        check("x2 unchanged (we=0)", data_a, (others => '0'));

        -- ====================================================
        -- 5. Simultaneous read of two different registers
        -- ====================================================
        report "--- Simultaneous dual read ---" severity note;
        -- Write known values to x3 and x4 first
        write_reg(clk, addr_dest, data_dest, we, 3, x"AABBCCDD");
        write_reg(clk, addr_dest, data_dest, we, 4, x"11223344");
        we     <= '0';
        addr_a <= std_logic_vector(to_unsigned(3, 5));
        addr_b <= std_logic_vector(to_unsigned(4, 5));
        wait for 1 ns;
        check("Dual read: x3 = 0xAABBCCDD", data_a, x"AABBCCDD");
        check("Dual read: x4 = 0x11223344", data_b, x"11223344");

        -- ====================================================
        -- 6. Overwrite an existing register
        -- ====================================================
        report "--- Overwrite register ---" severity note;
        -- x1 currently holds 0xCAFEBABE; overwrite with 0xDEADC0DE
        write_reg(clk, addr_dest, data_dest, we, 1, x"DEADC0DE");
        we     <= '0';
        addr_a <= std_logic_vector(to_unsigned(1, 5));
        wait for 1 ns;
        check("x1 overwritten = 0xDEADC0DE", data_a, x"DEADC0DE");

        -- ====================================================
        -- 7. Write to last register x31
        -- ====================================================
        report "--- Last register x31 ---" severity note;
        write_reg(clk, addr_dest, data_dest, we, 31, x"FFFFFFFF");
        we     <= '0';
        addr_a <= std_logic_vector(to_unsigned(31, 5));
        wait for 1 ns;
        check("x31 = 0xFFFFFFFF", data_a, x"FFFFFFFF");

        -- ====================================================
        -- 8. x0 still 0 after all writes above
        -- ====================================================
        report "--- x0 still zero after all writes ---" severity note;
        addr_a <= std_logic_vector(to_unsigned(0, 5));
        wait for 1 ns;
        check("x0 is still 0", data_a, (others => '0'));

        -- ====================================================
        -- 9. Reset clears everything including x31
        -- ====================================================
        report "--- Reset clears all ---" severity note;
        rst <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        rst    <= '0';
        addr_a <= std_logic_vector(to_unsigned(31, 5));
        addr_b <= std_logic_vector(to_unsigned(1,  5));
        wait for 1 ns;
        check("After reset: x31 = 0", data_a, (others => '0'));
        check("After reset: x1  = 0", data_b, (others => '0'));

        -- ====================================================
        report "======================================" severity note;
        report "  Simulation end                      " severity note;
        report "======================================" severity note;

        std.env.stop(0);  -- terminate simulation (needed with free-running clock)
    end process;

end architecture sim;
