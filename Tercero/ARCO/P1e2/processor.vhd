--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2017-18
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion de instruccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion de dato
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 
	
	component reg_bank
		port(
			Clk   : in std_logic; -- Reloj activo en flanco de subida
			Reset : in std_logic; -- Reset as�ncrono a nivel alto
			A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
			Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
			A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
			Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
			A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
			Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
			We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
		);
	end component;
	
	component alu
		port(
			OpA     : in  std_logic_vector (31 downto 0); -- Operando A
			OpB     : in  std_logic_vector (31 downto 0); -- Operando B
			Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
			Result  : out std_logic_vector (31 downto 0); -- Resultado
			ZFlag   : out std_logic                       -- Flag Z
		);
	end component;
	
	component control_unit
		port(
			-- Entrada = codigo de operacion en la instruccion:
			OpCode  : in  std_logic_vector (5 downto 0);
			-- Seniales para el PC
			Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
			-- Seniales relativas a la memoria
			MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
			MemWrite : out  std_logic; -- Escribir la memoria
			MemRead  : out  std_logic; -- Leer la memoria
			-- Seniales para la ALU
			ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
			ALUOp  : out  std_logic_vector (1 downto 0); -- Tipo operacion para control de la ALU
			-- Seniales para el GPR
			RegWrite : out  std_logic; -- 1=Escribir registro
			RegDst   : out  std_logic;  -- 0=Reg. destino es rt, 1=rd
			LUICtrl	: out std_logic;	-- 1=LUI, 0 resto
			Jump		: out std_logic	-- 1=Jump, 0 resto
		);
	end component;
	
	component alu_control
		port(
				 -- Entradas:
			ALUOp  : in std_logic_vector (1 downto 0); -- Codigo control desde la unidad de control
			Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
			-- Salida de control para la ALU:
			ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
		);
	end component;
	
	-- Seniales del procesador
	signal pc_exit : std_logic_vector(31 downto 0);
	signal pc_in	: std_logic_vector(31 downto 0);
	signal PC4		: std_logic_vector(31 downto 0);
	signal SL 		: std_logic_vector(31 downto 0);
	signal PCadd 	: std_logic_vector(31 downto 0);
	signal ANDBranch	: std_logic;
	signal DataToReg	: std_logic_vector(31 downto 0);
	signal pc_aux	: std_logic_vector(31 downto 0);
	
	-- Seniales de interconexion
	-- alu
	signal OpA     : std_logic_vector (31 downto 0); -- Operando A
	signal OpB     : std_logic_vector (31 downto 0); -- Operando B
	signal Control : std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
	signal Result  : std_logic_vector (31 downto 0); -- Resultado
	signal ZFlag   : std_logic;
	
	-- control_unit
	signal Branch	: std_logic;
	signal MemToReg: std_logic;
	signal MemWrite: std_logic;
	signal MemRead : std_logic;
	signal ALUSrc  : std_logic;
	signal ALUOp   : std_logic_vector (1 downto 0);
	signal RegWrite: std_logic;
	signal RegDst  : std_logic;
	signal LUICtrl	: std_logic;
	signal Jump		: std_logic;
	
	-- registros
	signal Rd2 : std_logic_vector(31 downto 0);
	signal A3  : std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
	signal Wd3 : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
	
	-- extension de signo
	signal SignEx : std_logic_vector (31 downto 0);

	-- extension del LUI
	signal LUIextended		: std_logic_vector (31 downto 0);

	-- Registro 1 segmentacion
	signal reg1_PC4_out : std_logic_vector(31 downto 0);
	signal reg1_IDataIn_out: std_logic_vector(31 downto 0);

	-- Registro 2 segmentacion
	signal reg2_IDataIn_out : std_logic_vector(31 downto 0);
 signal reg2_PC4_out : std_logic_vector(31 downto 0);
	signal reg2_RegDst_out : std_logic;
 signal reg2_Branch_out : std_logic;
 signal reg2_MemRead_out : std_logic;
	signal reg2_MemToReg_out : std_logic;
	signal reg2_ALUOp_out : std_logic_vector(1 downto 0);
	signal reg2_MemWrite_out : std_logic;
	signal reg2_ALUSrc_out : std_logic;
	signal reg2_RegWrite_out : std_logic;
	signal reg2_Jump_out : std_logic;
	signal reg2_Rd1_out : std_logic_vector(31 downto 0);
	signal reg2_Rd2_out : std_logic_vector(31 downto 0);
	signal reg2_SignEx_out : std_logic_vector(31 downto 0);
	signal reg2_LUICtrl_out : std_logic;

	-- Registro 3 segmentacion
		signal reg3_Branch_out : std_logic;
  signal reg3_MemRead_out : std_logic;
		signal reg3_MemToReg_out : std_logic;
		signal reg3_MemWrite_out : std_logic;
		signal reg3_RegWrite_out : std_logic;
		signal reg3_Jump_out : std_logic;
		signal reg3_Rd2_out : std_logic_vector(31 downto 0);
		signal reg3_LUIextended_out : std_logic_vector(31 downto 0);
		signal reg3_Result_out : std_logic_vector(31 downto 0);
	 signal reg3_ZFlag_out : std_logic;
		signal reg3_PCadd_out : std_logic_vector(31 downto 0);
		signal reg3_A3_out : std_logic_vector(31 downto 0);
		signal reg3_LUIctrl_out : std_logic;
		signal reg3_IDataIn_out : std_logic_vector(31 downto 0);
		signal reg3_PC4_out : std_logic_vector(31 downto 0);

	-- Registro 4 segmentacion
	signal reg4_MemToReg_out : std_logic;
 signal reg4_RegWrite_out : std_logic;
 signal reg4_LUIextended_out : std_logic_vector(31 downto 0);
 signal reg4_LUICtrl_out : std_logic;
 signal reg4_DDataIn_out : std_logic_vector(31 downto 0);
 signal reg4_Result_out : std_logic_vector(31 downto 0);
 signal reg4_A3_out : std_logic_vector(31 downto 0);
	
	
begin  
	
	-- instanciacion de alu
	
	i_alu : alu
		port map (
			OpA => reg2_OpA_out,
			OpB => OpB,
			Control => Control,
			Result => Result,
			ZFlag => ZFlag
		);
		
	-- instanciacion de alu_control
	i_alu_control: alu_control
		port map(
			ALUOp => reg2_ALUOp_out,
			Funct => reg2_IDataIn_out (5 downto 0),
			ALUControl => Control
		);
		
	-- instanciacion de control_unit
	
	i_control_unit : control_unit
		port map (
			OpCode => reg1_IDataIn_out(31 downto 26),
			Branch => Branch,
			MemToReg => MemToReg,
			MemWrite => MemWrite,
			MemRead => MemRead,
			ALUSrc => ALUSrc,
			ALUOp => ALUOp,
			RegWrite => RegWrite,
			RegDst => RegDst,
			LUICtrl => LUICtrl,
			Jump => Jump
		);
		
	-- instanciacion de reg_bank
		
	i_reg_bank : reg_bank
		port map (
			Clk => Clk,
			Reset => Reset,
			A1 => reg1_IDataIn_out(25 downto 21),
			Rd1 => OpA,
			A2 => reg1_IDataIn_out (20 downto 16),
			Rd2 => Rd2,
			A3 => reg4_A3_out,
			Wd3 => Wd3,
			We3 => reg4_RegWrite_out
		);

	------------------------------------------------------
   -- Program Counter
   ------------------------------------------------------
	
	PC4 <= pc_exit + 4;
	PC4 <= PC4;
	
	process(Clk, pc_in, Reset)
	begin
		if Reset = '1' then
			pc_exit <= (others => '0');
		elsif rising_edge(Clk) then
			pc_exit <= pc_in;			
		end if;
	end process;
	
	------------------------------------------------------
   -- MUX Write Register
   ------------------------------------------------------
	
	process(reg2_IDataIn_out, reg2_RegDst_out)
	begin
		if reg2_RegDst_out = '1' then
			A3 <= reg2_IDataIn_out(15 downto 11);
		else
			A3 <= reg2_IDataIn_out (20 downto 16);
		end if;
	end process;
	
	------------------------------------------------------
   -- MUX Read Data 2
   ------------------------------------------------------
	
	process (reg2_ALUSrc_out, reg2_Rd2_out, reg2_SignEx_out)
	begin
		if reg2_ALUSrc_out = '1' then
			OpB <= reg2_SignEx_out;
		else
			OpB <= reg2_Rd2_out;
		end if;
	end process;

	------------------------------------------------------
   -- Shift Left para los Jumps
   ------------------------------------------------------

   SL <= reg2_SignEx_out (29 downto 0) & "00"; --Multiplicamos por 2

   ------------------------------------------------------
   -- Program Counter ADD
   ------------------------------------------------------

   PCadd <= reg2_PC4_out + SL;

	------------------------------------------------------
   -- MUX Program Counter
   ------------------------------------------------------
   ANDBranch <= reg3_Branch_out AND reg3_ZFlag_out;
   process (PC4, reg3_PCadd_out, ANDBranch)
   begin
   	if ANDBranch = '0' then
   		pc_aux <= PC4;
   	else
   		pc_aux <= reg3_PCadd_out;
   	end if;
   end process;
	
	------------------------------------------------------
   -- MUX LUI
   ------------------------------------------------------

   LUIextended <= reg2_IDataIn_out (15 downto 0) & x"0000";
	
	process (reg4_LUICtrl_out, reg4_LUIextended_out, DataToReg)
	begin
		if reg4_LUICtrl_out = '1' then
			Wd3 <= reg4_LUIextended_out;
		else
			Wd3 <= DataToReg;
		end if;
	end process;
	
	------------------------------------------------------
   -- MUX Jump
   ------------------------------------------------------
	
	process (reg3_Jump_out, pc_aux, reg3_PC4_out, reg3_IDataIn_out)
	begin
		if reg3_Jump_out = '1' then
			pc_in <= reg3_PC4_out(31 downto 28) & reg3_IDataIn_out(25 downto 0) & "00";
		else
			pc_in <= pc_aux;
		end if;
	end process;
	

   ------------------------------------------------------
   -- MUX WriteData
   ------------------------------------------------------
	
   process(reg4_MemToReg_out, reg4_Result_out, reg4_DDataIn_out)
   begin
   	if reg4_MemToReg_out = '1' then
   		DataToReg <= reg4_DDataIn_out;
   	else
   		DataToReg <= reg4_Result_out;
   	end if;
   end process;

	------------------------------------------------------
   -- Extensor de Signo
   ------------------------------------------------------
	
	SignEx (31 downto 16) <= (others => reg1_IDataIn_out(15));	
	SignEx (15 downto 0) <= reg1_IDataIn_out (15 downto 0);

	------------------------------------------------------
   -- Conexiones procesador
   ------------------------------------------------------

   IAddr <= pc_exit;
   DAddr <= reg3_Result_out;
   DRdEn <= reg3_MemRead_out;
   DWrEn <= reg3_MemWrite_out;
   DDataOut <= reg3_Rd2_out;

   ------------------------------------------------------
   -- Registro 1 segmentacion
   ------------------------------------------------------
   	process(PC4, Clk, Reset, IDataIn)
   	begin
   			if Reset = '1' then
   					reg1_IDataIn_out <= (others => '0');
   					reg1_PC4_out <= (others => '0');
   			elsif rising_edge(Clk) then
   					reg1_PC4_out <= PC4;
   					reg1_IDataIn_out <= IDataIn;
   			end if;
   	end process;

   ------------------------------------------------------
   -- Registro 2 segmentacion
   ------------------------------------------------------
   	process(Clk, Reset, RegDst, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite, LUICtrl, 
   	Jump, reg1_PC4_out, Rd1, Rd2, SignEx, reg1_IDataIn_out, LUICtrl)
   	begin
   			if Reset = '1' then
   					reg2_IDataIn_out <= (others => '0');
   					reg2_PC4_out <= (others => '0');
   					reg2_RegDst_out <= '0';
   					reg2_Branch_out <= '0';
   					reg2_MemRead_out <= '0';
								reg2_MemToReg_out <= '0' ;
								reg2_ALUOp_out <= (others => '0');
								reg2_MemWrite_out <= '0';
								reg2_ALUSrc_out <= '0';
								reg2_RegWrite_out <= '0';
								reg2_Jump_out <= '0';
								reg2_Rd1_out <= (others => '0');
								reg2_Rd2_out <= (others => '0');
								reg2_SignEx_out <= (others => '0');
								reg2_LUICtrl_out <= '0';

   			elsif rising_edge(Clk) then
   					reg2_IDataIn_out <= reg1_IDataIn_out;
   					reg2_PC4_out <= reg1_PC4_out;
   					reg2_RegDst_out <= RegDst;
   					reg2_Branch_out <= Branch;
   					reg2_MemRead_out <= MemRead;
								reg2_MemToReg_out <= MemToReg;
								reg2_ALUOp_out <= ALUOp;
								reg2_MemWrite_out <= MemWrite;
								reg2_ALUSrc_out <= ALUSrc;
								reg2_RegWrite_out <= RegWrite;
								reg2_Jump_out <= Jump;
								reg2_Rd1_out <= Rd1;
								reg2_Rd2_out <= Rd2;
								reg2_SignEx_out <= SignEx;
								reg2_LUICtrl_out <= LUICtrl;
   			end if;
   	end process;

   ------------------------------------------------------
   -- Registro 3 segmentacion
   ------------------------------------------------------
   process(Clk, Reset, reg2_Branch_out, reg2_MemRead_out, reg2_MemWrite_out, reg2_MemToReg_out
   	reg2_RegWrite_out, reg2_Jump_out, LUIextended, Result, ZFlag, PCadd, reg2_Rd2_out, A3, reg2_LUICtrl_out, reg2_IDataIn_out)
   	begin
   			if Reset = '1' then
   					reg3_Branch_out <= '0';
   					reg3_MemRead_out <= '0';
								reg3_MemToReg_out <= '0' ;
								reg3_MemWrite_out <= '0';
								reg3_RegWrite_out <= '0';
								reg3_Jump_out <= '0';
								reg3_Rd2_out <= (others => '0');
								reg3_LUIextended_out <= (others => '0');
								reg3_Result_out <= (others => '0');
								reg3_ZFlag_out <= '0';
								reg3_PCadd_out <= (others => '0');
								reg3_A3_out <= (others => '0');
								reg3_LUIctrl_out <= '0';
								reg3_IDataIn_out <= (others => '0');
								reg3_PC4_out <= (others => '0');
						elsif rising_edge(Clk) then
   					reg3_Branch_out <= reg2_Branch_out;
   					reg3_MemRead_out <= reg2_MemRead_out;
								reg3_MemToReg_out <= reg2_MemToReg_out;
								reg3_MemWrite_out <= reg2_MemWrite_out;
								reg3_RegWrite_out <= reg2_RegWrite_out;
								reg3_Jump_out <= reg2_Jump_out;
								reg3_Rd2_out <= reg2_Rd2_out;
								reg3_LUIextended_out <= LUIextended;
								reg3_Result_out <= Resultt;
								reg3_ZFlag_out <= ZFlag;
								reg3_PCadd_out <= PCadd;
								reg3_A3_out <= A3;
								reg3_LUICtrl_out <= reg2_LUICtrl_out;
								reg3_IDataIn_out <= reg2_IDataIn_out;
								reg3_PC4_out <= reg2_PC4_out;
   			end if;
   	end process;

   ------------------------------------------------------
   -- Registro 4 segmentacion
   ------------------------------------------------------
   	process(Clk, Reset, reg3_MemToReg_out, reg3_RegWrite_out, reg3_LUIextended_out, reg3_LUIctrl, DDataIn, reg3_Result_out
   		reg3_A3_out)
   	begin
   			if Reset = '1' then
   					reg4_MemToReg_out <= '0';
   					reg4_RegWrite_out <= '0';
   					reg4_LUIextended_out <= (others => '0');
   					reg4_LUICtrl_out <= '0';
   					reg4_DDataIn_out <= (others => '0');
   					reg4_Result_out <= (others => '0');
   					reg4_A3_out <= (others => '0');
   			elsif rising_edge(Clk) then
   					reg4_MemToReg_out <= reg3_MemToReg_out;
   					reg4_RegWrite_out <= reg3_RegWrite_out;
   					reg4_LUIextended_out <= reg3_LUIextended_out;
   					reg4_LUICtrl_out <= reg3_LUIctrl;
   					reg4_DDataIn_out <= DDataIn;
   					reg4_Result_out <= reg3_Result_out;
   					reg4_A3_out <= reg3_A3_out;
   			end if;
   	end process;
	
end architecture;
