library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib.all;

-- Stage 5: Write Back
entity stage5_WB is
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
		ctrl_pc2reg31 : in std_logic;
		ctrl_reg_dest : in std_logic;
		ctrl_mem2reg : in std_logic;
		reg_write_addr : out std_logic_vector(get_log2(WIDTH)-1 downto 0);
		reg_write_data : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture arch of stage5_WB is
	-- Register Address Mux
	signal dest_mux_output : std_logic_vector(get_log2(WIDTH)-1 downto 0);
	
	-- Load Upper Immediate Mux (LUI)
	signal lui_mux : std_logic_vector(WIDTH-1 downto 0);
	signal lui_output : std_logic_vector(WIDTH-1 downto 0);
	
	-- PC to REG31 mux
	signal pc2reg31_output : std_logic_vector(WIDTH-1 downto 0);
begin
	
	-- Register Address
	-- Destination Register select for register file write address (between RT and RD)
	U_DEST_MUX : entity work.mux2
		generic map (
			WIDTH => get_log2(WIDTH)
		)
		port map (
			sel => ctrl_reg_dest,
			in0 => instruction(RT_RANGE),
			in1 => instruction(RTYPE_RD_RANGE),
			output => dest_mux_output
		);
	
	-- Jump and Link (selects between DEST_MUX and register 31)
	U_JAL_MUX : entity work.mux2
		generic map (
			WIDTH => get_log2(WIDTH)
		)
		port map (
			sel => ctrl_pc2reg31,
			in0 => dest_mux_output,
			in1 => int2slv(31, get_log2(WIDTH)),
			output => reg_write_addr
		);
		
	
	-- Register Data
	-- Load Upper Immediate (LUI): Imm[31:16] & Rt[15:0] or ALU ouptut
	lui_mux <= instruction(ITYPE_IMMEDIATE_RANGE) & reg_output_B(WIDTH-ITYPE_IMMEDIATE_WIDTH-1 downto 0);
	U_LUI_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => ctrl_lui_src,
			in0 => alu_output,
			in1 => lui_mux,
			output => lui_output
		);
	
	-- Jump and Link (JAL): PC + 4 or ALU to mem2reg MUX
	U_PC2REG31_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => ctrl_pc2reg31,
			in0 => lui_output,
			in1 => pc,
			output => pc2reg31_output
		);
	
	--  Memory-to-Reg Mux (between ALU and Data Memory)
	U_MEM2REG_MUX : entity work.mux2
		generic map (
			WIDTH => WIDTH
		)
		port map (
			sel => ctrl_mem2reg,
			in0 => pc2reg31_output,
			in1 => mem_output,
			output => reg_write_data
		);

end arch;