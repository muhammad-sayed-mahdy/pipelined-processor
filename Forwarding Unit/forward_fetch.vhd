LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY forward_fetch IS
    GENERIC (n : INTEGER := 32);
    PORT (
        Rdst_fetch : IN std_logic_vector(2 DOWNTO 0);
        Rdst_decode : IN std_logic_vector(2 DOWNTO 0);
        Rdst_decode_en : IN std_logic;
        Rdst_decode_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rdst_execute : IN std_logic_vector(2 DOWNTO 0);
        Rdst_execute_en : IN std_logic;
        Rdst_execute_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rsrc2_execute : IN std_logic_vector(2 DOWNTO 0);
        Rsrc2_execute_en : IN std_logic;
        Rsrc2_execute_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rdst_memory : IN std_logic_vector(2 DOWNTO 0);
        Rdst_memory_en : IN std_logic;
        Rdst_memory_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rsrc2_memory : IN std_logic_vector(2 DOWNTO 0);
        Rsrc2_memory_en : IN std_logic;
        Rsrc2_memory_val : IN std_logic_vector(n - 1 DOWNTO 0);
        forwarded_Rdst_en : OUT std_logic;
        forwarded_Rdst_val : OUT std_logic_vector(n - 1 DOWNTO 0));
END ENTITY forward_fetch;

ARCHITECTURE forward_fetch_rtl OF forward_fetch IS
BEGIN
    forwarded_Rdst_en <= '1' WHEN (((Rdst_decode_en = '1') AND (Rdst_fetch = Rdst_decode))
        OR ((Rdst_execute_en = '1') AND (Rdst_fetch = Rdst_execute))
        OR ((Rsrc2_execute_en = '1') AND (Rdst_fetch = Rsrc2_execute))
        OR ((Rdst_memory_en = '1') AND (Rdst_fetch = Rdst_memory))
        OR ((Rsrc2_memory_en = '1') AND (Rdst_fetch = Rsrc2_memory)))
        ELSE
        '0';

    forwarded_Rdst_val <= Rdst_decode_val WHEN ((Rdst_decode_en = '1') AND (Rdst_fetch = Rdst_decode))
        ELSE
        Rdst_execute_val WHEN ((Rdst_execute_en = '1') AND (Rdst_fetch = Rdst_execute))
        ELSE
        Rsrc2_execute_val WHEN ((Rsrc2_execute_en = '1') AND (Rdst_fetch = Rsrc2_execute))
        ELSE
        Rdst_memory_val WHEN ((Rdst_memory_en = '1') AND (Rdst_fetch = Rdst_memory))
        ELSE
        Rsrc2_memory_val WHEN ((Rsrc2_memory_en = '1') AND (Rdst_fetch = Rsrc2_memory));

END forward_fetch_rtl;