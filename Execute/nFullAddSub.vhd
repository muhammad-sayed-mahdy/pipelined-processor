library ieee;
use ieee.std_logic_1164.all;

entity nFullAddSub is
    generic (n : integer := 32);
    port (
        A, B : in std_logic_vector (n-1 downto 0);
        Cin, sub : in std_logic;
        F : out std_logic_vector (n-1 downto 0);
        Cout, O : out std_logic
    ) ;
end nFullAddSub;

architecture nFullAddSub_arch of nFullAddSub is

    signal X : std_logic_vector (n-1 downto 0);

begin
    f0: entity work.fullAddSub port map (A(0), B(0), Cin, sub, F(0), X(0));
    loop1: for i in 1 to n-1 generate
        fi: entity work.fullAddSub port map (A(i), B(i), X(i-1), sub, F(i), X(i));
    end generate;
    Cout <= X(n-1);
    O <= X(n-1) xor X(n-2);     --overflow flag is set when carry in sign bit != carry out
end nFullAddSub_arch ; 