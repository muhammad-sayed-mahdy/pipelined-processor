LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.arrays_pkg.all;

ENTITY forward_execute IS
    GENERIC (n : INTEGER := 32);
    PORT (
        Rsrc1, Rsrc2                        : IN std_logic_vector(2 DOWNTO 0);
        Rsrc1_enable, Rsrc2_enable          : IN std_logic;
        Rdst_WB, Rdst_Mem                   : IN std_logic_vector(2 DOWNTO 0);
        WB_WB, Mem_WB                       : IN std_logic;
        Rsrc1_WB, Rsrc1_Mem                 : IN std_logic_vector(2 DOWNTO 0);
        FR1_WB, FR2_WB                      : IN std_logic_vector(n - 1 DOWNTO 0);
        FR1_Mem, FR2_Mem                    : IN std_logic_vector(n - 1 DOWNTO 0);
        decode_Operand1, decode_Operand2    : IN std_logic_vector(n - 1 DOWNTO 0);
        op_Mem, op_WB, op_E                 : IN std_logic_vector (1 downto 0);
        Operand1, Operand2                  : OUT std_logic_vector(n - 1 DOWNTO 0)
        );
END ENTITY forward_execute;

ARCHITECTURE forward_execute_arch OF forward_execute IS

    signal FRsrc1_mem, FRsrc1_wb            : std_logic_vector(31 DOWNTO 0);
    signal FRsrc2_mem, FRsrc2_wb            : std_logic_vector(31 DOWNTO 0);
    signal Enable_mem_operand1              : std_logic;
    signal Enable_mem_operand2              : std_logic;
    signal Enable_WB_operand1               : std_logic;
    signal Enable_WB_operand2               : std_logic;

BEGIN

    Enable_mem_operand1 <= '0' when Rsrc1_enable = '0'
    else '1' when Rsrc1 = Rdst_Mem AND Mem_WB = '1'
    else '1' when Rsrc1 = Rsrc1_Mem AND op_Mem = "01"
    else '0';

    Enable_WB_operand1 <= '0' when Rsrc1_enable = '0'
    else '1' when Rsrc1 = Rdst_WB AND WB_WB = '1'
    else '1' when Rsrc1 = Rsrc1_WB AND op_WB = "01"
    else '0';

    Enable_mem_operand2 <= '0' when Rsrc2_enable = '0'
    else '1' when Rsrc2 = Rdst_Mem AND Mem_WB = '1'
    else '1' when (Rsrc2 = Rsrc1_Mem AND op_Mem = "01") OR (op_Mem = "10")
    else '0';

    Enable_WB_operand2 <= '0' when Rsrc2_enable = '0'
    else '1' when Rsrc2 = Rdst_WB AND WB_WB = '1'
    else '1' when (Rsrc2 = Rsrc1_WB AND op_WB = "01") OR (op_WB = "10")
    else '0';

    FRsrc1_mem <= decode_Operand1 when Rsrc1_enable = '0'
    else FR1_Mem when Rsrc1 = Rdst_Mem AND Mem_WB = '1'
    else FR2_Mem when Rsrc1 = Rsrc1_Mem AND op_Mem = "01"
    else decode_Operand1;

    FRsrc1_wb <= decode_Operand1 when Rsrc1_enable = '0'
    else FR1_WB when Rsrc1 = Rdst_WB AND WB_WB = '1'
    else FR2_WB when Rsrc1 = Rsrc1_WB AND op_WB = "01"
    else decode_Operand1;

    FRsrc2_mem <= decode_Operand2 when Rsrc2_enable = '0'
    else FR2_Mem when (Rsrc2 = Rsrc1_Mem AND op_Mem = "01") OR (op_Mem = "10")
    else FR1_Mem when Rsrc2 = Rdst_Mem AND Mem_WB = '1'
    else decode_Operand2;

    FRsrc2_wb <= decode_Operand2 when Rsrc2_enable = '0'
    else FR2_WB when (Rsrc2 = Rsrc1_WB AND op_WB = "01") OR (op_WB = "10")
    else FR1_WB when Rsrc2 = Rdst_WB AND WB_WB = '1'
    else decode_Operand2;

    Operand1 <= FRsrc1_mem when Enable_mem_operand1 = '1'
    else FRsrc1_wb when Enable_WB_operand1 = '1'
    else decode_Operand1;

    Operand2 <= FRsrc2_mem when Enable_mem_operand2 = '1'
    else FRsrc2_wb when Enable_WB_operand2 = '1'
    else decode_Operand2;

END forward_execute_arch;