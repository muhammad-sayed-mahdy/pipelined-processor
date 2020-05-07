LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--Branch Prediction Ram
ENTITY branch_prediction_ram IS
	GENERIC ( n : integer := 8);
	PORT(
		clk 		: IN std_logic;
		rst			: IN std_logic;
		we  		: IN std_logic;
		address 	: IN  std_logic_vector(n-1 DOWNTO 0);
		take  		: IN  std_logic;
		outState	: OUT std_logic
	);
END ENTITY branch_prediction_ram;

ARCHITECTURE syncrama OF branch_prediction_ram IS
	TYPE ram_type IS ARRAY(0 TO 255) OF std_logic_vector(1 downto 0);

	SIGNAL currVal, nextVal		: std_logic_vector(1 downto 0);
	SIGNAL ram 					: ram_type := (others => "00");
	
BEGIN
	currVal <= ram(to_integer(unsigned(address(n-1 downto 0))));
	outState <= currVal(1);

	process (currVal, take) 
	begin
		case currVal is
			when "00" =>
				if take = '1' then nextVal <= "01"; else nextVal <= "00"; end if;
			when "01" =>
				if take = '1' then nextVal <= "10"; else nextVal <= "00"; end if;
			when "10" =>
				if take = '1' then nextVal <= "11"; else nextVal <= "01"; end if;
			when others =>
				if take = '1' then nextVal <= "11"; else nextVal <= "10"; end if;
		end case;
	end process;
	
	
	process (clk, rst)
    begin
      if rst = '1' then
		ram <= (others => "00");
      elsif we = '1' and rising_edge(clk) then 
	  	ram(to_integer(unsigned(address(n-1 downto 0)))) <= nextVal;
      end if;
    end process;
END syncrama;
