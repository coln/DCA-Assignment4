library ieee;
use ieee.std_logic_1164.all;

-- Simple register with data width of WIDTH
entity reg is
	generic (
		WIDTH : positive := 32
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		wr : in std_logic;
		input : in std_logic_vector(WIDTH-1 downto 0);
		output : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture arch of reg is
begin

	process(clk, rst)
	begin
		if(rst = '1') then
			output <= (others => '0');
		elsif(rising_edge(clk)) then
			if(wr = '1') then
				output <= input;
			end if;
		end if;
	end process;

end arch;