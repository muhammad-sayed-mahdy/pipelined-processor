LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY hAdder IS
        PORT(A, B: IN std_logic;
            Cout, SUM: OUT std_logic);
END hAdder;

architecture arch1 of hAdder is 
begin 
        SUM <= A xor B; 
        Cout <= A and B; 
end arch1; 

