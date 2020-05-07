LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory IS
    GENERIC (
        dataW : INTEGER := 128;
        addressW : INTEGER := 11);
    PORT (
        clk : IN std_logic;
        we : IN std_logic;
        address : IN std_logic_vector(addressW - 1 DOWNTO 0);
        datain : IN std_logic_vector(dataW - 1 DOWNTO 0);
        dataout : OUT std_logic_vector(dataW - 1 DOWNTO 0));
END ENTITY memory;

ARCHITECTURE syncrama OF memory IS

    SIGNAL memoryH : INTEGER := to_integer(shift_left(to_unsigned(1, addressW + 1), addressW)) - 1;
    TYPE ram_type IS ARRAY(0 TO memoryH) OF std_logic_vector(dataW - 1 DOWNTO 0);
    SIGNAL memory : ram_type := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS (clk) IS
    BEGIN
        IF (falling_edge(clk) AND we = '1') THEN
            memory(to_integer(unsigned(address(addressW - 1 DOWNTO 0)))) <= datain;
        ELSIF (rising_edge(clk)) THEN
            dataout <= memory(to_integer(unsigned(address(addressW - 1 DOWNTO 0))));
        END IF;
    END PROCESS;
END syncrama;