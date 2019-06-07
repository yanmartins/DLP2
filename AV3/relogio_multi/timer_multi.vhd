--=============================
-- Listing 9.5 timer
--=============================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity timer_multi is
   port(
      clk, reset: in std_logic;
		csec : out std_logic_vector(6 downto 0);
      sec, min: out std_logic_vector(5 downto 0)
   );
end entity;

architecture multi_clock_arch of timer_multi is
   signal r_reg: unsigned(19 downto 0);
   signal r_next: unsigned(19 downto 0);
	
	signal c_reg, c_next: unsigned(6 downto 0);
	
   signal s_reg, m_reg: unsigned(5 downto 0);
   signal s_next, m_next: unsigned(5 downto 0);
	
   signal cclk, sclk, mclk: std_logic;
begin
   -- register
   process(clk,reset)
   begin
      if (reset='1') then
         r_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         r_reg <= r_next;
      end if;
   end process;
	
   -- next-state logic
   r_next <= (others=>'0') when r_reg=499999 else
             r_reg + 1;
   -- output logic
   cclk <= '1' when r_reg < 250000 else
           '0';
			  
			  
   -- csecond divider
   process(cclk,reset)
   begin
      if (reset='1') then
         c_reg <= (others=>'0');
      elsif (cclk'event and cclk='1') then
         c_reg <= c_next;
      end if;
   end process;
   -- next-state logic
   c_next <= (others=>'0') when c_reg=99 else
             c_reg + 1;
   -- output logic
   sclk <= '1' when c_reg < 50 else
           '0';
   csec <= std_logic_vector(c_reg);
	
	
	
	-- second divider
   process(sclk,reset)
   begin
      if (reset='1') then
         s_reg <= (others=>'0');
      elsif (sclk'event and sclk='1') then
         s_reg <= s_next;
      end if;
   end process;
   -- next-state logic
   s_next <= (others=>'0') when s_reg=59 else
             s_reg + 1;
   -- output logic
   mclk <= '1' when s_reg < 30 else
           '0';
   sec <= std_logic_vector(s_reg);
	
	
	
   -- minute divider
   process(mclk,reset)
   begin
      if (reset='1') then
         m_reg <= (others=>'0');
      elsif (mclk'event and mclk='1') then
         m_reg <= m_next;
      end if;
   end process;
   -- next-state logic
   m_next <= (others=>'0') when m_reg=59 else
             m_reg + 1;
   -- output logic
   min <= std_logic_vector(m_reg);
end architecture;