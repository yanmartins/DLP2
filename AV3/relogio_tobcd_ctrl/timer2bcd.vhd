
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer2bcd is
   port(
      clk, reset: in std_logic;
		csec, sec, min : out std_logic_vector(7 downto 0)
   );
end entity;

architecture ifsc of timer2bcd is
   signal r_reg: unsigned(19 downto 0);
   signal r_next: unsigned(19 downto 0);
	
	signal c_reg: unsigned(6 downto 0);
   signal s_reg, m_reg: unsigned(5 downto 0);
	
	signal c_reg_U, c_reg_D, s_reg_U, m_reg_U: unsigned(3 downto 0);
   signal s_reg_D, m_reg_D: unsigned(2 downto 0);
	
	signal c_next_U, c_next_D, s_next_U, m_next_U: unsigned(3 downto 0);
   signal s_next_D, m_next_D: unsigned(2 downto 0);
	
   signal c_en_D,s_en_D,m_en_D,c_en_U,s_en_U,m_en_U: std_logic;
begin
   -- register
   process(clk,reset)
   begin
      if (reset='1') then
         r_reg <= (others=>'0');
			c_reg_D <= (others=>'0');
         s_reg_D <= (others=>'0');
         m_reg_D <= (others=>'0');
			c_reg_U <= (others=>'0');
         s_reg_U <= (others=>'0');
         m_reg_U <= (others=>'0');
      elsif (clk'event and clk='1') then
         r_reg <= r_next;
			c_reg_D <= c_next_D;
         s_reg_D <= s_next_D;
         m_reg_D <= m_next_D;
			c_reg_U <= c_next_U;
         s_reg_U <= s_next_U;
         m_reg_U <= m_next_U;
      end if;
   end process;
   -- next-state logic/output logic for mod-1000000 counter
   r_next <= (others=>'0') when r_reg=499999 else
             r_reg + 1;	 
	c_en_U <= '1' when r_reg = 250000 else
           '0';
			  
	c_en_D <= '1' when (c_reg_U=9 and c_en_U='1') else
           '0';
			  
			  

	c_next_U <= (others=>'0') when (c_reg_U=9 and c_en_U='1') else
			 c_reg_U + 1     when c_en_U='1' else
			 c_reg_U;
			 
	c_next_D <= (others=>'0') when (c_reg_D=9 and c_en_D='1') else
				 c_reg_D + 1  when c_en_D='1' else
				 c_reg_D;
				 
				 
	s_en_U <= '1' when (c_reg_D=9 and c_en_D='1') else
			  '0';
			  
	s_en_D <= '1' when (s_reg_U=9 and s_en_U='1') else
			  '0';
	
			  
	
	-- next state logic/output logic for second divider
	s_next_U <= (others=>'0') when (s_reg_U=9 and s_en_U='1') else
				 s_reg_U + 1 when s_en_U='1' else
				 s_reg_U;
				 
	s_next_D <= (others=>'0') when (s_reg_D=5 and s_en_D='1') else
				 s_reg_D + 1 when s_en_D='1' else
				 s_reg_D;
			  
	m_en_U <= '1' when (s_reg_D=5 and s_en_D='1') else
			  '0';
			  
	m_en_D <= '1' when (m_reg_U=9 and m_en_U='1') else
			  '0';
			  
			  
	-- next-state logic for minute divider
	m_next_U <= (others=>'0') when (m_reg_U=9 and m_en_U='1') else
				 m_reg_U + 1	when (m_en_U='1') else
				 m_reg_U;
				 
	m_next_D <= (others=>'0') when (m_reg_D=5 and m_en_D='1') else
				 m_reg_D + 1	when (m_en_D='1') else
				 m_reg_D;
	
	-- output logic
	csec <= std_logic_vector(c_reg_D & c_reg_U);
	sec <= std_logic_vector("0" & s_reg_D & s_reg_U);
	min <= std_logic_vector("0" & m_reg_D & m_reg_U);
	
end architecture;
