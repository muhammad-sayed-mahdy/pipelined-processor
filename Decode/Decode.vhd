LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.arrays_pkg.all;

ENTITY Decode IS
    PORT(   clk                 : in std_logic;
            reg_arr             : in reg_array;
            instruction         : inout std_logic_vector(15 DOWNTO 0);
            incrementedPc       : inout std_logic_vector(31 DOWNTO 0);
            src1, src2          : out std_logic_vector(31 DOWNTO 0);
            Rsrc1, Rsrc2        : out std_logic_vector(2 DOWNTO 0);
            aluSrc2             : out std_logic_vector(1 DOWNTO 0);
            Rdst                : out std_logic_vector(2 DOWNTO 0);
            aluCode             : out std_logic_vector(3 DOWNTO 0);
            memRead, memWrite   : out std_logic;
            operation           : out std_logic_vector(1 DOWNTO 0);
            memPCWB, registerWB : out std_logic;
            Rsrc1E, Rsrc2E      : out std_logic
        );
END ENTITY Decode;


ARCHITECTURE archdecode OF Decode IS
    COMPONENT reg IS
        GENERIC ( n : integer := 32);
        PORT( E, Clk,Rst        : IN std_logic;
                d               : IN std_logic_vector(n-1 DOWNTO 0);
                q               : OUT std_logic_vector(n-1 DOWNTO 0));
    END COMPONENT;

    signal isNop                : std_logic;

BEGIN

    Rdst <= instruction(6 downto 4);

    memRead <= '1' when instruction(15 downto 12) = "1101" OR
     instruction(15 downto 10) = "101000" OR 
     instruction(15 downto 10) = "101100"
    else '0';

    memWrite <= '1' when (instruction(15 downto 13) = "101" AND instruction(10) = '1') OR
     instruction(15 downto 9) = "1100001"
    else '0';

    operation <= "01" when instruction(15 downto 12) = "0010"
    else "10" when instruction(15 downto 12) = "0010"
    else "11" when
    else "00"

    memPCWB <= '1' when instruction(15 downto 12) = "1101"
    else '0';

    registerWB <= '1' when instruction(15) = '0' OR
     (instruction(15 downto 13) = "100" AND (NOT (instruction(12 downto 10) = "101"))) OR
     (instruction(15 downto 13) = "101" AND instruction(10) = '0')
    else '0';

END archdecode;