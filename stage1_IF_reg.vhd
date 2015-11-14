library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Pass controls from one stage to another
entity stage1_IF_reg is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		pc : in std_logic_vector(WIDTH-1 downto 0);
		instruction : in std_logic_vector(WIDTH-1 downto 0);
		
		pc_out : out std_logic_vector(WIDTH-1 downto 0);
		instruction_out : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture arch of stage1_IF_reg is
begin
	
	process(clk, rst)
	begin
		if(rst = '1') then
			pc_out <= (others => '0');
			instruction_out <= (others => '0');
		elsif(rising_edge(clk)) then
			pc_out <= pc;
			instruction_out <= instruction;
		end if;
	end process;
	
end arch;
