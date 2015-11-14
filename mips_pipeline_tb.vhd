library ieee;
use ieee.std_logic_1164.all;
use work.lib.all;

entity mips_pipeline_tb is
end entity;

architecture arch of mips_pipeline_tb is
	constant WIDTH : positive := 32;
	signal done : std_logic := '0';
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
begin
	
	-- Generate clk signal (50MHz)
	clk_gen(clk, done, 50.0E6);
	
	U_MIPS_PIPELINE : entity work.mips_pipeline
		port map (
			clk => clk,
			rst => rst
		);
	
	process
	begin
		rst <= '1';
		wait for 25 ns;
		rst <= '0';
		
		wait for 4000 ns;
		done <= '1';
		
		wait;
	end process;
	
end arch;