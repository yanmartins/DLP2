library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relogio IS 
	generic (tipoDisplay : natural :=1);
	port
	(
		clk50MHz :  in  std_logic;
		rst_in : in std_logic;
		ssd_D_csec :  out  std_logic_vector(0 TO 6);
		ssd_U_csec :  out  std_logic_vector(0 TO 6);
		ssd_D_sec :  out  std_logic_vector(0 TO 6);
		ssd_U_sec :  out  std_logic_vector(0 TO 6);
		ssd_D_min :  out  std_logic_vector(0 TO 6);
		ssd_U_min :  out  std_logic_vector(0 TO 6)
		
	);
end entity;


architecture ifsc of relogio is
----------------------------------------------------------------------------------------------
	component timer_multi is
		port(
			clk, reset: in std_logic;
			csec : out std_logic_vector(6 downto 0);
			sec, min: out std_logic_vector(5 downto 0)
		);
	end component;
---------------------------------------------------------------------------------------------
	component bin2bcd is
		generic (
			NUM_DIGITS : natural := 2;
			BIN_SIZE : natural := 7
		);
		port ( 
			binIN  : in  STD_LOGIC_VECTOR (BIN_SIZE-1 downto 0);
			bcdOUT : out  STD_LOGIC_VECTOR (NUM_DIGITS*4-1 downto 0)	
		);
	end component;
---------------------------------------------------------------------------------------------
	component bcd2ssd is
	  generic (ac_ccn : natural := 0); -- Catodo comum
	  port (
		 bin_in : in std_logic_vector(3 downto 0);
		 ssd_out : out std_logic_vector(0 to 6)
	  );
	end component;
---------------------------------------------------------------------------------------------
	-- Declaraçoes de sinais internos
	
	signal bcd_csec, bcd_sec, bcd_min: std_logic_vector(7 downto 0);
	
	signal bin_csec : std_logic_vector(6 downto 0);
	signal bin_sec, bin_min : std_logic_vector(5 downto 0);

begin

	-- Instancias de componentes
		U1: component timer_multi
		port map(
			clk => clk50MHz,
			reset => rst_in,
			csec => bin_csec,
			sec => bin_sec,
			min => bin_min
		);
		
---------------------------------------------------------------------------------------------
--------------------------------- CENTESIMOS DE SEGUNDO

		C1: component bin2bcd
		generic map(
			NUM_DIGITS => 2, 
			BIN_SIZE => 7
		)
		port map(
			binIN  => bin_csec, 
			bcdOUT => bcd_csec
		);

		C2: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd_csec(3 downto 0),
		 ssd_out => ssd_U_csec
		);
		
		C3: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd_csec(7 downto 4),
		 ssd_out => ssd_D_csec
		);
--	
-----------------------------------------------------------------------------------------------
-----------------------------------SEGUNDOS
		S1: component bin2bcd
		generic map(
			NUM_DIGITS => 2, 
			BIN_SIZE => 6
		)
		port map(
			binIN  => bin_sec, 
			bcdOUT => bcd_sec
		);

		S2: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd_sec(3 downto 0),
		 ssd_out => ssd_U_sec
		);
		
		S3: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd_sec(7 downto 4),
		 ssd_out => ssd_D_sec
		);
----------------------------------------------------------------------------------------------
-----------------------------------MINUTOS
		M1: component bin2bcd
		generic map(
			NUM_DIGITS => 2, 
			BIN_SIZE => 6
		)
		port map(
			binIN  => bin_min, 
			bcdOUT => bcd_min
		);

		M2: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd_min(3 downto 0),
		 ssd_out => ssd_U_min
		);
		
		M3: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd_min(7 downto 4),
		 ssd_out => ssd_D_min
		);
		

end architecture;