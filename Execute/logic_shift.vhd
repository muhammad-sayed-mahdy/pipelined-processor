LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity logic_shift is 
    generic (n: integer := 32);
    port(A, B: in std_logic_vector(n-1 downto 0);
        S : in std_logic_vector(1 downto 0);
        F: out std_logic_vector(n-1 downto 0);
        Cout: out std_logic);
end entity logic_shift;

architecture logic_shift_arch of logic_shift is
    signal Ashl, Ashr: std_logic_vector(n-1 downto 0);
    signal Cshl, Cshr: std_logic;
    begin

        shift : process( A, B )
        variable vAshl, vAshr: std_logic_vector(n-1 downto 0);
        variable vCshl, vCshr: std_logic;
        begin
            vAshl := A;
            vAshr := A;
            vCshl := '0';
            vCshr := '0';
            if  to_integer(unsigned(B)) <= n then
                l1 : for i in 0 to to_integer(unsigned(B))-1 loop
                    vCshl := vAshl(n-1);
                    vAshl := vAshl(n-2 downto 0) & '0';
                    vCshr := vAshr(0);
                    vAshr := '0' & vAshr(n-1 downto 1);
                end loop ; -- l1
            else
                vAshl := (others => '0');
                vAshr := (others => '0');
            end if ;
            Ashl <= vAshl;
            Ashr <= vAshr;
            Cshl <= vCshl;
            Cshr <= vCshr;
        end process ; -- shift

        F <= Ashl when (S = "00")
        else Ashr when (S = "01")
        else (A and B) when (S = "10")
        else (A or B);

        Cout <= Cshl when (S = "00")
        else Cshr when (S = "01");
    end logic_shift_arch;
