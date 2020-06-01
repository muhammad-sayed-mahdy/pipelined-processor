LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY memory_stage IS
    GENERIC (n : INTEGER := 32);
    PORT (
        clk, memRead, memWrite : IN std_logic;
        opType : IN std_logic_vector(1 DOWNTO 0); --(00: other, 01: swap, 10: stack, 11: out)
        oldSP, datain, address : IN std_logic_vector(n - 1 DOWNTO 0); --dst1, dst2 of alu
        dataout : OUT std_logic_vector(n - 1 DOWNTO 0)
    );
END ENTITY memory_stage;

ARCHITECTURE memory_stage_arch OF memory_stage IS
    SIGNAL ramDataout, addressi : std_logic_vector(n - 1 DOWNTO 0);
BEGIN
    addressi <= oldSP WHEN (opType = "10" AND memWrite = '1') --PUSH or CALL
        ELSE address;

    ram : ENTITY work.memory GENERIC MAP(dataW => 16, busW => n, addressW => 11)
        PORT MAP(clk, memWrite, memRead, addressi(10 DOWNTO 0), datain, ramDataout);
    dataout <= ramDataout WHEN (memRead = '1' OR memWrite = '1')
        ELSE datain;
END memory_stage_arch;