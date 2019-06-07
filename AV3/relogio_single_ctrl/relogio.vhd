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
	component timer_single is
		port(
			clk, reset: in std_logic;
			csec : out std_logic_vector(6 downto 0);
			sec, min: out std_logic_vector(5 downto 0)
		);
	end component;
---------------------------------------------------------------------------------------------
	component counter is
		port(
			clk, reset: in std_logic;
			contador : out std_logic_vector(1 downto 0)
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
	
	signal bcd: std_logic_vector(7 downto 0);
	
	signal bin_csec : std_logic_vector(6 downto 0);
	signal bin_sec, bin_min : std_logic_vector(5 downto 0);
	
	signal bin_tmp : std_logic_vector(6 downto 0);
	signal ssd_U, ssd_D : std_logic_vector(0 TO 6);
	signal ctrl : std_logic_vector(1 downto 0);
	
begin

	-- Instancias de componentes
		U1: component timer_single
		port map(
			clk => clk50MHz,
			reset => rst_in,
			csec => bin_csec,
			sec => bin_sec,
			min => bin_min
		);
		
		U2: component counter
		port map(
			clk => clk50MHz,
			reset => rst_in,
			contador => ctrl
		);

		with ctrl select
		bin_tmp <= 	bin_csec when "00",
						'0' & bin_sec  when "01",
						'0' & bin_min when others;
		
		B1: component bin2bcd
		generic map(
			NUM_DIGITS => 2, 
			BIN_SIZE => 7
		)
		port map(
			binIN  => bin_tmp, 
			bcdOUT => bcd
		);

		SU2: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd(3 downto 0),
		 ssd_out => ssd_U
		);
		
		SD3: component bcd2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
		 bin_in => bcd(7 downto 4),
		 ssd_out => ssd_D
		);
		
		ssd_U_csec <= ssd_U when ctrl = "00" else "1111111";
		ssd_U_sec  <= ssd_U when ctrl = "01" else "1111111";
		ssd_U_min  <= ssd_U when ctrl = "10" else "1111111";
		
		ssd_D_csec <= ssd_D when ctrl = "00" else "1111111";
		ssd_D_sec  <= ssd_D When ctrl = "01" else "1111111";
		ssd_D_min  <= ssd_D when ctrl = "10" else "1111111";
	 

end architecture;
