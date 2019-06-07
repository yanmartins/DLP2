--=============================
-- Listing 9.5 timer
--=============================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity counter is
   port(
      clk, reset: in std_logic;
		contador : out std_logic_vector(1 downto 0)
   );
end counter;

architecture single_clock_arch of counter is
   signal r_reg: unsigned(19 downto 0);
   signal r_next: unsigned(19 downto 0);
	
	signal c_reg: unsigned(1 downto 0);
	signal c_next: unsigned(1 downto 0);
	
   signal c_en: std_logic;
begin
   -- register
   process(clk,reset)
   begin
      if (reset='1') then
         r_reg <= (others=>'0');
			c_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         r_reg <= r_next;
			c_reg <= c_next;
      end if;
   end process;
   -- next-state logic/output logic for mod-1000000 counter
   r_next <= (others=>'0') when r_reg=49 else
             r_reg + 1;	 
	c_en <= '1' when r_reg = 20 else
           '0';
			  
   -- next-state logic for minute divider
   c_next <= (others=>'0') when (c_reg=2 and c_en='1') else
             c_reg + 1     when c_en='1' else
             c_reg;
	
   -- output logic
	contador <= std_logic_vector(c_reg);
	
end single_clock_arch;
