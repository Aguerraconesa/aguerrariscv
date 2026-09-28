library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is 
    port(
        clk_i : in std_logic;
        rst_i : in std_logic
    );
end entity;

architecture rtl of datapath is

    -- Component declaration

    component pc is
        port (
            clk_i : in std_logic;
            rst_i : in std_logic;
            pc_next_i : in std_logic_vector(31 downto 0);
            pc_o : out std_logic_vector(31 downto 0)
        );
    end component;

    component control_unit is 
        port (
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
    end component;

    component alu is
        port (
            operand_a_i : in std_logic_vector(31 downto 0);
            operand_b_i : in std_logic_vector(31 downto 0);
            result_o : out std_logic_vector(31 downto 0);
            opcode_i : in std_logic_vector(3 downto 0)     
        );
    end component;

    component prog_mem is
        port (
            adr_i   : in  std_logic_vector(31 downto 0);  
            dout_o  : out std_logic_vector(31 downto 0)
        );
    end component;

    component ram is
        port (
            clk_i : in std_logic;
            addr_i : in std_logic_vector(31 downto 0);
            data_i : in std_logic_vector(31 downto 0);
            we_i : in std_logic;
            data_o : out std_logic_vector(31 downto 0)            
        );
    end component;

    component reg_file is
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
    end component;

    component sign_and_order is
        port (
            instr_i : in  std_logic_vector(31 downto 0);
            imm_o   : out std_logic_vector(31 downto 0)           
        );
    end component;

    component sign_extent is 
        port (
            data_i : in std_logic_vector(11 downto 0);
            data_o : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals
    signal instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal adr_pc      : std_logic_vector(31 downto 0) := (others => '0');

    signal alu_input_b : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_input_a : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_result  : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_op      : std_logic_vector(3 downto 0)  := (others => '0');

    signal data_out_b  : std_logic_vector(31 downto 0)  := (others => '0');
    signal data_dest   : std_logic_vector(31 downto 0)  := (others => '0');
    signal we_reg      : std_logic := '0';

    signal pc_next     : std_logic_vector(31 downto 0)  := (others => '0');
    
    signal ram_out     : std_logic_vector(31 downto 0)  := (others => '0');
    signal we_ram      : std_logic := '0';

    signal alu2reg     : std_logic := '0';
    signal alu_src     : std_logic := '0';
    signal imm_rd      : std_logic := '0';
    signal br_neg      : std_logic := '0';
    signal branch      : std_logic := '0';

    signal sign_extent_out : std_logic_vector(31 downto 0) := (others => '0');
    signal sign_extent_in : std_logic_vector(11 downto 0) := (others => '0');

    signal offsetpc : std_logic_vector(31 downto 0) := (others => '0');

    signal imm_plus : std_logic_vector(4 downto 0)  := (others => '0');

    signal branchs  : std_logic := '0';

    signal offsetsel : std_logic := '0';

    signal pc_plus : std_logic_vector(31 downto 0) := (others => '0');
begin

    prog_mem_inst: entity work.prog_mem
     port map(
        adr_i => adr_pc,
        dout_o => instruction
    );

    alu_inst: entity work.alu
     port map(
        operand_a_i => alu_input_a,
        operand_b_i => alu_input_b,
        result_o => alu_result,
        opcode_i => alu_op
    );

    reg_file_inst: entity work.reg_file
     port map(
        clk_i => clk_i,
        rst_i => rst_i,
        addr_a_i => instruction(19 downto 15),
        addr_b_i => instruction(24 downto 20),
        addr_dest_i => instruction(11 downto 7),
        data_a_o => alu_input_a,
        data_b_o => data_out_b,
        data_dest_i => data_dest,
        we_i => we_reg
    );

    pc_inst: entity work.pc
     port map(
        clk_i => clk_i,
        rst_i => rst_i,
        pc_next_i => pc_next,
        pc_o => adr_pc
    );

    ram_inst: entity work.ram
     port map(
        clk_i => clk_i,
        addr_i => alu_result,
        data_i => data_out_b,
        we_i => we_ram,
        data_o => ram_out
    );

    control_unit_inst: entity work.control_unit
     port map(
        opcode_i => instruction(6 downto 0),
        funct3_i => instruction(14 downto 12),
        funct7_i => instruction(31 downto 25),
        alu_op_o => alu_op,
        we_regfile_o => we_reg,
        we_mem_o => we_ram,
        alu_src_o => alu_src,
        alu2reg_o => alu2reg,
        imm_rd_o => imm_rd,
        br_neg_o => br_neg,
        branch_o => branch
    );

    sign_extent_inst: entity work.sign_extent
     port map(
        data_i => sign_extent_in,
        data_o => sign_extent_out
    );

    sign_and_order_inst: entity work.sign_and_order
     port map(
        instr_i => instruction,
        imm_o => offsetpc
    );


    alu_input_b <= data_out_b when alu_src = '1' else sign_extent_out;
    
    data_dest <= alu_result when alu2reg = '1' else ram_out;

    imm_plus <= instruction(11 downto 7) when imm_rd = '1' else instruction(24 downto 20);

    sign_extent_in <= instruction(31 downto 25) & imm_plus;

    branchs <= not(alu_result(0)) when br_neg = '1' else alu_result(0);

    offsetsel <= branch and branchs;

    pc_plus <= offsetpc when offsetsel = '1' else x"00000004";

    pc_next <= std_logic_vector(signed(adr_pc) + signed(pc_plus));
end architecture;

