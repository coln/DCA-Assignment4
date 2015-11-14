library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Stage 3: Execute
entity stage3_EX is
	generic (
		WIDTH : positive := DATA_WIDTH
	);
	port (
		pc : in std_logic_vector(WIDTH-1 downto 0);
		instruction : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_A : in std_logic_vector(WIDTH-1 downto 0);
		reg_output_B : in std_logic_vector(WIDTH-1 downto 0);
		ctrl_extender : in std_logic;
		ctrl_alu_src : in std_logic;
		ctrl_alu_op : in std_logic_vector(ALU_OP_WIDTH-1 downto 0);
		ctrl_beq : in std_logic;
		ctrl_bne : in std_logic;
		ctrl_jump : in std_logic;
		ctrl_jump_addr_src : in std_logic;
		
		branch_target : out std_logic_vector(WIDTH-1 downto 0);
		alu_output : out std_logic_vector(WIDTH-1 downto 0);
		alu_carry : out std_logic;
		alu_zero : out std_logic;
		alu_sign : out std_logic;
		alu_overflow : out std_logic
	);
end entity;

architecture arch of stage3_EX is
	-- Extender
	signal extender : std_logic_vector(WIDTH-1 downto 0);
	
	-- ALU
	signal alu_input_B : std_logic_vector(WIDTH-1 downto 0);
	signal alu_control : std_logic_vector(ALU_CONTROL_WIDTH-1 downto 0);
	signal alu_shiftdir : std_logic;
	signal zero : std_logic;
	
	-- Branch Target
	signal pc_immediate_output : std_logic_vector(WIDTH-1 downto 0);
	signal branch_mux_sel : std_logic;
	signal pc_branch_output : std_logic_vector(WIDTH-1 downto 0);
	signal jump_address : std_logic_vector(JTYPE_ADDRESS_WIDTH-1 downto 0);
	signal new_jump_address : std_logic_vector(WIDTH-1 downto 0);
begin
	
	-- Sign Extender for Immedate Value
	U_EXTENDER : entity work.extender
		generic map (
			WIDTH_IN => ITYPE_IMMEDIATE_WIDTH,
			WIDTH_OUT => WIDTH
		)
		port map (
			in0 => instruction(ITYPE_IMMEDIATE_RANGE),
			out0 => extender,
			is_signed => ctrl_extender
		);
	
	-- ALU Input B Mux
	U_ALU_INPUT_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => ctrl_alu_src,
			in0 => reg_output_B,
			in1 => extender,
			output => alu_input_B
		);
	
	-- ALU
	U_ALU_CONTROL : entity work.alu_control
		port map (
			func => instruction(RTYPE_FUNC_RANGE),
			ALUop => ctrl_alu_op,
			control => alu_control,
			shiftDir => alu_shiftdir
		);
	U_ALU : entity work.alu
		generic map (
			WIDTH => WIDTH
		)
		port map (
			inA => reg_output_A,
			inB => alu_input_B,
			control => alu_control,
			shiftAmt => instruction(RTYPE_SHAMT_RANGE),
			shiftDir => alu_shiftdir,
			output => alu_output,
			carry => alu_carry,
			zero => zero,
			sign => alu_sign,
			overflow => alu_overflow
		);
	alu_zero <= zero;
	
	
	-- Calculate next PC address (aka branch target)
	-- Adds immedate address
	-- Note: This used to add pc_inc1_output, but since the architecture has
	-- changed (notably branching and jumping), pc_inc1_output is filtered directly
	-- to NEXT_PC_MUX
	pc_immediate_output <= add_unsigned(pc, extender);
	
	-- Selects between "pc + 4" or "pc + immediate (extender)" depending on branch
	branch_mux_sel <= (ctrl_beq and zero) or (ctrl_bne and not zero);
	U_BRANCH_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => branch_mux_sel,
			in0 => pc,
			in1 => pc_immediate_output,
			output => pc_branch_output
		);
	
	
	-- Jump Address mux (selects between address in instruction and in regster)
	-- Used with J, JAL, and JR
	-- Note: Uses old address (from Instruction Regster (IR))
	U_JUMP_ADDRESS_MUX : entity work.mux2
		generic map (
			WIDTH => JTYPE_ADDRESS_WIDTH
		)
		port map (
			sel => ctrl_jump_addr_src,
			in0 => instruction(JTYPE_ADDRESS_RANGE),
			in1 => reg_output_A(JTYPE_ADDRESS_WIDTH-1 downto 0),
			output => jump_address
		);
	
	-- Selects between pc_branch_output and jump_output
	-- New jump address is PC[31:26] & JMP[25:0]
	new_jump_address <= pc(WIDTH-1 downto JTYPE_ADDRESS_WIDTH) & jump_address;
	U_JUMP_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => ctrl_jump,
			in0 => pc_branch_output,
			in1 => new_jump_address,
			output => branch_target
		);
	
end arch;