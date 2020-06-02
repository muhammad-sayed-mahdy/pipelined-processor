LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.arrays_pkg.all;

ENTITY forward_decode IS
    GENERIC (n : INTEGER := 32);
    PORT (
        Rsrc                                : IN std_logic_vector(2 DOWNTO 0);
        reg_arr                             : in reg_array;
        Rdst_Ex, Rdst_Mem                   : IN std_logic_vector(2 DOWNTO 0);
        WB_Ex, WB_Mem                       : IN std_logic;
        Rsrc1_Ex, Rsrc1_Mem                 : IN std_logic_vector(2 DOWNTO 0);
        FR1_Ex, FR2_Ex                      : IN std_logic_vector(n - 1 DOWNTO 0);
        FR1_Mem, FR2_Mem                    : IN std_logic_vector(n - 1 DOWNTO 0);
        op_Mem, op_Ex                       : IN std_logic_vector (1 downto 0);
        Operand1                            : OUT std_logic_vector(n - 1 DOWNTO 0)
        );
END ENTITY forward_decode;

ARCHITECTURE forward_decode_arch OF forward_decode IS
BEGIN

    Operand1 <= FR1_Ex when Rsrc = Rdst_Ex AND WB_Ex = '1'
    else FR2_Ex when Rsrc = Rsrc1_Ex AND op_Ex = "01"
    else FR1_Mem when Rsrc = Rdst_Mem AND WB_Mem = '1'
    else FR2_Mem when Rsrc = Rsrc1_Mem AND op_Mem = "01"
    else reg_arr(to_integer(unsigned(Rsrc)));

END forward_decode_arch;