LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY forward_fetch IS
    GENERIC (n : INTEGER := 32);
    PORT (
        opcode : IN std_logic_vector(5 DOWNTO 0);
        Rdst_fetch : IN std_logic_vector(2 DOWNTO 0);
        Rdst_decode : IN std_logic_vector(2 DOWNTO 0);
        force_pc    : IN std_logic;
        zflag       : IN std_logic;
        Rdst_decode_en : IN std_logic;
        Rdst_decode_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rdst_execute : IN std_logic_vector(2 DOWNTO 0);
        Rdst_execute_en : IN std_logic;
        Rdst_execute_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rsrc1_execute : IN std_logic_vector(2 DOWNTO 0);
        execute_opType : IN std_logic_vector (1 downto 0);
        Rsrc1_execute_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rdst_memory : IN std_logic_vector(2 DOWNTO 0);
        Rdst_memory_en : IN std_logic;
        Rdst_memory_val : IN std_logic_vector(n - 1 DOWNTO 0);
        Rsrc1_memory : IN std_logic_vector(2 DOWNTO 0);
        memory_opType : IN std_logic_vector (1 downto 0);
        Rsrc1_memory_val : IN std_logic_vector(n - 1 DOWNTO 0);
        forwarded_Rdst_en : OUT std_logic;
        forwarded_Rdst_val : OUT std_logic_vector(n - 1 DOWNTO 0));
END ENTITY forward_fetch;

ARCHITECTURE forward_fetch_rtl OF forward_fetch IS
    SIGNAL check_fetch_en, check_decode_en : std_logic;
    SIGNAL check_fetch_val, check_decode_val : std_logic_vector(n - 1 DOWNTO 0);
BEGIN
    check_fetch_en <= '1' WHEN (((Rdst_decode_en = '1') AND (Rdst_fetch = Rdst_decode))
        OR ((Rdst_execute_en = '1') AND (Rdst_fetch = Rdst_execute))
        OR ((execute_opType = "01") AND (Rdst_fetch = Rsrc1_execute))   --swap
        OR ((Rdst_memory_en = '1') AND (Rdst_fetch = Rdst_memory))
        OR ((memory_opType = "01") AND (Rdst_fetch = Rsrc1_memory)))    --swap
        ELSE
        '0';

    check_fetch_val <= Rdst_decode_val WHEN (opcode = "100110")   -- (Rdst_decode_en = '1') AND (Rdst_fetch = Rdst_decode)
        ELSE
        Rdst_execute_val WHEN ((Rdst_execute_en = '1') AND (Rdst_fetch = Rdst_execute))
        ELSE
        Rsrc1_execute_val WHEN ((execute_opType = "01") AND (Rdst_fetch = Rsrc1_execute))
        ELSE
        Rdst_memory_val WHEN ((Rdst_memory_en = '1') AND (Rdst_fetch = Rdst_memory))
        ELSE
        Rsrc1_memory_val WHEN ((memory_opType = "01") AND (Rdst_fetch = Rsrc1_memory))
        ELSE
        (others => '0');

    check_decode_en <= '1' WHEN ((Rdst_execute_en = '1') AND (Rdst_decode = Rdst_execute))
    OR ((execute_opType = "01") AND (Rdst_decode = Rsrc1_execute))   --swap
    OR ((Rdst_memory_en = '1') AND (Rdst_decode = Rdst_memory))
    OR ((memory_opType = "01") AND (Rdst_decode = Rsrc1_memory))    --swap
    ELSE
    '0';

    check_decode_val <= Rdst_execute_val WHEN ((Rdst_execute_en = '1') AND (Rdst_decode = Rdst_execute))
    ELSE
    Rsrc1_execute_val WHEN ((execute_opType = "01") AND (Rdst_decode = Rsrc1_execute))
    ELSE
    Rdst_memory_val WHEN ((Rdst_memory_en = '1') AND (Rdst_decode = Rdst_memory))
    ELSE
    Rsrc1_memory_val WHEN ((memory_opType = "01") AND (Rdst_decode = Rsrc1_memory))
    ELSE
    (others => '0');

    forwarded_Rdst_en <= check_decode_en WHEN force_pc = '1' AND zflag = '1'
    ELSE check_fetch_en;

    forwarded_Rdst_val <= check_decode_val WHEN force_pc = '1' AND zflag = '1'
    ELSE check_fetch_val;

END forward_fetch_rtl;