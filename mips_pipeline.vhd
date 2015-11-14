library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- MIPS mutli-cycle processor implementation
-- clk and rst - Main processor
-- mem_clk - Memory clock (should be ~3-4 times faster)
entity mips_pipeline is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		clk : in std_logic;
		rst : in std_logic
	);
end entity;

architecture arch of mips_pipeline is
	signal notclk : std_logic;
	
	-- Stage 1/2 IF register signals
	signal IF_pc_in : std_logic_vector(WIDTH-1 downto 0);
	signal IF_instruction_in : std_logic_vector(WIDTH-1 downto 0);
	signal IF_pc_out : std_logic_vector(WIDTH-1 downto 0);
	signal IF_instruction_out : std_logic_vector(WIDTH-1 downto 0);
	
	-- Stage 2/3 ID register signals
	signal ID_reg_output_A_in : std_logic_vector(WIDTH-1 downto 0);
	signal ID_reg_output_B_in : std_logic_vector(WIDTH-1 downto 0);
	signal ID_ctrl_next_pc_src_in : std_logic;
	signal ID_ctrl_beq_in : std_logic;
	signal ID_ctrl_bne_in : std_logic;
	signal ID_ctrl_jump_in : std_logic;
	signal ID_ctrl_jump_addr_src_in : std_logic;
	signal ID_ctrl_reg_dest_in : std_logic;
	signal ID_ctrl_reg_wr_in : std_logic;
	signal ID_ctrl_pc2reg31_in : std_logic;
	signal ID_ctrl_extender_in : std_logic;
	signal ID_ctrl_alu_src_in : std_logic;
	signal ID_ctrl_alu_op_in : std_logic_vector(ALU_OP_WIDTH-1 downto 0);
	signal ID_ctrl_lui_src_in : std_logic;
	signal ID_ctrl_byte_in : std_logic;
	signal ID_ctrl_half_in : std_logic;
	signal ID_ctrl_mem_rd_in : std_logic;
	signal ID_ctrl_mem_wr_in : std_logic;
	signal ID_ctrl_mem2reg_in : std_logic;
	signal ID_pc_out : std_logic_vector(WIDTH-1 downto 0);
	signal ID_instruction_out : std_logic_vector(WIDTH-1 downto 0);
	signal ID_reg_output_A_out : std_logic_vector(WIDTH-1 downto 0);
	signal ID_reg_output_B_out : std_logic_vector(WIDTH-1 downto 0);
	signal ID_ctrl_next_pc_src_out : std_logic;
	signal ID_ctrl_beq_out : std_logic;
	signal ID_ctrl_bne_out : std_logic;
	signal ID_ctrl_jump_out : std_logic;
	signal ID_ctrl_jump_addr_src_out : std_logic;
	signal ID_ctrl_reg_dest_out : std_logic;
	signal ID_ctrl_reg_wr_out : std_logic;
	signal ID_ctrl_pc2reg31_out : std_logic;
	signal ID_ctrl_extender_out : std_logic;
	signal ID_ctrl_alu_src_out : std_logic;
	signal ID_ctrl_alu_op_out : std_logic_vector(ALU_OP_WIDTH-1 downto 0);
	signal ID_ctrl_lui_src_out : std_logic;
	signal ID_ctrl_byte_out : std_logic;
	signal ID_ctrl_half_out : std_logic;
	signal ID_ctrl_mem_rd_out : std_logic;
	signal ID_ctrl_mem_wr_out : std_logic;
	signal ID_ctrl_mem2reg_out : std_logic;
	
	-- Stage 3/4 EX register signals
	signal EX_branch_target : std_logic_vector(WIDTH-1 downto 0);
	signal EX_alu_output_in : std_logic_vector(WIDTH-1 downto 0);
	signal EX_alu_zero : std_logic;
	signal EX_pc_out : std_logic_vector(WIDTH-1 downto 0);
	signal EX_instruction_out : std_logic_vector(WIDTH-1 downto 0);
	signal EX_alu_output_out : std_logic_vector(WIDTH-1 downto 0);
	signal EX_branch_target_out : std_logic_vector(WIDTH-1 downto 0);
	signal EX_reg_output_B_out : std_logic_vector(WIDTH-1 downto 0);
	signal EX_ctrl_lui_src_out : std_logic;
	signal EX_ctrl_reg_dest_out : std_logic;
	signal EX_ctrl_reg_wr_out : std_logic;
	signal EX_ctrl_pc2reg31_out : std_logic;
	signal EX_ctrl_byte_out : std_logic;
	signal EX_ctrl_half_out : std_logic;
	signal EX_ctrl_mem_rd_out : std_logic;
	signal EX_ctrl_mem_wr_out : std_logic;
	signal EX_ctrl_mem2reg_out : std_logic;
	
	-- Stage 4/5 MEM register signals
	signal MEM_alu_output_in : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_mem_output_in : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_pc_out : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_instruction_out : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_reg_output_B_out : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_alu_output_out : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_mem_output_out : std_logic_vector(WIDTH-1 downto 0);
	signal MEM_ctrl_lui_src_out : std_logic;
	signal MEM_ctrl_reg_dest_out : std_logic;
	signal MEM_ctrl_reg_wr_out : std_logic;
	signal MEM_ctrl_pc2reg31_out : std_logic;
	signal MEM_ctrl_mem2reg_out : std_logic;
	
	-- Stage 5/1 WB signals (no register)
	signal WB_reg_write_addr_out : std_logic_vector(get_log2(WIDTH)-1 downto 0);
	signal WB_reg_write_data_out : std_logic_vector(WIDTH-1 downto 0);
	
begin
	
	notclk <= not clk;
	
	-- Stage 1: Instruction Fetch
	U_STAGE1_IF : entity work.stage1_IF
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => clk,
			rst => rst,
			branch_target => EX_branch_target,
			beq => ID_ctrl_beq_out,
			bne => ID_ctrl_bne_out,
			jump => ID_ctrl_jump_out,
			zero => EX_alu_zero,
			pc => IF_pc_in,
			instruction => IF_instruction_in
		);
	
	U_IF_REG : entity work.stage1_IF_reg
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => notclk,
			rst => rst,
			pc => IF_pc_in,
			instruction => IF_instruction_in,
			pc_out => IF_pc_out,
			instruction_out => IF_instruction_out
		);
	
			
	
	-- Stage 2: Instruction Decode
	U_STAGE2_ID : entity work.stage2_ID
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => clk,
			rst => rst,
			instruction => IF_instruction_out,
			reg_wr => MEM_ctrl_reg_wr_out,
			reg_write_addr => WB_reg_write_addr_out,
			reg_write_data => WB_reg_write_data_out,
			reg_output_A => ID_reg_output_A_in,
			reg_output_B => ID_reg_output_B_in,
			ctrl_beq => ID_ctrl_beq_in,
			ctrl_bne => ID_ctrl_bne_in,
			ctrl_jump => ID_ctrl_jump_in,
			ctrl_jump_addr_src => ID_ctrl_jump_addr_src_in,
			ctrl_reg_dest => ID_ctrl_reg_dest_in,
			ctrl_reg_wr => ID_ctrl_reg_wr_in,
			ctrl_pc2reg31 => ID_ctrl_pc2reg31_in,
			ctrl_extender => ID_ctrl_extender_in,
			ctrl_alu_src => ID_ctrl_alu_src_in,
			ctrl_alu_op => ID_ctrl_alu_op_in,
			ctrl_lui_src => ID_ctrl_lui_src_in,
			ctrl_byte => ID_ctrl_byte_in,
			ctrl_half => ID_ctrl_half_in,
			ctrl_mem_rd => ID_ctrl_mem_rd_in,
			ctrl_mem_wr => ID_ctrl_mem_wr_in,
			ctrl_mem2reg => ID_ctrl_mem2reg_in
		);
	
	U_ID_REG : entity work.stage2_ID_reg
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => notclk,
			rst => rst,
			pc => IF_pc_out,
			instruction => IF_instruction_out,
			reg_output_A => ID_reg_output_A_in,
			reg_output_B => ID_reg_output_B_in,
			ctrl_beq => ID_ctrl_beq_in,
			ctrl_bne => ID_ctrl_bne_in,
			ctrl_jump => ID_ctrl_jump_in,
			ctrl_jump_addr_src => ID_ctrl_jump_addr_src_in,
			ctrl_reg_dest => ID_ctrl_reg_dest_in,
			ctrl_reg_wr => ID_ctrl_reg_wr_in,
			ctrl_pc2reg31 => ID_ctrl_pc2reg31_in,
			ctrl_extender => ID_ctrl_extender_in,
			ctrl_alu_src => ID_ctrl_alu_src_in,
			ctrl_alu_op => ID_ctrl_alu_op_in,
			ctrl_lui_src => ID_ctrl_lui_src_in,
			ctrl_byte => ID_ctrl_byte_in,
			ctrl_half => ID_ctrl_half_in,
			ctrl_mem_rd => ID_ctrl_mem_rd_in,
			ctrl_mem_wr => ID_ctrl_mem_wr_in,
			ctrl_mem2reg => ID_ctrl_mem2reg_in,
			
			pc_out => ID_pc_out,
			instruction_out => ID_instruction_out,
			reg_output_A_out => ID_reg_output_A_out,
			reg_output_B_out => ID_reg_output_B_out,
			ctrl_beq_out => ID_ctrl_beq_out,
			ctrl_bne_out => ID_ctrl_bne_out,
			ctrl_jump_out => ID_ctrl_jump_out,
			ctrl_jump_addr_src_out => ID_ctrl_jump_addr_src_out,
			ctrl_reg_dest_out => ID_ctrl_reg_dest_out,
			ctrl_reg_wr_out => ID_ctrl_reg_wr_out,
			ctrl_pc2reg31_out => ID_ctrl_pc2reg31_out,
			ctrl_extender_out => ID_ctrl_extender_out,
			ctrl_alu_src_out => ID_ctrl_alu_src_out,
			ctrl_alu_op_out => ID_ctrl_alu_op_out,
			ctrl_lui_src_out => ID_ctrl_lui_src_out,
			ctrl_byte_out => ID_ctrl_byte_out,
			ctrl_half_out => ID_ctrl_half_out,
			ctrl_mem_rd_out => ID_ctrl_mem_rd_out,
			ctrl_mem_wr_out => ID_ctrl_mem_wr_out,
			ctrl_mem2reg_out => ID_ctrl_mem2reg_out
		);
	
	
	-- Stage 3: Execute
	U_STAGE3_EX : entity work.stage3_EX
		generic map (
			WIDTH => WIDTH
		)
		port map (
			pc => ID_pc_out,
			instruction => ID_instruction_out,
			reg_output_A => ID_reg_output_A_out,
			reg_output_B => ID_reg_output_B_out,
			ctrl_extender => ID_ctrl_extender_out,
			ctrl_alu_src => ID_ctrl_alu_src_out,
			ctrl_alu_op => ID_ctrl_alu_op_out,
			ctrl_beq => ID_ctrl_beq_out,
			ctrl_bne => ID_ctrl_bne_out,
			ctrl_jump => ID_ctrl_jump_out,
			ctrl_jump_addr_src => ID_ctrl_jump_addr_src_out,
			
			branch_target => EX_branch_target,
			alu_output => EX_alu_output_in,
			alu_zero => EX_alu_zero
			--alu_carry =>
			--alu_sign =>
			--alu_overflow => 
		);
	
	U_EX_REG : entity work.stage3_EX_reg
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => notclk,
			rst => rst,
			pc => ID_pc_out,
			instruction => ID_instruction_out,
			reg_output_B => ID_reg_output_B_out,
			alu_output => EX_alu_output_in,
			ctrl_lui_src => ID_ctrl_lui_src_out,
			ctrl_reg_dest => ID_ctrl_reg_dest_out,
			ctrl_reg_wr => ID_ctrl_reg_wr_out,
			ctrl_pc2reg31 => ID_ctrl_pc2reg31_out,
			ctrl_byte => ID_ctrl_byte_out,
			ctrl_half => ID_ctrl_half_out,
			ctrl_mem_rd => ID_ctrl_mem_rd_out,
			ctrl_mem_wr => ID_ctrl_mem_wr_out,
			ctrl_mem2reg => ID_ctrl_mem2reg_out,
			
			pc_out => EX_pc_out,
			instruction_out => EX_instruction_out,
			reg_output_B_out => EX_reg_output_B_out,
			alu_output_out => EX_alu_output_out,
			ctrl_lui_src_out => EX_ctrl_lui_src_out,
			ctrl_reg_dest_out => EX_ctrl_reg_dest_out,
			ctrl_reg_wr_out => EX_ctrl_reg_wr_out,
			ctrl_pc2reg31_out => EX_ctrl_pc2reg31_out,
			ctrl_byte_out => EX_ctrl_byte_out,
			ctrl_half_out => EX_ctrl_half_out,
			ctrl_mem_rd_out => EX_ctrl_mem_rd_out,
			ctrl_mem_wr_out => EX_ctrl_mem_wr_out,
			ctrl_mem2reg_out => EX_ctrl_mem2reg_out
		);
	
	
	U_STAGE4_MEM : entity work.stage4_MEM
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => clk,
			rst => rst,
			alu_output => EX_alu_output_out,
			reg_output_B => EX_reg_output_B_out,
			ctrl_mem_rd => EX_ctrl_mem_rd_out,
			ctrl_mem_wr => EX_ctrl_mem_wr_out,
			ctrl_byte => EX_ctrl_byte_out,
			ctrl_half => EX_ctrl_half_out,
			mem_output => MEM_mem_output_in
		);
	
	U_MEM_REG : entity work.stage4_MEM_reg
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => notclk,
			rst => rst,
			pc => EX_pc_out,
			instruction => EX_instruction_out,
			reg_output_B => EX_reg_output_B_out,
			alu_output => EX_alu_output_out,
			mem_output => MEM_mem_output_in,
			ctrl_lui_src => EX_ctrl_lui_src_out,
			ctrl_reg_dest => EX_ctrl_reg_dest_out,
			ctrl_reg_wr => EX_ctrl_reg_wr_out,
			ctrl_pc2reg31 => EX_ctrl_pc2reg31_out,
			ctrl_mem2reg => EX_ctrl_mem2reg_out,
			
			pc_out => MEM_pc_out,
			instruction_out => MEM_instruction_out,
			reg_output_B_out => MEM_reg_output_B_out,
			alu_output_out => MEM_alu_output_out,
			mem_output_out => MEM_mem_output_out,
			ctrl_lui_src_out => MEM_ctrl_lui_src_out,
			ctrl_reg_dest_out => MEM_ctrl_reg_dest_out,
			ctrl_reg_wr_out => MEM_ctrl_reg_wr_out,
			ctrl_pc2reg31_out => MEM_ctrl_pc2reg31_out,
			ctrl_mem2reg_out => MEM_ctrl_mem2reg_out
		);
	
	U_STAGE5_WB : entity work.stage5_WB
		generic map (
			WIDTH => WIDTH
		)
		port map (
			clk => clk,
			rst => rst,
			pc => MEM_pc_out,
			instruction => MEM_instruction_out,
			reg_output_B => MEM_reg_output_B_out,
			alu_output => MEM_alu_output_out,
			mem_output => MEM_mem_output_out,
			ctrl_lui_src => MEM_ctrl_lui_src_out,
			ctrl_reg_dest => MEM_ctrl_reg_dest_out,
			ctrl_pc2reg31 => MEM_ctrl_pc2reg31_out,
			ctrl_mem2reg => MEM_ctrl_mem2reg_out,
			reg_write_addr => WB_reg_write_addr_out,
			reg_write_data => WB_reg_write_data_out
		);
	
end arch;