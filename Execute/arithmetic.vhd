library ieee;
use ieee.std_logic_1164.all;

entity arithmetic is
    generic (n : integer := 32);
    port (
        A, B : in std_logic_vector (n-1 downto 0);
        Cin : in std_logic;
        S : in std_logic_vector(1 downto 0);
        F : out std_logic_vector (n-1 downto 0);
        Cout, O : out std_logic
    ) ;
end arithmetic;

architecture arithmetic_arch of arithmetic is

    signal Bi : std_logic_vector (n-1 downto 0);
    signal Cini, sub : std_logic;
begin
    Bi <= B when (S(1) = '0')
    else (others => '0');

    Cini <= '1' when (S(1) = '1')
    else Cin;

    sub <= '1' when (S(0) = '1')
    else '0';

    u0: entity work.nFullAddSub generic map(n)
        port map (A, Bi, Cini, sub, F, Cout, O);

end arithmetic_arch ;