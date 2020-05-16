LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.arrays_pkg.all;

ENTITY Decode IS
    PORT(   clk                 : in std_logic;
            reg_arr             : in reg_array;
            spReg, inPort       : in std_logic_vector(31 DOWNTO 0);
            instruction         : in std_logic_vector(15 DOWNTO 0);
            zflag, decision     : in std_logic;
            curinstruction      : out std_logic_vector(3 DOWNTO 0);
            incrementedPc       : inout std_logic_vector(31 DOWNTO 0);
            src1, src2          : out std_logic_vector(31 DOWNTO 0);
            Rsrc1, Rsrc2        : out std_logic_vector(2 DOWNTO 0);
            aluSrc2             : out std_logic_vector(1 DOWNTO 0);
            Rdst                : out std_logic_vector(2 DOWNTO 0);
            aluCode             : out std_logic_vector(3 DOWNTO 0);
            memRead, memWrite   : out std_logic;
            operation           : out std_logic_vector(1 DOWNTO 0);
            memPCWB, registerWB : out std_logic;
            Rsrc1E, Rsrc2E      : out std_logic;
            isJz, chdecision    : out std_logic;
            rightPc             : out std_logic_vector(31 DOWNTO 0)
        );
END ENTITY Decode;


ARCHITECTURE archdecode OF Decode IS
    signal auxR1, auxR2         : std_logic_vector(2 DOWNTO 0);
    signal auxOp                : std_logic_vector(1 DOWNTO 0);
    signal isStack              : std_logic;
BEGIN

    
    Rsrc1 <= auxR1;
    Rsrc2 <= auxR2;
    operation <= auxOp;

    isStack <= '1' when auxOp = "10"
    else '0';

    curinstruction <= instruction(3 downto 0);

    src1 <= incrementedPc when instruction(15 downto 9) = "1100001"
    else inPort when instruction(15 downto 10) = "100110"
    else reg_arr(to_integer(unsigned(auxR1)));

    src2 <= spReg when isStack = '1'
    else reg_arr(to_integer(unsigned(auxR2)));

    auxR1 <= instruction(11 downto 9) when instruction(15) = '0' AND (instruction(14) = '1' OR instruction(13) = '1')
    else instruction(6 downto 4);

    auxR2 <= instruction(6 downto 4) when instruction(15 downto 12) = "0010"
    else instruction(3 downto 1);

    Rsrc1E <= '1' when instruction(15) = '0' OR
     (instruction(15 downto 13) = "100" AND (not(instruction(12 downto 10) = "110"))) OR
     (instruction(15 downto 13) = "101" AND instruction(10) = '1') OR
     instruction(15 downto 12) = "1100"
    else '0';

    Rsrc2E <= '1' when instruction(15 downto 14) = "01" OR instruction(15 downto 12) = "0010"
    else '0';

    aluSrc2 <= "00" when instruction(15 downto 13) = "000" OR
     instruction(15 downto 12) = "0011" OR instruction(15 downto 10) = "101010"
    else "01" when instruction(15 downto 11) = "10110"
    else "10";

    Rdst <= instruction(6 downto 4);

    memRead <= '1' when instruction(15 downto 12) = "1101" OR
     instruction(15 downto 10) = "101000" OR 
     instruction(15 downto 10) = "101100"
    else '0';

    memWrite <= '1' when (instruction(15 downto 13) = "101" AND instruction(10) = '1') OR
     instruction(15 downto 9) = "1100001"
    else '0';

    auxOp <= "01" when instruction(15 downto 12) = "0010"
    else "10" when instruction(15 downto 11) = "10100" OR
     (instruction(15 downto 13) = "110" AND (instruction(12) = '1' OR instruction(9) = '1'))
    else "11" when instruction(15 downto 10) = "100101"
    else "00";

    memPCWB <= '1' when instruction(15 downto 12) = "1101"
    else '0';

    registerWB <= '1' when instruction(15) = '0' OR
     (instruction(15 downto 13) = "100" AND (NOT (instruction(12 downto 10) = "101"))) OR
     (instruction(15 downto 13) = "101" AND instruction(10) = '0')
    else '0';

    aluCode <= "0001" when auxOp = "01"
    else "0010" when instruction(15 downto 8) = "10010000"
    else "0100" when instruction(15 downto 12) = "0000"
    else "0101" when instruction(15 downto 12) = "0001"
    else "0110" when instruction(15 downto 12) = "0110"
    else "0111" when instruction(15 downto 12) = "0111"
    else "1000" when instruction(15 downto 12) = "0011" OR instruction(15 downto 12) = "0100" OR
     (isStack = '1' AND (instruction(15 downto 10) = "101000" OR instruction(15 downto 12) = "1101")) 
    else "1001" when instruction(15 downto 12) = "0101" OR isStack = '1'
    else "1010" when instruction(15 downto 8) = "10010001"
    else "1011" when instruction(15 downto 8) = "10010010"
    else "0000";

    isJz <= '1' when instruction(15 downto 9) = "1100100"
    else '0';

    rightPc <= incrementedPc when zflag = '0'
    else reg_arr(to_integer(unsigned(auxR1)));

    chdecision <= decision XOR zflag when instruction(15 downto 9) = "1100100"
    else '0';

END archdecode;