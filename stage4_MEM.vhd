library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Stage 4: Memory Access
entity stage4_MEM is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		alu_output : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_B : in std_logic_vector(WIDTH-1 downto 0);
		ctrl_mem_rd : in std_logic;
		ctrl_mem_wr : in std_logic;
		ctrl_byte : in std_logic;
		ctrl_half : in std_logic;
		mem_output : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture arch of stage4_MEM is
	-- Memory
	signal data_mem_output : std_logic_vector(WIDTH-1 downto 0);
begin
	
	-- Altsyncram Data Memory Module
	-- Byte addressable
	U_DATA_MEMORY : entity work.data_memory_wrapper
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => clk,
			rst => rst,
			address => alu_output,
			data => reg_output_B,
			rden => ctrl_mem_rd,
			wren => ctrl_mem_wr,
			byte => ctrl_byte,
			half => ctrl_half,
			output => mem_output
		);
	
end arch;