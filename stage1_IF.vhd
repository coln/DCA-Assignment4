library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Stage 1: Instruction Fetch
entity stage1_IF is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		branch_target : in std_logic_vector(WIDTH-1 downto 0);
		beq : in std_logic;
		bne : in std_logic;
		jump : in std_logic;
		zero : in std_logic;
		pc : out std_logic_vector(WIDTH-1 downto 0);
		instruction : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture arch of stage1_IF is
	signal delay_cycle : std_logic;
	signal pc_reg_output : std_logic_vector(WIDTH-1 downto 0);
	signal pc_inc1 : std_logic_vector(WIDTH-1 downto 0);
	signal next_pc : std_logic_vector(WIDTH-1 downto 0);
	signal notclk : std_logic;
	signal pc_en : std_logic;
	signal next_pc_src : std_logic;
begin
	
	-- Altsyncram Memory Module (from Quartus Megawizard plugin)
	-- Since this is a simulation, the memory module is only 256 locations deep
	-- Maps to memory location 0x00400000
	pc <= pc_reg_output;
	pc_en <= not rst and bool2logic(pc_reg_output(31 downto 8) = INSTR_BASE_ADDR(31 downto 8));
	
	U_INSTR_MEMORY : entity work.instr_memory
		port map (
			address => pc_reg_output(7 downto 0),
			clock => clk,
			rden => pc_en,
			q => instruction
		);
	
	-- Program Counter (updates on falling edge)
	-- Would normally shift the extender output left by 2 for the word address boundary,
	-- but I am using 32-bit wide instruction memory, so this is unnecessary
	-- Update the PC on the falling edge
	notclk <= not clk;
	
	-- Increment PC on falling edge
	-- Delay 1 cycle to have 1 full clock cycle after reset for the first PC
	process(notclk, rst)
	begin
		if(rst = '1') then
			pc_reg_output <= INSTR_BASE_ADDR;
			delay_cycle <= '0';
		elsif(rising_edge(notclk)) then
			if(delay_cycle = '0') then
				delay_cycle <= '1';
			else
				pc_reg_output <= next_pc;
			end if;
		end if;
	end process;
	
	-- Although MIPS increments the PC by 4, since the memory is 32-bits wide,
	-- We only need to increment the PC by 1 and can multiplex the bytes later
	-- Add helper function in lib.vhd
	pc_inc1 <= add_unsigned(pc_reg_output, 1);
	
	next_pc_src <= not rst and ((beq and zero) or (bne and not zero) or jump);
	-- Only take the branch if next_pc_src AND zero are true
	U_NEXT_PC_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => next_pc_src,
			in0 => pc_inc1,
			in1 => branch_target,
			output => next_pc
		);
	
end arch;
