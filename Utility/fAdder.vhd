LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY fAdder IS
        PORT(A, B, Cin : IN std_logic;
            Cout, SUM: OUT std_logic);
END fAdder;

architecture arch1 of fAdder is 
signal i1, i2, i3 : std_logic;

COMPONENT hAdder IS
        PORT(A, B: IN std_logic;
            Cout, SUM: OUT std_logic);
END COMPONENT;

begin
    u1 : hAdder port map (A, B, i1, i2);
    u2 : hAdder port map (i2, cin, i3, sum); 
    Cout <= i3 OR i1; 
end arch1 ; 

