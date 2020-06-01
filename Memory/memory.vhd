LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory IS
    GENERIC (
        dataW : INTEGER := 16;
        busW : INTEGER := 128;
        addressW : INTEGER := 11);
    PORT (
        clk : IN std_logic;
        we : IN std_logic;
        re : IN std_logic;
        address : IN std_logic_vector(addressW - 1 DOWNTO 0);
        datain : IN std_logic_vector(busW - 1 DOWNTO 0);
        dataout : OUT std_logic_vector(busW - 1 DOWNTO 0));
END ENTITY memory;

ARCHITECTURE syncrama OF memory IS

    TYPE ram_type IS ARRAY(0 TO ((2 ** addressW) - 1)) OF std_logic_vector(dataW - 1 DOWNTO 0);
    SIGNAL memory : ram_type := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS (clk) IS
    BEGIN
        IF (falling_edge(clk) AND we = '1') THEN
            l1 : FOR i IN 0 TO (busW/dataW) - 1 LOOP
                memory(to_integer(unsigned(address)) + (busW/dataW) - 1 - i) <= datain((i + 1) * dataW - 1 DOWNTO i * dataW);
            END LOOP; --l1
        END IF;

    END PROCESS;

    PROCESS (memory, address, re)
    BEGIN
        IF (re = '1') THEN
            l2 : FOR i IN 0 TO (busW/dataW) - 1 LOOP
                dataout((i + 1) * dataW - 1 DOWNTO i * dataW) <= memory(to_integer(unsigned(address)) + (busW/dataW) - 1 - i);
            END LOOP; --l2
        END IF;
    END PROCESS;
END syncrama;