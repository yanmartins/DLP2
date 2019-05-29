library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relogio24Hrs IS 
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
		--ctrl : in std_logic_vector(1 downto 0)
		
	);
end entity;


architecture ifsc_v1 of relogio24Hrs is
----------------------------------------------------------------------------------------------
	component timer is
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
		U1: component timer
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












architecture ifsc_v2 of relogio24Hrs is
----------------------------------------------------------------------------------------------
	component timer is
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
		U1: component timer
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
		
--		process (ctrl)
--        variable count : integer range 0 to 2;
--		begin
--			count := to_integer(unsigned(ctrl));
--			case count  is
--			  when 0 => bin_tmp <= bin_csec;
--			  when 1 => bin_tmp <= bin_sec;
--			  when others=> bin_tmp <= bin_min;
--			end case;
--	   end process;

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
		
		process (ctrl, clk50MHz)
        variable count : integer range 0  to 2;
		begin
		  count := to_integer(unsigned(ctrl));
		  case count  is
			  when 0 => ssd_U_csec <= ssd_U;
			  when 1 => ssd_U_sec <= ssd_U;
			  when others=> ssd_U_min <= ssd_U;
		  end case;
		end process;
		
		process (ctrl, clk50MHz)
        variable count : integer range 0 to 2;
		begin
		  count := to_integer(unsigned(ctrl));
		  case count  is
			  when 0 => ssd_D_csec <= ssd_D;
			  when 1 => ssd_D_sec <= ssd_D;
			  when others => ssd_D_min <= ssd_D;
		  end case;
		end process;
	 

end architecture;

configuration configMain of relogio24Hrs is
	--for ifsc_v1
	for ifsc_v2
	end for;	
end configuration;