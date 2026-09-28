-- ============================================================
--  Testbench: alu_tb
--  Unit under test: alu (RISC-V ALU, 32-bit)
--  Opcodes covered:
--    0000 ADD  | 0001 SUB  | 0010 SLL  | 0011 BEQ
--    0100 SLT  | 0110 SLTU | 1000 XOR  | 1010 SRL
--    1011 SRA  | 1100 OR   | 1110 AND
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
-- Testbenches have no ports
end entity alu_tb;

architecture sim of alu_tb is

    -- --------------------------------------------------------
    -- Declaration of the device under test (DUT)
    -- --------------------------------------------------------
    component alu is
        port (
            operand_a_i : in  std_logic_vector(31 downto 0);
            operand_b_i : in  std_logic_vector(31 downto 0);
            result_o    : out std_logic_vector(31 downto 0);
            opcode_i    : in  std_logic_vector(3 downto 0);
            zero_o      : out std_logic
        );
    end component;

    -- --------------------------------------------------------
    -- Signals connecting the TB to the DUT
    -- --------------------------------------------------------
    signal operand_a : std_logic_vector(31 downto 0) := (others => '0');
    signal operand_b : std_logic_vector(31 downto 0) := (others => '0');
    signal opcode    : std_logic_vector(3 downto 0)  := (others => '0');
    signal result    : std_logic_vector(31 downto 0);
    signal zero      : std_logic;

    -- --------------------------------------------------------
    -- Opcode constants (matching the ALU)
    -- --------------------------------------------------------
    constant OP_ADD  : std_logic_vector(3 downto 0) := "0000";
    constant OP_SUB  : std_logic_vector(3 downto 0) := "0001";
    constant OP_SLL  : std_logic_vector(3 downto 0) := "0010";
    constant OP_BEQ  : std_logic_vector(3 downto 0) := "0011";
    constant OP_SLT  : std_logic_vector(3 downto 0) := "0100";
    constant OP_SLTU : std_logic_vector(3 downto 0) := "0110";
    constant OP_XOR  : std_logic_vector(3 downto 0) := "1000";
    constant OP_SRL  : std_logic_vector(3 downto 0) := "1010";
    constant OP_SRA  : std_logic_vector(3 downto 0) := "1011";
    constant OP_OR   : std_logic_vector(3 downto 0) := "1100";
    constant OP_AND  : std_logic_vector(3 downto 0) := "1110";

    -- --------------------------------------------------------
    -- Helper procedure for checking results
    -- Prints PASS/FAIL to the simulator console
    -- --------------------------------------------------------
    procedure check(
        test_name    : in string;
        got_result   : in std_logic_vector(31 downto 0);
        exp_result   : in std_logic_vector(31 downto 0);
        got_zero     : in std_logic;
        exp_zero     : in std_logic
    ) is
    begin
        if got_result = exp_result and got_zero = exp_zero then
            report "[PASS] " & test_name severity note;
        else
            report "[FAIL] " & test_name &
                   " | result esperado: " & integer'image(to_integer(signed(exp_result))) &
                   " obtenido: "          & integer'image(to_integer(signed(got_result))) &
                   " | zero esperado: "   & std_logic'image(exp_zero) &
                   " obtenido: "          & std_logic'image(got_zero)
            severity error;
        end if;
    end procedure;

begin

    -- --------------------------------------------------------
    -- DUT instantiation
    -- --------------------------------------------------------
    DUT : alu
        port map (
            operand_a_i => operand_a,
            operand_b_i => operand_b,
            opcode_i    => opcode,
            result_o    => result,
            zero_o      => zero
        );

    -- --------------------------------------------------------
    -- Stimulus process
    -- --------------------------------------------------------
    stim_proc : process
    begin

        report "======================================" severity note;
        report "  Inicio de simulacion: ALU RISC-V   " severity note;
        report "======================================" severity note;

        -- ====================================================
        -- 1. ADD (0000)
        -- ====================================================
        report "--- ADD ---" severity note;

        -- 5 + 3 = 8
        opcode    <= OP_ADD;
        operand_a <= std_logic_vector(to_signed(5, 32));
        operand_b <= std_logic_vector(to_signed(3, 32));
        wait for 10 ns;
        check("ADD 5+3=8", result, std_logic_vector(to_signed(8,32)), zero, '0');

        -- 0 + 0 = 0  -> zero debe ser '1'
        operand_a <= (others => '0');
        operand_b <= (others => '0');
        wait for 10 ns;
        check("ADD 0+0=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- Addition with a negative number: -10 + 10 = 0
        operand_a <= std_logic_vector(to_signed(-10, 32));
        operand_b <= std_logic_vector(to_signed(10,  32));
        wait for 10 ns;
        check("ADD -10+10=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- Controlled positive overflow: 2147483647 + 1 = -2147483648 (signed wraparound)
        operand_a <= std_logic_vector(to_signed(2147483647, 32));
        operand_b <= std_logic_vector(to_signed(1, 32));
        wait for 10 ns;
        check("ADD overflow +MAX+1", result, std_logic_vector(to_signed(-2147483648,32)), zero, '0');

        -- ====================================================
        -- 2. SUB (0001)
        -- ====================================================
        report "--- SUB ---" severity note;

        -- 10 - 3 = 7
        opcode    <= OP_SUB;
        operand_a <= std_logic_vector(to_signed(10, 32));
        operand_b <= std_logic_vector(to_signed(3,  32));
        wait for 10 ns;
        check("SUB 10-3=7", result, std_logic_vector(to_signed(7,32)), zero, '0');

        -- 5 - 5 = 0 -> zero='1'
        operand_a <= std_logic_vector(to_signed(5, 32));
        operand_b <= std_logic_vector(to_signed(5, 32));
        wait for 10 ns;
        check("SUB 5-5=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- 3 - 10 = -7 (resultado negativo)
        operand_a <= std_logic_vector(to_signed(3,  32));
        operand_b <= std_logic_vector(to_signed(10, 32));
        wait for 10 ns;
        check("SUB 3-10=-7", result, std_logic_vector(to_signed(-7,32)), zero, '0');

        -- ====================================================
        -- 3. SLL (0010) - Shift Left Logical
        -- ====================================================
        report "--- SLL ---" severity note;

        -- 1 << 4 = 16
        opcode    <= OP_SLL;
        operand_a <= std_logic_vector(to_unsigned(1, 32));
        operand_b <= std_logic_vector(to_unsigned(4, 32));  -- shamt=4 (bits 4:0)
        wait for 10 ns;
        check("SLL 1<<4=16", result, std_logic_vector(to_unsigned(16,32)), zero, '0');

        -- 1 << 0 = 1 (no shift)
        operand_b <= (others => '0');
        wait for 10 ns;
        check("SLL 1<<0=1", result, std_logic_vector(to_unsigned(1,32)), zero, '0');

        -- 1 << 31 = 0x80000000
        operand_a <= std_logic_vector(to_unsigned(1, 32));
        operand_b <= std_logic_vector(to_unsigned(31, 32));
        wait for 10 ns;
        check("SLL 1<<31=0x80000000", result, x"80000000", zero, '0');

        -- ====================================================
        -- 4. BEQ (0011) - Branch Equal
        -- ====================================================
        report "--- BEQ ---" severity note;

        -- Equal -> result=1
        opcode    <= OP_BEQ;
        operand_a <= std_logic_vector(to_signed(42, 32));
        operand_b <= std_logic_vector(to_signed(42, 32));
        wait for 10 ns;
        check("BEQ iguales -> result=1", result, std_logic_vector(to_signed(1,32)), zero, '0');

        -- Not equal -> result=0
        operand_a <= std_logic_vector(to_signed(1, 32));
        operand_b <= std_logic_vector(to_signed(2, 32));
        wait for 10 ns;
        check("BEQ distintos -> result=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- ====================================================
        -- 5. SLT (0100) - Set Less Than (signed)
        -- ====================================================
        report "--- SLT ---" severity note;

        -- -1 < 0 -> 1
        opcode    <= OP_SLT;
        operand_a <= std_logic_vector(to_signed(-1, 32));
        operand_b <= std_logic_vector(to_signed(0,  32));
        wait for 10 ns;
        check("SLT -1<0 -> 1", result, std_logic_vector(to_signed(1,32)), zero, '0');

        -- 5 < 3 -> 0
        operand_a <= std_logic_vector(to_signed(5, 32));
        operand_b <= std_logic_vector(to_signed(3, 32));
        wait for 10 ns;
        check("SLT 5<3 -> 0 (zero=1)", result, (others=>'0'), zero, '1');

        -- 3 < 3 -> 0 (equal)
        operand_a <= std_logic_vector(to_signed(3, 32));
        operand_b <= std_logic_vector(to_signed(3, 32));
        wait for 10 ns;
        check("SLT 3<3 -> 0 (zero=1)", result, (others=>'0'), zero, '1');

        -- ====================================================
        -- 6. SLTU (0110) - Set Less Than Unsigned
        -- ====================================================
        report "--- SLTU ---" severity note;

        -- 1 < 2 -> 1
        opcode    <= OP_SLTU;
        operand_a <= std_logic_vector(to_unsigned(1, 32));
        operand_b <= std_logic_vector(to_unsigned(2, 32));
        wait for 10 ns;
        check("SLTU 1<2 -> 1", result, std_logic_vector(to_signed(1,32)), zero, '0');

        -- 0xFFFFFFFF < 0 is false, but unsigned: 0 < 0xFFFFFFFF -> 1
        operand_a <= (others => '0');
        operand_b <= (others => '1');
        wait for 10 ns;
        check("SLTU 0<0xFFFFFFFF -> 1", result, std_logic_vector(to_signed(1,32)), zero, '0');

        -- 0xFFFFFFFF < 1 -> 0 (unsigned, it is very large)
        operand_a <= (others => '1');
        operand_b <= std_logic_vector(to_unsigned(1, 32));
        wait for 10 ns;
        check("SLTU 0xFFFF<1 -> 0 (zero=1)", result, (others=>'0'), zero, '1');

        -- ====================================================
        -- 7. XOR (1000)
        -- ====================================================
        report "--- XOR ---" severity note;

        -- 0xF0F0F0F0 XOR 0x0F0F0F0F = 0xFFFFFFFF
        opcode    <= OP_XOR;
        operand_a <= x"F0F0F0F0";
        operand_b <= x"0F0F0F0F";
        wait for 10 ns;
        check("XOR F0..^0F..=FF..", result, x"FFFFFFFF", zero, '0');

        -- A XOR A = 0
        operand_a <= x"ABCD1234";
        operand_b <= x"ABCD1234";
        wait for 10 ns;
        check("XOR A^A=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- ====================================================
        -- 8. SRL (1010) - Shift Right Logical
        -- ====================================================
        report "--- SRL ---" severity note;

        -- 0x80000000 >> 1 = 0x40000000 (does not sign-extend)
        opcode    <= OP_SRL;
        operand_a <= x"80000000";
        operand_b <= std_logic_vector(to_unsigned(1, 32));
        wait for 10 ns;
        check("SRL 0x80000000>>1=0x40000000", result, x"40000000", zero, '0');

        -- 16 >> 4 = 1
        operand_a <= std_logic_vector(to_unsigned(16, 32));
        operand_b <= std_logic_vector(to_unsigned(4,  32));
        wait for 10 ns;
        check("SRL 16>>4=1", result, std_logic_vector(to_unsigned(1,32)), zero, '0');

        -- ====================================================
        -- 9. SRA (1011) - Shift Right Arithmetic
        -- ====================================================
        report "--- SRA ---" severity note;

        -- 0x80000000 >> 1 = 0xC0000000 (sign-extends)
        opcode    <= OP_SRA;
        operand_a <= x"80000000";
        operand_b <= std_logic_vector(to_unsigned(1, 32));
        wait for 10 ns;
        check("SRA 0x80000000>>1=0xC0000000", result, x"C0000000", zero, '0');

        -- -8 >> 2 = -2
        operand_a <= std_logic_vector(to_signed(-8, 32));
        operand_b <= std_logic_vector(to_unsigned(2, 32));
        wait for 10 ns;
        check("SRA -8>>2=-2", result, std_logic_vector(to_signed(-2,32)), zero, '0');

        -- Positive: 8 >> 1 = 4 (same as SRL for positive values)
        operand_a <= std_logic_vector(to_signed(8, 32));
        operand_b <= std_logic_vector(to_unsigned(1, 32));
        wait for 10 ns;
        check("SRA 8>>1=4", result, std_logic_vector(to_signed(4,32)), zero, '0');

        -- ====================================================
        -- 10. OR (1100)
        -- ====================================================
        report "--- OR ---" severity note;

        -- 0xF0F0F0F0 OR 0x0F0F0F0F = 0xFFFFFFFF
        opcode    <= OP_OR;
        operand_a <= x"F0F0F0F0";
        operand_b <= x"0F0F0F0F";
        wait for 10 ns;
        check("OR F0..|0F..=FF..", result, x"FFFFFFFF", zero, '0');

        -- 0 OR 0 = 0
        operand_a <= (others => '0');
        operand_b <= (others => '0');
        wait for 10 ns;
        check("OR 0|0=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- ====================================================
        -- 11. AND (1110)
        -- ====================================================
        report "--- AND ---" severity note;

        -- 0xFF00FF00 AND 0x00FF00FF = 0x00000000
        opcode    <= OP_AND;
        operand_a <= x"FF00FF00";
        operand_b <= x"00FF00FF";
        wait for 10 ns;
        check("AND FF00&00FF=0 (zero=1)", result, (others=>'0'), zero, '1');

        -- 0xFFFFFFFF AND 0xABCD1234 = 0xABCD1234
        operand_a <= (others => '1');
        operand_b <= x"ABCD1234";
        wait for 10 ns;
        check("AND FF..&ABCD=ABCD", result, x"ABCD1234", zero, '0');

        -- ====================================================
        -- 12. Invalid opcode -> result 0
        -- ====================================================
        report "--- Opcode invalido ---" severity note;
        opcode    <= "0101";   -- not defined in the ALU
        operand_a <= x"DEADBEEF";
        operand_b <= x"CAFEBABE";
        wait for 10 ns;
        check("Opcode invalido -> 0 (zero=1)", result, (others=>'0'), zero, '1');

        -- ====================================================
        report "======================================" severity note;
        report "  Fin de simulacion                  " severity note;
        report "======================================" severity note;

        wait; -- Stop the simulation
    end process;

end architecture sim;
