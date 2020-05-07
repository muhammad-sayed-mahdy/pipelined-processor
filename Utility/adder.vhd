LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
-- n-bit adder
ENTITY adder IS
        GENERIC (N : integer := 16);
        PORT(A, B : IN std_logic_vector(N-1  DOWNTO 0);
            Cin : IN std_logic;  
            Cout : OUT std_logic;
            SUM : OUT std_logic_vector(N-1 DOWNTO 0));
END adder;

ARCHITECTURE arch1 OF adder IS
        COMPONENT fAdder IS
        PORT(A, B, Cin : IN std_logic;
            Cout, SUM : OUT std_logic);
        END COMPONENT;
        SIGNAL TEMP : std_logic_vector(N-1 DOWNTO 0);
BEGIN
        f0: fAdder PORT MAP(A(0), B(0), Cin, TEMP(0), SUM(0));
        loop1: FOR i IN 1 TO N-1 GENERATE
                fx: fAdder PORT MAP (A(i), B(i), TEMP(i-1), TEMP(i), SUM(i));
            END GENERATE;
            Cout <= TEMP(N-1);
END arch1;
