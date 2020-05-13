LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY memory_stage IS
    GENERIC (n : INTEGER := 32);
    PORT (
        clk, memRead, memWrite : IN std_logic;
        datain, address : IN std_logic_vector(n - 1 DOWNTO 0); --dst1, dst2 of alu
        dataout : OUT std_logic_vector(n - 1 DOWNTO 0)
    );
END ENTITY memory_stage;

ARCHITECTURE memory_stage_arch OF memory_stage IS
    SIGNAL ramDataout : std_logic_vector(n - 1 DOWNTO 0);
BEGIN
    ram : ENTITY work.memory GENERIC MAP(dataW => 16, busW => n, addressW => 11)
        PORT MAP(clk, memWrite, address(10 DOWNTO 0), datain, ramDataout);
    dataout <= ramDataout WHEN (memRead = '1' OR memWrite = '1')
    ELSE datain;
END memory_stage_arch;