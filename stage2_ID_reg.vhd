library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Pass controls from one stage to another
entity stage2_ID_reg is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		pc : in std_logic_vector(WIDTH-1 downto 0);
		instruction : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_A : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_B : in std_logic_vector(WIDTH-1 downto 0);
		ctrl_beq : in std_logic;
		ctrl_bne : in std_logic;
		ctrl_jump : in std_logic;
		ctrl_jump_addr_src : in std_logic;
		ctrl_reg_dest : in std_logic;
		ctrl_reg_wr : in std_logic;
		ctrl_pc2reg31 : in std_logic;
		ctrl_extender : in std_logic;
		ctrl_alu_src : in std_logic;
		ctrl_alu_op : in std_logic_vector(ALU_OP_WIDTH-1 downto 0);
		ctrl_lui_src : in std_logic;
		ctrl_byte : in std_logic;
		ctrl_half : in std_logic;
		ctrl_mem_rd : in std_logic;
		ctrl_mem_wr : in std_logic;
		ctrl_mem2reg : in std_logic;
		
		pc_out : out std_logic_vector(WIDTH-1 downto 0);
		instruction_out : out std_logic_vector(WIDTH-1 downto 0);
		reg_output_A_out : out std_logic_vector(WIDTH-1 downto 0);
		reg_output_B_out : out std_logic_vector(WIDTH-1 downto 0);
		ctrl_beq_out : out std_logic;
		ctrl_bne_out : out std_logic;
		ctrl_jump_out : out std_logic;
		ctrl_jump_addr_src_out : out std_logic;
		ctrl_reg_dest_out : out std_logic;
		ctrl_reg_wr_out : out std_logic;
		ctrl_pc2reg31_out : out std_logic;
		ctrl_extender_out : out std_logic;
		ctrl_alu_src_out : out std_logic;
		ctrl_alu_op_out : out std_logic_vector(ALU_OP_WIDTH-1 downto 0);
		ctrl_lui_src_out : out std_logic;
		ctrl_byte_out : out std_logic;
		ctrl_half_out : out std_logic;
		ctrl_mem_rd_out : out std_logic;
		ctrl_mem_wr_out : out std_logic;
		ctrl_mem2reg_out : out std_logic
	);
end entity;

architecture arch of stage2_ID_reg is
begin
	
	process(clk, rst)
	begin
		if(rst = '1') then
			pc_out <= (others => '0');
			instruction_out <= (others => '0');
			reg_output_A_out <= (others => '0');
			reg_output_B_out <= (others => '0');
			ctrl_beq_out <= '0';
			ctrl_bne_out <= '0';
			ctrl_jump_out <= '0';
			ctrl_jump_addr_src_out <= '0';
			ctrl_reg_dest_out <= '0';
			ctrl_reg_wr_out <= '0';
			ctrl_pc2reg31_out <= '0';
			ctrl_extender_out <= '0';
			ctrl_alu_src_out <= '0';
			ctrl_alu_op_out <= (others => '0');
			ctrl_lui_src_out <= '0';
			ctrl_byte_out <= '0';
			ctrl_half_out <= '0';
			ctrl_mem_rd_out <= '0';
			ctrl_mem_wr_out <= '0';
			ctrl_mem2reg_out <= '0';
		elsif(rising_edge(clk)) then
			pc_out <= pc;
			instruction_out <= instruction;
			reg_output_A_out <= reg_output_A;
			reg_output_B_out <= reg_output_B;
			ctrl_beq_out <= ctrl_beq;
			ctrl_bne_out <= ctrl_bne;
			ctrl_jump_out <= ctrl_jump;
			ctrl_jump_addr_src_out <= ctrl_jump_addr_src;
			ctrl_reg_dest_out <= ctrl_reg_dest;
			ctrl_reg_wr_out <= ctrl_reg_wr;
			ctrl_pc2reg31_out <= ctrl_pc2reg31;
			ctrl_extender_out <= ctrl_extender;
			ctrl_alu_src_out <= ctrl_alu_src;
			ctrl_alu_op_out <= ctrl_alu_op;
			ctrl_lui_src_out <= ctrl_lui_src;
			ctrl_byte_out <= ctrl_byte;
			ctrl_half_out <= ctrl_half;
			ctrl_mem_rd_out <= ctrl_mem_rd;
			ctrl_mem_wr_out <= ctrl_mem_wr;
			ctrl_mem2reg_out <= ctrl_mem2reg;
		end if;
	end process;
	
end arch;
