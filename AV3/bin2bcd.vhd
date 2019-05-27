-- Adapted from:
-- https://en.wikipedia.org/wiki/Double_dabble

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity bin2bcd is
	Generic (
		NUM_DIGITS : natural := 2;
		BIN_SIZE : natural := 7
	);
	Port ( 
		binIN  : in  STD_LOGIC_VECTOR (BIN_SIZE-1 downto 0);
		--ones : out  STD_LOGIC_VECTOR (3 downto 0);
      --tens : out  STD_LOGIC_VECTOR (3 downto 0);
		bcdOUT : out  STD_LOGIC_VECTOR (NUM_DIGITS*4-1 downto 0)	
	);
end bin2bcd;

architecture double_dabble of bin2bcd is

begin
	
bcd1: process(binIN)
	
	constant BCD_SIZE: natural := NUM_DIGITS*4;

	-- temporary variable
	variable temp : STD_LOGIC_VECTOR (BIN_SIZE-1 downto 0);

	-- variable to store the output BCD number
	-- organized as follows
	-- units = bcd(3 downto 0)
	-- tens = bcd(7 downto 4)
	-- etc ..
	variable bcd : UNSIGNED (BCD_SIZE-1 downto 0) := (others => '0');
  
	begin
		-- zero the bcd variable
		bcd := (others => '0');

		-- read input into temp variable
		temp:= binIN;

		for i in 0 to BIN_SIZE-1 loop

			MUX_ADDER:for j in 0 to NUM_DIGITS-1 loop
				if bcd(j*4+3 downto j*4) > 4 then 
					bcd(j*4+3 downto j*4) := bcd(j*4+3 downto j*4) + 3;
				end if;
			end loop MUX_ADDER;

			-- shift bcd left by 1 bit, copy MSB of temp into LSB of bcd
			bcd := bcd(BCD_SIZE-2 downto 0) & temp(BIN_SIZE-1);

			-- shift temp left by 1 bit
			temp := temp(BIN_SIZE-2 downto 0) & '0';

		end loop;
		bcdOUT <= STD_LOGIC_VECTOR(bcd);
		
		--ones <= STD_LOGIC_VECTOR(bcd(3 downto 0));
		--tens <= STD_LOGIC_VECTOR(bcd(7 downto 4));

	end process bcd1;            
  
end double_dabble;



--architecture division of bin2bcd is
--signal cent                                                 : integer range 0 to 99;
--signal dez                                                  : integer range 0 to 99;
--signal uni                                                  : integer range 0 to 9;
--
--begin
--
--	cent <= to_integer(unsigned((binIN)));
--	dez <= cent/10;
--	uni <= (cent - (dez*10));
--	
--	ones <= std_logic_vector(to_unsigned(uni,4));
--	tens <= std_logic_vector(to_unsigned(dez,4));
--	
--end architecture;
