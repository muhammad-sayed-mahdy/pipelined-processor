library ieee;
use ieee.std_logic_1164.all;

entity fullAddSub is
    port (
        A, B, Cin, sub : in std_logic;
        F, Cout : out std_logic
    );
end fullAddSub;

architecture fullAddSub_arch of fullAddSub is 
    signal x, X2, A2 : std_logic;
begin
    x <= (A xor B);
    F <= x xor Cin;
    X2 <= not x when sub = '1' else x;
    A2 <= not A when sub = '1' else A;
    Cout <= (x2 and Cin) or (A2 and B);
end fullAddSub_arch ;