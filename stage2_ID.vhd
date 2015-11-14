library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Stage 2: Instruction Decode
entity stage2_ID is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		instruction : in std_logic_vector(WIDTH-1 downto 0);
		reg_wr : in std_logic;
		reg_write_addr : in std_logic_vector(get_log2(WIDTH)-1 downto 0);
		reg_write_data : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_A : out std_logic_vector(WIDTH-1 downto 0);
		reg_output_B : out std_logic_vector(WIDTH-1 downto 0);
		ctrl_beq : out std_logic;
		ctrl_bne : out std_logic;
		ctrl_jump : out std_logic;
		ctrl_jump_addr_src : out std_logic;
		ctrl_reg_dest : out std_logic;
		ctrl_reg_wr : out std_logic;
		ctrl_pc2reg31 : out std_logic;
		ctrl_extender : out std_logic;
		ctrl_alu_src : out std_logic;
		ctrl_alu_op : out std_logic_vector(ALU_OP_WIDTH-1 downto 0);
		ctrl_lui_src : out std_logic;
		ctrl_byte : out std_logic;
		ctrl_half : out std_logic;
		ctrl_mem_rd : out std_logic;
		ctrl_mem_wr : out std_logic;
		ctrl_mem2reg : out std_logic
	);	
end entity;

architecture arch of stage2_ID is
	signal delay_reg_write_addr : std_logic_vector(get_log2(WIDTH)-1 downto 0);
	signal delay_reg_write_data : std_logic_vector(WIDTH-1 downto 0);
	signal delay_reg_wr : std_logic;
begin
	
	-- Control Logic State Machine
	U_CONTROL : entity work.control
		port map (
			rst => rst,
			opcode => instruction(OPCODE_RANGE),
			func => instruction(RTYPE_FUNC_RANGE),
			beq => ctrl_beq,
			bne => ctrl_bne,
			jump => ctrl_jump,
			jump_addr_src => ctrl_jump_addr_src,
			pc2reg31 => ctrl_pc2reg31,
			reg_dest => ctrl_reg_dest,
			reg_wr => ctrl_reg_wr,
			extender => ctrl_extender,
			alu_src => ctrl_alu_src,
			alu_op => ctrl_alu_op,
			lui_src => ctrl_lui_src,
			byte => ctrl_byte,
			half => ctrl_half,
			mem_rd => ctrl_mem_rd,
			mem_wr => ctrl_mem_wr,
			mem2reg => ctrl_mem2reg
		);
	
	-- We need to delay the write signals because the WB stage sends them
	-- WITH the falling clock edge, and this creates a race condition
	process(clk, rst)
	begin
		if(rst = '1') then
			delay_reg_write_addr <= (others => '0');
			delay_reg_write_data <= (others => '0');
			delay_reg_wr <= '0';
		elsif(rising_edge(clk)) then
			delay_reg_write_addr <= reg_write_addr;
			delay_reg_write_data <= reg_write_data;
			delay_reg_wr <= reg_wr;
		end if;
	end process;
	
	-- 32 Registers
	U_REG_FILE : entity work.reg_file
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => clk,
			rst => rst,
			rr0 => instruction(RS_RANGE),
			rr1 => instruction(RT_RANGE),
			q0 => reg_output_A,
			q1 => reg_output_B,
			wr => delay_reg_wr,
			rw => delay_reg_write_addr,
			d => delay_reg_write_data
		);
	
end arch;