library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Pass controls from one stage to another
entity stage4_MEM_reg is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		pc : in std_logic_vector(WIDTH-1 downto 0);
		instruction : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_B : in std_logic_vector(WIDTH-1 downto 0);
		alu_output : in std_logic_vector(WIDTH-1 downto 0);
		mem_output : in std_logic_vector(WIDTH-1 downto 0);
		ctrl_lui_src : in std_logic;
		ctrl_reg_dest : in std_logic;
		ctrl_reg_wr : in std_logic;
		ctrl_pc2reg31 : in std_logic;
		ctrl_mem2reg : in std_logic;
		
		pc_out : out std_logic_vector(WIDTH-1 downto 0);
		instruction_out : out std_logic_vector(WIDTH-1 downto 0);
		reg_output_B_out : out std_logic_vector(WIDTH-1 downto 0);
		alu_output_out : out std_logic_vector(WIDTH-1 downto 0);
		mem_output_out : out std_logic_vector(WIDTH-1 downto 0);
		ctrl_lui_src_out : out std_logic;
		ctrl_reg_dest_out : out std_logic;
		ctrl_reg_wr_out : out std_logic;
		ctrl_pc2reg31_out : out std_logic;
		ctrl_mem2reg_out : out std_logic
	);
end entity;

architecture arch of stage4_MEM_reg is
begin
	
	process(clk, rst)
	begin
		if(rst = '1') then
			pc_out <= (others => '0');
			instruction_out <= (others => '0');
			reg_output_B_out <= (others => '0');
			alu_output_out <= (others => '0');
			mem_output_out <= (others => '0');
			ctrl_lui_src_out <= '0';
			ctrl_reg_dest_out <= '0';
			ctrl_reg_wr_out <= '0';
			ctrl_pc2reg31_out <= '0';
			ctrl_mem2reg_out <= '0';
		elsif(rising_edge(clk)) then
			pc_out <= pc;
			instruction_out <= instruction;
			reg_output_B_out <= reg_output_B;
			alu_output_out <= alu_output;
			mem_output_out <= mem_output;
			ctrl_lui_src_out <= ctrl_lui_src;
			ctrl_reg_dest_out <= ctrl_reg_dest;
			ctrl_reg_wr_out <= ctrl_reg_wr;
			ctrl_pc2reg31_out <= ctrl_pc2reg31;
			ctrl_mem2reg_out <= ctrl_mem2reg;
		end if;
	end process;
	
end arch;
